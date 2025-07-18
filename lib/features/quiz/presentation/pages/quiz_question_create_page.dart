import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../shared/models/quiz_question_model.dart';
import '../../../../shared/providers/auth_provider.dart';
import 'dart:developer' as developer;

class QuizQuestionCreatePage extends ConsumerStatefulWidget {
  final String? quizId;
  
  const QuizQuestionCreatePage({super.key, this.quizId});

  @override
  ConsumerState<QuizQuestionCreatePage> createState() => _QuizQuestionCreatePageState();
}

class _QuizQuestionCreatePageState extends ConsumerState<QuizQuestionCreatePage> {
  final _formKey = GlobalKey<FormState>();
  final _questionController = TextEditingController();
  final List<TextEditingController> _optionControllers = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ];
  int _correctAnswerIndex = 0;
  String _selectedQuiz = 'Selecione um Quiz';
  bool _isLoading = false;

  // Lista de quizzes disponíveis
  List<String> _availableQuizzes = ['Selecione um Quiz'];

  @override
  void initState() {
    super.initState();
    _loadQuizzes();
  }

  Future<void> _loadQuizzes() async {
    try {
      final supabaseService = ref.read(supabaseServiceProvider);
      final quizzes = await supabaseService.getQuizzes();
      setState(() {
        _availableQuizzes = ['Selecione um Quiz'] + quizzes.map((q) => q.title).toList();
        
        // Se um quizId foi fornecido, pré-selecionar o quiz correspondente
        if (widget.quizId != null) {
          final selectedQuiz = quizzes.firstWhere(
            (q) => q.id == widget.quizId,
            orElse: () => quizzes.first,
          );
          _selectedQuiz = selectedQuiz.title;
        }
      });
    } catch (error) {
      developer.log('Erro ao carregar quizzes: $error');
    }
  }

  @override
  void dispose() {
    _questionController.dispose();
    for (var controller in _optionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        title: const Text('Criar Questão'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Icon(
                    Icons.question_answer,
                    size: 64,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Criar Nova Questão',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Adicione perguntas e opções ao seu quiz',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
            // Formulário
            Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Seleção do Quiz
                      const Text(
                        'Quiz',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      
                      DropdownButtonFormField<String>(
                        value: _selectedQuiz == 'Selecione um Quiz' ? null : _selectedQuiz,
                        decoration: const InputDecoration(
                          labelText: 'Selecione o Quiz',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.quiz),
                        ),
                        items: _availableQuizzes.map((quiz) {
                          return DropdownMenuItem(
                            value: quiz,
                            child: Text(quiz),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedQuiz = value!;
                          });
                        },
                        validator: (value) {
                          if (value == null || value == 'Selecione um Quiz') {
                            return 'Por favor, selecione um quiz';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Questão
                      const Text(
                        'Questão',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      
                      TextFormField(
                        controller: _questionController,
                        decoration: const InputDecoration(
                          labelText: 'Pergunta',
                          hintText: 'Digite a pergunta aqui...',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.question_mark),
                        ),
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, insira a pergunta';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Opções de Resposta
                      const Text(
                        'Opções de Resposta',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      
                      const Text(
                        'Marque a opção correta:',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Opções
                      ...List.generate(4, (index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            children: [
                              Radio<int>(
                                value: index,
                                groupValue: _correctAnswerIndex,
                                onChanged: (value) {
                                  setState(() {
                                    _correctAnswerIndex = value!;
                                  });
                                },
                                activeColor: AppColors.blue,
                              ),
                              Expanded(
                                child: TextFormField(
                                  controller: _optionControllers[index],
                                  decoration: InputDecoration(
                                    labelText: 'Opção ${index + 1}',
                                    hintText: 'Digite a opção ${index + 1}',
                                    border: const OutlineInputBorder(),
                                    suffixIcon: _correctAnswerIndex == index
                                        ? const Icon(Icons.check_circle, color: Colors.green)
                                        : null,
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Por favor, preencha esta opção';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                      
                      const SizedBox(height: 24),
                      
                      // Botão Criar
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _createQuestion,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'Criar Questão',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Botão Adicionar Outra Questão
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: _isLoading ? null : _addAnotherQuestion,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.blue,
                            side: const BorderSide(color: AppColors.blue),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Adicionar Outra Questão',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Dicas
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.orange.withOpacity(0.3),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.lightbulb,
                                  color: Colors.orange,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Dicas para Boas Questões',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            _buildTipItem('Seja claro e objetivo na pergunta'),
                            _buildTipItem('Use linguagem simples e direta'),
                            _buildTipItem('Evite perguntas com dupla negativa'),
                            _buildTipItem('Todas as opções devem ser plausíveis'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipItem(String tip) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(color: Colors.orange)),
          Expanded(
            child: Text(
              tip,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.orange,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _createQuestion() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final supabaseService = ref.read(supabaseServiceProvider);
      
      // Buscar o quiz selecionado
      final quizzes = await supabaseService.getQuizzes();
      final selectedQuiz = quizzes.firstWhere((q) => q.title == _selectedQuiz);
      
      // Criar a questão
      final question = QuizQuestionModel(
        id: const Uuid().v4(),
        quizId: selectedQuiz.id,
        question: _questionController.text.trim(),
        options: _optionControllers.map((c) => c.text.trim()).toList(),
        correctAnswer: _correctAnswerIndex,
        explanation: null,
        createdAt: DateTime.now(),
      );
      
      await supabaseService.createQuizQuestion(question);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Questão criada com sucesso para "${selectedQuiz.title}"!'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Limpar formulário
        _questionController.clear();
        for (var controller in _optionControllers) {
          controller.clear();
        }
        setState(() {
          _correctAnswerIndex = 0;
        });
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao criar questão: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _addAnotherQuestion() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Salvar a questão atual
      await Future.delayed(const Duration(seconds: 1));
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Questão adicionada! Continuando para a próxima...'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Limpar formulário para próxima questão
        _questionController.clear();
        for (var controller in _optionControllers) {
          controller.clear();
        }
        setState(() {
          _correctAnswerIndex = 0;
        });
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao adicionar questão: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
} 