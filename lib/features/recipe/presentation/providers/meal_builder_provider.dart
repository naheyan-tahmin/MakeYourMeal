// File: lib/features/recipe/presentation/providers/meal_builder_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:make_your_meal/features/recipe/domain/models/food_item_model.dart';
import 'package:make_your_meal/core/services/food_items_service.dart';

final foodItemsProvider = FutureProvider<List<FoodItemModel>>((ref) {
  return FoodItemsService.getAllFoodItems();
});

final foodItemsByCategoryProvider = Provider.family<AsyncValue<List<FoodItemModel>>, String>((ref, category) {
  final foodItemsAsync = ref.watch(foodItemsProvider);
  return foodItemsAsync.whenData((items) => 
    items.where((item) => item.category == category).toList()
  );
});

final selectedFoodItemsProvider = StateNotifierProvider<SelectedFoodItemsNotifier, List<SelectedFoodItem>>((ref) {
  return SelectedFoodItemsNotifier();
});

final mealSummaryProvider = Provider<MealSummary>((ref) {
  final selectedItems = ref.watch(selectedFoodItemsProvider);
  return MealSummary.fromSelectedItems(selectedItems);
});

final selectedCategoryProvider = StateProvider<String?>((ref) => null);

class SelectedFoodItemsNotifier extends StateNotifier<List<SelectedFoodItem>> {
  SelectedFoodItemsNotifier() : super([]);

  void addFoodItem(FoodItemModel foodItem, double quantity) {
    final selectedItem = SelectedFoodItem(
      foodItem: foodItem,
      quantity: quantity,
      addedAt: DateTime.now(),
    );
    state = [...state, selectedItem];
  }

  void removeFoodItem(int index) {
    final newState = List<SelectedFoodItem>.from(state);
    newState.removeAt(index);
    state = newState;
  }

  void updateQuantity(int index, double newQuantity) {
    final newState = List<SelectedFoodItem>.from(state);
    final item = newState[index];
    newState[index] = SelectedFoodItem(
      foodItem: item.foodItem,
      quantity: newQuantity,
      addedAt: item.addedAt,
    );
    state = newState;
  }

  void clearAll() {
    state = [];
  }
}

class MealSummary {
  final double totalCalories;
  final double totalProtein;
  final double totalCarbs;
  final double totalFat;
  final double totalFiber;
  final double totalSugar;
  final double totalWaterIntake; // in ml
  final int totalItems;

  const MealSummary({
    required this.totalCalories,
    required this.totalProtein,
    required this.totalCarbs,
    required this.totalFat,
    required this.totalFiber,
    required this.totalSugar,
    required this.totalWaterIntake,
    required this.totalItems,
  });

  factory MealSummary.fromSelectedItems(List<SelectedFoodItem> items) {
    double calories = 0;
    double protein = 0;
    double carbs = 0;
    double fat = 0;
    double fiber = 0;
    double sugar = 0;
    double waterIntake = 0;

    for (final item in items) {
      calories += item.totalCalories;
      protein += item.totalProtein;
      carbs += item.totalCarbs;
      fat += item.totalFat;
      fiber += item.totalFiber;
      sugar += item.totalSugar;
      
      // Calculate water intake from food items
      if (item.foodItem.isLiquid) {
        waterIntake += item.quantity; // Direct quantity for liquids
      } else {
        waterIntake += item.totalWaterContent; // Water content from solid foods
      }
    }

    return MealSummary(
      totalCalories: calories,
      totalProtein: protein,
      totalCarbs: carbs,
      totalFat: fat,
      totalFiber: fiber,
      totalSugar: sugar,
      totalWaterIntake: waterIntake,
      totalItems: items.length,
    );
  }
}