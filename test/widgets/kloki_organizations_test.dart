import 'dart:convert';

import 'package:checks/checks.dart';
import 'package:flutter_checks/flutter_checks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:material_ui/material_ui.dart';
import 'package:zulip/api/route/kloki.dart';
import 'package:zulip/model/binding.dart';
import 'package:zulip/widgets/home.dart';
import 'package:zulip/widgets/icons.dart';
import 'package:zulip/widgets/kloki.dart';
import 'package:zulip/widgets/kloki_organizations.dart';
import 'package:zulip/widgets/login.dart';
import 'package:zulip/widgets/page.dart';

import '../api/fake_api.dart';
import '../example_data.dart' as eg;
import '../model/binding.dart';
import '../stdlib_checks.dart';
import '../test_navigation.dart';
import 'dialog_checks.dart';
import 'checks.dart';
import 'test_app.dart';

void main() {
  TestZulipBinding.ensureInitialized();

  String jwt(Map<String, Object?> claims) {
    String part(Object json) =>
      base64Url.encode(utf8.encode(jsonEncode(json))).replaceAll('=', '');
    return '${part({'alg': 'HS256'})}.${part(claims)}.signature';
  }

  final session = jwt({'user_id': 7, 'user_login_id': 3});
  final profiles = [
    {'id': '7', 'company_name': 'Kodius', 'company_id': '1'},
    {'id': '9', 'company_name': 'Firma', 'company_id': '2'},
  ];

  late FakeApiConnection kloki;
  late List<Route<dynamic>> pushedRoutes;

  Future<void> prepare(WidgetTester tester, {
    String? klokiSession,
    List<Map<String, Object?>>? profilesJson,
    int profilesStatus = 200,
  }) async {
    addTearDown(testBinding.reset);
    addTearDown(KlokiLinkSignIn.debugReset);
    await testBinding.globalStore.add(eg.selfAccount, eg.initialSnapshot());
    if (klokiSession != null) {
      await testBinding.globalStore.settings.setKlokiSession(klokiSession);
    }
    testBinding.globalStore.useCachedApiConnections = true;
    kloki = testBinding.globalStore.apiConnection(
      realmUrl: kKlokiApiUrl, zulipFeatureLevel: null);
    if (profilesJson != null) {
      kloki.prepare(httpStatus: profilesStatus,
        body: profilesStatus == 200 ? jsonEncode(profilesJson) : '{}');
    }

    pushedRoutes = [];
    final testNavObserver = TestNavigatorObserver();
    testNavObserver.onPushed = (route, prevRoute) => pushedRoutes.add(route);
    testNavObserver.onReplaced = (route, prevRoute) => pushedRoutes.add(route!);
    await tester.pumpWidget(TestZulipApp(accountId: eg.selfAccount.id,
      navigatorObservers: [testNavObserver],
      child: const KlokiOrganizationsPage()));
    await tester.pump(); // the page, once the store is loaded
    await tester.pump(Duration.zero); // the request for the companies
    await tester.pump(Duration.zero); // its response
    await tester.pump();
    pushedRoutes.clear();
  }

  /// The connection the page gets next: it closes each one when done.
  FakeApiConnection nextKlokiConnection() {
    kloki = testBinding.globalStore.apiConnection(
      realmUrl: kKlokiApiUrl, zulipFeatureLevel: null);
    return kloki;
  }

  testWidgets('without a session, offer signing in through Kloki', (tester) async {
    await prepare(tester);
    check(find.textContaining('Sign in through Kloki to switch')).findsOne();
    check(kloki.takeRequests()).isEmpty();

    await tester.tap(find.widgetWithText(FilledButton, 'Sign in through Kloki'));
    await tester.pump();
    final call = testBinding.takeLaunchUrlCalls().single;
    check(call.url.replace(queryParameters: {})).equals(
      kKlokiChatSignInUrl.replace(queryParameters: {}));
    check(call.url.queryParameters['kloki_chat_otp']).isNotNull().length.equals(64);
    check(call.mode).equals(UrlLaunchMode.inAppBrowserView);
  });

  testWidgets('list the companies, marking the session\'s', (tester) async {
    await prepare(tester, klokiSession: session, profilesJson: profiles);
    check(kloki.takeRequests()).single.isA<http.Request>()
      ..url.equals(kKlokiApiUrl.replace(path: '/api/users/profiles'))
      ..headers['Authorization'].equals('Bearer $session');
    check(find.text('Kodius')).findsOne();
    check(find.text('Firma')).findsOne();
    check(find.descendant(of: find.ancestor(of: find.text('Kodius'), matching: find.byType(Row)),
      matching: find.byIcon(ZulipIcons.check))).findsOne();
    check(find.descendant(of: find.ancestor(of: find.text('Firma'), matching: find.byType(Row)),
      matching: find.byIcon(ZulipIcons.check))).findsNothing();
  });

  testWidgets('just one company', (tester) async {
    await prepare(tester, klokiSession: session, profilesJson: []);
    check(find.text("You're in just one company in Kloki.")).findsOne();
  });

  testWidgets('a session Kloki refuses is dropped', (tester) async {
    await prepare(tester, klokiSession: session, profilesJson: [], profilesStatus: 401);
    await tester.pump();
    check(testBinding.globalStore.settings.klokiSession).isNull();
    check(find.textContaining('Sign in through Kloki to switch')).findsOne();
  });

  group('switch', () {
    final firmaRealmUrl = Uri.parse('https://firma.chat.kloki.app');
    final firmaSession = jwt({'user_id': 9, 'user_login_id': 3});

    testWidgets('to a company with an account here: go to it', (tester) async {
      final firmaAccount = eg.account(user: eg.selfUser, realmUrl: firmaRealmUrl);
      await prepare(tester, klokiSession: session, profilesJson: profiles);
      await testBinding.globalStore.add(firmaAccount, eg.initialSnapshot());

      nextKlokiConnection()
        ..prepare(json: {'auth_token': firmaSession})
        ..prepare(json: {
          'token': jwt({'email': firmaAccount.email}),
          'realm_url': firmaRealmUrl.toString(),
          'login_url': firmaRealmUrl.resolve('/accounts/login/jwt/').toString(),
          'next': '/',
        });

      await tester.tap(find.text('Firma'));
      await tester.pump(Duration.zero);
      await tester.pump(Duration.zero);
      check(kloki.takeRequests()).deepEquals(<Condition<Object?>>[
        (it) => it.isA<http.Request>()
          ..url.path.equals('/api/users/switch-profile')
          ..headers['Authorization'].equals('Bearer $session'),
        (it) => it.isA<http.Request>()
          ..url.path.equals('/api/chat/login-token')
          ..headers['Authorization'].equals('Bearer $firmaSession'),
      ]);
      check(testBinding.globalStore.settings.klokiSession).equals(firmaSession);
      check(pushedRoutes).single.isA<MaterialAccountWidgetRoute>()
        ..accountId.equals(firmaAccount.id)
        ..page.isA<HomePage>();
    });

    testWidgets('to a company without a chat', (tester) async {
      await prepare(tester, klokiSession: session, profilesJson: profiles);

      nextKlokiConnection()
        ..prepare(json: {'auth_token': firmaSession})
        ..prepare(httpStatus: 403, json: {'error_code': 'chat_not_connected'});

      await tester.tap(find.text('Firma'));
      await tester.pump(Duration.zero);
      await tester.pump(Duration.zero);
      checkErrorDialog(tester,
        expectedTitle: "Couldn't switch",
        expectedMessage: 'Firma has no chat in Kloki.');
      check(testBinding.globalStore.accounts).length.equals(1);
    });
  });
}
