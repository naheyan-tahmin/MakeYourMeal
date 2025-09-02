
class FoodItemModel {
  final String id;
  final String name;
  final String category;
  final String? imageUrl;
  final NutritionPer100g nutrition;
  final double defaultServingSize; // in grams
  final bool isLiquid; // for water intake tracking
  final bool isCustom; // for user-added items

  const FoodItemModel({
    required this.id,
    required this.name,
    required this.category,
    this.imageUrl,
    required this.nutrition,
    required this.defaultServingSize,
    this.isLiquid = false,
    this.isCustom = false,
  });

  factory FoodItemModel.fromJson(Map<String, dynamic> json) {
    return FoodItemModel(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      imageUrl: json['imageUrl'] as String?,
      nutrition: NutritionPer100g.fromJson(json['nutrition'] as Map<String, dynamic>),
      defaultServingSize: (json['defaultServingSize'] as num).toDouble(),
      isLiquid: json['isLiquid'] as bool? ?? false,
      isCustom: json['isCustom'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'imageUrl': imageUrl,
      'nutrition': nutrition.toJson(),
      'defaultServingSize': defaultServingSize,
      'isLiquid': isLiquid,
      'isCustom': isCustom,
    };
  }

  FoodItemModel copyWith({
    String? id,
    String? name,
    String? category,
    String? imageUrl,
    NutritionPer100g? nutrition,
    double? defaultServingSize,
    bool? isLiquid,
    bool? isCustom,
  }) {
    return FoodItemModel(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      nutrition: nutrition ?? this.nutrition,
      defaultServingSize: defaultServingSize ?? this.defaultServingSize,
      isLiquid: isLiquid ?? this.isLiquid,
      isCustom: isCustom ?? this.isCustom,
    );
  }
}

class NutritionPer100g {
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final double fiber;
  final double sugar;
  final double waterContent; // ml per 100g, for water intake tracking

  const NutritionPer100g({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.fiber,
    required this.sugar,
    this.waterContent = 0,
  });

  factory NutritionPer100g.fromJson(Map<String, dynamic> json) {
    return NutritionPer100g(
      calories: (json['calories'] as num).toDouble(),
      protein: (json['protein'] as num).toDouble(),
      carbs: (json['carbs'] as num).toDouble(),
      fat: (json['fat'] as num).toDouble(),
      fiber: (json['fiber'] as num).toDouble(),
      sugar: (json['sugar'] as num).toDouble(),
      waterContent: (json['waterContent'] as num?)?.toDouble() ?? 0,
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
      'waterContent': waterContent,
    };
  }
}

class SelectedFoodItem {
  final FoodItemModel foodItem;
  final double quantity; // in grams
  final DateTime addedAt;

  const SelectedFoodItem({
    required this.foodItem,
    required this.quantity,
    required this.addedAt,
  });

  double get totalCalories => (foodItem.nutrition.calories * quantity) / 100;
  double get totalProtein => (foodItem.nutrition.protein * quantity) / 100;
  double get totalCarbs => (foodItem.nutrition.carbs * quantity) / 100;
  double get totalFat => (foodItem.nutrition.fat * quantity) / 100;
  double get totalFiber => (foodItem.nutrition.fiber * quantity) / 100;
  double get totalSugar => (foodItem.nutrition.sugar * quantity) / 100;
  double get totalWaterContent => (foodItem.nutrition.waterContent * quantity) / 100;

  factory SelectedFoodItem.fromJson(Map<String, dynamic> json) {
    return SelectedFoodItem(
      foodItem: FoodItemModel.fromJson(json['foodItem'] as Map<String, dynamic>),
      quantity: (json['quantity'] as num).toDouble(),
      addedAt: DateTime.parse(json['addedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'foodItem': foodItem.toJson(),
      'quantity': quantity,
      'addedAt': addedAt.toIso8601String(),
    };
  }
}