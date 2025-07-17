class QuizModel {
  final String id;
  final String title;
  final String description;
  final String type; // 'individual' or 'partner'
  final String category;
  final int difficulty;
  final bool isActive;
  final DateTime createdAt;

  QuizModel({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.category,
    required this.difficulty,
    required this.isActive,
    required this.createdAt,
  });

  factory QuizModel.fromJson(Map<String, dynamic> json) {
    return QuizModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      type: json['type'],
      category: json['category'],
      difficulty: json['difficulty'],
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type,
      'category': category,
      'difficulty': difficulty,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
    };
  }

  QuizModel copyWith({
    String? id,
    String? title,
    String? description,
    String? type,
    String? category,
    int? difficulty,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return QuizModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      category: category ?? this.category,
      difficulty: difficulty ?? this.difficulty,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  bool get isIndividual => type == 'individual';
  bool get isPartner => type == 'partner';
  
  String get difficultyText {
    switch (difficulty) {
      case 1: return 'Fácil';
      case 2: return 'Médio';
      case 3: return 'Difícil';
      default: return 'Não definido';
    }
  }
} 