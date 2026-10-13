import 'dart:async';

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_motion.dart';
import '../theme/app_spacing.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';

/// Fades and slides its child up into place once, after a stagger delay
/// based on [index]. Items past [maxStagger] (e.g. rows scrolled into view
/// later) appear immediately so long lists never feel slow.
class FadeSlideIn extends StatefulWidget {
  const FadeSlideIn({
    super.key,
    required this.child,
    this.index = 0,
    this.offset = 14,
    this.duration = AppMotion.slow,
  });

  static const maxStagger = 10;

  final Widget child;
  final int index;
  final double offset;
  final Duration duration;

  @override
  State<FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<FadeSlideIn>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  );
  late final _curve = CurvedAnimation(
    parent: _controller,
    curve: AppMotion.curve,
  );
  Timer? _timer;
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    if (AppMotion.reduced(context) || widget.index >= FadeSlideIn.maxStagger) {
      _controller.value = 1;
    } else if (widget.index == 0) {
      _controller.forward();
    } else {
      _timer = Timer(AppMotion.stagger * widget.index, _controller.forward);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _curve,
      child: widget.child,
      builder: (context, child) => Opacity(
        opacity: _curve.value,
        child: Transform.translate(
          offset: Offset(0, widget.offset * (1 - _curve.value)),
          child: child,
        ),
      ),
    );
  }
}

/// Counts up to [value] (and animates between later values).
class AnimatedAmount extends StatelessWidget {
  const AnimatedAmount({
    super.key,
    required this.value,
    this.style,
    this.format = Fmt.inr,
    this.duration = const Duration(milliseconds: 700),
  });

  final double value;
  final TextStyle? style;
  final String Function(num value) format;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    final base = style ?? DefaultTextStyle.of(context).style;
    return Semantics(
      label: format(value),
      excludeSemantics: true,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: value),
        duration: AppMotion.of(context, duration),
        curve: AppMotion.curve,
        builder: (context, v, _) => Text(
          // Land exactly on the target so rounding never shows ₹1 off.
          format(v == value ? value : v.roundToDouble()),
          style: base.tabular,
          maxLines: 1,
        ),
      ),
    );
  }
}

/// Shrinks slightly while pressed. Wrap tappable surfaces; the child keeps
/// handling the tap itself.
class PressScale extends StatefulWidget {
  const PressScale({
    super.key,
    required this.child,
    this.scale = 0.97,
    this.enabled = true,
  });

  final Widget child;
  final double scale;
  final bool enabled;

  @override
  State<PressScale> createState() => _PressScaleState();
}

class _PressScaleState extends State<PressScale> {
  bool _down = false;

  void _set(bool down) {
    // Pointer-up can arrive after a tap navigated away and disposed us.
    if (mounted && widget.enabled && _down != down) {
      setState(() => _down = down);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => _set(true),
      onPointerUp: (_) => _set(false),
      onPointerCancel: (_) => _set(false),
      child: AnimatedScale(
        scale: _down ? widget.scale : 1,
        duration: AppMotion.of(context, AppMotion.fast),
        curve: AppMotion.curve,
        child: widget.child,
      ),
    );
  }
}

/// Sweeping highlight over skeleton placeholders.
class Shimmer extends StatefulWidget {
  const Shimmer({super.key, required this.child});

  final Widget child;

  @override
  State<Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<Shimmer> with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (AppMotion.reduced(context)) {
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
    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) {
        final t = _controller.value * 2 - 0.5;
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) => LinearGradient(
            begin: Alignment(t * 2 - 1.5, -0.3),
            end: Alignment(t * 2 - 0.5, 0.3),
            colors: const [
              AppColors.surfaceMuted,
              Color(0xFFFAFBFD),
              AppColors.surfaceMuted,
            ],
          ).createShader(bounds),
          child: child,
        );
      },
    );
  }
}

class SkeletonBox extends StatelessWidget {
  const SkeletonBox({
    super.key,
    this.width,
    required this.height,
    this.radius = 8,
  });

  final double? width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

/// Placeholder for a card of list rows (avatar, two lines, trailing value).
class SkeletonList extends StatelessWidget {
  const SkeletonList({super.key, this.rows = 5});

  final int rows;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.card,
        boxShadow: AppShadows.card,
      ),
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Shimmer(
        child: Column(
          children: [
            for (var i = 0; i < rows; i++)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: 14,
                ),
                child: Row(
                  children: [
                    const SkeletonBox(width: 42, height: 42, radius: 21),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FractionallySizedBox(
                            widthFactor: i.isEven ? 0.7 : 0.55,
                            child: const SkeletonBox(height: 12),
                          ),
                          const SizedBox(height: 8),
                          const FractionallySizedBox(
                            widthFactor: 0.4,
                            child: SkeletonBox(height: 10),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    const SkeletonBox(width: 56, height: 20, radius: 10),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Shows [placeholder] briefly the first time a screen is built, then
/// cross-fades to [child] — simulating the first fetch of local data.
class FirstLoad extends StatefulWidget {
  const FirstLoad({
    super.key,
    required this.child,
    required this.placeholder,
    this.duration = const Duration(milliseconds: 650),
  });

  final Widget child;
  final Widget placeholder;
  final Duration duration;

  @override
  State<FirstLoad> createState() => _FirstLoadState();
}

class _FirstLoadState extends State<FirstLoad> {
  bool _loading = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(widget.duration, () {
      if (mounted) setState(() => _loading = false);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: AppMotion.of(context, AppMotion.medium),
      switchInCurve: AppMotion.curve,
      layoutBuilder: (current, previous) => Stack(
        alignment: Alignment.topCenter,
        children: [...previous, ?current],
      ),
      child: _loading
          ? KeyedSubtree(
              key: const ValueKey('loading'),
              child: widget.placeholder,
            )
          : KeyedSubtree(key: const ValueKey('ready'), child: widget.child),
    );
  }
}

/// Same as [FirstLoad] for screens built from slivers: exposes [firstLoading]
/// so the screen can render a skeleton sliver while it's true.
mixin FirstLoadMixin<T extends StatefulWidget> on State<T> {
  bool firstLoading = true;
  Timer? _firstLoadTimer;

  @override
  void initState() {
    super.initState();
    _firstLoadTimer = Timer(const Duration(milliseconds: 650), () {
      if (mounted) setState(() => firstLoading = false);
    });
  }

  @override
  void dispose() {
    _firstLoadTimer?.cancel();
    super.dispose();
  }
}
