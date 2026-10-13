import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/feedback.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/buttons.dart';
import '../../../core/widgets/form_section.dart';
import '../../../core/widgets/unsaved_changes_guard.dart';
import '../data/profile_providers.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _profile = ref.read(profileProvider);
  late final _name = TextEditingController(text: _profile.name);
  late final _email = TextEditingController(text: _profile.email);
  late final _phone = TextEditingController(text: _profile.phone);
  late final _city = TextEditingController(text: _profile.city);
  late final _company = TextEditingController(text: _profile.company);
  bool _dirty = false;
  bool _saving = false;

  @override
  void dispose() {
    for (final c in [_name, _email, _phone, _city, _company]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    // Simulated network delay.
    await Future<void>.delayed(const Duration(milliseconds: 600));
    ref
        .read(profileProvider.notifier)
        .update(
          _profile.copyWith(
            name: _name.text.trim(),
            email: _email.text.trim(),
            phone: _phone.text.trim(),
            city: _city.text.trim(),
            company: _company.text.trim(),
          ),
        );
    if (!mounted) return;
    AppFeedback.snack(
      context,
      'Profile updated',
      icon: Icons.check_circle_rounded,
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return UnsavedChangesGuard(
      hasChanges: _dirty && !_saving,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Edit profile'),
          leading: const CloseButton(),
        ),
        body: Form(
          key: _formKey,
          onChanged: () {
            if (!_dirty) setState(() => _dirty = true);
          },
          child: ListView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            children: [
              FormSection(
                title: 'Personal',
                children: [
                  TextFormField(
                    controller: _name,
                    enabled: !_saving,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(labelText: 'Full name'),
                    validator: (v) => Validators.required(v, 'your name'),
                  ),
                  TextFormField(
                    controller: _email,
                    enabled: !_saving,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    autocorrect: false,
                    decoration: const InputDecoration(labelText: 'Email'),
                    validator: Validators.email,
                  ),
                  TextFormField(
                    controller: _phone,
                    enabled: !_saving,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9+ ]')),
                      LengthLimitingTextInputFormatter(15),
                    ],
                    decoration: const InputDecoration(
                      labelText: 'Mobile number',
                    ),
                    validator: Validators.phone,
                  ),
                  TextFormField(
                    controller: _city,
                    enabled: !_saving,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(labelText: 'City'),
                  ),
                ],
              ),
              FormSection(
                title: 'Business',
                children: [
                  TextFormField(
                    controller: _company,
                    enabled: !_saving,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _save(),
                    decoration: const InputDecoration(
                      labelText: 'Company name',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              PrimaryButton(
                label: 'Save changes',
                loading: _saving,
                onPressed: _save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
