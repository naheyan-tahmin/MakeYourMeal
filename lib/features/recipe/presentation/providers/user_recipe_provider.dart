
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:make_your_meal/features/recipe/domain/models/recipe_model.dart';
import 'package:make_your_meal/features/recipe/presentation/providers/recipe_provider.dart';

// Provider to get recipes for a specific user
final userRecipesProvider = Provider.family<List<RecipeModel>, String?>((ref, userId) {
  if (userId == null) return [];
  
  final allRecipes = ref.watch(recipesProvider).recipes;
  return allRecipes.where((recipe) => recipe.authorId == userId).toList();
});

// Provider to get filtered user recipes (with search and category filter)
final filteredUserRecipesProvider = Provider.family<List<RecipeModel>, String?>((ref, userId) {
  if (userId == null) return [];
  
  final userRecipes = ref.watch(userRecipesProvider(userId));
  final searchQuery = ref.watch(recipeSearchProvider);
  final selectedCategory = ref.watch(recipeCategoryFilterProvider);
  
  List<RecipeModel> recipes = userRecipes;
  
  if (searchQuery.isNotEmpty) {
    recipes = recipes.where((recipe) {
      return recipe.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
          recipe.ingredients.any((ingredient) => 
              ingredient.toLowerCase().contains(searchQuery.toLowerCase()));
    }).toList();
  }
  
  if (selectedCategory != null) {
    recipes = recipes.where((recipe) => recipe.category == selectedCategory).toList();
  }
  
  return recipes;
});

// Provider to get user recipe count
final userRecipeCountProvider = Provider.family<int, String?>((ref, userId) {
  if (userId == null) return 0;
  return ref.watch(userRecipesProvider(userId)).length;
});