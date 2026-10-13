import '../../../core/utils/demo_dates.dart';
import '../../customers/data/customer.dart';
import 'lead.dart';

final dummyLeads = <Lead>[
  Lead(
    id: 'l01',
    contactName: 'Priya Krishnan',
    businessName: 'Krishna Silks',
    phone: '+91 98460 33412',
    email: 'priya@krishnasilks.in',
    city: 'Thrissur',
    interestedPlan: Plan.growth,
    notes: 'Runs 2 stores. Wants inventory + billing.',
    status: LeadStatus.demoScheduled,
    createdOn: daysFromNow(-2),
  ),
  Lead(
    id: 'l02',
    contactName: 'Nikhil George',
    businessName: 'George Auto Works',
    phone: '+91 94471 20987',
    city: 'Kottayam',
    interestedPlan: Plan.starter,
    status: LeadStatus.newLead,
    createdOn: daysFromNow(-1),
  ),
  Lead(
    id: 'l03',
    contactName: 'Shabna Ali',
    businessName: 'Pearl Beauty Studio',
    phone: '+91 90370 66521',
    email: 'shabna@pearlstudio.in',
    city: 'Kochi',
    status: LeadStatus.contacted,
    notes: 'Call back after 6 PM.',
    createdOn: daysFromNow(-5),
  ),
  Lead(
    id: 'l04',
    contactName: 'Ramesh Babu',
    businessName: 'Babu Traders',
    phone: '+91 97455 10234',
    city: 'Palakkad',
    interestedPlan: Plan.growth,
    status: LeadStatus.converted,
    createdOn: daysFromNow(-21),
  ),
  Lead(
    id: 'l05',
    contactName: 'Leena Joseph',
    businessName: 'Little Steps Play School',
    phone: '+91 95440 87120',
    city: 'Kochi',
    status: LeadStatus.lost,
    notes: 'Using a competitor, revisit next year.',
    createdOn: daysFromNow(-34),
  ),
];
