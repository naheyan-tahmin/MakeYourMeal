// File: lib/features/water_intake/data/repositories/local_water_intake_repository.dart

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:make_your_meal/features/water_intake/domain/models/water_intake_model.dart';
import 'package:make_your_meal/features/water_intake/domain/repositories/water_intake_repository.dart';

class LocalWaterIntakeRepository implements WaterIntakeRepository {
  static const String _waterIntakeKey = 'water_intake';
  static const String _waterGoalKey = 'water_goal';

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  @override
  Future<WaterIntakeModel?> getTodayWaterIntake(String userId) async {
    final today = DateTime.now();
    return await getWaterIntakeByDate(userId, today);
  }

  @override
  Future<WaterIntakeModel?> getWaterIntakeByDate(String userId, DateTime date) async {
    final allIntakes = await _getAllWaterIntakes();
    try {
      return allIntakes.firstWhere((intake) =>
          intake.userId == userId &&
          intake.date.year == date.year &&
          intake.date.month == date.month &&
          intake.date.day == date.day);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<WaterIntakeModel> createWaterIntake(WaterIntakeModel waterIntake) async {
    final allIntakes = await _getAllWaterIntakes();
    allIntakes.add(waterIntake);
    await _saveWaterIntakes(allIntakes);
    return waterIntake;
  }

  @override
  Future<WaterIntakeModel> updateWaterIntake(WaterIntakeModel waterIntake) async {
    final allIntakes = await _getAllWaterIntakes();
    final index = allIntakes.indexWhere((intake) => intake.id == waterIntake.id);
    if (index != -1) {
      allIntakes[index] = waterIntake.copyWith(updatedAt: DateTime.now());
      await _saveWaterIntakes(allIntakes);
      return allIntakes[index];
    }
    throw 'Water intake record not found';
  }

  @override
  Future<void> addManualWaterIntake(String userId, double amountMl) async {
    final today = DateTime.now();
    final existing = await getWaterIntakeByDate(userId, today);
    
    if (existing != null) {
      final updated = existing.copyWith(
        manualIntake: existing.manualIntake + amountMl,
        updatedAt: DateTime.now(),
      );
      await updateWaterIntake(updated);
    } else {
      final newIntake = WaterIntakeModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        date: today,
        manualIntake: amountMl,
        mealBasedIntake: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await createWaterIntake(newIntake);
    }
  }

  @override
  Future<void> updateMealBasedWaterIntake(String userId, DateTime date, double totalWaterMl) async {
    final existing = await getWaterIntakeByDate(userId, date);
    
    if (existing != null) {
      final updated = existing.copyWith(
        mealBasedIntake: totalWaterMl,
        updatedAt: DateTime.now(),
      );
      await updateWaterIntake(updated);
    } else {
      final newIntake = WaterIntakeModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        date: date,
        manualIntake: 0,
        mealBasedIntake: totalWaterMl,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await createWaterIntake(newIntake);
    }
  }

  @override
  Future<WaterGoalModel> getWaterGoal(String userId) async {
    final prefs = await _prefs;
    final goalJson = prefs.getString('$_waterGoalKey$userId');
    if (goalJson != null) {
      return WaterGoalModel.fromJson(jsonDecode(goalJson));
    }
    // Return default goal
    return WaterGoalModel(
      userId: userId,
      dailyGoalMl: 2000, // Default 2L per day
      updatedAt: DateTime.now(),
    );
  }

  @override
  Future<void> setWaterGoal(String userId, double dailyGoalMl) async {
    final goal = WaterGoalModel(
      userId: userId,
      dailyGoalMl: dailyGoalMl,
      updatedAt: DateTime.now(),
    );
    final prefs = await _prefs;
    await prefs.setString('$_waterGoalKey$userId', jsonEncode(goal.toJson()));
  }

  Future<List<WaterIntakeModel>> _getAllWaterIntakes() async {
    final prefs = await _prefs;
    final intakesJson = prefs.getStringList(_waterIntakeKey) ?? [];
    return intakesJson
        .map((json) => WaterIntakeModel.fromJson(jsonDecode(json)))
        .toList();
  }

  Future<void> _saveWaterIntakes(List<WaterIntakeModel> intakes) async {
    final prefs = await _prefs;
    final intakesJson = intakes.map((intake) => jsonEncode(intake.toJson())).toList();
    await prefs.setStringList(_waterIntakeKey, intakesJson);
  }
}

