import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:material_ui/material_ui.dart';

import '../api/model/web_auth.dart';
import '../generated/l10n/zulip_localizations.dart';
import '../log.dart';
import '../model/actions.dart';
import '../model/localizations.dart';
import '../model/store.dart';
import 'about_zulip.dart';
import 'dialog.dart';
import 'home.dart';
import 'kloki.dart';
import 'login.dart';
import 'page.dart';
import 'store.dart';
import 'text.dart';
import 'theme.dart';

class ZulipApp extends StatefulWidget {
  const ZulipApp({super.key, this.navigatorObservers});

  /// Whether the app's widget tree is ready.
  ///
  /// This begins as false.  It transitions to true when the
  /// [GlobalStore] has been loaded and the [MaterialApp] has been mounted,
  /// and then remains true.
  static ValueListenable<bool> get ready => _ready;
  static ValueNotifier<bool> _ready = ValueNotifier(false);

  /// The navigator for the whole app.
  ///
  /// This is always the [GlobalKey.currentState] of [navigatorKey].
  /// If [navigatorKey] is already mounted, this future completes immediately.
  /// Otherwise, it waits for [ready] to become true and then completes.
  static Future<NavigatorState> get navigator {
    final state = navigatorKey.currentState;
    if (state != null) return Future.value(state);

    assert(!ready.value);
    final completer = Completer<NavigatorState>();
    ready.addListener(() {
      assert(ready.value);
      completer.complete(navigatorKey.currentState!);
    });
    return completer.future;
  }

  /// A key for the navigator for the whole app.
  ///
  /// For code that exists entirely outside the widget tree and has no natural
  /// [BuildContext] of its own, this enables interacting with the app's
  /// navigation, by calling [GlobalKey.currentState] to get a [NavigatorState].
  ///
  /// During the app's early startup, this key will not yet be mounted.
  /// It will always be mounted before [ready] becomes true,
  /// and naturally before any widgets are mounted which are part of the
  /// app's main UI managed by the navigator.
  ///
  /// See also [navigator], to asynchronously wait for the navigator
  /// to be mounted.
  static final navigatorKey = GlobalKey<NavigatorState>();

  /// The [ScaffoldMessengerState] for the app.
  ///
  /// This is null during the app's early startup, while [ready] is still false.
  ///
  /// For code that exists entirely outside the widget tree and has no natural
  /// [BuildContext] of its own, this enables controlling snack bars.
  /// Where a relevant [BuildContext] does exist, prefer using that instead,
  /// with [ScaffoldMessenger.of].
  static ScaffoldMessengerState? get scaffoldMessenger {
    final context = navigatorKey.currentContext;
    if (context == null) return null;
    // Not maybeOf; we use MaterialApp, which provides ScaffoldMessenger,
    // so it's a bug if navigatorKey is mounted somewhere lacking that.
    return ScaffoldMessenger.of(context);
  }

  /// The app's stack of navigation routes.
  ///
  /// This is null when the navigator is not mounted,
  /// i.e. until [ready] becomes true.
  static NavigationStack? get navigationStack {
    final navigatorState = navigatorKey.currentState;
    if (navigatorState == null) return null;
    final appState = navigatorState.context
      .findAncestorStateOfType<_ZulipAppState>()!;
    return appState._navStackTracker;
  }

  /// Reset the state of [ZulipApp] statics, for testing.
  ///
  /// TODO refactor this better, perhaps unify with ZulipBinding
  @visibleForTesting
  static void debugReset() {
    _snackBarCount = 0;
    reportErrorToUserBriefly = defaultReportErrorToUserBriefly;
    reportErrorToUserModally = defaultReportErrorToUserModally;
    _ready.dispose();
    _ready = ValueNotifier(false);
  }

  /// A list to pass through to [MaterialApp.navigatorObservers].
  /// Useful in tests.
  final List<NavigatorObserver>? navigatorObservers;

  static int _snackBarCount = 0;

  /// The callback we normally use as [reportErrorToUserBriefly].
  static void _reportErrorToUserBriefly(String? message, {String? details}) {
    assert(_ready.value);

    if (message == null) {
      if (_snackBarCount == 0) return;
      assert(_snackBarCount > 0);
      // The [SnackBar] API only exposes ways to hide ether the current snack
      // bar or all of them.
      //
      // To reduce the possibility of hiding snack bars not created by this
      // helper, only clear when there are known active snack bars.
      scaffoldMessenger!.clearSnackBars();
      return;
    }

    final zulipLocalizations = ZulipLocalizations.of(navigatorKey.currentContext!);
    final newSnackBar = scaffoldMessenger!.showSnackBar(
      snackBarAnimationStyle: AnimationStyle(
        duration: const Duration(milliseconds: 200),
        reverseDuration: const Duration(milliseconds: 50)),
      SnackBar(
        content: Text(message),
        action: (details == null) ? null : SnackBarAction(
          label: zulipLocalizations.snackBarDetails,
          onPressed: () => showErrorDialog(context: navigatorKey.currentContext!,
            title: zulipLocalizations.errorDialogTitle,
            message: details))));

    _snackBarCount++;
    newSnackBar.closed.whenComplete(() => _snackBarCount--);
  }

