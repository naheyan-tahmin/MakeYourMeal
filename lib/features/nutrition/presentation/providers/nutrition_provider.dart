// File: lib/features/nutrition/presentation/providers/nutrition_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:make_your_meal/features/nutrition/domain/models/nutrition_goal_model.dart';
import 'package:make_your_meal/features/nutrition/domain/repositories/nutrition_repository.dart';
import 'package:make_your_meal/features/nutrition/data/repositories/local_nutrition_repository.dart';
import 'package:make_your_meal/features/meal_plan/presentation/providers/meal_plan_provider.dart';

// Repository provider
final nutritionRepositoryProvider = Provider<NutritionRepository>((ref) {
  return LocalNutritionRepository();
});

// StateNotifier provider for viewmodel + state
final nutritionProvider = StateNotifierProvider<NutritionViewModel, NutritionState>((ref) {
  final repository = ref.watch(nutritionRepositoryProvider);
  return NutritionViewModel(repository);
});

// Async providers for goal and daily summary
final nutritionGoalProvider = FutureProvider.family<NutritionGoalModel, String>((ref, userId) {
  final repository = ref.watch(nutritionRepositoryProvider);
  return repository.getNutritionGoal(userId);
});

final todayNutritionProvider = FutureProvider.family<DailyNutritionSummary, String>((ref, userId) async {
  final repository = ref.watch(nutritionRepositoryProvider);
  final mealPlanState = ref.watch(mealPlanProvider);
  final today = DateTime.now();
  
  return repository.calculateDailyNutrition(userId, today, mealPlanState.mealPlans);
});

// Provider to calculate progress
final nutritionProgressProvider = Provider.family<NutritionProgress, String>((ref, userId) {
  final goalAsync = ref.watch(nutritionGoalProvider(userId));
  final summaryAsync = ref.watch(todayNutritionProvider(userId));
  
  return goalAsync.when(
    data: (goal) => summaryAsync.when(
      data: (summary) => NutritionProgress.calculate(goal, summary),
      loading: () => NutritionProgress.empty(),
      error: (_, __) => NutritionProgress.empty(),
    ),
    loading: () => NutritionProgress.empty(),
    error: (_, __) => NutritionProgress.empty(),
  );
});

// --- Data classes ---

class NutritionProgress {
  final double caloriesProgress;
  final double proteinProgress;
  final double carbsProgress;
  final double fatProgress;
  final double fiberProgress;
  
  final double caloriesRemaining;
  final double proteinRemaining;
  final double carbsRemaining;
  final double fatRemaining;
  final double fiberRemaining;

  const NutritionProgress({
    required this.caloriesProgress,
    required this.proteinProgress,
    required this.carbsProgress,
    required this.fatProgress,
    required this.fiberProgress,
    required this.caloriesRemaining,
    required this.proteinRemaining,
    required this.carbsRemaining,
    required this.fatRemaining,
    required this.fiberRemaining,
  });

  static NutritionProgress calculate(NutritionGoalModel goal, DailyNutritionSummary summary) {
    return NutritionProgress(
      caloriesProgress: (summary.totalCalories / goal.caloriesGoal).clamp(0.0, 1.0),
      proteinProgress: (summary.totalProtein / goal.proteinGoal).clamp(0.0, 1.0),
      carbsProgress: (summary.totalCarbs / goal.carbsGoal).clamp(0.0, 1.0),
      fatProgress: (summary.totalFat / goal.fatGoal).clamp(0.0, 1.0),
      fiberProgress: (summary.totalFiber / goal.fiberGoal).clamp(0.0, 1.0),
      caloriesRemaining: (goal.caloriesGoal - summary.totalCalories).clamp(0.0, double.infinity),
      proteinRemaining: (goal.proteinGoal - summary.totalProtein).clamp(0.0, double.infinity),
      carbsRemaining: (goal.carbsGoal - summary.totalCarbs).clamp(0.0, double.infinity),
      fatRemaining: (goal.fatGoal - summary.totalFat).clamp(0.0, double.infinity),
      fiberRemaining: (goal.fiberGoal - summary.totalFiber).clamp(0.0, double.infinity),
    );
  }

  static NutritionProgress empty() {
    return const NutritionProgress(
      caloriesProgress: 0.0,
      proteinProgress: 0.0,
      carbsProgress: 0.0,
      fatProgress: 0.0,
      fiberProgress: 0.0,
      caloriesRemaining: 0.0,
      proteinRemaining: 0.0,
      carbsRemaining: 0.0,
      fatRemaining: 0.0,
      fiberRemaining: 0.0,
    );
  }
}

// --- State & ViewModel ---

class NutritionState {
  final NutritionGoalModel? goal;
  final DailyNutritionSummary? todaySummary;
  final bool isLoading;
  final String? error;

  const NutritionState({
    this.goal,
    this.todaySummary,
    this.isLoading = false,
    this.error,
  });

  NutritionState copyWith({
    NutritionGoalModel? goal,
    DailyNutritionSummary? todaySummary,
    bool? isLoading,
    String? error,
  }) {
    return NutritionState(
      goal: goal ?? this.goal,
      todaySummary: todaySummary ?? this.todaySummary,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class NutritionViewModel extends StateNotifier<NutritionState> {
  final NutritionRepository _repository;

  NutritionViewModel(this._repository) : super(const NutritionState());

  Future<void> loadUserNutritionData(String userId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final goal = await _repository.getNutritionGoal(userId);
      state = state.copyWith(goal: goal, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> updateNutritionGoal(NutritionGoalModel goal) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.setNutritionGoal(goal);
      state = state.copyWith(goal: goal, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}
