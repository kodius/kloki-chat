import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import '../generated/l10n/zulip_localizations.dart';
import '../model/binding.dart';
import 'text.dart';
import 'theme.dart';

/// The bundle ID of the old, private iOS app,
/// whose users should move to the new public app.
const kOldIosAppBundleId = 'konvo.kodius.com';

/// The App Store page of the new public iOS app, `com.kodius.klokichat`.
final kNewIosAppStoreUrl = Uri.parse('https://apps.apple.com/app/id6833812526');

bool _shownThisLaunch = false;

@visibleForTesting
void debugResetMoveToNewAppDialog() {
  _shownThisLaunch = false;
}

/// In the old iOS app, asks the user to install the new one,
/// once per launch.
///
/// The user can dismiss it and keep using this app.
Future<void> maybeShowMoveToNewAppDialog(BuildContext context) async {
  if (_shownThisLaunch) return;
  if (defaultTargetPlatform != TargetPlatform.iOS) return;
  final packageInfo = await ZulipBinding.instance.packageInfo;
  if (packageInfo?.packageName != kOldIosAppBundleId) return;
  if (!context.mounted) return;
  _shownThisLaunch = true;
  await showDialog<void>(context: context,
    builder: (_) => const _MoveToNewAppDialog());
}

class _MoveToNewAppDialog extends StatelessWidget {
  const _MoveToNewAppDialog();

  @override
  Widget build(BuildContext context) {
    final zulipLocalizations = ZulipLocalizations.of(context);
    final designVariables = DesignVariables.of(context);
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 26, 22, 14),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          ClipRRect(
            // The iOS app icon's corner radius, about 22% of its size.
            borderRadius: BorderRadius.circular(16),
            child: Image.asset('assets/app-icons/kloki-chat.png',
              width: 72, height: 72)),
          const SizedBox(height: 16),
          Text(zulipLocalizations.moveToNewAppTitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: designVariables.title,
              fontFamily: kKlokiHeadingFontFamily,
              fontSize: 20,
              height: 25 / 20,
            ).merge(weightVariableTextStyle(context, wght: 800))),
          const SizedBox(height: 10),
          Text(zulipLocalizations.moveToNewAppMessage,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: designVariables.labelMenuButton,
              fontSize: 15,
              height: 21 / 15,
            )),
          const SizedBox(height: 18),
          FilledButton(
            onPressed: () => ZulipBinding.instance.launchUrl(kNewIosAppStoreUrl,
              mode: LaunchMode.externalApplication),
            child: Text(zulipLocalizations.moveToNewAppOpenStoreButton)),
          const SizedBox(height: 4),
          SizedBox(width: double.infinity, height: 48,
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(zulipLocalizations.moveToNewAppLaterButton,
                style: const TextStyle(fontFamily: kKlokiHeadingFontFamily, fontSize: 16)
                  .merge(weightVariableTextStyle(context, wght: 700))))),
        ])));
  }
}
