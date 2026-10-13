import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_motion.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/buttons.dart';
import '../../../core/widgets/motion.dart';
import '../data/auth_providers.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  bool _loading = false;
  String? _sentTo;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    await ref.read(authProvider.notifier).sendPasswordReset(_email.text.trim());
    if (mounted) {
      setState(() {
        _loading = false;
        _sentTo = _email.text.trim();
      });
    }
  }

  void _backToLogin() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        leading: BackButton(onPressed: _backToLogin),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 4, 24, 32),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: AnimatedSwitcher(
                duration: AppMotion.of(context, AppMotion.slow),
                switchInCurve: AppMotion.curve,
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween(
                      begin: const Offset(0, 0.04),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                ),
                child: _sentTo == null ? _buildForm() : _buildSent(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _icon(IconData icon, {bool success = false}) => Container(
    width: 64,
    height: 64,
    decoration: BoxDecoration(
      color: success ? AppColors.successSoft : AppColors.primarySoft,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Icon(
      icon,
      size: 30,
      color: success ? AppColors.success : AppColors.primary,
    ),
  );

  Widget _buildForm() {
    final text = Theme.of(context).textTheme;
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FadeSlideIn(child: _icon(Icons.lock_reset_rounded)),
          const SizedBox(height: AppSpacing.xl),
          Text('Reset your password', style: text.headlineSmall),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Enter the email you use for GrowthX. We\'ll send you a link to '
            'create a new password.',
            style: text.bodyLarge?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.xl),
          TextFormField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.send,
            autofillHints: const [AutofillHints.email],
            autocorrect: false,
            autofocus: true,
            enabled: !_loading,
            onFieldSubmitted: (_) => _submit(),
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.mail_outline_rounded),
            ),
            validator: Validators.email,
          ),
          const SizedBox(height: AppSpacing.xl),
          PrimaryButton(
            label: 'Send reset link',
            loading: _loading,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }

  Widget _buildSent() {
    final text = Theme.of(context).textTheme;
    return Column(
      key: const ValueKey('sent'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.6, end: 1),
            duration: AppMotion.of(context, AppMotion.slow),
            curve: Curves.easeOutBack,
            builder: (context, s, child) =>
                Transform.scale(scale: s, child: child),
            child: _icon(Icons.mark_email_read_outlined, success: true),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Text('Check your email', style: text.headlineSmall),
        const SizedBox(height: AppSpacing.sm),
        Text.rich(
          TextSpan(
            children: [
              const TextSpan(text: 'We sent a password reset link to '),
              TextSpan(
                text: _sentTo,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const TextSpan(
                text:
                    '. It expires in 30 minutes. Check spam if you don\'t '
                    'see it.',
              ),
            ],
          ),
          style: text.bodyLarge?.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: AppSpacing.xxl),
        PrimaryButton(label: 'Back to sign in', onPressed: _backToLogin),
        const SizedBox(height: AppSpacing.sm),
        TextButton(
          onPressed: () => setState(() => _sentTo = null),
          child: const Text('Use a different email'),
        ),
      ],
    );
  }
}
