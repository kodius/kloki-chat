// Renders the app's real screens, filled with a made-up team,
// as PNGs for the app-store listings.
//
// Run with:
//   flutter test --no-pub --update-goldens tools/store_screenshots/store_screens_test.dart
// The images land in tools/store_screenshots/screens/.
// The marketing frames around them are in tools/store_screenshots/frames.html.

import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:zulip/api/model/model.dart';
import 'package:zulip/model/narrow.dart';
import 'package:zulip/model/store.dart';
import 'package:zulip/widgets/home.dart';
import 'package:zulip/widgets/icons.dart';
import 'package:zulip/widgets/login.dart';
import 'package:zulip/widgets/message_list.dart';

import '../../test/api/fake_api.dart';
import '../../test/example_data.dart' as eg;
import '../../test/model/binding.dart';
import '../../test/model/test_store.dart';
import '../../test/test_images.dart';
import '../../test/widgets/test_app.dart';

/// The phone the screens are drawn for: an iPhone 6.7" (1290 × 2796 px).
const _logicalSize = Size(430, 932);
const _pixelRatio = 3.0;
const _topInset = 59.0;
const _bottomInset = 34.0;

final _now = DateTime.now();
int _minutesAgo(int minutes) =>
  _now.subtract(Duration(minutes: minutes)).millisecondsSinceEpoch ~/ 1000;

final _me = eg.user(fullName: 'Maja Kovač', email: 'maja@nova.studio',
  avatarUrl: '/avatars/maja.png');
final _luka = eg.user(fullName: 'Luka Novak', avatarUrl: '/avatars/luka.png');
final _ivana = eg.user(fullName: 'Ivana Babić', avatarUrl: '/avatars/ivana.png');
final _marko = eg.user(fullName: 'Marko Jurić', avatarUrl: '/avatars/marko.png');
final _petra = eg.user(fullName: 'Petra Horvat', avatarUrl: '/avatars/petra.png');
final _tomislav = eg.user(fullName: 'Tomislav Marić', avatarUrl: '/avatars/tomislav.png');
final _ema = eg.user(fullName: 'Ema Knežević', avatarUrl: '/avatars/ema.png');
final _users = [_me, _luka, _ivana, _marko, _petra, _tomislav, _ema];

/// Avatar colors, as soft Kloki-friendly gradients.
const _avatarColors = {
  'maja': (Color(0xFF706ED8), Color(0xFF493DCC)),
  'luka': (Color(0xFF4FB3A9), Color(0xFF2E7D73)),
  'ivana': (Color(0xFFF29E6D), Color(0xFFD9645A)),
  'marko': (Color(0xFF5B9BF0), Color(0xFF3563C9)),
  'petra': (Color(0xFFE77FB3), Color(0xFFB64C8A)),
  'tomislav': (Color(0xFF8BC56A), Color(0xFF4E8F3A)),
  'ema': (Color(0xFFF4C152), Color(0xFFD9922B)),
};

final _account = eg.account(user: _me, realmName: 'Nova Studio',
  realmIcon: Uri.parse('/avatars/realm.png'));

ZulipStream _channel(String name) => eg.stream(name: name,
  canSendMessageGroup: eg.groupSetting(members: [for (final user in _users) user.userId]));

final _general = _channel('general');
final _design = _channel('design');
final _product = _channel('product');
final _marketing = _channel('marketing');
final _sales = _channel('sales');
final _support = _channel('support');
final _random = _channel('random');
final _channels = [_general, _design, _product, _marketing, _sales, _support, _random];

List<Subscription> get _subscriptions => [
  eg.subscription(_general, color: 0xFF706ED8, pinToTop: true),
  eg.subscription(_design, color: 0xFFE77FB3, pinToTop: true),
  eg.subscription(_product, color: 0xFF5B9BF0),
  eg.subscription(_marketing, color: 0xFFF29E6D),
  eg.subscription(_sales, color: 0xFF8BC56A),
  eg.subscription(_support, color: 0xFF4FB3A9),
  eg.subscription(_random, color: 0xFFF4C152),
];

