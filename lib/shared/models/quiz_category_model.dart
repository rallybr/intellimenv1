class QuizCategoryModel {
  final String id;
  final String name;
  final String description;
  final DateTime createdAt;

  QuizCategoryModel({
    required this.id,
    required this.name,
    required this.description,
    required this.createdAt,
  });

  factory QuizCategoryModel.fromJson(Map<String, dynamic> json) {
    return QuizCategoryModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'created_at': createdAt.toIso8601String(),
    };
  }

  QuizCategoryModel copyWith({
    String? id,
    String? name,
    String? description,
    DateTime? createdAt,
  }) {
    return QuizCategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'QuizCategoryModel(id: $id, name: $name)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is QuizCategoryModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
} 