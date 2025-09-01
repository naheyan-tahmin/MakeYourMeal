// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:make_your_meal/core/app.dart';
// import 'package:make_your_meal/core/firebase_options.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
  
//   // FIXED: Ensure Firebase is fully initialized before starting the app
//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );
  
//   // FIXED: Wait for Firebase Auth to initialize its state
//   // This prevents the first-launch authentication issues
//   await FirebaseAuth.instance.authStateChanges().first;
  
//   runApp(const ProviderScope(child: MyApp()));
// }

// File: lib/main.dart (Fixed - Simplified)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:make_your_meal/core/app.dart';
import 'package:make_your_meal/core/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // FIXED: Remove the auth state wait - let the app handle auth state naturally
  runApp(const ProviderScope(child: MyApp()));
}