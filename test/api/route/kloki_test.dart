import 'dart:convert';

import 'package:checks/checks.dart';
import 'package:http/http.dart' as http;
import 'package:test/scaffolding.dart';
import 'package:zulip/api/exception.dart';
import 'package:zulip/api/route/kloki.dart';

import '../../stdlib_checks.dart';
import '../exception_checks.dart';
import '../fake_api.dart';

void main() {
  group('postKlokiJwtLogin', () {
    const otp = '186f6d085a5621ebaf1ccfc05033e8acba57dae03f061705ac1e58c402c30a31';
    final location = Uri.parse('zulip://login?realm=https%3A%2F%2Fchat.example'
      '&email=self%40example&user_id=1&otp_encrypted_api_key=abcd');

    test('smoke', () {
      return FakeApiConnection.with_((connection) async {
        connection.prepare(httpStatus: 302,
          headers: {'location': location.toString()});
        final result = await postKlokiJwtLogin(connection,
          token: 'jwt-token', mobileFlowOtp: otp);
        check(result).equals(location);
        check(connection.takeRequests()).single.isA<http.Request>()
          ..method.equals('POST')
          ..url.path.equals('/accounts/login/jwt/')
          ..followRedirects.isFalse()
          ..headers.not((it) => it.containsKey('Authorization'))
          ..bodyFields.deepEquals({
            'token': 'jwt-token',
            'mobile_flow_otp': otp,
          });
      });
    });

    test('error from the server', () {
      return FakeApiConnection.with_((connection) async {
        connection.prepare(httpStatus: 400, json: {
          'result': 'error', 'code': 'BAD_REQUEST', 'msg': 'Bad JSON web token'});
        await check(postKlokiJwtLogin(connection,
          token: 'expired', mobileFlowOtp: otp))
          .throws<ZulipApiException>((it) => it.message.equals('Bad JSON web token'));
      });
    });

    test('no redirect', () {
      return FakeApiConnection.with_((connection) async {
        connection.prepare(httpStatus: 200, body: '<html></html>');
        await check(postKlokiJwtLogin(connection,
          token: 'jwt-token', mobileFlowOtp: otp))
          .throws<MalformedServerResponseException>();
      });
    });

    test('redirect without location', () {
      return FakeApiConnection.with_((connection) async {
        connection.prepare(httpStatus: 302);
        await check(postKlokiJwtLogin(connection,
          token: 'jwt-token', mobileFlowOtp: otp))
          .throws<MalformedServerResponseException>();
      });
    });
  });

  group('Kloki API', () {
    const session = 'kloki-session';

    test('getKlokiProfiles', () {
      return FakeApiConnection.with_((connection) async {
        connection.prepare(body: jsonEncode([
          {'id': '7', 'company_name': 'Kodius', 'company_id': '1'},
          {'id': '9', 'company_name': 'Firma', 'company_id': '2'},
        ]));
        final result = await getKlokiProfiles(connection, session: session);
        check(result.map((p) => (p.userId, p.companyName)))
          .deepEquals([('7', 'Kodius'), ('9', 'Firma')]);
        check(connection.takeRequests()).single.isA<http.Request>()
          ..method.equals('GET')
          ..url.path.equals('/api/users/profiles')
          ..headers['Authorization'].equals('Bearer $session');
      });
    });

    test('switchKlokiProfile', () {
      return FakeApiConnection.with_((connection) async {
        connection.prepare(json: {'auth_token': 'profile-session', 'id': 9});
        final result = await switchKlokiProfile(connection,
          session: session, userId: '9');
        check(result).equals('profile-session');
        check(connection.takeRequests()).single.isA<http.Request>()
          ..method.equals('POST')
          ..url.path.equals('/api/users/switch-profile')
          ..headers['Authorization'].equals('Bearer $session')
          ..body.equals(jsonEncode({'user_id': '9'}));
      });
    });

    test('postKlokiChatLoginToken', () {
      return FakeApiConnection.with_((connection) async {
        connection.prepare(json: {
          'token': 'jwt', 'login_url': 'https://firma.chat.kloki.app/accounts/login/jwt/',
          'realm_url': 'https://firma.chat.kloki.app', 'next': '/'});
        final result = await postKlokiChatLoginToken(connection, session: session);
        check(result.token).equals('jwt');
        check(result.realmUrl).equals(Uri.parse('https://firma.chat.kloki.app'));
        check(connection.takeRequests()).single.isA<http.Request>()
          ..method.equals('POST')
          ..url.path.equals('/api/chat/login-token');
      });
    });

    test('refusal, with Kloki\'s error code', () {
      return FakeApiConnection.with_((connection) async {
        connection.prepare(httpStatus: 403, json: {'error_code': 'chat_not_connected'});
        await check(postKlokiChatLoginToken(connection, session: session))
          .throws<KlokiApiException>((it) => it
            ..has((e) => e.httpStatus, 'httpStatus').equals(403)
            ..has((e) => e.code, 'code').equals('chat_not_connected')
            ..has((e) => e.sessionRefused, 'sessionRefused').isFalse());

        connection.prepare(httpStatus: 401, json: {'message': 'Unauthorized'});
        await check(getKlokiProfiles(connection, session: session))
          .throws<KlokiApiException>((it) => it
            .has((e) => e.sessionRefused, 'sessionRefused').isTrue());
      });
    });
  });
}
