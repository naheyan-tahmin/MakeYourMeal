import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:make_your_meal/features/recipe/presentation/providers/recipe_provider.dart';
import 'package:make_your_meal/features/recipe/presentation/views/add_recipe_view.dart';
import 'package:make_your_meal/features/recipe/presentation/views/recipe_detail_view.dart';
import 'package:make_your_meal/features/recipe/domain/models/recipe_category.dart';
import 'package:make_your_meal/core/services/cloudinary_service.dart';
import 'package:make_your_meal/features/recipe/domain/models/recipe_model.dart';

class RecipesListView extends ConsumerWidget {
  const RecipesListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recipeState = ref.watch(recipesProvider);
    final filteredRecipes = ref.watch(filteredRecipesProvider);
    final searchQuery = ref.watch(recipeSearchProvider);
    final selectedCategory = ref.watch(recipeCategoryFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recipes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddRecipeView(),
                ),
              );
            },
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
                hintText: 'Search recipes...',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),

          // Category Filter
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

          // Recipes List
          Expanded(
            child: recipeState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredRecipes.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.restaurant_menu,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              searchQuery.isNotEmpty 
                                  ? 'No recipes found for "$searchQuery"'
                                  : 'No recipes yet. Add your first recipe!',
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredRecipes.length,
                        itemBuilder: (context, index) {
                          final recipe = filteredRecipes[index];
                          return RecipeCard(recipe: recipe);
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class RecipeCard extends StatelessWidget {
  final RecipeModel recipe;

  const RecipeCard({super.key, required this.recipe});

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
