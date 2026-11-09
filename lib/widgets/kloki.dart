import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../generated/l10n/zulip_localizations.dart';
import '../model/settings.dart';
import 'store.dart';
import 'theme.dart';

/// Kloki's sign-in for the chat, on the web.
///
/// Without a `realm` parameter it signs in to the realm
/// of the company active in Kloki,
/// and the `zulip://login` redirect says which realm that is.
final kKlokiChatSignInUrl = Uri.parse('https://kloki.app/app/auth/chat');

/// The [ExternalAuthenticationMethod.name] of the Kloki sign-in
/// on chat.kloki.app realms.
const kKlokiAuthMethodName = 'kloki';

/// The Kloki mark: a ring with a check.
///
/// Drawn from the same SVG as the mark on chat.kloki.app's sign-in page.
class KlokiMark extends StatelessWidget {
  const KlokiMark({super.key, this.size = 32});

  final double size;

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return Semantics(
      label: 'Kloki',
      image: true,
      child: CustomPaint(
        size: Size.square(size),
        painter: _KlokiMarkPainter(
          ring: isLight ? const Color(0xff493dcc) : const Color(0xff7b74db),
          check: isLight ? const Color(0xff252525) : const Color(0xfff7f7f7))));
  }
}

class _KlokiMarkPainter extends CustomPainter {
  _KlokiMarkPainter({required this.ring, required this.check});

  final Color ring;
  final Color check;

  static final _ring = Path()
    ..fillType = PathFillType.evenOdd
    ..moveTo(14.0689, 27.8042)
    ..cubicTo(6.49935, 27.8042, 0.331055, 21.6504, 0.331055, 14.0664)
    ..cubicTo(0.331055, 6.48246, 6.4849, 0.328613, 14.0689, 0.328613)
    ..cubicTo(21.6384, 0.328613, 27.8067, 6.48246, 27.8067, 14.0664)
    ..cubicTo(27.8067, 21.6504, 21.6384, 27.8042, 14.0689, 27.8042)
    ..close()
    ..moveTo(14.0689, 5.09568)
    ..cubicTo(9.11401, 5.09568, 5.08367, 9.12601, 5.08367, 14.0809)
    ..cubicTo(5.08367, 19.0357, 9.11401, 23.0661, 14.0689, 23.0661)
    ..cubicTo(19.0237, 23.0661, 23.0541, 19.0357, 23.0541, 14.0809)
    ..cubicTo(23.0541, 9.12601, 19.0237, 5.09568, 14.0689, 5.09568)
    ..close();

  static final _check = Path()
    ..moveTo(12.8408, 17.9091)
    ..cubicTo(12.4941, 17.9091, 12.133, 17.779, 11.873, 17.5046)
    ..lineTo(8.91161, 14.5577)
    ..cubicTo(8.37712, 14.0232, 8.37712, 13.1564, 8.91161, 12.622)
    ..cubicTo(9.4461, 12.0875, 10.3128, 12.0875, 10.8473, 12.622)
    ..lineTo(12.8408, 14.6154)
    ..lineTo(17.7812, 9.67504)
    ..cubicTo(18.3157, 9.14055, 19.1825, 9.14055, 19.717, 9.67504)
    ..cubicTo(20.2514, 10.2095, 20.2514, 11.0763, 19.717, 11.6108)
    ..lineTo(13.7942, 17.5335)
    ..cubicTo(13.5487, 17.779, 13.202, 17.9091, 12.8408, 17.9091)
    ..close();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 28, size.height / 28);
    canvas.drawPath(_ring, Paint()..color = ring);
    canvas.drawPath(_check, Paint()..color = check);
  }

  @override
  bool shouldRepaint(_KlokiMarkPainter oldDelegate) =>
    ring != oldDelegate.ring || check != oldDelegate.check;
}

/// The illustration of a Kloki empty state:
/// an icon in a tinted circle, over a module motif and a faint dotted grid.
///
/// Follows `EmptyStateMark` with the "generic" motif
/// in kloking-core apps/users/components/empty-state/,
/// at its "page" size.
class KlokiIllustration extends StatefulWidget {
  const KlokiIllustration({
    super.key,
    required this.icon,
    this.tone,
  });

  final IconData icon;

