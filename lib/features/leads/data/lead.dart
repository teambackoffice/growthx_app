import '../../../core/widgets/status_badge.dart';
import '../../customers/data/customer.dart';

enum LeadStatus {
  newLead('New', BadgeTone.primary),
  contacted('Contacted', BadgeTone.info),
  demoScheduled('Demo scheduled', BadgeTone.warning),
  converted('Converted', BadgeTone.success),
  lost('Not interested', BadgeTone.neutral);

  const LeadStatus(this.label, this.tone);

  final String label;
  final BadgeTone tone;
}

class Lead {
  const Lead({
    required this.id,
    required this.contactName,
    required this.businessName,
    required this.phone,
    required this.createdOn,
    this.email = '',
    this.city = '',
    this.interestedPlan,
    this.notes = '',
    this.status = LeadStatus.newLead,
  });

  final String id;
  final String contactName;
  final String businessName;
  final String phone;
  final String email;
  final String city;
  final Plan? interestedPlan;
  final String notes;
  final LeadStatus status;
  final DateTime createdOn;

  Lead copyWith({LeadStatus? status}) => Lead(
    id: id,
    contactName: contactName,
    businessName: businessName,
    phone: phone,
    email: email,
    city: city,
    interestedPlan: interestedPlan,
    notes: notes,
    status: status ?? this.status,
    createdOn: createdOn,
  );
}
