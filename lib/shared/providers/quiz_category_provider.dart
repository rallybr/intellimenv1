import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../core/services/supabase_service.dart';
import '../models/quiz_category_model.dart';

// Provider para o serviço Supabase
final supabaseServiceProvider = Provider<SupabaseService>((ref) {
  return SupabaseService();
});

// Provider para listar todas as categorias
final quizCategoriesProvider = FutureProvider<List<QuizCategoryModel>>((ref) async {
  final supabaseService = ref.watch(supabaseServiceProvider);
  return await supabaseService.getQuizCategories();
});

// Notifier para gerenciar ações de categoria
class QuizCategoryNotifier extends StateNotifier<AsyncValue<void>> {
  final SupabaseService _supabaseService;
  
  QuizCategoryNotifier(this._supabaseService) : super(const AsyncValue.data(null));
  
  // Criar uma nova categoria
  Future<void> createCategory({
    required String name,
    required String description,
  }) async {
    try {
      state = const AsyncValue.loading();
      
      final category = QuizCategoryModel(
        id: const Uuid().v4(),
        name: name.trim(),
        description: description.trim(),
        createdAt: DateTime.now(),
      );
      
      await _supabaseService.createQuizCategory(category);
      
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }
  
  // Atualizar uma categoria
  Future<void> updateCategory(QuizCategoryModel category) async {
    try {
      state = const AsyncValue.loading();
      
      await _supabaseService.updateQuizCategory(category);
      
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }
  
  // Deletar uma categoria
  Future<void> deleteCategory(String categoryId) async {
    try {
      state = const AsyncValue.loading();
      
      await _supabaseService.deleteQuizCategory(categoryId);
      
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }
}

// Provider para o notifier de categoria
final quizCategoryNotifierProvider = StateNotifierProvider<QuizCategoryNotifier, AsyncValue<void>>((ref) {
  final supabaseService = ref.watch(supabaseServiceProvider);
  return QuizCategoryNotifier(supabaseService);
}); 