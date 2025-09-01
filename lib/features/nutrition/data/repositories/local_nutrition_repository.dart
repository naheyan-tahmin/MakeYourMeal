// File: lib/features/nutrition/data/repositories/local_nutrition_repository.dart

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:make_your_meal/features/nutrition/domain/models/nutrition_goal_model.dart';
import 'package:make_your_meal/features/nutrition/domain/repositories/nutrition_repository.dart';
import 'package:make_your_meal/features/meal_plan/domain/models/meal_plan_model.dart';

class LocalNutritionRepository implements NutritionRepository {
  static const String _nutritionGoalKey = 'nutrition_goal';

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  @override
  Future<NutritionGoalModel> getNutritionGoal(String userId) async {
    final prefs = await _prefs;
    final goalJson = prefs.getString('$_nutritionGoalKey$userId');
    if (goalJson != null) {
      return NutritionGoalModel.fromJson(jsonDecode(goalJson));
    }
    // Return default goals for new users
    return NutritionGoalModel.getDefaultGoals(userId);
  }

  @override
  Future<void> setNutritionGoal(NutritionGoalModel goal) async {
    final prefs = await _prefs;
    await prefs.setString('$_nutritionGoalKey${goal.userId}', jsonEncode(goal.toJson()));
  }

  @override
  Future<DailyNutritionSummary> calculateDailyNutrition(String userId, DateTime date, List<MealPlanModel> mealPlans) async {
    // Find meal plan for the specific date
    MealPlanModel? dayPlan;
    try {
      dayPlan = mealPlans.firstWhere((plan) =>
          plan.userId == userId &&
          plan.date.year == date.year &&
          plan.date.month == date.month &&
          plan.date.day == date.day);
    } catch (e) {
      return DailyNutritionSummary.empty(date);
    }

    double totalCalories = 0;
    double totalProtein = 0;
    double totalCarbs = 0;
    double totalFat = 0;
    double totalFiber = 0;
    double totalSugar = 0;
    double totalWater = 0;

    for (final meal in dayPlan.meals) {
      final recipe = meal.recipe;
      final servingMultiplier = meal.servings / recipe.servings;
      
      if (recipe.nutrition != null) {
        totalCalories += recipe.nutrition!.calories * servingMultiplier;
        totalProtein += recipe.nutrition!.protein * servingMultiplier;
        totalCarbs += recipe.nutrition!.carbs * servingMultiplier;
        totalFat += recipe.nutrition!.fat * servingMultiplier;
        totalFiber += recipe.nutrition!.fiber * servingMultiplier;
        totalSugar += recipe.nutrition!.sugar * servingMultiplier;
      }
    }

    return DailyNutritionSummary(
      date: date,
      totalCalories: totalCalories,
      totalProtein: totalProtein,
      totalCarbs: totalCarbs,
      totalFat: totalFat,
      totalFiber: totalFiber,
      totalSugar: totalSugar,
      totalWater: totalWater,
    );
  }
}

