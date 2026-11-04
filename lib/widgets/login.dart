import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import '../api/core.dart';
import '../api/exception.dart';
import '../api/model/web_auth.dart';
import '../api/route/account.dart';
import '../api/route/realm.dart';
import '../generated/l10n/zulip_localizations.dart';
import '../log.dart';
import '../model/binding.dart';
import '../model/server_support.dart';
import '../model/store.dart';
import 'actions.dart';
import 'button.dart';
import 'dialog.dart';
import 'home.dart';
import 'icons.dart';
import 'input.dart';
import 'kloki.dart';
import 'page.dart';
import 'store.dart';
import 'text.dart';
import 'theme.dart';

class _LoginSequenceRoute extends MaterialWidgetRoute<void> {
  _LoginSequenceRoute({
    required super.page,
  });
}

enum ServerUrlValidationError {
  empty,
  invalidUrl,
  noUseEmail,
  unsupportedSchemeZulip,
  unsupportedSchemeOther;

  /// Whether to wait until the user presses "submit" to give error feedback.
  ///
  /// True for errors that will often happen when the user just hasn't finished
  /// typing a good URL. False for errors that strongly signal a wrong path was
  /// taken, like when we recognize the form of an email address.
  bool shouldDeferFeedback() {
    switch (this) {
      case empty:
      case invalidUrl:
        return true;
      case noUseEmail:
      case unsupportedSchemeZulip:
      case unsupportedSchemeOther:
        return false;
    }
  }

  String message(ZulipLocalizations zulipLocalizations) {
    switch (this) {
      case empty:
        return zulipLocalizations.serverUrlValidationErrorEmpty;
      case invalidUrl:
        return zulipLocalizations.serverUrlValidationErrorInvalidUrl;
      case noUseEmail:
        return zulipLocalizations.serverUrlValidationErrorNoUseEmail;
      case unsupportedSchemeZulip:
      case unsupportedSchemeOther:
        return zulipLocalizations.serverUrlValidationErrorUnsupportedScheme;
    }
  }
}

class ServerUrlParseResult {
  ServerUrlParseResult.ok(this.url) : error = null;
  ServerUrlParseResult.error(this.error) : url = null;

  final Uri? url;
  final ServerUrlValidationError? error;
}

class ServerUrlTextEditingController extends TextEditingController {
  ServerUrlParseResult tryParse() {
    final trimmedText = text.trim();

    if (trimmedText.isEmpty) {
      return ServerUrlParseResult.error(ServerUrlValidationError.empty);
    }

    Uri? url = Uri.tryParse(trimmedText);
    if (!RegExp(r'^https?://').hasMatch(trimmedText)) {
      if (url != null && url.scheme == 'zulip') {
        // Someone might get the idea to try one of the "zulip://" URLs that
        // are discussed sometimes.
        // TODO(log): Log to Sentry? How much does this happen, if at all? Maybe
        //   log once when the input enters this error state, but don't spam
        //   on every keystroke/render while it's in it.
        return ServerUrlParseResult.error(ServerUrlValidationError.unsupportedSchemeZulip);
      } else if (url != null && url.hasScheme && url.scheme != 'http' && url.scheme != 'https') {
        return ServerUrlParseResult.error(ServerUrlValidationError.unsupportedSchemeOther);
      }
      url = Uri.tryParse('https://$trimmedText');
    }

    if (url == null || !url.isAbsolute) {
      return ServerUrlParseResult.error(ServerUrlValidationError.invalidUrl);
    }
    if (url.userInfo.isNotEmpty) {
      return ServerUrlParseResult.error(ServerUrlValidationError.noUseEmail);
    }
    return ServerUrlParseResult.ok(url);
  }
}

/// Fetch the server settings at [url], checking the server is supported.
///
/// On failure, shows an error dialog and returns null.
Future<GetServerSettingsResult?> _fetchServerSettingsOrShowError(
  BuildContext context,
  Uri url,
) async {
  final zulipLocalizations = ZulipLocalizations.of(context);
  try {
    final globalStore = GlobalStoreWidget.of(context);
    final serverSettings = await globalStore.fetchServerSettings(url);

    final zulipVersionData = ZulipVersionData.fromServerSettings(serverSettings);
    if (zulipVersionData.isNotAllowed) {
      throw ServerVersionNotAllowedException(zulipVersionData);
    }
    return serverSettings;
  } catch (e) {
    if (!context.mounted) return null;

    String? message;
    Uri? learnMoreButtonUrl;
    switch (e) {
      case ServerVersionNotAllowedException(:final data):
        message = zulipLocalizations.errorServerVersionNotAllowedMessage(
          url.toString(),
          data.zulipVersion,
          kMinAllowedZulipVersion);
        learnMoreButtonUrl = kServerSupportDocUrl;
      default:
        // TODO(#105) give more helpful feedback; see `fetchServerSettings`
        //   in zulip-mobile's src/message/fetchActions.js.
        message = zulipLocalizations.errorLoginCouldNotConnect(url.toString());
    }
    showErrorDialog(context: context,
      title: zulipLocalizations.errorCouldNotConnectTitle,
      message: message,
      learnMoreButtonUrl: learnMoreButtonUrl);
    return null;
  }
}

