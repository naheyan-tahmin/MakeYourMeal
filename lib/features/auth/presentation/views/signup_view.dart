// // File: lib/features/auth/presentation/views/signup_view.dart (Fixed)
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:make_your_meal/features/auth/presentation/providers/auth_provider.dart';
// import 'package:make_your_meal/features/auth/presentation/views/login_view.dart';
// import 'package:make_your_meal/features/auth/presentation/widgets/auth_text_field.dart';
// import 'package:make_your_meal/core/utils/validators.dart';

// class SignUpView extends ConsumerStatefulWidget {
//   const SignUpView({super.key});

//   @override
//   ConsumerState<SignUpView> createState() => _SignUpViewState();
// }

// class _SignUpViewState extends ConsumerState<SignUpView> {
//   final _formKey = GlobalKey<FormState>();
//   final _nameController = TextEditingController();
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   final _confirmPasswordController = TextEditingController();
//   bool _obscurePassword = true;
//   bool _obscureConfirmPassword = true;

//   @override
//   void dispose() {
//     _nameController.dispose();
//     _emailController.dispose();
//     _passwordController.dispose();
//     _confirmPasswordController.dispose();
//     super.dispose();
//   }

//   void _handleSignUp() {
//     if (_formKey.currentState!.validate()) {
//       ref.read(authViewModelProvider.notifier).signUp(
//         _emailController.text.trim(),
//         _passwordController.text,
//         _nameController.text.trim().isEmpty ? null : _nameController.text.trim(),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final authState = ref.watch(authViewModelProvider);

//     ref.listen<AuthState>(authViewModelProvider, (previous, next) {
//       if (next.error != null) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(next.error!),
//             backgroundColor: Colors.red,
//           ),
//         );
//         ref.read(authViewModelProvider.notifier).clearError();
//       }
//     });

//     // FIXED: Listen for successful signup completion
//     ref.listen<AuthState>(authViewModelProvider, (previous, next) {
//       // Check if signup was successful (loading changed from true to false with no error)
//       if (previous?.isLoading == true && 
//           next.isLoading == false && 
//           next.error == null) {
        
//         // Show success message
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Account created successfully! Please log in with your credentials.'),
//             backgroundColor: Colors.green,
//             duration: const Duration(seconds: 3),
//           ),
//         );
        
//         // Navigate to login page after a short delay
//         Future.delayed(const Duration(milliseconds: 500), () {
//           if (mounted) {
//             Navigator.pushReplacement(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => const LoginView(),
//               ),
//             );
//           }
//         });
//       }
//     });

