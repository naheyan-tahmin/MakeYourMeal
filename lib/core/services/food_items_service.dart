import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:make_your_meal/features/recipe/domain/models/food_item_model.dart';
import 'package:make_your_meal/core/services/cloudinary_service.dart';

class FoodItemsService {
  static const String _foodItemsKey = 'food_items';
  static const String _customItemsKey = 'custom_food_items';

  static Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  // Initialize with predefined food items
  static Future<void> initializeFoodItems() async {
    final prefs = await _prefs;
    final existingItems = prefs.getStringList(_foodItemsKey);
    
    if (existingItems == null || existingItems.isEmpty) {
      await _saveDefaultFoodItems();
    }
  }

  static Future<List<FoodItemModel>> getAllFoodItems() async {
    final prefs = await _prefs;
    final predefinedItems = prefs.getStringList(_foodItemsKey) ?? [];
    final customItems = prefs.getStringList(_customItemsKey) ?? [];
    
    final allItemsJson = [...predefinedItems, ...customItems];
    return allItemsJson.map((json) => FoodItemModel.fromJson(jsonDecode(json))).toList();
  }

  static Future<List<FoodItemModel>> getFoodItemsByCategory(String category) async {
    final allItems = await getAllFoodItems();
    return allItems.where((item) => item.category == category).toList();
  }

  static Future<FoodItemModel> addCustomFoodItem(
    String name,
    String category,
    NutritionPer100g nutrition,
    double defaultServingSize,
    {File? imageFile,
    bool isLiquid = false}
  ) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    
    String? imageUrl;
    if (imageFile != null) {
      imageUrl = await CloudinaryService.uploadFoodItemImage(imageFile, id);
    }

    final foodItem = FoodItemModel(
      id: id,
      name: name,
      category: category,
      imageUrl: imageUrl,
      nutrition: nutrition,
      defaultServingSize: defaultServingSize,
      isLiquid: isLiquid,
      isCustom: true,
    );

    final prefs = await _prefs;
    final customItems = prefs.getStringList(_customItemsKey) ?? [];
    customItems.add(jsonEncode(foodItem.toJson()));
    await prefs.setStringList(_customItemsKey, customItems);

