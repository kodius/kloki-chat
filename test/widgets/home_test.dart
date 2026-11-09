import 'dart:ui';

import 'package:checks/checks.dart';
import 'package:flutter_checks/flutter_checks.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:zulip/api/core.dart';
import 'package:zulip/api/model/events.dart';
import 'package:zulip/api/model/model.dart';
import 'package:zulip/model/actions.dart';
import 'package:zulip/model/localizations.dart';
import 'package:zulip/model/narrow.dart';
import 'package:zulip/model/store.dart';
import 'package:zulip/widgets/about_zulip.dart';
import 'package:zulip/widgets/app.dart';
import 'package:zulip/widgets/app_bar.dart';
import 'package:zulip/widgets/banner.dart';
import 'package:zulip/widgets/home.dart';
import 'package:zulip/widgets/kloki_organizations.dart';
import 'package:zulip/widgets/icons.dart';
import 'package:zulip/widgets/inbox.dart';
import 'package:zulip/widgets/kloki.dart';
import 'package:zulip/widgets/message_list.dart';
import 'package:zulip/widgets/page.dart';
import 'package:zulip/widgets/profile.dart';
import 'package:zulip/widgets/subscription_list.dart';

import '../api/fake_api.dart';
import '../example_data.dart' as eg;
import '../flutter_checks.dart';
import '../model/binding.dart';
import '../model/store_checks.dart';
import '../model/test_store.dart';
import '../stdlib_checks.dart';
import '../test_images.dart';
import '../test_navigation.dart';
import 'checks.dart';
import 'test_app.dart';

