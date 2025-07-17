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
      options: List<String>.from(json['options'] ?? []),
      correctAnswer: json['correct_answer'] ?? 0,
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

  // Verifica se uma resposta está correta
  bool isCorrectAnswer(int selectedOption) {
    return selectedOption == correctAnswer;
  }

  // Alias para compatibilidade
  bool isCorrect(int selectedOption) => isCorrectAnswer(selectedOption);

  // Retorna a opção correta
  String get correctOption {
    if (correctAnswer >= 0 && correctAnswer < options.length) {
      return options[correctAnswer];
    }
    return '';
  }

  // Retorna a letra da opção (A, B, C, D)
  String getOptionLetter(int index) {
    if (index >= 0 && index < 26) {
      return String.fromCharCode(65 + index); // A = 65 em ASCII
    }
    return '';
  }

  // Retorna todas as opções com letras
  List<Map<String, String>> get optionsWithLetters {
    return options.asMap().entries.map((entry) {
      return {
        'letter': getOptionLetter(entry.key),
        'text': entry.value,
      };
    }).toList();
  }

  QuizQuestionModel copyWith({
    String? id,
    String? quizId,
    String? question,
    List<String>? options,
    int? correctAnswer,
    String? explanation,
    DateTime? createdAt,
  }) {
    return QuizQuestionModel(
      id: id ?? this.id,
      quizId: quizId ?? this.quizId,
      question: question ?? this.question,
      options: options ?? this.options,
      correctAnswer: correctAnswer ?? this.correctAnswer,
      explanation: explanation ?? this.explanation,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'QuizQuestionModel(id: $id, quizId: $quizId, question: $question)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is QuizQuestionModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
} 