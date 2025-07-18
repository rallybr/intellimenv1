import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/models/user_quiz_model.dart';
import '../../../../shared/models/user_model.dart';
import '../../../../shared/providers/data_provider.dart';
import '../../../../shared/providers/auth_provider.dart';

class QuizDuploStatusWidget extends ConsumerWidget {
  final UserQuizModel userQuiz;
  final VoidCallback? onStartQuiz;

  const QuizDuploStatusWidget({
    super.key,
    required this.userQuiz,
    this.onStartQuiz,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserDataProvider).value;
    if (currentUser == null) return const SizedBox.shrink();

    return ref.watch(quizDuploStatusStreamProvider(userQuiz.quizId)).when(
      data: (quizzes) {
        if (quizzes.isEmpty) return const SizedBox.shrink();

        // Encontrar dados do usuário atual e do parceiro
        final userQuizData = quizzes.firstWhere(
          (q) => q.userId == currentUser.id,
          orElse: () => userQuiz,
        );
        
        final partnerQuizData = quizzes.firstWhere(
          (q) => q.userId != currentUser.id,
          orElse: () => userQuiz,
        );

        final isReady = userQuizData.isReady ?? false;
        final partnerReady = partnerQuizData.isReady ?? false;
        final canStart = userQuizData.canStart;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.people,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Status do Quiz Duplo',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Status do usuário atual
              Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: isReady ? Colors.green : Colors.grey,
                    child: Icon(
                      isReady ? Icons.check : Icons.person,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Você',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                  Text(
                    isReady ? 'Pronto' : 'Aguardando',
                    style: TextStyle(
                      fontSize: 12,
                      color: isReady ? Colors.green : Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Status do parceiro
              FutureBuilder<UserModel?>(
                future: ref.read(supabaseServiceProvider).getUser(userQuiz.partnerId!),
                builder: (context, snapshot) {
                  final partner = snapshot.data;
                  
                  return Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: partnerReady ? Colors.green : Colors.grey,
                        backgroundImage: partner?.photoUrl != null 
                            ? NetworkImage(partner!.photoUrl!)
                            : null,
                        child: partner?.photoUrl == null
                            ? Icon(
                                partnerReady ? Icons.check : Icons.person,
                                color: Colors.white,
                                size: 16,
                              )
                            : null,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          partner?.name ?? 'Parceiro',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                      Text(
                        partnerReady ? 'Pronto' : 'Aguardando',
                        style: TextStyle(
                          fontSize: 12,
                          color: partnerReady ? Colors.green : Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  );
                },
              ),
              
              // Botão para começar (só aparece quando ambos estão prontos)
              if (canStart) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onStartQuiz,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Começar Quiz!',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ] else if (!isReady) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      try {
                        await ref.read(dataNotifierProvider.notifier).marcarUsuarioPronto(
                          userId: currentUser.id,
                          quizId: userQuiz.quizId,
                        );
                      } catch (error) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Erro ao marcar como pronto: $error'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Ficar Pronto',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
      loading: () => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 8),
            Text('Carregando status...'),
          ],
        ),
      ),
      error: (error, stack) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red.shade200),
        ),
        child: Row(
          children: [
            Icon(Icons.error, color: Colors.red.shade600, size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Erro ao carregar status: $error',
                style: TextStyle(
                  color: Colors.red.shade600,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 