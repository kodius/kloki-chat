import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' show ImageFilter;

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../api/core.dart';
import '../api/model/model.dart';
import '../generated/l10n/zulip_localizations.dart';
import '../model/narrow.dart';
import 'about_zulip.dart';
import 'actions.dart';
import 'app.dart';
import 'app_bar.dart';
import 'banner.dart';
import 'button.dart';
import 'color.dart';
import 'icons.dart';
import 'inbox.dart';
import 'message_list.dart';
import 'page.dart';
import 'profile.dart';
import 'recent_dm_conversations.dart';
import 'settings.dart';
import 'store.dart';
import 'subscription_list.dart';
import 'text.dart';
import 'theme.dart';
import 'counter_badge.dart';
import 'kloki.dart';
import 'kloki_organizations.dart';
import 'user.dart';

enum _HomePageTab {
  inbox,
  feed,
  channels,
  directMessages,
  menu,
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  static AccountRoute<void> buildRoute({required int accountId}) {
    return MaterialAccountWidgetRoute(accountId: accountId,
      loadingPlaceholderPage: _LoadingPlaceholderPage(accountId: accountId),
      page: const HomePage());
  }

  /// Navigate to [HomePage], ensuring that its route is at the root level.
  static void navigate(BuildContext context, {required int accountId}) {
    final navigator = Navigator.of(context);
    navigator.popUntil((route) => route.isFirst);
    unawaited(navigator.pushReplacement(
      HomePage.buildRoute(accountId: accountId)));
  }

  static String contentSemanticsIdentifier = 'home-page-content';
  static String titleSemanticsIdentifier = 'home-page-title';

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final _tab = ValueNotifier(_HomePageTab.inbox);