String _p(String text) => '<p>$text</p>';

Reaction _reaction(String name, String code, User user) => Reaction(
  emojiName: name, emojiCode: code,
  reactionType: ReactionType.unicodeEmoji, userId: user.userId);

/// The conversation shown in the chat screen.
const _chatTopic = 'New onboarding flow';
List<Message> _chatMessages() => [
  eg.streamMessage(stream: _design, topic: _chatTopic, sender: _luka,
    timestamp: _minutesAgo(70), flags: [MessageFlag.read],
    content: _p('Kicking off the onboarding refresh. Goal: new teammates chatting in under a minute.')),
  eg.streamMessage(stream: _design, topic: _chatTopic, sender: _petra,
    timestamp: _minutesAgo(66), flags: [MessageFlag.read],
    content: _p('Love that goal. Data says most people drop off at the profile step.')),
  eg.streamMessage(stream: _design, topic: _chatTopic, sender: _ivana,
    timestamp: _minutesAgo(52), flags: [MessageFlag.read],
    content: _p('First pass of the new onboarding is up in Figma. '
      'Three screens instead of six, and the invite step moved to the end.')),
  eg.streamMessage(stream: _design, topic: _chatTopic, sender: _luka,
    timestamp: _minutesAgo(47), flags: [MessageFlag.read],
    content: _p('Love how much lighter it feels. '
      'Can we keep the progress dots? People liked knowing how far along they are.'),
    reactions: [_reaction('+1', '1f44d', _ivana), _reaction('+1', '1f44d', _marko)]),
  eg.streamMessage(stream: _design, topic: _chatTopic, sender: _ivana,
    timestamp: _minutesAgo(45), flags: [MessageFlag.read],
    content: _p('Good call, adding them back.')),
  eg.streamMessage(stream: _design, topic: _chatTopic, sender: _marko,
    timestamp: _minutesAgo(21), flags: [MessageFlag.read],
    content: _p('Engineering-wise this is a small change. '
      'We can ship it with Thursday\'s release.')),
  eg.streamMessage(stream: _design, topic: _chatTopic, sender: _me,
    timestamp: _minutesAgo(12), flags: [MessageFlag.read],
    content: _p('Perfect. I\'ll update the release notes and let support know.'),
    reactions: [_reaction('tada', '1f389', _luka), _reaction('tada', '1f389', _ivana),
      _reaction('heart', '2764', _petra)]),
  eg.streamMessage(stream: _design, topic: _chatTopic, sender: _petra,
    timestamp: _minutesAgo(3), flags: [MessageFlag.read],
    content: _p('Great work, team! Can\'t wait to see the numbers next week.')),
];

/// Unread messages, for the inbox and the DM list.
List<Message> _unreadMessages() => [
  for (final (minutes, text) in [(240, 'Quarterly planning is on Friday at 10.'),
                                 (95, 'Office is closed on Monday, enjoy the long weekend!')])
    eg.streamMessage(stream: _general, topic: 'Announcements', sender: _petra,
      timestamp: _minutesAgo(minutes), flags: [], content: _p(text)),
  for (final minutes in [30, 18, 9])
    eg.streamMessage(stream: _design, topic: _chatTopic, sender: _ivana,
      timestamp: _minutesAgo(minutes), flags: [], content: _p('Update')),
  eg.streamMessage(stream: _design, topic: 'Icon set', sender: _luka,
    timestamp: _minutesAgo(40), flags: [], content: _p('New icons are in.')),
  for (final minutes in [70, 66, 61, 15])
    eg.streamMessage(stream: _product, topic: 'Roadmap Q1', sender: _marko,
      timestamp: _minutesAgo(minutes), flags: [], content: _p('Roadmap')),
  eg.streamMessage(stream: _product, topic: 'Release 2.4', sender: _tomislav,
    timestamp: _minutesAgo(33), flags: [], content: _p('Release')),
  for (final minutes in [130, 25])
    eg.streamMessage(stream: _marketing, topic: 'Launch campaign', sender: _ema,
      timestamp: _minutesAgo(minutes), flags: [], content: _p('Campaign')),
  eg.dmMessage(from: _luka, to: [_me], timestamp: _minutesAgo(6), flags: [],
    content: _p('Got a minute to look at the mockups?')),
  eg.dmMessage(from: _ema, to: [_me], timestamp: _minutesAgo(14), flags: [],
    content: _p('Sent you the campaign brief.')),
  eg.dmMessage(from: _ema, to: [_me], timestamp: _minutesAgo(13), flags: [],
    content: _p('Let me know what you think!')),
];

