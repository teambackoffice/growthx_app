import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme/app_colors.dart';
import '../theme/app_motion.dart';

/// Lightweight user-feedback helpers shared by every feature.
abstract final class AppFeedback {
  static void snack(BuildContext context, String message, {IconData? icon}) {
    final messenger = ScaffoldMessenger.of(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 3),
          content: Row(
            children: [
              if (icon != null) ...[
                Icon(icon, color: Colors.white, size: 20),
                const SizedBox(width: 12),
              ],
              Expanded(child: Text(message)),
            ],
          ),
        ),
      );
  }

  static Future<void> copy(
    BuildContext context,
    String value, {
    String label = 'Copied to clipboard',
  }) async {
    await Clipboard.setData(ClipboardData(text: value));
    if (context.mounted) {
      snack(context, label, icon: Icons.check_circle_rounded);
    }
  }

  static Future<void> share(
    BuildContext context, {
    required String text,
    String? subject,
  }) async {
    try {
      await SharePlus.instance.share(ShareParams(text: text, subject: subject));
    } catch (_) {
      // Sharing isn't available everywhere (tests, some desktops) — fall back
      // to copying so the action still does something useful.
      if (context.mounted) {
        await copy(
          context,
          text,
          label: 'Sharing unavailable — copied to clipboard instead',
        );
      }
    }
  }

  /// Opens the dialer / mail app; copies [value] if nothing can handle it.
  static Future<void> open(
    BuildContext context,
    Uri uri, {
    required String value,
  }) async {
    var opened = false;
    try {
      opened = await launchUrl(uri);
    } catch (_) {
      opened = false;
    }
    if (!opened && context.mounted) {
      await copy(context, value, label: '$value copied to clipboard');
    }
  }

  /// Dialog that fades in while scaling up from 96%.
  static Future<T?> dialog<T>(
    BuildContext context, {
    required WidgetBuilder builder,
  }) {
    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: const Color(0x800B1230),
      transitionDuration: AppMotion.of(context, AppMotion.medium),
      pageBuilder: (context, _, _) => builder(context),
      transitionBuilder: (context, animation, _, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: AppMotion.emphasized,
          reverseCurve: Curves.easeIn,
        );
        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            scale: Tween(begin: 0.96, end: 1.0).animate(curved),
            child: child,
          ),
        );
      },
    );
  }

  /// Bottom sheet with a tuned slide-up animation.
  static Future<T?> sheet<T>(
    BuildContext context, {
    required WidgetBuilder builder,
    bool scrollControlled = false,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: scrollControlled,
      sheetAnimationStyle: AnimationStyle(
        duration: AppMotion.of(context, const Duration(milliseconds: 320)),
        reverseDuration: AppMotion.of(context, AppMotion.medium),
        curve: AppMotion.emphasized,
      ),
      builder: builder,
    );
  }

  static Future<bool> confirm(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmLabel,
    bool destructive = false,
    IconData icon = Icons.help_outline_rounded,
  }) async {
    final result = await dialog<bool>(
      context,
      builder: (context) {
        final text = Theme.of(context).textTheme;
        final tone = destructive ? AppColors.danger : AppColors.primary;
        final toneSoft = destructive
            ? AppColors.dangerSoft
            : AppColors.primarySoft;
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 28),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: toneSoft,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: tone),
                ),
                const SizedBox(height: 16),
                Text(title, style: text.titleLarge),
                const SizedBox(height: 6),
                Text(message, style: text.bodyMedium),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context, false),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(0, 48),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: FilledButton.styleFrom(
                          minimumSize: const Size(0, 48),
                          backgroundColor: tone,
                        ),
                        child: Text(confirmLabel),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
    return result ?? false;
  }
}
