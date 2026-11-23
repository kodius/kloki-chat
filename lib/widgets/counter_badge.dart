import 'package:flutter/widgets.dart';

import 'text.dart';
import 'theme.dart';

/// A widget to display a given number (e.g. of unread messages or of users).
///
/// See Figma's "counter-menu" component, which this is based on:
///   https://www.figma.com/design/1JTNtYo9memgW7vV6d0ygq/Zulip-Mobile?node-id=2037-186671&m=dev
/// It looks like that component was created for the main menu,
/// then adapted for various other contexts, like the Inbox page.
/// See [CounterBadgeStyle] and [CounterBadgeKind] for the possible variants.
class CounterBadge extends StatelessWidget {
  const CounterBadge({
    super.key,
    this.style = CounterBadgeStyle.other,
    required this.kind,
    required this.count,
    required this.channelIdForBackground,
  }) :
       // The API is awkward for callers who want [CounterBadgeKind.quantity] --
       // they're required to pass null for an irrelevant param --
       //   https://github.com/zulip/zulip-flutter/pull/1999#discussion_r2663221201
       // But [channelIdForBackground] has a TODO for being removed,
       // and that'll resolve the awkwardness.
       assert(!(kind == CounterBadgeKind.quantity && channelIdForBackground != null));

  final CounterBadgeStyle style;
  final CounterBadgeKind kind;
  final int count;

  /// The [Subscription.streamId] when this counter is for one channel's unreads.
  ///
  /// Unused: Kloki's badge is the same whatever the channel.
  // TODO remove; the Figma doesn't use this anymore.
  final int? channelIdForBackground;

  @override
  Widget build(BuildContext context) {
    final designVariables = DesignVariables.of(context);

    switch (kind) {
      case CounterBadgeKind.unread:
        // Kloki's badge, as on the web chat: a primary pill, 12px text,
        // whatever the channel (zulip:web/styles/kloki_inbox.css).
        return Container(
          constraints: const BoxConstraints(minWidth: 20),
          height: 20,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: designVariables.bgCounterUnread),
          child: Text(
            style: TextStyle(
              fontSize: 12,
              height: (20 / 12),
              color: designVariables.labelCounterUnread,
            ).merge(weightVariableTextStyle(context, wght: 500)),
            count.toString()));

      case CounterBadgeKind.quantity:
        final padding = switch (style) {
          CounterBadgeStyle.mainMenu =>
            const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
          CounterBadgeStyle.other =>
            const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
        };
        return Padding(
          padding: padding,
          child: Text(
            style: TextStyle(
              fontSize: 16,
              height: (16 / 16),
              color: designVariables.labelCounterQuantity,
            ).merge(weightVariableTextStyle(context, wght: 500)),
            count.toString()));
    }
  }
}

enum CounterBadgeStyle {
  /// The style to use in the main menu.
  ///
  /// Figma:
  ///   https://www.figma.com/design/1JTNtYo9memgW7vV6d0ygq/Zulip-Mobile?node-id=2037-185126&m=dev
  mainMenu,

  /// The style to use in other contexts besides the main menu.
  ///
  /// Other contexts include the "Channels" page and the topic-list page:
  ///   https://www.figma.com/design/1JTNtYo9memgW7vV6d0ygq/Zulip-Mobile?node-id=6205-26001&m=dev
  ///   https://www.figma.com/design/1JTNtYo9memgW7vV6d0ygq/Zulip-Mobile?node-id=6823-37113&m=dev
  /// (We use this for the topic-list page even though the Figma makes it a bit
  /// more compact there…the inconsistency seems worse and might be accidental.)
  other,
}

enum CounterBadgeKind {
  /// A counter specifically for unread messages.
  ///
  /// A pill background draws attention to the presence of unreads
  /// and distinguishes this kind of counter from any nearby [quantity] counters
  /// that do not track unread counts (e.g. a starred-messages counter).
  ///
  /// Figma:
  ///   Main-menu style: https://www.figma.com/design/1JTNtYo9memgW7vV6d0ygq/Zulip-Mobile?node-id=2037-185125&m=dev
  ///   Other style: https://www.figma.com/design/1JTNtYo9memgW7vV6d0ygq/Zulip-Mobile?node-id=6205-26001&m=dev
  unread,

  /// A generic counter for a quantity of something,
  /// such as starred messages or users.
  ///
  /// Figma:
  ///   Main-menu style: https://www.figma.com/design/1JTNtYo9memgW7vV6d0ygq/Zulip-Mobile?node-id=2037-186672&m=dev
  ///   Other style: https://www.figma.com/design/1JTNtYo9memgW7vV6d0ygq/Zulip-Mobile?node-id=6025-293468&m=dev
  quantity,
}

class MutedUnreadBadge extends StatelessWidget {
  const MutedUnreadBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final designVariables = DesignVariables.of(context);
    return Container(
      width: 8,
      height: 8,
      margin: const EdgeInsetsDirectional.only(end: 3),
      decoration: BoxDecoration(
        color: designVariables.mutedUnreadBadge,
        shape: BoxShape.circle));
  }
}
