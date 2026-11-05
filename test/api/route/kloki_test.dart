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
}
