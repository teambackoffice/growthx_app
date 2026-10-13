import 'package:flutter/material.dart';

import '../utils/feedback.dart';

/// Asks before leaving a form with unsaved input.
class UnsavedChangesGuard extends StatelessWidget {
  const UnsavedChangesGuard({
    super.key,
    required this.hasChanges,
    required this.child,
  });

  final bool hasChanges;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !hasChanges,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final navigator = Navigator.of(context);
        final discard = await AppFeedback.confirm(
          context,
          title: 'Discard changes?',
          message:
              'You have unsaved changes. If you leave now they\'ll be lost.',
          confirmLabel: 'Discard',
          destructive: true,
        );
        if (discard) navigator.pop();
      },
      child: child,
    );
  }
}
