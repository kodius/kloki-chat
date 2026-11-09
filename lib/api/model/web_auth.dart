import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';
import 'package:meta/meta.dart';

/// The authentication information contained in the zulip:// redirect URL.
class WebAuthPayload {
  final Uri realm;
  final String email;
  final int userId;
  final String otpEncryptedApiKey;

  WebAuthPayload._({
    required this.realm,
    required this.email,
    required this.userId,
    required this.otpEncryptedApiKey,
  });

  factory WebAuthPayload.parse(Uri url) {
    if (
      url case Uri(
        scheme: 'zulip',
        host: 'login',
        queryParameters: {
          'realm': String realmStr,
          'email': String email,
          'user_id': String userIdStr,
          'otp_encrypted_api_key': String otpEncryptedApiKey,
        },
      )
    ) {
      final Uri? realm = Uri.tryParse(realmStr);
      if (realm == null) throw const FormatException();

      final int? userId = int.tryParse(userIdStr, radix: 10);
      if (userId == null) throw const FormatException();

      if (!RegExp(r'^[0-9a-fA-F]{64}$').hasMatch(otpEncryptedApiKey)) {
        throw const FormatException();
      }

      return WebAuthPayload._(
        otpEncryptedApiKey: otpEncryptedApiKey,
        email: email,
        userId: userId,
        realm: realm,
      );
    } else {
      // TODO(dart): simplify after https://github.com/dart-lang/language/issues/2537
      throw const FormatException();
    }
  }

  String decodeApiKey(String otp) {
    final otpBytes = hex.decode(otp);
    final otpEncryptedApiKeyBytes = hex.decode(otpEncryptedApiKey);
    if (otpBytes.length != otpEncryptedApiKeyBytes.length) {
      throw const FormatException();
    }
    return String.fromCharCodes(Iterable.generate(otpBytes.length,
      (i) => otpBytes[i] ^ otpEncryptedApiKeyBytes[i]));
  }
}

/// A link from Kloki GO that signs in to a Kloki chat realm, like
/// `konvo://kloki-login?realm=https://slug.chat.kloki.app&token=…`.
///
/// The token is the 60-second JWT Kloki issues for one realm and one person.
/// The app posts it to the realm itself; see `postKlokiJwtLogin`.
///
/// From Kloki's web sign-in, which Kloki Chat starts,
/// the link also carries the Kloki session, sealed
/// with the app's one-time pad; see [openKlokiSession].
class KlokiLoginLink {
  final Uri realm;
  final String token;

  /// The Kloki session, sealed; see [openKlokiSession].
  final String? sealedSession;

  KlokiLoginLink._({required this.realm, required this.token, this.sealedSession});

  /// The token's `email` claim, if it can be read.
  ///
  /// The signature isn't checked; that's for the server.
  /// This is only for choosing among accounts already signed in.
  String? get email {
    final parts = token.split('.');
    if (parts.length != 3) return null;
    try {
      final claims = jsonDecode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))));
      return switch (claims) {
        {'email': String email} => email,
        _ => null,
      };
    } on FormatException {
      return null;
    }
  }

  /// Hosts under which a realm may be signed in to from a link.
  ///
  /// A link to any other server is refused before any request,
  /// so a token can't be sent to a server that isn't Kloki's.
  static const allowedRealmHostSuffixes = ['.chat.kloki.app', '.chat.dev.kloki.app'];

  /// Whether [url] is a sign-in link from Kloki GO, well-formed or not.
  static bool isKlokiLoginUrl(Uri url) =>
    url.scheme == 'konvo' && url.host == 'kloki-login';

  /// The link's realm, as a URL with only scheme and host,
  /// if it is one a link may sign in to; else null.
  static Uri? allowedRealmOf(Uri url) {
    final realmStr = url.queryParameters['realm'];
    if (realmStr == null) return null;
    final realm = Uri.tryParse(realmStr);
    if (realm == null) return null;
    return allowedRealm(realm);
  }

  /// [realm] as a URL with only scheme and host,
  /// if it is a Kloki realm; else null.
  static Uri? allowedRealm(Uri realm) {
    if (realm.scheme != 'https'
        || realm.userInfo.isNotEmpty
        || realm.hasPort) {
      return null;
    }
    final host = realm.host.toLowerCase();
    final allowed = allowedRealmHostSuffixes.any((suffix) =>
      host.length > suffix.length && host.endsWith(suffix)
        && !host.substring(0, host.length - suffix.length).contains('.'));
    if (!allowed) return null;
    return Uri(scheme: 'https', host: host);
  }

  /// A sign-in to [realm] with [token], as from Kloki's API
  /// (see `postKlokiChatLoginToken`).
  ///
  /// Throws [FormatException] if [realm] isn't a Kloki realm.
  factory KlokiLoginLink.forRealm({required Uri realm, required String token}) {
    final allowed = allowedRealm(realm);
    if (allowed == null || token.isEmpty) throw const FormatException();
    return KlokiLoginLink._(realm: allowed, token: token);
  }

  /// Throws [FormatException] if [url] isn't a sign-in link
  /// to an allowed realm, with a token.
  factory KlokiLoginLink.parse(Uri url) {
    if (!isKlokiLoginUrl(url)) throw const FormatException();
    final realm = allowedRealmOf(url);
    final token = url.queryParameters['token'];
    if (realm == null || token == null || token.isEmpty) {
      throw const FormatException();
    }
    return KlokiLoginLink._(realm: realm, token: token,
      sealedSession: url.queryParameters['session']);
  }
}

