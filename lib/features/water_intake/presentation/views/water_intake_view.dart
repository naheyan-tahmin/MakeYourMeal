// File: lib/features/water_intake/presentation/views/simple_water_intake_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:make_your_meal/features/auth/presentation/providers/auth_provider.dart';

// Simple state provider for water intake
final waterIntakeStateProvider = StateNotifierProvider<SimpleWaterIntakeNotifier, SimpleWaterIntakeState>((ref) {
  return SimpleWaterIntakeNotifier();
});

class SimpleWaterIntakeState {
  final double todayIntake;
  final double dailyGoal;
  final bool isLoading;

  SimpleWaterIntakeState({
    this.todayIntake = 0,
    this.dailyGoal = 2000,
    this.isLoading = false,
  });

  SimpleWaterIntakeState copyWith({
    double? todayIntake,
    double? dailyGoal,
    bool? isLoading,
  }) {
    return SimpleWaterIntakeState(
      todayIntake: todayIntake ?? this.todayIntake,
      dailyGoal: dailyGoal ?? this.dailyGoal,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  double get progressPercentage => (todayIntake / dailyGoal).clamp(0.0, 1.0);
  double get remainingWater => (dailyGoal - todayIntake).clamp(0.0, double.infinity);

  String get motivationalMessage {
    final percentage = progressPercentage;
    if (percentage >= 1.0) return "Hydration goal achieved! Keep it up!";
    if (percentage >= 0.8) return "Almost there! You're doing great!";
    if (percentage >= 0.5) return "Halfway to your goal. Keep drinking!";
    if (percentage >= 0.3) return "Good start! Your body will thank you.";
    return "Stay hydrated, stay healthy!";
  }

  String get inspirationalQuote {
    final quotes = [
      "Water is life, and clean water means health.",
      "Stay hydrated, stay healthy, stay happy.",
      "Your body is 60% water. Keep it flowing.",
      "Hydration is the foundation of good health.",
      "Every sip counts towards a healthier you.",
    ];
    return quotes[DateTime.now().day % quotes.length];
  }
}

class SimpleWaterIntakeNotifier extends StateNotifier<SimpleWaterIntakeState> {
  SimpleWaterIntakeNotifier() : super(SimpleWaterIntakeState());

  Future<void> loadTodayData(String userId) async {
    state = state.copyWith(isLoading: true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final today = DateTime.now();
      final dateKey = '${today.year}-${today.month}-${today.day}';
      
      final todayIntake = prefs.getDouble('water_intake_${userId}_$dateKey') ?? 0.0;
      final dailyGoal = prefs.getDouble('water_goal_$userId') ?? 2000.0;
      
      state = state.copyWith(
        todayIntake: todayIntake,
        dailyGoal: dailyGoal,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> addWaterIntake(String userId, double amountMl) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final today = DateTime.now();
      final dateKey = '${today.year}-${today.month}-${today.day}';
      
      final newIntake = state.todayIntake + amountMl;
      await prefs.setDouble('water_intake_${userId}_$dateKey', newIntake);
      
      state = state.copyWith(todayIntake: newIntake);
    } catch (e) {
      // Handle error silently for now
    }
  }

  Future<void> setWaterGoal(String userId, double goalMl) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('water_goal_$userId', goalMl);
      state = state.copyWith(dailyGoal: goalMl);
    } catch (e) {
      // Handle error silently for now
    }
  }
}

class SimpleWaterIntakeView extends ConsumerStatefulWidget {
  const SimpleWaterIntakeView({super.key});

  @override
  ConsumerState<SimpleWaterIntakeView> createState() => _SimpleWaterIntakeViewState();
}

class _SimpleWaterIntakeViewState extends ConsumerState<SimpleWaterIntakeView> {
  final TextEditingController _goalController = TextEditingController();
  bool _showGoalEdit = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(authStateProvider).value;
      if (user != null) {
        ref.read(waterIntakeStateProvider.notifier).loadTodayData(user.uid);
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
    final waterState = ref.watch(waterIntakeStateProvider);

    if (waterState.isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Water Intake'),
          backgroundColor: Colors.blue.shade50,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Water Intake'),
        backgroundColor: Colors.blue.shade50,
        foregroundColor: Colors.blue.shade800,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade50, Colors.white],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Progress Card
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                          const Icon(Icons.water_drop, color: Colors.white, size: 32),
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
                      _buildProgressIndicator(waterState),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Quick Add Buttons
              Text(
                'Quick Add Water',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
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
              
              // Goal Setting
             Card(
  child: Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Daily Goal', style: Theme.of(context).textTheme.titleMedium),
            const Spacer(),
            TextButton(
              onPressed: () {
                setState(() {
                  _showGoalEdit = !_showGoalEdit;
                  if (_showGoalEdit) {
                    // Pre-populate the controller with current goal
                    _goalController.text = waterState.dailyGoal.toInt().toString();
                  }
                });
              },
              child: Text(_showGoalEdit ? 'Cancel' : 'Edit'),
            ),
          ],
        ),
        if (_showGoalEdit) ...[
          const SizedBox(height: 12),
          // Fixed layout - use Column instead of Row for better sizing
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: double.infinity, // Give the TextFormField explicit width
                child: TextFormField(
                  controller: _goalController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Daily Goal (ml)',
                    border: OutlineInputBorder(),
                    hintText: 'Enter your daily water goal',
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _updateGoal(user?.uid ?? ''),
                  child: const Text('Save Goal'),
                ),
              ),
            ],
          ),
        ] else ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.track_changes, size: 16, color: Colors.blue),
              const SizedBox(width: 8),
              Text(
                '${waterState.dailyGoal.toInt()}ml per day',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ],
    ),
  ),
), 
              
              const SizedBox(height: 20),
              
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

  Widget _buildProgressIndicator(SimpleWaterIntakeState state) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 120,
              height: 120,
              child: CircularProgressIndicator(
                value: state.progressPercentage,
                strokeWidth: 8,
                backgroundColor: Colors.white24,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            Column(
              children: [
                Text(
                  '${state.todayIntake.toInt()}ml',
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  '/ ${state.dailyGoal.toInt()}ml',
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          state.remainingWater > 0 
            ? '${(state.remainingWater / 1000).toStringAsFixed(1)}L more to go!'
            : 'Goal achieved! 🎉',
          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Text(
          state.motivationalMessage,
          style: const TextStyle(color: Colors.white70, fontSize: 14),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  void _addWater(String userId, double amount) {
    ref.read(waterIntakeStateProvider.notifier).addWaterIntake(userId, amount);
  }
  void _updateGoal(String userId) {
  final text = _goalController.text.trim();
  if (text.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please enter a valid goal amount')),
    );
    return;
  }
  
  final amount = double.tryParse(text);
  if (amount != null && amount > 0) {
    ref.read(waterIntakeStateProvider.notifier).setWaterGoal(userId, amount);
    setState(() => _showGoalEdit = false);
    _goalController.clear();
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please enter a valid number greater than 0')),
    );
  }
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
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color, width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}