# Release notes

One folder per version, named after it: `28.1.2/` for pubspec's
`version: 28.1.2+108`. Inside it, `all.md` is the What's New text **both stores**
print, in **every language their listings have**.

`scripts/deploy` → Submit reads the folder, and refuses to submit
without `all.md`, on either platform. Build never asks for it.

## The files in a version folder

```
release-notes/28.1.2/
  all.md          everything: both stores, every language
  en-US.md        REPLACES all.md for the English listing (en.md works too)
  hr.md           REPLACES all.md for the Croatian listing
  ios.md          ADDS its lines after all.md, iOS only
  ios.en-US.md    ADDS its lines after en-US.md, iOS only
  android.md      ADDS its lines after all.md, Android only
```

- A **locale** file replaces, because it is another language.
- A **platform** file adds. The shared text is written once,
  and a change only one platform got is one extra line in `ios.md` or `android.md`.

Each lane prints what every locale was built from,
for example `hr <- all.md + ios.md`, so check that line.
`fastlane ios locales` and `fastlane android locales`
print which languages each listing has.

## Writing it

The text ships exactly as written, so write it for users.
Heading lines (`# ...`) are stripped, everything else is verbatim.

Limits: **500 characters on Play**, 4000 on the App Store,
counted after the platform file is appended. Write `all.md` to the 500.
