import 'package:flutter/widgets.dart';

/// Spacing scale on a 4pt grid.
abstract final class AppSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 24.0;
  static const xxl = 32.0;

  /// Horizontal gutter used by every screen.
  static const page = EdgeInsets.symmetric(horizontal: 20);

  /// Default padding for scrollable screen bodies.
  static const pageBody = EdgeInsets.fromLTRB(20, 4, 20, 28);
}

abstract final class AppRadius {
  static const sm = 10.0;
  static const md = 14.0;
  static const lg = 20.0;
  static const xl = 28.0;

  static final card = BorderRadius.circular(lg);
  static final control = BorderRadius.circular(md);
  static final pill = BorderRadius.circular(999);
}
