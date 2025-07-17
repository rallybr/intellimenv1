import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/models/quiz_model.dart';
import '../../../../shared/providers/quiz_provider.dart';
import '../widgets/question_widget.dart';
import 'quiz_result_page.dart';
import 'package:intellimen/shared/models/user_quiz_model.dart';
import 'package:intellimen/shared/models/quiz_question_model.dart';

class QuizPlayPage extends ConsumerStatefulWidget {
  final UserQuizModel userQuiz;

  const QuizPlayPage({
    super.key,
    required this.userQuiz,
  });

  @override
  ConsumerState<QuizPlayPage> createState() => _QuizPlayPageState();
}

class _QuizPlayPageState extends ConsumerState<QuizPlayPage> {
  int currentQuestionIndex = 0;
  List<QuizQuestionModel> questions = [];
  QuizModel? quiz;
  bool isLoading = true;
  bool isSubmitting = false;
  late UserQuizModel currentUserQuiz;

  @override
  void initState() {
    super.initState();
    currentUserQuiz = widget.userQuiz;
    _loadQuizData();
  }

  Future<void> _loadQuizData() async {
    try {
      // Carregar dados do quiz
      final quizData = await ref.read(quizByIdProvider(widget.userQuiz.quizId).future);
      final questionsData = await ref.read(quizQuestionsProvider(widget.userQuiz.quizId).future);

      if (mounted) {
        setState(() {
          quiz = quizData;
          questions = questionsData;
          isLoading = false;
        });
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar quiz: $error'),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: AppColors.primary,
        appBar: AppBar(
          title: const Text('Carregando Quiz...'),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    if (quiz == null || questions.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.primary,
        appBar: AppBar(
          title: const Text('Erro'),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: const Center(
          child: Text(
            'Erro ao carregar dados do quiz',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        title: Text(quiz!.title),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          // Botão para abandonar quiz
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: _showAbandonDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // Header com progresso
          _buildProgressHeader(),
          
          // Conteúdo da pergunta
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: QuestionWidget(
                question: questions[currentQuestionIndex],
                questionNumber: currentQuestionIndex + 1,
                totalQuestions: questions.length,
                onAnswerSelected: _handleAnswerSelected,
                isSubmitting: isSubmitting,
              ),
            ),
          ),
          
          // Botões de navegação
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildProgressHeader() {
    final progress = (currentQuestionIndex + 1) / questions.length;
    
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Barra de progresso
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.white.withOpacity(0.3),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            minHeight: 8,
          ),
          
          const SizedBox(height: 8),
          
          // Texto de progresso
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Pergunta ${currentQuestionIndex + 1} de ${questions.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // Score atual
          Text(
            'Pontuação: ${currentUserQuiz.score} pontos',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Botão anterior
          if (currentQuestionIndex > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: isSubmitting ? null : _previousQuestion,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Anterior'),
              ),
            ),
          
          if (currentQuestionIndex > 0) const SizedBox(width: 16),
          
          // Botão próximo/finalizar
          Expanded(
            child: ElevatedButton(
              onPressed: isSubmitting ? null : _nextQuestion,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                currentQuestionIndex == questions.length - 1 ? 'Finalizar' : 'Próxima',
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleAnswerSelected(int selectedAnswer) async {
    if (isSubmitting) return;

    setState(() {
      isSubmitting = true;
    });

    try {
      await ref.read(quizNotifierProvider.notifier).answerQuestion(
        userQuizId: currentUserQuiz.id,
        questionId: questions[currentQuestionIndex].id,
        selectedAnswer: selectedAnswer,
      );

      // Atualizar o userQuiz local
      final updatedUserQuiz = currentUserQuiz.copyWith(
        score: currentUserQuiz.score + 
            (questions[currentQuestionIndex].isCorrect(selectedAnswer) ? 1 : 0),
      );

      if (mounted) {
        setState(() {
          // Atualizar o currentUserQuiz
          currentUserQuiz = updatedUserQuiz;
          isSubmitting = false;
        });

        // Mostrar feedback da resposta
        _showAnswerFeedback(selectedAnswer);
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          isSubmitting = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao responder: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showAnswerFeedback(int selectedAnswer) {
    final question = questions[currentQuestionIndex];
    final isCorrect = question.isCorrect(selectedAnswer);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isCorrect ? Icons.check_circle : Icons.cancel,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                isCorrect ? 'Correto!' : 'Incorreto. Resposta correta: ${question.options[question.correctAnswer]}',
              ),
            ),
          ],
        ),
        backgroundColor: isCorrect ? Colors.green : Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _previousQuestion() {
    if (currentQuestionIndex > 0) {
      setState(() {
        currentQuestionIndex--;
      });
    }
  }

  void _nextQuestion() {
    if (currentQuestionIndex < questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
      });
    } else {
      _finishQuiz();
    }
  }

  void _finishQuiz() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Finalizar Quiz'),
        content: const Text('Tem certeza que deseja finalizar o quiz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Finalizar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      _completeQuiz();
    }
  }

  void _completeQuiz() async {
    try {
      final completedQuiz = await ref
          .read(quizNotifierProvider.notifier)
          .completeQuiz(currentUserQuiz.id);

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => QuizResultPage(userQuiz: completedQuiz),
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao finalizar quiz: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showAbandonDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Abandonar Quiz'),
        content: const Text('Tem certeza que deseja abandonar o quiz? Todo o progresso será perdido.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _abandonQuiz();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Abandonar'),
          ),
        ],
      ),
    );
  }

  void _abandonQuiz() async {
    try {
      await ref
          .read(quizNotifierProvider.notifier)
          .abandonQuiz(currentUserQuiz.id);

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao abandonar quiz: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
} 