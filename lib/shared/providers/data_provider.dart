import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/supabase_service.dart';
import '../models/user_model.dart';
import '../models/challenge_model.dart';
import '../models/quiz_model.dart';
import 'auth_provider.dart';
import 'package:intellimen/shared/models/user_challenge_model.dart';
import 'package:intellimen/shared/models/user_quiz_model.dart';

// Provider para lista de usuários ativos (para o carrossel de avatares)
final activeUsersProvider = FutureProvider<List<UserModel>>((ref) async {
  final supabaseService = ref.watch(supabaseServiceProvider);
  return await supabaseService.getUsersByAccessLevel('member');
});

// Provider para desafios ativos
final activeChallengesProvider = FutureProvider<List<ChallengeModel>>((ref) async {
  final supabaseService = ref.watch(supabaseServiceProvider);
  return await supabaseService.getChallenges();
});

// Provider para desafios do usuário atual
final userChallengesProvider = FutureProvider<List<UserChallengeModel>>((ref) async {
  final user = ref.watch(currentUserDataProvider).value;
  if (user == null) return [];
  
  final supabaseService = ref.watch(supabaseServiceProvider);
  return await supabaseService.getUserChallenges(user.id);
});

// Provider para quizzes ativos
final activeQuizzesProvider = FutureProvider<List<QuizModel>>((ref) async {
  final supabaseService = ref.watch(supabaseServiceProvider);
  return await supabaseService.getQuizzes();
});

// Provider para quizzes individuais
final individualQuizzesProvider = FutureProvider<List<QuizModel>>((ref) async {
  final supabaseService = ref.watch(supabaseServiceProvider);
  return await supabaseService.getQuizzes(type: 'individual');
});

// Provider para quizzes de parceria
final partnerQuizzesProvider = FutureProvider<List<QuizModel>>((ref) async {
  final supabaseService = ref.watch(supabaseServiceProvider);
  return await supabaseService.getQuizzes(type: 'partner');
});

// Provider para quizzes do usuário atual
final userQuizzesProvider = FutureProvider<List<UserQuizModel>>((ref) async {
  final user = ref.watch(currentUserDataProvider).value;
  if (user == null) return [];
  
  final supabaseService = ref.watch(supabaseServiceProvider);
  return await supabaseService.getUserQuizzes(user.id);
});

// Provider para parceiros disponíveis
final availablePartnersProvider = FutureProvider<List<UserModel>>((ref) async {
  final supabaseService = ref.watch(supabaseServiceProvider);
  return await supabaseService.getAvailablePartners();
});

// Provider para solicitações de parceria do usuário atual
final userPartnershipRequestsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final user = ref.watch(currentUserDataProvider).value;
  if (user == null) return [];
  
  final supabaseService = ref.watch(supabaseServiceProvider);
  return await supabaseService.getPartnershipRequests(user.id);
});

// Provider para solicitações de acesso do usuário atual
final userAccessRequestsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final user = ref.watch(currentUserDataProvider).value;
  if (user == null) return [];
  
  final supabaseService = ref.watch(supabaseServiceProvider);
  return await supabaseService.getAccessRequests(user.id);
});

// Provider para posts do feed
final feedPostsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final supabaseService = ref.watch(supabaseServiceProvider);
  return await supabaseService.getPosts();
});

// Provider para notificações do usuário atual
final userNotificationsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final user = ref.watch(currentUserDataProvider).value;
  if (user == null) return [];
  
  final supabaseService = ref.watch(supabaseServiceProvider);
  return await supabaseService.getNotifications(user.id);
});

// =====================================================
// PROVIDERS PARA QUIZ DUPLO
// =====================================================

// Provider para quizzes duplos ativos do usuário
final quizDuplosAtivosProvider = FutureProvider<List<UserQuizModel>>((ref) async {
  final user = ref.watch(currentUserDataProvider).value;
  if (user == null) return [];
  
  final supabaseService = ref.watch(supabaseServiceProvider);
  return await supabaseService.getQuizDuplosAtivos(user.id);
});

// Provider para quizzes duplos completados do usuário
final quizDuplosCompletadosProvider = FutureProvider<List<UserQuizModel>>((ref) async {
  final user = ref.watch(currentUserDataProvider).value;
  if (user == null) return [];
  
  final supabaseService = ref.watch(supabaseServiceProvider);
  return await supabaseService.getQuizDuplosCompletados(user.id);
});

