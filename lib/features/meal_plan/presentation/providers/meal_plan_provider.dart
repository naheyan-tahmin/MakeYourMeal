import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:make_your_meal/features/meal_plan/domain/models/meal_plan_model.dart';
import 'package:make_your_meal/features/meal_plan/domain/repositories/meal_plan_repository.dart';
import 'package:make_your_meal/features/meal_plan/data/repositories/local_meal_plan_repository.dart';

final mealPlanRepositoryProvider = Provider<MealPlanRepository>((ref) {
  return LocalMealPlanRepository();
});

final mealPlanProvider = StateNotifierProvider<MealPlanViewModel, MealPlanState>((ref) {
  final repository = ref.watch(mealPlanRepositoryProvider);
  return MealPlanViewModel(repository);
});

final selectedDateProvider = StateProvider<DateTime>((ref) => DateTime.now());

final weeklyMealPlanProvider = FutureProvider.family<List<MealPlanModel>, String>((ref, userId) {
  final repository = ref.watch(mealPlanRepositoryProvider);
  final selectedDate = ref.watch(selectedDateProvider);
  final startOfWeek = selectedDate.subtract(Duration(days: selectedDate.weekday - 1));
  return repository.getWeeklyMealPlan(userId, startOfWeek);
});

class MealPlanState {
  final List<MealPlanModel> mealPlans;
  final bool isLoading;
  final String? error;

  const MealPlanState({
    this.mealPlans = const [],
    this.isLoading = false,
    this.error,
  });

  MealPlanState copyWith({
    List<MealPlanModel>? mealPlans,
    bool? isLoading,
    String? error,
  }) {
    return MealPlanState(
      mealPlans: mealPlans ?? this.mealPlans,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class MealPlanViewModel extends StateNotifier<MealPlanState> {
  final MealPlanRepository _repository;

  MealPlanViewModel(this._repository) : super(const MealPlanState());

  Future<void> loadUserMealPlans(String userId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final mealPlans = await _repository.getUserMealPlans(userId);
      state = state.copyWith(mealPlans: mealPlans, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> addMealToPlan(String userId, DateTime date, PlannedMeal meal) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final existingPlan = await _repository.getMealPlanByDate(userId, date);
      
      if (existingPlan != null) {
        final updatedMeals = [...existingPlan.meals, meal];
        final updatedPlan = existingPlan.copyWith(meals: updatedMeals);
        await _repository.updateMealPlan(updatedPlan);
      } else {
        final newPlan = MealPlanModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          userId: userId,
          date: date,
          meals: [meal],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await _repository.createMealPlan(newPlan);
      }
      
      await loadUserMealPlans(userId);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> removeMealFromPlan(String userId, DateTime date, String mealId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final existingPlan = await _repository.getMealPlanByDate(userId, date);
      
      if (existingPlan != null) {
        final updatedMeals = existingPlan.meals.where((m) => m.id != mealId).toList();
        
        if (updatedMeals.isEmpty) {
          await _repository.deleteMealPlan(existingPlan.id);
        } else {
          final updatedPlan = existingPlan.copyWith(meals: updatedMeals);
          await _repository.updateMealPlan(updatedPlan);
        }
      }
      
      await loadUserMealPlans(userId);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}