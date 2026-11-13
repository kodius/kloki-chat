import 'package:checks/checks.dart';
import 'package:convert/convert.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zulip/api/model/web_auth.dart';

import '../../example_data.dart' as eg;

void main() {
  group('WebAuthPayload', () {
    const otp = '186f6d085a5621ebaf1ccfc05033e8acba57dae03f061705ac1e58c402c30a31';
    final encryptedApiKey = debugEncodeApiKey(eg.selfAccount.apiKey, otp);
    final wellFormed = Uri.parse(
      'zulip://login?otp_encrypted_api_key=$encryptedApiKey'
        '&email=self%40example&user_id=1&realm=https%3A%2F%2Fchat.example%2F');

    test('basic happy case', () {
      final payload = WebAuthPayload.parse(wellFormed);
      check(payload)
        ..otpEncryptedApiKey.equals(encryptedApiKey)
        ..email.equals('self@example')
        ..userId.equals(1)
        ..realm.equals(Uri.parse('https://chat.example/'));
      check(payload.decodeApiKey(otp)).equals(eg.selfAccount.apiKey);
    });

    test('parse fails when an expected field is missing', () {
      final queryParams = {...wellFormed.queryParameters}..remove('email');
      final input = wellFormed.replace(queryParameters: queryParams);
      check(() => WebAuthPayload.parse(input)).throws<FormatException>();
    });

    test('parse fails when otp_encrypted_api_key is wrong length', () {
      final queryParams = {...wellFormed.queryParameters}
        ..['otp_encrypted_api_key'] = 'asdf';
      final input = wellFormed.replace(queryParameters: queryParams);
      check(() => WebAuthPayload.parse(input)).throws<FormatException>();
    });

    test('parse fails when host is not "login"', () {
      final input = wellFormed.replace(host: 'foo');
      check(() => WebAuthPayload.parse(input)).throws<FormatException>();
    });

    test('parse fails when scheme is not "zulip"', () {
      final input = wellFormed.replace(scheme: 'https');
      check(() => WebAuthPayload.parse(input)).throws<FormatException>();
    });

    test('decodeApiKey fails when otp is wrong length', () {
      final payload = WebAuthPayload.parse(wellFormed);
      check(() => payload.decodeApiKey('asdf')).throws<FormatException>();
    });
  });

  group('KlokiLoginLink', () {
    Uri link({String? realm = 'https://firma.chat.kloki.app', String? token = 'jwt'}) =>
      Uri(scheme: 'konvo', host: 'kloki-login', queryParameters: {
        'realm': ?realm,
        'token': ?token,
      });

    test('kloki-chat and the old konvo scheme, nothing else', () {
      Uri withScheme(String scheme) => link().replace(scheme: scheme);
      check(KlokiLoginLink.isKlokiLoginUrl(withScheme('kloki-chat'))).isTrue();
      check(KlokiLoginLink.isKlokiLoginUrl(withScheme('konvo'))).isTrue();
      check(KlokiLoginLink.isKlokiLoginUrl(withScheme('zulip'))).isFalse();
      check(KlokiLoginLink.isKlokiLoginUrl(withScheme('https'))).isFalse();
    });

    test('basic happy case', () {
      check(KlokiLoginLink.parse(link()))
        ..realm.equals(Uri.parse('https://firma.chat.kloki.app'))
        ..token.equals('jwt');
    });

    test('dev realm', () {
      check(KlokiLoginLink.parse(link(realm: 'https://firma.chat.dev.kloki.app/')))
        .realm.equals(Uri.parse('https://firma.chat.dev.kloki.app'));
    });

    test('realm reduced to scheme and lowercase host', () {
      check(KlokiLoginLink.parse(link(realm: 'https://Firma.Chat.Kloki.App/#narrow')))
        .realm.equals(Uri.parse('https://firma.chat.kloki.app'));
    });

    test('parse fails for a realm outside Kloki', () {
      for (final realm in [
        'https://chat.zulip.org',
        'https://chat.kloki.app',
        'https://evilchat.kloki.app',
        'https://firma.chat.kloki.app.evil.example',
        'https://a.b.chat.kloki.app',
        'http://firma.chat.kloki.app',
        'https://firma.chat.kloki.app:8443',
        'https://user@firma.chat.kloki.app',
        'not a url',
      ]) {
        check(because: realm, () => KlokiLoginLink.parse(link(realm: realm)))
          .throws<FormatException>();
        check(because: realm,
          KlokiLoginLink.allowedRealmOf(link(realm: realm))).isNull();
      }
    });

    test('parse fails without realm or token', () {
      check(() => KlokiLoginLink.parse(link(realm: null))).throws<FormatException>();
      check(() => KlokiLoginLink.parse(link(token: null))).throws<FormatException>();
      check(() => KlokiLoginLink.parse(link(token: ''))).throws<FormatException>();
    });

    test('parse fails for another scheme or host', () {
      check(() => KlokiLoginLink.parse(link().replace(scheme: 'zulip')))
        .throws<FormatException>();
      check(() => KlokiLoginLink.parse(link().replace(host: 'login')))
        .throws<FormatException>();
    });

    test('session, sealed, from Kloki\'s web sign-in', () {
      check(KlokiLoginLink.parse(link()).sealedSession).isNull();
      final url = link().replace(queryParameters: {
        ...link().queryParameters, 'session': 'abcd'});
      check(KlokiLoginLink.parse(url).sealedSession).equals('abcd');
    });

    test('forRealm', () {
      check(KlokiLoginLink.forRealm(
          realm: Uri.parse('https://Firma.chat.kloki.app/'), token: 'jwt'))
        ..realm.equals(Uri.parse('https://firma.chat.kloki.app'))
        ..token.equals('jwt');
      check(() => KlokiLoginLink.forRealm(
        realm: Uri.parse('https://chat.zulip.org'), token: 'jwt')).throws<FormatException>();
      check(() => KlokiLoginLink.forRealm(
        realm: Uri.parse('https://firma.chat.kloki.app'), token: '')).throws<FormatException>();
    });

    test('allowedRealmOf with a bad token', () {
      check(KlokiLoginLink.allowedRealmOf(link(token: null)))
        .equals(Uri.parse('https://firma.chat.kloki.app'));
    });
  });

  group('parseKlokiOrganization', () {
    final firma = Uri.parse('https://firma.chat.kloki.app');

    test('subdomain', () {
      check(parseKlokiOrganization('firma')).equals(firma);
      check(parseKlokiOrganization(' Firma-2 ')).equals(
        Uri.parse('https://firma-2.chat.kloki.app'));
    });

    test('host or URL, reduced to the realm', () {
      for (final input in [
        'firma.chat.kloki.app',
        'https://firma.chat.kloki.app',
        'https://Firma.chat.kloki.app/join/abcdefghijklmnopqrstuvwx/',
        'https://firma.chat.kloki.app/#narrow/channel/1-general',
      ]) {
        check(because: input, parseKlokiOrganization(input)).equals(firma);
      }
    });

    test('dev realm', () {
      check(parseKlokiOrganization('firma.chat.dev.kloki.app'))
        .equals(Uri.parse('https://firma.chat.dev.kloki.app'));
    });

    test('null for no Kloki realm', () {
      for (final input in [
        '',
        '-firma',
        'firma-',
        'fir ma',
        'chat.zulip.org',
        'chat.kloki.app',
        'kloki.app',
        'http://firma.chat.kloki.app',
        'firma.chat.kloki.app.evil.example',
        'https://firma.chat.kloki.app:8443',
      ]) {
        check(because: input, parseKlokiOrganization(input)).isNull();
      }
    });
  });

  group('openKlokiSession', () {
    const otp = '186f6d085a5621ebaf1ccfc05033e8acba57dae03f061705ac1e58c402c30a31';
    const session = 'eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjo3fQ.sig-longer-than-one-block';

    test('opens what Kloki\'s web sign-in seals', () {
      // The same vector as `sealForApp`'s test in Kloki's web app
      // (apps/users/__tests__/chat-app-handoff.test.ts).
      check(openKlokiSession(
        'd326136e9a315696b41dbafd447da312102f1736a48da88dbb98459f55dde1f3'
        '0dd578b5ac180258241a15941bde6029907a5c668baf8d0209d75feb2681f8580e',
        otp)).equals(session);
      check(debugSealKlokiSession(session, otp)).equals(
        'd326136e9a315696b41dbafd447da312102f1736a48da88dbb98459f55dde1f3'
        '0dd578b5ac180258241a15941bde6029907a5c668baf8d0209d75feb2681f8580e');
    });

    test('throws for what isn\'t hex', () {
      check(() => openKlokiSession('zz', otp)).throws<FormatException>();
      check(() => openKlokiSession('abcd', 'not hex')).throws<FormatException>();
    });
  });

  group('generateOtp', () {
    test('smoke, and check all 256 byte values are used', () {
      // This is a probabilistic test.  We've chosen `n` so that when the test
      // should pass, the probability it fails is < 1e-9.  See analysis below.
      const n = 216;
      final manyOtps = List.generate(n, (_) => generateOtp());

      final bytesThatAppear = <int>{};
      for (final otp in manyOtps) {
        final bytes = hex.decode(otp);
        check(bytes).length.equals(32);
        bytesThatAppear.addAll(bytes);
      }

      // Each possible value gets n * 32 opportunities to show up,
      // each with probability 1/256; so the probability of missing all of those
      // is exp(- n * 32 / 256) < 2e-12, and there are 256 such possible
      // byte values so the probability that any of them gets missed is < 1e-9.
      for (final byteValue in Iterable<int>.generate(256)) {
        check(bytesThatAppear).contains(byteValue);
      }
    });
  });
}

extension WebAuthPayloadChecks on Subject<WebAuthPayload> {
  Subject<String> get otpEncryptedApiKey => has((x) => x.otpEncryptedApiKey, 'otpEncryptedApiKey');
  Subject<String> get email => has((x) => x.email, 'email');
  Subject<int> get userId => has((x) => x.userId, 'userId');
  Subject<Uri> get realm => has((x) => x.realm, 'realm');
}

extension KlokiLoginLinkChecks on Subject<KlokiLoginLink> {
  Subject<Uri> get realm => has((x) => x.realm, 'realm');
  Subject<String> get token => has((x) => x.token, 'token');
}