// Provider para convites de quiz duplo pendentes
final convitesQuizDuploPendentesProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final user = ref.watch(currentUserDataProvider).value;
  if (user == null) return [];
  
  final supabaseService = ref.watch(supabaseServiceProvider);
  return await supabaseService.getConvitesQuizDuploPendentes(user.id);
});

// Provider para buscar usuários para Quiz Duplo
final buscaUsuariosParaQuizDuploProvider = FutureProvider.family<List<UserModel>, String>((ref, termo) async {
  final user = ref.watch(currentUserDataProvider).value;
  if (user == null) return [];
  
  final supabaseService = ref.watch(supabaseServiceProvider);
  return await supabaseService.buscarUsuariosParaQuizDuplo(user.id, termo);
});

// Provider para controlar convites processados (evitar duplicação)
final processedConvitesProvider = StateProvider<Set<String>>((ref) => <String>{});

// =====================================================
// PROVIDERS PARA SINCRONIZAÇÃO EM TEMPO REAL
// =====================================================

// Stream provider para monitorar quizzes do usuário em tempo real
final userQuizzesStreamProvider = StreamProvider<List<UserQuizModel>>((ref) {
  final user = ref.watch(currentUserDataProvider).value;
  if (user == null) return const Stream.empty();
  
  final supabaseService = ref.watch(supabaseServiceProvider);
  return supabaseService.streamUserQuizzes(user.id)
      .map((data) => data.map((json) => UserQuizModel.fromJson(json)).toList());
});

// Stream provider para monitorar status de um quiz duplo específico
final quizDuploStatusStreamProvider = StreamProvider.family<List<UserQuizModel>, String>((ref, quizId) {
  final supabaseService = ref.watch(supabaseServiceProvider);
  return supabaseService.streamQuizDuploStatus(quizId)
      .map((data) => data.map((json) => UserQuizModel.fromJson(json)).toList());
});

// Stream provider para monitorar convites pendentes em tempo real
final convitesPendentesStreamProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  final user = ref.watch(currentUserDataProvider).value;
  if (user == null) return const Stream.empty();
  
  final supabaseService = ref.watch(supabaseServiceProvider);
  return supabaseService.streamConvitesPendentes(user.id);
});

// Provider para verificar se um quiz duplo pode ser iniciado
final podeIniciarQuizDuploProvider = FutureProvider.family<bool, String>((ref, quizId) async {
  final user = ref.watch(currentUserDataProvider).value;
  if (user == null) return false;
  
  final supabaseService = ref.watch(supabaseServiceProvider);
  return await supabaseService.podeIniciarQuizDuplo(quizId, user.id);
});

// Provider para dados atualizados de um quiz duplo
final quizDuploDataProvider = FutureProvider.family<Map<String, dynamic>?, String>((ref, quizId) async {
  final user = ref.watch(currentUserDataProvider).value;
  if (user == null) return null;
  
  final supabaseService = ref.watch(supabaseServiceProvider);
  return await supabaseService.getQuizDuploData(quizId, user.id);
});

// Provider para quizzes duplos aguardando parceiro
final quizzesAguardandoParceiroProvider = FutureProvider<List<UserQuizModel>>((ref) async {
  final user = ref.watch(currentUserDataProvider).value;
  if (user == null) return [];
  
  final supabaseService = ref.watch(supabaseServiceProvider);
  final quizzes = await supabaseService.getQuizDuplosAtivos(user.id);
  return quizzes.where((quiz) => quiz.isWaitingPartner).toList();
});

// Provider para quizzes duplos em progresso
final quizzesEmProgressoProvider = FutureProvider<List<UserQuizModel>>((ref) async {
  final user = ref.watch(currentUserDataProvider).value;
  if (user == null) return [];
  
  final supabaseService = ref.watch(supabaseServiceProvider);
  final quizzes = await supabaseService.getQuizDuplosAtivos(user.id);
  return quizzes.where((quiz) => quiz.isInProgress).toList();
});

// Notifier para gerenciar ações de dados
class DataNotifier extends StateNotifier<AsyncValue<void>> {
  final SupabaseService _supabaseService;
  
  DataNotifier(this._supabaseService) : super(const AsyncValue.data(null));
  
