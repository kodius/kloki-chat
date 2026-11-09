import 'dart:async';
import 'dart:convert';

import 'package:material_ui/material_ui.dart';

import '../api/exception.dart';
import '../api/model/web_auth.dart';
import '../api/route/kloki.dart';
import '../generated/l10n/zulip_localizations.dart';
import '../log.dart';
import 'app_bar.dart';
import 'dialog.dart';
import 'icons.dart';
import 'login.dart';
import 'page.dart';
import 'store.dart';
import 'text.dart';
import 'theme.dart';

/// The person's companies in Kloki, to switch the chat between them,
/// as Kloki's own company switcher does.
///
/// It works with the Kloki session from signing in through Kloki
/// (see [KlokiLinkSignIn.beginWebSignIn]); without one,
/// it offers that sign-in.
/// Switching goes to the account already here for that company's chat,
/// or signs in to it without the browser.
class KlokiOrganizationsPage extends StatefulWidget {
  const KlokiOrganizationsPage({super.key});

  static AccountRoute<void> buildRoute(BuildContext context) {
    return MaterialAccountWidgetRoute(context: context,
      page: const KlokiOrganizationsPage());
  }

  @override
  State<KlokiOrganizationsPage> createState() => _KlokiOrganizationsPageState();
}

class _KlokiOrganizationsPageState extends State<KlokiOrganizationsPage> {
  Future<List<KlokiProfile>>? _profiles;
  String? _loadedForSession;

