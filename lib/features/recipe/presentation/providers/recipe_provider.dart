import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:make_your_meal/features/recipe/domain/models/recipe_model.dart';
import 'package:make_your_meal/features/recipe/domain/repositories/recipe_repository.dart';
import 'package:make_your_meal/features/recipe/data/repositories/local_recipe_repository.dart';
import 'dart:io';

final recipeRepositoryProvider = Provider<RecipeRepository>((ref) {
  return LocalRecipeRepository();
});

final recipesProvider = StateNotifierProvider<RecipeViewModel, RecipeState>((ref) {
  final repository = ref.watch(recipeRepositoryProvider);
  return RecipeViewModel(repository);
});

final filteredRecipesProvider = Provider<List<RecipeModel>>((ref) {
  final state = ref.watch(recipesProvider);
  final searchQuery = ref.watch(recipeSearchProvider);
  final selectedCategory = ref.watch(recipeCategoryFilterProvider);
  
  List<RecipeModel> recipes = state.recipes;
  
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

final recipeSearchProvider = StateProvider<String>((ref) => '');
final recipeCategoryFilterProvider = StateProvider<String?>((ref) => null);

class RecipeState {
  final List<RecipeModel> recipes;
  final bool isLoading;
  final String? error;

  const RecipeState({
    this.recipes = const [],
    this.isLoading = false,
    this.error,
  });

  RecipeState copyWith({
    List<RecipeModel>? recipes,
    bool? isLoading,
    String? error,
  }) {
    return RecipeState(
      recipes: recipes ?? this.recipes,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class RecipeViewModel extends StateNotifier<RecipeState> {
  final RecipeRepository _repository;

  RecipeViewModel(this._repository) : super(const RecipeState()) {
    loadRecipes();
  }

  Future<void> loadRecipes() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final recipes = await _repository.getAllRecipes();
      state = state.copyWith(recipes: recipes, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> createRecipe(RecipeModel recipe, {File? imageFile}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final newRecipe = await _repository.createRecipe(recipe, imageFile: imageFile);
      final updatedRecipes = [...state.recipes, newRecipe];
      state = state.copyWith(recipes: updatedRecipes, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> updateRecipe(RecipeModel recipe, {File? imageFile}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final updatedRecipe = await _repository.updateRecipe(recipe, imageFile: imageFile);
      final updatedRecipes = state.recipes.map((r) => 
          r.id == recipe.id ? updatedRecipe : r).toList();
      state = state.copyWith(recipes: updatedRecipes, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> deleteRecipe(String id) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.deleteRecipe(id);
      final updatedRecipes = state.recipes.where((r) => r.id != id).toList();
      state = state.copyWith(recipes: updatedRecipes, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}