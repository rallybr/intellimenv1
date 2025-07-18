import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../models/user_quiz_model.dart';
import '../providers/data_provider.dart';

class QuizConfrontationWidget extends ConsumerStatefulWidget {
  final String userId;
  final VoidCallback? onUpdate;

  const QuizConfrontationWidget({
    super.key,
    required this.userId,
    this.onUpdate,
  });

  @override
  ConsumerState<QuizConfrontationWidget> createState() => _QuizConfrontationWidgetState();
}

class _QuizConfrontationWidgetState extends ConsumerState<QuizConfrontationWidget> {
  final PageController _pageController = PageController(viewportFraction: 0.92);
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final confrontosAsync = ref.watch(userQuizzesStreamProvider);
    
    return confrontosAsync.when(
      data: (allQuizzes) {
        // Filtrar apenas confrontos (que têm partnerId)
        final confrontos = allQuizzes.where((quiz) => quiz.isPartner).toList();
        
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
                  return _buildQuizCard(context, ref, confronto);
                },
              ),
            ),
            const SizedBox(height: 16),
            _buildPageIndicators(confrontos.length),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('Erro: $error'),
      ),
    );
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
            color: Colors.black.withValues(alpha: 0.08),
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

  Widget _buildPageIndicators(int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        return Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _currentPage == index ? AppColors.primary : Colors.grey[300],
          ),
        );
      }),
    );
  }

  Widget _buildQuizCard(BuildContext context, WidgetRef ref, UserQuizModel confronto) {
    final pontuacaoAsync = ref.watch(pontuacaoQuizDuploStreamProvider(confronto.quizId));
    
    return pontuacaoAsync.when(
      data: (pontuacao) {
        // Buscar dados dos usuários
        final user1Async = ref.watch(userByIdProvider(confronto.userId));
        final user2Async = ref.watch(userByIdProvider(confronto.partnerId!));
        final quizAsync = ref.watch(quizByIdProvider(confronto.quizId));
        
        return user1Async.when(
          data: (user1) {
            return user2Async.when(
              data: (user2) {
                return quizAsync.when(
                  data: (quiz) {
                    // Buscar dados do parceiro na pontuação em tempo real
                    final partnerData = pontuacao[confronto.partnerId!];
                    final currentUserData = pontuacao[confronto.userId];
                    
                    final partnerScore = partnerData?['score'] ?? 0;
                    final currentUserScore = currentUserData?['score'] ?? confronto.score;
                    final totalQuestions = currentUserData?['totalQuestions'] ?? confronto.totalQuestions ?? 0;
            
                    final pontos1 = currentUserScore;
                    final total = totalQuestions;
                    final pontos2 = partnerScore;
                    
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEE0E0E0),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.12),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            quiz?.title ?? 'Quiz Duplo',
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
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, stack) => Center(child: Text('Erro: $error')),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('Erro: $error')),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(child: Text('Erro: $error')),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('Erro: $error'),
      ),
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
            backgroundImage: url.isNotEmpty ? NetworkImage(url) : null,
            radius: 32,
            onBackgroundImageError: (exception, stackTrace) {
              // Handle error if image fails to load
            },
            child: url.isEmpty ? Icon(Icons.person, size: 32, color: Colors.grey[600]) : null,
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
} 