class ChallengeModel {
  final String id;
  final String title;
  final String description;
  final int weekNumber;
  final String category;
  final int difficulty;
  final DateTime createdAt;
  final bool isActive;

  ChallengeModel({
    required this.id,
    required this.title,
    required this.description,
    required this.weekNumber,
    required this.category,
    required this.difficulty,
    required this.createdAt,
    required this.isActive,
  });

  factory ChallengeModel.fromJson(Map<String, dynamic> json) {
    return ChallengeModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      weekNumber: json['week_number'],
      category: json['category'],
      difficulty: json['difficulty'],
      createdAt: DateTime.parse(json['created_at']),
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'week_number': weekNumber,
      'category': category,
      'difficulty': difficulty,
      'created_at': createdAt.toIso8601String(),
      'is_active': isActive,
    };
  }
} 