  @override
  void initState() {
    super.initState();
    _tab.addListener(_tabChanged);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  void _tabChanged() {
    setState(() {
      // The actual state lives in [_tab].
    });
  }

  /// The tabs whose content is scrolled on under the title.
  final _scrolledUnder = <_HomePageTab>{};

  bool _handleScroll(_HomePageTab tab, ScrollMetrics metrics) {
    if (metrics.axis != Axis.vertical) return false;
    // In a reversed list (as for messages) the content above is the extent after.
    final hidden = metrics.axisDirection == AxisDirection.up
      ? metrics.extentAfter : metrics.extentBefore;
    final scrolledUnder = hidden > 0;
    if (scrolledUnder != _scrolledUnder.contains(tab)) {
      setState(() {
        scrolledUnder ? _scrolledUnder.add(tab) : _scrolledUnder.remove(tab);
      });
    }
    return false;
  }

  String get _currentTabTitle {
    final zulipLocalizations = ZulipLocalizations.of(context);
    switch(_tab.value) {
      case _HomePageTab.inbox:
        return zulipLocalizations.inboxPageTitle;
      case _HomePageTab.feed:
        return zulipLocalizations.navBarFeedLabel;
      case _HomePageTab.channels:
        return zulipLocalizations.channelsPageTitle;
      case _HomePageTab.directMessages:
        return zulipLocalizations.recentDmConversationsPageTitle;
      case _HomePageTab.menu:
        return zulipLocalizations.navBarMenuLabel;
    }
  }

  List<Widget>? get _currentTabAppBarActions {
    switch(_tab.value) {
      case .inbox:
      case .feed:
        return [
          IconButton(
            icon: const Icon(ZulipIcons.search),
            tooltip: ZulipLocalizations.of(context).searchMessagesPageTitle,
            onPressed: () => Navigator.push(context,
              MessageListPage.buildRoute(context: context,
                narrow: KeywordSearchNarrow('')))),
        ];
      case .channels:
      case .directMessages:
      case .menu:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    const pageBodies = [
      (_HomePageTab.inbox,          InboxPageBody()),
      (_HomePageTab.feed,
        MessageListPage(initNarrow: CombinedFeedNarrow(), embedded: true)),
      (_HomePageTab.channels,       SubscriptionListPageBody()),
      // TODO(#1094): Users
      (_HomePageTab.directMessages, RecentDmConversationsPageBody()),
      (_HomePageTab.menu,           _MenuPageBody()),
    ];

    final designVariables = DesignVariables.of(context);
    // With the server-compat banner at the top, keep the plain layout.
    final frostedTitle = !_ServerCompatBanner.shows(context);
    return Scaffold(
      // Lists scroll on under the frosted title, as under the bottom nav.
      extendBodyBehindAppBar: frostedTitle,
      // A large Kloki page title, part of the page rather than a bar.
      appBar: ZulipAppBar(
        titleSpacing: 20,
        centerTitle: false,
        toolbarHeight: 76,
        backgroundColor: frostedTitle ? Colors.transparent : null,
        // With no bar color to go by, say which status-bar icons suit the page.
        systemOverlayStyle: Theme.of(context).brightness == Brightness.light
          ? SystemUiOverlayStyle.dark : SystemUiOverlayStyle.light,
        // Frosted only once something is under it: the blur would otherwise
        // pull the content just below it up into the bar.
        flexibleSpace: frostedTitle
          ? AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: !_scrolledUnder.contains(_tab.value)
                ? const SizedBox.expand()
                : ClipRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                      child: ColoredBox(
                        color: designVariables.mainBackground.withValues(alpha: 0.6),
                        // Fill the bar; the app bar lays this out loosely.
                        child: const SizedBox.expand()))))
          : null,
        title: Semantics(
          identifier: HomePage.titleSemanticsIdentifier,
          namesRoute: true,
          child: Text(_currentTabTitle,
            style: TextStyle(
              fontFamily: kKlokiHeadingFontFamily,
              fontSize: 28,
              height: 1.2,
              color: designVariables.title,
            ).merge(weightVariableTextStyle(context, wght: 800)))),
        actions: _currentTabAppBarActions),
      body: Column(
        children: [
          _ServerCompatBanner(),
          Expanded(
            child: Semantics(
              role: SemanticsRole.tabPanel,
              identifier: HomePage.contentSemanticsIdentifier,
              container: true,
              explicitChildNodes: true,
              child: Stack(
                children: [
                  for (final (tab, body) in pageBodies)
                    _TabBody(active: tab == _tab.value,
                      child: NotificationListener<ScrollMetricsNotification>(
                        onNotification: (n) => n.depth == 0 && _handleScroll(tab, n.metrics),
                        child: NotificationListener<ScrollUpdateNotification>(
                          onNotification: (n) => n.depth == 0 && _handleScroll(tab, n.metrics),
                          child: body))),
                ]))),
        ]),
      // The bar floats over the content, which scrolls on under it.
      extendBody: true,
      bottomNavigationBar: _BottomNavBar(tabNotifier: _tab));
  }
}

/// A home-page tab's body, kept alive while hidden,
/// which eases in (a fade and a short rise) when its tab is chosen,
/// its rows staggering in through a [KlokiEntrance].
class _TabBody extends StatefulWidget {
  const _TabBody({required this.active, required this.child});

  final bool active;
  final Widget child;

  @override
  State<_TabBody> createState() => _TabBodyState();
}

class _TabBodyState extends State<_TabBody> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this, duration: const Duration(milliseconds: 320));

  // The page itself eases in over the first part, its rows staggering alongside.
  late final _curve = CurvedAnimation(parent: _controller,
    curve: const Interval(0, 0.35, curve: Curves.easeOutCubic));

  void _enter() {
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.value = 1;
    } else {
      _controller.forward(from: 0);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.active && _controller.isDismissed) _enter();
  }

  @override
  void didUpdateWidget(covariant _TabBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active && !oldWidget.active) _enter();
  }

  @override
  void dispose() {
    _curve.dispose();
    _controller.dispose();
    super.dispose();
  }

  /// Whether this tab has been shown; until then its body isn't built,
  /// so e.g. the Feed tab doesn't fetch messages nobody has asked for.
  late bool _everShown = widget.active;

  @override
  Widget build(BuildContext context) {
    if (widget.active) _everShown = true;
    if (!_everShown) return const SizedBox.shrink();
    return Offstage(
      offstage: !widget.active,
      // Stop the hidden tab's animations; showing it again restarts them,
      // as for a page uncovered in the navigator.
      child: TickerMode(
        enabled: widget.active,
        child: KlokiEntrance(
        animation: _controller,
        child: FadeTransition(
          opacity: _curve,
          child: SlideTransition(
            position: _curve.drive(
              Tween(begin: const Offset(0, 0.015), end: Offset.zero)),
            child: widget.child)))));
  }
}