/// The first page for adding an account: sign in to the Kloki chat.
///
/// Signing in through Kloki or as a guest goes to [kKlokiChatRealmUrl].
/// Another server can still be chosen, through [AddAccountPage].
class KlokiSignInPage extends StatefulWidget {
  const KlokiSignInPage({super.key});

  static Route<void> buildRoute() {
    return _LoginSequenceRoute(page: const KlokiSignInPage());
  }

  @override
  State<KlokiSignInPage> createState() => _KlokiSignInPageState();
}

class _KlokiSignInPageState extends State<KlokiSignInPage>
    with SingleTickerProviderStateMixin, _WebAuthMixin<KlokiSignInPage> {
  bool _inProgress = false;

  GetServerSettingsResult? _serverSettings;

  @override
  GetServerSettingsResult? get webAuthServerSettings => _serverSettings;

  @override
  set webAuthInProgress(bool value) {
    setState(() {
      _inProgress = value;
    });
  }

  late final AnimationController _entrance = AnimationController(
    vsync: this, duration: const Duration(milliseconds: 1600));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _entrance.value = 1;
    } else if (_entrance.isDismissed) {
      _entrance.forward();
    }
  }

  @override
  void dispose() {
    _entrance.dispose();
    super.dispose();
  }

  /// Open Kloki's sign-in in the browser; or for a guest,
  /// the password form.
  Future<void> _continue({required bool guest}) async {
    setState(() {
      _inProgress = true;
    });
    try {
      final serverSettings = await _fetchServerSettingsOrShowError(
        context, kKlokiChatRealmUrl);
      if (serverSettings == null || !mounted) return;
      final klokiMethod = serverSettings.externalAuthenticationMethods
        .where((method) => method.name == kKlokiAuthMethodName)
        .firstOrNull;
      if (guest || klokiMethod == null) {
        unawaited(Navigator.push(context,
          LoginPage.buildRoute(serverSettings: serverSettings, klokiGuest: guest)));
        return;
      }
      _serverSettings = serverSettings;
      await beginWebAuth(klokiMethod);
    } finally {
      if (mounted) {
        setState(() {
          _inProgress = false;
        });
      }
    }
  }

  /// Fade and slide [child] in, over the part of the entrance
  /// from [begin] to [end].
  Widget _appear(double begin, double end, Widget child) {
    final animation = CurvedAnimation(parent: _entrance,
      curve: Interval(begin, end, curve: Curves.easeOutCubic));
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: animation.drive(
          Tween(begin: const Offset(0, 0.3), end: Offset.zero)),
        child: child));
  }

  @override
  Widget build(BuildContext context) {
    assert(!PerAccountStoreWidget.debugExistsOf(context));
    final zulipLocalizations = ZulipLocalizations.of(context);
    final designVariables = DesignVariables.of(context);
    final background = designVariables.mainBackground;

    final header = Row(children: [
      const KlokiMark(size: 28),
      const SizedBox(width: 10),
      Text('Kloki',
        style: TextStyle(
          fontFamily: kKlokiHeadingFontFamily,
          fontSize: 22,
          color: designVariables.title,
        ).merge(weightVariableTextStyle(context, wght: 800))),
    ]);

    final hero = LayoutBuilder(builder: (context, constraints) {
      // On a short screen (e.g. a phone in landscape) the words come first.
      if (constraints.maxHeight < 160) return const SizedBox.shrink();
      return Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: KlokiWelcomeHero(entrance: _entrance))));
    });

    final title = Text(zulipLocalizations.klokiWelcomeTitle,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontFamily: kKlokiHeadingFontFamily,
        fontSize: 30,
        height: 1.15,
        color: designVariables.title,
      ).merge(weightVariableTextStyle(context, wght: 800)));

    final description = Text(zulipLocalizations.klokiWelcomeDescription,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontFamily: kKlokiHeadingFontFamily,
        fontSize: 16,
        height: 1.5,
        color: designVariables.loginOrDividerText,
      ).merge(weightVariableTextStyle(context, wght: 500)));

    final links = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _KlokiTextLink(
          label: zulipLocalizations.klokiGuestSignIn,
          muted: true,
          onPressed: _inProgress ? null : () => _continue(guest: true)),
        _KlokiTextLink(
          label: zulipLocalizations.klokiOtherServer,
          muted: true,
          onPressed: () => Navigator.push(context, AddAccountPage.buildRoute())),
      ]);

    return Scaffold(
      backgroundColor: background,
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const [0, 0.7],
            colors: [
              Color.lerp(background, designVariables.fabBg, 0.10)!,
              background,
            ])),
        child: SafeArea(
          minimum: const EdgeInsets.fromLTRB(24, 16, 24, 12),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                _appear(0, 0.4, header),
                Expanded(child: hero),
                _appear(0.35, 0.75, title),
                const SizedBox(height: 12),
                _appear(0.45, 0.85, description),
                const SizedBox(height: 32),
                _appear(0.55, 0.95, _KlokiPrimaryButton(
                  label: zulipLocalizations.klokiSignInButton,
                  inProgress: _inProgress,
                  onPressed: _inProgress ? null : () => _continue(guest: false))),
                const SizedBox(height: 8),
                _appear(0.65, 1, links),
              ]))))));
  }
}