void main () {
  TestZulipBinding.ensureInitialized();

  late PerAccountStore store;
  late FakeApiConnection connection;

  late Route<dynamic>? topRoute;
  late List<Route<dynamic>> pushedRoutes;
  late Route<dynamic>? lastPoppedRoute;

  final testNavObserver = TestNavigatorObserver()
    ..onChangedTop = ((current, previous) {
        topRoute = current;
      })
    ..onPushed = ((route, prevRoute) => pushedRoutes.add(route))
    ..onPopped = ((route, prevRoute) => lastPoppedRoute = route);

  setUp(() {
    topRoute = null;
    pushedRoutes = [];
    lastPoppedRoute = null;
  });

  Future<void> prepare(WidgetTester tester) async {
    addTearDown(testBinding.reset);
    await testBinding.globalStore.add(eg.selfAccount, eg.initialSnapshot());
    store = await testBinding.globalStore.perAccount(eg.selfAccount.id);
    connection = store.connection as FakeApiConnection;
    await store.addUser(eg.selfUser);

    await tester.pumpWidget(TestZulipApp(
      accountId: eg.selfAccount.id,
      navigatorObservers: [testNavObserver],
      child: const HomePage()));
    await tester.pump();
  }

  void checkOnLoadingPage() {
    check(find.byType(KlokiLoader).hitTestable()).findsOne();
    check(find.byType(ChooseAccountPage)).findsNothing();
    check(find.byType(HomePage)).findsNothing();
  }

  ModalRoute<void>? getRouteOf(WidgetTester tester, Finder finder) =>
    ModalRoute.of(tester.element(finder));

  void checkOnHomePage(WidgetTester tester, {required Account expectedAccount}) {
    check(find.byType(KlokiLoader)).findsNothing();
    check(find.byType(ChooseAccountPage)).findsNothing();
    check(find.byType(HomePage).hitTestable()).findsOne();
    check(getRouteOf(tester, find.byType(HomePage)))
      .isA<MaterialAccountWidgetRoute>().accountId.equals(expectedAccount.id);
  }

  group('bottom nav navigation', () {
    final findBottomNavSemantics = find.byWidgetPredicate((widget) {
      if (widget is! Semantics) return false;
      return widget.properties.role == SemanticsRole.tab;
    });

    // Finds a widget within the bottom navbar's semantics box subtree.
    Finder findInBottomNav(Finder finder) =>
      find.descendant(of: findBottomNavSemantics, matching: finder);

    testWidgets('channel stays collapsed when switching between bottom-nav tabs', (tester) async {
      // For simplicity, this test just checks the channel header as it appears
      // in the list; it doesn't also check the case where it's in the
      // sticky-header position (via [StickyHeaderItem]).
      // We arrange that by also preparing an unread DM, which
      // shifts the channel header down so it's not at the top of the viewport.

      await prepare(tester);
      await store.addUser(eg.otherUser);
      await store.addMessage(
        eg.dmMessage(from: eg.otherUser, to: [eg.selfUser]));
      final channel = eg.stream();
      await store.addStream(channel);
      await store.addSubscription(eg.subscription(channel));
      await store.addMessage(eg.streamMessage(stream: channel));
      await tester.pump();

      final findChevron = find.widgetWithIcon(
        InboxChannelHeaderItem, ZulipIcons.chevron_down);

      // Uncollapsed: no chevron visible.
      check(findChevron).findsNothing();

      // Collapsing the header updates inbox's internal state.
      await tester.tap(find.byType(InboxChannelHeaderItem));
      await tester.pump();
      check(findChevron).findsOne();

      // Switch to channels view.
      await tester.tap(find.byIcon(ZulipIcons.hash_italic));
      await tester.pump();
      check(findChevron).findsNothing();

      // The header should remain collapsed when we return to the inbox.
      await tester.tap(find.byIcon(ZulipIcons.inbox));
      await tester.pump();
      check(findChevron).findsOne();
    });

    testWidgets('update app bar title and actions when switching between views', (tester) async {
      await prepare(tester);

      final findSearchButton = find.descendant(
        of: find.byType(ZulipAppBar),
        matching: find.byIcon(ZulipIcons.search));

      check(find.descendant(
        of: find.byType(ZulipAppBar),
        matching: find.text('Inbox'))).findsOne();
      check(findSearchButton).findsOne();

      await tester.tap(find.byIcon(ZulipIcons.hash_italic));
      await tester.pump();
      check(find.descendant(
        of: find.byType(ZulipAppBar),
        matching: find.text('Channels'))).findsOne();
      check(findSearchButton).findsNothing();

      await tester.tap(find.byIcon(ZulipIcons.two_person));
      await tester.pump();
      check(find.descendant(
        of: find.byType(ZulipAppBar),
        matching: find.text('Direct messages'))).findsOne();
      check(findSearchButton).findsNothing();
    });

    testWidgets('only the chosen tab shows its label', (tester) async {
      await prepare(tester);
      check(findInBottomNav(find.text('Inbox'))).findsOne();
      check(findInBottomNav(find.text('Channels'))).findsNothing();

      await tester.tap(findInBottomNav(find.byIcon(ZulipIcons.hash_italic)));
      await tester.pump();
      check(find.descendant(
        of: find.byType(ZulipAppBar),
        matching: find.text('Channels'))).findsOne();
      check(findInBottomNav(find.text('Channels'))).findsOne();
      check(findInBottomNav(find.text('Inbox'))).findsNothing();
    });

    testWidgets('unchosen tabs are named to screen readers', (tester) async {
      await prepare(tester);
      check(find.bySemanticsLabel('Channels')).findsOne();
      check(find.bySemanticsLabel('DMs')).findsOne();
    });

    testWidgets('combined feed is a tab', (tester) async {
      await prepare(tester);
      pushedRoutes.clear();

      connection.prepare(json: eg.newestGetMessagesResult(
        foundOldest: true, messages: []).toJson());
      await tester.tap(find.byIcon(ZulipIcons.message_feed));
      await tester.pump();
      check(pushedRoutes).isEmpty();
      check(find.descendant(
        of: find.byType(ZulipAppBar),
        matching: find.text('Feed'))).findsOne();
      check(tester.widget<MessageListPage>(find.byType(MessageListPage)))
        .initNarrow.equals(const CombinedFeedNarrow());
      await tester.pump(Duration.zero); // message-list fetch
    });

    testWidgets('combined feed not fetched until its tab is shown', (tester) async {
      await prepare(tester);
      check(find.byType(MessageListPage)).findsNothing();
      check(connection.takeRequests()).isEmpty();
    });
  });

  group('app bar frost', () {
    final findFrost = find.descendant(
      of: find.byType(ZulipAppBar),
      matching: find.byType(BackdropFilter));

    Future<void> prepareManyChannels(WidgetTester tester) async {
      await prepare(tester);
      for (var i = 0; i < 40; i++) {
        final channel = eg.stream(name: 'channel $i');
        await store.addStream(channel);
        await store.addSubscription(eg.subscription(channel));
      }
      await tester.tap(find.byIcon(ZulipIcons.hash_italic));
      await tester.pump();
    }

    Future<void> dragChannels(WidgetTester tester, double dy) async {
      await tester.drag(find.byType(SubscriptionListPageBody), Offset(0, dy));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250)); // cross-fade
    }

    testWidgets('no frost on first load', (tester) async {
      await prepareManyChannels(tester);
      check(findFrost).findsNothing();
    });

    testWidgets('frost while content is under the bar, and not after', (tester) async {
      await prepareManyChannels(tester);
      await dragChannels(tester, -300);
      check(findFrost).findsOne();

      await dragChannels(tester, 600);
      check(findFrost).findsNothing();
    });

    testWidgets('each tab keeps its own scroll state', (tester) async {
      await prepareManyChannels(tester);
      await dragChannels(tester, -300);
      check(findFrost).findsOne();

      await tester.tap(find.byIcon(ZulipIcons.two_person));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));
      check(findFrost).findsNothing();

      await tester.tap(find.byIcon(ZulipIcons.hash_italic));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));
      check(findFrost).findsOne();
    });

    testWidgets('status bar icons are dark in the light theme', (tester) async {
      await prepare(tester);
      final appBar = tester.widget<ZulipAppBar>(find.byType(ZulipAppBar));
      check(appBar.systemOverlayStyle).equals(SystemUiOverlayStyle.dark);
    });
  });

  group('menu tab', () {
    Future<void> openMenuTab(WidgetTester tester) async {
      // A phone-height screen, so the whole menu fits.
      tester.view.physicalSize = const Size(400, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.tap(find.byIcon(ZulipIcons.menu));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400)); // entrance
      check(find.descendant(
        of: find.byType(ZulipAppBar),
        matching: find.text('Menu'))).findsOne();
    }

    Future<void> tapRowAndAwaitPush(WidgetTester tester, Finder finder) async {
      await tester.tap(finder);
      await tester.pump();
      final route = pushedRoutes.last as TransitionRoute<dynamic>;
      await tester.pump(route.transitionDuration);
    }

    testWidgets('a tab, not a sheet', (tester) async {
      prepareBoringImageHttpClient();
      addTearDown(() => debugNetworkImageHttpClientProvider = null);
      await prepare(tester);
      pushedRoutes.clear();
      await openMenuTab(tester);
      check(pushedRoutes).isEmpty();
      check(find.byType(BottomSheet)).findsNothing();
      check(find.text(eg.selfUser.fullName)).findsAny();
    });

    testWidgets('switch account', (tester) async {
      prepareBoringImageHttpClient();
      addTearDown(() => debugNetworkImageHttpClientProvider = null);
      await prepare(tester);
      await openMenuTab(tester);
      await tapRowAndAwaitPush(tester, find.byIcon(ZulipIcons.arrow_left_right));
      check(find.byType(ChooseAccountPage)).findsOne();
    });

    testWidgets('organizations', (tester) async {
      prepareBoringImageHttpClient();
      addTearDown(() => debugNetworkImageHttpClientProvider = null);
      await prepare(tester);
      await openMenuTab(tester);
      check(find.text(eg.initialSnapshot().realmName)).findsAny();
      await tapRowAndAwaitPush(tester, find.byIcon(ZulipIcons.globe));
      check(find.byType(KlokiOrganizationsPage)).findsOne();
    });

    testWidgets('starred messages', (tester) async {
      prepareBoringImageHttpClient();
      addTearDown(() => debugNetworkImageHttpClientProvider = null);

      final findRow = find.ancestor(
        of: find.byIcon(ZulipIcons.star), matching: find.byType(InkWell));

      await prepare(tester);
      final message = eg.streamMessage();
      await store.addMessage(message);
      await store.handleEvent(UpdateMessageFlagsAddEvent(
        id: 1, flag: MessageFlag.starred, messages: [message.id], all: false));

      await openMenuTab(tester);
      check(find.descendant(of: findRow, matching: find.text('1'))).findsOne();

      connection.prepare(json: eg.newestGetMessagesResult(
        foundOldest: true,
        messages: [
          Message.fromJson((deepToJson(message) as Map<String, dynamic>)
                              ..['flags'] = ['starred'])
        ]).toJson());
      await tapRowAndAwaitPush(tester, findRow);
      check(find.text('Starred messages')).findsAny();
    });

    testWidgets('my profile', (tester) async {
      prepareBoringImageHttpClient();
      addTearDown(() => debugNetworkImageHttpClientProvider = null);
      await prepare(tester);
      await openMenuTab(tester);
      await tapRowAndAwaitPush(tester, find.text('My profile'));
      check(find.byType(ProfilePage)).findsOne();
    });

    testWidgets('about', (tester) async {
      prepareBoringImageHttpClient();
      addTearDown(() => debugNetworkImageHttpClientProvider = null);
      await prepare(tester);
      await openMenuTab(tester);
      await tapRowAndAwaitPush(tester, find.byIcon(ZulipIcons.info));
      check(find.byType(AboutZulipPage)).findsOne();
    });
  });

  group('_LoadingPlaceholderPage', () {
    const loadPerAccountDuration = Duration(seconds: 30);
    assert(loadPerAccountDuration > kTryAnotherAccountWaitPeriod);

    void checkOnChooseAccountPage() {
      // Ignore the possible loading page in the background.
      check(find.byType(KlokiLoader).hitTestable()).findsNothing();
      check(find.byType(ChooseAccountPage)).findsOne();
      check(find.byType(HomePage)).findsNothing();
    }

    Future<void> prepare(WidgetTester tester) async {
      addTearDown(testBinding.reset);
      topRoute = null;
        pushedRoutes = [];
      lastPoppedRoute = null;
      await testBinding.globalStore.add(eg.selfAccount, eg.initialSnapshot());
      await testBinding.globalStore.add(
        eg.otherAccount, eg.initialSnapshot(realmUsers: [eg.otherUser]),
        markLastVisited: false);
      await tester.pumpWidget(ZulipApp(navigatorObservers: [testNavObserver]));
      await tester.pump(Duration.zero); // wait for the loading page
      checkOnLoadingPage();
    }

    Future<void> tapTryAnotherAccount(WidgetTester tester) async {
      final numPushedRoutesBefore = pushedRoutes.length;
      await tester.tap(find.text('Try another account'));
      await tester.pump();
      final pushedRoute = pushedRoutes.skip(numPushedRoutesBefore).single;
      check(pushedRoute).isA<MaterialWidgetRoute>().page.isA<ChooseAccountPage>();
      await tester.pump((pushedRoute as TransitionRoute).transitionDuration);
      checkOnChooseAccountPage();
    }

    Future<void> chooseAccountWithEmail(WidgetTester tester, String email) async {
      lastPoppedRoute = null;
      await tester.tap(find.text(email));
      await tester.pump();
      check(topRoute).isA<MaterialAccountWidgetRoute>().page.isA<HomePage>();
      check(lastPoppedRoute).isA<MaterialWidgetRoute>().page.isA<ChooseAccountPage>();
      final popDuration = (lastPoppedRoute as TransitionRoute).reverseTransitionDuration;
      final pushDuration = (topRoute as TransitionRoute).transitionDuration;
      final animationDuration = popDuration > pushDuration ? popDuration : pushDuration;
      // TODO not sure why a 1ms fudge is needed; investigate.
      await tester.pump(animationDuration + Duration(milliseconds: 1));
      checkOnLoadingPage();
    }

    testWidgets('smoke', (tester) async {
      addTearDown(testBinding.reset);
      testBinding.globalStore.loadPerAccountDuration = loadPerAccountDuration;
      await prepare(tester);
      await tester.pump(loadPerAccountDuration);
      checkOnHomePage(tester, expectedAccount: eg.selfAccount);
    });

    testWidgets('"Try another account" button appears after timeout', (tester) async {
      addTearDown(testBinding.reset);
      testBinding.globalStore.loadPerAccountDuration = loadPerAccountDuration;
      await prepare(tester);
      checkOnLoadingPage();
      check(find.text('Try another account').hitTestable()).findsNothing();

      await tester.pump(kTryAnotherAccountWaitPeriod);
      checkOnLoadingPage();
      check(find.text('Try another account').hitTestable()).findsOne();

      await tester.pump(loadPerAccountDuration);
      checkOnHomePage(tester, expectedAccount: eg.selfAccount);
    });

    testWidgets('while loading, go back from ChooseAccountPage', (tester) async {
      testBinding.globalStore.loadPerAccountDuration = loadPerAccountDuration;
      await prepare(tester);
      await tester.pump(kTryAnotherAccountWaitPeriod);
      await tapTryAnotherAccount(tester);

      lastPoppedRoute = null;
      await tester.tap(find.byType(BackButton));
      await tester.pump();
      check(lastPoppedRoute).isA<MaterialWidgetRoute>().page.isA<ChooseAccountPage>();
      await tester.pump(
        (lastPoppedRoute as TransitionRoute).reverseTransitionDuration
        // TODO not sure why a 1ms fudge is needed; investigate.
        + Duration(milliseconds: 1));
      checkOnLoadingPage();

      await tester.pump(loadPerAccountDuration);
      checkOnHomePage(tester, expectedAccount: eg.selfAccount);
    });

    testWidgets('while loading, choose a different account', (tester) async {
      testBinding.globalStore.loadPerAccountDuration = loadPerAccountDuration;
      await prepare(tester);
      await tester.pump(kTryAnotherAccountWaitPeriod);
      await tapTryAnotherAccount(tester);

      testBinding.globalStore.loadPerAccountDuration = loadPerAccountDuration * 2;
      await chooseAccountWithEmail(tester, eg.otherAccount.email);

      await tester.pump(loadPerAccountDuration);
      // The second loadPerAccount is still pending.
      checkOnLoadingPage();

      await tester.pump(loadPerAccountDuration);
      // The second loadPerAccount finished.
      checkOnHomePage(tester, expectedAccount: eg.otherAccount);
    });

    testWidgets('while loading, choosing an account disallows going back', (tester) async {
      testBinding.globalStore.loadPerAccountDuration = loadPerAccountDuration;
      await prepare(tester);
      await tester.pump(kTryAnotherAccountWaitPeriod);
      await tapTryAnotherAccount(tester);

      // While still loading, choose a different account.
      await chooseAccountWithEmail(tester, eg.otherAccount.email);

      // User cannot go back because the navigator stack
      // was cleared after choosing an account.
      check(getRouteOf(tester, find.byType(KlokiLoader)))
        .isNotNull().isFirst.isTrue();

      await tester.pump(loadPerAccountDuration); // wait for loadPerAccount
      checkOnHomePage(tester, expectedAccount: eg.otherAccount);
    });

    testWidgets('while loading, go to nested levels of ChooseAccountPage', (tester) async {
      testBinding.globalStore.loadPerAccountDuration = loadPerAccountDuration;
      final thirdAccount = eg.account(user: eg.thirdUser);
      await testBinding.globalStore.add(thirdAccount, eg.initialSnapshot(
        realmUsers: [eg.thirdUser]));
      await prepare(tester);

      await tester.pump(kTryAnotherAccountWaitPeriod);
      // While still loading the first account, choose a different account.
      await tapTryAnotherAccount(tester);
      await chooseAccountWithEmail(tester, eg.otherAccount.email);
      // User cannot go back because the navigator stack
      // was cleared after choosing an account.
      check(getRouteOf(tester, find.byType(KlokiLoader)))
        .isA<MaterialAccountWidgetRoute>()
          ..isFirst.isTrue()
          ..accountId.equals(eg.otherAccount.id);

      await tester.pump(kTryAnotherAccountWaitPeriod);
      // While still loading the second account, choose a different account.
      await tapTryAnotherAccount(tester);
      await chooseAccountWithEmail(tester, thirdAccount.email);
      // User cannot go back because the navigator stack
      // was cleared after choosing an account.
      check(getRouteOf(tester, find.byType(KlokiLoader)))
        .isA<MaterialAccountWidgetRoute>()
          ..isFirst.isTrue()
          ..accountId.equals(thirdAccount.id);

      await tester.pump(loadPerAccountDuration); // wait for loadPerAccount
      checkOnHomePage(tester, expectedAccount: thirdAccount);
    });

    testWidgets('after finishing loading, go back from ChooseAccountPage', (tester) async {
      testBinding.globalStore.loadPerAccountDuration = loadPerAccountDuration;
      await prepare(tester);
      await tester.pump(kTryAnotherAccountWaitPeriod);
      await tapTryAnotherAccount(tester);

      // Stall while on ChoooseAccountPage so that the account finished loading.
      await tester.pump(loadPerAccountDuration);
      checkOnChooseAccountPage();

      lastPoppedRoute = null;
      await tester.tap(find.byType(BackButton));
      await tester.pump();
      check(lastPoppedRoute).isA<MaterialWidgetRoute>().page.isA<ChooseAccountPage>();
      await tester.pump(
        (lastPoppedRoute as TransitionRoute).reverseTransitionDuration
        // TODO not sure why a 1ms fudge is needed; investigate.
        + Duration(milliseconds: 1));
      checkOnHomePage(tester, expectedAccount: eg.selfAccount);
    });

    testWidgets('after finishing loading, choose the loaded account', (tester) async {
      testBinding.globalStore.loadPerAccountDuration = loadPerAccountDuration;
      await prepare(tester);
      await tester.pump(kTryAnotherAccountWaitPeriod);
      await tapTryAnotherAccount(tester);

      // Stall while on ChoooseAccountPage so that the account finished loading.
      await tester.pump(loadPerAccountDuration);
      checkOnChooseAccountPage();

      // Choosing the already loaded account should result in no loading page.
      lastPoppedRoute = null;
      await tester.tap(find.text(eg.selfAccount.email));
      await tester.pump();
      check(lastPoppedRoute).isA<MaterialWidgetRoute>().page.isA<ChooseAccountPage>();
      await tester.pump(
        (lastPoppedRoute as TransitionRoute).reverseTransitionDuration
        // TODO not sure why a 1ms fudge is needed; investigate.
        + Duration(milliseconds: 1));
      // No additional wait for loadPerAccount.
      checkOnHomePage(tester, expectedAccount: eg.selfAccount);
    });
  });

  testWidgets('logging out while still loading', (tester) async {
    // Regression test for: https://github.com/zulip/zulip-flutter/issues/1219
    addTearDown(testBinding.reset);
    await testBinding.globalStore.add(eg.selfAccount, eg.initialSnapshot());
    await tester.pumpWidget(const ZulipApp());
    await tester.pump(); // wait for the loading page
    checkOnLoadingPage();

    final future = logOutAccount(testBinding.globalStore, eg.selfAccount.id);
    await tester.pump(TestGlobalStore.removeAccountDuration);
    await future;
    // No error expected from briefly not having
    // access to the account being logged out.
    check(testBinding.globalStore).accountIds.isEmpty();
  });

  testWidgets('logging out after fully loaded', (tester) async {
    // Regression test for: https://github.com/zulip/zulip-flutter/issues/1219
    addTearDown(testBinding.reset);
    await testBinding.globalStore.add(eg.selfAccount, eg.initialSnapshot());
    await tester.pumpWidget(const ZulipApp());
    await tester.pump(); // wait for the loading page
    await tester.pump(); // wait for store
    checkOnHomePage(tester, expectedAccount: eg.selfAccount);

    final future = logOutAccount(testBinding.globalStore, eg.selfAccount.id);
    await tester.pump(TestGlobalStore.removeAccountDuration);
    await future;
    // No error expected from briefly not having
    // access to the account being logged out.
    check(testBinding.globalStore).accountIds.isEmpty();
  });

  // TODO end-to-end widget test that checks the error dialog when connecting
  //   to an ancient server:
  //     https://github.com/zulip/zulip-flutter/pull/1410#discussion_r1999991512

  group('server compatibility banner', () {
    Future<void> prepareBanner(WidgetTester tester, {
      int? zulipFeatureLevel,
      String? zulipVersion,
      User? selfUser,
      Account? selfAccount,
      Account? otherAccount,
    }) async {
      assert(selfAccount != null ||
        (zulipFeatureLevel != null && zulipVersion != null));
      addTearDown(testBinding.reset);
      selfUser ??= eg.selfUser;
      selfAccount ??= eg.account(
        user: selfUser,
        zulipFeatureLevel: zulipFeatureLevel,
        zulipVersion: zulipVersion);
      await testBinding.globalStore.add(
        selfAccount,
        eg.initialSnapshot(
          zulipFeatureLevel: selfAccount.zulipFeatureLevel,
          zulipVersion: selfAccount.zulipVersion,
          realmUsers: [selfUser]));

      if (otherAccount != null) {
        await testBinding.globalStore.add(
          otherAccount,
          eg.initialSnapshot(
            zulipFeatureLevel: otherAccount.zulipFeatureLevel,
            zulipVersion: otherAccount.zulipVersion,
            realmUsers: [eg.otherUser]),
          markLastVisited: false);
      }

      await tester.pumpWidget(ZulipApp(navigatorObservers: [testNavObserver]));
      await tester.pump(Duration.zero); // wait for the loading page
      await tester.pump(); // wait for store
    }

    Future<void> switchToAccount(WidgetTester tester, Account account) async {
      // Open the menu tab, then its switch-account row,
      // on a phone-height screen so the whole menu fits.
      tester.view.physicalSize = const Size(400, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.tap(find.byIcon(ZulipIcons.menu));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400)); // entrance
      await tester.ensureVisible(find.byIcon(ZulipIcons.arrow_left_right));
      await tester.pump();
      await tester.tap(find.byIcon(ZulipIcons.arrow_left_right));
      await tester.pump();
      await tester.pump((topRoute as TransitionRoute).transitionDuration);

      lastPoppedRoute = null;
      await tester.tap(find.text(account.email));
      await tester.pump();
      final popDuration = (lastPoppedRoute as TransitionRoute).reverseTransitionDuration;
      final pushDuration = (topRoute as TransitionRoute).transitionDuration;
      final animationDuration = popDuration > pushDuration ? popDuration : pushDuration;
      await tester.pump(animationDuration + Duration(milliseconds: 1));
    }

    final zulipLocalizations = GlobalLocalizations.zulipLocalizations;
    final sampleRealmUrl = eg.realmUrl.toString();
    final unsupportedFeatureLevel = kMinSupportedZulipFeatureLevel - 1;
    final unsupportedVersion = '3.0';

    testWidgets('not shown when server is at supported feature level', (tester) async {
      await prepareBanner(tester,
        zulipFeatureLevel: kMinSupportedZulipFeatureLevel,
        zulipVersion: kMinSupportedZulipVersion);
      check(find.byType(ZulipBanner)).findsNothing();
    });

    testWidgets('shown for administrator when server is below supported feature level', (tester) async {
      await prepareBanner(tester,
        zulipFeatureLevel: unsupportedFeatureLevel,
        zulipVersion: unsupportedVersion,
        selfUser: eg.user(role: UserRole.administrator));
      check(find.text(zulipLocalizations.serverCompatBannerAdminMessage(
        sampleRealmUrl, unsupportedVersion))).findsOne();
    });

    testWidgets('shown for owner when server is below supported feature level', (tester) async {
      await prepareBanner(tester,
        zulipFeatureLevel: unsupportedFeatureLevel,
        zulipVersion: unsupportedVersion,
        selfUser: eg.user(role: UserRole.owner));
      check(find.text(zulipLocalizations.serverCompatBannerAdminMessage(
        sampleRealmUrl, unsupportedVersion))).findsOne();
    });

    testWidgets('shown for member when server is below supported feature level', (tester) async {
      await prepareBanner(tester,
        zulipFeatureLevel: unsupportedFeatureLevel,
        zulipVersion: unsupportedVersion);
      check(find.text(zulipLocalizations.serverCompatBannerUserMessage(
        sampleRealmUrl, unsupportedVersion))).findsOne();
    });

    testWidgets('banner has alert semantics role', (tester) async {
      final findBannerSemantics = find.byWidgetPredicate((widget) =>
        widget is Semantics && widget.properties.role == SemanticsRole.alert);
      await prepareBanner(tester,
        zulipFeatureLevel: unsupportedFeatureLevel,
        zulipVersion: unsupportedVersion);
      check(find.descendant(
        of: find.byType(ZulipBanner),
        matching: findBannerSemantics)
      ).findsOne();
    });

    testWidgets('banner dismiss state persists when switching account away and back', (tester) async {
      prepareBoringImageHttpClient();

      final accountA = eg.selfAccount.copyWith(
        zulipFeatureLevel: unsupportedFeatureLevel,
        zulipVersion: unsupportedVersion);
      final accountB = eg.otherAccount.copyWith(
        zulipFeatureLevel: kMinSupportedZulipFeatureLevel,
        zulipVersion: kMinSupportedZulipVersion);

      await prepareBanner(tester,
        selfAccount: accountA,
        otherAccount: accountB);
      checkOnHomePage(tester, expectedAccount: accountA);
      check(find.byType(ZulipBanner)).findsOne();

      await switchToAccount(tester, accountB);
      checkOnHomePage(tester, expectedAccount: accountB);

      await switchToAccount(tester, accountA);
      checkOnHomePage(tester, expectedAccount: accountA);
      // Banner reappears after switching accounts.
      check(find.byType(ZulipBanner)).findsOne();

      await tester.tap(find.text(zulipLocalizations.serverCompatBannerDismissLabel));
      await tester.pump();
      check(find.byType(ZulipBanner)).findsNothing();

      await switchToAccount(tester, accountB);
      checkOnHomePage(tester, expectedAccount: accountB);

      await switchToAccount(tester, accountA);
      checkOnHomePage(tester, expectedAccount: accountA);
      // Dismissal persists after switching accounts.
      check(find.byType(ZulipBanner)).findsNothing();

      debugNetworkImageHttpClientProvider = null;
    });

    testWidgets('learn more opens kServerSupportDocUrl', (tester) async {
      await prepareBanner(tester,
        zulipFeatureLevel: unsupportedFeatureLevel,
        zulipVersion: unsupportedVersion);
      await tester.tap(find.text(zulipLocalizations.serverCompatBannerLearnMoreLabel));
      check(testBinding.takeLaunchUrlCalls()).single
        .equals((url: kServerSupportDocUrl, mode: LaunchMode.inAppBrowserView));
    });
  });
}
