# Signing in with Kloki

Kloki Chat's chat runs on a Zulip server at
`https://kodius.chat.kloki.app` (see `kKlokiChatRealmUrl`
in `lib/widgets/kloki.dart`).
People don't have a chat password:
their accounts come from Kloki, and they sign in through it.

## The first screen

`KlokiSignInPage` (in `lib/widgets/login.dart`) offers:

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

## Tests

The flows above are covered in `test/widgets/login_test.dart`,
in the `KlokiSignInPage` group and the `Kloki sign-in` group under `LoginPage`.