class AddAccountPage extends StatefulWidget {
  const AddAccountPage({super.key});

  static Route<void> buildRoute() {
    return _LoginSequenceRoute(page: const AddAccountPage());
  }

  /// The hint text to show in the "Zulip server URL" input.
  ///
  /// If this contains an example value, it must be one that has been reserved
  /// so that it cannot point to a real Zulip realm (nor any unknown other site).
  /// The realm name `your-org` under zulipchat.com is reserved for this reason.
  /// See discussion:
  ///   https://chat.zulip.org/#narrow/channel/243-mobile-team/topic/flutter.3A.20login.20URL/near/1570347
  // TODO(i18n): In principle this should be translated, because it's trying to
  //   convey to the user the English phrase "your org".  But doing that is
  //   tricky because of the need to have the example name reserved.
  //   Realistically that probably means we'll only ever translate this for
  //   at most a handful of languages, most likely none.
  static const _serverUrlHint = 'your-org.zulipchat.com';

  @override
  State<AddAccountPage> createState() => _AddAccountPageState();
}

class _AddAccountPageState extends State<AddAccountPage> {
  bool _inProgress = false;

  final ServerUrlTextEditingController _controller = ServerUrlTextEditingController();
  late ServerUrlParseResult _parseResult;

  void _serverUrlChanged() {
    setState(() {
      _parseResult = _controller.tryParse();
    });
  }

