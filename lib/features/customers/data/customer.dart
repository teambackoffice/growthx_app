import '../../../core/widgets/status_badge.dart';

enum SubscriptionStatus {
  active('Active', BadgeTone.success),
  trial('Trial', BadgeTone.info),
  pastDue('Payment due', BadgeTone.warning),
  cancelled('Cancelled', BadgeTone.neutral);

  const SubscriptionStatus(this.label, this.tone);

  final String label;
  final BadgeTone tone;
}

enum Plan {
  starter('Starter', 999),
  growth('Growth', 2499),
  pro('Pro', 4999);

  const Plan(this.label, this.monthlyPrice);

  final String label;
  final int monthlyPrice;
}

class Customer {
  const Customer({
    required this.id,
    required this.businessName,
    required this.contactName,
    required this.phone,
    required this.email,
    required this.city,
    required this.plan,
    required this.status,
    required this.joinedOn,
    required this.source,
    this.trialEndsOn,
    this.renewsOn,
  });

  final String id;
  final String businessName;
  final String contactName;
  final String phone;
  final String email;
  final String city;
  final Plan plan;
  final SubscriptionStatus status;
  final DateTime joinedOn;
  final String source;
  final DateTime? trialEndsOn;
  final DateTime? renewsOn;
}
