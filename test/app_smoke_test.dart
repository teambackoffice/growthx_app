import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:growthx_app/app/app.dart';
import 'package:growthx_app/app/router.dart';
import 'package:growthx_app/app/routes.dart';
import 'package:growthx_app/app/shell/app_shell.dart';
import 'package:growthx_app/core/widgets/buttons.dart';

/// Small Android phone. Any RenderFlex overflow fails the test.
const _smallPhone = Size(320, 568);

Future<ProviderContainer> _pumpApp(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size * 2;
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.reset);

  final container = ProviderContainer();
  addTearDown(container.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(container: container, child: const GrowthXApp()),
  );
  await tester.pumpAndSettle();
  return container;
}

Future<void> _signIn(WidgetTester tester) async {
  await tester.enterText(
    find.widgetWithText(TextFormField, 'Email'),
    'arjun@example.com',
  );
  await tester.enterText(
    find.widgetWithText(TextFormField, 'Password'),
    'secret123',
  );
  await _tapVisible(tester, find.widgetWithText(PrimaryButton, 'Sign in'));
}

/// The scrollable on the visible screen (hidden tabs ignore pointers).
Finder get _visibleScrollable => find.byType(Scrollable).hitTestable();

Future<void> _scrollTo(WidgetTester tester, Finder finder) async {
  await tester.scrollUntilVisible(
    finder,
    200,
    scrollable: _visibleScrollable.first,
  );
  await tester.pumpAndSettle();
}

Future<void> _flingToBottom(WidgetTester tester) async {
  if (_visibleScrollable.evaluate().isEmpty) return;
  await tester.fling(_visibleScrollable.first, const Offset(0, -3000), 3000);
  await tester.pumpAndSettle();
}

Future<void> _flingToTop(WidgetTester tester) async {
  await tester.fling(_visibleScrollable.first, const Offset(0, 3000), 3000);
  await tester.pumpAndSettle();
}