/// The Kloki bottom navigation: a floating, frosted capsule,
/// with a tinted pill that slides to the chosen tab.
class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar({required this.tabNotifier});

  final ValueNotifier<_HomePageTab> tabNotifier;

  _NavigationBarButton _button({
    required _HomePageTab tab,
    required IconData icon,
    required String label,
  }) {
    return _NavigationBarButton(icon: icon,
      label: label,
      selected: tabNotifier.value == tab,
      onPressed: () {
        tabNotifier.value = tab;
      });
  }

  @override
  Widget build(BuildContext context) {
    final designVariables = DesignVariables.of(context);
    final zulipLocalizations = ZulipLocalizations.of(context);

    // TODO(a11y): add tooltips for these buttons
    final navigationBarButtons = [
      _button(tab: _HomePageTab.inbox,
        icon: ZulipIcons.inbox,
        label: zulipLocalizations.inboxPageTitle),
      _button(tab: _HomePageTab.feed,
        icon: ZulipIcons.message_feed,
        label: zulipLocalizations.navBarFeedLabel),
      _button(tab: _HomePageTab.channels,
        icon: ZulipIcons.hash_italic,
        label: zulipLocalizations.channelsPageTitle),
      // TODO(#1094): Users
      _button(tab: _HomePageTab.directMessages,
        icon: ZulipIcons.two_person,
        label: zulipLocalizations.recentDmConversationsPageShortLabel),
      _NavigationBarButton(icon: ZulipIcons.menu,
        label: zulipLocalizations.navBarMenuLabel,
        selected: tabNotifier.value == _HomePageTab.menu,
        onPressed: () {
          tabNotifier.value = _HomePageTab.menu;
        }),
    ];

    final selectedIndex = switch (tabNotifier.value) {
      _HomePageTab.inbox => 0,
      _HomePageTab.feed => 1,
      _HomePageTab.channels => 2,
      _HomePageTab.directMessages => 3,
      _HomePageTab.menu => 4,
    };

    final bottomInset = MediaQuery.paddingOf(context).bottom;

    Widget result = Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, math.max(bottomInset, 12)),
      child: Center(
        heightFactor: 1,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              boxShadow: [BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 24, offset: const Offset(0, 8)),
              ]),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    // Frosted: what scrolls under shows through, softly.
                    color: designVariables.bgBotBar.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: designVariables.borderBar.withFadedAlpha(0.6))),
                  child: SizedBox(
                    height: 64,
                    child: Stack(children: [
                      // The pill slides from tab to tab.
                      AnimatedAlign(
                        duration: const Duration(milliseconds: 320),
                        curve: Curves.easeOutCubic,
                        alignment: Alignment(-1 + selectedIndex * 0.5, 0),
                        child: FractionallySizedBox(
                          widthFactor: 1 / navigationBarButtons.length,
                          child: Padding(
                            padding: const EdgeInsets.all(6),
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: designVariables.fabBg.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(22)),
                              child: const SizedBox(height: 52))))),
                      Row(children: [
                        for (final navigationBarButton in navigationBarButtons)
                          Expanded(child: navigationBarButton),
                      ]),
                    ])))))))));

    result = Semantics(
      container: true,
      explicitChildNodes: true,
      role: SemanticsRole.tabBar,
      child: result);

    return result;
  }
}

const kTryAnotherAccountWaitPeriod = Duration(seconds: 5);

class _LoadingPlaceholderPage extends StatefulWidget {
  const _LoadingPlaceholderPage({required this.accountId});

  /// The relevant account for this page.
  ///
  /// The account is not guaranteed to exist in the global store. This can
  /// happen briefly when the account is removed from the database for logout,
  /// but before [PerAccountStoreWidget.routeToRemoveOnLogout] is processed.
  final int accountId;

  @override
  State<_LoadingPlaceholderPage> createState() => _LoadingPlaceholderPageState();
}

