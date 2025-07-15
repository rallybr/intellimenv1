class UserChallengeModel {
  final String id;
  final String userId;
  final String partnerId;
  final String challengeId;
  final String status;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final String? notes;
  final int? rating;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserChallengeModel({
    required this.id,
    required this.userId,
    required this.partnerId,
    required this.challengeId,
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
      partnerId: json['partner_id'],
      challengeId: json['challenge_id'],
      status: json['status'],
      startedAt: json['started_at'] != null ? DateTime.tryParse(json['started_at']) : null,
      completedAt: json['completed_at'] != null ? DateTime.tryParse(json['completed_at']) : null,
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
      'partner_id': partnerId,
      'challenge_id': challengeId,
      'status': status,
      'started_at': startedAt?.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'notes': notes,
      'rating': rating,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
} 