  @override
  void initState() {
    super.initState();
    _parseResult = _controller.tryParse();
    _controller.addListener(_serverUrlChanged);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onSubmitted(BuildContext context) async {
    final zulipLocalizations = ZulipLocalizations.of(context);
    final url = _parseResult.url;
    final error = _parseResult.error;
    if (error != null) {
      showErrorDialog(context: context,
        title: zulipLocalizations.errorLoginInvalidInputTitle,
        message: error.message(zulipLocalizations));
      return;
    }
    assert(url != null);

    setState(() {
      _inProgress = true;
    });
    try {
      final serverSettings = await _fetchServerSettingsOrShowError(context, url!);
      if (serverSettings == null || !context.mounted) return;

      unawaited(Navigator.push(context,
        LoginPage.buildRoute(serverSettings: serverSettings)));
    } finally {
      setState(() {
        _inProgress = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    assert(!PerAccountStoreWidget.debugExistsOf(context));
    final zulipLocalizations = ZulipLocalizations.of(context);
    final designVariables = DesignVariables.of(context);
    final error = _parseResult.error;
    final errorText = error == null || error.shouldDeferFeedback()
      ? null
      : error.message(zulipLocalizations);

    return _KlokiLoginScaffold(
      inProgress: _inProgress,
      children: [
        const _KlokiIconTile(icon: Icons.dns_outlined),
        _KlokiTitle(zulipLocalizations.klokiOtherServer),
        _KlokiText(zulipLocalizations.loginRealmUrlHelperText),
        const SizedBox(height: 32),
        // TODO(#111) Perhaps give tappable realm URL suggestions based on text typed so far
        _KlokiField(
          label: zulipLocalizations.loginRealmUrlLabel,
          field: TextField(
            controller: _controller,
            onSubmitted: (value) => _onSubmitted(context),
            keyboardType: TextInputType.url,
            autocorrect: false,
            scrollPadding: _KlokiField.scrollPadding,
            textInputAction: TextInputAction.go,
            onEditingComplete: () {
              // Repeat default implementation by clearing IME compose session…
              _controller.clearComposing();
              // …but leave out unfocusing the input in case more editing is needed.
            },
            style: filledInputTextStyle(designVariables),
            decoration: _KlokiField.decoration(designVariables,
              hintText: AddAccountPage._serverUrlHint,
              suffixIcon: ZulipIconButton(
                icon: ZulipIcons.help,
                tooltip: zulipLocalizations.loginRealmUrlHelpButton,
                onPressed: () => PlatformActions.launchUrl(context,
                  Uri.parse('https://zulip.com/help/logging-in#find-the-zulip-log-in-url')),
                size: .large,
                backgroundWhenPressed: false),
            ).copyWith(errorText: errorText, errorMaxLines: 3))),
        const SizedBox(height: 28),
        _KlokiPrimaryButton(
          label: zulipLocalizations.dialogContinue,
          inProgress: _inProgress,
          onPressed: !_inProgress && errorText == null
            ? () => _onSubmitted(context)
            : null),
      ]);
  }
}

/// Signing in through a browser, ending in a zulip://login URL;
/// shared by [LoginPage] and [KlokiSignInPage].
mixin _WebAuthMixin<T extends StatefulWidget> on State<T> {
  /// The state that began the latest web auth, to handle its result.
  static _WebAuthMixin? _pending;

  /// The server signed in to; null before it's known.
  GetServerSettingsResult? get webAuthServerSettings;

  set webAuthInProgress(bool value);

  String? get _otp {
    String? result;
    assert(() {
      result = LoginPage.debugOtpOverride;
      return true;
    }());
    return result ?? __otp;
  }
  String? __otp;

  @override
  void dispose() {
    if (_pending == this) _pending = null;
    super.dispose();
  }

  Future<void> handleWebAuthUrl(Uri url) async {
    webAuthInProgress = true;
    try {
      await ZulipBinding.instance.closeInAppWebView();

      final serverSettings = webAuthServerSettings;
      if (_otp == null || serverSettings == null) throw Error();
      final payload = WebAuthPayload.parse(url);
      if (payload.realm.origin != serverSettings.realmUrl.origin) throw Error();
      final apiKey = payload.decodeApiKey(_otp!);
      await tryInsertAccountAndNavigate(
        userId: payload.userId,
        email: payload.email,
        apiKey: apiKey,
      );
    } catch (e) {
      assert(debugLog(e.toString()));
      if (!mounted) return;
      final zulipLocalizations = ZulipLocalizations.of(context);

      String message = zulipLocalizations.errorWebAuthOperationalError;
      if (e is PlatformException && e.message != null) {
        message = e.message!;
      }
      showErrorDialog(context: context,
        title: zulipLocalizations.errorWebAuthOperationalErrorTitle,
        message: message);
    } finally {
      if (mounted) webAuthInProgress = false;
      __otp = null;
    }
  }

  Future<void> beginWebAuth(ExternalAuthenticationMethod method) async {
    __otp = generateOtp();
    _pending = this;
    try {
      final url = webAuthServerSettings!.realmUrl.resolve(method.loginUrl)
        .replace(queryParameters: {'mobile_flow_otp': _otp!});

      // Could set [_inProgress]… but we'd need to unset it if the web-auth
      // attempt is aborted (by the user closing the browser, for example),
      // and I don't think we can reliably know when that happens.

      // Not using [PlatformActions.launchUrl] because web auth needs special
      // error handling.
      await ZulipBinding.instance.launchUrl(url, mode: LaunchMode.inAppBrowserView);
    } catch (e) {
      assert(debugLog(e.toString()));

      if (e is PlatformException
        && defaultTargetPlatform == TargetPlatform.iOS
        && e.message != null && e.message!.startsWith('Error while launching')) {
        // Ignore; I've seen this on my iPhone even when auth succeeds.
        // Specifically, Apple web auth…which on iOS should be replaced by
        // Apple native auth; that's #462.
        // Possibly related:
        //   https://github.com/flutter/flutter/issues/91660
        // but in that issue, people report authentication not succeeding.
        // TODO(#462) remove this?
        return;
      }

      if (!mounted) return;
      final zulipLocalizations = ZulipLocalizations.of(context);

      String message = zulipLocalizations.errorWebAuthOperationalError;
      if (e is PlatformException && e.message != null) {
        message = e.message!;
      }
      showErrorDialog(context: context,
        title: zulipLocalizations.errorWebAuthOperationalErrorTitle,
        message: message);
    }
  }

  Future<void> tryInsertAccountAndNavigate({
    required String email,
    required String apiKey,
    required int userId,
  }) async {
    final serverSettings = webAuthServerSettings!;
    final globalStore = GlobalStoreWidget.of(context);
    final realmUrl = serverSettings.realmUrl;
    final int accountId;
    try {
      accountId = await globalStore.insertAccount(AccountsCompanion.insert(
        realmUrl: realmUrl,
        realmName: Value(serverSettings.realmName),
        realmIcon: Value(serverSettings.realmIcon),
        email: email,
        apiKey: apiKey,
        userId: userId,
        zulipFeatureLevel: serverSettings.zulipFeatureLevel,
        zulipVersion: serverSettings.zulipVersion,
        zulipMergeBase: Value(serverSettings.zulipMergeBase),
        possibleLegacyPushToken: const Value(false),
      ));
      // TODO give feedback to user on other SQL exceptions
    } on AccountAlreadyExistsException {
      if (!mounted) {
        return;
      }
      final zulipLocalizations = ZulipLocalizations.of(context);
      showErrorDialog(
        context: context,
        title: zulipLocalizations.errorAccountLoggedInTitle,
        message: zulipLocalizations.errorAccountLoggedIn(
          email, realmUrl.toString()));
      return;
    }

    if (!mounted) {
      return;
    }

    HomePage.navigate(context, accountId: accountId);
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, required this.serverSettings, this.klokiGuest = false});

  static Route<void> buildRoute({
    required GetServerSettingsResult serverSettings,
    bool klokiGuest = false,
  }) {
    return _LoginSequenceRoute(
      page: LoginPage(serverSettings: serverSettings, klokiGuest: klokiGuest));
  }

  final GetServerSettingsResult serverSettings;

  /// Whether to show only the guest sign-in,
  /// on a server with the Kloki sign-in.
  final bool klokiGuest;

  /// Log in using the payload of a web-auth URL like zulip://login?…
  ///
  /// The page that began the web auth handles it:
  /// a [LoginPage], or the [KlokiSignInPage].
  static Future<void> handleWebAuthUrl(Uri url) async {
    return _WebAuthMixin._pending?.handleWebAuthUrl(url);
  }

  /// The OTP to use, instead of an app-generated one, for testing.
  @visibleForTesting
  static String? debugOtpOverride;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with _WebAuthMixin<LoginPage> {
  bool _inProgress = false;

  late bool _showGuestForm = widget.klokiGuest;

  @override
  GetServerSettingsResult? get webAuthServerSettings => widget.serverSettings;

  @override
  set webAuthInProgress(bool value) {
    setState(() {
      _inProgress = value;
    });
  }

  ExternalAuthenticationMethod? get _klokiMethod => widget
    .serverSettings.externalAuthenticationMethods
    .where((method) => method.name == kKlokiAuthMethodName)
    .firstOrNull;

  Future<void> _beginWebAuth(ExternalAuthenticationMethod method) =>
    beginWebAuth(method);

  Future<void> _tryInsertAccountAndNavigate({
    required String email,
    required String apiKey,
    required int userId,
  }) => tryInsertAccountAndNavigate(email: email, apiKey: apiKey, userId: userId);

  /// The sign-in page of a server with the Kloki sign-in,
  /// following the one on chat.kloki.app.
  Widget _buildKloki(BuildContext context, ExternalAuthenticationMethod klokiMethod, {
    required bool showPasswordForm,
  }) {
    final zulipLocalizations = ZulipLocalizations.of(context);
    final serverSettings = widget.serverSettings;
    final showGuestForm = showPasswordForm && _showGuestForm;

    return _KlokiLoginScaffold(
      inProgress: _inProgress,
      children: [
        _KlokiRealmHeader(serverSettings: serverSettings),
        if (!showGuestForm) ...[
          _KlokiTitle(zulipLocalizations.klokiSignInTitle),
          _KlokiText(zulipLocalizations.klokiSignInDescription),
          const SizedBox(height: 32),
          _KlokiPrimaryButton(
            label: zulipLocalizations.klokiSignInButton,
            onPressed: _inProgress ? null : () => _beginWebAuth(klokiMethod)),
          if (showPasswordForm) ...[
            const SizedBox(height: 8),
            _KlokiTextLink(
              label: zulipLocalizations.klokiGuestSignIn,
              muted: true,
              onPressed: () => setState(() {
                _showGuestForm = true;
              })),
          ],
        ] else ...[
          _KlokiTitle(zulipLocalizations.klokiGuestSignIn),
          _KlokiText(zulipLocalizations.klokiGuestSignInDescription),
          const SizedBox(height: 32),
          _UsernamePasswordForm(loginPageState: this),
          if (!widget.klokiGuest) ...[
            const SizedBox(height: 8),
            _KlokiTextLink(
              label: zulipLocalizations.klokiBackToKlokiSignIn,
              onPressed: () => setState(() {
                _showGuestForm = false;
              })),
          ],
        ],
      ]);
  }

  @override
  Widget build(BuildContext context) {
    assert(!PerAccountStoreWidget.debugExistsOf(context));
    final colorScheme = Theme.of(context).colorScheme;
    final zulipLocalizations = ZulipLocalizations.of(context);

    final externalAuthenticationMethods = widget.serverSettings.externalAuthenticationMethods;
    final emailAuthEnabled = widget.serverSettings.emailAuthEnabled;
    final ldapEnabled = widget.serverSettings.authenticationMethods.ldap;
    final showPasswordForm = emailAuthEnabled || ldapEnabled;

    final klokiMethod = _klokiMethod;
    if (klokiMethod != null) {
      return _buildKloki(context, klokiMethod, showPasswordForm: showPasswordForm);
    }

    final loginContent = Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      if (showPasswordForm)
        _UsernamePasswordForm(loginPageState: this),
      if (externalAuthenticationMethods.isNotEmpty) ...[
        if (showPasswordForm)
          _AlternativeAuthDivider(),
        ...externalAuthenticationMethods.map((method) {
          final icon = method.displayIcon;
          return OutlinedButton.icon(
            style: ButtonStyle(
              backgroundColor: WidgetStatePropertyAll(colorScheme.secondaryContainer),
              foregroundColor: WidgetStatePropertyAll(colorScheme.onSecondaryContainer)),
            icon: icon != null
              ? Image.network(icon, width: 24, height: 24)
              : null,
            onPressed: !_inProgress
              ? () => _beginWebAuth(method)
              : null,
            label: Text(
              zulipLocalizations.signInWithFoo(method.displayName)));
        }),
      ],
    ]);

    return Scaffold(
      appBar: AppBar(title: Text(zulipLocalizations.loginPageTitle),
        bottom: _inProgress
          ? const PreferredSize(preferredSize: Size.fromHeight(4),
              child: LinearProgressIndicator(minHeight: 4)) // 4 restates default
          : null),
      body: SafeArea(
        minimum: const EdgeInsets.symmetric(horizontal: 8),
        bottom: false,
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(top: 8),
            child: SafeArea(
              minimum: const EdgeInsets.only(bottom: 8),
              // TODO also detect vertical scroll gestures that start on the
              //   left or the right of this box
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: loginContent))))));
  }
}

