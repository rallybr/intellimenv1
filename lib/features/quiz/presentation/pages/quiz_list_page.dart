import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/providers/quiz_provider.dart';
import '../../../../shared/providers/auth_provider.dart';
import '../../../../shared/models/quiz_model.dart';
import '../../../../shared/models/user_quiz_model.dart';
import '../widgets/quiz_card_widget.dart';
import 'quiz_play_page.dart';
import 'quiz_waiting_partner_page.dart';

class QuizListPage extends ConsumerStatefulWidget {
  const QuizListPage({super.key});

  @override
  ConsumerState<QuizListPage> createState() => _QuizListPageState();
}

class _QuizListPageState extends ConsumerState<QuizListPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserDataProvider);
    final hasPartner = ref.watch(hasPartnerProvider);

    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        title: const Text('Quizzes'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Individuais'),
            Tab(text: 'Em Parceria'),
          ],
        ),
      ),
      body: userAsync.when(
        data: (user) {
          if (user == null) {
            return const Center(
              child: Text(
                'Erro ao carregar dados do usuário',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          return TabBarView(
            controller: _tabController,
            children: [
              // Tab de Quizzes Individuais
              _buildIndividualQuizzesTab(),
              // Tab de Quizzes em Parceria
              _buildPartnerQuizzesTab(hasPartner),
            ],
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
        error: (error, stackTrace) => Center(
          child: Text(
            'Erro: $error',
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildIndividualQuizzesTab() {
    final individualQuizzesAsync = ref.watch(individualQuizzesProvider);

    return individualQuizzesAsync.when(
      data: (quizzes) {
        if (quizzes.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.quiz_outlined,
                  size: 64,
                  color: Colors.white54,
                ),
                SizedBox(height: 16),
                Text(
                  'Nenhum quiz individual disponível',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: quizzes.length,
          itemBuilder: (context, index) {
            final quiz = quizzes[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: QuizCardWidget(
                quiz: quiz,
                onTap: () => _startIndividualQuiz(quiz),
              ),
            );
          },
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
      error: (error, stackTrace) => Center(
        child: Text(
          'Erro ao carregar quizzes: $error',
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildPartnerQuizzesTab(bool hasPartner) {
    if (!hasPartner) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 64,
              color: Colors.white54,
            ),
            SizedBox(height: 16),
            Text(
              'Você precisa ter um parceiro\npara acessar quizzes em dupla',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    final partnerQuizzesAsync = ref.watch(partnerQuizzesProvider);

    return partnerQuizzesAsync.when(
      data: (quizzes) {
        if (quizzes.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.quiz_outlined,
                  size: 64,
                  color: Colors.white54,
                ),
                SizedBox(height: 16),
                Text(
                  'Nenhum quiz em parceria disponível',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: quizzes.length,
          itemBuilder: (context, index) {
            final quiz = quizzes[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: QuizCardWidget(
                quiz: quiz,
                onTap: () => _startPartnerQuiz(quiz),
              ),
            );
          },
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
      error: (error, stackTrace) => Center(
        child: Text(
          'Erro ao carregar quizzes: $error',
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  void _startIndividualQuiz(QuizModel quiz) {
    _showQuizStartDialog(quiz, null);
  }

  void _startPartnerQuiz(QuizModel quiz) async {
    final userAsync = ref.read(currentUserDataProvider);
    userAsync.whenData((user) async {
      if (user?.partnerId != null) {
        // Verificar se já existe um quiz duplo em andamento para este quiz
        final supabaseService = ref.read(supabaseServiceProvider);
        final existingQuizzes = await supabaseService.getUserQuizzes(user!.id);
        
        final existingQuiz = existingQuizzes.firstWhere(
          (uq) => uq.quizId == quiz.id && uq.isPartner,
          orElse: () => UserQuizModel(
            id: '',
            userId: user.id,
            quizId: quiz.id,
            partnerId: user.partnerId,
            score: 0,
            totalQuestions: 0,
            startedAt: DateTime.now(),
            status: 'pending_invite',
            createdAt: DateTime.now(),
            isReady: false,
          ),
        );

        if (existingQuiz.id.isNotEmpty) {
          // Se já existe um quiz, verificar o status
          if (existingQuiz.isWaitingPartner) {
            // Redirecionar para página de aguardando parceiro
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => QuizWaitingPartnerPage(userQuiz: existingQuiz),
              ),
            );
            return;
          } else if (existingQuiz.isInProgress) {
            // Redirecionar para página do quiz
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => QuizPlayPage(userQuiz: existingQuiz),
              ),
            );
            return;
          }
        }

        // Se não existe ou está em outro status, mostrar diálogo de início
        _showQuizStartDialog(quiz, user.partnerId);
      }
    });
  }

  void _showQuizStartDialog(QuizModel quiz, String? partnerId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Iniciar Quiz: ${quiz.title}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Descrição: ${quiz.description}'),
            const SizedBox(height: 8),
            Text('Categoria: ${quiz.category}'),
            const SizedBox(height: 8),
            Text('Dificuldade: ${quiz.difficultyText}'),
            if (partnerId != null) ...[
              const SizedBox(height: 8),
              const Text(
                'Este quiz será realizado em parceria.',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _createAndStartQuiz(quiz, partnerId);
            },
            child: const Text('Iniciar'),
          ),
        ],
      ),
    );
  }

  void _createAndStartQuiz(QuizModel quiz, String? partnerId) async {
    try {
      final user = ref.read(currentUserDataProvider).value;
      if (user == null) return;

      if (partnerId != null) {
        // Criar convite para quiz duplo
        final supabaseService = ref.read(supabaseServiceProvider);
        await supabaseService.criarConviteQuizDuplo(
          fromUserId: user.id,
          toUserId: partnerId,
          quizId: quiz.id,
        );

        // Buscar o quiz criado
        final userQuizzes = await supabaseService.getUserQuizzes(user.id);
        final createdQuiz = userQuizzes.firstWhere(
          (uq) => uq.quizId == quiz.id && uq.partnerId == partnerId,
        );

        // Navegar para a página de aguardando parceiro
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => QuizWaitingPartnerPage(userQuiz: createdQuiz),
          ),
        );
      } else {
        // Quiz individual - criar e iniciar diretamente
        final supabaseService = ref.read(supabaseServiceProvider);
        final questions = await supabaseService.getQuizQuestions(quiz.id);
        
        final userQuiz = UserQuizModel(
          id: '',
          userId: user.id,
          quizId: quiz.id,
          score: 0,
          totalQuestions: questions.length,
          startedAt: DateTime.now(),
          status: 'in_progress',
          createdAt: DateTime.now(),
          isReady: false,
        );

        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => QuizPlayPage(userQuiz: userQuiz),
          ),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao iniciar quiz: $error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
} 