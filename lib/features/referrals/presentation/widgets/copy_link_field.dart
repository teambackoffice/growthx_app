import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_motion.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/motion.dart';

/// Read-only link with a Copy button that briefly morphs into "Copied".
class CopyLinkField extends StatefulWidget {
  const CopyLinkField({super.key, required this.value, this.display});

  final String value;

  /// Shorter text to show (e.g. without https://).
  final String? display;

  @override
  State<CopyLinkField> createState() => _CopyLinkFieldState();
}

class _CopyLinkFieldState extends State<CopyLinkField> {
  bool _copied = false;
  Timer? _reset;

  @override
  void dispose() {
    _reset?.cancel();
    super.dispose();
  }

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: widget.value));
    HapticFeedback.selectionClick();
    if (!mounted) return;
    setState(() => _copied = true);
    _reset?.cancel();
    _reset = Timer(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final duration = AppMotion.of(context, AppMotion.medium);
    return Container(
      height: 52,
      padding: const EdgeInsets.only(left: 14, right: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: AppRadius.control,
      ),
      child: Row(
        children: [
          const Icon(
            Icons.link_rounded,
            size: 20,
            color: AppColors.textTertiary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              widget.display ?? widget.value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: text.bodyMedium?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Semantics(
            button: true,
            label: _copied ? 'Link copied' : 'Copy link',
            excludeSemantics: true,
            child: PressScale(
              scale: 0.94,
              child: AnimatedContainer(
                duration: duration,
                curve: AppMotion.curve,
                height: 40,
                decoration: BoxDecoration(
                  color: _copied ? AppColors.success : AppColors.surface,
                  borderRadius: BorderRadius.circular(11),
                  boxShadow: _copied ? const [] : AppShadows.card,
                ),
                child: Material(
                  type: MaterialType.transparency,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(11),
                    onTap: _copy,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: AnimatedSwitcher(
                        duration: duration,
                        transitionBuilder: (child, a) => FadeTransition(
                          opacity: a,
                          child: ScaleTransition(
                            scale: Tween(begin: 0.85, end: 1.0).animate(a),
                            child: child,
                          ),
                        ),
                        child: Row(
                          key: ValueKey(_copied),
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _copied
                                  ? Icons.check_rounded
                                  : Icons.copy_rounded,
                              size: 16,
                              color: _copied
                                  ? Colors.white
                                  : AppColors.textPrimary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _copied ? 'Copied' : 'Copy',
                              style: text.labelMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: _copied
                                    ? Colors.white
                                    : AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