/// Read DMs, so the DM list has a few more people.
List<Message> _readDms() => [
  eg.dmMessage(from: _me, to: [_ivana], timestamp: _minutesAgo(80),
    flags: [MessageFlag.read], content: _p('Thanks!')),
  eg.dmMessage(from: _marko, to: [_me, _tomislav], timestamp: _minutesAgo(150),
    flags: [MessageFlag.read], content: _p('Deploy went fine.')),
  eg.dmMessage(from: _petra, to: [_me], timestamp: _minutesAgo(300),
    flags: [MessageFlag.read], content: _p('See you tomorrow.')),
  eg.dmMessage(from: _me, to: [_tomislav], timestamp: _minutesAgo(1500),
    flags: [MessageFlag.read], content: _p('Sounds good.')),
];

Future<Uint8List> _drawAvatar(String initials, (Color, Color) colors, {double radius = 0}) async {
  const size = 256.0;
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  final rect = Offset.zero & const Size.square(size);
  canvas.drawRRect(RRect.fromRectAndRadius(rect, Radius.circular(radius)), Paint()
    ..shader = ui.Gradient.linear(Offset.zero, const Offset(size, size),
      [colors.$1, colors.$2]));
  final builder = ui.ParagraphBuilder(ui.ParagraphStyle(
      textAlign: TextAlign.center, fontFamily: 'Raleway', fontSize: 104))
    ..pushStyle(ui.TextStyle(color: const Color(0xFFFFFFFF),
      fontVariations: const [FontVariation('wght', 700)]))
    ..addText(initials);
  final paragraph = builder.build()..layout(const ui.ParagraphConstraints(width: size));
  canvas.drawParagraph(paragraph, Offset(0, (size - paragraph.height) / 2));
  final image = await recorder.endRecording().toImage(size.toInt(), size.toInt());
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  return bytes!.buffer.asUint8List();
}

class _ImagesHttpClient extends Fake implements HttpClient {
  _ImagesHttpClient(this.images);

  final Map<String, List<int>> images;

  @override
  Future<HttpClientRequest> getUrl(Uri url) async {
    final request = FakeImageHttpClientRequest();
    final name = images.keys.firstWhere((name) => url.path.contains('/$name'),
      orElse: () => images.keys.first);
    request.response
      ..statusCode = HttpStatus.ok
      ..content = images[name]!;
    return request;
  }
}

Future<void> _loadFont(String family, List<String> paths) async {
  final loader = FontLoader(family);
  for (final path in paths) {
    loader.addFont(path.startsWith('/')
      ? File(path).readAsBytes().then((bytes) => ByteData.sublistView(bytes))
      : rootBundle.load(path));
  }
  await loader.load();
}

