class RecipeModel {
  final String id;
  final String title;
  final String description;
  final List<String> ingredients;
  final List<String> instructions;
  final String category;
  final int prepTimeMinutes;
  final int cookTimeMinutes;
  final int servings;
  final String? imageUrl;
  final NutritionData? nutrition;
  final String authorId;
  final String authorName;
  final DateTime createdAt;
  final DateTime updatedAt;

  const RecipeModel({
    required this.id,
    required this.title,
    required this.description,
    required this.ingredients,
    required this.instructions,
    required this.category,
    required this.prepTimeMinutes,
    required this.cookTimeMinutes,
    required this.servings,
    this.imageUrl,
    this.nutrition,
    required this.authorId,
    required this.authorName,
    required this.createdAt,
    required this.updatedAt,
  });

  factory RecipeModel.fromJson(Map<String, dynamic> json) {
    return RecipeModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      ingredients: List<String>.from(json['ingredients'] as List),
      instructions: List<String>.from(json['instructions'] as List),
      category: json['category'] as String,
      prepTimeMinutes: json['prepTimeMinutes'] as int,
      cookTimeMinutes: json['cookTimeMinutes'] as int,
      servings: json['servings'] as int,
      imageUrl: json['imageUrl'] as String?,
      nutrition: json['nutrition'] != null 
          ? NutritionData.fromJson(json['nutrition'] as Map<String, dynamic>)
          : null,
      authorId: json['authorId'] as String,
      authorName: json['authorName'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'ingredients': ingredients,
      'instructions': instructions,
      'category': category,
      'prepTimeMinutes': prepTimeMinutes,
      'cookTimeMinutes': cookTimeMinutes,
      'servings': servings,
      'imageUrl': imageUrl,
      'nutrition': nutrition?.toJson(),
      'authorId': authorId,
      'authorName': authorName,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  RecipeModel copyWith({
    String? id,
    String? title,
    String? description,
    List<String>? ingredients,
    List<String>? instructions,
    String? category,
    int? prepTimeMinutes,
    int? cookTimeMinutes,
    int? servings,
    String? imageUrl,
    NutritionData? nutrition,
    String? authorId,
    String? authorName,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RecipeModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      ingredients: ingredients ?? this.ingredients,
      instructions: instructions ?? this.instructions,
      category: category ?? this.category,
      prepTimeMinutes: prepTimeMinutes ?? this.prepTimeMinutes,
      cookTimeMinutes: cookTimeMinutes ?? this.cookTimeMinutes,
      servings: servings ?? this.servings,
      imageUrl: imageUrl ?? this.imageUrl,
      nutrition: nutrition ?? this.nutrition,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class NutritionData {
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final double fiber;
  final double sugar;

  const NutritionData({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.fiber,
    required this.sugar,
  });

  factory NutritionData.fromJson(Map<String, dynamic> json) {
    return NutritionData(
      calories: (json['calories'] as num).toDouble(),
      protein: (json['protein'] as num).toDouble(),
      carbs: (json['carbs'] as num).toDouble(),
      fat: (json['fat'] as num).toDouble(),
      fiber: (json['fiber'] as num).toDouble(),
      sugar: (json['sugar'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'fiber': fiber,
      'sugar': sugar,
    };
  }
}
