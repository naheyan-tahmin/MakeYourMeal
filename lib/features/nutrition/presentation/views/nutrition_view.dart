

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:make_your_meal/features/nutrition/presentation/providers/nutrition_provider.dart';
import 'package:make_your_meal/features/nutrition/domain/models/nutrition_goal_model.dart';
import 'package:make_your_meal/features/auth/presentation/providers/auth_provider.dart';

class NutritionView extends ConsumerStatefulWidget {
  const NutritionView({super.key});

  @override
  ConsumerState<NutritionView> createState() => _NutritionViewState();
}

class _NutritionViewState extends ConsumerState<NutritionView> {
  bool _showGoalEdit = false;
  final _caloriesController = TextEditingController();
  final _proteinController = TextEditingController();
  final _carbsController = TextEditingController();
  final _fatController = TextEditingController();
  final _fiberController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(authStateProvider).value;
      if (user != null) {
        ref.read(nutritionProvider.notifier).loadUserNutritionData(user.uid);
      }
    });
  }

  @override
  void dispose() {
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    _fiberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider).value;
    final nutritionProgress = ref.watch(nutritionProgressProvider(user?.uid ?? ''));
    final todayNutrition = ref.watch(todayNutritionProvider(user?.uid ?? ''));
    final nutritionGoal = ref.watch(nutritionGoalProvider(user?.uid ?? ''));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nutrition Tracker'),
        backgroundColor: Colors.green.shade50,
        foregroundColor: Colors.green.shade800,
        actions: [
          IconButton(
            icon: Icon(_showGoalEdit ? Icons.close : Icons.settings),
            onPressed: () {
              setState(() => _showGoalEdit = !_showGoalEdit);
              if (_showGoalEdit) {
                _populateControllers();
              }
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.green.shade50,
              Colors.white,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Today's Summary Card
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      colors: [Colors.green.shade400, Colors.green.shade600],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.analytics, color: Colors.white, size: 32),
                          const SizedBox(width: 12),
                          Text(
                            'Today\'s Nutrition',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      todayNutrition.when(
                        data: (summary) => Text(
                          '${summary.totalCalories.toInt()} calories consumed from your planned meals',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                        loading: () => const Text(
                          'Calculating nutrition...',
                          style: TextStyle(color: Colors.white),
                        ),
                        error: (_, __) => const Text(
                          'Error calculating nutrition',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              if (_showGoalEdit) ...[
                // Goal Setting Form
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Set Your Daily Goals',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _caloriesController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'Calories',
                                  suffixText: 'kcal',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: _proteinController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'Protein',
                                  suffixText: 'g',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _carbsController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'Carbs',
                                  suffixText: 'g',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: _fatController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'Fat',
                                  suffixText: 'g',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.5,
                          child: TextFormField(
                            controller: _fiberController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Fiber',
                              suffixText: 'g',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _saveGoals,
                          child: const Text('Save Goals'),
                        ),
                      ],
                    ),
                  ),
                ),
              ] else ...[
                // Nutrition Progress Display
                Text(
                  'Macro Progress',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                
                Expanded(
                  child: nutritionGoal.when(
                    data: (goal) => todayNutrition.when(
                      data: (summary) => ListView(
                        children: [
                          _MacroProgressCard(
                            title: 'Calories',
                            current: summary.totalCalories,
                            target: goal.caloriesGoal,
                            unit: 'kcal',
                            color: Colors.orange,
                            icon: Icons.local_fire_department,
                          ),
                          const SizedBox(height: 12),
                          _MacroProgressCard(
                            title: 'Protein',
                            current: summary.totalProtein,
                            target: goal.proteinGoal,
                            unit: 'g',
                            color: Colors.red,
                            icon: Icons.fitness_center,
                          ),
                          const SizedBox(height: 12),
                          _MacroProgressCard(
                            title: 'Carbohydrates',
                            current: summary.totalCarbs,
                            target: goal.carbsGoal,
                            unit: 'g',
                            color: Colors.amber,
                            icon: Icons.grain,
                          ),
                          const SizedBox(height: 12),
                          _MacroProgressCard(
                            title: 'Fat',
                            current: summary.totalFat,
                            target: goal.fatGoal,
                            unit: 'g',
                            color: Colors.purple,
                            icon: Icons.opacity,
                          ),
                          const SizedBox(height: 12),
                          _MacroProgressCard(
                            title: 'Fiber',
                            current: summary.totalFiber,
                            target: goal.fiberGoal,
                            unit: 'g',
                            color: Colors.green,
                            icon: Icons.eco,
                          ),
                        ],
                      ),
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (_, __) => const Center(
                        child: Text('Error loading nutrition data'),
                      ),
                    ),
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (_, __) => const Center(
                      child: Text('Error loading nutrition goals'),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _populateControllers() {
    final user = ref.read(authStateProvider).value;
    if (user != null) {
      final goalAsync = ref.read(nutritionGoalProvider(user.uid));
      goalAsync.whenData((goal) {
        _caloriesController.text = goal.caloriesGoal.toInt().toString();
        _proteinController.text = goal.proteinGoal.toInt().toString();
        _carbsController.text = goal.carbsGoal.toInt().toString();
        _fatController.text = goal.fatGoal.toInt().toString();
        _fiberController.text = goal.fiberGoal.toInt().toString();
      });
    }
  }

  void _saveGoals() {
    final user = ref.read(authStateProvider).value;
    if (user == null) return;

    final calories = double.tryParse(_caloriesController.text);
    final protein = double.tryParse(_proteinController.text);
    final carbs = double.tryParse(_carbsController.text);
    final fat = double.tryParse(_fatController.text);
    final fiber = double.tryParse(_fiberController.text);

    if (calories != null && protein != null && carbs != null && fat != null && fiber != null) {
      final goal = NutritionGoalModel(
        userId: user.uid,
        caloriesGoal: calories,
        proteinGoal: protein,
        carbsGoal: carbs,
        fatGoal: fat,
        fiberGoal: fiber,
        updatedAt: DateTime.now(),
      );

      ref.read(nutritionProvider.notifier).updateNutritionGoal(goal);
      ref.invalidate(nutritionGoalProvider(user.uid));
      ref.invalidate(todayNutritionProvider(user.uid));
      setState(() => _showGoalEdit = false);
    }
  }
}

class _MacroProgressCard extends StatelessWidget {
  final String title;
  final double current;
  final double target;
  final String unit;
  final Color color;
  final IconData icon;

  const _MacroProgressCard({
    required this.title,
    required this.current,
    required this.target,
    required this.unit,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (current / target).clamp(0.0, 1.0);
    final remaining = (target - current).clamp(0.0, double.infinity);
    final isCompleted = current >= target;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${current.toInt()} / ${target.toInt()} $unit',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                if (isCompleted)
                  Icon(Icons.check_circle, color: color, size: 24)
                else
                  Text(
                    '${remaining.toInt()} $unit\nremaining',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.right,
                  ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: color.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 8,
            ),
            const SizedBox(height: 8),
            Text(
              '${(progress * 100).toInt()}% of daily goal',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}