class _LoadingPlaceholderPageState extends State<_LoadingPlaceholderPage> {
  Timer? tryAnotherAccountTimer;
  bool showTryAnotherAccount = false;

  @override
  void initState() {
    super.initState();
    tryAnotherAccountTimer = Timer(kTryAnotherAccountWaitPeriod, () {
      setState(() {
        showTryAnotherAccount = true;
      });
    });
  }

  @override
  void dispose() {
    tryAnotherAccountTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final zulipLocalizations = ZulipLocalizations.of(context);
    final account = GlobalStoreWidget.of(context).getAccount(widget.accountId);

    if (account == null) {
      // We should only reach this state very briefly.
      // See [_LoadingPlaceholderPage.accountId].
      return Scaffold(
        appBar: AppBar(),
        body: const SizedBox.shrink());
    }

    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const KlokiLoader(),
            Visibility(
              visible: showTryAnotherAccount,
              maintainSize: true,
              maintainAnimation: true,
              maintainState: true,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    Text(textAlign: TextAlign.center,
                      zulipLocalizations.tryAnotherAccountMessage(account.realmUrl.toString())),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () => Navigator.push(context,
                        MaterialWidgetRoute(page: const ChooseAccountPage())),
                      child: Text(zulipLocalizations.tryAnotherAccountButton)),
                  ]))),
          ])));
  }
}

class _NavigationBarButton extends StatelessWidget {
  const _NavigationBarButton({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final void Function() onPressed;

  @override
  Widget build(BuildContext context) {
    final designVariables = DesignVariables.of(context);
    final color = selected
      ? designVariables.fabBg
      : designVariables.foreground.withValues(alpha: 0.55);

    Widget result = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onPressed,
      child: AnimatedScaleOnPress(
        scaleEnd: 0.88,
        duration: const Duration(milliseconds: 100),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // The chosen tab's icon pops a little.
            AnimatedScale(
              scale: selected ? 1.08 : 1,
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeOutBack,
              child: Icon(icon, size: 22, color: color)),
            // Only the chosen tab says its name.
            AnimatedSize(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              child: selected
                ? Padding(
                    padding: const EdgeInsets.only(top: 3),
                    child: Text(label,
                      maxLines: 1,
                      overflow: TextOverflow.fade,
                      softWrap: false,
                      style: TextStyle(
                        fontFamily: kKlokiHeadingFontFamily,
                        fontSize: 11,
                        color: color,
                        height: 1,
                      ).merge(weightVariableTextStyle(context, wght: 700)),
                      textScaler: MediaQuery.textScalerOf(context).clamp(maxScaleFactor: 1.3)))
                : const SizedBox(width: double.infinity),
            ),
          ])));

    result = MergeSemantics(
      child: Semantics(
        role: SemanticsRole.tab,
        controlsNodes: {
          HomePage.contentSemanticsIdentifier,
          HomePage.titleSemanticsIdentifier,
        },
        selected: selected,
        onTap: onPressed,
        // Unchosen tabs show no name; give it to screen readers anyway.
        label: selected ? null : label,
        child: result));

    return result;
  }
}

/// The menu tab: the self-user up top, then cards of places and settings.
class _MenuPageBody extends StatelessWidget {
  const _MenuPageBody();

  @override
  Widget build(BuildContext context) {
    final store = PerAccountStoreWidget.of(context);
    final designVariables = DesignVariables.of(context);
    final padding = MediaQuery.paddingOf(context);
    final self = store.selfUser;

    final header = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => Navigator.push(context,
        ProfilePage.buildRoute(context: context, userId: store.selfUserId)),
      child: Column(children: [
        Avatar(userId: store.selfUserId, size: 88, borderRadius: 44),
        const SizedBox(height: 14),
        Text(store.userDisplayName(store.selfUserId),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: kKlokiHeadingFontFamily,
            fontSize: 22,
            color: designVariables.title,
          ).merge(weightVariableTextStyle(context, wght: 800))),
        const SizedBox(height: 4),
        Text(self.deliveryEmail ?? self.email,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 15, color: designVariables.loginOrDividerText)),
      ]));

    // Two quick beats: the user and the cards come in nearly together,
    // then the rows ripple in down through the cards.
    var rowIndex = 0;
    Widget row(MenuButton button) => KlokiStaggered.at(
      begin: 0.22 + 0.045 * rowIndex++,
      child: _MenuPageRow(button: button));

    return ListView(
      padding: EdgeInsets.fromLTRB(16, padding.top + 8, 16, padding.bottom + 24),
      children: [
        KlokiStaggered.at(begin: 0, child: header),
        const SizedBox(height: 24),
        KlokiStaggered.at(begin: 0.05, child: _MenuPageCard(children: [
          row(const _MyProfileButton()),
          row(const _SearchButton()),
          row(const _MentionsButton()),
          row(const _StarredMessagesButton()),
        ])),
        const SizedBox(height: 16),
        KlokiStaggered.at(begin: 0.1, child: _MenuPageCard(children: [
          row(const _SettingsButton()),
          row(const _KlokiOrganizationsButton()),
          row(const _SwitchAccountButton()),
          row(const _AboutZulipButton()),
        ])),
      ]);
  }
}

