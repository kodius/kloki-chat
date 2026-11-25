# Kloki Chat

Kloki Chat is the chat app of Kloki, for Android and iOS.
Every Kloki client company has its own chat organization,
at `https://<slug>.chat.kloki.app`,
and people sign in with their Kloki account.

The app is a fork of [zulip-flutter][], the official Zulip app,
built with Flutter.
The server is Kodius's fork of the Zulip server
(repo `kodius/zulip`), deployed from boro's `.kubernetes/zulip/`.
The chat is its own app, not a screen in Kloki GO:
Kloki GO opens it with a sign-in link.

It replaced Konvo, the earlier Kodius app,
a fork of the React Native zulip-mobile.

[zulip-flutter]: https://github.com/zulip/zulip-flutter


## Docs

* [Dev setup](docs/setup.md): running the app, tests, conventions
* [Signing in with Kloki](docs/kloki-login.md):
  the first screen, the Kloki GO link, switching companies
* [Push notifications](docs/push-notifications.md)
* [Releasing](docs/release.md): `scripts/deploy`, store apps, review notes
* [Release notes](release-notes/README.md): the stores' What's New text
* [Store screenshots](docs/store-screenshots.md)
* [Working with Claude Code](docs/howto/claude.md),
  and [on the web](docs/howto/claude-web.md)

Instructions for Claude, and the code conventions
in more detail, are in [.claude/](.claude/CLAUDE.md).


## Store apps

| | iOS | Android |
|---|---|---|
| Store name | Kloki Chat – Team Chat | Kloki Chat |
| ID | `com.kodius.klokichat` | `konvo.kodius.com` |

Android kept Konvo's Play listing,
so updating Konvo brings in Kloki Chat.
iOS is a new public app,
because Konvo's App Store app was a private Custom App.
See [docs/release.md](docs/release.md#store-apps).


## Upstream

The code still follows zulip-flutter's structure and conventions,
and many names in it (the `zulip` package, `ZulipBinding`, …)
are upstream's.
Many Kloki changes carry a `Kloki` comment,
where they would surprise someone who knows upstream.
Upstream's own docs are at [zulip-flutter][];
read them there when a question is about the shared code.


## License

Copyright (c) 2022 Kandra Labs, Inc., and contributors.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

The software includes some works released by third parties under other
free and open source licenses. Those works are redistributed under the
license terms under which the works were received.
