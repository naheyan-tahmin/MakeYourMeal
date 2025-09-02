
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:make_your_meal/features/recipe/domain/models/food_item_model.dart';
import 'package:make_your_meal/features/recipe/domain/models/recipe_model.dart';
import 'package:make_your_meal/features/recipe/domain/models/recipe_category.dart';
import 'package:make_your_meal/features/recipe/presentation/providers/meal_builder_provider.dart';
import 'package:make_your_meal/features/recipe/presentation/providers/recipe_provider.dart';
import 'package:make_your_meal/features/recipe/presentation/views/add_custom_food_item_view.dart';
import 'package:make_your_meal/features/auth/presentation/providers/auth_provider.dart';
import 'package:make_your_meal/core/services/food_items_service.dart';

class MealBuilderView extends ConsumerStatefulWidget {
  const MealBuilderView({super.key});

  @override
  ConsumerState<MealBuilderView> createState() => _MealBuilderViewState();
}

class _MealBuilderViewState extends ConsumerState<MealBuilderView> {
  final _mealNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final RecipeCategory _selectedCategory = RecipeCategory.lunch;

  @override
  void initState() {
    super.initState();
    // Initialize food items when view loads
    FoodItemsService.initializeFoodItems();
  }

  @override
  void dispose() {
    _mealNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final selectedItems = ref.watch(selectedFoodItemsProvider);
    final mealSummary = ref.watch(mealSummaryProvider);
    final foodItemsAsync = ref.watch(foodItemsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Build Your Meal'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddCustomFoodItemView(),
                ),
              );
            },
          ),
          TextButton(
            onPressed: selectedItems.isNotEmpty ? _saveMealAsRecipe : null,
            child: const Text('Save Meal'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Meal Summary Card
          if (selectedItems.isNotEmpty)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    'Meal Summary',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _SummaryItem(
                        label: 'Calories',
                        value: '${mealSummary.totalCalories.toInt()}',
                        unit: 'kcal',
                        icon: Icons.local_fire_department,
                        color: Colors.orange,
                      ),
                      _SummaryItem(
                        label: 'Protein',
                        value: '${mealSummary.totalProtein.toInt()}',
                        unit: 'g',
                        icon: Icons.fitness_center,
                        color: Colors.red,
                      ),
                      _SummaryItem(
                        label: 'Water',
                        value: '${mealSummary.totalWaterIntake.toInt()}',
                        unit: 'ml',
                        icon: Icons.water_drop,
                        color: Colors.blue,
                      ),
                    ],
                  ),
                ],
              ),
            ),

          // Selected Items List
          if (selectedItems.isNotEmpty)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Selected Items (${selectedItems.length})',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 120,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: selectedItems.length,
                      itemBuilder: (context, index) {
                        final item = selectedItems[index];
                        return _SelectedItemChip(
                          selectedItem: item,
                          onRemove: () {
                            ref.read(selectedFoodItemsProvider.notifier)
                                .removeFoodItem(index);
                          },
                          onQuantityChanged: (newQuantity) {
                            ref.read(selectedFoodItemsProvider.notifier)
                                .updateQuantity(index, newQuantity);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

          // Category Filter
          Container(
            height: 50,
            margin: const EdgeInsets.all(16),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: FoodItemsService.getCategories().length,
              itemBuilder: (context, index) {
                final category = FoodItemsService.getCategories()[index];
                final isSelected = selectedCategory == category;
                
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      ref.read(selectedCategoryProvider.notifier).state = 
                          selected ? category : null;
                    },
                  ),
                );
              },
            ),
          ),

          // Food Items Grid
          Expanded(
            child: foodItemsAsync.when(
              data: (allItems) {
                final filteredItems = selectedCategory != null
                    ? allItems.where((item) => item.category == selectedCategory).toList()
                    : allItems;

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.8,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: filteredItems.length,
                  itemBuilder: (context, index) {
                    final foodItem = filteredItems[index];
                    return _FoodItemCard(
                      foodItem: foodItem,
                      onAdd: (quantity) {
                        ref.read(selectedFoodItemsProvider.notifier)
                            .addFoodItem(foodItem, quantity);
                      },
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('Error: $error')),
            ),
          ),
        ],
      ),
    );
  }

  void _saveMealAsRecipe() {
    showDialog(
      context: context,
      builder: (context) => _SaveMealDialog(
        selectedItems: ref.read(selectedFoodItemsProvider),
        mealSummary: ref.read(mealSummaryProvider),
        onSave: (mealName, description, category) {
          _createRecipeFromMeal(mealName, description, category);
        },
      ),
    );
  }

  void _createRecipeFromMeal(String mealName, String description, RecipeCategory category) {
    final selectedItems = ref.read(selectedFoodItemsProvider);
    final mealSummary = ref.read(mealSummaryProvider);
    final user = ref.read(authStateProvider).value;

    if (user == null) return;

    // Convert selected items to ingredients and instructions
    final ingredients = selectedItems.map((item) => 
        '${item.quantity.toInt()}g ${item.foodItem.name}').toList();
    
    final instructions = [
      'Prepare all ingredients as listed.',
      ...selectedItems.where((item) => !item.foodItem.isLiquid).map((item) => 
          'Add ${item.quantity.toInt()}g of ${item.foodItem.name} to your meal.'),
      if (selectedItems.any((item) => item.foodItem.isLiquid))
        'Serve with beverages: ${selectedItems.where((item) => item.foodItem.isLiquid).map((item) => '${item.quantity.toInt()}ml ${item.foodItem.name}').join(', ')}',
      'Enjoy your balanced meal!'
    ];

    // Create nutrition data from meal summary
    final nutrition = NutritionData(
      calories: mealSummary.totalCalories,
      protein: mealSummary.totalProtein,
      carbs: mealSummary.totalCarbs,
      fat: mealSummary.totalFat,
      fiber: mealSummary.totalFiber,
      sugar: mealSummary.totalSugar,
    );

    final recipe = RecipeModel(
      id: const Uuid().v4(),
      title: mealName,
      description: description,
      ingredients: ingredients,
      instructions: instructions,
      category: category.name,
      prepTimeMinutes: 5,
      cookTimeMinutes: 15,
      servings: 1,
      nutrition: nutrition,
      authorId: user.uid,
      authorName: user.displayName ?? user.email.split('@')[0],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    // Save recipe and clear selected items
    ref.read(recipesProvider.notifier).createRecipe(recipe);
    ref.read(selectedFoodItemsProvider.notifier).clearAll();

    // Show success message and navigate back
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Meal "$mealName" saved as recipe!'),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.pop(context);
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final IconData icon;
  final Color color;

  const _SummaryItem({
    required this.label,
    required this.value,
    required this.unit,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          '$value$unit',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
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

class _SelectedItemChip extends StatelessWidget {
  final SelectedFoodItem selectedItem;
  final VoidCallback onRemove;
  final Function(double) onQuantityChanged;

  const _SelectedItemChip({
    required this.selectedItem,
    required this.onRemove,
    required this.onQuantityChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 8),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                selectedItem.foodItem.name,
                style: Theme.of(context).textTheme.bodySmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              GestureDetector(
                onTap: () => _showQuantityDialog(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${selectedItem.quantity.toInt()}g',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${selectedItem.totalCalories.toInt()} cal',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.orange,
                  fontWeight: FontWeight.w500,
                ),
              ),
              IconButton(
                onPressed: onRemove,
                icon: const Icon(Icons.remove_circle, size: 16),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showQuantityDialog(BuildContext context) {
    final controller = TextEditingController(text: selectedItem.quantity.toInt().toString());
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Update ${selectedItem.foodItem.name}'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Quantity (g)',
            suffixText: 'g',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final newQuantity = double.tryParse(controller.text);
              if (newQuantity != null && newQuantity > 0) {
                onQuantityChanged(newQuantity);
              }
              Navigator.pop(context);
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }
}

class _FoodItemCard extends StatelessWidget {
  final FoodItemModel foodItem;
  final Function(double) onAdd;

  const _FoodItemCard({
    required this.foodItem,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () => _showAddDialog(context),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Food Item Image or Icon
              Expanded(
                child: Center(
                  child: foodItem.imageUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            foodItem.imageUrl!,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildFoodIcon();
                            },
                          ),
                        )
                      : _buildFoodIcon(),
                ),
              ),
              const SizedBox(height: 8),
              
              // Food Name
              Text(
                foodItem.name,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              
              // Calories per serving
              Text(
                '${((foodItem.nutrition.calories * foodItem.defaultServingSize) / 100).toInt()} cal',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.orange,
                ),
              ),
              
              // Category badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  foodItem.category,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFoodIcon() {
    IconData icon;
    switch (foodItem.category.toLowerCase()) {
      case 'grains':
        icon = Icons.grain;
        break;
      case 'protein':
        icon = Icons.egg;
        break;
      case 'fruits':
        icon = Icons.apple;
        break;
      case 'vegetables':
        icon = Icons.eco;
        break;
      case 'nuts':
        icon = Icons.scatter_plot;
        break;
      case 'dairy':
        icon = Icons.local_drink;
        break;
      case 'soups':
        icon = Icons.soup_kitchen;
        break;
      case 'beverages':
        icon = Icons.local_cafe;
        break;
      default:
        icon = Icons.restaurant;
    }
    
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, size: 32, color: Colors.grey[600]),
    );
  }

  void _showAddDialog(BuildContext context) {
    double quantity = foodItem.defaultServingSize;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Add ${foodItem.name}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Quantity: ${quantity.toInt()}g'),
              Slider(
                value: quantity,
                min: 10,
                max: foodItem.defaultServingSize * 3,
                divisions: 20,
                onChanged: (value) => setState(() => quantity = value),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _NutritionPreview(
                    label: 'Cal',
                    value: ((foodItem.nutrition.calories * quantity) / 100).toInt(),
                    color: Colors.orange,
                  ),
                  _NutritionPreview(
                    label: 'Protein',
                    value: ((foodItem.nutrition.protein * quantity) / 100).toInt(),
                    color: Colors.red,
                  ),
                  if (foodItem.isLiquid)
                    _NutritionPreview(
                      label: 'Water',
                      value: quantity.toInt(),
                      color: Colors.blue,
                      unit: 'ml',
                    ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                onAdd(quantity);
                Navigator.pop(context);
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }
}

class _NutritionPreview extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  final String unit;

  const _NutritionPreview({
    required this.label,
    required this.value,
    required this.color,
    this.unit = 'g',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '$value${unit == 'g' && label == 'Cal' ? '' : unit}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
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

class _SaveMealDialog extends StatefulWidget {
  final List<SelectedFoodItem> selectedItems;
  final MealSummary mealSummary;
  final Function(String, String, RecipeCategory) onSave;

  const _SaveMealDialog({
    required this.selectedItems,
    required this.mealSummary,
    required this.onSave,
  });

  @override
  State<_SaveMealDialog> createState() => _SaveMealDialogState();
}

class _SaveMealDialogState extends State<_SaveMealDialog> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  RecipeCategory _category = RecipeCategory.lunch;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Save Your Meal'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Meal Name',
              hintText: 'e.g., Healthy Breakfast Bowl',
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: 'Description',
              hintText: 'Describe your meal...',
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<RecipeCategory>(
            value: _category,
            decoration: const InputDecoration(labelText: 'Category'),
            items: RecipeCategory.values.map((category) {
              return DropdownMenuItem(
                value: category,
                child: Text(category.displayName),
              );
            }).toList(),
            onChanged: (value) => setState(() => _category = value!),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Text(
                  'Meal Summary',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text('${widget.mealSummary.totalCalories.toInt()} calories'),
                Text('${widget.mealSummary.totalWaterIntake.toInt()}ml water intake'),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _nameController.text.isNotEmpty
              ? () {
                  widget.onSave(
                    _nameController.text,
                    _descriptionController.text,
                    _category,
                  );
                  Navigator.pop(context);
                }
              : null,
          child: const Text('Save'),
        ),
      ],
    );
  }
}