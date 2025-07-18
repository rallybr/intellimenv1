class UserQuizModel {
  final String id;
  final String userId;
  final String quizId;
  final String? partnerId; // Para Quiz Duplo
  final int score;
  final int? totalQuestions;
  final DateTime startedAt;
  final DateTime? completedAt;
  final String status; // 'pending_invite', 'waiting_partner', 'in_progress', 'completed', 'abandoned'
  final DateTime createdAt;
  final DateTime? updatedAt; // Novo campo para rastrear atualizações
  final Map<String, dynamic>? answers;
  final bool? isReady; // Novo campo para indicar se o usuário está pronto
  final DateTime? readyAt; // Novo campo para timestamp de quando ficou pronto

  UserQuizModel({
    required this.id,
    required this.userId,
    required this.quizId,
    this.partnerId,
    required this.score,
    this.totalQuestions,
    required this.startedAt,
    this.completedAt,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    this.answers,
    this.isReady,
    this.readyAt,
  });

  factory UserQuizModel.fromJson(Map<String, dynamic> json) {
    return UserQuizModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      quizId: json['quiz_id'] as String,
      partnerId: json['partner_id'] as String?,
      score: json['score'] as int? ?? 0,
      totalQuestions: json['total_questions'] as int?,
      startedAt: DateTime.parse(json['started_at'] as String),
      completedAt: json['completed_at'] != null 
          ? DateTime.parse(json['completed_at'] as String) 
          : null,
      status: json['status'] as String? ?? 'in_progress',
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'] as String) 
          : null,
      answers: json['answers'] as Map<String, dynamic>?,
      isReady: json['is_ready'] as bool? ?? false,
      readyAt: json['ready_at'] != null 
          ? DateTime.parse(json['ready_at'] as String) 
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
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'answers': answers,
      'is_ready': isReady,
      'ready_at': readyAt?.toIso8601String(),
    };
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
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? answers,
    bool? isReady,
    DateTime? readyAt,
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
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      answers: answers ?? this.answers,
      isReady: isReady ?? this.isReady,
      readyAt: readyAt ?? this.readyAt,
    );
  }

  // Getters para verificar status
  bool get isPendingInvite => status == 'pending_invite';
  bool get isWaitingPartner => status == 'waiting_partner';
  bool get isInProgress => status == 'in_progress';
  bool get isCompleted => status == 'completed';
  bool get isAbandoned => status == 'abandoned';
  bool get isPartner => partnerId != null;
  bool get isIndividual => partnerId == null;

  // Calcular porcentagem de acerto
  double get percentage {
    if (totalQuestions == null || totalQuestions == 0) return 0.0;
    return (score / totalQuestions!) * 100;
  }

  // Calcular duração do quiz
  Duration get duration {
    final endTime = completedAt ?? DateTime.now();
    return endTime.difference(startedAt);
  }

  // Formatar duração como texto
  String get durationText {
    final duration = this.duration;
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes}m ${seconds}s';
  }

  // Verificar se ambos os parceiros estão prontos
  bool get bothPartnersReady {
    return isReady == true;
  }

  // Verificar se pode começar o quiz (ambos prontos)
  bool get canStart {
    return isPartner && bothPartnersReady && status == 'waiting_partner';
  }

  @override
  String toString() {
    return 'UserQuizModel(id: $id, userId: $userId, quizId: $quizId, status: $status, score: $score)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserQuizModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
} 