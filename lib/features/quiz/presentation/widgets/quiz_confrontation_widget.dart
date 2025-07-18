import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/models/quiz_model.dart';
import '../../../../shared/models/user_model.dart';
import 'package:intellimen/shared/models/user_quiz_model.dart';

class QuizConfrontationWidget extends StatelessWidget {
  final UserQuizModel userQuiz;
  final UserQuizModel partnerQuiz;
  final UserModel partner;

  const QuizConfrontationWidget({
    super.key,
    required this.userQuiz,
    required this.partnerQuiz,
    required this.partner,
  });

  @override
  Widget build(BuildContext context) {
    final userWon = userQuiz.percentage > partnerQuiz.percentage;
    final isTie = userQuiz.percentage == partnerQuiz.percentage;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Título do confronto
          Row(
            children: [
              const Icon(
                Icons.emoji_events,
                color: Colors.orange,
                size: 24,
              ),
              const SizedBox(width: 8),
              const Text(
                'Confronto em Parceria',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Resultado do confronto
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _getResultColor(userWon, isTie).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _getResultColor(userWon, isTie),
                width: 2,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _getResultIcon(userWon, isTie),
                  color: _getResultColor(userWon, isTie),
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  _getResultText(userWon, isTie),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _getResultColor(userWon, isTie),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Comparação dos resultados
          Row(
            children: [
              // Resultado do usuário atual
              Expanded(
                child: _buildPlayerResult(
                  name: 'Você',
                  score: userQuiz.score,
                  totalQuestions: userQuiz.totalQuestions ?? 0,
                  percentage: userQuiz.percentage,
                  duration: userQuiz.durationText,
                  isWinner: userWon && !isTie,
                  isCurrentUser: true,
                ),
              ),
              
              // VS
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  children: [
                    const Text(
                      'VS',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 2,
                      height: 60,
                      color: Colors.grey.shade300,
                    ),
                  ],
                ),
              ),
              
              // Resultado do parceiro
              Expanded(
                child: _buildPlayerResult(
                  name: partner.name,
                  score: partnerQuiz.score,
                  totalQuestions: partnerQuiz.totalQuestions ?? 0,
                  percentage: partnerQuiz.percentage,
                  duration: partnerQuiz.durationText,
                  isWinner: !userWon && !isTie,
                  isCurrentUser: false,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Diferença de pontuação
          if (!isTie) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    userWon ? Icons.trending_up : Icons.trending_down,
                    color: userWon ? Colors.green : Colors.red,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    userWon 
                        ? 'Você venceu por ${(userQuiz.percentage - partnerQuiz.percentage).toStringAsFixed(1)}%'
                        : 'Você perdeu por ${(partnerQuiz.percentage - userQuiz.percentage).toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 14,
                      color: userWon ? Colors.green : Colors.red,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPlayerResult({
    required String name,
    required int score,
    required int totalQuestions,
    required double percentage,
    required String duration,
    required bool isWinner,
    required bool isCurrentUser,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isWinner ? Colors.green.withOpacity(0.1) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isWinner ? Colors.green : Colors.grey.shade300,
          width: isWinner ? 2 : 1,
        ),
      ),
      child: Column(
        children: [
          // Nome do jogador
          Text(
            name,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isCurrentUser ? AppColors.primary : Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 8),
          
          // Pontuação
          Text(
            '$score/$totalQuestions',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          
          // Percentual
          Text(
            '${percentage.toStringAsFixed(1)}%',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Duração
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.timer,
                size: 16,
                color: Colors.grey,
              ),
              const SizedBox(width: 4),
              Text(
                duration,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          
          // Indicador de vitória
          if (isWinner) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'VENCEDOR',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getResultColor(bool userWon, bool isTie) {
    if (isTie) return Colors.orange;
    return userWon ? Colors.green : Colors.red;
  }

  IconData _getResultIcon(bool userWon, bool isTie) {
    if (isTie) return Icons.handshake;
    return userWon ? Icons.emoji_events : Icons.sentiment_dissatisfied;
  }

  String _getResultText(bool userWon, bool isTie) {
    if (isTie) return 'Empate!';
    return userWon ? 'Você Venceu!' : 'Você Perdeu!';
  }
} 