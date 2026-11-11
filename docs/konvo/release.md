# Releasing Kloki Chat

This is the Kloki release process for the App Store and Google Play.
For upstream Zulip's process, see [../release.md](../release.md).

Everything goes through `scripts/deploy`, which wraps fastlane
(`fastlane/Fastfile`).
It asks what to do, which platform, and which version, then runs the lanes.


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
