

class WaterIntakeModel {
  final String id;
  final String userId;
  final DateTime date;
  final double manualIntake; // manual water intake in ml
  final double mealBasedIntake; // water from meals in ml
  final DateTime createdAt;
  final DateTime updatedAt;

  const WaterIntakeModel({
    required this.id,
    required this.userId,
    required this.date,
    required this.manualIntake,
    required this.mealBasedIntake,
    required this.createdAt,
    required this.updatedAt,
  });

  double get totalIntake => manualIntake + mealBasedIntake;

  factory WaterIntakeModel.fromJson(Map<String, dynamic> json) {
    return WaterIntakeModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      date: DateTime.parse(json['date'] as String),
      manualIntake: (json['manualIntake'] as num).toDouble(),
      mealBasedIntake: (json['mealBasedIntake'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'date': date.toIso8601String(),
      'manualIntake': manualIntake,
      'mealBasedIntake': mealBasedIntake,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  WaterIntakeModel copyWith({
    String? id,
    String? userId,
    DateTime? date,
    double? manualIntake,
    double? mealBasedIntake,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WaterIntakeModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      manualIntake: manualIntake ?? this.manualIntake,
      mealBasedIntake: mealBasedIntake ?? this.mealBasedIntake,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class WaterGoalModel {
  final String userId;
  final double dailyGoalMl;
  final DateTime updatedAt;

  const WaterGoalModel({
    required this.userId,
    required this.dailyGoalMl,
    required this.updatedAt,
  });

  factory WaterGoalModel.fromJson(Map<String, dynamic> json) {
    return WaterGoalModel(
      userId: json['userId'] as String,
      dailyGoalMl: (json['dailyGoalMl'] as num).toDouble(),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'dailyGoalMl': dailyGoalMl,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}