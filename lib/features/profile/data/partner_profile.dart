class PartnerProfile {
  const PartnerProfile({
    required this.name,
    required this.partnerId,
    required this.tier,
    required this.email,
    required this.phone,
    required this.city,
    required this.company,
    required this.gstin,
    required this.pan,
    required this.bankName,
    required this.accountNumber,
    required this.ifsc,
    required this.upiId,
    required this.memberSince,
    required this.referralCode,
  });

  final String name;
  final String partnerId;
  final String tier;
  final String email;
  final String phone;
  final String city;
  final String company;
  final String gstin;
  final String pan;
  final String bankName;
  final String accountNumber;
  final String ifsc;
  final String upiId;
  final DateTime memberSince;
  final String referralCode;

  String get firstName => name.split(' ').first;
  String get maskedAccount =>
      '•••• ${accountNumber.substring(accountNumber.length - 4)}';
  String get referralLink =>
      'https://growthx.teambackoffice.com/r/$referralCode';

  PartnerProfile copyWith({
    String? name,
    String? email,
    String? phone,
    String? city,
    String? company,
  }) {
    return PartnerProfile(
      name: name ?? this.name,
      partnerId: partnerId,
      tier: tier,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      city: city ?? this.city,
      company: company ?? this.company,
      gstin: gstin,
      pan: pan,
      bankName: bankName,
      accountNumber: accountNumber,
      ifsc: ifsc,
      upiId: upiId,
      memberSince: memberSince,
      referralCode: referralCode,
    );
  }
}

class NotificationPreferences {
  const NotificationPreferences({
    this.commissions = true,
    this.trialReminders = true,
    this.productUpdates = false,
  });

  final bool commissions;
  final bool trialReminders;
  final bool productUpdates;

  NotificationPreferences copyWith({
    bool? commissions,
    bool? trialReminders,
    bool? productUpdates,
  }) {
    return NotificationPreferences(
      commissions: commissions ?? this.commissions,
      trialReminders: trialReminders ?? this.trialReminders,
      productUpdates: productUpdates ?? this.productUpdates,
    );
  }
}
