import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:developer' as developer;
import 'dart:io';
import '../../shared/models/user_model.dart';
import '../../shared/models/challenge_model.dart';
import '../../shared/models/quiz_model.dart';
import '../config/supabase_config.dart';
import 'package:intellimen/shared/models/user_challenge_model.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  late final SupabaseClient _client;

  Future<void> initialize() async {
    await Supabase.initialize(
      url: SupabaseConfig.url,
      anonKey: SupabaseConfig.anonKey,
    );
    _client = Supabase.instance.client;
  }

  SupabaseClient get client => _client;

  // =====================================================
  // AUTENTICAÇÃO
  // =====================================================

  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    return await _client.auth.signUp(
      email: email,
      password: password,
      data: {'name': name},
    );
  }

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  User? get currentUser => _client.auth.currentUser;

  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  // =====================================================
  // USUÁRIOS
  // =====================================================

  Future<UserModel?> getUser(String userId) async {
    try {
      final response = await _client
          .from('users')
          .select()
          .eq('id', userId)
          .single();
      
      return UserModel.fromJson(response);
    } catch (e) {
      developer.log('Erro ao buscar usuário: $e');
      return null;
    }
  }

  Future<UserModel?> getCurrentUser() async {
    final user = currentUser;
    if (user == null) return null;
    return await getUser(user.id);
  }

  Future<void> createUser(UserModel user) async {
    await _client.from('users').insert(user.toJson());
  }

  Future<void> updateUser(UserModel user) async {
    await _client
        .from('users')
        .update(user.toJson())
        .eq('id', user.id);
  }

  Future<List<UserModel>> getUsersByAccessLevel(String accessLevel) async {
    try {
      final response = await _client
          .from('users')
          .select()
          .eq('access_level', accessLevel)
          .eq('is_active', true);
      
      return response.map((json) => UserModel.fromJson(json)).toList();
    } catch (e) {
      developer.log('Erro ao buscar usuários: $e');
      return [];
    }
  }

  Future<List<UserModel>> getAvailablePartners() async {
    try {
      final response = await _client
          .from('users')
          .select()
          .filter('partner_id', 'is', null)
          .eq('is_active', true)
          .neq('access_level', 'general');
      
      return response.map((json) => UserModel.fromJson(json)).toList();
    } catch (e) {
      developer.log('Erro ao buscar parceiros disponíveis: $e');
      return [];
    }
  }

  Future<List<UserModel>> buscarUsuariosPorNome(String termo) async {
    try {
      final response = await _client
          .from('users')
          .select()
          .ilike('name', '$termo%')
          .limit(20);
      return response.map<UserModel>((json) => UserModel.fromJson(json)).toList();
    } catch (e) {
      developer.log('Erro ao buscar usuários por nome: $e');
      return [];
    }
  }

  // =====================================================
  // DESAFIOS
  // =====================================================

  Future<List<ChallengeModel>> getChallenges() async {
    try {
      final response = await _client
          .from('challenges')
          .select()
          .eq('is_active', true)
          .order('week_number');
      
      return response.map((json) => ChallengeModel.fromJson(json)).toList();
    } catch (e) {
      developer.log('Erro ao buscar desafios: $e');
      return [];
    }
  }

  Future<ChallengeModel?> getChallenge(String challengeId) async {
    try {
      final response = await _client
          .from('challenges')
          .select()
          .eq('id', challengeId)
          .single();
      
      return ChallengeModel.fromJson(response);
    } catch (e) {
      developer.log('Erro ao buscar desafio: $e');
      return null;
    }
  }

  Future<List<UserChallengeModel>> getUserChallenges(String userId) async {
    try {
      final response = await _client
          .from('user_challenges')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      
      return response.map((json) => UserChallengeModel.fromJson(json)).toList();
    } catch (e) {
      developer.log('Erro ao buscar desafios do usuário: $e');
      return [];
    }
  }

  Future<void> createUserChallenge(UserChallengeModel userChallenge) async {
    await _client.from('user_challenges').insert(userChallenge.toJson());
  }

  Future<void> updateUserChallenge(UserChallengeModel userChallenge) async {
    await _client
        .from('user_challenges')
        .update(userChallenge.toJson())
        .eq('id', userChallenge.id);
  }

  Future<List<UserChallengeModel>> getDesafiosDaDupla(String userId, String partnerId) async {
    try {
      final response = await _client
          .from('user_challenges')
          .select()
          .or('and(user_id.eq.$userId,partner_id.eq.$partnerId),and(user_id.eq.$partnerId,partner_id.eq.$userId)')
          .order('created_at');
      if (response is List) {
        return List<UserChallengeModel>.from(
          response
            .whereType<Map<String, dynamic>>()
            .map((json) => UserChallengeModel.fromJson(json))
        );
      }
      return <UserChallengeModel>[];
    } catch (e) {
      developer.log('Erro ao buscar desafios da dupla: $e');
      return <UserChallengeModel>[];
    }
  }

  Future<UserChallengeModel?> getUserChallenge(String userId, String partnerId, String challengeId) async {
    try {
      final response = await _client
          .from('user_challenges')
          .select()
          .eq('user_id', userId)
          .eq('partner_id', partnerId)
          .eq('challenge_id', challengeId)
          .maybeSingle();
      if (response == null) return null;
      return UserChallengeModel.fromJson(response);
    } catch (e) {
      developer.log('Erro ao buscar user_challenge: $e');
      return null;
    }
  }

  // =====================================================
  // QUIZZES
  // =====================================================

  Future<List<QuizModel>> getQuizzes({String? type}) async {
    try {
      var query = _client
          .from('quizzes')
          .select()
          .eq('is_active', true);
      
      if (type != null) {
        query = query.eq('type', type);
      }
      
      final response = await query.order('created_at');
      return response.map((json) => QuizModel.fromJson(json)).toList();
    } catch (e) {
      developer.log('Erro ao buscar quizzes: $e');
      return [];
    }
  }

  Future<List<QuizQuestionModel>> getQuizQuestions(String quizId) async {
    try {
      final response = await _client
          .from('quiz_questions')
          .select()
          .eq('quiz_id', quizId)
          .order('created_at');
      
      return response.map((json) => QuizQuestionModel.fromJson(json)).toList();
    } catch (e) {
      developer.log('Erro ao buscar perguntas do quiz: $e');
      return [];
    }
  }

  Future<List<UserQuizModel>> getUserQuizzes(String userId) async {
    try {
      final response = await _client
          .from('user_quizzes')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      
      return response.map((json) => UserQuizModel.fromJson(json)).toList();
    } catch (e) {
      developer.log('Erro ao buscar quizzes do usuário: $e');
      return [];
    }
  }

  Future<void> createUserQuiz(UserQuizModel userQuiz) async {
    await _client.from('user_quizzes').insert(userQuiz.toJson());
  }

  Future<void> updateUserQuiz(UserQuizModel userQuiz) async {
    await _client
        .from('user_quizzes')
        .update(userQuiz.toJson())
        .eq('id', userQuiz.id);
  }

  // =====================================================
  // SOLICITAÇÕES DE PARCERIA
  // =====================================================

  Future<void> sendPartnershipRequest({
    required String requesterId,
    required String requestedId,
    String? message,
  }) async {
    await _client.from('partnership_requests').insert({
      'requester_id': requesterId,
      'requested_id': requestedId,
      'message': message,
    });
  }

  Future<List<Map<String, dynamic>>> getPartnershipRequests(String userId) async {
    try {
      final response = await _client
          .from('partnership_requests')
          .select('*, requester:users!partnership_requests_requester_id_fkey(*), requested:users!partnership_requests_requested_id_fkey(*)')
          .or('requester_id.eq.$userId,requested_id.eq.$userId')
          .order('created_at', ascending: false);
      
      return response;
    } catch (e) {
      developer.log('Erro ao buscar solicitações de parceria: $e');
      return [];
    }
  }

  Future<void> respondToPartnershipRequest({
    required String requestId,
    required String status,
  }) async {
    await _client
        .from('partnership_requests')
        .update({'status': status})
        .eq('id', requestId);
  }

  // =====================================================
  // SOLICITAÇÕES DE ACESSO
  // =====================================================

  Future<void> sendAccessRequest({
    required String userId,
    required String requestedAccess,
    String? reason,
  }) async {
    await _client.from('access_requests').insert({
      'user_id': userId,
      'requested_access': requestedAccess,
      'reason': reason,
    });
  }

  Future<List<Map<String, dynamic>>> getAccessRequests(String userId) async {
    try {
      final response = await _client
          .from('access_requests')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      
      return response;
    } catch (e) {
      developer.log('Erro ao buscar solicitações de acesso: $e');
      return [];
    }
  }

  // =====================================================
  // POSTS E FEED
  // =====================================================

  Future<List<Map<String, dynamic>>> getPosts() async {
    try {
      final response = await _client
          .from('posts')
          .select('*, user:users(*)')
          .eq('is_public', true)
          .order('created_at', ascending: false);
      
      return response;
    } catch (e) {
      developer.log('Erro ao buscar posts: $e');
      return [];
    }
  }

  Future<void> createPost({
    required String userId,
    required String content,
    String? imageUrl,
    String? challengeId,
  }) async {
    await _client.from('posts').insert({
      'user_id': userId,
      'content': content,
      'image_url': imageUrl,
      'challenge_id': challengeId,
    });
  }

  // =====================================================
  // NOTIFICAÇÕES
  // =====================================================

  Future<List<Map<String, dynamic>>> getNotifications(String userId) async {
    try {
      final response = await _client
          .from('notifications')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      
      return response;
    } catch (e) {
      developer.log('Erro ao buscar notificações: $e');
      return [];
    }
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    await _client
        .from('notifications')
        .update({'is_read': true})
        .eq('id', notificationId);
  }

  // =====================================================
  // UPLOAD DE ARQUIVOS
  // =====================================================

  Future<String?> uploadFile({
    required File file,
    required String bucketName,
    String? fileName,
  }) async {
    try {
      final uploadedPath = await _client.storage
          .from(bucketName)
          .upload(
            fileName ?? DateTime.now().millisecondsSinceEpoch.toString(),
            file,
          );
      return _client.storage
          .from(bucketName)
          .getPublicUrl(uploadedPath);
    } catch (e) {
      developer.log('Erro ao fazer upload do arquivo: $e');
      return null;
    }
  }

  Future<String?> uploadUserProfilePhoto(String userId, File file) async {
    final fileName = 'profile.jpg';
    final filePath = '$userId/$fileName';
    final storage = _client.storage.from('profile-photos');
    final response = await storage.upload(filePath, file, fileOptions: const FileOptions(upsert: true));
    if (response != null && response.isNotEmpty) {
      // Gerar URL pública
      final publicUrl = storage.getPublicUrl(filePath);
      return publicUrl;
    } else {
      return null;
    }
  }

  // =====================================================
  // CONVITES DE DESAFIO
  // =====================================================

  Future<void> enviarConviteDesafio({
    required String fromUserId,
    required String toUserId,
  }) async {
    try {
      await _client.from('challenge_invites').insert({
        'from_user_id': fromUserId,
        'to_user_id': toUserId,
        'status': 'pending',
      });
    } catch (e) {
      developer.log('Erro ao enviar convite de desafio: $e');
      rethrow;
    }
  }
} 