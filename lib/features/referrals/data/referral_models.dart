class Campaign {
  const Campaign({
    required this.id,
    required this.name,
    required this.description,
    required this.code,
    required this.offer,
    required this.startsOn,
    required this.endsOn,
    required this.clicks,
    required this.signups,
    required this.conversions,
  });

  final String id;
  final String name;
  final String description;
  final String code;

  /// What the customer gets, e.g. "30-day free trial + 20% off".
  final String offer;
  final DateTime startsOn;
  final DateTime endsOn;
  final int clicks;
  final int signups;
  final int conversions;

  bool get isActive => DateTime.now().isBefore(endsOn);

  String link(String partnerCode) =>
      'https://growthx.teambackoffice.com/r/$partnerCode?c=$code';
}

class ReferralStats {
  const ReferralStats({
    required this.clicks,
    required this.signups,
    required this.conversions,
  });

  final int clicks;
  final int signups;
  final int conversions;

  double get conversionRate => signups == 0 ? 0 : conversions / signups;
}
