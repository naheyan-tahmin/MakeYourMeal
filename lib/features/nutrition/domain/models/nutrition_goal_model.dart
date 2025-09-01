// File: lib/features/nutrition/domain/models/nutrition_goal_model.dart

class NutritionGoalModel {
  final String userId;
  final double caloriesGoal;
  final double proteinGoal;
  final double carbsGoal;
  final double fatGoal;
  final double fiberGoal;
  final DateTime updatedAt;

  const NutritionGoalModel({
    required this.userId,
    required this.caloriesGoal,
    required this.proteinGoal,
    required this.carbsGoal,
    required this.fatGoal,
    required this.fiberGoal,
    required this.updatedAt,
  });

  factory NutritionGoalModel.fromJson(Map<String, dynamic> json) {
    return NutritionGoalModel(
      userId: json['userId'] as String,
      caloriesGoal: (json['caloriesGoal'] as num).toDouble(),
      proteinGoal: (json['proteinGoal'] as num).toDouble(),
      carbsGoal: (json['carbsGoal'] as num).toDouble(),
      fatGoal: (json['fatGoal'] as num).toDouble(),
      fiberGoal: (json['fiberGoal'] as num).toDouble(),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'caloriesGoal': caloriesGoal,
      'proteinGoal': proteinGoal,
      'carbsGoal': carbsGoal,
      'fatGoal': fatGoal,
      'fiberGoal': fiberGoal,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  NutritionGoalModel copyWith({
    String? userId,
    double? caloriesGoal,
    double? proteinGoal,
    double? carbsGoal,
    double? fatGoal,
    double? fiberGoal,
    DateTime? updatedAt,
  }) {
    return NutritionGoalModel(
      userId: userId ?? this.userId,
      caloriesGoal: caloriesGoal ?? this.caloriesGoal,
      proteinGoal: proteinGoal ?? this.proteinGoal,
      carbsGoal: carbsGoal ?? this.carbsGoal,
      fatGoal: fatGoal ?? this.fatGoal,
      fiberGoal: fiberGoal ?? this.fiberGoal,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Default goals for new users
  static NutritionGoalModel getDefaultGoals(String userId) {
    return NutritionGoalModel(
      userId: userId,
      caloriesGoal: 2000,
      proteinGoal: 150,
      carbsGoal: 250,
      fatGoal: 65,
      fiberGoal: 25,
      updatedAt: DateTime.now(),
    );
  }
}

class DailyNutritionSummary {
  final DateTime date;
  final double totalCalories;
  final double totalProtein;
  final double totalCarbs;
  final double totalFat;
  final double totalFiber;
  final double totalSugar;
  final double totalWater;

  const DailyNutritionSummary({
    required this.date,
    required this.totalCalories,
    required this.totalProtein,
    required this.totalCarbs,
    required this.totalFat,
    required this.totalFiber,
    required this.totalSugar,
    required this.totalWater,
  });

  static DailyNutritionSummary empty(DateTime date) {
    return DailyNutritionSummary(
      date: date,
      totalCalories: 0,
      totalProtein: 0,
      totalCarbs: 0,
      totalFat: 0,
      totalFiber: 0,
      totalSugar: 0,
      totalWater: 0,
    );
  }
}