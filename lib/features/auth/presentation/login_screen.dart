import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_motion.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/brand_mark.dart';
import '../../../core/widgets/buttons.dart';
import '../../../core/widgets/inline_banner.dart';
import '../../../core/widgets/motion.dart';
import '../../../core/widgets/status_badge.dart';
import '../data/auth_providers.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    setState(() => _error = null);
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      await ref
          .read(authProvider.notifier)
          .signIn(email: _email.text.trim(), password: _password.text);
      // The router redirects to Home once signed in.
    } on AuthException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.navy,
        // Gradient behind the header, white behind the sheet, so the sheet
        // always reaches the bottom edge without measuring its height.
        body: Stack(
          fit: StackFit.expand,
          children: [
            const Positioned.fill(
              child: Column(
                children: [
                  Expanded(
                    child: DecoratedBox(
                      decoration: BoxDecoration(gradient: AppGradients.hero),
                      child: SizedBox.expand(),
                    ),
                  ),
                  Expanded(
                    child: ColoredBox(
                      color: AppColors.surface,
                      child: SizedBox.expand(),
                    ),
                  ),
                ],
              ),
            ),
            SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              // One gradient behind header and sheet, so the sheet's rounded
              // corners reveal the same gradient as the header.
              child: DecoratedBox(
                decoration: const BoxDecoration(gradient: AppGradients.hero),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const _Header(),
                    FadeSlideIn(
                      index: 3,
                      offset: 40,
                      child: _buildSheet(context),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSheet(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(
        24,
        28,
        24,
        24 + MediaQuery.paddingOf(context).bottom,
      ),
      child: AutofillGroup(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Welcome back', style: text.headlineSmall),
              const SizedBox(height: 4),
              Text(
                'Track customers, referrals and earnings.',
                style: text.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.xl),
              AnimatedSize(
                duration: AppMotion.of(context, AppMotion.medium),
                curve: AppMotion.curve,
                child: _error == null
                    ? const SizedBox(width: double.infinity)
                    : Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: InlineBanner(
                          message: _error!,
                          tone: BadgeTone.danger,
                          icon: Icons.error_outline_rounded,
                        ),
                      ),
              ),
              TextFormField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.email],
                autocorrect: false,
                enabled: !_loading,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.mail_outline_rounded),
                ),
                validator: Validators.email,
              ),
              const SizedBox(height: AppSpacing.md + 2),
              TextFormField(
                controller: _password,
                obscureText: _obscure,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.password],
                enabled: !_loading,
                onFieldSubmitted: (_) => _submit(),
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                  suffixIcon: IconButton(
                    tooltip: _obscure ? 'Show password' : 'Hide password',
                    icon: AnimatedSwitcher(
                      duration: AppMotion.of(context, AppMotion.fast),
                      child: Icon(
                        _obscure
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        key: ValueKey(_obscure),
                      ),
                    ),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
                validator: Validators.password,
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _loading
                      ? null
                      : () => context.push(AppRoutes.forgotPassword),
                  child: const Text('Forgot password?'),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              PrimaryButton(
                label: 'Sign in',
                loading: _loading,
                onPressed: _submit,
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                'Demo: any email and a password of 6+ characters.',
                textAlign: TextAlign.center,
                style: text.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const FadeSlideIn(child: BrandMark(onDark: true)),
            const SizedBox(height: 36),
            FadeSlideIn(
              index: 1,
              child: Text(
                'Grow with every\nbusiness you refer.',
                style: text.headlineMedium?.copyWith(color: Colors.white),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            const FadeSlideIn(
              index: 2,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _GlassPill(
                    icon: Icons.percent_rounded,
                    label: '50% first-month commission',
                  ),
                  _GlassPill(
                    icon: Icons.event_available_rounded,
                    label: 'Paid every 15th',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GlassPill extends StatelessWidget {
  const _GlassPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 6, 12, 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: AppRadius.pill,
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: AppColors.accent),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelMedium
                  ?.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
