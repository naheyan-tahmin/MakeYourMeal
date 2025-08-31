import 'package:firebase_auth/firebase_auth.dart';
import 'package:make_your_meal/features/auth/domain/models/user_model.dart';
import 'package:make_your_meal/features/auth/domain/repositories/auth_repository.dart';

class FirebaseAuthRepository implements AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Stream<UserModel?> get authStateChanges {
    return _auth.authStateChanges().map((user) {
      return user != null ? _mapFirebaseUserToUserModel(user) : null;
    });
  }

  @override
  Future<UserModel> signInWithEmailAndPassword(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return _mapFirebaseUserToUserModel(credential.user!);
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseException(e);
    }
  }

  @override
  Future<UserModel> signUpWithEmailAndPassword(
    String email,
    String password,
    String? displayName,
  ) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user!;
      
      if (displayName != null && displayName.isNotEmpty) {
        await user.updateDisplayName(displayName);
        await user.reload();
      }

      final userModel = _mapFirebaseUserToUserModel(user);
      
      return userModel;
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseException(e);
    }
  }

  @override
  Future<void> signOut() async {
    await _auth.signOut();
  }

  UserModel _mapFirebaseUserToUserModel(User user) {
    return UserModel(
      uid: user.uid,
      email: user.email!,
      displayName: user.displayName,
      photoURL: user.photoURL,
      createdAt: user.metadata.creationTime ?? DateTime.now(),
    );
  }

  String _mapFirebaseException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email address';
      case 'wrong-password':
        return 'Wrong password provided';
      case 'email-already-in-use':
        return 'An account already exists with this email address';
      case 'weak-password':
        return 'Password is too weak';
      case 'invalid-email':
        return 'Email address is invalid';
      case 'user-disabled':
        return 'This user account has been disabled';
      case 'too-many-requests':
        return 'Too many requests. Please try again later';
      default:
        return e.message ?? 'An unknown error occurred';
    }
  }
}