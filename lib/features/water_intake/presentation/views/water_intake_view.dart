// File: lib/features/water_intake/presentation/views/water_intake_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:make_your_meal/features/water_intake/presentation/providers/water_intake_provider.dart';
import 'package:make_your_meal/features/auth/presentation/providers/auth_provider.dart';

class WaterIntakeView extends ConsumerStatefulWidget {
  const WaterIntakeView({super.key});

  @override
  ConsumerState<WaterIntakeView> createState() => _WaterIntakeViewState();
}

class _WaterIntakeViewState extends ConsumerState<WaterIntakeView> {
  final TextEditingController _goalController = TextEditingController();
  bool _showGoalEdit = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(authStateProvider).value;
      if (user != null) {
        ref.read(waterIntakeProvider.notifier).loadTodayData(user.uid);
      }
    });
  }

  @override
  void dispose() {
    _goalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider).value;
    final waterState = ref.watch(waterIntakeProvider);
    final todayIntakeAsync = ref.watch(todayWaterIntakeProvider(user?.uid ?? ''));
    final waterGoalAsync = ref.watch(waterGoalProvider(user?.uid ?? ''));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Water Intake'),
        backgroundColor: Colors.blue.shade50,
        foregroundColor: Colors.blue.shade800,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade50,
              Colors.white,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Progress Card
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
                      colors: [Colors.blue.shade400, Colors.blue.shade600],
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.water_drop, color: Colors.white, size: 32),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Today\'s Hydration',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Progress indicator
                      todayIntakeAsync.when(
                        data: (intake) => waterGoalAsync.when(
                          data: (goal) => _buildProgressIndicator(intake, goal, waterState),
                          loading: () => const CircularProgressIndicator(color: Colors.white),
                          error: (_, __) => const Text('Error loading goal', style: TextStyle(color: Colors.white)),
                        ),
                        loading: () => const CircularProgressIndicator(color: Colors.white),
                        error: (_, __) => const Text('Error loading intake', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Quick Add Buttons
              Text(
                'Quick Add Water',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _QuickAddButton(
                    amount: 250,
                    label: '250ml\nGlass',
                    icon: Icons.local_drink,
                    color: Colors.blue,
                    onTap: () => _addWater(user?.uid ?? '', 250),
                  ),
                  _QuickAddButton(
                    amount: 500,
                    label: '500ml\nBottle',
                    icon: Icons.sports_bar,
                    color: Colors.cyan,
                    onTap: () => _addWater(user?.uid ?? '', 500),
                  ),
                  _QuickAddButton(
                    amount: 1000,
                    label: '1L\nBig Bottle',
                    icon: Icons.local_bar,
                    color: Colors.teal,
                    onTap: () => _addWater(user?.uid ?? '', 1000),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // Custom Amount
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        'Add Custom Amount',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Amount (ml)',
                                border: OutlineInputBorder(),
                              ),
                              onFieldSubmitted: (value) {
                                final amount = double.tryParse(value);
                                if (amount != null && amount > 0) {
                                  _addWater(user?.uid ?? '', amount);
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            onPressed: () => _showCustomAmountDialog(),
                            child: const Text('Add'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Goal Setting
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Daily Goal',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: () => setState(() => _showGoalEdit = !_showGoalEdit),
                            child: Text(_showGoalEdit ? 'Cancel' : 'Edit'),
                          ),
                        ],
                      ),
                      if (_showGoalEdit) ...[
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _goalController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'Daily Goal (ml)',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton(
                              onPressed: () => _updateGoal(user?.uid ?? ''),
                              child: const Text('Save'),
                            ),
                          ],
                        ),
                      ] else ...[
                        waterGoalAsync.when(
                          data: (goal) => Text(
                            '${goal.dailyGoalMl.toInt()}ml per day',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          loading: () => const Text('Loading...'),
                          error: (_, __) => const Text('Error loading goal'),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              
              const Spacer(),
              
              // Motivational Quote
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  children: [
                    Icon(Icons.format_quote, color: Colors.blue.shade600),
                    const SizedBox(height: 8),
                    Text(
                      waterState.inspirationalQuote,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontStyle: FontStyle.italic,
                        color: Colors.blue.shade800,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(intake, goal,WaterIntakeState waterState) {
    final progress = intake != null && goal != null ? 
        (intake.totalIntake / goal.dailyGoalMl).clamp(0.0, 1.0) : 0.0;
    final consumed = intake?.totalIntake ?? 0.0;
    final target = goal?.dailyGoalMl ?? 2000.0;
    final remaining = (target - consumed).clamp(0.0, double.infinity);

    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 120,
              height: 120,
              child: CircularProgressIndicator(
                value: progress,
                strokeWidth: 8,
                backgroundColor: Colors.white24,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            Column(
              children: [
                Text(
                  '${consumed.toInt()}ml',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '/ ${target.toInt()}ml',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (remaining > 0) ...[
          Text(
            '${(remaining / 1000).toStringAsFixed(1)}L more to go!',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ] else ...[
          const Text(
            'Goal achieved! 🎉',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
        const SizedBox(height: 8),
        Text(
          waterState.motivationalMessage,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  void _addWater(String userId, double amount) {
    ref.read(waterIntakeProvider.notifier).addWaterIntake(userId, amount);
    ref.invalidate(todayWaterIntakeProvider(userId));
  }

  void _updateGoal(String userId) {
    final amount = double.tryParse(_goalController.text);
    if (amount != null && amount > 0) {
      ref.read(waterIntakeProvider.notifier).setWaterGoal(userId, amount);
      ref.invalidate(waterGoalProvider(userId));
      setState(() => _showGoalEdit = false);
      _goalController.clear();
    }
  }

  void _showCustomAmountDialog() {
    final customController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Water'),
        content: TextFormField(
          controller: customController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Amount (ml)',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(customController.text);
              if (amount != null && amount > 0) {
                final user = ref.read(authStateProvider).value;
                _addWater(user?.uid ?? '', amount);
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}

class _QuickAddButton extends StatelessWidget {
  final double amount;
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickAddButton({
    required this.amount,
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 90,
        height: 90,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color, width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}