import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_motion.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/motion.dart';

/// The primary referral action. A light sheen sweeps across once shortly
/// after it appears to draw the eye, then it stays still.
class ShareReferralButton extends StatefulWidget {
  const ShareReferralButton({
    super.key,
    required this.onPressed,
    this.label = 'Share referral link',
  });

  final VoidCallback onPressed;
  final String label;

  @override
  State<ShareReferralButton> createState() => _ShareReferralButtonState();
}

class _ShareReferralButtonState extends State<ShareReferralButton>
    with SingleTickerProviderStateMixin {
  late final _sheen = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );
  Timer? _delay;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_delay == null && !AppMotion.reduced(context)) {
      _delay = Timer(const Duration(milliseconds: 700), () {
        if (mounted) _sheen.forward();
      });
    }
  }

  @override
  void dispose() {
    _delay?.cancel();
    _sheen.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Semantics(
      button: true,
      label: widget.label,
      excludeSemantics: true,
      child: PressScale(
        child: Container(
          height: 54,
          decoration: BoxDecoration(
            gradient: AppGradients.primary,
            borderRadius: AppRadius.control,
            boxShadow: AppShadows.primaryGlow,
          ),
          child: Material(
            type: MaterialType.transparency,
            borderRadius: AppRadius.control,
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: widget.onPressed,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  AnimatedBuilder(
                    animation: _sheen,
                    builder: (context, _) => _sheen.value == 0
                        ? const SizedBox.shrink()
                        : FractionalTranslation(
                            translation: Offset(
                              -1.2 +
                                  2.4 *
                                      Curves.easeInOut.transform(_sheen.value),
                              0,
                            ),
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.white.withValues(alpha: 0),
                                    Colors.white.withValues(alpha: 0.28),
                                    Colors.white.withValues(alpha: 0),
                                  ],
                                  stops: const [0.3, 0.5, 0.7],
                                ),
                              ),
                            ),
                          ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.ios_share_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Flexible(
                        child: Text(
                          widget.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: text.labelLarge?.copyWith(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