    return foodItem;
  }

  static Future<void> updateCustomFoodItem(FoodItemModel foodItem, {File? imageFile}) async {
    if (!foodItem.isCustom) throw 'Cannot update predefined food items';

    String? imageUrl = foodItem.imageUrl;
    if (imageFile != null) {
      imageUrl = await CloudinaryService.uploadFoodItemImage(imageFile, foodItem.id);
    }

    final updatedItem = foodItem.copyWith(imageUrl: imageUrl);

    final prefs = await _prefs;
    final customItems = prefs.getStringList(_customItemsKey) ?? [];
    final index = customItems.indexWhere((json) {
      final item = FoodItemModel.fromJson(jsonDecode(json));
      return item.id == foodItem.id;
    });

    if (index != -1) {
      customItems[index] = jsonEncode(updatedItem.toJson());
      await prefs.setStringList(_customItemsKey, customItems);
    }
  }

  static Future<void> deleteCustomFoodItem(String id) async {
    final prefs = await _prefs;
    final customItems = prefs.getStringList(_customItemsKey) ?? [];
    customItems.removeWhere((json) {
      final item = FoodItemModel.fromJson(jsonDecode(json));
      return item.id == id;
    });
    await prefs.setStringList(_customItemsKey, customItems);
  }

  static Future<void> _saveDefaultFoodItems() async {
    final defaultItems = _getDefaultFoodItems();
    final prefs = await _prefs;
    final itemsJson = defaultItems.map((item) => jsonEncode(item.toJson())).toList();
    await prefs.setStringList(_foodItemsKey, itemsJson);
  }

  static List<FoodItemModel> _getDefaultFoodItems() {
    return [
      // Grains & Carbs
      FoodItemModel(
        id: 'rice',
        name: 'Rice',
        category: 'Grains',
        nutrition: const NutritionPer100g(
          calories: 130,
          protein: 2.7,
          carbs: 28,
          fat: 0.3,
          fiber: 0.4,
          sugar: 0.1,
          waterContent: 69,
        ),
        defaultServingSize: 150, // 1 cup cooked
      ),
      
      FoodItemModel(
        id: 'oats',
        name: 'Oats',
        category: 'Grains',
        nutrition: const NutritionPer100g(
          calories: 389,
          protein: 16.9,
          carbs: 66.3,
          fat: 6.9,
          fiber: 10.6,
          sugar: 0.7,
          waterContent: 8,
        ),
        defaultServingSize: 40, // 1/2 cup dry
      ),

      FoodItemModel(
        id: 'noodles',
        name: 'Noodles',
        category: 'Grains',
        nutrition: const NutritionPer100g(
          calories: 138,
          protein: 4.5,
          carbs: 25.1,
          fat: 1.1,
          fiber: 1.8,
          sugar: 0.6,
          waterContent: 62,
        ),
        defaultServingSize: 100, // 1 cup cooked
      ),

      // Proteins
      FoodItemModel(
        id: 'chicken',
        name: 'Chicken Breast',
        category: 'Protein',
        nutrition: const NutritionPer100g(
          calories: 165,
          protein: 31,
          carbs: 0,
          fat: 3.6,
          fiber: 0,
          sugar: 0,
          waterContent: 65,
        ),
        defaultServingSize: 100, // 3.5 oz
      ),

      FoodItemModel(
        id: 'beef',
        name: 'Beef',
        category: 'Protein',
        nutrition: const NutritionPer100g(
          calories: 250,
          protein: 26,
          carbs: 0,
          fat: 15,
          fiber: 0,
          sugar: 0,
          waterContent: 56,
        ),
        defaultServingSize: 100, // 3.5 oz
      ),

      FoodItemModel(
        id: 'egg',
        name: 'Egg',
        category: 'Protein',
        nutrition: const NutritionPer100g(
          calories: 155,
          protein: 13,
          carbs: 1.1,
          fat: 11,
          fiber: 0,
          sugar: 1.1,
          waterContent: 76,
        ),
        defaultServingSize: 50, // 1 large egg
      ),

      // Fruits
      FoodItemModel(
        id: 'banana',
        name: 'Banana',
        category: 'Fruits',
        nutrition: const NutritionPer100g(
          calories: 89,
          protein: 1.1,
          carbs: 23,
          fat: 0.3,
          fiber: 2.6,
          sugar: 12,
          waterContent: 75,
        ),
        defaultServingSize: 120, // 1 medium banana
      ),

      FoodItemModel(
        id: 'apple',
        name: 'Apple',
        category: 'Fruits',
        nutrition: const NutritionPer100g(
          calories: 52,
          protein: 0.3,
          carbs: 14,
          fat: 0.2,
          fiber: 2.4,
          sugar: 10,
          waterContent: 86,
        ),
        defaultServingSize: 180, // 1 medium apple
      ),

      // Nuts & Seeds
      FoodItemModel(
        id: 'peanuts',
        name: 'Peanuts',
        category: 'Nuts',
        nutrition: const NutritionPer100g(
          calories: 567,
          protein: 26,
          carbs: 16,
          fat: 49,
          fiber: 8.5,
          sugar: 4,
          waterContent: 7,
        ),
        defaultServingSize: 30, // Small handful
      ),

      // Soups & Liquids
      FoodItemModel(
        id: 'soup',
        name: 'Vegetable Soup',
        category: 'Soups',
        nutrition: const NutritionPer100g(
          calories: 30,
          protein: 1.2,
          carbs: 6,
          fat: 0.5,
          fiber: 1.5,
          sugar: 3,
          waterContent: 90,
        ),
        defaultServingSize: 250, // 1 cup
        isLiquid: true,
      ),

      // Beverages
      FoodItemModel(
        id: 'water',
        name: 'Water',
        category: 'Beverages',
        nutrition: const NutritionPer100g(
          calories: 0,
          protein: 0,
          carbs: 0,
          fat: 0,
          fiber: 0,
          sugar: 0,
          waterContent: 100,
        ),
        defaultServingSize: 250, // 1 glass
        isLiquid: true,
      ),

      FoodItemModel(
        id: 'soft_drinks',
        name: 'Soft Drinks',
        category: 'Beverages',
        nutrition: const NutritionPer100g(
          calories: 42,
          protein: 0,
          carbs: 10.6,
          fat: 0,
          fiber: 0,
          sugar: 10.6,
          waterContent: 89,
        ),
        defaultServingSize: 330, // 1 can
        isLiquid: true,
      ),
    ];
  }

  static List<String> getCategories() {
    return ['Grains', 'Protein', 'Fruits', 'Vegetables', 'Nuts', 'Dairy', 'Soups', 'Beverages'];
  }
}