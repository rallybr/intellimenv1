import 'quiz_model.dart';

class UserQuizModel {
  final String id;
  final String userId;
  final String quizId;
  final String? partnerId;
  final int score;
  final int totalQuestions;
  final DateTime startedAt;
  final DateTime? completedAt;
  final String status;
  final Map<String, dynamic>? answers;
  final DateTime createdAt;
  final QuizModel? quiz;

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
    this.answers,
    required this.createdAt,
    this.quiz,
  });

  factory UserQuizModel.fromJson(Map<String, dynamic> json) {
    return UserQuizModel(
      id: json['id'],
      userId: json['user_id'],
      quizId: json['quiz_id'],
      partnerId: json['partner_id'],
      score: json['score'] ?? 0,
      totalQuestions: json['total_questions'] ?? 0,
      startedAt: DateTime.parse(json['started_at']),
      completedAt: json['completed_at'] != null 
          ? DateTime.parse(json['completed_at']) 
          : null,
      status: json['status'] ?? 'in_progress',
      answers: json['answers'],
      createdAt: DateTime.parse(json['created_at']),
      quiz: json['quizzes'] != null 
          ? QuizModel.fromJson(json['quizzes']) 
          : null,
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
      'answers': answers,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Calcula a porcentagem de acerto
  double get percentage {
    if (totalQuestions == 0) return 0.0;
    return (score / totalQuestions) * 100;
  }

  // Retorna o texto da duração
  String get durationText {
    if (completedAt == null) return 'Em andamento';
    
    final duration = completedAt!.difference(startedAt);
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    
    if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  // Retorna a duração em segundos
  int get durationInSeconds {
    if (completedAt == null) return 0;
    return completedAt!.difference(startedAt).inSeconds;
  }

  // Getter para duração como Duration
  Duration? get duration => completedAt != null ? completedAt!.difference(startedAt) : null;

  // Verifica se o quiz foi completado
  bool get isCompleted => status == 'completed';

  // Verifica se o quiz está em progresso
  bool get isInProgress => status == 'in_progress';

  // Verifica se é um quiz individual
  bool get isIndividual => partnerId == null;

  // Verifica se é um quiz em parceria
  bool get isPartner => partnerId != null;

  // Retorna o texto do resultado baseado na porcentagem
  String get resultText {
    if (percentage >= 90) return 'Excelente! 🏆';
    if (percentage >= 70) return 'Muito Bom! 👍';
    if (percentage >= 50) return 'Bom! 😊';
    return 'Continue Estudando! 📚';
  }

  // Retorna a cor baseada na porcentagem
  String get resultColor {
    if (percentage >= 90) return '#4CAF50'; // Verde
    if (percentage >= 70) return '#8BC34A'; // Verde claro
    if (percentage >= 50) return '#FF9800'; // Laranja
    return '#F44336'; // Vermelho
  }

  UserQuizModel copyWith({
    String? id,
    String? userId,
    String? quizId,
    String? partnerId,
    int? score,
    int? totalQuestions,
    DateTime? startedAt,
    DateTime? completedAt,
    String? status,
    Map<String, dynamic>? answers,
    DateTime? createdAt,
    QuizModel? quiz,
  }) {
    return UserQuizModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      quizId: quizId ?? this.quizId,
      partnerId: partnerId ?? this.partnerId,
      score: score ?? this.score,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      status: status ?? this.status,
      answers: answers ?? this.answers,
      createdAt: createdAt ?? this.createdAt,
      quiz: quiz ?? this.quiz,
    );
  }

  @override
  String toString() {
    return 'UserQuizModel(id: $id, userId: $userId, quizId: $quizId, score: $score, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserQuizModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
} 