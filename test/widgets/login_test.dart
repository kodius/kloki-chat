import 'dart:async';
import 'dart:convert';

import 'package:checks/checks.dart';
import 'package:drift/drift.dart' as drift;
import 'package:flutter/services.dart';
import 'package:flutter_checks/flutter_checks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:material_ui/material_ui.dart';
import 'package:zulip/api/core.dart';
import 'package:zulip/api/exception.dart';
import 'package:zulip/api/model/web_auth.dart';
import 'package:zulip/api/route/account.dart';
import 'package:zulip/api/route/realm.dart';
import 'package:zulip/model/binding.dart';
import 'package:zulip/model/localizations.dart';
import 'package:zulip/model/store.dart';
import 'package:zulip/widgets/app.dart';
import 'package:zulip/widgets/home.dart';
import 'package:zulip/widgets/kloki.dart';
import 'package:zulip/widgets/login.dart';
import 'package:zulip/widgets/page.dart';

import '../api/fake_api.dart';
import '../api/route/route_checks.dart';
import '../example_data.dart' as eg;
import '../model/binding.dart';
import '../model/store_checks.dart';
import '../stdlib_checks.dart';
import '../test_images.dart';
import '../test_navigation.dart';
import 'dialog_checks.dart';
import 'checks.dart';