/// The Kloki realm for what someone typed as their organization:
/// the realm's subdomain (`firma` for `https://firma.chat.kloki.app`),
/// its host, or any URL on it, such as a link from an invitation.
///
/// Null if the input names no realm under
/// [KlokiLoginLink.allowedRealmHostSuffixes].
Uri? parseKlokiOrganization(String input) {
  final text = input.trim().toLowerCase();
  if (_klokiRealmSubdomain.hasMatch(text)) {
    return Uri(scheme: 'https', host: '$text.chat.kloki.app');
  }
  final url = Uri.tryParse(text.contains('://') ? text : 'https://$text');
  if (url == null) return null;
  return KlokiLoginLink.allowedRealm(url);
}

/// A realm subdomain: lowercase letters, digits, inner hyphens.
final _klokiRealmSubdomain = RegExp(r'^[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?$');

/// The Kloki session in [sealed], as Kloki's web sign-in seals it
/// with the one-time pad [otp] the app sent.
///
/// Sealed is hex: the session's UTF-8 bytes, XOR the keystream
/// SHA-256(pad ‖ block index as 4 bytes, big-endian), block after block.
/// The same as `sealForApp` in Kloki's web app
/// (apps/users/features/chat/helpers/app-handoff.ts).
///
/// Throws [FormatException] if either isn't hex, or the result isn't UTF-8.
String openKlokiSession(String sealed, String otp) {
  final List<int> sealedBytes;
  final List<int> pad;
  try {
    sealedBytes = hex.decode(sealed);
    pad = hex.decode(otp);
  } on Object {
    throw const FormatException();
  }
  final out = Uint8List(sealedBytes.length);
  for (var block = 0; block * 32 < sealedBytes.length; block++) {
    final index = ByteData(4)..setUint32(0, block);
    final stream = sha256.convert([...pad, ...index.buffer.asUint8List()]).bytes;
    for (var i = 0; i < 32 && block * 32 + i < sealedBytes.length; i++) {
      out[block * 32 + i] = sealedBytes[block * 32 + i] ^ stream[i];
    }
  }
  return utf8.decode(out);
}

String generateOtp() {
  final rand = Random.secure();
  final Uint8List bytes = Uint8List.fromList(
    List.generate(32, (_) => rand.nextInt(256)));
  return hex.encode(bytes);
}

/// For tests, seal [session] as Kloki's web sign-in does;
/// see [openKlokiSession].
@visibleForTesting
String debugSealKlokiSession(String session, String otp) {
  final data = utf8.encode(session);
  final pad = hex.decode(otp);
  final out = Uint8List(data.length);
  for (var block = 0; block * 32 < data.length; block++) {
    final index = ByteData(4)..setUint32(0, block);
    final stream = sha256.convert([...pad, ...index.buffer.asUint8List()]).bytes;
    for (var i = 0; i < 32 && block * 32 + i < data.length; i++) {
      out[block * 32 + i] = data[block * 32 + i] ^ stream[i];
    }
  }
  return hex.encode(out);
}

/// For tests, create an OTP-encrypted API key.
@visibleForTesting
String debugEncodeApiKey(String apiKey, String otp) {
  final apiKeyBytes = apiKey.codeUnits;
  assert(apiKeyBytes.every((byte) => byte <= 0xff));
  final otpBytes = hex.decode(otp);
  assert(apiKeyBytes.length == otpBytes.length);
  return hex.encode(List.generate(otpBytes.length,
    (i) => apiKeyBytes[i] ^ otpBytes[i]));
}
