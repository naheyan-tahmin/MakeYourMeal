// File: lib/features/home/presentation/views/home_view.dart (Updated)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:make_your_meal/features/auth/presentation/providers/auth_provider.dart';
import 'package:make_your_meal/features/recipe/presentation/providers/recipe_provider.dart';
import 'package:make_your_meal/features/meal_plan/presentation/providers/meal_plan_provider.dart';
import 'package:make_your_meal/features/recipe/presentation/views/my_recipe_view.dart';
import 'package:make_your_meal/features/nutrition/presentation/providers/nutrition_provider.dart';
import 'package:make_your_meal/features/recipe/presentation/views/recipes_list_view.dart';
import 'package:make_your_meal/features/meal_plan/presentation/views/meal_plan_view.dart';
import 'package:make_your_meal/features/water_intake/presentation/views/water_intake_view.dart';
import 'package:make_your_meal/features/nutrition/presentation/views/nutrition_view.dart';
import 'package:make_your_meal/core/widgets/app_logo.dart';


class HomeView extends ConsumerStatefulWidget {
  const HomeView({super.key});

  @override
  ConsumerState<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends ConsumerState<HomeView> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const DashboardTab(),
    const RecipesListView(),
    const MealPlanView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu),
            label: 'Recipes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Meal Plan',
          ),
        ],
      ),
    );
  }
}

class DashboardTab extends ConsumerWidget {
  const DashboardTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value;
    final recipesState = ref.watch(recipesProvider);
    final mealPlanState = ref.watch(mealPlanProvider);

    // Calculate user-specific stats
    final userRecipes = recipesState.recipes.where((recipe) => recipe.authorId == user?.uid).toList();
    final userMealPlans = mealPlanState.mealPlans.where((plan) => plan.userId == user?.uid).toList();

    return Scaffold(
      appBar: AppBar(
        title: const  MakeYourMealLogo(
    fontSize: 22.0,
    showIcon: true,
  ),
  backgroundColor: Colors.transparent,
  elevation: 0,
  flexibleSpace: Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.green.shade50,
          Colors.white,
           ],
        ),
      ),
    ),
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome back, ${user?.displayName ?? user?.email.split('@')[0] ?? 'User'}!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              )
            ),
            const SizedBox(height: 24),
            
            // Updated Stats Cards with real data
            Row(
              children: [
                Expanded(
                  child: _DashboardCard(
                    title: 'My Recipes',
                    value: userRecipes.length.toString(),
                    icon: Icons.restaurant_menu,
                    color: Colors.orange,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MyRecipesView(),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _DashboardCard(
                    title: 'Meal Plans',
                    value: userMealPlans.length.toString(),
                    icon: Icons.calendar_month,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Water and Nutrition Summary Cards
            if (user != null) ...[
              Row(
                children: [
                  Expanded(
                    child: _WaterSummaryCard(userId: user.uid),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _NutritionSummaryCard(userId: user.uid),
                  ),
                ],
              ),
            ],
            
            const SizedBox(height: 24),
            
            // Quick Actions
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.2,
                children: [
                  _ActionCard(
                    title: 'Add Recipe',
                    icon: Icons.add_circle,
                    color: Colors.blue,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RecipesListView(),
                        ),
                      );
                    },
                  ),
                  _ActionCard(
                    title: 'Plan Meals',
                    icon: Icons.event_note,
                    color: Colors.purple,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MealPlanView(),
                        ),
                      );
                    },
                  ),
                  _ActionCard(
                    title: 'Water Goal',
                    icon: Icons.water_drop,
                    color: Colors.cyan,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SimpleWaterIntakeView(),
                        ),
                      );
                    },
                  ),
                  _ActionCard(
                    title: 'Nutrition',
                    icon: Icons.analytics,
                    color: Colors.green,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NutritionView(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _DashboardCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color, 
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    )
    );
  }
}

class _WaterSummaryCard extends ConsumerWidget {
  final String userId;

  const _WaterSummaryCard({required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final waterState = ref.watch(waterIntakeStateProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(Icons.water_drop, size: 32, color: Colors.blue),
            const SizedBox(height: 8),
            Text(
                    '${(waterState.progressPercentage * 100).toInt()}%',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),  
            const Text(
              'Water Goal',
              style: TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _NutritionSummaryCard extends ConsumerWidget {
  final String userId;

  const _NutritionSummaryCard({required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayNutrition = ref.watch(todayNutritionProvider(userId));
    final nutritionGoal = ref.watch(nutritionGoalProvider(userId));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(Icons.analytics, size: 32, color: Colors.green),
            const SizedBox(height: 8),
            todayNutrition.when(
              data: (summary) => nutritionGoal.when(
                data: (goal) {
                  final progress = (summary.totalCalories / goal.caloriesGoal).clamp(0.0, 1.0);
                  return Text(
                    '${summary.totalCalories.toInt()}',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  );
                },
                loading: () => const Text('--'),
                error: (_, __) => const Text('--'),
              ),
              loading: () => const Text('--'),
              error: (_, __) => const Text('--'),
            ),
            const Text(
              'Calories Today',
              style: TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}