  /// The one color the circle, icon and motif are mixed from.
  ///
  /// Defaults to the Kloki primary color.
  final Color? tone;

  static const _width = 240.0;
  static const _height = 72.0;
  static const _circleSize = 72.0;

  /// Whether the shapes keep floating after the entrance.
  ///
  /// Tests turn this off, so that [WidgetTester.pumpAndSettle] can settle.
  @visibleForTesting
  static bool debugFloat = true;

  @override
  State<KlokiIllustration> createState() => _KlokiIllustrationState();
}

/// The illustration comes in quickly (the circle pops, the shapes fly out
/// from behind it, the dots light up), then the shapes float gently
/// for as long as it shows; its ticker stops when the page is hidden.
/// It comes in again each time the page shows again.
/// With reduced motion it just shows.
class _KlokiIllustrationState extends State<KlokiIllustration>
    with TickerProviderStateMixin, _ReplayWhenShown {
  late final AnimationController _entrance = AnimationController(
    vsync: this, duration: const Duration(milliseconds: 450));
  late final AnimationController _float = AnimationController(
    vsync: this, duration: const Duration(seconds: 4));

  @override
  void enter() {
    if (MediaQuery.disableAnimationsOf(context)) {
      _entrance.value = 1;
    } else {
      _entrance.forward(from: 0);
      if (KlokiIllustration.debugFloat && !_float.isAnimating) _float.repeat();
    }
  }

  @override
  void dispose() {
    _entrance.dispose();
    _float.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final designVariables = DesignVariables.of(context);
    final tone = widget.tone ?? designVariables.fabBg;
    final card = designVariables.bgTopBar;

    final pop = CurvedAnimation(parent: _entrance,
      curve: const Interval(0, 0.6, curve: Curves.easeOutBack));
    final popFade = CurvedAnimation(parent: _entrance,
      curve: const Interval(0, 0.3, curve: Curves.easeOut));
    final dotsFade = CurvedAnimation(parent: _entrance,
      curve: const Interval(0.2, 0.8, curve: Curves.easeOut));
    final iconIn = CurvedAnimation(parent: _entrance,
      curve: const Interval(0.25, 0.75, curve: Curves.easeOutBack));

    return ExcludeSemantics(
      child: SizedBox(
        width: KlokiIllustration._width,
        height: KlokiIllustration._height,
        child: Stack(clipBehavior: Clip.none, alignment: Alignment.center, children: [
          Positioned(left: -24, right: -24, top: -40, bottom: -40,
            child: FadeTransition(
              opacity: dotsFade,
              child: CustomPaint(painter: _DotsPainter(
                color: designVariables.foreground.withValues(alpha: 0.08))))),
          Positioned.fill(
            child: AnimatedBuilder(
              animation: Listenable.merge([_entrance, _float]),
              builder: (context, _) => CustomPaint(painter: _GenericMotifPainter(
                tone: tone, card: card,
                entrance: _entrance.value, float: _float.value)))),
          FadeTransition(
            opacity: popFade,
            child: ScaleTransition(
              scale: pop.drive(Tween(begin: 0.6, end: 1.0)),
              child: Container(
                width: KlokiIllustration._circleSize,
                height: KlokiIllustration._circleSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: card, width: 4),
                  boxShadow: [BoxShadow(color: tone.withValues(alpha: 0.12), spreadRadius: 1)],
                  gradient: RadialGradient(
                    center: const Alignment(-0.3, -0.4), // "circle at 35% 30%"
                    radius: 0.9,
                    colors: [
                      Color.lerp(card, tone, 0.07)!,
                      Color.lerp(card, tone, 0.20)!,
                    ])),
                child: ScaleTransition(
                  scale: iconIn,
                  child: Icon(widget.icon, size: 28, color: tone))))),
        ])));
  }
}

/// Calls [enter] when the widget first shows,
/// and again each time it shows after being hidden
/// (on another tab, or under another page),
/// as told by [TickerMode].
mixin _ReplayWhenShown<T extends StatefulWidget> on State<T> {
  bool? _wasShown;

  void enter();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final shown = TickerMode.valuesOf(context).enabled;
    if (shown && _wasShown != true) enter();
    _wasShown = shown;
  }
}

