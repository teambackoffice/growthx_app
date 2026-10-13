import 'package:flutter/widgets.dart';

/// Motion tokens. Everything is short (150–350 ms) and eases out, so motion
/// confirms an action without slowing it down.
abstract final class AppMotion {
  static const fast = Duration(milliseconds: 150);
  static const medium = Duration(milliseconds: 250);
  static const slow = Duration(milliseconds: 350);

  /// Delay between items in a staggered entrance.
  static const stagger = Duration(milliseconds: 45);

  static const curve = Curves.easeOutCubic;
  static const emphasized = Cubic(0.2, 0, 0, 1);

  /// True when the user asked the OS to reduce motion.
  static bool reduced(BuildContext context) =>
      MediaQuery.maybeDisableAnimationsOf(context) ?? false;

  /// [duration], or zero when motion is reduced.
  static Duration of(BuildContext context, Duration duration) =>
      reduced(context) ? Duration.zero : duration;
}