void main() {
  TestZulipBinding.ensureInitialized();
  WidgetsApp.debugAllowBannerOverride = false;
  MessageListPage.debugEnableMarkReadOnScroll = false;

  final images = <String, List<int>>{};

  setUpAll(() async {
    await _loadFont('Source Sans 3', ['assets/Source_Sans_3/SourceSans3VF-Upright.otf',
      'assets/Source_Sans_3/SourceSans3VF-Italic.otf']);
    await _loadFont('Raleway', ['assets/Raleway/RalewayVF.ttf']);
    await _loadFont('Zulip Icons', ['assets/icons/ZulipIcons.ttf']);
    await _loadFont('Noto Color Emoji', ['assets/Noto_Color_Emoji/Noto-COLRv1.ttf']);
    final flutterRoot = Platform.environment['FLUTTER_ROOT']
      ?? '${Platform.environment['HOME']}/development/flutter';
    await _loadFont('MaterialIcons',
      ['$flutterRoot/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf']);

    for (final user in _users) {
      final key = user.avatarUrl!.split('/').last.split('.').first;
      final initials = user.fullName.split(' ').map((part) => part[0]).join();
      images[key] = await _drawAvatar(initials, _avatarColors[key]!);
    }
    images['realm'] = await _drawAvatar('N', (const Color(0xFF706ED8), const Color(0xFF493DCC)),
      radius: 56);
  });

  Future<void> setUpView(WidgetTester tester, Brightness brightness) async {
    tester.view.physicalSize = _logicalSize * _pixelRatio;
    tester.view.devicePixelRatio = _pixelRatio;
    const padding = FakeViewPadding(
      top: _topInset * _pixelRatio, bottom: _bottomInset * _pixelRatio);
    tester.view.padding = padding;
    tester.view.viewPadding = padding;
    tester.platformDispatcher.platformBrightnessTestValue = brightness;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
    debugNetworkImageHttpClientProvider = () => _ImagesHttpClient(images);
    addTearDown(() => debugNetworkImageHttpClientProvider = null);
  }

  Future<PerAccountStore> setUpStore({bool withUnreads = true}) async {
    addTearDown(testBinding.reset);
    await testBinding.globalStore.add(_account, eg.initialSnapshot(
      realmName: _account.realmName,
      realmIconUrl: _account.realmIcon,
      realmUsers: _users,
      presences: {
        for (final user in [_me, _luka, _ivana, _petra, _ema])
          user.userId: PerUserPresence(
            activeTimestamp: _minutesAgo(0), idleTimestamp: _minutesAgo(0)),
      }));
    final store = await testBinding.globalStore.perAccount(_account.id);
    await store.addStreams(_channels);
    await store.addSubscriptions(_subscriptions);
    await store.addMessages([if (withUnreads) ..._unreadMessages(), ..._readDms()]);
    return store;
  }

  /// Lets images decode and the entrance animations finish.
  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 4; i++) {
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 200)));
      await tester.pump(const Duration(milliseconds: 500));
    }
  }

  Future<void> capture(WidgetTester tester, String name) async {
    await expectLater(find.byType(TestZulipApp), matchesGoldenFile('screens/$name.png'));
  }

  Future<void> openTab(WidgetTester tester, IconData icon) async {
    await tester.tap(find.descendant(
      of: find.byType(HomePage), matching: find.byIcon(icon)).last);
    await settle(tester);
  }

  for (final brightness in Brightness.values) {
    final suffix = brightness.name;

    testWidgets('welcome $suffix', (tester) async {
      await setUpView(tester, brightness);
      addTearDown(testBinding.reset);
      await tester.pumpWidget(const TestZulipApp(child: KlokiSignInPage()));
      await settle(tester);
      await capture(tester, 'welcome_$suffix');
    });

    testWidgets('home tabs $suffix', (tester) async {
      await setUpView(tester, brightness);
      await setUpStore();
      await tester.pumpWidget(TestZulipApp(accountId: _account.id,
        child: const HomePage()));
      await settle(tester);
      await capture(tester, 'inbox_$suffix');

      await openTab(tester, ZulipIcons.hash_italic);
      await capture(tester, 'channels_$suffix');

      await openTab(tester, ZulipIcons.two_person);
      await capture(tester, 'dms_$suffix');

      await openTab(tester, ZulipIcons.menu);
      await capture(tester, 'menu_$suffix');
    });

    testWidgets('chat $suffix', (tester) async {
      await setUpView(tester, brightness);
      final store = await setUpStore(withUnreads: false);
      final connection = store.connection as FakeApiConnection;
      connection.prepare(json: eg.newestGetMessagesResult(
        foundOldest: true, messages: _chatMessages()).toJson());
      await tester.pumpWidget(TestZulipApp(accountId: _account.id,
        child: MessageListPage(
          initNarrow: TopicNarrow(_design.streamId, eg.t(_chatTopic)))));
      await settle(tester);
      await capture(tester, 'chat_$suffix');
    });
  }
}
