import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../utils/formatters.dart';

/// Initials on a soft tint chosen from the name, so each person keeps a
/// consistent colour across screens.
class InitialsAvatar extends StatelessWidget {
  const InitialsAvatar({
    super.key,
    required this.name,
    this.size = 42,
    this.gradient = false,
  });

  final String name;
  final double size;

  /// Brand gradient instead of a tint — used for the partner's own avatar.
  final bool gradient;

  @override
  Widget build(BuildContext context) {
    final tints = AppColors.avatarTints;
    final (bg, fg) =
        tints[name.codeUnits.fold<int>(0, (a, b) => a + b) % tints.length];
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: gradient ? null : bg,
        gradient: gradient ? AppGradients.primary : null,
        shape: BoxShape.circle,
      ),
      child: Text(
        Fmt.initials(name),
        style: TextStyle(
          color: gradient ? Colors.white : fg,
          fontWeight: FontWeight.w700,
          fontSize: size * 0.36,
          letterSpacing: -0.2,
        ),
      ),
    );
  }
}

/// Rounded-square tinted icon used to lead rows.
class IconBox extends StatelessWidget {
  const IconBox({
    super.key,
    required this.icon,
    this.color = AppColors.primary,
    this.background = AppColors.primarySoft,
    this.size = 42,
  });

  final IconData icon;
  final Color color;
  final Color background;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(size * 0.32),
      ),
      child: Icon(icon, color: color, size: size * 0.5),
    );
  }
}