/// A rounded Kloki card of menu rows, as on the settings page.
class _MenuPageCard extends StatelessWidget {
  const _MenuPageCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final designVariables = DesignVariables.of(context);
    return DecoratedBox(
      decoration: klokiCardDecoration(designVariables),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Material(
          type: MaterialType.transparency,
          child: Column(children: children))));
  }
}

/// A row of the menu tab, showing a [MenuButton]'s icon, label and trailing.
class _MenuPageRow extends StatelessWidget {
  const _MenuPageRow({required this.button});

  final MenuButton button;

  @override
  Widget build(BuildContext context) {
    final designVariables = DesignVariables.of(context);
    final zulipLocalizations = ZulipLocalizations.of(context);
    final tone = designVariables.fabBg;
    final icon = button.icon;
    return InkWell(
      onTap: () => button.onPressed(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: tone.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10)),
            child: icon != null
              ? Icon(icon, size: 18, color: tone)
              : Center(child: button.buildLeading(context))),
          const SizedBox(width: 14),
          Expanded(child: Text(button.label(zulipLocalizations),
            maxLines: 1, overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 17, color: designVariables.title)
              .merge(weightVariableTextStyle(context, wght: 500)))),
          ?button.buildTrailing(context),
          const SizedBox(width: 6),
          Icon(ZulipIcons.chevron_right, size: 18,
            color: designVariables.loginOrDividerText),
        ])));
  }
}

/// Switch the chat between the person's companies in Kloki.
class _KlokiOrganizationsButton extends MenuButton {
  const _KlokiOrganizationsButton();

  @override
  IconData get icon => ZulipIcons.globe;

  @override
  String label(ZulipLocalizations zulipLocalizations) {
    return zulipLocalizations.klokiOrganizationsTitle;
  }

  @override
  Widget? buildTrailing(BuildContext context) {
    final store = PerAccountStoreWidget.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 140),
      child: Text(store.realmName,
        maxLines: 1, overflow: TextOverflow.ellipsis,
        style: TextStyle(fontSize: 15,
          color: DesignVariables.of(context).loginOrDividerText)));
  }

  @override
  void onPressed(BuildContext context) {
    Navigator.push(context, KlokiOrganizationsPage.buildRoute(context));
  }
}

class _SwitchAccountButton extends MenuButton {
  const _SwitchAccountButton();

  @override
  IconData get icon => ZulipIcons.arrow_left_right;

  @override
  String label(ZulipLocalizations zulipLocalizations) {
    return zulipLocalizations.switchAccountButtonTooltip;
  }

  @override
  void onPressed(BuildContext context) {
    Navigator.push(context,
      MaterialWidgetRoute(page: const ChooseAccountPage()));
  }
}

@visibleForTesting
abstract class MenuButton extends StatelessWidget {
  const MenuButton({super.key});

  String label(ZulipLocalizations zulipLocalizations);

  bool get selected => false;

  /// An icon to display before [label].
  ///
  /// Must be non-null unless [buildLeading] is overridden.
  IconData? get icon;

  static const _iconSize = 24.0;

  Widget buildLeading(BuildContext context) {
    assert(icon != null);
    final designVariables = DesignVariables.of(context);
    return Icon(icon, size: _iconSize,
      color: selected ? designVariables.iconSelected : designVariables.icon);
  }

