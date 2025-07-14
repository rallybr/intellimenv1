import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/supabase_service.dart';
import '../models/user_model.dart';
import '../models/challenge_model.dart';
import '../models/quiz_model.dart';

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
}

// Provider para o DataNotifier
final dataNotifierProvider = StateNotifierProvider<DataNotifier, AsyncValue<void>>((ref) {
  final supabaseService = ref.watch(supabaseServiceProvider);
  return DataNotifier(supabaseService);
}); 