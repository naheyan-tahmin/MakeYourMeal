import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:make_your_meal/features/meal_plan/domain/models/meal_plan_model.dart';
import 'package:make_your_meal/features/meal_plan/presentation/providers/meal_plan_provider.dart';
import 'package:make_your_meal/features/recipe/presentation/providers/recipe_provider.dart';
import 'package:make_your_meal/features/auth/presentation/providers/auth_provider.dart';

class AddMealToPlanView extends ConsumerStatefulWidget {
  final DateTime selectedDate;

  const AddMealToPlanView({super.key, required this.selectedDate});

  @override
  ConsumerState<AddMealToPlanView> createState() => _AddMealToPlanViewState();
}

class _AddMealToPlanViewState extends ConsumerState<AddMealToPlanView> {
  MealType _selectedMealType = MealType.lunch;
  int _servings = 1;
  String? _selectedRecipeId;

  @override
  Widget build(BuildContext context) {
    final recipes = ref.watch(filteredRecipesProvider);
    final user = ref.watch(authStateProvider).value;

    return Scaffold(
      appBar: AppBar(
        title: Text('Add Meal - ${_formatDate(widget.selectedDate)}'),
        actions: [
          TextButton(
            onPressed: _selectedRecipeId != null
                ? () => _addMealToPlan(user?.uid ?? '')
                : null,
            child: const Text('Add'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Meal Type Selection
            Text(
              'Meal Type',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: MealType.values.map((type) {
                return FilterChip(
                  label: Text(type.displayName),
                  selected: _selectedMealType == type,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedMealType = type;
                      });
                    }
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Servings
            Text(
              'Servings',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: _servings > 1
                      ? () => setState(() => _servings--)
                      : null,
                ),
                Text(
                  '$_servings',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => setState(() => _servings++),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Recipe Selection
            Text(
              'Select Recipe',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            
            Expanded(
              child: recipes.isEmpty
                  ? const Center(
                      child: Text('No recipes available. Add some recipes first!'),
                    )
                  : ListView.builder(
                      itemCount: recipes.length,
                      itemBuilder: (context, index) {
                        final recipe = recipes[index];
                        final isSelected = _selectedRecipeId == recipe.id;
                        
                        return Card(
                          color: isSelected 
                              ? Theme.of(context).colorScheme.primaryContainer
                              : null,
                          child: ListTile(
                            leading: recipe.imageUrl != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      recipe.imageUrl!,
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          width: 50,
                                          height: 50,
                                          color: Colors.grey[300],
                                          child: const Icon(Icons.restaurant_menu),
                                        );
                                      },
                                    ),
                                  )
                                : Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[300],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(Icons.restaurant_menu),
                                  ),
                            title: Text(recipe.title),
                            subtitle: Text(
                              '${recipe.prepTimeMinutes + recipe.cookTimeMinutes} min • ${recipe.servings} servings',
                            ),
                            trailing: recipe.nutrition != null
                                ? Text('${recipe.nutrition!.calories.toInt()} cal')
                                : null,
                            selected: isSelected,
                            onTap: () {
                              setState(() {
                                _selectedRecipeId = isSelected ? null : recipe.id;
                              });
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _addMealToPlan(String userId) {
    if (_selectedRecipeId == null) return;

    final selectedRecipe = ref.read(filteredRecipesProvider)
        .firstWhere((recipe) => recipe.id == _selectedRecipeId);

    final plannedMeal = PlannedMeal(
      id: const Uuid().v4(),
      recipe: selectedRecipe,
      mealType: _selectedMealType,
      servings: _servings,
    );

    ref.read(mealPlanProvider.notifier).addMealToPlan(
      userId,
      widget.selectedDate,
      plannedMeal,
    );

    Navigator.pop(context);
  }

  String _formatDate(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                   'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    
    return '${days[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}';
  }
}