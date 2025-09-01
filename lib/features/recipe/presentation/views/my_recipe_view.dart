// File: lib/features/recipe/presentation/views/my_recipes_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:make_your_meal/features/recipe/domain/models/recipe_model.dart';
import 'package:make_your_meal/features/recipe/presentation/providers/user_recipe_provider.dart';
import 'package:make_your_meal/features/recipe/presentation/providers/recipe_provider.dart';
import 'package:make_your_meal/features/recipe/presentation/views/add_recipe_view.dart';
import 'package:make_your_meal/features/recipe/presentation/views/meal_builder_view.dart';
import 'package:make_your_meal/features/recipe/presentation/views/recipe_detail_view.dart';
import 'package:make_your_meal/features/recipe/domain/models/recipe_category.dart';
import 'package:make_your_meal/features/auth/presentation/providers/auth_provider.dart';
import 'package:make_your_meal/core/services/cloudinary_service.dart';

class MyRecipesView extends ConsumerWidget {
  const MyRecipesView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value;
    final userId = user?.uid;
    
    final userRecipes = ref.watch(filteredUserRecipesProvider(userId));
    final searchQuery = ref.watch(recipeSearchProvider);
    final selectedCategory = ref.watch(recipeCategoryFilterProvider);
    final recipeState = ref.watch(recipesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Recipes'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'add_traditional') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddRecipeView(),
                  ),
                );
              } else if (value == 'build_meal') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MealBuilderView(),
                  ),
                );
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'build_meal',
                child: Row(
                  children: [
                    Icon(Icons.build_circle),
                    SizedBox(width: 8),
                    Text('Build Meal'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'add_traditional',
                child: Row(
                  children: [
                    Icon(Icons.edit_note),
                    SizedBox(width: 8),
                    Text('Add Traditional Recipe'),
                  ],
                ),
              ),
            ],
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.add,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (value) {
                ref.read(recipeSearchProvider.notifier).state = value;
              },
              decoration: const InputDecoration(
                hintText: 'Search your recipes...',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),

          // Quick Action Cards (only show if user has no recipes)
          if (userRecipes.isEmpty && searchQuery.isEmpty)
            Container(
              height: 100,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: _QuickActionCard(
                      title: 'Build Meal',
                      subtitle: 'Create your first recipe',
                      icon: Icons.build_circle,
                      color: Colors.green,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MealBuilderView(),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _QuickActionCard(
                      title: 'Add Recipe',
                      subtitle: 'Write manually',
                      icon: Icons.edit_note,
                      color: Colors.blue,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AddRecipeView(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

          // Category Filter (only show if user has recipes)
          if (userRecipes.isNotEmpty || searchQuery.isNotEmpty)
            SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: RecipeCategory.values.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: const Text('All'),
                        selected: selectedCategory == null,
                        onSelected: (selected) {
                          ref.read(recipeCategoryFilterProvider.notifier).state = null;
                        },
                      ),
                    );
                  }
                  
                  final category = RecipeCategory.values[index - 1];
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(category.displayName),
                      selected: selectedCategory == category.name,
                      onSelected: (selected) {
                        ref.read(recipeCategoryFilterProvider.notifier).state = 
                            selected ? category.name : null;
                      },
                    ),
                  );
                },
              ),
            ),

          // Recipe Count Header
          if (userRecipes.isNotEmpty || searchQuery.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Text(
                    '${userRecipes.length} recipe${userRecipes.length == 1 ? '' : 's'}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (searchQuery.isNotEmpty || selectedCategory != null) ...[
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () {
                        ref.read(recipeSearchProvider.notifier).state = '';
                        ref.read(recipeCategoryFilterProvider.notifier).state = null;
                      },
                      child: const Text('Clear filters'),
                    ),
                  ],
                ],
              ),
            ),

          // Recipes List
          Expanded(
            child: recipeState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : userRecipes.isEmpty
                    ? _buildEmptyState(context, searchQuery, selectedCategory)
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: userRecipes.length,
                        itemBuilder: (context, index) {
                          final recipe = userRecipes[index];
                          return _RecipeCard(recipe: recipe);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, String searchQuery, String? selectedCategory) {
    if (searchQuery.isNotEmpty || selectedCategory != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No recipes found',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              searchQuery.isNotEmpty 
                  ? 'Try a different search term'
                  : 'Try selecting a different category',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.restaurant_menu,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 24),
          Text(
            'No recipes yet',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start building your personal recipe collection',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MealBuilderView(),
                    ),
                  );
                },
                icon: const Icon(Icons.build_circle),
                label: const Text('Build Meal'),
              ),
              const SizedBox(width: 16),
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddRecipeView(),
                    ),
                  );
                },
                icon: const Icon(Icons.edit_note),
                label: const Text('Add Recipe'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecipeCard extends StatelessWidget {
  final RecipeModel recipe;

  const _RecipeCard({required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RecipeDetailView(recipe: recipe),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Recipe Image
            if (recipe.imageUrl != null)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.network(
                  CloudinaryService.getOptimizedImageUrl(
                    recipe.imageUrl!,
                    width: 400,
                    height: 200,
                  ),
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 150,
                      color: Colors.grey[300],
                      child: const Icon(Icons.image_not_supported, size: 50),
                    );
                  },
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          recipe.title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          recipe.category,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    recipe.description,
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.schedule, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        '${recipe.prepTimeMinutes + recipe.cookTimeMinutes} min',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(width: 16),
                      Icon(Icons.people, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        '${recipe.servings} servings',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      if (recipe.nutrition != null) ...[
                        const SizedBox(width: 16),
                        Icon(Icons.local_fire_department, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          '${recipe.nutrition!.calories.toInt()} cal',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}