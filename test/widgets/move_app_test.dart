import 'package:checks/checks.dart';
import 'package:flutter_checks/flutter_checks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:zulip/widgets/home.dart';
import 'package:zulip/widgets/move_app.dart';

import '../example_data.dart' as eg;
import '../model/binding.dart';
import 'test_app.dart';

void main() {
  TestZulipBinding.ensureInitialized();

  const title = 'Kloki Chat has a new app';

  Future<void> prepare(WidgetTester tester, {required String packageName}) async {
    addTearDown(testBinding.reset);
    addTearDown(debugResetMoveToNewAppDialog);
    testBinding.packageInfoResult = eg.packageInfo(packageName: packageName);
    await testBinding.globalStore.add(eg.selfAccount, eg.initialSnapshot());
    await tester.pumpWidget(TestZulipApp(accountId: eg.selfAccount.id,
      child: const HomePage()));
    await tester.pump();
    await tester.pump();
    await tester.pump();
  }

  testWidgets('old iOS app: show dialog, open App Store', (tester) async {
    await prepare(tester, packageName: kOldIosAppBundleId);
    check(find.text(title)).findsOne();

    await tester.tap(find.text('Open App Store'));
    await tester.pump();
    check(testBinding.takeLaunchUrlCalls()).single
      .equals((url: kNewIosAppStoreUrl, mode: LaunchMode.externalApplication));
  }, variant: const TargetPlatformVariant({TargetPlatform.iOS}));

  testWidgets('old iOS app: dismiss with Later, once per launch', (tester) async {
    await prepare(tester, packageName: kOldIosAppBundleId);
    await tester.tap(find.text('Later'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    check(find.text(title)).findsNothing();

    // A new home page, as when switching accounts, in the same launch.
    await tester.pumpWidget(TestZulipApp(accountId: eg.selfAccount.id,
      child: HomePage(key: UniqueKey())));
    await tester.pump();
    await tester.pump();
    await tester.pump();
    check(find.text(title)).findsNothing();
  }, variant: const TargetPlatformVariant({TargetPlatform.iOS}));

  testWidgets('no dialog in the new iOS app', (tester) async {
    await prepare(tester, packageName: 'com.kodius.klokichat');
    check(find.text(title)).findsNothing();
  }, variant: const TargetPlatformVariant({TargetPlatform.iOS}));

  testWidgets('no dialog on Android, same package name', (tester) async {
    await prepare(tester, packageName: kOldIosAppBundleId);
    check(find.text(title)).findsNothing();
  }, variant: const TargetPlatformVariant({TargetPlatform.android}));
}
