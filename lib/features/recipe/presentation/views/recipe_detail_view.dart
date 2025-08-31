import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:make_your_meal/features/recipe/domain/models/recipe_model.dart';
import 'package:make_your_meal/features/recipe/presentation/views/add_recipe_view.dart';
import 'package:make_your_meal/features/recipe/presentation/providers/recipe_provider.dart';
import 'package:make_your_meal/features/auth/presentation/providers/auth_provider.dart';
import 'package:make_your_meal/core/services/cloudinary_service.dart';

class RecipeDetailView extends ConsumerWidget {
  final RecipeModel recipe;

  const RecipeDetailView({super.key, required this.recipe});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value;
    final isOwner = user?.uid == recipe.authorId;

    return Scaffold(
      appBar: AppBar(
        title: Text(recipe.title),
        actions: [
          if (isOwner) ...[
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddRecipeView(recipe: recipe),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _showDeleteDialog(context, ref),
            ),
          ],
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Recipe Image
            if (recipe.imageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  CloudinaryService.getOptimizedImageUrl(
                    recipe.imageUrl!,
                    width: 600,
                    height: 300,
                  ),
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 200,
                      color: Colors.grey[300],
                      child: const Icon(Icons.image_not_supported, size: 50),
                    );
                  },
                ),
              ),
            const SizedBox(height: 16),

            // Recipe Info
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(recipe.category.toUpperCase()),
                ),
                const Spacer(),
                Text('By ${recipe.authorName}'),
              ],
            ),
            const SizedBox(height: 16),

            Text(
              recipe.description,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),

            // Time and Servings Info
            Row(
              children: [
                _InfoChip(
                  icon: Icons.schedule,
                  label: 'Prep: ${recipe.prepTimeMinutes}m',
                ),
                const SizedBox(width: 8),
                _InfoChip(
                  icon: Icons.timer,
                  label: 'Cook: ${recipe.cookTimeMinutes}m',
                ),
                const SizedBox(width: 8),
                _InfoChip(
                  icon: Icons.people,
                  label: '${recipe.servings} servings',
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Nutrition Info
            if (recipe.nutrition != null) ...[
              Text(
                'Nutrition Information',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _NutritionItem(
                              label: 'Calories',
                              value: '${recipe.nutrition!.calories.toInt()}',
                              unit: 'kcal',
                            ),
                          ),
                          Expanded(
                            child: _NutritionItem(
                              label: 'Protein',
                              value: '${recipe.nutrition!.protein.toInt()}',
                              unit: 'g',
                            ),
                          ),
                        ],
                      ),
                      const Divider(),
                      Row(
                        children: [
                          Expanded(
                            child: _NutritionItem(
                              label: 'Carbs',
                              value: '${recipe.nutrition!.carbs.toInt()}',
                              unit: 'g',
                            ),
                          ),
                          Expanded(
                            child: _NutritionItem(
                              label: 'Fat',
                              value: '${recipe.nutrition!.fat.toInt()}',
                              unit: 'g',
                            ),
                          ),
                        ],
                      ),
                      const Divider(),
                      Row(
                        children: [
                          Expanded(
                            child: _NutritionItem(
                              label: 'Fiber',
                              value: '${recipe.nutrition!.fiber.toInt()}',
                              unit: 'g',
                            ),
                          ),
                          Expanded(
                            child: _NutritionItem(
                              label: 'Sugar',
                              value: '${recipe.nutrition!.sugar.toInt()}',
                              unit: 'g',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Ingredients
            Text(
              'Ingredients',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...recipe.ingredients.asMap().entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.only(top: 8, right: 12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        entry.value,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 24),

            // Instructions
            Text(
              'Instructions',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...recipe.instructions.asMap().entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${entry.key + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        entry.value,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Recipe'),
        content: Text('Are you sure you want to delete "${recipe.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(recipesProvider.notifier).deleteRecipe(recipe.id);
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to recipes list
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 4),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _NutritionItem extends StatelessWidget {
  final String label;
  final String value;
  final String unit;

  const _NutritionItem({
    required this.label,
    required this.value,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '$value$unit',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}