/// Eases [child] in (a fade and a short rise) as it shows,
/// after [delay] of the way through a 450ms entrance;
/// again each time it shows after being hidden.
class KlokiEaseIn extends StatefulWidget {
  const KlokiEaseIn({super.key, required this.delay, required this.child});

  final double delay;
  final Widget child;

  @override
  State<KlokiEaseIn> createState() => _KlokiEaseInState();
}

class _KlokiEaseInState extends State<KlokiEaseIn>
    with SingleTickerProviderStateMixin, _ReplayWhenShown {
  late final AnimationController _controller = AnimationController(
    vsync: this, duration: const Duration(milliseconds: 450));
  late final _curve = CurvedAnimation(parent: _controller,
    curve: Interval(widget.delay, 1, curve: Curves.easeOutCubic));

  @override
  void enter() {
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.value = 1;
    } else {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _curve.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _curve,
      child: SlideTransition(
        position: _curve.drive(
          Tween(begin: const Offset(0, 0.25), end: Offset.zero)),
        child: widget.child));
  }
}

/// A grid of dots every 12 px, fading out towards the edges.
class _DotsPainter extends CustomPainter {
  _DotsPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    const spacing = 12.0;
    final center = size.center(Offset.zero);
    final rx = size.width / 2;
    final ry = size.height / 2;
    final paint = Paint();
    for (double y = spacing / 2; y < size.height; y += spacing) {
      for (double x = spacing / 2; x < size.width; x += spacing) {
        final dx = (x - center.dx) / rx;
        final dy = (y - center.dy) / ry;
        final r = math.sqrt(dx * dx + dy * dy);
        // Fully visible inside 45% of the ellipse, gone at its edge.
        final fade = ((1 - r) / (1 - 0.45)).clamp(0.0, 1.0);
        if (fade == 0) continue;
        paint.color = color.withValues(alpha: color.a * fade);
        canvas.drawCircle(Offset(x, y), 1.5, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DotsPainter oldDelegate) => color != oldDelegate.color;
}

/// The "generic" motif: scattered rounded squares and bars,
/// drawn on a 240×72 box.
class _GenericMotifPainter extends CustomPainter {
  _GenericMotifPainter({
    required this.tone,
    required this.card,
    this.entrance = 1,
    this.float = 0,
  });

  final Color tone;
  final Color card;

  /// From 0 to 1 as the shapes fly out from behind the circle to their places.
  final double entrance;

  /// The phase of the shapes' gentle float, from 0 to 1.
  final double float;

  // x, y, width, height, radius, rotation in degrees, fill opacity
  static const _shapes = <(double, double, double, double, double, double, double)>[
    (60, 29, 14, 14, 3, 0, 0.52),
    (42, 12, 10, 10, 3, 12, 0.24),
    (40, 45, 11, 11, 3, -8, 0.32),
    (22, 28, 9, 9, 3, 0, 0.16),
    (8, 12, 7, 7, 2, 0, 0.1),
    (24, 14, 12, 4, 2, 0, 0.14),
    (4, 34, 12, 4, 2, 0, 0.1),
    (26, 54, 10, 4, 2, 0, 0.16),
    (57, 52, 15, 4, 2, 0, 0.26),
    (60, 13, 12, 4, 2, 0, 0.2),
    (166, 29, 14, 14, 3, 0, 0.52),
    (189, 15, 10, 10, 3, -10, 0.28),
    (187, 44, 11, 11, 3, 10, 0.22),
    (210, 30, 9, 9, 3, 0, 0.16),
    (225, 50, 7, 7, 2, 0, 0.1),
    (168, 13, 15, 4, 2, 0, 0.26),
    (206, 16, 10, 4, 2, 0, 0.14),
    (224, 34, 12, 4, 2, 0, 0.1),
    (166, 52, 12, 4, 2, 0, 0.2),
    (204, 56, 12, 4, 2, 0, 0.16),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 240, size.height / 72);
    final backing = Paint()..color = card;
    final fill = Paint();
    for (final (i, (x, y, w, h, r, deg, opacity)) in _shapes.indexed) {
      // Each shape flies out from the center a moment after the one before.
      final t = Curves.easeOutCubic.transform(
        ((entrance - 0.15 - (i % 10) * 0.03) / 0.55).clamp(0.0, 1.0));
      if (t == 0) continue;
      final cx = x + w / 2;
      final dx = (120 - cx) * (1 - t) * 0.6;
      final dy = 1.5 * math.sin(2 * math.pi * (float + i * 0.13));
      final rrect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x + dx, y + dy, w, h), Radius.circular(r));
      canvas.save();
      if (deg != 0) {
        final c = rrect.center;
        canvas.translate(c.dx, c.dy);
        canvas.rotate(deg * math.pi / 180);
        canvas.translate(-c.dx, -c.dy);
      }
      // A card-colored backing hides the dots behind each shape.
      backing.color = card.withValues(alpha: card.a * t);
      canvas.drawRRect(rrect, backing);
      fill.color = tone.withValues(alpha: opacity * t);
      canvas.drawRRect(rrect, fill);
      canvas.restore();
    }

