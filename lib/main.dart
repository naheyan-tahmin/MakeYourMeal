

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
  
  // REMOVED: Don't wait for authStateChanges().first as it can cause issues
  // This was causing the authentication flow problems
  
  runApp(const ProviderScope(child: MyApp()));
}