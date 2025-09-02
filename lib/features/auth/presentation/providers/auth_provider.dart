import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:make_your_meal/features/auth/domain/models/user_model.dart';
import 'package:make_your_meal/features/auth/domain/repositories/auth_repository.dart';
import 'package:make_your_meal/features/auth/data/repositories/firebase_auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return FirebaseAuthRepository();
});

// FIXED: More robust auth state provider
final authStateProvider = StreamProvider<UserModel?>((ref) {
  return FirebaseAuth.instance.authStateChanges().map((user) {
    if (user != null) {
      return UserModel(
        uid: user.uid,
        email: user.email!,
        displayName: user.displayName,
        photoURL: user.photoURL,
        createdAt: user.metadata.creationTime ?? DateTime.now(),
      );
    }
    return null;
  });
});

final authViewModelProvider = StateNotifierProvider<AuthViewModel, AuthState>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return AuthViewModel(authRepository);
});

class AuthState {
  final bool isLoading;
  final String? error;
  final bool isSignUpSuccess; // Added to track signup success

  const AuthState({
    this.isLoading = false,
    this.error,
    this.isSignUpSuccess = false,
  });

  AuthState copyWith({
    bool? isLoading,
    String? error,
    bool? isSignUpSuccess,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isSignUpSuccess: isSignUpSuccess ?? this.isSignUpSuccess,
    );
  }
}

class AuthViewModel extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;

  AuthViewModel(this._authRepository) : super(const AuthState());

  Future<void> signIn(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null, isSignUpSuccess: false);
    try {
      await _authRepository.signInWithEmailAndPassword(email, password);
      
      // FIXED: Add a small delay to ensure Firebase auth state propagates
      await Future.delayed(const Duration(milliseconds: 500));
      
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> signUp(String email, String password, String? displayName) async {
    state = state.copyWith(isLoading: true, error: null, isSignUpSuccess: false);
    try {
      await _authRepository.signUpWithEmailAndPassword(email, password, displayName);
      
      // FIXED: Mark signup as successful for proper UI handling
      state = state.copyWith(isLoading: false, isSignUpSuccess: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> signOut() async {
    state = state.copyWith(isLoading: true, error: null, isSignUpSuccess: false);
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

  void clearSignUpSuccess() {
    state = state.copyWith(isSignUpSuccess: false);
  }
}


