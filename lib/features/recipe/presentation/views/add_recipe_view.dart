import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';
import 'package:make_your_meal/features/recipe/domain/models/recipe_model.dart';
import 'package:make_your_meal/features/recipe/domain/models/recipe_category.dart';
import 'package:make_your_meal/features/recipe/presentation/providers/recipe_provider.dart';
import 'package:make_your_meal/features/auth/presentation/providers/auth_provider.dart';
import 'package:make_your_meal/core/utils/validators.dart';

class AddRecipeView extends ConsumerStatefulWidget {
  final RecipeModel? recipe; // For editing

  const AddRecipeView({super.key, this.recipe});

  @override
  ConsumerState<AddRecipeView> createState() => _AddRecipeViewState();
}

class _AddRecipeViewState extends ConsumerState<AddRecipeView> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _prepTimeController = TextEditingController();
  final _cookTimeController = TextEditingController();
  final _servingsController = TextEditingController();
  
  // Nutrition controllers
  final _caloriesController = TextEditingController();
  final _proteinController = TextEditingController();
  final _carbsController = TextEditingController();
  final _fatController = TextEditingController();
  final _fiberController = TextEditingController();
  final _sugarController = TextEditingController();

  List<String> _ingredients = [''];
  List<String> _instructions = [''];
  RecipeCategory _selectedCategory = RecipeCategory.lunch;
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  bool get _isEditing => widget.recipe != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _populateFields();
    }
  }

  void _populateFields() {
    final recipe = widget.recipe!;
    _titleController.text = recipe.title;
    _descriptionController.text = recipe.description;
    _prepTimeController.text = recipe.prepTimeMinutes.toString();
    _cookTimeController.text = recipe.cookTimeMinutes.toString();
    _servingsController.text = recipe.servings.toString();
    _selectedCategory = RecipeCategory.fromString(recipe.category);
    _ingredients = List.from(recipe.ingredients);
    _instructions = List.from(recipe.instructions);
    
    if (recipe.nutrition != null) {
      _caloriesController.text = recipe.nutrition!.calories.toString();
      _proteinController.text = recipe.nutrition!.protein.toString();
      _carbsController.text = recipe.nutrition!.carbs.toString();
      _fatController.text = recipe.nutrition!.fat.toString();
      _fiberController.text = recipe.nutrition!.fiber.toString();
      _sugarController.text = recipe.nutrition!.sugar.toString();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _prepTimeController.dispose();
    _cookTimeController.dispose();
    _servingsController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    _fiberController.dispose();
    _sugarController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  void _addIngredient() {
    setState(() {
      _ingredients.add('');
    });
  }

  void _removeIngredient(int index) {
    if (_ingredients.length > 1) {
      setState(() {
        _ingredients.removeAt(index);
      });
    }
  }

  void _addInstruction() {
    setState(() {
      _instructions.add('');
    });
  }

  void _removeInstruction(int index) {
    if (_instructions.length > 1) {
      setState(() {
        _instructions.removeAt(index);
      });
    }
  }

  Future<void> _saveRecipe() async {
    if (!_formKey.currentState!.validate()) return;

    final user = ref.read(authStateProvider).value;
    if (user == null) return;

    final filteredIngredients = _ingredients.where((i) => i.trim().isNotEmpty).toList();
    final filteredInstructions = _instructions.where((i) => i.trim().isNotEmpty).toList();

    if (filteredIngredients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one ingredient')),
      );
      return;
    }

    if (filteredInstructions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one instruction')),
      );
      return;
    }

    NutritionData? nutrition;
    if (_caloriesController.text.isNotEmpty) {
      nutrition = NutritionData(
        calories: double.tryParse(_caloriesController.text) ?? 0,
        protein: double.tryParse(_proteinController.text) ?? 0,
        carbs: double.tryParse(_carbsController.text) ?? 0,
        fat: double.tryParse(_fatController.text) ?? 0,
        fiber: double.tryParse(_fiberController.text) ?? 0,
        sugar: double.tryParse(_sugarController.text) ?? 0,
      );
    }

    final recipe = RecipeModel(
      id: _isEditing ? widget.recipe!.id : const Uuid().v4(),
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      ingredients: filteredIngredients,
      instructions: filteredInstructions,
      category: _selectedCategory.name,
      prepTimeMinutes: int.parse(_prepTimeController.text),
      cookTimeMinutes: int.parse(_cookTimeController.text),
      servings: int.parse(_servingsController.text),
      imageUrl: _isEditing ? widget.recipe!.imageUrl : null,
      nutrition: nutrition,
      authorId: user.uid,
      authorName: user.displayName ?? user.email.split('@')[0],
      createdAt: _isEditing ? widget.recipe!.createdAt : DateTime.now(),
      updatedAt: DateTime.now(),
    );

    if (_isEditing) {
      await ref.read(recipesProvider.notifier).updateRecipe(recipe, imageFile: _selectedImage);
    } else {
      await ref.read(recipesProvider.notifier).createRecipe(recipe, imageFile: _selectedImage);
    }

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final recipeState = ref.watch(recipesProvider);

    ref.listen<RecipeState>(recipesProvider, (previous, next) {
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: Colors.red,
          ),
        );
        ref.read(recipesProvider.notifier).clearError();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Recipe' : 'Add Recipe'),
        actions: [
          TextButton(
            onPressed: recipeState.isLoading ? null : _saveRecipe,
            child: recipeState.isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(_isEditing ? 'Update' : 'Save'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Image Section
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: _selectedImage != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          _selectedImage!,
                          fit: BoxFit.cover,
                        ),
                      )
                    : (_isEditing && widget.recipe!.imageUrl != null)
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              widget.recipe!.imageUrl!,
                              fit: BoxFit.cover,
                            ),
                          )
                        : const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_a_photo, size: 50, color: Colors.grey),
                              SizedBox(height: 8),
                              Text('Tap to add image'),
                            ],
                          ),
              ),
            ),
            const SizedBox(height: 24),

            // Basic Info
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Recipe Title'),
              validator: (value) => Validators.required(value, 'Title'),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 3,
              validator: (value) => Validators.required(value, 'Description'),
            ),
            const SizedBox(height: 16),

            // Category Dropdown
            DropdownButtonFormField<RecipeCategory>(
              value: _selectedCategory,
              decoration: const InputDecoration(labelText: 'Category'),
              items: RecipeCategory.values.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category.displayName),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value!;
                });
              },
            ),
            const SizedBox(height: 16),

            // Time and Servings
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _prepTimeController,
                    decoration: const InputDecoration(labelText: 'Prep Time (min)'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Required';
                      if (int.tryParse(value) == null) return 'Invalid number';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _cookTimeController,
                    decoration: const InputDecoration(labelText: 'Cook Time (min)'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Required';
                      if (int.tryParse(value) == null) return 'Invalid number';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _servingsController,
                    decoration: const InputDecoration(labelText: 'Servings'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Required';
                      if (int.tryParse(value) == null) return 'Invalid number';
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Ingredients Section
            Text(
              'Ingredients',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ..._ingredients.asMap().entries.map((entry) {
              final index = entry.key;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        initialValue: entry.value,
                        decoration: InputDecoration(
                          labelText: 'Ingredient ${index + 1}',
                        ),
                        onChanged: (value) {
                          _ingredients[index] = value;
                        },
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.remove_circle),
                      onPressed: () => _removeIngredient(index),
                    ),
                  ],
                ),
              );
            }),
            ElevatedButton.icon(
              onPressed: _addIngredient,
              icon: const Icon(Icons.add),
              label: const Text('Add Ingredient'),
            ),
            const SizedBox(height: 24),

            // Instructions Section
            Text(
              'Instructions',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ..._instructions.asMap().entries.map((entry) {
              final index = entry.key;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextFormField(
                        initialValue: entry.value,
                        decoration: InputDecoration(
                          labelText: 'Step ${index + 1}',
                        ),
                        maxLines: 3,
                        onChanged: (value) {
                          _instructions[index] = value;
                        },
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.remove_circle),
                      onPressed: () => _removeInstruction(index),
                    ),
                  ],
                ),
              );
            }),
            ElevatedButton.icon(
              onPressed: _addInstruction,
              icon: const Icon(Icons.add),
              label: const Text('Add Instruction'),
            ),
            const SizedBox(height: 24),

            // Nutrition Section (Optional)
            Text(
              'Nutrition Information (Optional)',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _caloriesController,
                    decoration: const InputDecoration(labelText: 'Calories'),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _proteinController,
                    decoration: const InputDecoration(labelText: 'Protein (g)'),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _carbsController,
                    decoration: const InputDecoration(labelText: 'Carbs (g)'),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _fatController,
                    decoration: const InputDecoration(labelText: 'Fat (g)'),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _fiberController,
                    decoration: const InputDecoration(labelText: 'Fiber (g)'),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _sugarController,
                    decoration: const InputDecoration(labelText: 'Sugar (g)'),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
