---
name: kloki-chat-release-notes
description: "Write the store What's New text for a Kloki Chat version into release-notes/<version>/ (all.md + hr.md), from the commits since the last release. Use after building with scripts/deploy, before Submit, or when the user asks for release notes, What's New, or 'napiši release notes'."
argument-hint: "[version]"
---

# Kloki Chat release notes

The format and the rules are in `release-notes/README.md`. Read it first.
`scripts/deploy` → Submit reads the folder and ships the text exactly as written.

## 1. Version

Use the argument if one was given.
Otherwise take the `version:` from `pubspec.yaml`, without the `+build` part
(`28.1.7+115` → `28.1.7`).

If `release-notes/<version>/` already exists, show what's there
and ask whether to rewrite it or leave it alone.

## 2. What changed

Tags:
- `v28.1.6` marks a release that has been submitted,
- `v28.1.7-ios.114` and `v28.1.7-android.115` mark the builds.

The range runs from the previous release tag
(the newest `vX.Y.Z` tag with no suffix that is older than this version)
to the newest build tag of this version
(`git tag --list 'v<version>-*' --sort=-creatordate | head -1`),
or to `@` if there is no build tag.

```bash
git log --no-merges --format='%h %s' <prev-release-tag>..<end>
```

Read a commit's diff (`git show --stat <hash>`) when its subject doesn't make clear
what a user would notice.
Uncommitted changes in `git status` (for example `fastlane/Fastfile`, `pubspec.yaml`)
count too when they change something users see, such as the app name.

## 3. Pick what users notice

Keep: new features, visible UI changes, fixes users would notice (notifications, login, crashes),
renames.
Drop: version bumps, release notes, fastlane/CI/deploy tooling, refactors, tests,
upstream Zulip merges that change nothing users see, icon tweaks unless the icon looks clearly different.

If nothing users would notice is left, propose one line such as
"Bug fixes and performance improvements." / "Ispravci grešaka i poboljšanja performansi."

## 4. Write

`release-notes/<version>/all.md` (English, every listing that has no locale file of its own):

```
# 28.1.7

- One short sentence per change, written for users.
```

`release-notes/<version>/hr.md`: the same points in natural Croatian, same order.

Style (see `release-notes/28.1.6/` for an example):
- Plain words, no ticket numbers, no internal names (Konvo, Zulip, fork, fastlane).
- The app is called **Kloki Go Chat**.
- At most 4–5 points, most important first.
- **Under 500 characters per file** with the `#` line removed (the Play limit).
  Check: `sed '/^[[:space:]]*#/d' FILE | wc -m`

Add `ios.md` / `android.md` only when a change shipped on one platform only.

## 5. Report

Show both files and their character counts, and the commits that were left out with a short reason.
Don't commit. The user does that together with the version bump.