  /// The callback we normally use as [reportErrorToUserModally].
  static void _reportErrorToUserModally(
    String title, {
    String? message,
    Uri? learnMoreButtonUrl,
  }) {
    assert(_ready.value);

    showErrorDialog(
      context: navigatorKey.currentContext!,
      title: title,
      message: message,
      learnMoreButtonUrl: learnMoreButtonUrl);
  }

  void _declareReady() {
    assert(navigatorKey.currentContext != null);
    _ready.value = true;
    reportErrorToUserBriefly = _reportErrorToUserBriefly;
    reportErrorToUserModally = _reportErrorToUserModally;
  }

  @override
  State<ZulipApp> createState() => _ZulipAppState();
}

class _ZulipAppState extends State<ZulipApp> with WidgetsBindingObserver {
  final _navStackTracker = _TrackNavigationStack();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  List<Route<dynamic>> _handleGenerateInitialRoutes(String initialRoute) {
    // We ignore any notification at this step, and handle any initial
    // notification by a navigation after the first frame.
    // See `NotificationOpenService.start`, and the buffering in
    // NotificationTapEventListener.kt (on Android) and
    // NotificationTapEventListener.swift (on iOS),
    // for events that arrive before `onListen` is called.
    //
    // That navigation causes a small visible glitch, where one loading
    // spinner gets replaced by another; and when the notification is for
    // an account other than the last-visited one, a brief flash of the
    // latter's home page.
    // See recordings for Android (the behavior is similar on iOS):
    //   https://github.com/zulip/zulip-flutter/pull/2043#discussion_r2794138972
    //
    // TODO avoid the glitch by controlling the initial route.
    //   On Android, this may become possible when this upstream issue is fixed:
    //     https://github.com/flutter/flutter/issues/178305
    //   Or on both platforms, we could instead have the native side flag whether
    //   a tap event came from the app's launch, and await the first such event
    //   (or a report that none is coming) via `GlobalStoreWidget.blockingFuture`
    //   before generating the initial routes.

    // The `_ZulipAppState.context` lacks the required ancestors. Instead
    // we use the Navigator which should be available when this callback is
    // called and its context should have the required ancestors.
    final context = ZulipApp.navigatorKey.currentContext!;

    final globalStore = GlobalStoreWidget.of(context);
    final lastVisitedAccountId = globalStore.lastVisitedAccount?.id;

    // On Android, a link that launches the app comes as the initial route
    // (on iOS, through [didPushRouteInformation]).
    final initialUrl = Uri.tryParse(initialRoute);
    if (initialUrl != null && KlokiLoginLink.isKlokiLoginUrl(initialUrl)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        unawaited(KlokiLinkSignIn.handleUrl(initialUrl));
      });
    }

    return [
      if (lastVisitedAccountId == null)
        // There are no accounts, or the last-visited account was logged out.
        MaterialWidgetRoute(page: const ChooseAccountPage())
      else
        HomePage.buildRoute(accountId: lastVisitedAccountId),
    ];
  }

  @override
  Future<bool> didPushRouteInformation(routeInformation) async {
    switch (routeInformation.uri) {
      case Uri(scheme: 'zulip', host: 'login') && var url:
        await LoginPage.handleWebAuthUrl(url);
        return true;
      case var url when KlokiLoginLink.isKlokiLoginUrl(url):
        await KlokiLinkSignIn.handleUrl(url);
        return true;
    }
    return super.didPushRouteInformation(routeInformation);
  }

  @override
  Widget build(BuildContext context) {
    return GlobalStoreWidget(
      child: Builder(builder: (context) {
        return MaterialApp(
          onGenerateTitle: (BuildContext context) {
            return ZulipLocalizations.of(context).zulipAppTitle;
          },
          // TODO(upstream): use ZulipLocalizations.localizationsDelegates
          //   once gen-l10n supports material_ui:
          //     https://github.com/flutter/flutter/issues/191072
          localizationsDelegates: const [
            ZulipLocalizations.delegate,
            ...GlobalMaterialLocalizations.delegates,
          ],
          supportedLocales: ZulipLocalizations.supportedLocales,
          // The context has to be taken from the [Builder] because
          // [zulipThemeData] requires access to [GlobalStoreWidget] in the tree.
          theme: zulipThemeData(context),

          navigatorKey: ZulipApp.navigatorKey,
          navigatorObservers: [
            if (widget.navigatorObservers != null)
              ...widget.navigatorObservers!,
            _PreventEmptyStack(),
            _navStackTracker,
            _UpdateLastVisitedAccount(GlobalStoreWidget.of(context)),
          ],
          builder: (BuildContext context, Widget? child) {
            if (!ZulipApp.ready.value) {
              SchedulerBinding.instance.addPostFrameCallback(
                (_) => widget._declareReady());
            }
            GlobalLocalizations.zulipLocalizations = ZulipLocalizations.of(context);
            return child!;
          },

          // We use onGenerateInitialRoutes for the real work of specifying the
          // initial nav state.  To do that we need [MaterialApp] to decide to
          // build a [Navigator]... which means specifying either `home`, `routes`,
          // `onGenerateRoute`, or `onUnknownRoute`.  Make it `onGenerateRoute`.
          // It never actually gets called, though: `onGenerateInitialRoutes`
          // handles startup, and then we always push whole routes with methods
          // like [Navigator.push], never mere names as with [Navigator.pushNamed].
          onGenerateRoute: (_) => null,

          onGenerateInitialRoutes: _handleGenerateInitialRoutes);
      }));
  }
}

