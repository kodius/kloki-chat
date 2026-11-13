# Signing in with Kloki

Kloki's chat runs on a Zulip server
with one realm per company, at `https://<slug>.chat.kloki.app`
(dev `https://<slug>.chat.dev.kloki.app`).
People don't have a chat password:
their accounts come from Kloki, and they sign in through it.

## The first screen

`KlokiSignInPage` (in `lib/widgets/login.dart`) asks for nothing:

* **Sign in through Kloki**: opens Kloki's
  `https://kloki.app/app/auth/chat?kloki_chat_otp=<pad>`
  (`kKlokiChatSignInUrl` in `lib/widgets/kloki.dart`,
  `KlokiLinkSignIn.beginWebSignIn`) in the browser.
  Kloki signs the person in if needed;
  then its `/api/chat-app-handoff` asks boro for the token
  of the company active in Kloki (`POST /api/chat/login-token`
  without `realm`) and redirects to
  `konvo://kloki-login?realm=…&token=…&session=…`:
  Kloki GO's sign-in link (below), plus the Kloki session
  (Kloki's own 30-day auth token), sealed with the pad.
  The app opens the session (`openKlokiSession`
  in `lib/api/model/web_auth.dart`; the web's `sealForApp`
  seals it the same way), keeps it
  (`GlobalSettingsStore.klokiSession`, cleared when Kloki refuses it
  or the last account is logged out),
  and signs in with the token as from Kloki GO.
  A session in a link the app didn't ask for is ignored.
* **Guest sign-in** and **Sign in to another server**: open
  `AddAccountPage`, which asks for the organization,
  shown with a fixed `.chat.kloki.app` after it.
  It takes the realm's slug, its host, or any link on it,
  such as the link in a guest's invitation;
  `parseKlokiOrganization` (in `lib/api/model/web_auth.dart`)
  turns that into the realm, and refuses anything
  not under `*.chat.kloki.app` or `*.chat.dev.kloki.app`
  before any request, so no other Zulip server can be added.
  From the guest link it goes on to the password form,
  for guests the company invited who have no Kloki account;
  it's also how the App Store and Google Play reviewers sign in.
  Otherwise it goes to the realm's `LoginPage`.

If the server has no Kloki method,
`LoginPage` falls back to the password form.

## Switching between companies

The main menu's **Organizations** (`KlokiOrganizationsPage`
in `lib/widgets/kloki_organizations.dart`) lists the person's companies
with the Kloki session (`GET https://api.kloki.app/api/users/profiles`;
an empty list means just the one), the session's own marked.
Picking another switches the session to that profile
(`POST /api/users/switch-profile`), gets the chat token for it
(`POST /api/chat/login-token`), and signs in as from Kloki GO's link:
to the account already here for that realm, or a new one,
without the browser.
Without a session, the page offers signing in through Kloki.

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

## Scheme

The app opens sign-in links under two schemes:
`kloki-chat://kloki-login?…`, the name to use from now on,
and `konvo://kloki-login?…`, the scheme of Konvo, the app this one replaced.
Both are registered in `android/app/src/main/AndroidManifest.xml`
and in `CFBundleURLSchemes` in `ios/Runner/Info.plist`,
and `KlokiLoginLink.klokiLoginSchemes` accepts both.

`konvo://` stays until nothing sends it any more:
Kloki GO versions that only know `konvo://`,
and Kloki web's `/api/chat-app-handoff`, which redirects to `konvo://`.
Order of the move:

1. This app registers both (done, 2026-11-13). Release it.
2. Kloki GO asks for `kloki-chat://` first and falls back to `konvo://`
   (a Kloki Chat older than step 1 knows only that), and declares both
   in its query lists. The web handoff switches to `kloki-chat://`.
3. **When releasing a new Kloki Chat, check whether `konvo://` can go:**
   only once every Kloki GO in use is past step 2,
   and no Kloki Chat older than step 1 is still around.
   Then drop it here (manifest, Info.plist, `klokiLoginSchemes`) and in Kloki GO.

## Tests

The flows above are covered in `test/widgets/login_test.dart`,
in the `KlokiSignInPage` and `KlokiLinkSignIn` groups
and the `Kloki sign-in` group under `LoginPage`;
the link and the request in `test/api/model/web_auth_test.dart`
and `test/api/route/kloki_test.dart`.
The server side is tested in the Kloki fork of Zulip
(`test_kloki_jwt_from_konvo_*` in `zerver/tests/test_auth_backends.py`).