  Future<void> refreshAllData(WidgetRef ref) async {
    try {
      state = const AsyncValue.loading();
      
      // Invalidar todos os providers para recarregar os dados
      ref.invalidate(activeUsersProvider);
      ref.invalidate(activeChallengesProvider);
      ref.invalidate(userChallengesProvider);
      ref.invalidate(activeQuizzesProvider);
      ref.invalidate(userQuizzesProvider);
      ref.invalidate(availablePartnersProvider);
      ref.invalidate(userPartnershipRequestsProvider);
      ref.invalidate(userAccessRequestsProvider);
      ref.invalidate(feedPostsProvider);
      ref.invalidate(userNotificationsProvider);
      ref.invalidate(quizDuplosAtivosProvider);
      ref.invalidate(quizDuplosCompletadosProvider);
      ref.invalidate(convitesQuizDuploPendentesProvider);
      
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
  
  Future<void> createUserChallenge(UserChallengeModel userChallenge) async {
    try {
      state = const AsyncValue.loading();
      await _supabaseService.createUserChallenge(userChallenge);
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }
  
  Future<void> updateUserChallenge(UserChallengeModel userChallenge) async {
    try {
      state = const AsyncValue.loading();
      await _supabaseService.updateUserChallenge(userChallenge);
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }
  
  Future<void> createUserQuiz(UserQuizModel userQuiz) async {
    try {
      state = const AsyncValue.loading();
      await _supabaseService.createUserQuiz(userQuiz);
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }
  
  Future<void> updateUserQuiz(UserQuizModel userQuiz) async {
    try {
      state = const AsyncValue.loading();
      await _supabaseService.updateUserQuiz(userQuiz);
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }
  
  Future<void> sendPartnershipRequest({
    required String requesterId,
    required String requestedId,
    String? message,
  }) async {
    try {
      state = const AsyncValue.loading();
      await _supabaseService.sendPartnershipRequest(
        requesterId: requesterId,
        requestedId: requestedId,
        message: message,
      );
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }
  
  Future<void> respondToPartnershipRequest({
    required String requestId,
    required String status,
  }) async {
    try {
      state = const AsyncValue.loading();
      await _supabaseService.respondToPartnershipRequest(
        requestId: requestId,
        status: status,
      );
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }
  
  Future<void> sendAccessRequest({
    required String userId,
    required String requestedAccess,
    String? reason,
  }) async {
    try {
      state = const AsyncValue.loading();
      await _supabaseService.sendAccessRequest(
        userId: userId,
        requestedAccess: requestedAccess,
        reason: reason,
      );
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }
  
  Future<void> createPost({
    required String userId,
    required String content,
    String? imageUrl,
    String? challengeId,
  }) async {
    try {
      state = const AsyncValue.loading();
      await _supabaseService.createPost(
        userId: userId,
        content: content,
        imageUrl: imageUrl,
        challengeId: challengeId,
      );
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }
  
  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      state = const AsyncValue.loading();
      await _supabaseService.markNotificationAsRead(notificationId);
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  // =====================================================
  // MÉTODOS PARA QUIZ DUPLO
  // =====================================================

  Future<void> criarConviteQuizDuplo({
    required String fromUserId,
    required String toUserId,
    required String quizId,
  }) async {
    try {
      state = const AsyncValue.loading();
      await _supabaseService.criarConviteQuizDuplo(
        fromUserId: fromUserId,
        toUserId: toUserId,
        quizId: quizId,
      );
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  Future<void> aceitarConviteQuizDuplo({
    required String userId,
    required String partnerId,
    required String quizId,
  }) async {
    try {
      state = const AsyncValue.loading();
      await _supabaseService.aceitarConviteQuizDuplo(
        userId: userId,
        partnerId: partnerId,
        quizId: quizId,
      );
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  Future<void> marcarUsuarioPronto({
    required String userId,
    required String quizId,
  }) async {
    try {
      state = const AsyncValue.loading();
      await _supabaseService.marcarUsuarioPronto(
        userId: userId,
        quizId: quizId,
      );
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  Future<bool> verificarEIniciarQuizDuplo({
    required String quizId,
    required String user1Id,
    required String user2Id,
  }) async {
    try {
      state = const AsyncValue.loading();
      final result = await _supabaseService.verificarEIniciarQuizDuplo(
        quizId: quizId,
        user1Id: user1Id,
        user2Id: user2Id,
      );
      state = const AsyncValue.data(null);
      return result;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  Future<bool> podeIniciarQuizDuplo(String quizId, String userId) async {
    try {
      return await _supabaseService.podeIniciarQuizDuplo(quizId, userId);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getQuizDuploData(String quizId, String userId) async {
    try {
      return await _supabaseService.getQuizDuploData(quizId, userId);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  Future<void> recusarConviteQuizDuplo({
    required String userId,
    required String partnerId,
    required String quizId,
  }) async {
    try {
      state = const AsyncValue.loading();
      await _supabaseService.recusarConviteQuizDuplo(
        userId: userId,
        partnerId: partnerId,
        quizId: quizId,
      );
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  Future<void> atualizarPontuacaoQuizDuplo({
    required String userId,
    required String quizId,
    required int score,
    required Map<String, dynamic> answers,
  }) async {
    try {
      state = const AsyncValue.loading();
      await _supabaseService.atualizarPontuacaoQuizDuplo(
        userId: userId,
        quizId: quizId,
        score: score,
        answers: answers,
      );
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  Future<List<UserModel>> buscarUsuariosParaQuizDuplo(String currentUserId, String termo) async {
    try {
      return await _supabaseService.buscarUsuariosParaQuizDuplo(currentUserId, termo);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }
}

// Provider para o DataNotifier
final dataNotifierProvider = StateNotifierProvider<DataNotifier, AsyncValue<void>>((ref) {
  final supabaseService = ref.watch(supabaseServiceProvider);
  return DataNotifier(supabaseService);
}); 

// =====================================================
// PROVIDERS PARA PONTUAÇÃO EM TEMPO REAL - QUIZ DUPLO
// =====================================================

// Stream provider para monitorar pontuação em tempo real
final pontuacaoQuizDuploStreamProvider = StreamProvider.family<Map<String, dynamic>, String>((ref, quizId) {
  final supabaseService = ref.watch(supabaseServiceProvider);
  return supabaseService.streamPontuacaoQuizDuplo(quizId);
});

// Provider para buscar pontuação atual
final pontuacaoQuizDuploProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, quizId) async {
  final supabaseService = ref.watch(supabaseServiceProvider);
  return await supabaseService.buscarPontuacaoQuizDuplo(quizId);
});

// Provider para verificar se ambos finalizaram
final ambosFinalizaramProvider = FutureProvider.family<bool, String>((ref, quizId) async {
  final supabaseService = ref.watch(supabaseServiceProvider);
  return await supabaseService.verificarAmbosFinalizaram(quizId);
});

// Notifier para gerenciar ações de pontuação em tempo real
class PontuacaoTempoRealNotifier extends StateNotifier<AsyncValue<void>> {
  final SupabaseService _supabaseService;

  PontuacaoTempoRealNotifier(this._supabaseService) : super(const AsyncValue.data(null));

  // Atualizar pontuação em tempo real (sem finalizar)
  Future<void> atualizarPontuacaoTempoReal({
    required String userId,
    required String quizId,
    required int score,
    required Map<String, dynamic> answers,
  }) async {
    try {
      state = const AsyncValue.loading();
      await _supabaseService.atualizarPontuacaoTempoReal(
        userId: userId,
        quizId: quizId,
        score: score,
        answers: answers,
      );
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  // Finalizar quiz individual
  Future<void> finalizarQuizIndividual({
    required String userId,
    required String quizId,
    required int score,
    required Map<String, dynamic> answers,
  }) async {
    try {
      state = const AsyncValue.loading();
      await _supabaseService.finalizarQuizIndividual(
        userId: userId,
        quizId: quizId,
        score: score,
        answers: answers,
      );
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }
}

// Provider para o notifier de pontuação em tempo real
final pontuacaoTempoRealNotifierProvider = StateNotifierProvider<PontuacaoTempoRealNotifier, AsyncValue<void>>((ref) {
  final supabaseService = ref.watch(supabaseServiceProvider);
  return PontuacaoTempoRealNotifier(supabaseService);
}); 

// Provider para buscar usuário por ID
final userByIdProvider = FutureProvider.family<UserModel?, String>((ref, userId) async {
  final supabaseService = ref.watch(supabaseServiceProvider);
  return await supabaseService.getUser(userId);
});

// Provider para buscar quiz por ID
final quizByIdProvider = FutureProvider.family<QuizModel?, String>((ref, quizId) async {
  final supabaseService = ref.watch(supabaseServiceProvider);
  return await supabaseService.getQuiz(quizId);
}); 