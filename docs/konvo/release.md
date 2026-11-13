# Releasing Kloki Chat

This is the Kloki release process for the App Store and Google Play.
For upstream Zulip's process, see [../release.md](../release.md).

Everything goes through `scripts/deploy`, which wraps fastlane
(`fastlane/Fastfile`).
It asks what to do, which platform, and which version, then runs the lanes.


Before every release, check [kloki-login.md, "Scheme"](kloki-login.md#scheme):
the old `konvo://` sign-in scheme is waiting to be dropped.


## Build, test, Submit

There is one build, with no environments:
every build talks to the production Kloki servers.
"Internal" and "production" are the same binary,
handed to different people.

| | **Build** puts it on | **Submit** sends the same build to |
|---|---|---|
| iOS | TestFlight (internal testers) | App Store review |
| Android | Play **internal** track | Play **production** |

Nothing a Build uploads is public.
Submit promotes the exact build that was tested,
and it is the step that uploads the What's New text,
from `release-notes/<version>/`.
See [release-notes/README.md](../../release-notes/README.md).

Both stores release on their own once review approves the build.


## Store apps

| | iOS | Android |
|---|---|---|
| Store name | Kloki Chat – Team Chat | Kloki Chat |
| ID | `com.kodius.klokichat`, Apple ID 6833812526 | `konvo.kodius.com` |
| Account | Kodius d.o.o., team `N53842DU2C` | Kodius Play Console |

The two IDs differ: fastlane has `IOS_APP_ID` and `ANDROID_APP_ID`.
Android kept Konvo's Play listing.
iOS moved to a new public app in November 2026:
Konvo's App Store app (`konvo.kodius.com`) was a private Custom App,
which Apple does not make public.
The iOS app group is `group.com.kodius.klokichat`
(`ios/Flutter/Zulip.xcconfig`, `lib/model/store.dart`).

Kloki GO links to the App Store app by
`EXPO_PUBLIC_KONVO_APP_STORE_ID` in kloki-mobile.


## Push notifications

Both platforms receive notifications through FCM,
from the Firebase project `konvo-fb886`.
The app reads its Firebase configuration from `lib/firebase_options.dart`,
not from `google-services.json` or `GoogleService-Info.plist`.
Each platform has its own app in that project,
registered under the store ID above.

For iOS, FCM delivers through APNs
with the team's APNs auth key `Q22MAG94D6`
(team-scoped, sandbox and production),
uploaded in Firebase → Project settings → Cloud Messaging
→ the iOS app → APNs Authentication Key,
in both the Development and Production rows.
The key file is private; it is not in the repo.

The server needs nothing per app:
it sends iOS FCM tokens through FCM whatever their app ID
(kodius/zulip `zerver/lib/kloki_push.py`).


### Moving iOS to the new app: remaining steps

Done: bundle ID, app group, fastlane;
the Firebase iOS app for `com.kodius.klokichat`
(project renamed `kloki-chat`, still `konvo-fb886`),
whose App ID is in `kFirebaseOptionsIos`,
with the APNs key uploaded;
and the App Store ID in kloki-mobile.
Still to do, on the Mac:

1. `scripts/deploy` → iOS → Build.
   Automatic signing registers `com.kodius.klokichat.NotificationService`
   and the app group.
   The version waiting in App Store Connect is 28.1.6.
2. On a real iPhone, from TestFlight:
   the token in Settings is an FCM token (`…:APA91b…`), not hex,
   and a message from another account shows a notification.
3. Before the first Submit, App Review needs, for a public chat app:
   a demo account, reporting content and blocking users (guideline 1.2),
   and deleting the account in the app (5.1.1(v)).
   The review notes should say that it is a B2B app for many companies,
   the companion of Kloki GO.
4. Take `konvo.kodius.com` off sale once users have moved.

Then delete this subsection.


## One-time setup

1. `brew install fastlane`
2. Copy `fastlane/.env.example` to `fastlane/.env` and fill it in.
   The file says where each value comes from.
   The App Store Connect key and Play service account
   can be the same ones kloki-mobile uses.
   Keep the `.p8` and the JSON key outside the repo.
3. For Android, `android/release-keystore.properties`
   and the keystore it points to.
   Neither is in the repo; ask whoever does releases.
4. For iOS, be signed in to the Kodius team in Xcode,
   so automatic signing can create the distribution profiles.


## What a build does

- reads the last build number off the store, adds 1,
  and writes `version: <version>+<build>` to `pubspec.yaml`
- `flutter build ios --config-only` and fastlane's `build_app`,
  or `flutter build appbundle -Psigned`
- uploads the IPA to TestFlight, or the AAB to the internal track
- tags the commit it built from (`v28.1.2-ios.108`) and pushes the tag;
  Submit adds `v28.1.2` on that commit

Commit the `pubspec.yaml` the lane changed, as `version: 28.1.2+108`.

Apple takes 10 to 20 minutes to process an iOS build
before internal testers get it.


## Versions

`version` (before the `+`) is what the stores print.
The script offers the next one rather than asking you to type it,
and refuses anything below the current value.
The build number (after the `+`) is never typed.


## Review notes

Both stores sign in with a review account.
Its sign-in steps are in App Store Connect's *App Review Information*
and in Play Console's *App content → Sign in details*.
Keep them matching what the app's first screen shows:
tap *Guest sign-in*, then log in with the email and password.
The organization is `https://kodius.chat.kloki.app/`.

Screenshots and the rest of the listing are not touched by the lanes;
see [store-screenshots.md](store-screenshots.md).


## By hand

If fastlane can't be used:

```bash
flutter build appbundle -Psigned   # Android
flutter build ipa                  # iOS
```

Bump `version:` in `pubspec.yaml` first; both stores reject
a build number they've already seen.
Don't pass `--no-pub` to the Android build:
without `pub get`, a stale plugin registrant
may still list dev-only plugins, and the build fails.

Then upload `build/ios/archive/Runner.xcarchive` from Xcode's Organizer,
and `build/app/outputs/bundle/release/app-release.aab` in Play Console.