    // The small marks come in last.
    final marks = ((entrance - 0.6) / 0.4).clamp(0.0, 1.0);
    if (marks == 0) return;
    final dashed = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = tone.withValues(alpha: 0.24 * marks);
    for (final rect in const [
      Rect.fromLTWH(10.6, 48.6, 7.8, 7.8),
      Rect.fromLTWH(220.6, 12.6, 7.8, 7.8),
    ]) {
      _drawDashedRRect(canvas, RRect.fromRectAndRadius(rect, const Radius.circular(2.5)), dashed);
    }

    final plus = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..color = tone.withValues(alpha: 0.34 * marks);
    for (final (cx, cy) in const [(30.0, 42.0), (203.0, 40.0)]) {
      canvas.drawLine(Offset(cx, cy - 3), Offset(cx, cy + 3), plus);
      canvas.drawLine(Offset(cx - 3, cy), Offset(cx + 3, cy), plus);
    }
  }

  void _drawDashedRRect(Canvas canvas, RRect rrect, Paint paint) {
    final path = Path()..addRRect(rrect);
    for (final metric in path.computeMetrics()) {
      for (double d = 0; d < metric.length; d += 4) {
        canvas.drawPath(metric.extractPath(d, math.min(d + 2, metric.length)), paint);
      }
    }
  }

  @override
  bool shouldRepaint(_GenericMotifPainter oldDelegate) =>
    tone != oldDelegate.tone || card != oldDelegate.card
    || entrance != oldDelegate.entrance || float != oldDelegate.float;
}

/// The animated illustration on the welcome page:
/// the Kloki mark in a pulsing circle, among floating Kloki shapes
/// and chat bubbles.
///
/// [entrance] runs from 0 to 1 once, as the page appears.
/// The idle motion then loops a few times and rests;
/// it doesn't run if the platform asks to reduce motion.
class KlokiWelcomeHero extends StatefulWidget {
  const KlokiWelcomeHero({super.key, required this.entrance});

  final Animation<double> entrance;

  static const size = Size(340, 320);

  @override
  State<KlokiWelcomeHero> createState() => _KlokiWelcomeHeroState();
}

