

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:make_your_meal/features/meal_plan/domain/models/meal_plan_model.dart';
import 'package:make_your_meal/features/meal_plan/domain/repositories/meal_plan_repository.dart';
import 'package:make_your_meal/features/meal_plan/presentation/providers/meal_plan_provider.dart';
import 'package:make_your_meal/features/water_intake/domain/repositories/water_intake_repository.dart';
import 'package:make_your_meal/features/water_intake/presentation/providers/water_intake_provider.dart';
import 'package:make_your_meal/core/services/food_items_service.dart';

// Enhanced meal plan provider that also updates water intake
final enhancedMealPlanProvider = StateNotifierProvider<EnhancedMealPlanViewModel, MealPlanState>((ref) {
  final repository = ref.watch(mealPlanRepositoryProvider);
  final waterRepository = ref.watch(waterIntakeRepositoryProvider);
  return EnhancedMealPlanViewModel(repository, waterRepository);
});

class EnhancedMealPlanViewModel extends StateNotifier<MealPlanState> {
  final MealPlanRepository _mealPlanRepository;
  final WaterIntakeRepository _waterRepository;

  EnhancedMealPlanViewModel(this._mealPlanRepository, this._waterRepository) 
      : super(const MealPlanState());

  Future<void> loadUserMealPlans(String userId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final mealPlans = await _mealPlanRepository.getUserMealPlans(userId);
      state = state.copyWith(mealPlans: mealPlans, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> addMealToPlan(String userId, DateTime date, PlannedMeal meal) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final existingPlan = await _mealPlanRepository.getMealPlanByDate(userId, date);
      if (existingPlan != null) {
        final updatedMeals = [...existingPlan.meals, meal];
        final updatedPlan = existingPlan.copyWith(meals: updatedMeals);
        await _mealPlanRepository.updateMealPlan(updatedPlan);
      } else {
        final newPlan = MealPlanModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          userId: userId,
          date: date,
          meals: [meal],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await _mealPlanRepository.createMealPlan(newPlan);
      }

      // Update water intake based on new meal
      await _updateWaterIntakeFromMeals(userId, date);
      await loadUserMealPlans(userId);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> removeMealFromPlan(String userId, DateTime date, String mealId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final existingPlan = await _mealPlanRepository.getMealPlanByDate(userId, date);
      if (existingPlan != null) {
        final updatedMeals = existingPlan.meals.where((m) => m.id != mealId).toList();
        if (updatedMeals.isEmpty) {
          await _mealPlanRepository.deleteMealPlan(existingPlan.id);
        } else {
          final updatedPlan = existingPlan.copyWith(meals: updatedMeals);
          await _mealPlanRepository.updateMealPlan(updatedPlan);
        }
      }

      // Update water intake after removing meal
      await _updateWaterIntakeFromMeals(userId, date);
      await loadUserMealPlans(userId);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> _updateWaterIntakeFromMeals(String userId, DateTime date) async {
    try {
      final mealPlan = await _mealPlanRepository.getMealPlanByDate(userId, date);
      double totalWaterFromMeals = 0.0;

      if (mealPlan != null) {
        // Get all food items to calculate water content
        final allFoodItems = await FoodItemsService.getAllFoodItems();
        
        for (final meal in mealPlan.meals) {
          // Calculate water from recipe ingredients (simplified approach)
          // This would need enhancement based on your recipe ingredients structure
          // For now, we'll estimate based on recipe nutrition data
          final recipe = meal.recipe;
          final servingMultiplier = meal.servings / recipe.servings;
          
          // Estimate water content: recipes with high water content foods
          // This is a simplified calculation - you might want to enhance this
          // based on actual ingredient water content
          if (recipe.category.toLowerCase().contains('soup') || 
              recipe.category.toLowerCase().contains('beverage')) {
            totalWaterFromMeals += 200 * servingMultiplier; // 200ml per serving for soups/beverages
          } else if (recipe.category.toLowerCase().contains('fruit')) {
            totalWaterFromMeals += 100 * servingMultiplier; // 100ml per serving for fruits
          } else {
            totalWaterFromMeals += 50 * servingMultiplier; // 50ml per serving for other foods
          }
        }
      }

      await _waterRepository.updateMealBasedWaterIntake(userId, date, totalWaterFromMeals);
    } catch (e) {
      // Log error but don't fail the meal plan operation
      print('Error updating water intake from meals: $e');
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}