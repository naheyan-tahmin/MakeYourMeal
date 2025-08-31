import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:make_your_meal/features/recipe/domain/models/recipe_model.dart';
import 'package:make_your_meal/features/recipe/domain/repositories/recipe_repository.dart';
import 'package:make_your_meal/core/services/cloudinary_service.dart';

class LocalRecipeRepository implements RecipeRepository {
  static const String _recipesKey = 'recipes';

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  @override
  Future<List<RecipeModel>> getAllRecipes() async {
    final prefs = await _prefs;
    final recipesJson = prefs.getStringList(_recipesKey) ?? [];
    return recipesJson.map((json) => RecipeModel.fromJson(jsonDecode(json))).toList();
  }

  @override
  Future<RecipeModel?> getRecipeById(String id) async {
    final recipes = await getAllRecipes();
    try {
      return recipes.firstWhere((recipe) => recipe.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<RecipeModel>> getRecipesByCategory(String category) async {
    final recipes = await getAllRecipes();
    return recipes.where((recipe) => recipe.category == category).toList();
  }

  @override
  Future<List<RecipeModel>> searchRecipes(String query) async {
    final recipes = await getAllRecipes();
    final lowercaseQuery = query.toLowerCase();
    return recipes.where((recipe) {
      return recipe.title.toLowerCase().contains(lowercaseQuery) ||
          recipe.description.toLowerCase().contains(lowercaseQuery) ||
          recipe.ingredients.any((ingredient) => 
              ingredient.toLowerCase().contains(lowercaseQuery));
    }).toList();
  }

  @override
  Future<RecipeModel> createRecipe(RecipeModel recipe, {File? imageFile}) async {
    String? imageUrl;
    if (imageFile != null) {
      imageUrl = await CloudinaryService.uploadRecipeImage(imageFile, recipe.id);
    }

    final newRecipe = recipe.copyWith(
      imageUrl: imageUrl,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final recipes = await getAllRecipes();
    recipes.add(newRecipe);
    await _saveRecipes(recipes);
    return newRecipe;
  }

  @override
  Future<RecipeModel> updateRecipe(RecipeModel recipe, {File? imageFile}) async {
    String? imageUrl = recipe.imageUrl;
    if (imageFile != null) {
      imageUrl = await CloudinaryService.uploadRecipeImage(imageFile, recipe.id);
    }

    final updatedRecipe = recipe.copyWith(
      imageUrl: imageUrl,
      updatedAt: DateTime.now(),
    );

    final recipes = await getAllRecipes();
    final index = recipes.indexWhere((r) => r.id == recipe.id);
    if (index != -1) {
      recipes[index] = updatedRecipe;
      await _saveRecipes(recipes);
    }
    return updatedRecipe;
  }

  @override
  Future<void> deleteRecipe(String id) async {
    final recipes = await getAllRecipes();
    recipes.removeWhere((recipe) => recipe.id == id);
    await _saveRecipes(recipes);
  }

  @override
  Future<List<RecipeModel>> getUserRecipes(String userId) async {
    final recipes = await getAllRecipes();
    return recipes.where((recipe) => recipe.authorId == userId).toList();
  }

  Future<void> _saveRecipes(List<RecipeModel> recipes) async {
    final prefs = await _prefs;
    final recipesJson = recipes.map((recipe) => jsonEncode(recipe.toJson())).toList();
    await prefs.setStringList(_recipesKey, recipesJson);
  }
}
