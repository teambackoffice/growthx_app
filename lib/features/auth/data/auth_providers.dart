import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Dummy authentication. Any well-formed email + 6-char password signs in,
/// except the password "wrongpass", which demonstrates the error state.
final authProvider = NotifierProvider<AuthNotifier, bool>(AuthNotifier.new);

class AuthException implements Exception {
  const AuthException(this.message);

  final String message;
}

class AuthNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  Future<void> signIn({required String email, required String password}) async {
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (password == 'wrongpass') {
      throw const AuthException(
        'That email and password don\'t match. Please try again.',
      );
    }
    state = true;
  }

  Future<void> sendPasswordReset(String email) async {
    await Future<void>.delayed(const Duration(milliseconds: 900));
  }

  void signOut() => state = false;
}