/// The frame of a Kloki sign-in page:
/// the Kloki mark above a card, on the page background.
/// The frame of a Kloki sign-in page:
/// a full page on the Kloki background, its contents easing in one by one.
class _KlokiLoginScaffold extends StatefulWidget {
  const _KlokiLoginScaffold({
    required this.inProgress,
    required this.children,
  });

  final bool inProgress;
  final List<Widget> children;

  @override
  State<_KlokiLoginScaffold> createState() => _KlokiLoginScaffoldState();
}

class _KlokiLoginScaffoldState extends State<_KlokiLoginScaffold>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entrance = AnimationController(
    vsync: this, duration: const Duration(milliseconds: 900));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _entrance.value = 1;
    } else if (_entrance.isDismissed) {
      _entrance.forward();
    }
  }

  @override
  void dispose() {
    _entrance.dispose();
    super.dispose();
  }

  Widget _appear(int index, Widget child) {
    final begin = math.min(index * 0.06, 0.5);
    final animation = CurvedAnimation(parent: _entrance,
      curve: Interval(begin, begin + 0.5, curve: Curves.easeOutCubic));
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: animation.drive(
          Tween(begin: const Offset(0, 0.4), end: Offset.zero)),
        child: child));
  }

  @override
  Widget build(BuildContext context) {
    final designVariables = DesignVariables.of(context);
    final background = designVariables.mainBackground;

    return Scaffold(
      backgroundColor: background,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        // With no bar color to go by, say which status-bar icons suit the page.
        systemOverlayStyle: Theme.of(context).brightness == Brightness.light
          ? SystemUiOverlayStyle.dark : SystemUiOverlayStyle.light,
        shape: const Border(),
        bottom: widget.inProgress
          ? const PreferredSize(preferredSize: Size.fromHeight(4),
              child: LinearProgressIndicator(minHeight: 4)) // 4 restates default
          : null),
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const [0, 0.6],
            colors: [
              Color.lerp(background, designVariables.fabBg, 0.10)!,
              background,
            ])),
        // Top-aligned, so the content stays put when the keyboard opens.
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, kToolbarHeight + 24, 24, 24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final (i, child) in widget.children.indexed)
                      _appear(i, child),
                  ])))))));
  }
}

