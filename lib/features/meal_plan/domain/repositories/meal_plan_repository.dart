import 'package:make_your_meal/features/meal_plan/domain/models/meal_plan_model.dart';

abstract class MealPlanRepository {
  Future<List<MealPlanModel>> getUserMealPlans(String userId);
  Future<MealPlanModel?> getMealPlanByDate(String userId, DateTime date);
  Future<MealPlanModel> createMealPlan(MealPlanModel mealPlan);
  Future<MealPlanModel> updateMealPlan(MealPlanModel mealPlan);
  Future<void> deleteMealPlan(String id);
  Future<List<MealPlanModel>> getWeeklyMealPlan(String userId, DateTime startDate);
}
