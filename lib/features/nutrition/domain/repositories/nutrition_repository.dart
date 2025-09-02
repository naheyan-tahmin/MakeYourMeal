

import 'package:make_your_meal/features/nutrition/domain/models/nutrition_goal_model.dart';
import 'package:make_your_meal/features/meal_plan/domain/models/meal_plan_model.dart';

abstract class NutritionRepository {
  Future<NutritionGoalModel> getNutritionGoal(String userId);
  Future<void> setNutritionGoal(NutritionGoalModel goal);
  Future<DailyNutritionSummary> calculateDailyNutrition(String userId, DateTime date, List<MealPlanModel> mealPlans);
}