/// An icon on a tinted tile, heading a Kloki sign-in page.
class _KlokiIconTile extends StatelessWidget {
  const _KlokiIconTile({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final designVariables = DesignVariables.of(context);
    final tone = designVariables.fabBg;
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Container(
        width: 52, height: 52,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: Color.lerp(designVariables.bgTopBar, tone, 0.12),
          border: Border.all(color: tone.withValues(alpha: 0.15))),
        child: Icon(icon, size: 26, color: tone)));
  }
}

/// The organization signed in to: its icon, name and address.
class _KlokiRealmHeader extends StatelessWidget {
  const _KlokiRealmHeader({required this.serverSettings});

  final GetServerSettingsResult serverSettings;

  @override
  Widget build(BuildContext context) {
    final designVariables = DesignVariables.of(context);
    final iconUrl = serverSettings.realmUrl.resolveUri(serverSettings.realmIcon);

    return Row(children: [
      DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(color: designVariables.fabBg.withValues(alpha: 0.25),
              blurRadius: 18, offset: const Offset(0, 6)),
          ]),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Image.network(iconUrl.toString(),
            width: 52, height: 52, fit: BoxFit.cover,
            errorBuilder: (_, _, _) => Container(width: 52, height: 52,
              color: designVariables.bgTopBar,
              alignment: Alignment.center,
              child: const KlokiMark(size: 28))))),
      const SizedBox(width: 14),
      Expanded(child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(serverSettings.realmName,
            maxLines: 1, overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: kKlokiHeadingFontFamily,
              fontSize: 17,
              color: designVariables.title,
            ).merge(weightVariableTextStyle(context, wght: 700))),
          const SizedBox(height: 2),
          Text(serverSettings.realmUrl.host,
            maxLines: 1, overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: kKlokiHeadingFontFamily,
              fontSize: 13,
              color: designVariables.loginOrDividerText,
            ).merge(weightVariableTextStyle(context, wght: 500))),
        ])),
    ]);
  }
}

class _KlokiTitle extends StatelessWidget {
  const _KlokiTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final designVariables = DesignVariables.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 36),
      child: Text(text,
        style: TextStyle(
          fontFamily: kKlokiHeadingFontFamily,
          fontSize: 30,
          height: 1.15,
          color: designVariables.title,
        ).merge(weightVariableTextStyle(context, wght: 800))));
  }
}

class _KlokiText extends StatelessWidget {
  const _KlokiText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final designVariables = DesignVariables.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Text(text,
        style: TextStyle(
          fontFamily: kKlokiHeadingFontFamily,
          fontSize: 15,
          height: 1.5,
          color: designVariables.loginOrDividerText,
        ).merge(weightVariableTextStyle(context, wght: 500))));
  }
}

