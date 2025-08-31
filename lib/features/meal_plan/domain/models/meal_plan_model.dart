import 'package:make_your_meal/features/recipe/domain/models/recipe_model.dart';
class MealPlanModel {
  final String id;
  final String userId;
  final DateTime date;
  final List<PlannedMeal> meals;
  final DateTime createdAt;
  final DateTime updatedAt;

  const MealPlanModel({
    required this.id,
    required this.userId,
    required this.date,
    required this.meals,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MealPlanModel.fromJson(Map<String, dynamic> json) {
    return MealPlanModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      date: DateTime.parse(json['date'] as String),
      meals: (json['meals'] as List)
          .map((meal) => PlannedMeal.fromJson(meal as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'date': date.toIso8601String(),
      'meals': meals.map((meal) => meal.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  MealPlanModel copyWith({
    String? id,
    String? userId,
    DateTime? date,
    List<PlannedMeal>? meals,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MealPlanModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      meals: meals ?? this.meals,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  double get totalCalories {
    return meals.fold(0.0, (sum, meal) => sum + (meal.recipe.nutrition?.calories ?? 0));
  }
}

class PlannedMeal {
  final String id;
  final RecipeModel recipe;
  final MealType mealType;
  final int servings;

  const PlannedMeal({
    required this.id,
    required this.recipe,
    required this.mealType,
    required this.servings,
  });

  factory PlannedMeal.fromJson(Map<String, dynamic> json) {
    return PlannedMeal(
      id: json['id'] as String,
      recipe: RecipeModel.fromJson(json['recipe'] as Map<String, dynamic>),
      mealType: MealType.fromString(json['mealType'] as String),
      servings: json['servings'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'recipe': recipe.toJson(),
      'mealType': mealType.name,
      'servings': servings,
    };
  }

  double get calories {
    return (recipe.nutrition?.calories ?? 0) * (servings / recipe.servings);
  }
}

enum MealType {
  breakfast('Breakfast'),
  lunch('Lunch'),
  dinner('Dinner'),
  snack('Snack');

  const MealType(this.displayName);
  final String displayName;

  static MealType fromString(String value) {
    return MealType.values.firstWhere(
      (type) => type.name == value,
      orElse: () => MealType.lunch,
    );
  }
}
