import 'dart:convert';

import 'package:http/http.dart' as http;

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

/// Kloki's API, on which Kloki Chat lists the person's companies
/// and switches between them, with the Kloki session
/// (see `GlobalSettingsStore.klokiSession`).
///
/// An [ApiConnection] for it has this as its realm URL
/// and no Zulip credentials.
final kKlokiApiUrl = Uri.parse('https://api.kloki.app');

/// Kloki refused a request, or answered with something unexpected.
class KlokiApiException implements Exception {
  KlokiApiException(this.routeName, {required this.httpStatus, this.code});

  final String routeName;
  final int httpStatus;

  /// Kloki's `error_code`, like `chat_not_connected`, if it sent one.
  final String? code;

  /// Whether the session is no good any more (expired, or signed out).
  bool get sessionRefused => httpStatus == 401;

  @override
  String toString() => 'KlokiApiException: $routeName: $httpStatus${code == null ? '' : ' $code'}';
}

/// One of the companies the person is in, with its profile there.
class KlokiProfile {
  KlokiProfile({required this.userId, required this.companyName});

  /// The person's user (profile) ID in that company.
  final String userId;
  final String companyName;
}

Future<Object?> _klokiRequest(ApiConnection connection, String routeName, {
  required String session,
  required String method,
  required String path,
  Map<String, Object?>? body,
}) async {
  final request = http.Request(method, connection.realmUrl.replace(path: path))
    ..headers['Authorization'] = 'Bearer $session'
    ..headers['Accept'] = 'application/json';
  if (body != null) {
    request.headers['Content-Type'] = 'application/json';
    request.body = jsonEncode(body);
  }
  final (:httpStatus, :json) = await connection.sendForJson(routeName, request);
  if (httpStatus != 200) {
    final code = switch (json) {
      {'error_code': String code} => code,
      _ => null,
    };
    throw KlokiApiException(routeName, httpStatus: httpStatus, code: code);
  }
  return json;
}

/// The person's companies; empty when there's only the one.
///
/// Kloki's `GET /api/users/profiles`.
Future<List<KlokiProfile>> getKlokiProfiles(ApiConnection connection, {
  required String session,
}) async {
  final json = await _klokiRequest(connection, 'getKlokiProfiles',
    session: session, method: 'GET', path: '/api/users/profiles');
  if (json is! List) {
    throw KlokiApiException('getKlokiProfiles', httpStatus: 200);
  }
  return [
    for (final item in json)
      if (item case {'id': String userId, 'company_name': String companyName})
        KlokiProfile(userId: userId, companyName: companyName),
  ];
}

/// Switch the session to the person's profile in another company;
/// returns the session for that profile.
///
/// Kloki's `POST /api/users/switch-profile`.
Future<String> switchKlokiProfile(ApiConnection connection, {
  required String session,
  required String userId,
}) async {
  final json = await _klokiRequest(connection, 'switchKlokiProfile',
    session: session, method: 'POST', path: '/api/users/switch-profile',
    body: {'user_id': userId});
  return switch (json) {
    {'auth_token': String authToken} => authToken,
    _ => throw KlokiApiException('switchKlokiProfile', httpStatus: 200),
  };
}

/// Kloki's token for signing in to the chat of the session's company.
class KlokiChatLoginToken {
  KlokiChatLoginToken({required this.token, required this.realmUrl});

  /// The 60-second JWT; see [postKlokiJwtLogin].
  final String token;
  final Uri realmUrl;
}

/// The token for signing in to the chat of the session's company.
///
/// Kloki's `POST /api/chat/login-token`.
Future<KlokiChatLoginToken> postKlokiChatLoginToken(ApiConnection connection, {
  required String session,
}) async {
  final json = await _klokiRequest(connection, 'postKlokiChatLoginToken',
    session: session, method: 'POST', path: '/api/chat/login-token',
    body: {});
  if (json case {'token': String token, 'realm_url': String realmUrlStr}) {
    final realmUrl = Uri.tryParse(realmUrlStr);
    if (realmUrl != null) return KlokiChatLoginToken(token: token, realmUrl: realmUrl);
  }
  throw KlokiApiException('postKlokiChatLoginToken', httpStatus: 200);
}
