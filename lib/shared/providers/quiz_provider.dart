import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/quiz_model.dart';
import 'package:intellimen/shared/models/quiz_question_model.dart';
import 'package:intellimen/shared/models/user_quiz_model.dart';
import '../../core/services/supabase_service.dart';
import 'auth_provider.dart';

// Provider para listar todos os quizzes ativos
final quizzesProvider = FutureProvider<List<QuizModel>>((ref) async {
  final supabaseService = ref.watch(supabaseServiceProvider);
  return await supabaseService.getQuizzes();
});

// Provider para quizzes individuais
final individualQuizzesProvider = FutureProvider<List<QuizModel>>((ref) async {
  final quizzes = await ref.watch(quizzesProvider.future);
  return quizzes.where((quiz) => quiz.isIndividual).toList();
});

// Provider para quizzes em parceria
final partnerQuizzesProvider = FutureProvider<List<QuizModel>>((ref) async {
  final quizzes = await ref.watch(quizzesProvider.future);
  return quizzes.where((quiz) => quiz.isPartner).toList();
});



// Provider para buscar perguntas de um quiz
final quizQuestionsProvider = FutureProvider.family<List<QuizQuestionModel>, String>((ref, quizId) async {
  final supabaseService = ref.watch(supabaseServiceProvider);
  return await supabaseService.getQuizQuestions(quizId);
});

// Provider para quizzes do usuário atual
final userQuizzesProvider = FutureProvider<List<UserQuizModel>>((ref) async {
  final supabaseService = ref.watch(supabaseServiceProvider);
  final currentUser = supabaseService.currentUser;
  if (currentUser == null) return [];
  return await supabaseService.getUserQuizzes(currentUser.id);
});

// Provider para quizzes em andamento do usuário
final userInProgressQuizzesProvider = FutureProvider<List<UserQuizModel>>((ref) async {
  final userQuizzes = await ref.watch(userQuizzesProvider.future);
  return userQuizzes.where((quiz) => quiz.isInProgress).toList();
});

// Provider para quizzes completados do usuário
final userCompletedQuizzesProvider = FutureProvider<List<UserQuizModel>>((ref) async {
  final userQuizzes = await ref.watch(userQuizzesProvider.future);
  return userQuizzes.where((quiz) => quiz.isCompleted).toList();
});

// Provider para confrontos em parceria
final partnerConfrontationsProvider = FutureProvider<List<UserQuizModel>>((ref) async {
  final supabaseService = ref.watch(supabaseServiceProvider);
  // Buscar o userData do modelo próprio
  final userData = ref.watch(currentUserDataProvider).value;
  final currentUser = supabaseService.currentUser;
  if (currentUser == null || userData == null) return [];
  return await supabaseService.getPartnerQuizzes(currentUser.id, userData.partnerId ?? '');
});

// Notifier para gerenciar ações de quiz
class QuizNotifier extends StateNotifier<AsyncValue<void>> {
  final SupabaseService _supabaseService;
  
  QuizNotifier(this._supabaseService) : super(const AsyncValue.data(null));
  
  // Iniciar um quiz
  Future<UserQuizModel> startQuiz({
    required String quizId,
    String? partnerId,
  }) async {
    try {
      state = const AsyncValue.loading();
      
      final currentUser = _supabaseService.currentUser;
      if (currentUser == null) {
        throw Exception('Usuário não autenticado');
      }
      
      // Buscar perguntas do quiz
      final questions = await _supabaseService.getQuizQuestions(quizId);
      if (questions.isEmpty) {
        throw Exception('Quiz não possui perguntas');
      }
      
      // Criar registro de execução do quiz
      final userQuiz = UserQuizModel(
        id: const Uuid().v4(),
        userId: currentUser.id,
        quizId: quizId,
        partnerId: partnerId,
        score: 0,
        totalQuestions: questions.length,
        startedAt: DateTime.now(),
        completedAt: null,
        status: 'in_progress',
        answers: {},
        createdAt: DateTime.now(),

      );
      
      await _supabaseService.createUserQuiz(userQuiz);
      
      state = const AsyncValue.data(null);
      return userQuiz;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }
  
  // Responder uma pergunta
  Future<void> answerQuestion({
    required String userQuizId,
    required String questionId,
    required int selectedAnswer,
  }) async {
    try {
      state = const AsyncValue.loading();
      
      // Buscar quiz atual
      final userQuiz = await _supabaseService.getUserQuiz(userQuizId);
      if (userQuiz == null) {
        throw Exception('Quiz não encontrado');
      }
      
      // Buscar pergunta
      final questions = await _supabaseService.getQuizQuestions(userQuiz.quizId);
      final question = questions.firstWhere((q) => q.id == questionId);
      
      // Verificar se a resposta está correta
      final isCorrect = question.isCorrectAnswer(selectedAnswer);
      final newScore = isCorrect ? userQuiz.score + 1 : userQuiz.score;
      
      // Atualizar respostas
      final updatedAnswers = Map<String, dynamic>.from(userQuiz.answers ?? {});
      updatedAnswers[questionId] = {
        'selected_answer': selectedAnswer,
        'is_correct': isCorrect,
        'correct_answer': question.correctAnswer,
      };
      
      // Atualizar quiz
      final updatedUserQuiz = userQuiz.copyWith(
        score: newScore,
        answers: updatedAnswers,
      );
      
      await _supabaseService.updateUserQuiz(updatedUserQuiz);
      
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }
  
  // Finalizar quiz
  Future<UserQuizModel> completeQuiz(String userQuizId) async {
    try {
      state = const AsyncValue.loading();
      
      final userQuiz = await _supabaseService.getUserQuiz(userQuizId);
      if (userQuiz == null) {
        throw Exception('Quiz não encontrado');
      }
      
      final completedUserQuiz = userQuiz.copyWith(
        status: 'completed',
        completedAt: DateTime.now(),
      );
      
      await _supabaseService.updateUserQuiz(completedUserQuiz);
      
      state = const AsyncValue.data(null);
      return completedUserQuiz;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }
  
  // Abandonar quiz
  Future<void> abandonQuiz(String userQuizId) async {
    try {
      state = const AsyncValue.loading();
      
      final userQuiz = await _supabaseService.getUserQuiz(userQuizId);
      if (userQuiz == null) {
        throw Exception('Quiz não encontrado');
      }
      
      final abandonedUserQuiz = userQuiz.copyWith(
        status: 'abandoned',
        completedAt: DateTime.now(),
      );
      
      await _supabaseService.updateUserQuiz(abandonedUserQuiz);
      
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }
  
  // Buscar confrontos com parceiro
  Future<List<UserQuizModel>> getConfrontationsWithPartner(String partnerId) async {
    try {
      final currentUser = _supabaseService.currentUser;
      if (currentUser == null) {
        throw Exception('Usuário não autenticado');
      }
      
      return await _supabaseService.getPartnerQuizzes(
        currentUser.id,
        partnerId,
      );
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }
}

// Provider para o notifier de quiz
final quizNotifierProvider = StateNotifierProvider<QuizNotifier, AsyncValue<void>>((ref) {
  final supabaseService = ref.watch(supabaseServiceProvider);
  return QuizNotifier(supabaseService);
}); 