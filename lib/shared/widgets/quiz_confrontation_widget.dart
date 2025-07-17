import 'package:flutter/material.dart';
import '../../core/services/supabase_service.dart';
import '../models/user_model.dart';
import '../models/quiz_model.dart';

class QuizConfrontationWidget extends StatefulWidget {
  final String userId;
  final VoidCallback? onUpdate;

  const QuizConfrontationWidget({
    Key? key,
    required this.userId,
    this.onUpdate,
  }) : super(key: key);

  @override
  State<QuizConfrontationWidget> createState() => _QuizConfrontationWidgetState();
}

class _QuizConfrontationWidgetState extends State<QuizConfrontationWidget> {
  final PageController _pageController = PageController(viewportFraction: 0.92);
  int _currentPage = 0;
  final SupabaseService _supabaseService = SupabaseService();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<UserQuizModel>>(
      stream: Stream.periodic(const Duration(seconds: 2), (_) async {
        return await _getConfrontos();
      }).asyncMap((future) => future),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final confrontos = snapshot.data!;
        if (confrontos.isEmpty) {
          return _buildEmptyState();
        }

        return Column(
          children: [
            SizedBox(
              height: 320,
              child: PageView.builder(
                itemCount: confrontos.length,
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  final confronto = confrontos[index];
                  return _buildQuizCard(confronto);
                },
              ),
            ),
            const SizedBox(height: 16),
            _buildPageIndicators(confrontos.length),
          ],
        );
      },
    );
  }

  Future<List<UserQuizModel>> _getConfrontos() async {
    try {
      // Buscar todos os quizzes do usuário (como jogador principal)
      final userQuizzes = await _supabaseService.getUserQuizzes(widget.userId);
      
      // Buscar todos os quizzes onde o usuário é parceiro
      final partnerQuizzes = await _supabaseService.client
          .from('user_quizzes')
          .select()
          .eq('partner_id', widget.userId);
      
      // Buscar também quizzes completados que podem ser confrontos
      final completedQuizzes = await _supabaseService.client
          .from('user_quizzes')
          .select()
          .eq('user_id', widget.userId)
          .eq('status', 'completed')
          .not('partner_id', 'is', null);
      
      // Combinar e filtrar apenas confrontos (que têm partnerId)
      final allQuizzes = [
        ...userQuizzes,
        ...partnerQuizzes.map((json) => UserQuizModel.fromJson(json)),
        ...completedQuizzes.map((json) => UserQuizModel.fromJson(json)),
      ];
      
      // Filtrar apenas confrontos únicos (remover duplicatas)
      final confrontos = <UserQuizModel>[];
      final seenIds = <String>{};
      
      for (final quiz in allQuizzes) {
        if (quiz.partnerId != null && !seenIds.contains(quiz.id)) {
          confrontos.add(quiz);
          seenIds.add(quiz.id ?? '');
        }
      }
      
      if (confrontos.isEmpty) {
        final completedConfrontos = await _supabaseService.client
            .from('user_quizzes')
            .select()
            .or('user_id.eq.${widget.userId},partner_id.eq.${widget.userId}')
            .eq('status', 'completed')
            .not('partner_id', 'is', null);
        
        for (final json in completedConfrontos) {
          final quiz = UserQuizModel.fromJson(json);
          if (!seenIds.contains(quiz.id)) {
            confrontos.add(quiz);
            seenIds.add(quiz.id ?? '');
          }
        }
      }
      
      return confrontos;
    } catch (e) {
      return [];
    }
  }

  Widget _buildEmptyState() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFEE0E0E0),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 25,
            offset: const Offset(0, 12),
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(Icons.quiz, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Nenhum confronto encontrado',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Participe de um confronto de quiz para ver seu histórico aqui',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildQuizCard(UserQuizModel confronto) {
    return FutureBuilder(
      future: Future.wait([
        _supabaseService.getUser(confronto.userId),
        _supabaseService.getUser(confronto.partnerId!),
        _supabaseService.client
            .from('user_quizzes')
            .select()
            .eq('user_id', confronto.partnerId!)
            .eq('quiz_id', confronto.quizId)
            .maybeSingle()
            .then((result) => result),
        _supabaseService.getQuizQuestions(confronto.quizId),
        _supabaseService.getQuizzes(),
      ]),
      builder: (context, AsyncSnapshot<List<dynamic>> snap) {
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final user1 = snap.data![0] as UserModel?;
        final user2 = snap.data![1] as UserModel?;
        final partnerQuizRaw = snap.data![2];
        final quizQuestions = snap.data![3] as List;
        final quizzes = snap.data![4] as List<QuizModel>;
        
        final quiz = quizzes.firstWhere(
          (q) => q.id == confronto.quizId,
          orElse: () => QuizModel(
            id: confronto.quizId,
            title: 'Quiz',
            description: '',
            type: '',
            category: '',
            difficulty: 1,
            createdAt: DateTime.now(),
            isActive: true,
          ),
        );
        
        final partnerQuiz = partnerQuizRaw != null
            ? UserQuizModel.fromJson(partnerQuizRaw)
            : null;
        
        final pontos1 = confronto.score;
        final total = confronto.totalQuestions > 0 ? confronto.totalQuestions : quizQuestions.length;
        final pontos2 = partnerQuiz?.score ?? 0;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFEE0E0E0),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                quiz.title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                  color: Color(0xFF232323),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildQuizProfile(
                      nome: user1?.name ?? '-',
                      url: user1?.photoUrl ?? '',
                      pontos: pontos1,
                      total: total,
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 80,
                    color: Colors.grey[300],
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                  Expanded(
                    child: _buildQuizProfile(
                      nome: user2?.name ?? '-',
                      url: user2?.photoUrl ?? '',
                      pontos: pontos2,
                      total: total,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuizProfile({
    required String nome,
    required String url,
    required int pontos,
    required int total,
  }) {
    final progresso = total > 0 ? pontos / total : 0.0;

    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFF00256d), width: 2),
          ),
          child: CircleAvatar(
            backgroundImage: NetworkImage(url),
            radius: 32,
            onBackgroundImageError: (exception, stackTrace) {
              // Handle error if image fails to load
            },
          ),
        ),
        const SizedBox(height: 8),
        Text(
          nome,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: progresso,
            backgroundColor: Colors.grey[200],
            color: Colors.blue,
            minHeight: 20,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          total > 0 ? '$pontos pontos de $total total' : '0 pontos',
          style: const TextStyle(fontSize: 14, color: Colors.black87),
        ),
      ],
    );
  }

  Widget _buildPageIndicators(int totalItems) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        totalItems > 10 ? 10 : totalItems,
        (index) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: index == _currentPage ? const Color(0xFF0256D) : Colors.grey[300],
            ),
          );
        },
      ),
    );
  }
} 