/// A text field in the Kloki style, with its label above it.
class _KlokiField extends StatelessWidget {
  const _KlokiField({required this.label, required this.field});

  /// The [TextField.scrollPadding] that keeps the button
  /// under the fields above the keyboard too.
  static const scrollPadding = EdgeInsets.only(bottom: 140);

  final String label;
  final Widget field;

  static InputDecoration decoration(DesignVariables designVariables, {
    String? hintText,
    Widget? suffixIcon,
  }) {
    OutlineInputBorder border(Color color, [double width = 1]) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: color, width: width));
    final danger = designVariables.btnLabelAttLowIntDanger;
    return InputDecoration(
      filled: true,
      fillColor: designVariables.bgTopBar,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      hintText: hintText,
      hintStyle: TextStyle(color: designVariables.loginOrDividerText.withValues(alpha: 0.7)),
      suffixIcon: suffixIcon,
      enabledBorder: border(designVariables.borderBar),
      focusedBorder: border(designVariables.fabBg, 2),
      errorBorder: border(danger),
      focusedErrorBorder: border(danger, 2),
      errorStyle: TextStyle(color: danger));
  }

  @override
  Widget build(BuildContext context) {
    final designVariables = DesignVariables.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.only(start: 2, bottom: 6),
          child: Text(label,
            style: TextStyle(
              fontFamily: kKlokiHeadingFontFamily,
              fontSize: 14,
              color: designVariables.title,
            ).merge(weightVariableTextStyle(context, wght: 600)))),
        field,
      ]);
  }
}

class _KlokiPrimaryButton extends StatelessWidget {
  const _KlokiPrimaryButton({
    required this.label,
    required this.onPressed,
    this.inProgress = false,
  });

  final String label;
  final VoidCallback? onPressed;

  /// Whether to show a spinner next to the label.
  final bool inProgress;

  @override
  Widget build(BuildContext context) {
    final designVariables = DesignVariables.of(context);
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          disabledBackgroundColor: designVariables.fabBg.withValues(alpha: 0.7),
          disabledForegroundColor: Colors.white),
        onPressed: onPressed,
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          if (inProgress) ...[
            const SizedBox.square(dimension: 18,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
            const SizedBox(width: 12),
          ],
          Flexible(child: Text(label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontFamily: kKlokiHeadingFontFamily, fontSize: 16)
              .merge(weightVariableTextStyle(context, wght: 700)))),
        ])));
  }
}

class _KlokiTextLink extends StatelessWidget {
  const _KlokiTextLink({
    required this.label,
    required this.onPressed,
    this.muted = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final designVariables = DesignVariables.of(context);
    return Center(
      child: TextButton(
        style: TextButton.styleFrom(
          visualDensity: VisualDensity.compact,
          foregroundColor: muted ? designVariables.loginOrDividerText : designVariables.fabBg),
        onPressed: onPressed,
        child: Text(label,
          textAlign: TextAlign.center,
          style: const TextStyle(fontFamily: kKlokiHeadingFontFamily, fontSize: 14)
            .merge(weightVariableTextStyle(context, wght: 600)))));
  }
}

class _UsernamePasswordForm extends StatefulWidget {
  const _UsernamePasswordForm({required this.loginPageState});

  final _LoginPageState loginPageState;

  @override
  State<_UsernamePasswordForm> createState() => _UsernamePasswordFormState();
}

class _UsernamePasswordFormState extends State<_UsernamePasswordForm> {
  final GlobalKey<FormFieldState<String>> _usernameKey = GlobalKey();
  final GlobalKey<FormFieldState<String>> _passwordKey = GlobalKey();