/// A view of the app's navigation stack, plus convenient helpers to inspect it.
mixin NavigationStack {
  List<Route<dynamic>> get routes;

  /// The Zulip account ID being viewed topmost in the navigation, if any.
  ///
  /// Typically there should be only one account present in the nav stack
  /// at a time, in which case this is that one account's ID.
  int? get currentAccountId {
    for (final route in routes.reversed) {
      if (route case AccountPageRouteMixin(:final accountId)) {
        return accountId;
      }
    }
    return null;
  }

  /// The topmost page route on the stack, if any.
  ///
  /// In particular this excludes dialogs and modal bottom sheets.
  PageRoute<dynamic>? get currentPageRoute {
    for (final route in routes.reversed) {
      switch (route) {
        case PageRoute():
          return route;

        case PopupRoute():
          // This case includes dialogs and modal bottom sheets.
          continue;

        default:
          // TODO(log) All known concrete Route subclasses are either of
          //   PageRoute or PopupRoute.  If something else appears, we should
          //   decide how the callers of this method want to treat it.
          continue;
      }
    }
    return null;
  }
}

// TODO(upstream): why doesn't Navigator expose the list of routes itself?
class _TrackNavigationStack extends NavigatorObserver with NavigationStack {
  @override
  final List<Route<dynamic>> routes = [];

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    assert(identical(routes.lastOrNull, previousRoute));
    routes.add(route);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    assert(identical(routes.lastOrNull, route));
    routes.removeLast();
    assert(identical(routes.lastOrNull, previousRoute));
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    final index = routes.lastIndexOf(route);
    assert(index >= 0);
    routes.removeAt(index);
    assert((previousRoute == null && index == 0)
        || (previousRoute != null && routes[index - 1] == previousRoute));
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    assert(newRoute != null); // TODO(upstream) why doesn't signature say this?
    assert(oldRoute != null); // TODO(upstream) why doesn't signature say this?
    final index = routes.lastIndexOf(oldRoute!);
    assert(index >= 0);
    routes[index] = newRoute!;
  }

  // No didChangeTop; it summarizes changes that the observer was already
  // notified of through the other methods above.
}

/// Pushes a route whenever the observed navigator stack becomes empty.
class _PreventEmptyStack extends NavigatorObserver {
  void _pushRouteIfEmptyStack() async {
    final navigator = await ZulipApp.navigator;
    bool isEmptyStack = true;
    // TODO: find a better way to inspect the navigator stack
    navigator.popUntil((route) {
      isEmptyStack = false;
      return true; // never actually pops
    });
    if (isEmptyStack) {
      unawaited(navigator.push(
        MaterialWidgetRoute(page: const ChooseAccountPage())));
    }
  }

  @override
  void didRemove(Route<void> route, Route<void>? previousRoute) async {
    _pushRouteIfEmptyStack();
  }

  @override
  void didPop(Route<void> route, Route<void>? previousRoute) async {
    _pushRouteIfEmptyStack();
  }
}

class _UpdateLastVisitedAccount extends NavigatorObserver {
  _UpdateLastVisitedAccount(this.globalStore);

  final GlobalStore globalStore;

  @override
  void didChangeTop(Route<void> topRoute, _) {
    if (topRoute case AccountPageRouteMixin(:var accountId)) {
      globalStore.setLastVisitedAccount(accountId);
    }
  }
}

class ChooseAccountPage extends StatelessWidget {
  const ChooseAccountPage({super.key});

