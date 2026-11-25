# Dev setup

## Flutter

The app uses the latest Flutter from Flutter's `main` channel,
not stable or beta.

1. Install Flutter
   (see the [installation guide](https://docs.flutter.dev/get-started/install)),
   for example as a git clone at `~/development/flutter`, on `PATH`.
2. `flutter channel main` and `flutter upgrade`.
3. `flutter doctor`, until Android and iOS are both fine.

`pubspec.yaml` sets the lowest Flutter and Dart versions the app accepts.
`tools/upgrade flutter-local` raises them to your local Flutter,
as a commit.


## Running the app

```bash
flutter run                        # picks a connected device or simulator
flutter run -d <device-id>         # see `flutter devices`
```

For iOS, CocoaPods must be installed.
If `pod install` complains that the specs repo is out of date,
run `pod install --repo-update` in `ios/`.
On Xcode 27 the simulators are in DeviceHub
(`open -a DeviceHub`, or `flutter emulators --launch apple_ios_simulator`).

There's no dev build and no environment switch:
the app signs in to whichever organization you pick.
For testing, use a dev organization,
`https://<slug>.chat.dev.kloki.app`,
with an account on the dev Kloki (`https://dev.kloki.app`).
To try the sign-in link from Kloki GO without the phone app,
see [kloki-login.md](kloki-login.md#from-kloki-go-without-typing).

Debug builds talk to the same servers as release builds,
so be careful what you send from a production organization.


## Tests

```bash
flutter analyze --no-pub           # types and lints
flutter test --no-pub              # all unit and widget tests (about a minute)
flutter test --no-pub test/foo/bar_test.dart --name 'baz'
tools/check                        # all suites, on files changed vs. main
```

`tools/check --help` lists the suites.
Besides the analyzer and the tests,
they check that generated files are up to date
(`build_runner`, `l10n`, `drift`, `pigeon`, `icons`).
`tools/check --fix <suite>` regenerates them.

Tests use `package:checks`, not `expect`;
see [.claude/rules/testing.md](../.claude/rules/testing.md).


## Conventions

* No `dart format`: follow the style of the code around you.
  VS Code's auto-format is off in the repo settings.
* API types live in `lib/api/model/` with `json_serializable`.
  After changing one, run `tools/check --fix build_runner`.
  All constructor parameters are `required`, even nullable ones.
  See [.claude/rules/api.md](../.claude/rules/api.md).
* Database schema changes need `tools/check --fix drift`.
* New UI strings go in `assets/l10n/app_en.arb`,
  with the Croatian text in `assets/l10n/app_hr.arb`;
  then `flutter gen-l10n`.
  The other languages come from upstream;
  for new strings they show the English.
* When adding or upgrading a dependency,
  update `ios/Podfile.lock` too (`cd ios && pod update <pod>`).
  `tools/upgrade` does that for a full upgrade.


## Android without Android Studio

On a Linux machine without Android Studio:

1. Install JDK 17: `sudo apt install openjdk-17-jdk`
2. Install the Android SDK command-line tools
   ([download](https://developer.android.com/studio#command-line-tools-only))
   under `~/Android/Sdk/cmdline-tools/latest`,
   and with `sdkmanager` the `platform-tools`,
   a `platforms;android-NN` and a `build-tools;NN.0.0`
   (whatever `flutter doctor` asks for).
3. `flutter config --android-sdk ~/Android/Sdk`
   and `flutter doctor --android-licenses`.
