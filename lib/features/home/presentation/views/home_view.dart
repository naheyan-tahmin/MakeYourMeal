import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:make_your_meal/features/auth/presentation/providers/auth_provider.dart';

class HomeView extends ConsumerWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Make Your Meal'),
        actions: [
          PopupMenuButton(
            onSelected: (value) {
              if (value == 'logout') {
                ref.read(authViewModelProvider.notifier).signOut();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout),
                    SizedBox(width: 8),
                    Text('Logout'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.restaurant_menu,
              size: 100,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              'Welcome ${user?.displayName ?? user?.email ?? 'User'}!',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Your meal planning journey starts here',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      'Coming Soon Features:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text('• Recipe Management'),
                    const Text('• Weekly Meal Planner'),
                    const Text('• Calorie Tracking'),
                    const Text('• Water Intake Goals'),
                    const Text('• Nutritional Summary'),
                    const Text('• Recipe Feed & Favorites'),
                    const Text('• Export Grocery Lists'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}