  Widget? buildTrailing(BuildContext context) => null;

  void onPressed(BuildContext context);

  void _handlePress(BuildContext context) {
    // Dismiss the enclosing action sheet immediately,
    // for swift UI feedback that the user's selection was received.
    Navigator.of(context).pop();

    onPressed(context);
  }

  @override
  Widget build(BuildContext context) {
    final designVariables = DesignVariables.of(context);
    final zulipLocalizations = ZulipLocalizations.of(context);

    // Make [TextButton] set 44 instead of 48 for the height.
    final visualDensity = VisualDensity(vertical: -1);
    // A value that [TextButton] adds to some of its layout parameters;
    // we can cancel out those adjustments by subtracting it.
    final densityVerticalAdjustment = visualDensity.baseSizeAdjustment.dy;

    final buttonStyle = TextButton.styleFrom(
      // Make the button 44px instead of 48px tall, to match the Figma.
      visualDensity: visualDensity,
      padding: EdgeInsets.symmetric(
        vertical: 10 - densityVerticalAdjustment, horizontal: 8),
      foregroundColor: designVariables.labelMenuButton,
      // This has a default behavior of affecting the background color of the
      // button for states including "hovered", "focused" and "pressed".
      // Make this transparent so that we can have full control of these colors.
      overlayColor: Colors.transparent,
      splashFactory: NoSplash.splashFactory,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ).copyWith(
      backgroundColor: WidgetStateColor.fromMap({
        WidgetState.hovered: designVariables.bgMenuButtonActive.withFadedAlpha(0.5),
        WidgetState.focused: designVariables.bgMenuButtonActive,
        WidgetState.pressed: designVariables.bgMenuButtonActive,
        WidgetState.any:
          selected ? designVariables.bgMenuButtonSelected : Colors.transparent,
      }),
      foregroundColor: WidgetStatePropertyAll(
        selected ? designVariables.iconSelected : designVariables.labelMenuButton));

    final trailing = buildTrailing(context);

    return AnimatedScaleOnPress(
      duration: const Duration(milliseconds: 100),
      scaleEnd: 0.95,
      child: TextButton(
        onPressed: () => _handlePress(context),
        style: buttonStyle,
        child: Row(spacing: 8, children: [
          SizedBox.square(dimension: _iconSize,
            child: buildLeading(context)),
          Expanded(child: Text(label(zulipLocalizations),
            // TODO(design): determine if we prefer to wrap
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 18, height: 23 / 18)
              .merge(weightVariableTextStyle(context, wght: selected ? 600 : 400)))),
          ?trailing,
        ])));
  }
}

/// A menu button controlling the selected [_HomePageTab] on the bottom nav bar.
class _SearchButton extends MenuButton {
  const _SearchButton();

  @override
  IconData get icon => ZulipIcons.search;

  @override
  String label(ZulipLocalizations zulipLocalizations) {
    return zulipLocalizations.searchMessagesPageTitle;
  }

  @override
  void onPressed(BuildContext context) {
    Navigator.of(context).push(MessageListPage.buildRoute(
      context: context, narrow: KeywordSearchNarrow('')));
  }
}

class _MentionsButton extends MenuButton {
  const _MentionsButton();

  @override
  IconData get icon => ZulipIcons.at_sign;

  @override
  String label(ZulipLocalizations zulipLocalizations) {
    return zulipLocalizations.mentionsPageTitle;
  }

  @override
  Widget? buildTrailing(BuildContext context) {
    final store = PerAccountStoreWidget.of(context);
    final unreadCount = store.unreads.countInMentionsNarrow();
    if (unreadCount == 0) return null;
    return CounterBadge(
      kind: CounterBadgeKind.unread,
      style: CounterBadgeStyle.mainMenu,
      count: unreadCount,
      channelIdForBackground: null,
    );
  }

  @override
  void onPressed(BuildContext context) {
    Navigator.of(context).push(MessageListPage.buildRoute(
      context: context, narrow: const MentionsNarrow()));
  }
}

class _StarredMessagesButton extends MenuButton {
  const _StarredMessagesButton();

  @override
  IconData get icon => ZulipIcons.star;

