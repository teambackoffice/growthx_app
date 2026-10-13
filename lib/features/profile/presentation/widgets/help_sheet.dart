import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';

const _faqs = [
  (
    'When do I get paid?',
    'Approved commissions are paid to your bank account on the 15th of every '
        'month.',
  ),
  (
    'Why is a commission "under review"?',
    'New commissions are held for 30 days in case the customer asks for a '
        'refund. After that they\'re approved automatically.',
  ),
  (
    'How is a customer linked to me?',
    'Anyone who signs up through your referral link, QR code, campaign link '
        'or a lead you added is credited to you for 90 days.',
  ),
  (
    'What happens if a payment is overdue?',
    'Your commission for that customer is put on hold until they pay. A quick '
        'reminder from you often helps.',
  ),
  (
    'How do I change my bank account?',
    'For your security, bank details can only be changed by partner support. '
        'Contact us from the More tab.',
  ),
];

class HelpSheet extends StatelessWidget {
  const HelpSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      maxChildSize: 0.92,
      builder: (context, controller) => ListView(
        controller: controller,
        padding: const EdgeInsets.fromLTRB(8, 0, 8, 24),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, AppSpacing.sm),
            child: Text(
              'Frequently asked questions',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          for (final (q, a) in _faqs)
            Theme(
              data: Theme.of(context)
                  .copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                title: Text(q, style: Theme.of(context).textTheme.titleSmall),
                childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                expandedAlignment: Alignment.centerLeft,
                children: [
                  Text(a, style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
