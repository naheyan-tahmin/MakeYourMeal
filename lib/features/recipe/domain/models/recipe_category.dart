enum RecipeCategory {
  breakfast('Breakfast'),
  lunch('Lunch'),
  dinner('Dinner'),
  snack('Snack'),
  dessert('Dessert'),
  appetizer('Appetizer'),
  beverage('Beverage');

  const RecipeCategory(this.displayName);
  final String displayName;

  static RecipeCategory fromString(String value) {
    return RecipeCategory.values.firstWhere(
      (category) => category.name == value,
      orElse: () => RecipeCategory.lunch,
    );
  }
}