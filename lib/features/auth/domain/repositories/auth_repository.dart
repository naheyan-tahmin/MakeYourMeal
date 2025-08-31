import 'package:make_your_meal/features/auth/domain/models/user_model.dart';

abstract class AuthRepository {
  Stream<UserModel?> get authStateChanges;
  Future<UserModel> signInWithEmailAndPassword(String email, String password);
  Future<UserModel> signUpWithEmailAndPassword(String email, String password, String? displayName);
  Future<void> signOut();
}