void main() {
  TestZulipBinding.ensureInitialized();

  final klokiAuthMethod = ExternalAuthenticationMethod(
    name: 'kloki',
    displayName: 'Kloki',
    displayIcon: null,
    loginUrl: '/accounts/login/kloki/',
    signupUrl: '/accounts/login/kloki/');

  const otp = '186f6d085a5621ebaf1ccfc05033e8acba57dae03f061705ac1e58c402c30a31';

  final findPasswordInput = find.byWidgetPredicate((widget) =>
    widget is TextField
    && (widget.autofillHints ?? []).contains(AutofillHints.password));

  group('ServerUrlTextEditingController.tryParse', () {
    final controller = ServerUrlTextEditingController();

    void expectUrlFromText(String text, String expectedUrl) {
      test('text "$text" gives URL "$expectedUrl"', () {
        controller.text = text;
        final result = controller.tryParse();
        check(result.error).isNull();
        check(result.url).isNotNull().asString.equals(expectedUrl);
      });
    }

    void expectErrorFromText(String text, ServerUrlValidationError expectedError) {
      test('text "$text" gives error "$expectedError"', () {
        controller.text = text;
        final result = controller.tryParse();
        check(result.url).isNull();
        check(result.error).equals(expectedError);
      });
    }

    expectUrlFromText('https://chat.zulip.org',   'https://chat.zulip.org');
    expectUrlFromText('https://chat.zulip.org/',  'https://chat.zulip.org/');
    expectUrlFromText(' https://chat.zulip.org ', 'https://chat.zulip.org');
    expectUrlFromText('http://chat.zulip.org',    'http://chat.zulip.org');
    expectUrlFromText('chat.zulip.org',           'https://chat.zulip.org');
    expectUrlFromText('192.168.1.21:9991',        'https://192.168.1.21:9991');
    expectUrlFromText('http://192.168.1.21:9991', 'http://192.168.1.21:9991');

    expectErrorFromText('',                  ServerUrlValidationError.empty);
    expectErrorFromText(' ',                 ServerUrlValidationError.empty);
    expectErrorFromText('zulip://foo',       ServerUrlValidationError.unsupportedSchemeZulip);
    expectErrorFromText('ftp://foo',         ServerUrlValidationError.unsupportedSchemeOther);
    expectErrorFromText('!@#*asd;l4fkj',     ServerUrlValidationError.invalidUrl);
    expectErrorFromText('email@example.com', ServerUrlValidationError.noUseEmail);
  });

  group('AddAccountPage', () {
    late FakeApiConnection connection;
    late TestNavigatorObserver testNavObserver;
    List<Route<dynamic>> pushedRoutes = [];

    final realmUrl = Uri.parse('https://firma.chat.kloki.app');

    List<Route<dynamic>> takePushedRoutes() {
      final routes = pushedRoutes.toList();
      pushedRoutes.clear();
      return routes;
    }

    Future<void> prepare(WidgetTester tester, {String link = 'Sign in to another server'}) async {
      addTearDown(testBinding.reset);

      pushedRoutes = [];
      testNavObserver = TestNavigatorObserver();
      testNavObserver.onPushed = (route, prevRoute) => pushedRoutes.add(route);
      testNavObserver.onReplaced = (route, prevRoute) => pushedRoutes.add(route!);

      await tester.pumpWidget(ZulipApp(navigatorObservers: [testNavObserver]));
      await tester.pump();
      check(takePushedRoutes()).single.isA<WidgetRoute>().page.isA<ChooseAccountPage>();
      await tester.pump(const Duration(seconds: 2)); // entrance animation
      await tester.ensureVisible(find.text(link));
      await tester.tap(find.text(link));
      check(takePushedRoutes()).single.isA<WidgetRoute>().page.isA<AddAccountPage>();
      await testNavObserver.pumpPastTransition(tester);

      testBinding.globalStore.useCachedApiConnections = true;
      connection = testBinding.globalStore.apiConnection(
        realmUrl: realmUrl, zulipFeatureLevel: null);
    }

    Future<void> attempt(WidgetTester tester, String text, {
      Map<String, Object?>? json,
      ZulipApiException? apiException,
    }) async {
      await tester.enterText(find.byType(TextField), text);
      await tester.pump();
      if (json != null || apiException != null) {
        connection.prepare(json: json, apiException: apiException);
      }
      await tester.tap(find.text('Continue'));
      await tester.pump(Duration.zero);
    }

    testWidgets('happy path', (tester) async {
      await prepare(tester);

      final serverSettings = eg.serverSettings(realmUrl: realmUrl);
      await tester.enterText(find.byType(TextField), 'firma');
      await tester.pump();
      check(find.text('.chat.kloki.app')).findsOne();
      await attempt(tester, 'firma', json: serverSettings.toJson());
      checkNoDialog(tester);
      check(connection.takeRequests()).single.isA<http.Request>()
        .url.equals(realmUrl.resolve('/api/v1/server_settings'));
      check(takePushedRoutes()).single.isA<WidgetRoute>().page.isA<LoginPage>()
        ..serverSettings.realmUrl.equals(realmUrl)
        ..has((page) => page.klokiGuest, 'klokiGuest').isFalse();
    });

    testWidgets('guest sign-in from a pasted invitation link', (tester) async {
      await prepare(tester, link: 'Guest sign-in');

      await attempt(tester,
        ' https://firma.chat.kloki.app/join/abcdefghijklmnopqrstuvwx/ ',
        json: eg.serverSettings(realmUrl: realmUrl,
          externalAuthenticationMethods: [klokiAuthMethod]).toJson());
      check(connection.takeRequests()).single.isA<http.Request>()
        .url.equals(realmUrl.resolve('/api/v1/server_settings'));
      check(takePushedRoutes()).single.isA<WidgetRoute>().page.isA<LoginPage>()
        ..serverSettings.realmUrl.equals(realmUrl)
        ..has((page) => page.klokiGuest, 'klokiGuest').isTrue();
      await testNavObserver.pumpPastTransition(tester);
      check(findPasswordInput).findsOne();
      check(find.text('Back to signing in through Kloki')).findsNothing();
    });

    testWidgets('no request for a server outside Kloki', (tester) async {
      await prepare(tester);

      await attempt(tester, 'chat.zulip.org');
      check(find.textContaining('Enter the organization')).findsOne();
      check(connection.takeRequests()).isEmpty();
      check(takePushedRoutes()).isEmpty();

      await tester.enterText(find.byType(TextField), 'firma');
      await tester.pump();
      check(find.textContaining('Enter the organization')).findsNothing();
    });

    testWidgets('organization not found', (tester) async {
      await prepare(tester);

      await attempt(tester, 'firma',
        apiException: eg.apiBadRequest(message: 'Invalid subdomain'));
      checkErrorDialog(tester,
        expectedTitle: 'Organization not found',
        expectedMessage: "There's no chat at $realmUrl. Check the organization's name.");
      check(takePushedRoutes()).single.isA<DialogRoute<void>>();
    });

    testWidgets('Server too old, well-formed response', (tester) async {
      await prepare(tester);

      final serverSettings = eg.serverSettings(realmUrl: realmUrl,
        zulipFeatureLevel: 1, zulipVersion: '3.0');

      await attempt(tester, 'firma', json: serverSettings.toJson());
      checkErrorDialog(tester,
        expectedTitle: 'Could not connect',
        expectedMessage: '$realmUrl is running Zulip Server 3.0, which is unsupported. The minimum supported version is Zulip Server $kMinAllowedZulipVersion.');
      // i.e., not the login route
      check(takePushedRoutes()).single.isA<DialogRoute<void>>();
    });

    testWidgets('Server too old, malformed response', (tester) async {
      await prepare(tester);

      final serverSettings = eg.serverSettings(realmUrl: realmUrl,
        zulipFeatureLevel: 1, zulipVersion: '3.0');
      final serverSettingsMalformedJson =
        serverSettings.toJson()..['push_notifications_enabled'] = 'abcd';
      check(() => GetServerSettingsResult.fromJson(serverSettingsMalformedJson))
        .throws<void>();

      await attempt(tester, 'firma', json: serverSettingsMalformedJson);
      checkErrorDialog(tester,
        expectedTitle: 'Could not connect',
        expectedMessage: '$realmUrl is running Zulip Server 3.0, which is unsupported. The minimum supported version is Zulip Server $kMinAllowedZulipVersion.');
      // i.e., not the login route
      check(takePushedRoutes()).single.isA<DialogRoute<void>>();
    });

    testWidgets('Malformed response, server not too old', (tester) async {
      await prepare(tester);

      final serverSettings = eg.serverSettings(realmUrl: realmUrl,
        zulipVersion: eg.recentZulipVersion,
        zulipFeatureLevel: eg.recentZulipFeatureLevel);
      final serverSettingsMalformedJson =
        serverSettings.toJson()..['push_notifications_enabled'] = 'abcd';
      check(() => GetServerSettingsResult.fromJson(serverSettingsMalformedJson))
        .throws<void>();

      await attempt(tester, 'firma', json: serverSettingsMalformedJson);
      checkErrorDialog(tester,
        expectedTitle: 'Could not connect',
        expectedMessage: 'Failed to connect to server:\n$realmUrl');
      // i.e., not the login route
      check(takePushedRoutes()).single.isA<DialogRoute<void>>();
    });

    // TODO other errors
  });

  group('KlokiSignInPage', () {
    late TestNavigatorObserver testNavObserver;
    late List<Route<dynamic>> pushedRoutes;

    final realmUrl = Uri.parse('https://firma.chat.kloki.app');
    final serverSettings = eg.serverSettings(
      realmUrl: realmUrl,
      externalAuthenticationMethods: [klokiAuthMethod]);

    Future<void> prepare(WidgetTester tester) async {
      addTearDown(testBinding.reset);
      prepareBoringImageHttpClient(); // realm icon
      addTearDown(() => debugNetworkImageHttpClientProvider = null);

      pushedRoutes = [];
      testNavObserver = TestNavigatorObserver();
      testNavObserver.onPushed = (route, prevRoute) => pushedRoutes.add(route);
      testNavObserver.onReplaced = (route, prevRoute) => pushedRoutes.add(route!);
      await tester.pumpWidget(ZulipApp(navigatorObservers: [testNavObserver]));
      await tester.pump();
      check(pushedRoutes).single.isA<WidgetRoute>().page.isA<ChooseAccountPage>();
      pushedRoutes.clear();
      check(find.byType(KlokiSignInPage)).findsOne();
      await tester.pump(const Duration(seconds: 2)); // entrance animation

      testBinding.globalStore.useCachedApiConnections = true;
    }

    FakeApiConnection connectionFor(Uri realmUrl) => testBinding.globalStore
      .apiConnection(realmUrl: realmUrl, zulipFeatureLevel: null);

    const session = 'kloki.session.jwt-that-is-longer-than-one-sha256-block';

    Future<void> signInThroughKloki(WidgetTester tester) async {
      LoginPage.debugOtpOverride = otp;
      addTearDown(() => LoginPage.debugOtpOverride = null);
      addTearDown(KlokiLinkSignIn.debugReset);
      await tester.ensureVisible(find.text('Sign in through Kloki'));
      await tester.tap(find.text('Sign in through Kloki'));
      await tester.pump(Duration.zero);
    }

    /// Kloki's web sign-in sends the browser back with this link.
    Future<void> returnFromBrowser(WidgetTester tester, {String? sealedSession}) async {
      final url = Uri(scheme: 'konvo', host: 'kloki-login', queryParameters: {
        'realm': realmUrl.toString(),
        'token': 'jwt',
        'session': sealedSession ?? debugSealKlokiSession(session, otp),
      });
      final ByteData message = const JSONMethodCodec().encodeMethodCall(
        MethodCall('pushRouteInformation', {'location': url.toString()}));
      // Not awaited: signing in makes requests,
      // which take the test clock moving.
      // Moved without a frame, so the home page isn't built.
      unawaited(tester.binding.defaultBinaryMessenger.handlePlatformMessage(
        'flutter/navigation', message, null));
      await tester.binding.delayed(Duration.zero);
      await tester.binding.delayed(Duration.zero);
    }

    void prepareSignIn(FakeApiConnection connection) {
      connection.prepare(json: serverSettings.toJson());
      connection.prepare(httpStatus: 302, headers: {'location': Uri(
        scheme: 'zulip', host: 'login', queryParameters: {
          'otp_encrypted_api_key': debugEncodeApiKey(eg.selfAccount.apiKey, otp),
          'email': eg.selfAccount.email,
          'user_id': eg.selfAccount.userId.toString(),
          'realm': realmUrl.toString(),
        }).toString()});
    }

    testWidgets('no organization input', (tester) async {
      await prepare(tester);
      check(find.byType(TextField)).findsNothing();
    });

    testWidgets('sign in through Kloki: browser, then the app keeps the session', (tester) async {
      await prepare(tester);
      final connection = connectionFor(realmUrl);

      await signInThroughKloki(tester);
      check(connection.takeRequests()).isEmpty();
      final expectedUrl = kKlokiChatSignInUrl
        .replace(queryParameters: {'kloki_chat_otp': otp});
      check(testBinding.takeLaunchUrlCalls())
        .deepEquals([(url: expectedUrl, mode: UrlLaunchMode.inAppBrowserView)]);
      // No page in between; closing the browser leaves this page.
      check(pushedRoutes).isEmpty();

      prepareSignIn(connection);
      await returnFromBrowser(tester);
      check(testBinding.takeCloseInAppWebViewCallCount()).equals(1);
      check(testBinding.globalStore.settings.klokiSession).equals(session);
      check(connection.takeRequests()).length.equals(2);
      final account = testBinding.globalStore.accounts.single;
      check(account)
        ..realmUrl.equals(realmUrl)
        ..email.equals(eg.selfAccount.email);
      check(pushedRoutes).single.isA<MaterialAccountWidgetRoute>()
        ..accountId.equals(account.id)
        ..page.isA<HomePage>();
    });

    testWidgets('no session from a link this app did not ask for', (tester) async {
      await prepare(tester);
      LoginPage.debugOtpOverride = otp;
      addTearDown(() => LoginPage.debugOtpOverride = null);
      final connection = connectionFor(realmUrl);

      prepareSignIn(connection);
      await returnFromBrowser(tester);
      check(testBinding.takeCloseInAppWebViewCallCount()).equals(0);
      check(testBinding.globalStore.settings.klokiSession).isNull();
      check(testBinding.globalStore.accounts).length.equals(1);
    });

    testWidgets('a session sealed with another pad is not kept', (tester) async {
      await prepare(tester);
      final connection = connectionFor(realmUrl);

      await signInThroughKloki(tester);
      testBinding.takeLaunchUrlCalls();
      prepareSignIn(connection);
      await returnFromBrowser(tester,
        sealedSession: debugSealKlokiSession(session, 'ab' * 32));
      check(testBinding.globalStore.settings.klokiSession).not((it) => it.equals(session));
      check(testBinding.globalStore.accounts).length.equals(1);
    });

    testWidgets('guest sign-in asks for the organization', (tester) async {
      await prepare(tester);

      await tester.ensureVisible(find.text('Guest sign-in'));
      await tester.tap(find.text('Guest sign-in'));
      check(pushedRoutes).single.isA<WidgetRoute>().page.isA<AddAccountPage>()
        .has((page) => page.klokiGuest, 'klokiGuest').isTrue();
      check(testBinding.takeLaunchUrlCalls()).isEmpty();
    });

    testWidgets('another server opens AddAccountPage', (tester) async {
      await prepare(tester);

      await tester.ensureVisible(find.text('Sign in to another server'));
      await tester.tap(find.text('Sign in to another server'));
      check(pushedRoutes).single.isA<WidgetRoute>().page.isA<AddAccountPage>()
        .has((page) => page.klokiGuest, 'klokiGuest').isFalse();
    });
  });

  group('KlokiLinkSignIn', () {
    late FakeApiConnection connection;
    late List<Route<dynamic>> pushedRoutes;

    final realmUrl = Uri.parse('https://firma.chat.kloki.app');
    final serverSettings = eg.serverSettings(realmUrl: realmUrl,
      externalAuthenticationMethods: [klokiAuthMethod]);

    String jwt(Map<String, Object?> claims) {
      String part(Object json) =>
        base64Url.encode(utf8.encode(jsonEncode(json))).replaceAll('=', '');
      return '${part({'alg': 'HS256'})}.${part(claims)}.signature';
    }
    final self = eg.selfAccount.copyWith(realmUrl: realmUrl);
    final token = jwt({'email': self.email, 'purpose': 'zulip_login'});

    Uri link({String? realm}) =>
      Uri(scheme: 'konvo', host: 'kloki-login', queryParameters: {
        'realm': realm ?? realmUrl.toString(),
        'token': token,
      });

    Uri location() => Uri(scheme: 'zulip', host: 'login', queryParameters: {
      'otp_encrypted_api_key': debugEncodeApiKey(eg.selfAccount.apiKey, otp),
      'email': self.email,
      'user_id': self.userId.toString(),
      'realm': realmUrl.toString(),
    });

    Future<void> prepare(WidgetTester tester, {List<Account> accounts = const []}) async {
      addTearDown(testBinding.reset);
      LoginPage.debugOtpOverride = otp;
      addTearDown(() => LoginPage.debugOtpOverride = null);
      for (final account in accounts) {
        await testBinding.globalStore.add(account, eg.initialSnapshot());
      }

      pushedRoutes = [];
      final testNavObserver = TestNavigatorObserver();
      testNavObserver.onPushed = (route, prevRoute) => pushedRoutes.add(route);
      testNavObserver.onReplaced = (route, prevRoute) => pushedRoutes.add(route!);
      await tester.pumpWidget(ZulipApp(navigatorObservers: [testNavObserver]));
      await tester.pump();
      pushedRoutes.clear();

      testBinding.globalStore.useCachedApiConnections = true;
      connection = testBinding.globalStore.apiConnection(
        realmUrl: realmUrl, zulipFeatureLevel: null);
    }

    // Let each request finish, without a frame:
    // the tests stop short of building the new account's home page.
    Future<void> pumpSignIn(WidgetTester tester) async {
      await tester.binding.delayed(Duration.zero);
      await tester.binding.delayed(Duration.zero);
    }

    Future<void> open(WidgetTester tester, Uri url) async {
      // Not awaited: the sign-in's requests need the clock to advance.
      unawaited(KlokiLinkSignIn.handleUrl(url));
      await pumpSignIn(tester);
    }

    /// Open the link as the platform delivers it to a running app.
    Future<void> openFromPlatform(WidgetTester tester, Uri url) async {
      final ByteData message = const JSONMethodCodec().encodeMethodCall(
        MethodCall('pushRouteInformation', {'location': url.toString()}));
      await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
        'flutter/navigation', message, null);
    }

    void checkSignedIn() {
      final account = testBinding.globalStore.accounts.single;
      check(account)
        ..realmUrl.equals(realmUrl)
        ..email.equals(self.email)
        ..apiKey.equals(self.apiKey)
        ..userId.equals(self.userId);
      check(pushedRoutes).single.isA<MaterialAccountWidgetRoute>()
        ..accountId.equals(account.id)
        ..page.isA<HomePage>();
    }

    testWidgets('sign in without a browser or sign-in page', (tester) async {
      await prepare(tester);
      connection.prepare(json: serverSettings.toJson());
      connection.prepare(httpStatus: 302,
        headers: {'location': location().toString()});
      await open(tester, link());
      check(connection.takeRequests()).deepEquals(<Condition<Object?>>[
        (it) => it.isA<http.Request>()
          ..method.equals('GET')
          ..url.equals(realmUrl.resolve('/api/v1/server_settings')),
        (it) => it.isA<http.Request>()
          ..method.equals('POST')
          ..url.equals(realmUrl.resolve('/accounts/login/jwt/'))
          ..followRedirects.isFalse()
          ..bodyFields.deepEquals({'token': token, 'mobile_flow_otp': otp}),
      ]);
      check(testBinding.takeLaunchUrlCalls()).isEmpty();
      checkSignedIn();
    });

    testWidgets('on cold start, from the initial route', (tester) async {
      // On Android, a link that launches the app is the initial route.
      tester.platformDispatcher.defaultRouteNameTestValue = link().toString();
      addTearDown(tester.platformDispatcher.clearDefaultRouteNameTestValue);
      addTearDown(testBinding.reset);
      LoginPage.debugOtpOverride = otp;
      addTearDown(() => LoginPage.debugOtpOverride = null);
      testBinding.globalStore.useCachedApiConnections = true;
      connection = testBinding.globalStore.apiConnection(
        realmUrl: realmUrl, zulipFeatureLevel: null);
      connection.prepare(json: serverSettings.toJson());
      connection.prepare(httpStatus: 302,
        headers: {'location': location().toString()});

      pushedRoutes = [];
      final testNavObserver = TestNavigatorObserver();
      testNavObserver.onReplaced = (route, prevRoute) => pushedRoutes.add(route!);
      await tester.pumpWidget(ZulipApp(navigatorObservers: [testNavObserver]));
      await tester.pump();
      await pumpSignIn(tester);
      check(connection.takeRequests()).length.equals(2);
      checkSignedIn();
    });

    testWidgets('with an account on the realm, just go to it', (tester) async {
      final otherPerson = eg.otherAccount.copyWith(realmUrl: realmUrl);
      final otherRealm = eg.selfAccount.copyWith(id: self.id + 100,
        realmUrl: Uri.parse('https://druga.chat.kloki.app'));
      await prepare(tester, accounts: [otherPerson, self, otherRealm]);
      await openFromPlatform(tester, link());
      check(connection.takeRequests()).isEmpty();
      check(pushedRoutes).single.isA<MaterialAccountWidgetRoute>()
        .accountId.equals(self.id);
    });

    testWidgets('realm outside Kloki: no request, no manual sign-in', (tester) async {
      await prepare(tester);
      await open(tester, link(realm: 'https://chat.zulip.org'));
      await tester.pump(); // the dialog
      check(connection.takeRequests()).isEmpty();
      check(find.text("Couldn't sign in from Kloki")).findsOne();
      check(find.text('Sign in here')).findsNothing();
      check(find.text('Back to Kloki GO')).findsOne();
    });

    testWidgets('expired token: back to Kloki GO', (tester) async {
      await prepare(tester);
      connection.prepare(json: serverSettings.toJson());
      connection.prepare(httpStatus: 400, json: {
        'result': 'error', 'code': 'BAD_REQUEST', 'msg': 'Bad JSON web token'});
      await open(tester, link());
      await tester.pump(); // the dialog
      check(connection.takeRequests()).length.equals(2);
      check(testBinding.globalStore.accounts).isEmpty();
      check(find.text("Couldn't sign in from Kloki")).findsOne();
      check(find.text('Bad JSON web token')).findsNothing();

      await tester.tap(find.text('Back to Kloki GO'));
      await tester.pump();
      check(testBinding.takeLaunchUrlCalls()).deepEquals([
        (url: Uri.parse('klokimobile://'), mode: UrlLaunchMode.externalApplication)]);
      check(find.text("Couldn't sign in from Kloki")).findsNothing();
    });

    testWidgets('failed sign-in: sign in here, on the same realm', (tester) async {
      await prepare(tester);
      connection.prepare(json: serverSettings.toJson());
      connection.prepare(httpStatus: 400, json: {
        'result': 'error', 'code': 'BAD_REQUEST', 'msg': 'Bad JSON web token'});
      await open(tester, link());
      await tester.pump(); // the dialog
      pushedRoutes.clear();

      prepareBoringImageHttpClient(); // realm icon
      addTearDown(() => debugNetworkImageHttpClientProvider = null);
      await tester.tap(find.text('Sign in here'));
      await tester.pump();
      check(pushedRoutes).single.isA<WidgetRoute>().page.isA<LoginPage>()
        .has((page) => page.serverSettings.realmUrl, 'realmUrl').equals(realmUrl);
    });

    testWidgets('server unreachable: sign in here, with the realm filled in', (tester) async {
      await prepare(tester);
      connection.prepare(httpException: Exception('offline'));
      await open(tester, link());
      await tester.pump(); // the dialog
      pushedRoutes.clear();

      await tester.tap(find.text('Sign in here'));
      await tester.pump();
      check(pushedRoutes).single.isA<WidgetRoute>().page.isA<AddAccountPage>()
        .has((page) => page.initialServerUrl, 'initialServerUrl').equals(realmUrl);
    });
  });

  group('LoginPage', () {
    late FakeApiConnection connection;
    late List<Route<void>> pushedRoutes;
    late List<Route<void>> poppedRoutes;

    void takeStartingRoutes() {
      final expected = <Condition<Object?>>[
        (it) => it.isA<WidgetRoute>().page.isA<ChooseAccountPage>(),
        (it) => it.isA<WidgetRoute>().page.isA<LoginPage>(),
      ];
      check(pushedRoutes.take(expected.length)).deepEquals(expected);
      pushedRoutes.removeRange(0, expected.length);
    }

    Future<void> prepare(WidgetTester tester,
        GetServerSettingsResult serverSettings) async {
      addTearDown(testBinding.reset);

      connection = testBinding.globalStore.apiConnection(
        realmUrl: serverSettings.realmUrl,
        zulipFeatureLevel: serverSettings.zulipFeatureLevel);

      pushedRoutes = [];
      poppedRoutes = [];
      final testNavObserver = TestNavigatorObserver();
      testNavObserver.onPushed = (route, prevRoute) => pushedRoutes.add(route);
      testNavObserver.onPopped = (route, prevRoute) => poppedRoutes.add(route);
      testNavObserver.onReplaced = (route, prevRoute) {
        poppedRoutes.add(prevRoute!);
        pushedRoutes.add(route!);
      };
      await tester.pumpWidget(ZulipApp(navigatorObservers: [testNavObserver]));
      await tester.pump();
      final navigator = await ZulipApp.navigator;
      unawaited(navigator.push(LoginPage.buildRoute(serverSettings: serverSettings)));
      await tester.pumpAndSettle();
    }

    final googleAuthMethod = ExternalAuthenticationMethod(
      name: 'google',
      displayName: 'Google',
      displayIcon: eg.realmUrl.resolve('/static/images/authentication_backends/googl_e-icon.png').toString(),
      loginUrl: '/accounts/login/social/google',
      signupUrl: '/accounts/register/social/google');

    final findUsernameInput = find.byWidgetPredicate((widget) =>
      widget is TextField
      && (widget.autofillHints ?? []).contains(AutofillHints.email));
    final findSubmitButton = find.widgetWithText(ElevatedButton, 'Log in');

    /// Check the account is as expected, ignoring fields that are
    /// freshly generated at login time.
    void checkMatchesAccount(Account actual, Account expected) {
      check(actual).equals(expected.copyWith(
        id: actual.id,
        // The example accounts have non-null deviceId because that's how
        // an account will typically look in the app after fully set up.
        // But it doesn't happen at login time, so expect null at this stage.
        deviceId: drift.Value(null),
        possibleLegacyPushToken: false,
      ));
    }

    group('username/password login', () {
      void checkFetchApiKey({required String username, required String password}) {
        check(connection.lastRequest).isA<http.Request>()
          ..method.equals('POST')
          ..url.path.equals('/api/v1/fetch_api_key')
          ..bodyFields.deepEquals({
            'username': username,
            'password': password,
          });
      }

      Future<void> login(WidgetTester tester, Account account) async {
        await tester.enterText(findUsernameInput, account.email);
        await tester.enterText(findPasswordInput, 'p455w0rd');
        testBinding.globalStore.useCachedApiConnections = true;
        connection.prepare(json: FetchApiKeyResult(
          apiKey: account.apiKey,
          email: account.email,
          userId: account.userId,
        ).toJson());
        await tester.tap(findSubmitButton);
        checkFetchApiKey(username: account.email, password: 'p455w0rd');
        await tester.idle();
      }

      testWidgets('basic happy case', (tester) async {
        final serverSettings = eg.serverSettings();
        await prepare(tester, serverSettings);
        takeStartingRoutes();
        check(pushedRoutes).isEmpty();
        check(testBinding.globalStore.accounts).isEmpty();

        await login(tester, eg.selfAccount);
        checkMatchesAccount(testBinding.globalStore.accounts.single,
          eg.selfAccount);
      });

      testWidgets('logging into a second account', (tester) async {
        await testBinding.globalStore.add(eg.selfAccount, eg.initialSnapshot());
        final serverSettings = eg.serverSettings();
        await prepare(tester, serverSettings);
        check(poppedRoutes).isEmpty();
        check(pushedRoutes).deepEquals(<Condition<Object?>>[
          (it) => it.isA<WidgetRoute>().page.isA<HomePage>(),
          (it) => it.isA<WidgetRoute>().page.isA<LoginPage>(),
        ]);
        pushedRoutes.clear();

        await login(tester, eg.otherAccount);
        final newAccount = testBinding.globalStore.accounts.singleWhere(
          (account) => account.userId != eg.selfAccount.userId);
        checkMatchesAccount(newAccount, eg.otherAccount);
        check(poppedRoutes).length.equals(2);
        check(pushedRoutes).single.isA<WidgetRoute>().page.isA<HomePage>();
      });

      testWidgets('trims whitespace on username', (tester) async {
        final serverSettings = eg.serverSettings();
        await prepare(tester, serverSettings);
        takeStartingRoutes();
        check(pushedRoutes).isEmpty();
        check(testBinding.globalStore.accounts).isEmpty();

        await tester.enterText(findUsernameInput, '  ${eg.selfAccount.email}  ');
        await tester.enterText(findPasswordInput, 'p455w0rd');
        testBinding.globalStore.useCachedApiConnections = true;
        connection.prepare(json: FetchApiKeyResult(
          apiKey: eg.selfAccount.apiKey,
          email: eg.selfAccount.email,
          userId: eg.selfAccount.userId,
        ).toJson());
        await tester.tap(findSubmitButton);
        checkFetchApiKey(username: eg.selfAccount.email, password: 'p455w0rd');
        await tester.idle();
        checkMatchesAccount(testBinding.globalStore.accounts.single,
          eg.selfAccount);
      });

      testWidgets('account already exists: go to it', (tester) async {
        final serverSettings = eg.serverSettings();
        await prepare(tester, serverSettings);
        takeStartingRoutes();
        check(pushedRoutes).isEmpty();
        check(testBinding.globalStore.accounts).isEmpty();
        await testBinding.globalStore.add(eg.selfAccount, eg.initialSnapshot());

        await tester.enterText(findUsernameInput, eg.selfAccount.email);
        await tester.enterText(findPasswordInput, 'p455w0rd');
        testBinding.globalStore.useCachedApiConnections = true;
        connection.prepare(json: FetchApiKeyResult(
          apiKey: eg.selfAccount.apiKey,
          email: eg.selfAccount.email,
          userId: eg.selfAccount.userId,
        ).toJson());
        await tester.tap(findSubmitButton);
        await tester.idle();
        await tester.pump();
        checkNoDialog(tester);
        check(testBinding.globalStore.accounts).single.id.equals(eg.selfAccount.id);
        check(pushedRoutes).single.isA<MaterialAccountWidgetRoute>()
          ..accountId.equals(eg.selfAccount.id)
          ..page.isA<HomePage>();
      });

      testWidgets('account already exists for the email, not the user: error', (tester) async {
        final serverSettings = eg.serverSettings();
        await prepare(tester, serverSettings);
        takeStartingRoutes();
        await testBinding.globalStore.add(eg.selfAccount, eg.initialSnapshot());

        await tester.enterText(findUsernameInput, eg.selfAccount.email);
        await tester.enterText(findPasswordInput, 'p455w0rd');
        testBinding.globalStore.useCachedApiConnections = true;
        connection.prepare(json: FetchApiKeyResult(
          apiKey: eg.selfAccount.apiKey,
          email: eg.selfAccount.email,
          userId: eg.selfAccount.userId + 1,
        ).toJson());
        await tester.tap(findSubmitButton);
        await tester.idle();
        await tester.pump();

        final zulipLocalizations = GlobalLocalizations.zulipLocalizations;
        checkErrorDialog(tester,
          expectedTitle: zulipLocalizations.errorAccountLoggedInTitle);
      });

      testWidgets('creates account with data from server settings', (tester) async {
        final serverSettings = eg.serverSettings(
          realmName: 'Some organization',
          realmIcon: Uri.parse('/some-image.png'),
          zulipFeatureLevel: 427,
          zulipVersion: '12.0-dev-524-ga557b1e721',
          zulipMergeBase: '12.0-dev-523-g72e3b94855',
        );
        await prepare(tester, serverSettings);
        takeStartingRoutes();
        check(pushedRoutes).isEmpty();
        check(testBinding.globalStore.accounts).isEmpty();

        await login(tester, eg.selfAccount);
        checkMatchesAccount(testBinding.globalStore.accounts.single,
          eg.selfAccount.copyWith(
            realmName: Value('Some organization'),
            realmIcon: Value(Uri.parse('/some-image.png')),
            zulipFeatureLevel: 427,
            zulipVersion: '12.0-dev-524-ga557b1e721',
            zulipMergeBase: Value('12.0-dev-523-g72e3b94855')));
      });

      // TODO test validators on the TextFormField widgets
      // TODO test handling failure in fetchApiKey request
      // TODO test _inProgress logic
    });

    group('password auth visibility', () {
      testWidgets('hides username/password fields and login button', (tester) async {
        final serverSettings = eg.serverSettings(
          emailAuthEnabled: false,
          authenticationMethods: eg.authMethods(ldap: false));
        await prepare(tester, serverSettings);
        check(findUsernameInput).findsNothing();
        check(findPasswordInput).findsNothing();
        check(findSubmitButton).findsNothing();
      });

      testWidgets('shows fields when email auth disabled but LDAP enabled', (tester) async {
        final serverSettings = eg.serverSettings(
          emailAuthEnabled: false,
          authenticationMethods: eg.authMethods(ldap: true),
        );
        await prepare(tester, serverSettings);
        check(findUsernameInput).findsOne();
        check(findPasswordInput).findsOne();
        check(findSubmitButton).findsOne();
      });

      testWidgets('shows external auth methods without divider', (tester) async {
        prepareBoringImageHttpClient(); // icon on social-auth button
        final serverSettings = eg.serverSettings(
          emailAuthEnabled: false,
          authenticationMethods: eg.authMethods(ldap: false),
          externalAuthenticationMethods: [googleAuthMethod]);
        await prepare(tester, serverSettings);
        check(find.textContaining('Google')).findsOne();
        final zulipLocalizations = GlobalLocalizations.zulipLocalizations;
        check(find.bySemanticsLabel(zulipLocalizations.loginMethodDividerSemanticLabel))
          .findsNothing();
        debugNetworkImageHttpClientProvider = null;
      });

      testWidgets('shows divider when email auth enabled with external methods', (tester) async {
        prepareBoringImageHttpClient(); // icon on social-auth button
        final serverSettings = eg.serverSettings(
          emailAuthEnabled: true,
          externalAuthenticationMethods: [googleAuthMethod]);
        await prepare(tester, serverSettings);
        check(findUsernameInput).findsOne();
        check(findPasswordInput).findsOne();
        check(findSubmitButton).findsOne();
        check(find.textContaining('Google')).findsOne();
        final zulipLocalizations = GlobalLocalizations.zulipLocalizations;
        check(find.bySemanticsLabel(zulipLocalizations.loginMethodDividerSemanticLabel))
          .findsOne();
        debugNetworkImageHttpClientProvider = null;
      });
    });

    group('web auth', () {
      testWidgets('basic happy case', (tester) async {
        final serverSettings = eg.serverSettings(
          externalAuthenticationMethods: [googleAuthMethod]);
        prepareBoringImageHttpClient(); // icon on social-auth button
        await prepare(tester, serverSettings);
        takeStartingRoutes();
        check(pushedRoutes).isEmpty();
        check(testBinding.globalStore.accounts).isEmpty();

        LoginPage.debugOtpOverride = otp;
        await tester.tap(find.textContaining('Google'));

        final expectedUrl = eg.realmUrl.resolve(googleAuthMethod.loginUrl)
          .replace(queryParameters: {'mobile_flow_otp': otp});
        check(testBinding.takeLaunchUrlCalls())
          .deepEquals([(url: expectedUrl, mode: UrlLaunchMode.inAppBrowserView)]);

        // TODO test _inProgress logic?

        final encoded = debugEncodeApiKey(eg.selfAccount.apiKey, otp);
        final url = Uri(scheme: 'zulip', host: 'login', queryParameters: {
          'otp_encrypted_api_key': encoded,
          'email': eg.selfAccount.email,
          'user_id': eg.selfAccount.userId.toString(),
          'realm': eg.selfAccount.realmUrl.toString(),
        });

        final ByteData message = const JSONMethodCodec().encodeMethodCall(
          MethodCall('pushRouteInformation', {'location': url.toString()}));
        await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
          'flutter/navigation', message, null);

        check(testBinding.takeCloseInAppWebViewCallCount()).equals(1);

        final account = testBinding.globalStore.accounts.single;
        checkMatchesAccount(account, eg.selfAccount);
        check(pushedRoutes).single.isA<MaterialAccountWidgetRoute>()
          ..accountId.equals(account.id)
          ..page.isA<HomePage>();

        debugNetworkImageHttpClientProvider = null;
      });

      // TODO failures, such as: invalid loginUrl; URL can't be launched;
      //   WebAuthPayload.realm doesn't match the realm the UI is about
    });

    group('Kloki sign-in', () {
      Future<void> prepareKloki(WidgetTester tester, {bool emailAuthEnabled = true}) async {
        prepareBoringImageHttpClient(); // realm icon
        addTearDown(() => debugNetworkImageHttpClientProvider = null);
        await prepare(tester, eg.serverSettings(
          emailAuthEnabled: emailAuthEnabled,
          externalAuthenticationMethods: [klokiAuthMethod]));
        takeStartingRoutes();
      }

      testWidgets('Kloki button opens Kloki in the browser', (tester) async {
        await prepareKloki(tester);
        check(testBinding.takeLaunchUrlCalls()).isEmpty();
        check(findPasswordInput).findsNothing();

        LoginPage.debugOtpOverride = otp;
        addTearDown(() => LoginPage.debugOtpOverride = null);
        await tester.ensureVisible(find.text('Sign in through Kloki'));
        await tester.tap(find.text('Sign in through Kloki'));
        final expectedUrl = eg.realmUrl.resolve(klokiAuthMethod.loginUrl)
          .replace(queryParameters: {'mobile_flow_otp': otp});
        check(testBinding.takeLaunchUrlCalls())
          .deepEquals([(url: expectedUrl, mode: UrlLaunchMode.inAppBrowserView)]);
      });

      testWidgets('switch to guest sign-in and back', (tester) async {
        await prepareKloki(tester);

        await tester.ensureVisible(find.text('Guest sign-in'));
        await tester.tap(find.text('Guest sign-in'));
        await tester.pump();
        check(findPasswordInput).findsOne();
        check(find.text('Sign in through Kloki')).findsNothing();

        await tester.ensureVisible(find.text('Back to signing in through Kloki'));
        await tester.tap(find.text('Back to signing in through Kloki'));
        await tester.pump();
        check(findPasswordInput).findsNothing();
        check(find.text('Sign in through Kloki')).findsOne();
      });

      testWidgets('no guest sign-in without password auth', (tester) async {
        await prepareKloki(tester, emailAuthEnabled: false);
        check(find.text('Guest sign-in')).findsNothing();
      });
    });
  });
}
