import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/feedback.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/card_sliver_list.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/filter_chip_bar.dart';
import '../../../core/widgets/initials_avatar.dart';
import '../../../core/widgets/status_badge.dart';
import '../data/lead.dart';
import '../data/lead_providers.dart';

class LeadsScreen extends ConsumerStatefulWidget {
  const LeadsScreen({super.key});

  @override
  ConsumerState<LeadsScreen> createState() => _LeadsScreenState();
}

class _LeadsScreenState extends ConsumerState<LeadsScreen> {
  LeadStatus? _status;

  @override
  Widget build(BuildContext context) {
    final leads = ref.watch(leadsProvider);
    final visible = _status == null
        ? leads
        : leads.where((l) => l.status == _status).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('My leads')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.addLead),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add lead'),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 4, bottom: 12),
              child: FilterChipBar<LeadStatus?>(
                selected: _status,
                onSelected: (s) => setState(() => _status = s),
                options: [
                  FilterOption(null, 'All', count: leads.length),
                  for (final s in LeadStatus.values)
                    FilterOption(
                      s,
                      s.label,
                      count: leads.where((l) => l.status == s).length,
                    ),
                ],
              ),
            ),
          ),
          if (visible.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: leads.isEmpty
                  ? EmptyState(
                      icon: Icons.add_business_outlined,
                      title: 'No leads yet',
                      message:
                          'Add businesses you know and we\'ll follow up for '
                          'you.',
                      actionLabel: 'Add your first lead',
                      onAction: () => context.push(AppRoutes.addLead),
                    )
                  : EmptyState(
                      icon: Icons.filter_list_off_rounded,
                      title: 'Nothing here',
                      message: 'No leads are "${_status!.label}" right now.',
                      actionLabel: 'Show all leads',
                      onAction: () => setState(() => _status = null),
                    ),
            )
          else
            CardSliverList(
              itemCount: visible.length,
              itemBuilder: (context, i) => _LeadTile(lead: visible[i]),
            ),
          // Room so the FAB never covers the last row.
          const SliverToBoxAdapter(child: SizedBox(height: 96)),
        ],
      ),
    );
  }
}

class _LeadTile extends StatelessWidget {
  const _LeadTile({required this.lead});

  final Lead lead;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return InkWell(
      onTap: () => _showLeadSheet(context, lead.id),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            InitialsAvatar(name: lead.businessName),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lead.businessName,
                    style: text.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${lead.contactName} · ${Fmt.dayMonth(lead.createdOn)}',
                    style: text.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Flexible(
              child: StatusBadge(
                label: lead.status.label,
                tone: lead.status.tone,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void _showLeadSheet(BuildContext context, String leadId) {
  AppFeedback.sheet<void>(
    context,
    scrollControlled: true,
    builder: (context) => _LeadSheet(leadId: leadId),
  );
}

class _LeadSheet extends ConsumerWidget {
  const _LeadSheet({required this.leadId});

  final String leadId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lead = ref.watch(leadsProvider).firstWhere((l) => l.id == leadId);
    final text = Theme.of(context).textTheme;

    final details = <(IconData, String)>[
      (Icons.person_outline_rounded, lead.contactName),
      (Icons.phone_outlined, lead.phone),
      if (lead.email.isNotEmpty) (Icons.mail_outline_rounded, lead.email),
      if (lead.city.isNotEmpty) (Icons.location_on_outlined, lead.city),
      if (lead.interestedPlan != null)
        (
          Icons.workspace_premium_outlined,
          '${lead.interestedPlan!.label} plan',
        ),
      (Icons.event_outlined, 'Added ${Fmt.date(lead.createdOn)}'),
    ];

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(lead.businessName, style: text.titleLarge),
            const SizedBox(height: AppSpacing.md),
            for (final (icon, value) in details)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  children: [
                    Icon(icon, size: 18, color: AppColors.textTertiary),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        value,
                        style: text.bodyMedium?.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            if (lead.notes.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.surfaceMuted,
                  borderRadius: AppRadius.control,
                ),
                child: Text(lead.notes, style: text.bodyMedium),
              ),
            ],
            const SizedBox(height: AppSpacing.xl),
            Text('Status', style: text.titleSmall),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                for (final s in LeadStatus.values)
                  AppChoicePill(
                    label: s.label,
                    selected: lead.status == s,
                    onTap: () => ref
                        .read(leadsProvider.notifier)
                        .updateStatus(lead.id, s),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            FilledButton.icon(
              onPressed: () => AppFeedback.open(
                context,
                Uri(scheme: 'tel', path: lead.phone.replaceAll(' ', '')),
                value: lead.phone,
              ),
              icon: const Icon(Icons.call_outlined, size: 18),
              label: Text('Call ${lead.contactName.split(' ').first}'),
            ),
          ],
        ),
      ),
    );
  }
}