  /// The profile being switched to, if any.
  String? _switchingTo;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final session = GlobalStoreWidget.settingsOf(context).klokiSession;
    if (session != _loadedForSession) {
      _loadedForSession = session;
      _profiles = session == null ? null : _load(session);
    }
  }

  Future<List<KlokiProfile>> _load(String session) async {
    final globalStore = GlobalStoreWidget.of(context);
    final connection = globalStore.apiConnection(
      realmUrl: kKlokiApiUrl, zulipFeatureLevel: null);
    try {
      return await getKlokiProfiles(connection, session: session);
    } on KlokiApiException catch (e) {
      if (e.sessionRefused) {
        // Signed out of Kloki, or expired; this offers signing in again.
        unawaited(globalStore.settings.setKlokiSession(null));
      }
      rethrow;
    } finally {
      connection.close();
    }
  }

  /// The profile [session] stands for: its JWT's `user_id`.
  static String? _sessionUserId(String session) {
    final parts = session.split('.');
    if (parts.length != 3) return null;
    try {
      final claims = jsonDecode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))));
      return switch (claims) {
        {'user_id': int userId} => userId.toString(),
        {'user_id': String userId} => userId,
        _ => null,
      };
    } on FormatException {
      return null;
    }
  }

  Future<void> _switchTo(KlokiProfile profile) async {
    final globalStore = GlobalStoreWidget.of(context);
    final zulipLocalizations = ZulipLocalizations.of(context);
    final session = globalStore.settings.klokiSession;
    if (session == null) return;

    setState(() {
      _switchingTo = profile.userId;
    });
    final connection = globalStore.apiConnection(
      realmUrl: kKlokiApiUrl, zulipFeatureLevel: null);
    try {
      final KlokiLoginLink link;
      try {
        final profileSession = await switchKlokiProfile(connection,
          session: session, userId: profile.userId);
        await globalStore.settings.setKlokiSession(profileSession);
        final login = await postKlokiChatLoginToken(connection,
          session: profileSession);
        link = KlokiLoginLink.forRealm(realm: login.realmUrl, token: login.token);
      } finally {
        connection.close();
      }
      if (!mounted) return;
      await KlokiLinkSignIn.signIn(context, link, onFailure: (_) async {
        if (!mounted) return;
        _showSwitchFailed(zulipLocalizations, profile);
      });
    } catch (e) {
      assert(debugLog(e.toString()));
      if (!mounted) return;
      switch (e) {
        case KlokiApiException(sessionRefused: true):
          await globalStore.settings.setKlokiSession(null);
        case KlokiApiException(:final code?) when code.startsWith('chat_'):
          showErrorDialog(context: context,
            title: zulipLocalizations.klokiOrganizationSwitchFailedTitle,
            message: zulipLocalizations.klokiOrganizationNoChat(profile.companyName));
        case NetworkException():
          showErrorDialog(context: context,
            title: zulipLocalizations.errorCouldNotConnectTitle,
            message: zulipLocalizations.errorLoginCouldNotConnect(kKlokiApiUrl.toString()));
        default:
          _showSwitchFailed(zulipLocalizations, profile);
      }
    } finally {
      if (mounted) {
        setState(() {
          _switchingTo = null;
        });
      }
    }
  }

  void _showSwitchFailed(ZulipLocalizations zulipLocalizations, KlokiProfile profile) {
    showErrorDialog(context: context,
      title: zulipLocalizations.klokiOrganizationSwitchFailedTitle,
      message: zulipLocalizations.klokiOrganizationSwitchFailed(profile.companyName));
  }

  Widget _message(BuildContext context, String text, {Widget? action}) {
    final designVariables = DesignVariables.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(text,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 17, height: 1.4,
              color: designVariables.labelSearchPrompt)),
          if (action != null) ...[
            const SizedBox(height: 20),
            action,
          ],
        ])));
  }

  @override
  Widget build(BuildContext context) {
    final zulipLocalizations = ZulipLocalizations.of(context);
    final session = GlobalStoreWidget.settingsOf(context).klokiSession;
    final profiles = _profiles;

    final Widget body;
    if (session == null || profiles == null) {
      body = _message(context, zulipLocalizations.klokiOrganizationsSignInPrompt,
        action: FilledButton(
          onPressed: () => KlokiLinkSignIn.beginWebSignIn(context),
          child: Text(zulipLocalizations.klokiSignInButton)));
    } else {
      body = FutureBuilder(
        future: profiles,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _message(context, zulipLocalizations.klokiOrganizationsLoadFailed,
              action: TextButton(
                onPressed: () => setState(() {
                  _profiles = _load(session);
                }),
                child: Text(zulipLocalizations.klokiOrganizationsRetry)));
          }
          final list = snapshot.data;
          if (list == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (list.isEmpty) {
            return _message(context, zulipLocalizations.klokiOrganizationsOnlyOne);
          }
          final currentUserId = _sessionUserId(session);
          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            children: [
              for (final profile in list)
                _KlokiOrganizationRow(
                  profile: profile,
                  current: profile.userId == currentUserId,
                  switching: _switchingTo == profile.userId,
                  onTap: _switchingTo != null ? null : () => _switchTo(profile)),
            ]);
        });
    }

    return Scaffold(
      appBar: ZulipAppBar(title: Text(zulipLocalizations.klokiOrganizationsTitle)),
      body: SafeArea(child: body));
  }
}

class _KlokiOrganizationRow extends StatelessWidget {
  const _KlokiOrganizationRow({
    required this.profile,
    required this.current,
    required this.switching,
    required this.onTap,
  });

  final KlokiProfile profile;
  final bool current;
  final bool switching;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final designVariables = DesignVariables.of(context);
    final tone = designVariables.fabBg;
    final name = profile.companyName.trim();
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(children: [
          Container(
            width: 40, height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: tone.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10)),
            child: Text(name.isEmpty ? '?' : name.characters.first.toUpperCase(),
              style: TextStyle(fontSize: 18, color: tone)
                .merge(weightVariableTextStyle(context, wght: 700)))),
          const SizedBox(width: 14),
          Expanded(child: Text(name,
            maxLines: 1, overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 17, color: designVariables.title)
              .merge(weightVariableTextStyle(context, wght: current ? 700 : 500)))),
          if (switching)
            const SizedBox.square(dimension: 20,
              child: CircularProgressIndicator(strokeWidth: 2))
          else if (current)
            Icon(ZulipIcons.check, size: 20, color: tone),
        ])));
  }
}
