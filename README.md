# MakeYourMeal

A comprehensive Flutter application for meal planning, recipe management, nutrition tracking, and hydration monitoring. Built with clean architecture principles and modern Flutter practices.

## Features

### 🍽️ Recipe Management
- Create, edit, and delete custom recipes
- Organize recipes by categories (Breakfast, Lunch, Dinner, Snack, Dessert, Appetizer, Beverage)
- Upload recipe images via Cloudinary integration
- Detailed nutrition information tracking
- Search and filter recipes
- Ingredient and instruction management

### 📅 Meal Planning
- Weekly meal planning interface
- Add recipes to specific dates and meal types
- Serving size adjustments
- Visual calendar layout
- Daily calorie tracking from planned meals

### 💧 Water Intake Tracking
- Daily hydration goal setting
- Manual water logging with quick-add buttons (250ml, 500ml, 1L)
- Automatic water intake estimation from planned meals
- Progress visualization with circular indicators
- Motivational messages and inspirational quotes
- Goal achievement tracking

### 📊 Nutrition Tracking
- Comprehensive macro tracking (calories, protein, carbs, fat, fiber)
- Customizable daily nutrition goals
- Visual progress bars for each macro
- Remaining nutrients calculation
- Daily nutrition summaries
- Goal vs actual consumption comparison

### 🔐 Authentication
- Firebase Authentication integration
- Email/password registration and login
- User profile management
- Secure session handling
- Auto-logout functionality

### 🎨 User Interface
- Material 3 design system
- Light and dark theme support
- Responsive layout design
- Intuitive navigation with bottom navigation bar
- Custom styled components
- Beautiful gradients and visual elements

## Technical Architecture

### Clean Architecture Structure
```
lib/
├── core/
│   ├── constants/           # App-wide constants
│   ├── extensions/          # Dart extensions
│   ├── services/           # External services (Cloudinary)
│   ├── theme/              # App theming
│   ├── utils/              # Utility functions
│   └── widgets/            # Reusable widgets
├── features/
│   ├── auth/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   ├── home/
│   ├── meal_plan/
│   ├── nutrition/
│   ├── recipe/
│   └── water_intake/
```

### State Management
- **Riverpod** for state management
- Repository pattern for data layer
- Provider-based dependency injection
- Reactive UI updates

### Data Persistence
- **SharedPreferences** for local data storage
- JSON serialization for complex data structures
- Offline-first approach

### External Services
- **Firebase Authentication** for user management
- **Cloudinary** for image storage and optimization
- **Firebase Core** for app configuration

## Dependencies

### Core Dependencies
```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_riverpod: ^2.6.1
  firebase_core: ^4.0.0
  firebase_auth: ^6.0.1
  cloudinary_public: ^0.23.1
  shared_preferences: ^2.5.3
  image_picker: ^1.2.0
  uuid: ^4.5.1
  cupertino_icons: ^1.0.8
```

### Development Dependencies
```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^6.0.0
```

## Setup Instructions

