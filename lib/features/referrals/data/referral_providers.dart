import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'referral_models.dart';
import 'referrals_dummy_data.dart';

final referralStatsProvider = Provider<ReferralStats>(
  (ref) => dummyReferralStats,
);

final campaignsProvider = Provider<List<Campaign>>((ref) => dummyCampaigns);
