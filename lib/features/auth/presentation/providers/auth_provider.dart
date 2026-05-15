import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final authStateProvider = StreamProvider<AuthState>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return authRepository.authStateChanges;
});

final loginControllerProvider = StateNotifierProvider<LoginController, AsyncValue<void>>((ref) {
  return LoginController(ref.watch(authRepositoryProvider));
});

class LoginController extends StateNotifier<AsyncValue<void>> {
  final AuthRepository _authRepository;

  LoginController(this._authRepository) : super(const AsyncData(null));

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    try {
      await _authRepository.signInWithEmailPassword(email, password);
      
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
  
  Future<void> logout() async {
    await _authRepository.signOut();
  }
}
