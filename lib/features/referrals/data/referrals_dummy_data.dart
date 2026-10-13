import '../../../core/utils/demo_dates.dart';
import 'referral_models.dart';

const dummyReferralStats = ReferralStats(
  clicks: 342,
  signups: 18,
  conversions: 7,
);

final dummyCampaigns = <Campaign>[
  Campaign(
    id: 'cmp1',
    name: 'Diwali Business Boost',
    description: 'Festive offer for retail and service businesses.',
    code: 'DIWALI25',
    offer: '30-day free trial + 25% off the first 3 months',
    startsOn: daysFromNow(-20),
    endsOn: daysFromNow(24),
    clicks: 186,
    signups: 9,
    conversions: 3,
  ),
  Campaign(
    id: 'cmp2',
    name: 'Clinic Starter Pack',
    description: 'For clinics and healthcare practices.',
    code: 'CLINIC10',
    offer: 'Free onboarding call + 10% off yearly plans',
    startsOn: daysFromNow(-45),
    endsOn: daysFromNow(60),
    clicks: 74,
    signups: 4,
    conversions: 2,
  ),
  Campaign(
    id: 'cmp3',
    name: 'Onam Special',
    description: 'Seasonal campaign for Kerala businesses.',
    code: 'ONAM24',
    offer: '45-day free trial',
    startsOn: daysFromNow(-80),
    endsOn: daysFromNow(-30),
    clicks: 212,
    signups: 11,
    conversions: 5,
  ),
];
