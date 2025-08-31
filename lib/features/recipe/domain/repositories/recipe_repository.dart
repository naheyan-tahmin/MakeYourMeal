import 'dart:io';
import 'package:make_your_meal/features/recipe/domain/models/recipe_model.dart';

abstract class RecipeRepository {
  Future<List<RecipeModel>> getAllRecipes();
  Future<RecipeModel?> getRecipeById(String id);
  Future<List<RecipeModel>> getRecipesByCategory(String category);
  Future<List<RecipeModel>> searchRecipes(String query);
  Future<RecipeModel> createRecipe(RecipeModel recipe, {File? imageFile});
  Future<RecipeModel> updateRecipe(RecipeModel recipe, {File? imageFile});
  Future<void> deleteRecipe(String id);
  Future<List<RecipeModel>> getUserRecipes(String userId);
}