class _KlokiWelcomeHeroState extends State<KlokiWelcomeHero>
    with SingleTickerProviderStateMixin {
  late final AnimationController _loop = AnimationController(
    vsync: this, duration: const Duration(seconds: 6));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _loop.stop();
    } else if (!_loop.isAnimating && _loop.isDismissed) {
      // Rest after a while, to spare the battery of a phone left on this page.
      _loop.repeat(count: 4);
    }
  }

  @override
  void dispose() {
    _loop.dispose();
    super.dispose();
  }

  // x, y (of the center), size, opacity, rotation in degrees, phase
  static const _shapes = <(double, double, double, double, double, double)>[
    (64, 128, 16, 0.30, 12, 0.0),
    (300, 58, 14, 0.22, -10, 0.3),
    (316, 252, 18, 0.34, 8, 0.6),
    (24, 236, 12, 0.18, -8, 0.15),
    (90, 296, 10, 0.16, 0, 0.45),
    (262, 300, 16, 0.24, 14, 0.8),
    (176, 14, 10, 0.14, 0, 0.55),
  ];

  @override
  Widget build(BuildContext context) {
    final designVariables = DesignVariables.of(context);
    final tone = designVariables.fabBg;
    final card = designVariables.bgTopBar;
    final entrance = widget.entrance;

    Animation<double> step(double begin, double end, [Curve curve = Curves.easeOut]) =>
      CurvedAnimation(parent: entrance, curve: Interval(begin, end, curve: curve));

    Widget float({required double phase, double amplitude = 6, required Widget child}) {
      return AnimatedBuilder(
        animation: _loop,
        builder: (context, child) => Transform.translate(
          offset: Offset(0, amplitude * math.sin(2 * math.pi * (_loop.value + phase))),
          child: child),
        child: child);
    }

    /// Fade in and scale up, overshooting a little, from [begin] to [end].
    Widget pop(double begin, double end, Widget child) {
      return FadeTransition(
        opacity: step(begin, begin + (end - begin) * 0.6),
        child: ScaleTransition(
          scale: step(begin, end, Curves.easeOutBack),
          child: child));
    }

    const circleSize = 148.0;
    final center = KlokiWelcomeHero.size.center(Offset.zero);

    return ExcludeSemantics(
      child: SizedBox.fromSize(
        size: KlokiWelcomeHero.size,
        child: Stack(clipBehavior: Clip.none, children: [
          Positioned.fill(
            child: FadeTransition(
              opacity: step(0, 0.5),
              child: CustomPaint(painter: _DotsPainter(
                color: designVariables.foreground.withValues(alpha: 0.09))))),

          Positioned.fill(
            child: AnimatedBuilder(
              animation: Listenable.merge([_loop, entrance]),
              builder: (context, _) => CustomPaint(painter: _PulsePainter(
                progress: _loop.value,
                visibility: entrance.value.clamp(0.0, 1.0),
                color: tone,
                innerRadius: circleSize / 2)))),

          for (final (i, (x, y, size, opacity, deg, phase)) in _shapes.indexed)
            Positioned(
              left: x - size / 2, top: y - size / 2,
              child: pop(0.2 + i * 0.05, 0.6 + i * 0.05,
                float(phase: phase, amplitude: 5,
                  child: Transform.rotate(
                    angle: deg * math.pi / 180,
                    child: Container(
                      width: size, height: size,
                      decoration: BoxDecoration(
                        color: tone.withValues(alpha: opacity),
                        borderRadius: BorderRadius.circular(size / 4))))))),

          Positioned(
            left: center.dx - circleSize / 2, top: center.dy - circleSize / 2,
            child: pop(0, 0.45,
              Container(
                width: circleSize, height: circleSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: card, width: 6),
                  boxShadow: [
                    BoxShadow(color: tone.withValues(alpha: 0.28),
                      blurRadius: 40, offset: const Offset(0, 16)),
                  ],
                  gradient: RadialGradient(
                    center: const Alignment(-0.3, -0.4),
                    radius: 0.9,
                    colors: [
                      Color.lerp(card, tone, 0.06)!,
                      Color.lerp(card, tone, 0.22)!,
                    ])),
                child: const Center(child: KlokiMark(size: 64))))),

          Positioned(left: 0, top: 36,
            child: pop(0.3, 0.7,
              float(phase: 0.1, child: _ChatBubble(
                tone: tone, card: card, border: designVariables.borderBar,
                lines: const [72, 46])))),

          Positioned(right: 0, top: 150,
            child: pop(0.42, 0.82,
              float(phase: 0.4, child: _ChatBubble(
                tone: tone, card: card, border: designVariables.borderBar,
                mine: true,
                lines: const [64, 38])))),

          Positioned(left: 22, bottom: 30,
            child: pop(0.55, 0.95,
              float(phase: 0.7, child: _ChatBubble(
                tone: tone, card: card, border: designVariables.borderBar,
                typing: _loop)))),
        ])));
  }
}

/// Rings spreading out from the circle and fading.
class _PulsePainter extends CustomPainter {
  _PulsePainter({
    required this.progress,
    required this.visibility,
    required this.color,
    required this.innerRadius,
  });

  final double progress;
  final double visibility;
  final Color color;
  final double innerRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    // Two rings half a loop apart, so one leaves every 3 seconds.
    for (int i = 0; i < 2; i++) {
      final t = (progress + i / 2) % 1;
      paint.color = color.withValues(alpha: 0.28 * (1 - t) * visibility);
      canvas.drawCircle(center, innerRadius + 4 + t * 90, paint);
    }
  }

  @override
  bool shouldRepaint(_PulsePainter oldDelegate) =>
    progress != oldDelegate.progress
    || visibility != oldDelegate.visibility
    || color != oldDelegate.color;
}

