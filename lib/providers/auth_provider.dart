import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/models.dart';
import '../services/auth_service.dart';

// Single instance providers
final authServiceProvider = Provider((ref) => AuthService());

// Auth state providers
final currentUserProvider = StateNotifierProvider<CurrentUserNotifier, User?>((ref) {
  return CurrentUserNotifier(ref.watch(authServiceProvider));
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(currentUserProvider) != null;
});

final authLoadingProvider = StateProvider<bool>((ref) => false);

class CurrentUserNotifier extends StateNotifier<User?> {
  final AuthService _authService;

  CurrentUserNotifier(this._authService) : super(null);

  Future<bool> login(String username, String password) async {
    final success = await _authService.login(username, password);
    if (success) {
      state = _authService.currentUser;
    }
    return success;
  }

  Future<void> logout() async {
    await _authService.logout();
    state = null;
  }

  Future<bool> tryAutoLogin() async {
    final success = await _authService.tryAutoLogin();
    if (success) {
      state = _authService.currentUser;
    }
    return success;
  }

  Future<bool> addEmergencyContact(String phoneNumber, String name, String priority) async {
    final success = await _authService.addEmergencyContact(phoneNumber, name, priority);
    if (success) {
      state = _authService.currentUser;
    }
    return success;
  }

  Future<bool> removeEmergencyContact(String contactId) async {
    final success = await _authService.removeEmergencyContact(contactId);
    if (success) {
      state = _authService.currentUser;
    }
    return success;
  }
}