Future<void> _tapVisible(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Future<void> _tapTab(WidgetTester tester, String label) async {
  await tester.tap(
    find.descendant(
      of: find.byType(FloatingNavBar),
      matching: find.text(label),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('login validates and signs in', (tester) async {
    await _pumpApp(tester, _smallPhone);
    expect(find.text('Welcome back'), findsOneWidget);

    await _tapVisible(tester, find.widgetWithText(PrimaryButton, 'Sign in'));
    expect(find.text('Enter your email address'), findsOneWidget);
    expect(find.text('Enter your password'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Email'),
      'arjun@example.com',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Password'),
      'wrongpass',
    );
    await _tapVisible(tester, find.widgetWithText(PrimaryButton, 'Sign in'));
    expect(find.textContaining('don\'t match'), findsOneWidget);

    await _signIn(tester);
    expect(find.textContaining('Arjun'), findsWidgets);
    expect(find.byType(FloatingNavBar), findsOneWidget);
  });

  testWidgets('forgot password flow', (tester) async {
    await _pumpApp(tester, _smallPhone);
    await _tapVisible(tester, find.text('Forgot password?'));
    await tester.enterText(find.byType(TextFormField), 'arjun@example.com');
    await _tapVisible(tester, find.text('Send reset link'));
    expect(find.text('Check your email'), findsOneWidget);
    await _tapVisible(tester, find.text('Back to sign in'));
    expect(find.text('Welcome back'), findsOneWidget);
  });

  testWidgets('every tab and pushed route renders on a small phone', (
    tester,
  ) async {
    final container = await _pumpApp(tester, _smallPhone);
    await _signIn(tester);
    final router = container.read(routerProvider);

    for (final tab in ['Customers', 'Referrals', 'Earnings', 'More', 'Home']) {
      await _tapTab(tester, tab);
      // Scroll each tab to the bottom so every section gets laid out.
      await _flingToBottom(tester);
    }

    final routes = [
      AppRoutes.customer('c01'),
      AppRoutes.customer('c05'),
      AppRoutes.customer('missing'),
      AppRoutes.payout('p03'),
      AppRoutes.notifications,
      AppRoutes.leads,
      AppRoutes.addLead,
      AppRoutes.profile,
      AppRoutes.editProfile,
      '/does-not-exist',
    ];
    for (final route in routes) {
      router.push(route);
      await tester.pumpAndSettle();
      await _flingToBottom(tester);
      router.pop();
      await tester.pumpAndSettle();
    }
  });

  testWidgets('home shortcuts filter customers; tabs keep state', (
    tester,
  ) async {
    await _pumpApp(tester, _smallPhone);
    await _signIn(tester);

    await _scrollTo(tester, find.text('Trials ending'));
    await tester.tap(find.text('Trials ending'));
    await tester.pumpAndSettle();
    expect(find.text('Trials ending in 7 days'), findsOneWidget);

    // Clear the shortcut chip, then search for something that doesn't exist.
    await tester.tap(find.byTooltip('Delete'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'zzzz');
    await tester.pumpAndSettle();
    expect(find.text('No customers found'), findsOneWidget);

    // Switching tabs and back preserves the search.
    await _tapTab(tester, 'Earnings');
    await _tapTab(tester, 'Customers');
    expect(find.text('No customers found'), findsOneWidget);

    await _tapVisible(tester, find.text('Clear filters'));
    expect(find.text('11 customers'), findsOneWidget);
  });

  testWidgets('add lead validates and saves', (tester) async {
    final container = await _pumpApp(tester, const Size(360, 740));
    await _signIn(tester);
    container.read(routerProvider).push(AppRoutes.leads);
    await tester.pumpAndSettle();
    expect(find.text('Krishna Silks'), findsOneWidget);

    await tester.tap(find.text('Add lead'));
    await tester.pumpAndSettle();

    final save = find.text('Save lead');
    await _scrollTo(tester, save);
    await tester.tap(save);
    await tester.pumpAndSettle();
    expect(find.text('Please confirm before saving'), findsOneWidget);
    await _flingToTop(tester);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Full name'),
      'Asha Thomas',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Mobile number'),
      '12345',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Business name'),
      'Asha Florists',
    );
    await tester.pumpAndSettle();
    expect(find.text('Enter a valid 10-digit mobile number'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Mobile number'),
      '98470 12345',
    );
    await tester.pumpAndSettle();
    final consent = find.text('This person agreed to be contacted by GrowthX.');
    await _scrollTo(tester, consent);
    await tester.tap(consent);
    await _scrollTo(tester, save);
    await tester.tap(save);
    await tester.pumpAndSettle();

    expect(find.text('My leads'), findsOneWidget);
    expect(find.text('Asha Florists'), findsOneWidget);
  });

  testWidgets('leaving a dirty form asks to discard', (tester) async {
    final container = await _pumpApp(tester, _smallPhone);
    await _signIn(tester);
    container.read(routerProvider).push(AppRoutes.addLead);
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Full name'),
      'Someone',
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byType(CloseButton));
    await tester.pumpAndSettle();
    expect(find.text('Discard changes?'), findsOneWidget);
    await tester.tap(find.text('Discard'));
    await tester.pumpAndSettle();
    expect(find.text('Discard changes?'), findsNothing);
    expect(find.byType(FloatingNavBar), findsOneWidget);
  });

  testWidgets('notifications mark read and badge updates', (tester) async {
    final container = await _pumpApp(tester, _smallPhone);
    await _signIn(tester);
    expect(find.byType(Badge), findsOneWidget);
    container.read(routerProvider).push(AppRoutes.notifications);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mark all read'));
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('Unread'));
    await tester.pumpAndSettle();
    expect(find.text('You\'re all caught up'), findsOneWidget);
  });

  testWidgets('logout asks for confirmation', (tester) async {
    final container = await _pumpApp(tester, _smallPhone);
    await _signIn(tester);
    await _tapTab(tester, 'More');
    final logout = find.text('Log out');
    await _scrollTo(tester, logout);
    await tester.tap(logout);
    await tester.pumpAndSettle();
    expect(find.text('Log out?'), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.byType(FloatingNavBar), findsOneWidget);

    await tester.tap(logout);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Log out'));
    await tester.pumpAndSettle();
    expect(find.text('Welcome back'), findsOneWidget);
    expect(
      container.read(routerProvider).routeInformationProvider.value.uri.path,
      AppRoutes.login,
    );
  });

  testWidgets('works with reduced motion', (tester) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    await _pumpApp(tester, _smallPhone);
    await _signIn(tester);
    expect(find.byType(FloatingNavBar), findsOneWidget);
    for (final tab in ['Customers', 'Referrals', 'Earnings', 'More', 'Home']) {
      await _tapTab(tester, tab);
    }
    await _scrollTo(tester, find.text('Invite & earn'));
    expect(find.text('Invite & earn'), findsOneWidget);
  });

  testWidgets('Android back on a tab returns to Home, then exits', (
    tester,
  ) async {
    final container = await _pumpApp(tester, _smallPhone);
    await _signIn(tester);
    final router = container.read(routerProvider);
    String location() => router.routerDelegate.currentConfiguration.uri.path;

    await _tapTab(tester, 'Earnings');
    expect(location(), AppRoutes.earnings);

    expect(await tester.binding.handlePopRoute(), isTrue);
    await tester.pumpAndSettle();
    expect(location(), AppRoutes.home);

    // On Home, back is left to the system (closes the app).
    expect(await tester.binding.handlePopRoute(), isFalse);
  });
}
