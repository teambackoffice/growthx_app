import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/feedback.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/buttons.dart';
import '../../../core/widgets/filter_chip_bar.dart';
import '../../../core/widgets/form_section.dart';
import '../../../core/widgets/unsaved_changes_guard.dart';
import '../../customers/data/customer.dart';
import '../data/lead.dart';
import '../data/lead_providers.dart';

class AddLeadScreen extends ConsumerStatefulWidget {
  const AddLeadScreen({super.key});

  @override
  ConsumerState<AddLeadScreen> createState() => _AddLeadScreenState();
}

class _AddLeadScreenState extends ConsumerState<AddLeadScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _business = TextEditingController();
  final _city = TextEditingController();
  final _notes = TextEditingController();
  Plan? _plan;
  bool _consent = false;
  bool _dirty = false;
  bool _saving = false;
  bool _submitted = false;

  @override
  void dispose() {
    for (final c in [_name, _phone, _email, _business, _city, _notes]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    setState(() => _submitted = true);
    if (!_formKey.currentState!.validate() || !_consent) {
      AppFeedback.snack(
        context,
        'Please fix the highlighted fields',
        icon: Icons.error_outline_rounded,
      );
      return;
    }

    setState(() => _saving = true);
    final lead = Lead(
      id: 'l${DateTime.now().millisecondsSinceEpoch}',
      contactName: _name.text.trim(),
      businessName: _business.text.trim(),
      phone: _phone.text.trim(),
      email: _email.text.trim(),
      city: _city.text.trim(),
      interestedPlan: _plan,
      notes: _notes.text.trim(),
      createdOn: DateTime.now(),
    );
    await ref.read(leadsProvider.notifier).add(lead);
    if (!mounted) return;
    AppFeedback.snack(
      context,
      'Lead added. Our team will reach out within 24 hours.',
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
          title: const Text('Add a lead'),
          leading: const CloseButton(),
        ),
        body: Form(
          key: _formKey,
          onChanged: () {
            if (!_dirty) setState(() => _dirty = true);
          },
          autovalidateMode: _submitted
              ? AutovalidateMode.onUserInteraction
              : AutovalidateMode.disabled,
          child: ListView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            children: [
              Text(
                'Share a business that could use GrowthX. We\'ll contact '
                'them and credit the sign-up to you.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.xl),
              FormSection(
                title: 'Contact',
                children: [
                  TextFormField(
                    controller: _name,
                    enabled: !_saving,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.name],
                    decoration: const InputDecoration(
                      labelText: 'Full name',
                      prefixIcon: Icon(Icons.person_outline_rounded),
                    ),
                    validator: (v) => Validators.required(v, 'their name'),
                  ),
                  TextFormField(
                    controller: _phone,
                    enabled: !_saving,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.telephoneNumber],
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9+ ]')),
                      LengthLimitingTextInputFormatter(15),
                    ],
                    decoration: const InputDecoration(
                      labelText: 'Mobile number',
                      hintText: '98470 12345',
                      prefixIcon: Icon(Icons.phone_outlined),
                    ),
                    validator: Validators.phone,
                  ),
                  TextFormField(
                    controller: _email,
                    enabled: !_saving,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    autocorrect: false,
                    decoration: const InputDecoration(
                      labelText: 'Email (optional)',
                      prefixIcon: Icon(Icons.mail_outline_rounded),
                    ),
                    validator: (v) => Validators.email(v, optional: true),
                  ),
                ],
              ),
              FormSection(
                title: 'Business',
                children: [
                  TextFormField(
                    controller: _business,
                    enabled: !_saving,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Business name',
                      prefixIcon: Icon(Icons.storefront_outlined),
                    ),
                    validator: (v) =>
                        Validators.required(v, 'the business name'),
                  ),
                  TextFormField(
                    controller: _city,
                    enabled: !_saving,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'City (optional)',
                      prefixIcon: Icon(Icons.location_on_outlined),
                    ),
                  ),
                  _PlanPicker(
                    selected: _plan,
                    onChanged: _saving
                        ? null
                        : (p) => setState(() {
                            _plan = p;
                            _dirty = true;
                          }),
                  ),
                ],
              ),
              FormSection(
                title: 'Notes',
                children: [
                  TextFormField(
                    controller: _notes,
                    enabled: !_saving,
                    minLines: 3,
                    maxLines: 5,
                    maxLength: 300,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      hintText:
                          'Anything that helps us — needs, best time to call…',
                      alignLabelWithHint: true,
                    ),
                  ),
                ],
              ),
              _ConsentTile(
                value: _consent,
                showError: _submitted && !_consent,
                onChanged: _saving
                    ? null
                    : (v) => setState(() {
                        _consent = v;
                        _dirty = true;
                      }),
              ),
              const SizedBox(height: AppSpacing.xl),
              PrimaryButton(
                label: 'Save lead',
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

class _PlanPicker extends StatelessWidget {
  const _PlanPicker({required this.selected, required this.onChanged});

  final Plan? selected;
  final ValueChanged<Plan?>? onChanged;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final options = <(Plan?, String)>[
      (null, 'Not sure'),
      for (final p in Plan.values) (p, p.label),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Interested plan', style: text.bodyMedium),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (final (plan, label) in options)
              AppChoicePill(
                label: label,
                selected: selected == plan,
                onTap: onChanged == null ? null : () => onChanged!(plan),
              ),
          ],
        ),
      ],
    );
  }
}

class _ConsentTile extends StatelessWidget {
  const _ConsentTile({
    required this.value,
    required this.showError,
    required this.onChanged,
  });

  final bool value;
  final bool showError;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: onChanged == null ? null : () => onChanged!(!value),
          borderRadius: AppRadius.control,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: value,
                onChanged: onChanged == null
                    ? null
                    : (v) => onChanged!(v ?? false),
                isError: showError,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 12, right: 8),
                  child: Text(
                    'This person agreed to be contacted by GrowthX.',
                    style: text.bodyMedium?.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (showError)
          Padding(
            padding: const EdgeInsets.only(left: 48),
            child: Text(
              'Please confirm before saving',
              style: text.bodySmall?.copyWith(color: AppColors.danger),
            ),
          ),
      ],
    );
  }
}