//     return Scaffold(
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.all(24.0),
//           child: Form(
//             key: _formKey,
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: [
//                 Icon(
//                   Icons.restaurant_menu,
//                   size: 80,
//                   color: Theme.of(context).colorScheme.primary,
//                 ),
//                 const SizedBox(height: 16),
//                 Text(
//                   'Create Account',
//                   style: Theme.of(context).textTheme.headlineMedium?.copyWith(
//                     fontWeight: FontWeight.bold,
//                     color: Theme.of(context).colorScheme.primary,
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   'Join us to start your healthy meal journey',
//                   style: Theme.of(context).textTheme.bodyMedium,
//                   textAlign: TextAlign.center,
//                 ),
//                 const SizedBox(height: 48),

//                 AuthTextField(
//                   controller: _nameController,
//                   labelText: 'Full Name (Optional)',
//                   prefixIcon: const Icon(Icons.person_outlined),
//                 ),
//                 const SizedBox(height: 16),

//                 AuthTextField(
//                   controller: _emailController,
//                   labelText: 'Email',
//                   keyboardType: TextInputType.emailAddress,
//                   validator: Validators.email,
//                   prefixIcon: const Icon(Icons.email_outlined),
//                 ),
//                 const SizedBox(height: 16),

//                 AuthTextField(
//                   controller: _passwordController,
//                   labelText: 'Password',
//                   obscureText: _obscurePassword,
//                   validator: Validators.password,
//                   prefixIcon: const Icon(Icons.lock_outlined),
//                   suffixIcon: IconButton(
//                     icon: Icon(
//                       _obscurePassword ? Icons.visibility : Icons.visibility_off,
//                     ),
//                     onPressed: () {
//                       setState(() {
//                         _obscurePassword = !_obscurePassword;
//                       });
//                     },
//                   ),
//                 ),
//                 const SizedBox(height: 16),

//                 AuthTextField(
//                   controller: _confirmPasswordController,
//                   labelText: 'Confirm Password',
//                   obscureText: _obscureConfirmPassword,
//                   validator: (value) => Validators.confirmPassword(value, _passwordController.text),
//                   prefixIcon: const Icon(Icons.lock_outlined),
//                   suffixIcon: IconButton(
//                     icon: Icon(
//                       _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
//                     ),
//                     onPressed: () {
//                       setState(() {
//                         _obscureConfirmPassword = !_obscureConfirmPassword;
//                       });
//                     },
//                   ),
//                 ),
//                 const SizedBox(height: 24),

//                 ElevatedButton(
//                   onPressed: authState.isLoading ? null : _handleSignUp,
//                   child: authState.isLoading
//                       ? const SizedBox(
//                           height: 20,
//                           width: 20,
//                           child: CircularProgressIndicator(strokeWidth: 2),
//                         )
//                       : const Text('Sign Up'),
//                 ),
//                 const SizedBox(height: 24),

//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     const Text('Already have an account? '),
//                     TextButton(
//                       onPressed: () {
//                         Navigator.pushReplacement(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => const LoginView(),
//                           ),
//                         );
//                       },
//                       child: const Text('Login'),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// File: lib/features/auth/presentation/views/signup_view.dart (Fixed)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:make_your_meal/features/auth/presentation/providers/auth_provider.dart';
import 'package:make_your_meal/features/auth/presentation/views/login_view.dart';
import 'package:make_your_meal/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:make_your_meal/core/utils/validators.dart';

class SignUpView extends ConsumerStatefulWidget {
  const SignUpView({super.key});

  @override
  ConsumerState<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends ConsumerState<SignUpView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleSignUp() {
    if (_formKey.currentState!.validate()) {
      ref.read(authViewModelProvider.notifier).signUp(
        _emailController.text.trim(),
        _passwordController.text,
        _nameController.text.trim().isEmpty ? null : _nameController.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);

    // FIXED: Listen for errors
    ref.listen<AuthState>(authViewModelProvider, (previous, next) {
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: Colors.red,
          ),
        );
        ref.read(authViewModelProvider.notifier).clearError();
      }
    });

    // FIXED: Listen for successful signup and navigate to login
    ref.listen<AuthState>(authViewModelProvider, (previous, next) {
      if (next.justSignedUp && !next.isLoading && next.error == null) {
        // Clear the signup flag
        ref.read(authViewModelProvider.notifier).clearSignupFlag();
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account created successfully! Please log in.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        
        // Navigate to login page
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginView()),
          (route) => false, // Remove all previous routes
        );
      }
    });

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(
                  Icons.restaurant_menu,
                  size: 80,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  'Create Account',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Join us to start your healthy meal journey',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),

                AuthTextField(
                  controller: _nameController,
                  labelText: 'Full Name (Optional)',
                  prefixIcon: const Icon(Icons.person_outlined),
                ),
                const SizedBox(height: 16),

                AuthTextField(
                  controller: _emailController,
                  labelText: 'Email',
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.email,
                  prefixIcon: const Icon(Icons.email_outlined),
                ),
                const SizedBox(height: 16),

                AuthTextField(
                  controller: _passwordController,
                  labelText: 'Password',
                  obscureText: _obscurePassword,
                  validator: Validators.password,
                  prefixIcon: const Icon(Icons.lock_outlined),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 16),

                AuthTextField(
                  controller: _confirmPasswordController,
                  labelText: 'Confirm Password',
                  obscureText: _obscureConfirmPassword,
                  validator: (value) => Validators.confirmPassword(value, _passwordController.text),
                  prefixIcon: const Icon(Icons.lock_outlined),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 24),

                ElevatedButton(
                  onPressed: authState.isLoading ? null : _handleSignUp,
                  child: authState.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Sign Up'),
                ),
                const SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Already have an account? '),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginView(),
                          ),
                        );
                      },
                      child: const Text('Login'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}