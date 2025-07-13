class QuizModel {
  final String id;
  final String title;
  final String description;
  final String type; // 'partner' or 'individual'
  final String category;
  final int difficulty;
  final DateTime createdAt;
  final bool isActive;

  QuizModel({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.category,
    required this.difficulty,
    required this.createdAt,
    required this.isActive,
  });

  factory QuizModel.fromJson(Map<String, dynamic> json) {
    return QuizModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      type: json['type'],
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
      'type': type,
      'category': category,
      'difficulty': difficulty,
      'created_at': createdAt.toIso8601String(),
      'is_active': isActive,
    };
  }
}

class QuizQuestionModel {
  final String id;
  final String quizId;
  final String question;
  final List<String> options;
  final int correctAnswer;
  final String? explanation;
  final DateTime createdAt;

  QuizQuestionModel({
    required this.id,
    required this.quizId,
    required this.question,
    required this.options,
    required this.correctAnswer,
    this.explanation,
    required this.createdAt,
  });

  factory QuizQuestionModel.fromJson(Map<String, dynamic> json) {
    return QuizQuestionModel(
      id: json['id'],
      quizId: json['quiz_id'],
      question: json['question'],
      options: List<String>.from(json['options']),
      correctAnswer: json['correct_answer'],
      explanation: json['explanation'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'quiz_id': quizId,
      'question': question,
      'options': options,
      'correct_answer': correctAnswer,
      'explanation': explanation,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class UserQuizModel {
  final String id;
  final String userId;
  final String quizId;
  final String? partnerId;
  final int score;
  final int totalQuestions;
  final DateTime startedAt;
  final DateTime? completedAt;
  final String status; // 'in_progress', 'completed', 'abandoned'
  final DateTime createdAt;

  UserQuizModel({
    required this.id,
    required this.userId,
    required this.quizId,
    this.partnerId,
    required this.score,
    required this.totalQuestions,
    required this.startedAt,
    this.completedAt,
    required this.status,
    required this.createdAt,
  });

  factory UserQuizModel.fromJson(Map<String, dynamic> json) {
    return UserQuizModel(
      id: json['id'],
      userId: json['user_id'],
      quizId: json['quiz_id'],
      partnerId: json['partner_id'],
      score: json['score'],
      totalQuestions: json['total_questions'],
      startedAt: DateTime.parse(json['started_at']),
      completedAt: json['completed_at'] != null 
          ? DateTime.parse(json['completed_at']) 
          : null,
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'quiz_id': quizId,
      'partner_id': partnerId,
      'score': score,
      'total_questions': totalQuestions,
      'started_at': startedAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }

  double get percentage => (score / totalQuestions) * 100;
} 