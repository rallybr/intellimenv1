import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/models/user_quiz_model.dart';
import '../../../../shared/models/quiz_model.dart';
import '../../../../shared/models/user_model.dart';
import '../../../../shared/providers/data_provider.dart';
import '../../../../shared/providers/auth_provider.dart';
import 'quiz_play_page.dart';

class QuizWaitingPartnerPage extends ConsumerStatefulWidget {
  final UserQuizModel userQuiz;

  const QuizWaitingPartnerPage({
    super.key,
    required this.userQuiz,
  });

  @override
  ConsumerState<QuizWaitingPartnerPage> createState() => _QuizWaitingPartnerPageState();
}

class _QuizWaitingPartnerPageState extends ConsumerState<QuizWaitingPartnerPage> {
  QuizModel? quiz;
  UserModel? partner;
  bool isLoading = true;
  bool isReady = false;
  bool partnerReady = false;
  bool canStart = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
      // Carregar dados do quiz
      final quizData = await ref.read(quizByIdProvider(widget.userQuiz.quizId).future);
      
      // Carregar dados do parceiro
      UserModel? partnerData;
      if (widget.userQuiz.partnerId != null) {
        final supabaseService = ref.read(supabaseServiceProvider);
        partnerData = await supabaseService.getUser(widget.userQuiz.partnerId!);
      }

      if (mounted) {
        setState(() {
          quiz = quizData;
          partner = partnerData;
          isLoading = false;
        });
      }

      // Iniciar monitoramento em tempo real
      _startRealTimeMonitoring();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar dados: $error'),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.of(context).pop();
      }
    }
  }

  void _startRealTimeMonitoring() {
    // Monitorar mudanças no status do quiz duplo
    ref.listen(quizDuploStatusStreamProvider(widget.userQuiz.quizId), (previous, next) {
      next.whenData((quizzes) {
        if (quizzes.isNotEmpty) {
          final currentUser = ref.read(currentUserDataProvider).value;
          if (currentUser == null) return;

          // Encontrar dados do usuário atual e do parceiro
          final userQuiz = quizzes.firstWhere(
            (q) => q.userId == currentUser.id,
            orElse: () => widget.userQuiz,
          );
          
          final partnerQuiz = quizzes.firstWhere(
            (q) => q.userId != currentUser.id,
            orElse: () => widget.userQuiz,
          );

          setState(() {
            isReady = userQuiz.isReady ?? false;
            partnerReady = partnerQuiz.isReady ?? false;
            canStart = userQuiz.canStart;
          });

          // Se ambos estão prontos e o quiz pode começar, navegar para o quiz
          if (canStart) {
            _startQuiz();
          }
        }
      });
    });
  }

  Future<void> _markAsReady() async {
    try {
      final currentUser = ref.read(currentUserDataProvider).value;
      if (currentUser == null) return;

      await ref.read(dataNotifierProvider.notifier).marcarUsuarioPronto(
        userId: currentUser.id,
        quizId: widget.userQuiz.quizId,
      );

      setState(() {
        isReady = true;
      });

      // Verificar se ambos estão prontos
      if (widget.userQuiz.partnerId != null) {
        final canStartQuiz = await ref.read(dataNotifierProvider.notifier).verificarEIniciarQuizDuplo(
          quizId: widget.userQuiz.quizId,
          user1Id: currentUser.id,
          user2Id: widget.userQuiz.partnerId!,
        );

        if (canStartQuiz) {
          _startQuiz();
        }
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao marcar como pronto: $error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _startQuiz() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => QuizPlayPage(userQuiz: widget.userQuiz),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: AppColors.primary,
        appBar: AppBar(
          title: const Text('Carregando...'),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    if (quiz == null) {
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
        title: Text('Quiz: ${quiz!.title}'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header com informações do quiz
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.people,
                    size: 48,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Quiz em Dupla',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    quiz!.title,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 18,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${quiz!.difficultyText} • ${quiz!.category}',
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Status dos participantes
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Status dos Participantes',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Status do usuário atual
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: isReady ? Colors.green : Colors.grey,
                        child: Icon(
                          isReady ? Icons.check : Icons.person,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Você',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              isReady ? 'Pronto!' : 'Aguardando...',
                              style: TextStyle(
                                fontSize: 14,
                                color: isReady ? Colors.green : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (!isReady)
                        ElevatedButton(
                          onPressed: _markAsReady,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          ),
                          child: const Text('Pronto'),
                        ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Status do parceiro
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: partnerReady ? Colors.green : Colors.grey,
                        backgroundImage: partner?.photoUrl != null 
                            ? NetworkImage(partner!.photoUrl!)
                            : null,
                        child: partner?.photoUrl == null
                            ? Icon(
                                partnerReady ? Icons.check : Icons.person,
                                color: Colors.white,
                              )
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              partner?.name ?? 'Parceiro',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              partnerReady ? 'Pronto!' : 'Aguardando...',
                              style: TextStyle(
                                fontSize: 14,
                                color: partnerReady ? Colors.green : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Botão para começar (só aparece quando ambos estão prontos)
            if (canStart)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _startQuiz,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Começar Quiz!',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

            const Spacer(),

            // Informações adicionais
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: Colors.white70,
                    size: 24,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Aguarde seu parceiro ficar pronto para começar o quiz',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 