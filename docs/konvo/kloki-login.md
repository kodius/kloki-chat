# Signing in with Kloki

Kloki's chat runs on a Zulip server
with one realm per company, at `https://<slug>.chat.kloki.app`
(dev `https://<slug>.chat.dev.kloki.app`).
People don't have a chat password:
their accounts come from Kloki, and they sign in through it.

## The first screen

`KlokiSignInPage` (in `lib/widgets/login.dart`) asks for the
organization, starting with `kodius` (`kKlokiDefaultOrganization`
in `lib/widgets/kloki.dart`).
It takes the realm's slug, its host, or any link on it,
such as the link in a guest's invitation;
`parseKlokiOrganization` (in `lib/api/model/web_auth.dart`)
turns that into the realm, and refuses anything
not under `*.chat.kloki.app` or `*.chat.dev.kloki.app`
before any request.
Both buttons go to that realm:

* **Sign in through Kloki**: fetches the server's settings,
  finds the Kloki entry among its external authentication methods,
  and opens it in the browser.
  The browser comes back to the app with the API key,
  as for any Zulip web sign-in.
* **Guest sign-in**: opens the password form
  on the same server, for guests the company invited
  who have no Kloki account.
  It's also how the App Store and Google Play reviewers sign in.
* **Sign in to another server**: opens the stock Zulip
  `AddAccountPage`, for any other Zulip server.

If the server has no Kloki method,
the app falls back to the password form.

## On the login page

`LoginPage` shows the Kloki button
when the server offers a Kloki method,
with a link to switch to the guest password form and back.
Without password auth on the server,
there's no guest link.

## From Kloki GO, without typing

Kloki GO opens the chat with a link like

```
konvo://kloki-login?realm=https://slug.chat.kloki.app&token=<jwt>
```

where the token is the 60-second JWT
Kloki issues for one realm and one person
(`POST /api/chat/login-token`).
`KlokiLinkSignIn` (in `lib/widgets/login.dart`) handles it,
on a cold start (on Android, the link is the initial route)
and with the app running:

* The realm must be HTTPS on `<slug>.chat.kloki.app`
  or `<slug>.chat.dev.kloki.app` (`KlokiLoginLink` in
  `lib/api/model/web_auth.dart`); any other link is refused
  before any request, so the token never goes to another server.
* With an account here already on that realm, for the token's e-mail,
  the app just switches to it, and the token goes unused.
* Otherwise it fetches the realm's server settings,
  makes a one-time pad, and posts the token and pad to
  `/accounts/login/jwt/` on the realm without following the redirect
  (`postKlokiJwtLogin`).
  The redirect's `zulip://login?…` carries the API key,
  as at the end of a browser sign-in.
  No browser and no sign-in page are shown.
* If any of that fails (an expired token, the server unreachable),
  a dialog offers *Back to Kloki GO* (`klokimobile://`)
  and *Sign in here*: the login page of the same realm,
  or the server URL page with the realm filled in.

The shared `konvo` scheme is registered in
`android/app/src/main/AndroidManifest.xml` and `ios/Runner/Info.plist`.
The `zulip` scheme stays for the browser sign-in only,
since the Zulip app may hold it too.

To try it on a device, get a token from Kloki
(`Chat::IssueLoginToken` in the boro console)
and open the link within a minute:

```bash
adb shell am start -a android.intent.action.VIEW \
  -d 'konvo://kloki-login?realm=https://slug.chat.dev.kloki.app&token=…'
xcrun simctl openurl booted \
  'konvo://kloki-login?realm=https://slug.chat.dev.kloki.app&token=…'
```

## Tests

The flows above are covered in `test/widgets/login_test.dart`,
in the `KlokiSignInPage` and `KlokiLinkSignIn` groups
and the `Kloki sign-in` group under `LoginPage`;
the link and the request in `test/api/model/web_auth_test.dart`
and `test/api/route/kloki_test.dart`.
The server side is tested in the Kloki fork of Zulip
(`test_kloki_jwt_from_konvo_*` in `zerver/tests/test_auth_backends.py`).
