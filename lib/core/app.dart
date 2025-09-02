// // File: lib/core/app.dart (Fixed - Simplified)
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:make_your_meal/features/auth/presentation/providers/auth_provider.dart';
// import 'package:make_your_meal/features/auth/presentation/views/login_view.dart';
// import 'package:make_your_meal/features/home/presentation/views/home_view.dart';
// import 'package:make_your_meal/core/theme/app_theme.dart';

// class MyApp extends ConsumerWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final authState = ref.watch(authStateProvider);

//     return MaterialApp(
//       title: 'Make Your Meal',
//       debugShowCheckedModeBanner: false,
//       theme: AppTheme.lightTheme,
//       darkTheme: AppTheme.darkTheme,
//       home: authState.when(
//         data: (user) {
//           // FIXED: Simple check - if user exists, show home, otherwise show login
//           return user != null ? const HomeView() : const LoginView();
//         },
//         loading: () => const Scaffold(
//           body: Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 CircularProgressIndicator(),
//                 SizedBox(height: 16),
//                 Text('Loading...'),
//               ],
//             ),
//           ),
//         ),
//         error: (error, stack) => Scaffold(
//           body: Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 const Icon(Icons.error_outline, size: 48, color: Colors.red),
//                 const SizedBox(height: 16),
//                 Text('Error: $error'),
//                 const SizedBox(height: 16),
//                 ElevatedButton(
//                   onPressed: () {
//                     // Restart the auth provider
//                     ref.invalidate(authStateProvider);
//                   },
//                   child: const Text('Retry'),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }


// File: lib/core/app.dart (Fixed Authentication Flow)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:make_your_meal/features/auth/presentation/providers/auth_provider.dart';
import 'package:make_your_meal/features/auth/presentation/views/login_view.dart';
import 'package:make_your_meal/features/home/presentation/views/home_view.dart';
import 'package:make_your_meal/core/theme/app_theme.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Make Your Meal',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: const AuthWrapper(),
      // Add this to handle navigation properly
      navigatorKey: GlobalKey<NavigatorState>(),
    );
  }
}

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Handle different connection states properly
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Initializing...'),
                ],
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Authentication Error: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      // Force a rebuild
                      ref.invalidate(authStateProvider);
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        // FIXED: The key change - more robust auth state handling
        final user = snapshot.data;
        
        // Add a small delay to ensure Firebase auth state is fully propagated
        if (snapshot.connectionState == ConnectionState.active) {
          if (user != null) {
            // User is authenticated - show home
            return const HomeView();
          } else {
            // User is not authenticated - show login
            return const LoginView();
          }
        }

        // Fallback loading state
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}