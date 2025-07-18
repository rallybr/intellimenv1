import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:developer' as developer;
import 'dart:io';
import '../../shared/models/user_model.dart';
import '../../shared/models/challenge_model.dart';
import '../../shared/models/quiz_model.dart';
import '../../shared/models/quiz_question_model.dart';
import '../../shared/models/user_quiz_model.dart';
import '../../shared/models/quiz_category_model.dart';
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

  // =====================================================
  // QUIZZES
  // =====================================================

  Future<List<QuizModel>> getQuizzes({String? category, String? type}) async {
    try {
      var query = _client
          .from('quizzes')
          .select()
          .eq('is_active', true);
      
      if (category != null) {
        query = query.eq('category', category);
      }
      
      if (type != null) {
        query = query.eq('type', type);
      }
      
      final response = await query.order('created_at', ascending: false);
      return response.map((json) => QuizModel.fromJson(json)).toList();
    } catch (e) {
      developer.log('Erro ao buscar quizzes: $e');
      return [];
    }
  }

  Future<QuizModel?> getQuiz(String quizId) async {
    try {
      final response = await _client
          .from('quizzes')
          .select()
          .eq('id', quizId)
          .single();
      
      return QuizModel.fromJson(response);
    } catch (e) {
      developer.log('Erro ao buscar quiz: $e');
      return null;
    }
  }

  Future<void> createQuiz(QuizModel quiz) async {
    await _client.from('quizzes').insert(quiz.toJson());
  }

  Future<void> updateQuiz(QuizModel quiz) async {
    await _client
        .from('quizzes')
        .update(quiz.toJson())
        .eq('id', quiz.id);
  }

  Future<void> deleteQuiz(String quizId) async {
    await _client
        .from('quizzes')
        .delete()
        .eq('id', quizId);
  }

  // =====================================================
  // QUESTÕES DE QUIZ
  // =====================================================

  Future<List<QuizQuestionModel>> getQuizQuestions(String quizId) async {
    try {
      final response = await _client
          .from('quiz_questions')
          .select()
          .eq('quiz_id', quizId)
          .order('created_at');
      
      return response.map((json) => QuizQuestionModel.fromJson(json)).toList();
    } catch (e) {
      developer.log('Erro ao buscar questões do quiz: $e');
      return [];
    }
  }

  Future<QuizQuestionModel?> getQuizQuestion(String questionId) async {
    try {
      final response = await _client
          .from('quiz_questions')
          .select()
          .eq('id', questionId)
          .single();
      
      return QuizQuestionModel.fromJson(response);
    } catch (e) {
      developer.log('Erro ao buscar questão: $e');
      return null;
    }
  }

  Future<void> createQuizQuestion(QuizQuestionModel question) async {
    await _client.from('quiz_questions').insert(question.toJson());
  }

  Future<void> updateQuizQuestion(QuizQuestionModel question) async {
    await _client
        .from('quiz_questions')
        .update(question.toJson())
        .eq('id', question.id);
  }

  Future<void> deleteQuizQuestion(String questionId) async {
    await _client
        .from('quiz_questions')
        .delete()
        .eq('id', questionId);
  }

  // =====================================================
  // EXECUÇÕES DE QUIZ
  // =====================================================

  Future<List<UserQuizModel>> getUserQuizzes(String userId) async {
    try {
      final response = await _client
          .from('user_quizzes')
          .select('*, quizzes(*)')
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      
      return response.map((json) => UserQuizModel.fromJson(json)).toList();
    } catch (e) {
      developer.log('Erro ao buscar execuções de quiz do usuário: $e');
      return [];
    }
  }

  Future<UserQuizModel?> getUserQuiz(String userQuizId) async {
    try {
      final response = await _client
          .from('user_quizzes')
          .select('*, quizzes(*)')
          .eq('id', userQuizId)
          .single();
      
      return UserQuizModel.fromJson(response);
    } catch (e) {
      developer.log('Erro ao buscar execução de quiz: $e');
      return null;
    }
  }

  Future<UserQuizModel?> getCurrentUserQuiz(String quizId) async {
    final user = currentUser;
    if (user == null) return null;
    
    try {
      final response = await _client
          .from('user_quizzes')
          .select('*, quizzes(*)')
          .eq('user_id', user.id)
          .eq('quiz_id', quizId)
          .eq('status', 'in_progress')
          .maybeSingle();
      
      if (response == null) return null;
      return UserQuizModel.fromJson(response);
    } catch (e) {
      developer.log('Erro ao buscar execução atual do quiz: $e');
      return null;
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

  Future<void> completeUserQuiz(String userQuizId, int score, Map<String, dynamic> answers) async {
    await _client
        .from('user_quizzes')
        .update({
          'score': score,
          'answers': answers,
          'completed_at': DateTime.now().toIso8601String(),
          'status': 'completed',
        })
        .eq('id', userQuizId);
  }

  Future<List<UserQuizModel>> getPartnerQuizzes(String userId, String partnerId) async {
    try {
      final response = await _client
          .from('user_quizzes')
          .select('*, quizzes(*)')
          .or('user_id.eq.$userId,partner_id.eq.$userId')
          .or('user_id.eq.$partnerId,partner_id.eq.$partnerId')
          .eq('status', 'completed')
          .order('completed_at', ascending: false);
      
      return response.map((json) => UserQuizModel.fromJson(json)).toList();
    } catch (e) {
      developer.log('Erro ao buscar quizzes em parceria: $e');
      return [];
    }
  }

  // Buscar desafios da dupla (usuário + parceiro)
  Future<List<UserChallengeModel>> getDesafiosDaDupla(String userId, String partnerId) async {
    try {
      developer.log('Buscando desafios da dupla: userId=$userId, partnerId=$partnerId');
      
      // Buscar desafios do usuário
      final response1 = await _client
          .from('user_challenges')
          .select('*, challenges(*)')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      // Buscar desafios do parceiro
      final response2 = await _client
          .from('user_challenges')
          .select('*, challenges(*)')
          .eq('user_id', partnerId)
          .order('created_at', ascending: false);

      // Combinar e ordenar por data de criação
      final allResponses = [...response1, ...response2];
      allResponses.sort((a, b) => DateTime.parse(b['created_at'] as String)
          .compareTo(DateTime.parse(a['created_at'] as String)));

      developer.log('Total de desafios encontrados: ${allResponses.length}');
      
      return allResponses.map((json) => UserChallengeModel.fromJson(json)).toList();
    } catch (e) {
      developer.log('Erro ao buscar desafios da dupla: $e');
      return [];
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

  // =====================================================
  // CATEGORIAS DE QUIZ
  // =====================================================

  Future<List<QuizCategoryModel>> getQuizCategories() async {
    try {
      final response = await _client
          .from('quiz_categories')
          .select()
          .order('name');
      
      return response.map((json) => QuizCategoryModel.fromJson(json)).toList();
    } catch (e) {
      developer.log('Erro ao buscar categorias de quiz: $e');
      return [];
    }
  }

  Future<QuizCategoryModel?> getQuizCategory(String categoryId) async {
    try {
      final response = await _client
          .from('quiz_categories')
          .select()
          .eq('id', categoryId)
          .single();
      
      return QuizCategoryModel.fromJson(response);
    } catch (e) {
      developer.log('Erro ao buscar categoria de quiz: $e');
      return null;
    }
  }

  Future<void> createQuizCategory(QuizCategoryModel category) async {
    try {
      await _client.from('quiz_categories').insert(category.toJson());
    } catch (e) {
      developer.log('Erro ao criar categoria de quiz: $e');
      rethrow;
    }
  }

  Future<void> updateQuizCategory(QuizCategoryModel category) async {
    try {
      await _client
          .from('quiz_categories')
          .update(category.toJson())
          .eq('id', category.id);
    } catch (e) {
      developer.log('Erro ao atualizar categoria de quiz: $e');
      rethrow;
    }
  }

  Future<void> deleteQuizCategory(String categoryId) async {
    try {
      await _client
          .from('quiz_categories')
          .delete()
          .eq('id', categoryId);
    } catch (e) {
      developer.log('Erro ao deletar categoria de quiz: $e');
      rethrow;
    }
  }

  // =====================================================
  // QUIZ DUPLO
  // =====================================================

  // Buscar quizzes duplos ativos do usuário
  Future<List<UserQuizModel>> getQuizDuplosAtivos(String userId) async {
    try {
      final response = await _client
          .from('user_quizzes')
          .select('*, quizzes(*)')
          .or('user_id.eq.$userId,partner_id.eq.$userId')
          .inFilter('status', ['waiting_partner', 'in_progress', 'completed'])
          .order('created_at', ascending: false);
      
      return response.map((json) => UserQuizModel.fromJson(json)).toList();
    } catch (e) {
      developer.log('Erro ao buscar quizzes duplos ativos: $e');
      return [];
    }
  }

  // Buscar quizzes duplos completados do usuário
  Future<List<UserQuizModel>> getQuizDuplosCompletados(String userId) async {
    try {
      final response = await _client
          .from('user_quizzes')
          .select('*, quizzes(*)')
          .or('user_id.eq.$userId,partner_id.eq.$userId')
          .inFilter('status', ['completed'])
          .order('created_at', ascending: false)
          .limit(10);
      
      return response.map((json) => UserQuizModel.fromJson(json)).toList();
    } catch (e) {
      developer.log('Erro ao buscar quizzes duplos completados: $e');
      return [];
    }
  }

  // Criar convite para Quiz Duplo
  Future<void> criarConviteQuizDuplo({
    required String fromUserId,
    required String toUserId,
    required String quizId,
  }) async {
    try {
      // Buscar o número total de questões do quiz
      final questions = await _client
          .from('quiz_questions')
          .select('id')
          .eq('quiz_id', quizId);
      
      final totalQuestions = questions.length;

      // Criar registro para o usuário que convida
      await _client.from('user_quizzes').insert({
        'user_id': fromUserId,
        'quiz_id': quizId,
        'partner_id': toUserId,
        'score': 0,
        'total_questions': totalQuestions,
        'status': 'pending_invite',
        'started_at': DateTime.now().toIso8601String(),
        'is_ready': false,
      });

      // Criar registro para o usuário convidado
      await _client.from('user_quizzes').insert({
        'user_id': toUserId,
        'quiz_id': quizId,
        'partner_id': fromUserId,
        'score': 0,
        'total_questions': totalQuestions,
        'status': 'pending_invite',
        'started_at': DateTime.now().toIso8601String(),
        'is_ready': false,
      });
    } catch (e) {
      developer.log('Erro ao criar convite de quiz duplo: $e');
      rethrow;
    }
  }

  // Aceitar convite de Quiz Duplo
  Future<void> aceitarConviteQuizDuplo({
    required String userId,
    required String partnerId,
    required String quizId,
  }) async {
    try {
      // Atualizar status dos dois registros para 'waiting_partner'
      await _client
          .from('user_quizzes')
          .update({'status': 'waiting_partner'})
          .or('user_id.eq.$userId,user_id.eq.$partnerId')
          .eq('quiz_id', quizId)
          .or('partner_id.eq.$userId,partner_id.eq.$partnerId');
    } catch (e) {
      developer.log('Erro ao aceitar convite de quiz duplo: $e');
      rethrow;
    }
  }

  // Marcar usuário como pronto para começar o quiz
  Future<void> marcarUsuarioPronto({
    required String userId,
    required String quizId,
  }) async {
    try {
      await _client
          .from('user_quizzes')
          .update({
            'is_ready': true,
            'ready_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', userId)
          .eq('quiz_id', quizId);
    } catch (e) {
      developer.log('Erro ao marcar usuário como pronto: $e');
      rethrow;
    }
  }

  // Verificar se ambos os parceiros estão prontos e iniciar o quiz
  Future<bool> verificarEIniciarQuizDuplo({
    required String quizId,
    required String user1Id,
    required String user2Id,
  }) async {
    try {
      // Buscar status de ambos os usuários
      final response = await _client
          .from('user_quizzes')
          .select('user_id, is_ready')
          .eq('quiz_id', quizId)
          .inFilter('user_id', [user1Id, user2Id]);

      if (response.length == 2) {
        final user1Ready = response.firstWhere((r) => r['user_id'] == user1Id)['is_ready'] ?? false;
        final user2Ready = response.firstWhere((r) => r['user_id'] == user2Id)['is_ready'] ?? false;

        // Se ambos estão prontos, atualizar status para 'in_progress'
        if (user1Ready && user2Ready) {
          await _client
              .from('user_quizzes')
              .update({'status': 'in_progress'})
              .eq('quiz_id', quizId)
              .inFilter('user_id', [user1Id, user2Id]);
          
          return true;
        }
      }
      
      return false;
    } catch (e) {
      developer.log('Erro ao verificar e iniciar quiz duplo: $e');
      return false;
    }
  }

  // Recusar convite de Quiz Duplo
  Future<void> recusarConviteQuizDuplo({
    required String userId,
    required String partnerId,
    required String quizId,
  }) async {
    try {
      // Deletar os registros do convite
      await _client
          .from('user_quizzes')
          .delete()
          .or('user_id.eq.$userId,user_id.eq.$partnerId')
          .eq('quiz_id', quizId)
          .or('partner_id.eq.$userId,partner_id.eq.$partnerId');
    } catch (e) {
      developer.log('Erro ao recusar convite de quiz duplo: $e');
      rethrow;
    }
  }

  // Buscar convites pendentes de Quiz Duplo
  Future<List<Map<String, dynamic>>> getConvitesQuizDuploPendentes(String userId) async {
    try {
      // Buscar apenas registros onde o usuário é o destinatário (partner_id)
      // E NÃO o remetente (user_id)
      final response = await _client
          .from('user_quizzes')
          .select('*, quizzes(*), users!user_quizzes_user_id_fkey(*)')
          .eq('partner_id', userId)  // Usuário é o destinatário
          .neq('user_id', userId)    // Usuário NÃO é o remetente
          .eq('status', 'pending_invite')
          .order('created_at', ascending: false);
      
      // Filtro adicional para garantir que só retorne convites válidos
      final convitesFiltrados = response.where((convite) {
        final user_id = convite['user_id'] as String;
        final partner_id = convite['partner_id'] as String;
        
        // O usuário deve ser o destinatário (partner_id) e não o remetente (user_id)
        return partner_id == userId && user_id != userId;
      }).toList();
      
      return convitesFiltrados;
    } catch (e) {
      developer.log('Erro ao buscar convites de quiz duplo pendentes: $e');
      return [];
    }
  }

  // Buscar usuários para convite (excluindo o próprio usuário)
  Future<List<UserModel>> buscarUsuariosParaQuizDuplo(String currentUserId, String termo) async {
    try {
      final response = await _client
          .from('users')
          .select()
          .neq('id', currentUserId)
          .ilike('name', '$termo%')
          .eq('is_active', true)
          .limit(10);
      
      return response.map((json) => UserModel.fromJson(json)).toList();
    } catch (e) {
      developer.log('Erro ao buscar usuários para quiz duplo: $e');
      return [];
    }
  }

  // Atualizar pontuação do Quiz Duplo
  Future<void> atualizarPontuacaoQuizDuplo({
    required String userId,
    required String quizId,
    required int score,
    required Map<String, dynamic> answers,
  }) async {
    try {
      await _client
          .from('user_quizzes')
          .update({
            'score': score,
            'answers': answers,
            'completed_at': DateTime.now().toIso8601String(),
            'status': 'completed',
          })
          .eq('user_id', userId)
          .eq('quiz_id', quizId);
    } catch (e) {
      developer.log('Erro ao atualizar pontuação do quiz duplo: $e');
      rethrow;
    }
  }

  // Verificar se ambos os usuários completaram o quiz
  Future<bool> verificarQuizDuploCompleto(String quizId, String user1Id, String user2Id) async {
    try {
      final response = await _client
          .from('user_quizzes')
          .select('status')
          .eq('quiz_id', quizId)
          .inFilter('user_id', [user1Id, user2Id]);
      
      return response.every((record) => record['status'] == 'completed');
    } catch (e) {
      developer.log('Erro ao verificar se quiz duplo está completo: $e');
      return false;
    }
  }

  // =====================================================
  // SINCRONIZAÇÃO EM TEMPO REAL
  // =====================================================

  // Stream para monitorar mudanças em user_quizzes em tempo real
  Stream<List<Map<String, dynamic>>> streamUserQuizzes(String userId) {
    return _client
        .from('user_quizzes')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('created_at', ascending: false);
  }

  // Stream para monitorar status específico de um quiz duplo
  Stream<List<Map<String, dynamic>>> streamQuizDuploStatus(String quizId) {
    return _client
        .from('user_quizzes')
        .stream(primaryKey: ['id'])
        .eq('quiz_id', quizId)
        .order('created_at', ascending: false);
  }

  // Stream para monitorar convites pendentes (como partner_id)
  Stream<List<Map<String, dynamic>>> streamConvitesPendentes(String userId) {
    return _client
        .from('user_quizzes')
        .stream(primaryKey: ['id'])
        .eq('partner_id', userId)
        .order('created_at', ascending: false);
  }

  // Buscar dados atualizados de um quiz duplo específico
  Future<Map<String, dynamic>?> getQuizDuploData(String quizId, String userId) async {
    try {
      final response = await _client
          .from('user_quizzes')
          .select('*, quizzes(*), users!user_quizzes_user_id_fkey(*)')
          .eq('quiz_id', quizId)
          .or('user_id.eq.$userId,partner_id.eq.$userId')
          .order('created_at', ascending: false);

      if (response.isNotEmpty) {
        // Separar dados do usuário atual e do parceiro
        final userData = response.firstWhere(
          (r) => r['user_id'] == userId,
          orElse: () => response.first,
        );
        
        final partnerData = response.firstWhere(
          (r) => r['user_id'] != userId,
          orElse: () => response.first,
        );

        return {
          'userQuiz': userData,
          'partnerQuiz': partnerData,
          'quiz': userData['quizzes'],
          'partner': partnerData['users'],
        };
      }
      
      return null;
    } catch (e) {
      developer.log('Erro ao buscar dados do quiz duplo: $e');
      return null;
    }
  }

  // Verificar se um quiz duplo pode ser iniciado
  Future<bool> podeIniciarQuizDuplo(String quizId, String userId) async {
    try {
      final response = await _client
          .from('user_quizzes')
          .select('is_ready, status')
          .eq('quiz_id', quizId)
          .or('user_id.eq.$userId,partner_id.eq.$userId');

      if (response.length == 2) {
        final userReady = response.firstWhere((r) => r['user_id'] == userId)['is_ready'] ?? false;
        final partnerReady = response.firstWhere((r) => r['user_id'] != userId)['is_ready'] ?? false;
        final status = response.first['status'] as String;

        return userReady && partnerReady && status == 'waiting_partner';
      }
      
      return false;
    } catch (e) {
      developer.log('Erro ao verificar se pode iniciar quiz duplo: $e');
      return false;
    }
  }

  // =====================================================
  // ATUALIZAÇÃO EM TEMPO REAL - QUIZ DUPLO
  // =====================================================

  // Atualizar pontuação em tempo real (sem finalizar o quiz)
  Future<void> atualizarPontuacaoTempoReal({
    required String userId,
    required String quizId,
    required int score,
    required Map<String, dynamic> answers,
  }) async {
    try {
      await _client
          .from('user_quizzes')
          .update({
            'score': score,
            'answers': answers,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', userId)
          .eq('quiz_id', quizId);
    } catch (e) {
      developer.log('Erro ao atualizar pontuação em tempo real: $e');
      rethrow;
    }
  }

  // Finalizar quiz individual (marcar como completed)
  Future<void> finalizarQuizIndividual({
    required String userId,
    required String quizId,
    required int score,
    required Map<String, dynamic> answers,
  }) async {
    try {
      await _client
          .from('user_quizzes')
          .update({
            'score': score,
            'answers': answers,
            'completed_at': DateTime.now().toIso8601String(),
            'status': 'completed',
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', userId)
          .eq('quiz_id', quizId);
    } catch (e) {
      developer.log('Erro ao finalizar quiz individual: $e');
      rethrow;
    }
  }

  // Verificar se ambos os usuários finalizaram o quiz
  Future<bool> verificarAmbosFinalizaram(String quizId) async {
    try {
      final response = await _client
          .from('user_quizzes')
          .select('user_id, status')
          .eq('quiz_id', quizId);
      
      // Verificar se todos os registros estão com status 'completed'
      return response.every((record) => record['status'] == 'completed');
    } catch (e) {
      developer.log('Erro ao verificar se ambos finalizaram: $e');
      return false;
    }
  }

  // Buscar pontuação atual de um quiz duplo
  Future<Map<String, dynamic>> buscarPontuacaoQuizDuplo(String quizId) async {
    try {
      final response = await _client
          .from('user_quizzes')
          .select('user_id, partner_id, score, total_questions, status, answers')
          .eq('quiz_id', quizId);
      
      if (response.isEmpty) return {};
      
      final result = <String, dynamic>{};
      for (final record in response) {
        final userId = record['user_id'] as String;
        result[userId] = {
          'score': record['score'] ?? 0,
          'totalQuestions': record['total_questions'] ?? 0,
          'status': record['status'],
          'answers': record['answers'],
          'partnerId': record['partner_id'],
        };
      }
      
      return result;
    } catch (e) {
      developer.log('Erro ao buscar pontuação do quiz duplo: $e');
      return {};
    }
  }

  // Stream para monitorar pontuação em tempo real
  Stream<Map<String, dynamic>> streamPontuacaoQuizDuplo(String quizId) {
    return _client
        .from('user_quizzes')
        .stream(primaryKey: ['id'])
        .eq('quiz_id', quizId)
        .map((data) {
          final result = <String, dynamic>{};
          for (final record in data) {
            final userId = record['user_id'] as String;
            result[userId] = {
              'score': record['score'] ?? 0,
              'totalQuestions': record['total_questions'] ?? 0,
              'status': record['status'],
              'answers': record['answers'],
              'partnerId': record['partner_id'],
            };
          }
          return result;
        });
  }
} 