/// An abstract chat bubble: an avatar and lines of text,
/// or dots for someone typing.
class _ChatBubble extends StatelessWidget {
  const _ChatBubble({
    required this.tone,
    required this.card,
    required this.border,
    this.mine = false,
    this.lines = const [],
    this.typing,
  });

  final Color tone;
  final Color card;
  final Color border;
  final bool mine;
  final List<double> lines;

  /// The looping animation that moves the typing dots; null for a message.
  final Animation<double>? typing;

  @override
  Widget build(BuildContext context) {
    final background = mine ? tone : card;
    final ink = mine ? Colors.white.withValues(alpha: 0.75) : tone.withValues(alpha: 0.22);

    final Widget body;
    final typing = this.typing;
    if (typing != null) {
      body = AnimatedBuilder(
        animation: typing,
        builder: (context, _) => Row(mainAxisSize: MainAxisSize.min, children: [
          for (int i = 0; i < 3; i++)
            Padding(
              padding: EdgeInsetsDirectional.only(start: i == 0 ? 0 : 5),
              child: Transform.translate(
                // Six bounces per 6-second loop.
                offset: Offset(0, -3 * math.max(0,
                  math.sin(2 * math.pi * (typing.value * 6 - i * 0.18)))),
                child: Container(width: 7, height: 7,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: tone.withValues(alpha: 0.55))))),
        ]));
    } else {
      body = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final (i, width) in lines.indexed)
            Padding(
              padding: EdgeInsets.only(top: i == 0 ? 0 : 6),
              child: Container(width: width, height: 7,
                decoration: BoxDecoration(
                  color: ink, borderRadius: BorderRadius.circular(4)))),
        ]);
    }

    final bubble = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: background,
        border: mine ? null : Border.all(color: border),
        borderRadius: BorderRadiusDirectional.only(
          topStart: const Radius.circular(16),
          topEnd: const Radius.circular(16),
          bottomStart: Radius.circular(mine ? 16 : 4),
          bottomEnd: Radius.circular(mine ? 4 : 16),
        ).resolve(Directionality.of(context)),
        boxShadow: [
          BoxShadow(
            color: (mine ? tone : Colors.black).withValues(alpha: mine ? 0.3 : 0.06),
            blurRadius: 18, offset: const Offset(0, 6)),
        ]),
      child: body);

    if (mine) return bubble;
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(width: 26, height: 26,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Color.lerp(card, tone, 0.25),
            border: Border.all(color: card, width: 2))),
        const SizedBox(width: 6),
        bubble,
      ]);
  }
}

/// The entrance of a page, for its rows to stagger in with [KlokiStaggered].
///
/// [animation] runs from 0 to 1 as the page appears.
class KlokiEntrance extends InheritedWidget {
  const KlokiEntrance({super.key, required this.animation, required super.child});

  final Animation<double> animation;

  static Animation<double>? maybeOf(BuildContext context) =>
    context.dependOnInheritedWidgetOfExactType<KlokiEntrance>()?.animation;

  @override
  bool updateShouldNotify(KlokiEntrance oldWidget) => animation != oldWidget.animation;
}

/// A row of a page that eases in (a fade and a short rise)
/// a moment after the rows above it, as the page's [KlokiEntrance] runs.
///
/// Without a [KlokiEntrance], or once it has run, the row just shows;
/// so rows scrolled to later appear at once.
class KlokiStaggered extends StatelessWidget {
  const KlokiStaggered({super.key, required this.index, required this.child})
    : begin = null;

  /// A row that starts easing in at [begin] of the way through the entrance,
  /// for a page that orders its own beats.
  const KlokiStaggered.at({super.key, required double this.begin, required this.child})
    : index = 0;

  /// The row's place on the page, from the top.
  final int index;

  /// Where in the entrance this row starts; if null, from [index].
  final double? begin;
  final Widget child;

  /// Rows past this many share the last row's moment;
  /// they're below the first screen anyway.
  static const _maxStaggered = 10;

