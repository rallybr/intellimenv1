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

class UserChallengeModel {
  final String id;
  final String userId;
  final String challengeId;
  final String? partnerId;
  final String status; // 'pending', 'in_progress', 'completed', 'failed'
  final DateTime? startedAt;
  final DateTime? completedAt;
  final String? notes;
  final int? rating;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserChallengeModel({
    required this.id,
    required this.userId,
    required this.challengeId,
    this.partnerId,
    required this.status,
    this.startedAt,
    this.completedAt,
    this.notes,
    this.rating,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserChallengeModel.fromJson(Map<String, dynamic> json) {
    return UserChallengeModel(
      id: json['id'],
      userId: json['user_id'],
      challengeId: json['challenge_id'],
      partnerId: json['partner_id'],
      status: json['status'],
      startedAt: json['started_at'] != null 
          ? DateTime.parse(json['started_at']) 
          : null,
      completedAt: json['completed_at'] != null 
          ? DateTime.parse(json['completed_at']) 
          : null,
      notes: json['notes'],
      rating: json['rating'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'challenge_id': challengeId,
      'partner_id': partnerId,
      'status': status,
      'started_at': startedAt?.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'notes': notes,
      'rating': rating,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  UserChallengeModel copyWith({
    String? id,
    String? userId,
    String? challengeId,
    String? partnerId,
    String? status,
    DateTime? startedAt,
    DateTime? completedAt,
    String? notes,
    int? rating,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserChallengeModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      challengeId: challengeId ?? this.challengeId,
      partnerId: partnerId ?? this.partnerId,
      status: status ?? this.status,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      notes: notes ?? this.notes,
      rating: rating ?? this.rating,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
} 