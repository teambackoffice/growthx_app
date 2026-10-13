import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/empty_state.dart';
import '../routes.dart';

class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: EmptyState(
          icon: Icons.explore_off_outlined,
          title: 'Page not found',
          message: 'The page you were looking for doesn\'t exist or has moved.',
          actionLabel: 'Go to Home',
          onAction: () => context.go(AppRoutes.home),
        ),
      ),
    );
  }
}
