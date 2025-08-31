import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:make_your_meal/features/meal_plan/domain/models/meal_plan_model.dart';
import 'package:make_your_meal/features/meal_plan/domain/repositories/meal_plan_repository.dart';

class LocalMealPlanRepository implements MealPlanRepository {
  static const String _mealPlansKey = 'meal_plans';

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  @override
  Future<List<MealPlanModel>> getUserMealPlans(String userId) async {
    final prefs = await _prefs;
    final mealPlansJson = prefs.getStringList(_mealPlansKey) ?? [];
    final allMealPlans = mealPlansJson
        .map((json) => MealPlanModel.fromJson(jsonDecode(json)))
        .toList();
    return allMealPlans.where((plan) => plan.userId == userId).toList();
  }

  @override
  Future<MealPlanModel?> getMealPlanByDate(String userId, DateTime date) async {
    final userPlans = await getUserMealPlans(userId);
    try {
      return userPlans.firstWhere((plan) => 
          plan.date.year == date.year && 
          plan.date.month == date.month && 
          plan.date.day == date.day);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<MealPlanModel> createMealPlan(MealPlanModel mealPlan) async {
    final allPlans = await _getAllMealPlans();
    allPlans.add(mealPlan);
    await _saveMealPlans(allPlans);
    return mealPlan;
  }

  @override
  Future<MealPlanModel> updateMealPlan(MealPlanModel mealPlan) async {
    final allPlans = await _getAllMealPlans();
    final index = allPlans.indexWhere((plan) => plan.id == mealPlan.id);
    if (index != -1) {
      allPlans[index] = mealPlan.copyWith(updatedAt: DateTime.now());
      await _saveMealPlans(allPlans);
      return allPlans[index];
    }
    throw 'Meal plan not found';
  }

  @override
  Future<void> deleteMealPlan(String id) async {
    final allPlans = await _getAllMealPlans();
    allPlans.removeWhere((plan) => plan.id == id);
    await _saveMealPlans(allPlans);
  }

  @override
  Future<List<MealPlanModel>> getWeeklyMealPlan(String userId, DateTime startDate) async {
    final userPlans = await getUserMealPlans(userId);
    final endDate = startDate.add(const Duration(days: 7));
    
    return userPlans.where((plan) {
      return plan.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
          plan.date.isBefore(endDate);
    }).toList();
  }

  Future<List<MealPlanModel>> _getAllMealPlans() async {
    final prefs = await _prefs;
    final mealPlansJson = prefs.getStringList(_mealPlansKey) ?? [];
    return mealPlansJson
        .map((json) => MealPlanModel.fromJson(jsonDecode(json)))
        .toList();
  }

  Future<void> _saveMealPlans(List<MealPlanModel> mealPlans) async {
    final prefs = await _prefs;
    final mealPlansJson = mealPlans.map((plan) => jsonEncode(plan.toJson())).toList();
    await prefs.setStringList(_mealPlansKey, mealPlansJson);
  }
}