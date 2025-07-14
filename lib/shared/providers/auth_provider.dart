import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/services/supabase_service.dart';
import '../models/user_model.dart';

// Provider para o serviço do Supabase
final supabaseServiceProvider = Provider<SupabaseService>((ref) {
  return SupabaseService();
});

// Provider para o usuário atual
final currentUserProvider = StreamProvider<User?>((ref) {
  final supabaseService = ref.watch(supabaseServiceProvider);
  return supabaseService.authStateChanges.map((event) => event.session?.user);
});

// Provider para os dados completos do usuário atual
final currentUserDataProvider = FutureProvider<UserModel?>((ref) async {
  final user = ref.watch(currentUserProvider).value;
  if (user == null) return null;
  
  final supabaseService = ref.watch(supabaseServiceProvider);
  return await supabaseService.getUser(user.id);
});

// Provider para verificar se o usuário está autenticado
final isAuthenticatedProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider).value;
  return user != null;
});

// Provider para verificar se o usuário completou o perfil
final hasCompletedProfileProvider = Provider<bool>((ref) {
  final userData = ref.watch(currentUserDataProvider).value;
  return userData?.hasCompletedProfile ?? false;
});

// Provider para o nível de acesso do usuário
final userAccessLevelProvider = Provider<String>((ref) {
  final userData = ref.watch(currentUserDataProvider).value;
  return userData?.accessLevel ?? 'general';
});

// Provider para verificar se o usuário tem parceiro
final hasPartnerProvider = Provider<bool>((ref) {
  final userData = ref.watch(currentUserDataProvider).value;
  return userData?.partnerId != null;
});

// Provider para verificar se o usuário é elegível para Campus
final isCampusEligibleProvider = Provider<bool>((ref) {
  final userData = ref.watch(currentUserDataProvider).value;
  return userData?.isCampusEligible ?? false;
});

// Provider para verificar se o usuário é elegível para Academy
final isAcademyEligibleProvider = Provider<bool>((ref) {
  final userData = ref.watch(currentUserDataProvider).value;
  return userData?.isTeen ?? false;
});

// Notifier para gerenciar ações de autenticação
class AuthNotifier extends StateNotifier<AsyncValue<UserModel?>> {
  final SupabaseService _supabaseService;
  
  AuthNotifier(this._supabaseService) : super(const AsyncValue.loading()) {
    _initialize();
  }
  
  void _initialize() {
    final user = _supabaseService.currentUser;
    if (user != null) {
      _loadUserData(user.id);
    } else {
      state = const AsyncValue.data(null);
    }
  }
  
  Future<void> _loadUserData(String userId) async {
    try {
      state = const AsyncValue.loading();
      final userData = await _supabaseService.getUser(userId);
      state = AsyncValue.data(userData);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
  
  Future<void> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      state = const AsyncValue.loading();
      final response = await _supabaseService.signUp(
        email: email,
        password: password,
        name: name,
      );
      
      if (response.user != null) {
        await _loadUserData(response.user!.id);
      }
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }
  
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    try {
      state = const AsyncValue.loading();
      final response = await _supabaseService.signIn(
        email: email,
        password: password,
      );
      
      if (response.user != null) {
        await _loadUserData(response.user!.id);
      }
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }
  
  Future<void> signOut() async {
    try {
      await _supabaseService.signOut();
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }
  
  Future<void> updateProfile(UserModel updatedUser) async {
    try {
      await _supabaseService.updateUser(updatedUser);
      state = AsyncValue.data(updatedUser);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }
  
  Future<void> refreshUserData() async {
    final user = _supabaseService.currentUser;
    if (user != null) {
      await _loadUserData(user.id);
    }
  }
}

// Provider para o AuthNotifier
final authNotifierProvider = StateNotifierProvider<AuthNotifier, AsyncValue<UserModel?>>((ref) {
  final supabaseService = ref.watch(supabaseServiceProvider);
  return AuthNotifier(supabaseService);
}); 