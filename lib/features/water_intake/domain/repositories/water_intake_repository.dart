// File: lib/features/water_intake/domain/repositories/water_intake_repository.dart

import 'package:make_your_meal/features/water_intake/domain/models/water_intake_model.dart';

abstract class WaterIntakeRepository {
  Future<WaterIntakeModel?> getTodayWaterIntake(String userId);
  Future<WaterIntakeModel?> getWaterIntakeByDate(String userId, DateTime date);
  Future<WaterIntakeModel> createWaterIntake(WaterIntakeModel waterIntake);
  Future<WaterIntakeModel> updateWaterIntake(WaterIntakeModel waterIntake);
  Future<void> addManualWaterIntake(String userId, double amountMl);
  Future<void> updateMealBasedWaterIntake(String userId, DateTime date, double totalWaterMl);
  Future<WaterGoalModel> getWaterGoal(String userId);
  Future<void> setWaterGoal(String userId, double dailyGoalMl);
}