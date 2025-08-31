import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:make_your_meal/features/meal_plan/presentation/providers/meal_plan_provider.dart';
import 'package:make_your_meal/features/meal_plan/presentation/views/add_meal_to_plan_view.dart';
import 'package:make_your_meal/features/meal_plan/domain/models/meal_plan_model.dart';
import 'package:make_your_meal/features/auth/presentation/providers/auth_provider.dart';

class MealPlanView extends ConsumerStatefulWidget {
  const MealPlanView({super.key});

  @override
  ConsumerState<MealPlanView> createState() => _MealPlanViewState();
}

class _MealPlanViewState extends ConsumerState<MealPlanView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(authStateProvider).value;
      if (user != null) {
        ref.read(mealPlanProvider.notifier).loadUserMealPlans(user.uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider).value;
    final selectedDate = ref.watch(selectedDateProvider);
    final weeklyMealPlan = ref.watch(weeklyMealPlanProvider(user?.uid ?? ''));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meal Plan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.today),
            onPressed: () {
              ref.read(selectedDateProvider.notifier).state = DateTime.now();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Week Navigation
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () {
                    final newDate = selectedDate.subtract(const Duration(days: 7));
                    ref.read(selectedDateProvider.notifier).state = newDate;
                  },
                ),
                Expanded(
                  child: Text(
                    _getWeekRange(selectedDate),
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () {
                    final newDate = selectedDate.add(const Duration(days: 7));
                    ref.read(selectedDateProvider.notifier).state = newDate;
                  },
                ),
              ],
            ),
          ),

          // Weekly Meal Plan
          Expanded(
            child: weeklyMealPlan.when(
              data: (mealPlans) => _buildWeeklyView(context, ref, selectedDate, mealPlans),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('Error: $error')),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddMealToPlanView(selectedDate: selectedDate),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildWeeklyView(BuildContext context, WidgetRef ref, DateTime selectedDate, List<MealPlanModel> mealPlans) {
    final startOfWeek = selectedDate.subtract(Duration(days: selectedDate.weekday - 1));
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 7,
      itemBuilder: (context, index) {
        final date = startOfWeek.add(Duration(days: index));
        final dayMealPlan = mealPlans.where((plan) => 
            plan.date.year == date.year && 
            plan.date.month == date.month && 
            plan.date.day == date.day).firstOrNull;

        return _DayMealPlanCard(
          date: date,
          mealPlan: dayMealPlan,
          onAddMeal: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddMealToPlanView(selectedDate: date),
              ),
            );
          },
        );
      },
    );
  }

  String _getWeekRange(DateTime date) {
    final startOfWeek = date.subtract(Duration(days: date.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    
    return '${_formatDate(startOfWeek)} - ${_formatDate(endOfWeek)}';
  }

  String _formatDate(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                   'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}';
  }
}

class _DayMealPlanCard extends ConsumerWidget {
  final DateTime date;
  final MealPlanModel? mealPlan;
  final VoidCallback onAddMeal;

  const _DayMealPlanCard({
    required this.date,
    required this.mealPlan,
    required this.onAddMeal,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isToday = DateTime.now().difference(date).inDays == 0;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  _getDayName(date),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isToday ? Theme.of(context).colorScheme.primary : null,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${date.month}/${date.day}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const Spacer(),
                if (mealPlan != null)
                  Text(
                    '${mealPlan!.totalCalories.toInt()} cal',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: onAddMeal,
                ),
              ],
            ),
            
            if (mealPlan != null && mealPlan!.meals.isNotEmpty) ...[
              const SizedBox(height: 12),
              ...mealPlan!.meals.map((meal) => _MealItem(
                meal: meal,
                date: date,
              )),
            ] else ...[
              const SizedBox(height: 8),
              Text(
                'No meals planned',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getDayName(DateTime date) {
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return days[date.weekday - 1];
  }
}

class _MealItem extends ConsumerWidget {
  final PlannedMeal meal;
  final DateTime date;

  const _MealItem({required this.meal, required this.date});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getMealTypeColor(meal.mealType),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              meal.mealType.displayName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  meal.recipe.title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '${meal.servings} servings • ${meal.calories.toInt()} cal',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.remove_circle_outline),
            onPressed: () {
              final user = ref.read(authStateProvider).value;
              if (user != null) {
                ref.read(mealPlanProvider.notifier).removeMealFromPlan(
                  user.uid,
                  date,
                  meal.id,
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Color _getMealTypeColor(MealType mealType) {
    switch (mealType) {
      case MealType.breakfast:
        return Colors.orange;
      case MealType.lunch:
        return Colors.green;
      case MealType.dinner:
        return Colors.blue;
      case MealType.snack:
        return Colors.purple;
    }
  }
}