  Widget _buildAccountItem(
    BuildContext context, {
    required int accountId,
    required Account account,
  }) {
    final designVariables = DesignVariables.of(context);
    final zulipLocalizations = ZulipLocalizations.of(context);
    final materialLocalizations = MaterialLocalizations.of(context);
    final realmIcon = account.realmIcon;

    // A Kloki list row: the organization's icon, its name and the email.
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => HomePage.navigate(context, accountId: accountId),
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(4, 10, 0, 10),
          child: Row(children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox.square(dimension: 44,
                child: realmIcon == null
                  ? ColoredBox(color: designVariables.bgSearchInput,
                      child: const Center(child: KlokiMark(size: 24)))
                  : Image.network(account.realmUrl.resolveUri(realmIcon).toString(),
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => ColoredBox(
                        color: designVariables.bgSearchInput,
                        child: const Center(child: KlokiMark(size: 24)))))),
            const SizedBox(width: 14),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(account.realmName ?? account.realmUrl.host,
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: kKlokiHeadingFontFamily,
                    fontSize: 17,
                    color: designVariables.title,
                  ).merge(weightVariableTextStyle(context, wght: 700))),
                const SizedBox(height: 2),
                Text(account.email,
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 15,
                    color: designVariables.loginOrDividerText)),
              ])),
            MenuAnchor(
              menuChildren: [
                MenuItemButton(
                  onPressed: () async {
                    final dialog = showSuggestedActionDialog(context: context,
                      title: zulipLocalizations.logOutConfirmationDialogTitle,
                      message: zulipLocalizations.logOutConfirmationDialogMessage,
                      destructiveActionButton: true,
                      actionButtonText: zulipLocalizations.logOutConfirmationDialogConfirmButton);
                    if (await dialog.result == true) {
                      if (!context.mounted) return;
                      // TODO error handling if db write fails?
                      unawaited(logOutAccount(GlobalStoreWidget.of(context), accountId));
                    }
                  },
                  child: Text(zulipLocalizations.chooseAccountPageLogOutButton)),
              ],
              builder: (BuildContext context, MenuController controller, Widget? child) {
                return IconButton(
                  tooltip: materialLocalizations.showMenuTooltip, // "Show menu"
                  onPressed: () {
                    if (controller.isOpen) {
                      controller.close();
                    } else {
                      controller.open();
                    }
                  },
                  icon: Icon(Icons.adaptive.more, color: designVariables.loginOrDividerText));
              }),
          ]))));
  }

  @override
  Widget build(BuildContext context) {
    final zulipLocalizations = ZulipLocalizations.of(context);
    final designVariables = DesignVariables.of(context);
    assert(!PerAccountStoreWidget.debugExistsOf(context));
    final globalStore = GlobalStoreWidget.of(context);

    if (globalStore.accountEntries.isEmpty) {
      // With no accounts, there's nothing to choose; go straight to signing in.
      return const KlokiSignInPage();
    }

    return Scaffold(
      appBar: AppBar(
        actions: const [ChooseAccountPageOverflowButton()]),
      body: SafeArea(
        minimum: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              // A large Kloki page title, as on the home tabs.
              Text(zulipLocalizations.chooseAccountPageTitle,
                style: TextStyle(
                  fontFamily: kKlokiHeadingFontFamily,
                  fontSize: 28,
                  height: 1.2,
                  color: designVariables.title,
                ).merge(weightVariableTextStyle(context, wght: 800))),
              const SizedBox(height: 20),
              Expanded(child: ListView(children: [
                for (final (i, (:accountId, :account)) in globalStore.accountEntries.indexed)
                  KlokiEaseIn(delay: (i * 0.08).clamp(0, 0.5),
                    child: _buildAccountItem(context,
                      accountId: accountId, account: account)),
              ])),
              FilledButton.icon(
                onPressed: () => Navigator.push(context,
                  KlokiSignInPage.buildRoute()),
                icon: const Icon(Icons.add),
                label: Text(zulipLocalizations.chooseAccountButtonAddAnAccount)),
            ])))));
  }
}

class ChooseAccountPageOverflowButton extends StatelessWidget {
  const ChooseAccountPageOverflowButton({super.key});

  @override
  Widget build(BuildContext context) {
    final zulipLocalizations = ZulipLocalizations.of(context);
    final materialLocalizations = MaterialLocalizations.of(context);
    return MenuAnchor(
      menuChildren: [
        MenuItemButton(
          onPressed: () {
            Navigator.push(context, AboutZulipPage.buildRoute(context));
          },
          child: Text(zulipLocalizations.aboutPageTitle)),
      ],
      builder: (BuildContext context, MenuController controller, Widget? child) {
        return IconButton(
          tooltip: materialLocalizations.showMenuTooltip, // "Show menu"
          onPressed: () {
            if (controller.isOpen) {
              controller.close();
            } else {
              controller.open();
            }
          },
          icon: Icon(Icons.adaptive.more));
      });
  }
}