  bool _obscurePassword = true;
  void _handlePasswordVisibilityPress() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  void _submit() async {
    final serverSettings = widget.loginPageState.widget.serverSettings;

    final context = _usernameKey.currentContext!;
    final realmUrl = serverSettings.realmUrl;
    final usernameFieldState = _usernameKey.currentState!;
    final passwordFieldState = _passwordKey.currentState!;
    final usernameValid = usernameFieldState.validate(); // Side effect: on-field error text
    final passwordValid = passwordFieldState.validate(); // Side effect: on-field error text
    if (!usernameValid || !passwordValid) {
      return;
    }
    final String username = usernameFieldState.value!.trim();
    final String password = passwordFieldState.value!;

    widget.loginPageState.setState(() {
      widget.loginPageState._inProgress = true;
    });
    try {
      final FetchApiKeyResult result;
      try {
        final globalStore = GlobalStoreWidget.of(context);
        final connection = globalStore.apiConnection(realmUrl: realmUrl,
          zulipFeatureLevel: serverSettings.zulipFeatureLevel);
        try {
          result = await fetchApiKey(connection,
            username: username, password: password);
        } finally {
          connection.close();
        }
      } on ApiRequestException catch (e) {
        if (!context.mounted) return;
        // TODO(#105) give more helpful feedback. The RN app is
        //   unhelpful here; we should at least recognize invalid auth errors, and
        //   errors for deactivated user or realm (see zulip-mobile#4571).
        final zulipLocalizations = ZulipLocalizations.of(context);
        final message = (e is ZulipApiException)
          ? zulipLocalizations.errorServerMessage(e.message)
          : e.message;
        showErrorDialog(context: context,
          title: zulipLocalizations.errorLoginFailedTitle,
          message: message);
        return;
      }

      if (!context.mounted) {
        return;
      }

      await widget.loginPageState._tryInsertAccountAndNavigate(
        email: result.email,
        apiKey: result.apiKey,
        userId: result.userId,
      );
    } finally {
      widget.loginPageState.setState(() {
        widget.loginPageState._inProgress = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    assert(!PerAccountStoreWidget.debugExistsOf(context));
    final designVariables = DesignVariables.of(context);
    final serverSettings = widget.loginPageState.widget.serverSettings;
    final zulipLocalizations = ZulipLocalizations.of(context);
    final requireEmailFormatUsernames = serverSettings.requireEmailFormatUsernames;
    final kloki = widget.loginPageState._klokiMethod != null;
    final usernameLabel = requireEmailFormatUsernames
      ? zulipLocalizations.loginEmailLabel
      : zulipLocalizations.loginUsernameLabel;

    final passwordVisibilityButton = ZulipIconButton(
      icon: Icons.visibility,
      isSelected: _obscurePassword,
      selectedIcon: Icons.visibility_off,
      tooltip: zulipLocalizations.loginHidePassword,
      onPressed: _handlePasswordVisibilityPress,
      size: .large,
      backgroundWhenPressed: false);

    final usernameField = TextFormField(
      key: _usernameKey,
      autofillHints: [
        if (!requireEmailFormatUsernames) AutofillHints.username,
        AutofillHints.email,
      ],
      keyboardType: TextInputType.emailAddress,
      scrollPadding: kloki ? _KlokiField.scrollPadding : const EdgeInsets.all(20),
      // TODO(upstream?): Apparently pressing "next" doesn't count
      //   as user interaction, and validation isn't done.
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return requireEmailFormatUsernames
            ? zulipLocalizations.loginErrorMissingEmail
            : zulipLocalizations.loginErrorMissingUsername;
        }
        if (requireEmailFormatUsernames) {
          // TODO(#106): validate is in the shape of an email
        }
        return null;
      },
      textInputAction: TextInputAction.next,
      style: filledInputTextStyle(designVariables),
      decoration: kloki
        ? _KlokiField.decoration(designVariables)
        : baseFilledInputDecoration(designVariables).copyWith(
            label: Text(usernameLabel),
            helperText: kLayoutPinningHelperText,
          ));

    final passwordField = TextFormField(
      key: _passwordKey,
      autofillHints: const [AutofillHints.password],
      obscureText: _obscurePassword,
      scrollPadding: kloki ? _KlokiField.scrollPadding : const EdgeInsets.all(20),
      keyboardType: _obscurePassword ? null : TextInputType.visiblePassword,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return zulipLocalizations.loginErrorMissingPassword;
        }
        return null;
      },
      textInputAction: TextInputAction.go,
      onFieldSubmitted: (value) => _submit(),
      style: filledInputTextStyle(designVariables),
      decoration: kloki
        ? _KlokiField.decoration(designVariables, suffixIcon: passwordVisibilityButton)
        : baseFilledInputDecoration(designVariables).copyWith(
            label: Text(zulipLocalizations.loginPasswordLabel),
            helperText: kLayoutPinningHelperText,
            suffixIconConstraints: BoxConstraints.tight(ZulipIconButtonSize.large.surface),
            suffixIcon: passwordVisibilityButton));

    if (kloki) {
      return Form(
        child: AutofillGroup(
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            _KlokiField(label: usernameLabel, field: usernameField),
            const SizedBox(height: 16),
            _KlokiField(label: zulipLocalizations.loginPasswordLabel, field: passwordField),
            const SizedBox(height: 28),
            _KlokiPrimaryButton(
              label: zulipLocalizations.loginFormSubmitLabel,
              inProgress: widget.loginPageState._inProgress,
              onPressed: widget.loginPageState._inProgress ? null : _submit),
          ])));
    }

    return Form(
      // TODO(#110) Try to highlight CZO / Zulip Cloud realms in autofill
      child: AutofillGroup(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          usernameField,
          const SizedBox(height: 8),
          passwordField,
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: widget.loginPageState._inProgress ? null : _submit,
            child: Text(zulipLocalizations.loginFormSubmitLabel)),
        ])));
  }
}

// Loosely based on the corresponding element in the web app.
class _AlternativeAuthDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final zulipLocalizations = ZulipLocalizations.of(context);
    final designVariables = DesignVariables.of(context);

    final divider = Expanded(
      child: Divider(color: designVariables.loginOrDivider, thickness: 2));

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Semantics(
        excludeSemantics: true,
        label: zulipLocalizations.loginMethodDividerSemanticLabel,
        child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          divider,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: Text(zulipLocalizations.loginMethodDivider,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: designVariables.loginOrDividerText,
                height: 1.5,
              ).merge(weightVariableTextStyle(context, wght: 600)))),
          divider,
        ])));
  }
}
