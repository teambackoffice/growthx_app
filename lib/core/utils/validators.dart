/// Form validators returning user-facing messages.
abstract final class Validators {
  static final _email = RegExp(r'^[\w.+-]+@[\w-]+(\.[\w-]+)+$');

  static String? required(String? value, String field) =>
      (value == null || value.trim().isEmpty) ? 'Enter $field' : null;

  static String? email(String? value, {bool optional = false}) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return optional ? null : 'Enter your email address';
    return _email.hasMatch(v)
        ? null
        : 'Enter a valid email, like name@company.com';
  }

  /// Indian mobile numbers: 10 digits starting 6–9, optional +91 / 0 prefix.
  static String? phone(String? value) {
    final digits = (value ?? '').replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return 'Enter a mobile number';
    final local = digits.length > 10
        ? digits.substring(digits.length - 10)
        : digits;
    final validPrefix =
        digits.length == 10 ||
        (digits.length == 12 && digits.startsWith('91')) ||
        (digits.length == 11 && digits.startsWith('0'));
    if (!validPrefix || !RegExp(r'^[6-9]\d{9}$').hasMatch(local)) {
      return 'Enter a valid 10-digit mobile number';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Enter your password';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }
}
