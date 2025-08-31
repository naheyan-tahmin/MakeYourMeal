class AppConstants {
  // Recipe Categories
  static const List<String> recipeCategories = [
    'Breakfast',
    'Lunch', 
    'Dinner',
    'Snack',
    'Dessert',
    'Appetizer',
    'Beverage',
  ];

  // Meal Types
  static const List<String> mealTypes = [
    'Breakfast',
    'Lunch',
    'Dinner',
    'Snack',
  ];

  // Nutrition Units
  static const String caloriesUnit = 'kcal';
  static const String weightUnit = 'g';
  static const String volumeUnit = 'ml';

  // Default Values
  static const int defaultServings = 4;
  static const int defaultPrepTime = 15;
  static const int defaultCookTime = 30;

  // UI Constants
  static const double cardBorderRadius = 12.0;
  static const double buttonBorderRadius = 8.0;
  static const double defaultPadding = 16.0;
  
  // Image Sizes
  static const int recipeImageWidth = 400;
  static const int recipeImageHeight = 300;
  static const int thumbnailSize = 100;
}