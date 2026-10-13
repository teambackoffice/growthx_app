import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_motion.dart';

class _Destination {
  const _Destination(this.label, this.icon, this.selectedIcon);

  final String label;
  final IconData icon;
  final IconData selectedIcon;
}

const _destinations = [
  _Destination('Home', Icons.home_outlined, Icons.home_rounded),
  _Destination('Customers', Icons.people_outline_rounded, Icons.people_rounded),
  _Destination('Referrals', Icons.share_outlined, Icons.share_rounded),
  _Destination(
    'Earnings',
    Icons.account_balance_wallet_outlined,
    Icons.account_balance_wallet_rounded,
  ),
  _Destination('More', Icons.grid_view_outlined, Icons.grid_view_rounded),
];

/// Scaffold for the five main tabs. Each tab keeps its own navigation stack
/// and scroll position via [StatefulNavigationShell].
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  void _onSelect(int index) {
    // Re-tapping the current tab returns it to its first screen.
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final onHome = navigationShell.currentIndex == 0;
    // Android back on another tab's first screen returns to Home instead of
    // closing the app. Screens pushed inside a tab still pop first.
    return PopScope(
      canPop: onHome,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && !onHome) navigationShell.goBranch(0);
      },
      child: Scaffold(
        body: navigationShell,
        // Sits below the content (not over it), so nothing is ever hidden.
        bottomNavigationBar: FloatingNavBar(
          currentIndex: navigationShell.currentIndex,
          onSelect: _onSelect,
        ),
      ),
    );
  }
}

/// Rounded navy bar floating above the bottom edge. An indigo pill slides
/// to the selected destination.
class FloatingNavBar extends StatelessWidget {
  const FloatingNavBar({
    super.key,
    required this.currentIndex,
    required this.onSelect,
  });

  final int currentIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final duration = AppMotion.of(context, AppMotion.slow);
    return ColoredBox(
      color: AppColors.background,
      child: SafeArea(
        top: false,
        minimum: const EdgeInsets.only(bottom: 10),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 6, 12, 0),
          child: Container(
            height: 64,
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.navy,
              borderRadius: BorderRadius.circular(22),
              boxShadow: AppShadows.floating,
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final itemWidth = constraints.maxWidth / _destinations.length;
                return Stack(
                  children: [
                    AnimatedPositioned(
                      duration: duration,
                      curve: AppMotion.emphasized,
                      left: itemWidth * currentIndex,
                      top: 0,
                      bottom: 0,
                      width: itemWidth,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: AppGradients.primary,
                          borderRadius: BorderRadius.circular(17),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        for (var i = 0; i < _destinations.length; i++)
                          Expanded(
                            child: _NavItem(
                              destination: _destinations[i],
                              selected: i == currentIndex,
                              onTap: () => onSelect(i),
                            ),
                          ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.destination,
    required this.selected,
    required this.onTap,
  });

  final _Destination destination;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final duration = AppMotion.of(context, AppMotion.medium);
    final color = selected ? Colors.white : AppColors.onNavyMuted;
    return Semantics(
      button: true,
      selected: selected,
      label: destination.label,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedSwitcher(
              duration: duration,
              transitionBuilder: (child, animation) => ScaleTransition(
                scale: Tween(begin: 0.8, end: 1.0).animate(animation),
                child: FadeTransition(opacity: animation, child: child),
              ),
              child: Icon(
                selected ? destination.selectedIcon : destination.icon,
                key: ValueKey(selected),
                color: color,
                size: 22,
              ),
            ),
            const SizedBox(height: 3),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: AnimatedDefaultTextStyle(
                  duration: duration,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    height: 1.1,
                    letterSpacing: -0.1,
                    color: color,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  ),
                  child: Text(destination.label, maxLines: 1),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Keeps every visited tab alive (like go_router's IndexedStack container)
/// and fades and lifts the incoming tab into place.
class FadingBranchContainer extends StatelessWidget {
  const FadingBranchContainer({
    super.key,
    required this.currentIndex,
    required this.children,
  });

  final int currentIndex;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        for (var i = 0; i < children.length; i++)
          _Branch(active: i == currentIndex, child: children[i]),
      ],
    );
  }
}

class _Branch extends StatelessWidget {
  const _Branch({required this.active, required this.child});

  final bool active;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final duration = AppMotion.of(context, AppMotion.medium);
    // Inactive tabs are Offstage (not laid out, painted, hit-tested or read
    // by screen readers) but keep their state; the active one fades in.
    return Offstage(
      offstage: !active,
      child: ExcludeFocus(
        excluding: !active,
        child: TickerMode(
          enabled: active,
          child: AnimatedOpacity(
            opacity: active ? 1 : 0,
            duration: duration,
            curve: AppMotion.curve,
            child: AnimatedSlide(
              offset: active ? Offset.zero : const Offset(0, 0.012),
              duration: duration,
              curve: AppMotion.curve,
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
