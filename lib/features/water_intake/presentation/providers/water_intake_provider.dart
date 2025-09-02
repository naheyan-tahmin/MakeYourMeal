

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:make_your_meal/features/water_intake/domain/models/water_intake_model.dart';
import 'package:make_your_meal/features/water_intake/domain/repositories/water_intake_repository.dart';
import 'package:make_your_meal/features/water_intake/data/repositories/local_water_intake_repository.dart';

final waterIntakeRepositoryProvider = Provider<WaterIntakeRepository>((ref) {
  return LocalWaterIntakeRepository();
});

final waterIntakeProvider = StateNotifierProvider<WaterIntakeViewModel, WaterIntakeState>((ref) {
  final repository = ref.watch(waterIntakeRepositoryProvider);
  return WaterIntakeViewModel(repository);
});

final todayWaterIntakeProvider = FutureProvider.family<WaterIntakeModel?, String>((ref, userId) {
  final repository = ref.watch(waterIntakeRepositoryProvider);
  return repository.getTodayWaterIntake(userId);
});

final waterGoalProvider = FutureProvider.family<WaterGoalModel, String>((ref, userId) {
  final repository = ref.watch(waterIntakeRepositoryProvider);
  return repository.getWaterGoal(userId);
});

class WaterIntakeState {
  final WaterIntakeModel? todayIntake;
  final WaterGoalModel? goal;
  final bool isLoading;
  final String? error;

  const WaterIntakeState({
    this.todayIntake,
    this.goal,
    this.isLoading = false,
    this.error,
  });

  WaterIntakeState copyWith({
    WaterIntakeModel? todayIntake,
    WaterGoalModel? goal,
    bool? isLoading,
    String? error,
  }) {
    return WaterIntakeState(
      todayIntake: todayIntake ?? this.todayIntake,
      goal: goal ?? this.goal,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  double get progressPercentage {
    if (todayIntake == null || goal == null) return 0.0;
    return (todayIntake!.totalIntake / goal!.dailyGoalMl).clamp(0.0, 1.0);
  }

  double get remainingWater {
    if (todayIntake == null || goal == null) return 2000.0;
    final remaining = goal!.dailyGoalMl - todayIntake!.totalIntake;
    return remaining > 0 ? remaining : 0.0;
  }

  String get motivationalMessage {
    final percentage = progressPercentage;
    
    if (percentage >= 1.0) {
      return "Hydration goal achieved! Keep it up!";
    } else if (percentage >= 0.8) {
      return "Almost there! You're doing great!";
    } else if (percentage >= 0.5) {
      return "Halfway to your goal. Keep drinking!";
    } else if (percentage >= 0.3) {
      return "Good start! Your body will thank you.";
    } else {
      return "Stay hydrated, stay healthy!";
    }
  }

  String get inspirationalQuote {
    final quotes = [
      "Water is life, and clean water means health.",
      "Stay hydrated, stay healthy, stay happy.",
      "Your body is 60% water. Keep it flowing.",
      "Hydration is the foundation of good health.",
      "Every sip counts towards a healthier you.",
      "Water: the most important nutrient.",
      "Drink water like your life depends on it.",
    ];
    final index = DateTime.now().day % quotes.length;
    return quotes[index];
  }
}

class WaterIntakeViewModel extends StateNotifier<WaterIntakeState> {
  final WaterIntakeRepository _repository;

  WaterIntakeViewModel(this._repository) : super(const WaterIntakeState());

  Future<void> loadTodayData(String userId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final todayIntake = await _repository.getTodayWaterIntake(userId);
      final goal = await _repository.getWaterGoal(userId);
      state = state.copyWith(
        todayIntake: todayIntake,
        goal: goal,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> addWaterIntake(String userId, double amountMl) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.addManualWaterIntake(userId, amountMl);
      await loadTodayData(userId);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> setWaterGoal(String userId, double dailyGoalMl) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.setWaterGoal(userId, dailyGoalMl);
      await loadTodayData(userId);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}