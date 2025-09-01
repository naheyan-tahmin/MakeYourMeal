// File: lib/features/recipe/presentation/views/add_custom_food_item_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:make_your_meal/features/recipe/domain/models/food_item_model.dart';
import 'package:make_your_meal/core/services/food_items_service.dart';
import 'package:make_your_meal/features/recipe/presentation/providers/meal_builder_provider.dart';

class AddCustomFoodItemView extends ConsumerStatefulWidget {
  const AddCustomFoodItemView({super.key});

  @override
  ConsumerState<AddCustomFoodItemView> createState() => _AddCustomFoodItemViewState();
}

class _AddCustomFoodItemViewState extends ConsumerState<AddCustomFoodItemView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _categoryController = TextEditingController();
  final _servingSizeController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _proteinController = TextEditingController();
  final _carbsController = TextEditingController();
  final _fatController = TextEditingController();
  final _fiberController = TextEditingController();
  final _sugarController = TextEditingController();
  final _waterContentController = TextEditingController();

  String _selectedCategory = 'Custom';
  bool _isLiquid = false;
  File? _selectedImage;
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _servingSizeController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    _fiberController.dispose();
    _sugarController.dispose();
    _waterContentController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );
    
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  Future<void> _saveFoodItem() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final nutrition = NutritionPer100g(
        calories: double.parse(_caloriesController.text),
        protein: double.parse(_proteinController.text),
        carbs: double.parse(_carbsController.text),
        fat: double.parse(_fatController.text),
        fiber: double.parse(_fiberController.text),
        sugar: double.parse(_sugarController.text),
        waterContent: double.parse(_waterContentController.text),
      );

      await FoodItemsService.addCustomFoodItem(
        _nameController.text.trim(),
        _selectedCategory,
        nutrition,
        double.parse(_servingSizeController.text),
        imageFile: _selectedImage,
        isLiquid: _isLiquid,
      );

      // Refresh the food items provider
      ref.invalidate(foodItemsProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Food item added successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding food item: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = [...FoodItemsService.getCategories(), 'Custom'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Custom Food Item'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveFoodItem,
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save'),
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
                height: 150,
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
                    : const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_a_photo, size: 40, color: Colors.grey),
                          SizedBox(height: 8),
                          Text('Tap to add image'),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 24),

            // Basic Information
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Food Name *',
                hintText: 'e.g., Homemade Smoothie',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Food name is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              initialValue: _selectedCategory,
              decoration: const InputDecoration(labelText: 'Category'),
              items: categories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value!;
                });
              },
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _servingSizeController,
              decoration: const InputDecoration(
                labelText: 'Default Serving Size (g/ml) *',
                hintText: '100',
                suffixText: 'g/ml',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) return 'Required';
                if (double.tryParse(value) == null || double.parse(value) <= 0) {
                  return 'Enter a valid positive number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            SwitchListTile(
              title: const Text('Is this a liquid/beverage?'),
              subtitle: const Text('This affects water intake calculations'),
              value: _isLiquid,
              onChanged: (value) {
                setState(() {
                  _isLiquid = value;
                });
              },
            ),
            const SizedBox(height: 24),

            // Nutrition Information Section
            Text(
              'Nutrition Information (per 100g)',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Enter nutritional values per 100g of this food item',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _caloriesController,
                    decoration: const InputDecoration(
                      labelText: 'Calories *',
                      suffixText: 'kcal',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Required';
                      if (double.tryParse(value) == null || double.parse(value) < 0) {
                        return 'Enter a valid number';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _proteinController,
                    decoration: const InputDecoration(
                      labelText: 'Protein *',
                      suffixText: 'g',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Required';
                      if (double.tryParse(value) == null || double.parse(value) < 0) {
                        return 'Enter a valid number';
                      }
                      return null;
                    },
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
                    decoration: const InputDecoration(
                      labelText: 'Carbohydrates *',
                      suffixText: 'g',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Required';
                      if (double.tryParse(value) == null || double.parse(value) < 0) {
                        return 'Enter a valid number';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _fatController,
                    decoration: const InputDecoration(
                      labelText: 'Fat *',
                      suffixText: 'g',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Required';
                      if (double.tryParse(value) == null || double.parse(value) < 0) {
                        return 'Enter a valid number';
                      }
                      return null;
                    },
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
                    decoration: const InputDecoration(
                      labelText: 'Fiber',
                      suffixText: 'g',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        if (double.tryParse(value) == null || double.parse(value) < 0) {
                          return 'Enter a valid number';
                        }
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _sugarController,
                    decoration: const InputDecoration(
                      labelText: 'Sugar',
                      suffixText: 'g',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        if (double.tryParse(value) == null || double.parse(value) < 0) {
                          return 'Enter a valid number';
                        }
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _waterContentController,
              decoration: const InputDecoration(
                labelText: 'Water Content',
                suffixText: 'ml per 100g',
                hintText: '0',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  if (double.tryParse(value) == null || double.parse(value) < 0 || double.parse(value) > 100) {
                    return 'Enter a number between 0-100';
                  }
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Nutrition Tips Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        color: Theme.of(context).colorScheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Nutrition Tips',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• You can find nutrition information on food packaging labels\n'
                    '• Use nutrition databases like USDA FoodData Central for reference\n'
                    '• For liquids, set water content to 100ml per 100g\n'
                    '• Leave fiber and sugar empty if unknown (will default to 0)',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}