### Prerequisites
- Flutter SDK (latest stable version)
- Dart SDK
- Firebase project setup
- Cloudinary account (for image uploads)

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd makeyourmeal
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Setup**
   - Create a Firebase project at [Firebase Console](https://console.firebase.google.com)
   - Enable Authentication with Email/Password provider
   - Download and place configuration files:
     - `google-services.json` for Android
     - `GoogleService-Info.plist` for iOS
   - Update `firebase_options.dart` with your project credentials

4. **Cloudinary Setup**
   - Create account at [Cloudinary](https://cloudinary.com)
   - Update `CloudinaryService` in `lib/core/services/cloudinary_service.dart`:
     ```dart
     static const String _cloudName = 'your-cloud-name';
     static const String _uploadPreset = 'your-upload-preset';
     ```

5. **Run the application**
   ```bash
   flutter run
   ```

## Project Structure

### Features Overview

#### Authentication (`features/auth/`)
- Firebase-based user authentication
- Registration and login flows
- Profile management
- Session persistence

#### Recipe Management (`features/recipe/`)
- CRUD operations for recipes
- Image upload and management
- Nutrition data integration
- Category-based organization

#### Meal Planning (`features/meal_plan/`)
- Weekly meal planning
- Recipe assignment to dates
- Serving size calculations
- Nutrition aggregation

#### Water Intake (`features/water_intake/`)
- Daily hydration tracking
- Goal setting and progress monitoring
- Manual and automatic water logging
- Motivational features

#### Nutrition Tracking (`features/nutrition/`)
- Macro nutrient monitoring
- Goal setting for all nutrients
- Progress visualization
- Daily summaries

## Key Models

### Recipe Model
- Complete recipe information including ingredients, instructions, nutrition
- Author tracking and timestamps
- Image URL management
- Serving size calculations

### Food Item Model
- Nutritional information per 100g
- Water content tracking
- Custom vs predefined items
- Category organization

### Meal Plan Model
- Date-based meal organization
- Multiple meal types per day
- Serving size tracking
- Nutrition aggregation

### User Model
- Firebase user integration
- Profile information management
- Creation timestamps

## Usage Guide

### Getting Started
1. Register a new account or login with existing credentials
2. Set up your daily nutrition and hydration goals
3. Create your first recipes or use predefined food items
4. Plan your meals for the week
5. Track your progress on the dashboard

### Creating Recipes
1. Navigate to Recipes tab
2. Tap "Add Recipe" button
3. Fill in recipe details including ingredients and instructions
4. Add nutrition information
5. Upload an image (optional)
6. Save the recipe

### Planning Meals
1. Go to Meal Plan tab
2. Select a date from the weekly view
3. Tap "+" to add a meal
4. Choose meal type (Breakfast, Lunch, Dinner, Snack)
5. Select recipe and serving size
6. Confirm to add to plan

### Tracking Water Intake
1. Access Water Goal from dashboard
2. Use quick-add buttons for common amounts
3. Add custom amounts as needed
4. Set and adjust daily goals
5. Monitor progress throughout the day

### Monitoring Nutrition
1. Access Nutrition from dashboard
2. View daily macro progress
3. Set personalized nutrition goals
4. Track remaining nutrients needed
5. Monitor long-term trends

## Development Notes

### Architecture Decisions
- **Repository Pattern**: Clean separation between data sources and business logic
- **Provider Pattern**: Scalable state management with Riverpod
- **Feature-based Structure**: Modular organization for maintainability
- **Model-driven Development**: Strong typing and data validation

### Performance Considerations
- Lazy loading of images
- Efficient data caching with SharedPreferences
- Optimized Cloudinary image transformations
- Reactive UI updates only when necessary

### Testing Strategy
- Unit tests for business logic
- Widget tests for UI components
- Integration tests for complete flows
- Mock repositories for isolated testing

## Contributing

### Code Style
- Follow Flutter/Dart style guidelines
- Use meaningful variable and function names
- Add documentation for complex logic
- Maintain consistent file organization

### Pull Request Process
1. Fork the repository
2. Create a feature branch
3. Implement changes with tests
4. Update documentation as needed
5. Submit pull request with detailed description

## Troubleshooting

### Common Issues

**Authentication not working after signup**
- Ensure Firebase configuration is correct
- Check network connectivity
- Verify email/password requirements

**Images not uploading**
- Confirm Cloudinary credentials
- Check device permissions for image picker
- Verify network connectivity

**Data not persisting**
- Ensure app has storage permissions
- Check SharedPreferences initialization
- Verify JSON serialization

**White screen on water intake**
- Check provider dependencies
- Verify import statements
- Ensure repository implementations exist

## License

Copyright © 2025, Naheyan Tahmin. All rights reserved.

## Support

For support and questions:
- Create an issue in the repository
- Check existing documentation
- Review common troubleshooting steps

## Roadmap

### Planned Features
- Cloud data synchronization
- Social recipe sharing
- Barcode scanning for food items
- Advanced nutrition analytics
- Export meal plans to calendar
- Grocery list generation
- Recipe recommendations based on preferences

### Technical Improvements
- Offline data synchronization
- Performance optimizations
- Enhanced error handling
- Accessibility improvements
- Comprehensive test coverage