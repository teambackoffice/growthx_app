import 'package:flutter/material.dart';

/// Colour tokens: deep navy + indigo brand, cool neutrals, four status tones.
abstract final class AppColors {
  // Brand.
  static const navy = Color(0xFF0B1230);
  static const navySoft = Color(0xFF1A2350);
  static const primary = Color(0xFF4F46E5);
  static const primaryDark = Color(0xFF3730A3);
  static const primarySoft = Color(0xFFEEF0FF);
  static const accent = Color(0xFF22C3A6);

  // Neutrals.
  static const background = Color(0xFFF5F6FA);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceMuted = Color(0xFFF1F2F7);
  static const border = Color(0xFFE5E7EF);
  static const divider = Color(0xFFEEF0F5);

  static const textPrimary = Color(0xFF0B1220);
  static const textSecondary = Color(0xFF4A5170);
  static const textTertiary = Color(0xFF7A819C);
  static const textDisabled = Color(0xFFA6ACC2);

  // On dark (navy) surfaces.
  static const onNavy = Color(0xFFFFFFFF);
  static const onNavyMuted = Color(0xFFA9B0D6);

  // Status.
  static const success = Color(0xFF0E9F6E);
  static const successSoft = Color(0xFFE6F7F0);
  static const warning = Color(0xFFC2620A);
  static const warningSoft = Color(0xFFFFF3E5);
  static const danger = Color(0xFFD92D20);
  static const dangerSoft = Color(0xFFFDECEB);
  static const info = Color(0xFF2563EB);
  static const infoSoft = Color(0xFFEAF1FE);

  /// Soft tints for avatars, picked by name so each customer stays the same.
  static const avatarTints = [
    (Color(0xFFEEF0FF), Color(0xFF4338CA)),
    (Color(0xFFE6F7F0), Color(0xFF047857)),
    (Color(0xFFFFF3E5), Color(0xFFB45309)),
    (Color(0xFFFCEBF4), Color(0xFFBE185D)),
    (Color(0xFFE8F4FD), Color(0xFF0369A1)),
  ];
}

abstract final class AppGradients {
  /// Hero surfaces: earnings, login header, QR showcase.
  static const hero = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0B1230), Color(0xFF1E1B6B), Color(0xFF4338CA)],
    stops: [0, 0.55, 1],
  );

  /// Primary call-to-action.
  static const primary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF5B52F0), Color(0xFF4338CA)],
  );
}

abstract final class AppShadows {
  /// Resting cards — barely there.
  static const card = [
    BoxShadow(color: Color(0x0A0B1230), blurRadius: 2, offset: Offset(0, 1)),
    BoxShadow(color: Color(0x0D0B1230), blurRadius: 16, offset: Offset(0, 6)),
  ];

  /// Floating elements: navigation bar, hero card, primary button.
  static const floating = [
    BoxShadow(color: Color(0x1F0B1230), blurRadius: 24, offset: Offset(0, 10)),
    BoxShadow(color: Color(0x140B1230), blurRadius: 4, offset: Offset(0, 1)),
  ];

  static const primaryGlow = [
    BoxShadow(color: Color(0x404F46E5), blurRadius: 18, offset: Offset(0, 8)),
  ];
}
