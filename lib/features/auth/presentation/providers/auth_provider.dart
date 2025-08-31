import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:make_your_meal/features/auth/domain/models/user_model.dart';
import 'package:make_your_meal/features/auth/domain/repositories/auth_repository.dart';
import 'package:make_your_meal/features/auth/data/repositories/firebase_auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return FirebaseAuthRepository();
});

final authStateProvider = StreamProvider<UserModel?>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return authRepository.authStateChanges;
});

final authViewModelProvider = StateNotifierProvider<AuthViewModel, AuthState>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return AuthViewModel(authRepository);
});

class AuthState {
  final bool isLoading;
  final String? error;

  const AuthState({
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class AuthViewModel extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;

  AuthViewModel(this._authRepository) : super(const AuthState());

  Future<void> signIn(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _authRepository.signInWithEmailAndPassword(email, password);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> signUp(String email, String password, String? displayName) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _authRepository.signUpWithEmailAndPassword(email, password, displayName);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> signOut() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _authRepository.signOut();
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}