  @override
  Widget build(BuildContext context) {
    final entrance = KlokiEntrance.maybeOf(context);
    if (entrance == null) return child;
    // Rows start almost together, each a beat after the one above;
    // each fades in quickly, while its short rise eases out after.
    final begin = this.begin ?? math.min(index, _maxStaggered) * 0.03;
    final end = math.min(begin + 0.6, 1.0);
    final opacity = CurvedAnimation(parent: entrance,
      curve: Interval(begin, begin + (end - begin) * 0.5, curve: Curves.easeOut));
    final rise = CurvedAnimation(parent: entrance,
      curve: Interval(begin, end, curve: Curves.easeOutCubic));
    return FadeTransition(
      opacity: opacity,
      child: SlideTransition(
        position: rise.drive(
          Tween(begin: const Offset(0, 0.15), end: Offset.zero)),
        child: child));
  }
}

/// A Kloki loading indicator: the Kloki ring, with an arc running around it
/// and the check inside gently pulsing.
///
/// With reduced motion, it's the still Kloki mark.
class KlokiLoader extends StatefulWidget {
  const KlokiLoader({super.key, this.size = 40});

  final double size;

  @override
  State<KlokiLoader> createState() => _KlokiLoaderState();
}

class _KlokiLoaderState extends State<KlokiLoader> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this, duration: const Duration(milliseconds: 1100));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.maybeDisableAnimationsOf(context) ?? false) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.maybeDisableAnimationsOf(context) ?? false) {
      return KlokiMark(size: widget.size);
    }
    // This can show before the app's theme exists, as while the global store loads.
    final designVariables = Theme.of(context).extension<DesignVariables>()
      ?? DesignVariables.light;
    return Semantics(
      label: Localizations.of<MaterialLocalizations>(context, MaterialLocalizations)
        ?.refreshIndicatorSemanticLabel,
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) => CustomPaint(
            size: Size.square(widget.size),
            painter: _KlokiLoaderPainter(
              progress: _controller.value,
              tone: designVariables.fabBg,
              check: designVariables.title)))));
  }
}

class _KlokiLoaderPainter extends CustomPainter {
  _KlokiLoaderPainter({required this.progress, required this.tone, required this.check});

  final double progress;
  final Color tone;
  final Color check;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 28, size.height / 28);
    const center = Offset(14.07, 14.07);
    const radius = 11.4;
    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.7
      ..strokeCap = StrokeCap.round;

    ring.color = tone.withValues(alpha: 0.18);
    canvas.drawCircle(center, radius, ring);

    // The arc runs round, stretching and shrinking a little as it goes.
    final turn = 2 * math.pi * progress;
    final sweep = math.pi * (0.45 + 0.25 * math.sin(turn));
    ring.color = tone;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius),
      turn - math.pi / 2, sweep, false, ring);

    final pulse = 0.55 + 0.45 * (0.5 + 0.5 * math.sin(turn * 2));
    canvas.drawPath(_KlokiMarkPainter._check,
      Paint()..color = check.withValues(alpha: check.a * pulse));
  }

  @override
  bool shouldRepaint(_KlokiLoaderPainter oldDelegate) =>
    progress != oldDelegate.progress || tone != oldDelegate.tone || check != oldDelegate.check;
}

/// A quiet sun-or-moon button that switches between the light and dark themes,
/// live; the choice is the same setting as in the settings page.
class KlokiThemeToggle extends StatelessWidget {
  const KlokiThemeToggle({super.key});

  @override
  Widget build(BuildContext context) {
    final designVariables = DesignVariables.of(context);
    final zulipLocalizations = ZulipLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return IconButton(
      tooltip: isDark
        ? zulipLocalizations.themeSettingLight
        : zulipLocalizations.themeSettingDark,
      style: IconButton.styleFrom(
        backgroundColor: designVariables.fabBg,
        fixedSize: const Size.square(40)),
      onPressed: () => GlobalStoreWidget.settingsOf(context)
        .setThemeSetting(isDark ? ThemeSetting.light : ThemeSetting.dark),
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        switchInCurve: Curves.easeOutBack,
        switchOutCurve: Curves.easeIn,
        transitionBuilder: (child, animation) => RotationTransition(
          turns: animation.drive(Tween(begin: 0.6, end: 1.0)),
          child: ScaleTransition(scale: animation,
            child: FadeTransition(opacity: animation, child: child))),
        child: Icon(
          isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
          key: ValueKey(isDark),
          size: 20,
          color: Colors.white)));
  }
}
