# Store screenshots

The App Store and Google Play screenshots for Kloki Chat
are rendered from the app itself, with a made-up demo team,
so they never show anyone's real chat.

This happens in two steps:
first the app's screens are rendered as plain PNGs,
then those are framed with a device, a caption, and the Kloki background.

## 1. Render the app's screens

```bash
flutter test --no-pub --update-goldens tools/store_screenshots/store_screens_test.dart
```

This writes `tools/store_screenshots/screens/*.png`
(gitignored), for each screen in light and dark,
at iPhone size and with an `ipad_` prefix at iPad size.

The demo team, its channels, and its messages
are set up in `store_screens_test.dart`.
Edit them there; nothing comes from a real server.

## 2. Frame them

Open `tools/store_screenshots/frames.html` in a browser
to preview every frame, per platform and language.

To capture one frame at its exact store size,
load the page with query parameters and take a headless screenshot:

```bash
CHROME="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
cd tools/store_screenshots
"$CHROME" --headless=new --allow-file-access-from-files \
  --force-device-scale-factor=1 --hide-scrollbars \
  --window-size=1206,2622 --virtual-time-budget=3000 \
  --screenshot="$PWD/out/ios/en/01.png" \
  "file://$PWD/frames.html?frame=0&platform=ios&lang=en"
```

| `platform` | Size        | Used for                               |
|------------|-------------|----------------------------------------|
| `ios`      | 1206 × 2622 | App Store, iPhone 6.3″ (the main slot) |
| `ipad`     | 2064 × 2752 | App Store, iPad 13″                    |
| `play`     | 1080 × 1920 | Google Play, phone                     |
| `tablet`   | 1440 × 2560 | Google Play, 7″ and 10″ tablet         |

`frame` is 0 to 5, or `feature` for the
1024 × 500 Google Play feature graphic.
`lang` is `en` or `hr`.

Output goes to `tools/store_screenshots/out/` (gitignored).

## Uploading

* **App Store Connect**: drag the files into each screenshot slot,
  per language. Files land in the order they're dropped.
* **Google Play**: uploads of several files at once
  arrive in random order.
  Upload them one at a time,
  or add them from the asset library in the order you want.
  Google Play wants 9:16 for tablets too,
  which is why tablets use their own `tablet` size
  rather than the iPad frames.
