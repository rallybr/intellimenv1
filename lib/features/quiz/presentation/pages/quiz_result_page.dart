import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/models/quiz_model.dart';
import '../../../../shared/models/user_model.dart';
import '../../../../shared/providers/data_provider.dart';
import '../../../../shared/providers/auth_provider.dart';
import '../widgets/quiz_confrontation_widget.dart';
import 'package:intellimen/shared/models/user_quiz_model.dart';

class QuizResultPage extends ConsumerStatefulWidget {
  final UserQuizModel userQuiz;

  const QuizResultPage({
    super.key,
    required this.userQuiz,
  });

  @override
  ConsumerState<QuizResultPage> createState() => _QuizResultPageState();
}

class _QuizResultPageState extends ConsumerState<QuizResultPage> {
  QuizModel? quiz;
  UserModel? partner;
  UserQuizModel? partnerQuiz;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadResultData();
  }

  Future<void> _loadResultData() async {
    try {
      // Carregar dados do quiz
      final quizData = await ref.read(quizByIdProvider(widget.userQuiz.quizId).future);
      
      // Se for quiz em parceria, carregar dados do parceiro
      UserModel? partnerData;
      UserQuizModel? partnerQuizData;
      
      if (widget.userQuiz.isPartner && widget.userQuiz.partnerId != null) {
        final supabaseService = ref.read(supabaseServiceProvider);
        partnerData = await supabaseService.getUser(widget.userQuiz.partnerId!);
        
        // Buscar quiz do parceiro
        final partnerQuizzes = await supabaseService.getUserQuizzes(widget.userQuiz.partnerId!);
        partnerQuizData = partnerQuizzes.firstWhere(
          (pq) => pq.quizId == widget.userQuiz.quizId && pq.isCompleted,
          orElse: () => widget.userQuiz,
        );
      }

      if (mounted) {
        setState(() {
          quiz = quizData;
          partner = partnerData;
          partnerQuiz = partnerQuizData;
          isLoading = false;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar resultados: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: AppColors.primary,
        appBar: AppBar(
          title: const Text('Carregando Resultados...'),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        title: Text(quiz?.title ?? 'Resultados'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareResults,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Card de resultado principal
            _buildResultCard(),
            
            const SizedBox(height: 20),
            
            // Confronto em parceria (se aplicável)
            if (widget.userQuiz.isPartner && partner != null && partnerQuiz != null)
              QuizConfrontationWidget(
                userQuiz: widget.userQuiz,
                partnerQuiz: partnerQuiz!,
                partner: partner!,
              ),
            
            const SizedBox(height: 20),
            
            // Estatísticas detalhadas
            _buildDetailedStats(),
            
            const SizedBox(height: 20),
            
            // Botões de ação
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard() {
    final percentage = widget.userQuiz.percentage;
    final isExcellent = percentage >= 90;
    final isGood = percentage >= 70;
    final isAverage = percentage >= 50;
    
    Color resultColor;
    String resultText;
    IconData resultIcon;
    
    if (isExcellent) {
      resultColor = Colors.green;
      resultText = 'Excelente!';
      resultIcon = Icons.emoji_events;
    } else if (isGood) {
      resultColor = Colors.blue;
      resultText = 'Muito Bom!';
      resultIcon = Icons.thumb_up;
    } else if (isAverage) {
      resultColor = Colors.orange;
      resultText = 'Bom!';
      resultIcon = Icons.sentiment_satisfied;
    } else {
      resultColor = Colors.red;
      resultText = 'Continue Estudando!';
      resultIcon = Icons.school;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
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
          // Ícone de resultado
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: resultColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(40),
            ),
            child: Icon(
              resultIcon,
              size: 40,
              color: resultColor,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Texto de resultado
          Text(
            resultText,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: resultColor,
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Pontuação
          Text(
            '${widget.userQuiz.score}/${widget.userQuiz.totalQuestions}',
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          
          const SizedBox(height: 4),
          
          // Percentual
          Text(
            '${percentage.toStringAsFixed(1)}%',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Duração
          if (widget.userQuiz.duration != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.timer, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  'Tempo: ${widget.userQuiz.durationText}',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailedStats() {
    return Container(
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
            'Estatísticas Detalhadas',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          
          const SizedBox(height: 16),
          
          _buildStatRow('Acertos', '${widget.userQuiz.score}', Colors.green),
          _buildStatRow('Erros', '${(widget.userQuiz.totalQuestions ?? 0) - widget.userQuiz.score}', Colors.red),
          _buildStatRow('Total de Perguntas', '${widget.userQuiz.totalQuestions}', Colors.blue),
          _buildStatRow('Taxa de Acerto', '${widget.userQuiz.percentage.toStringAsFixed(1)}%', Colors.orange),
          
          if (widget.userQuiz.duration != null)
            _buildStatRow('Tempo Total', widget.userQuiz.durationText, Colors.purple),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // Botão para tentar novamente
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _retryQuiz,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Tentar Novamente',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Botão para voltar à lista
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: _backToQuizList,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Voltar à Lista de Quizzes',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _shareResults() {
    // Aqui você pode implementar a funcionalidade de compartilhamento
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Resultados copiados para a área de transferência!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  String _getResultText(double percentage) {
    if (percentage >= 90) return 'Excelente! 🏆';
    if (percentage >= 70) return 'Muito Bom! 👍';
    if (percentage >= 50) return 'Bom! 😊';
    return 'Continue Estudando! 📚';
  }

  void _retryQuiz() {
    Navigator.of(context).pop(); // Volta para a lista de quizzes
  }

  void _backToQuizList() {
    Navigator.of(context).pop(); // Volta para a lista de quizzes
  }
} 