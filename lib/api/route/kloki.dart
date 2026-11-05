import '../core.dart';

/// Sign in with a Kloki chat token, for the mobile flow.
///
/// Kloki issues the token (a 60-second JWT for one realm and one person);
/// the server answers with a redirect to `zulip://login?…`,
/// carrying the API key encrypted with [mobileFlowOtp].
/// That URL is returned, not followed;
/// see `WebAuthPayload.parse`.
///
/// This is the Kloki fork's `/accounts/login/jwt/`, outside the API.
Future<Uri> postKlokiJwtLogin(ApiConnection connection, {
  required String token,
  required String mobileFlowOtp,
}) {
  return connection.postFormForRedirect('postKlokiJwtLogin',
    '/accounts/login/jwt/', {
      'token': token,
      'mobile_flow_otp': mobileFlowOtp,
    });
}
