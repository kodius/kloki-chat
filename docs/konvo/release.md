# Releasing Kloki Chat

This is the Konvo release process for the App Store and Google Play.
For upstream Zulip's process, see [../release.md](../release.md).

## 1. Bump the version

In `pubspec.yaml`, bump the build number (after the `+`)
for every upload, and the version name when it's a new release:

```yaml
version: 28.1.0+104
```

Both stores reject a build number they've already seen.
Commit this as its own commit, `version: 28.1.0+104`.

## 2. Build

```bash
flutter build appbundle -Psigned   # Android
flutter build ipa                  # iOS
```

Don't pass `--no-pub` to the Android build.
Without `pub get`, a stale plugin registrant
may still list dev-only plugins, and the build fails.

`-Psigned` needs `android/release-keystore.properties`
and the keystore it points to.
Neither is in the repo; ask whoever does releases.

## 3. Upload

* **iOS**: open `build/ios/archive/Runner.xcarchive`
  (it opens in Xcode's Organizer)
  and choose *Distribute App → App Store Connect → Upload*.
  Or, from the command line, export it with
  `xcodebuild -exportArchive` and `destination` set to `upload`
  in the export-options plist.
  Apple takes 10 to 20 minutes to process the build.
* **Android**: upload
  `build/app/outputs/bundle/release/app-release.aab`
  in Play Console, on the release.

## 4. Store listing

* App Store Connect: on the version, attach the build,
  fill in *What's New*, and check the screenshots.
  See [store-screenshots.md](store-screenshots.md).
* Google Play: create the release on the *Production* track
  (or *Internal testing* first), with release notes for each language:

  ```
  <en-US>
  …
  </en-US>
  <hr>
  …
  </hr>
  ```

  Play Console sometimes drops one language's notes
  when the bundle in a release is swapped.
  Check both before saving.

## 5. Review notes

Both stores sign in with a review account.
Its sign-in steps are in App Store Connect's *App Review Information*
and in Play Console's *App content → Sign in details*.
Keep them matching what the app's first screen shows:
tap *Guest sign-in*, then log in with the email and password.
The organization is `https://kodius.chat.kloki.app/`.

## 6. Submit

* App Store Connect: *Add for Review*, then *Submit for Review*.
  Choose whether the release goes out on its own once approved,
  or waits for you to release it.
* Play Console: *Publishing overview → Send changes for review*.
  With managed publishing off, approved changes go live on their own.