  @override
  String label(ZulipLocalizations zulipLocalizations) {
    return zulipLocalizations.starredMessagesPageTitle;
  }

  @override
  Widget? buildTrailing(BuildContext context) {
    final store = PerAccountStoreWidget.of(context);
    if (!store.userSettings.starredMessageCounts) return null;
    return CounterBadge(
      kind: CounterBadgeKind.quantity,
      style: CounterBadgeStyle.mainMenu,
      count: store.starredMessages.length,
      channelIdForBackground: null,
    );
  }

  @override
  void onPressed(BuildContext context) {
    Navigator.of(context).push(MessageListPage.buildRoute(
      context: context, narrow: const StarredMessagesNarrow()));
  }
}

class _MyProfileButton extends MenuButton {
  const _MyProfileButton();

  @override
  IconData? get icon => null;

  @override
  Widget buildLeading(BuildContext context) {
    final store = PerAccountStoreWidget.of(context);
    return Avatar(
      userId: store.selfUserId,
      size: MenuButton._iconSize,
      borderRadius: 4,
      showPresence: false,
    );
  }

  @override
  String label(ZulipLocalizations zulipLocalizations) {
    return zulipLocalizations.mainMenuMyProfile;
  }

  @override
  void onPressed(BuildContext context) {
    final store = PerAccountStoreWidget.of(context);
    Navigator.of(context).push(
      ProfilePage.buildRoute(context: context, userId: store.selfUserId));
  }
}

class _SettingsButton extends MenuButton {
  const _SettingsButton();

  @override
  IconData get icon => ZulipIcons.settings;

  @override
  String label(ZulipLocalizations zulipLocalizations) {
    return zulipLocalizations.settingsPageTitle;
  }

  @override
  void onPressed(BuildContext context) {
    Navigator.of(context).push(SettingsPage.buildRoute(context: context));
  }
}

class _AboutZulipButton extends MenuButton {
  const _AboutZulipButton();

  @override
  IconData get icon => ZulipIcons.info;

  @override
  String label(ZulipLocalizations zulipLocalizations) {
    return zulipLocalizations.aboutPageTitle;
  }

  @override
  void onPressed(BuildContext context) {
    Navigator.of(context).push(AboutZulipPage.buildRoute(context));
  }
}

class _ServerCompatBanner extends StatelessWidget {
  const _ServerCompatBanner();

  /// Whether the banner shows.
  static bool shows(BuildContext context) {
    final globalStore = GlobalStoreWidget.of(context);
    final store = PerAccountStoreWidget.of(context);
    return store.zulipFeatureLevel < kMinSupportedZulipFeatureLevel
      && !globalStore.getServerCompatBannerDismissed(store.accountId);
  }

  @override
  Widget build(BuildContext context) {
    final globalStore = GlobalStoreWidget.of(context);
    final store = PerAccountStoreWidget.of(context);
    final zulipLocalizations = ZulipLocalizations.of(context);
    final showCompatBanner =
      store.zulipFeatureLevel < kMinSupportedZulipFeatureLevel
      && !globalStore.getServerCompatBannerDismissed(store.accountId);
    final isAtLeastAdmin = store.selfUser.role.isAtLeast(UserRole.administrator);
    final label = isAtLeastAdmin
      ? zulipLocalizations.serverCompatBannerAdminMessage(
          store.realmUrl.toString(), store.zulipVersion)
      : zulipLocalizations.serverCompatBannerUserMessage(
          store.realmUrl.toString(), store.zulipVersion);
    if (!showCompatBanner) return const SizedBox.shrink();
    return ZulipBanner(
      intent: .danger,
      label: label,
      actions: [
        ZulipWebUiKitButton(
          label: zulipLocalizations.serverCompatBannerLearnMoreLabel,
          size: .small,
          intent: .danger,
          attention: .low,
          onPressed: () => PlatformActions.launchUrl(context, kServerSupportDocUrl)),
        ZulipWebUiKitButton(
          label: zulipLocalizations.serverCompatBannerDismissLabel,
          size: .small,
          intent: .danger,
          attention: .medium,
          onPressed: () => globalStore
            .setServerCompatBannerDismissed(store.accountId)),
      ]);
  }
}
