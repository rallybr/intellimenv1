import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/supabase_service.dart';
import '../../../shared/models/quiz_model.dart';
import 'package:intellimen/shared/models/user_quiz_model.dart';
import 'package:intellimen/shared/models/quiz_question_model.dart';

import '../../../core/constants/welcome_constants.dart';
import '../../../shared/providers/auth_provider.dart';

class QuizPlayPage extends ConsumerStatefulWidget {
  final String quizId;
  const QuizPlayPage({Key? key, required this.quizId}) : super(key: key);

  @override
  ConsumerState<QuizPlayPage> createState() => _QuizPlayPageState();
}

class _QuizPlayPageState extends ConsumerState<QuizPlayPage> {
  List<QuizQuestionModel> _questions = [];
  int _current = 0;
  int _score = 0;
  int? _selected;
  bool _showResult = false;
  bool _answered = false;
  bool _timeout = false;
  Timer? _timer;
  double _progress = 1.0;
  static const int _maxSeconds = 15;
  int _secondsLeft = _maxSeconds;
  String? _userQuizId;
  List<Map<String, dynamic>> _answers = []; // Lista para armazenar as respostas

  @override
  void initState() {
    super.initState();
    _loadQuestionsAndRegister();
  }

  Future<void> _loadQuestionsAndRegister() async {
    final questions = await SupabaseService().getQuizQuestions(widget.quizId);
    await _registerUserQuiz();
    setState(() {
      _questions = questions;
      _current = 0;
      _score = 0;
      _selected = null;
      _showResult = false;
      _answered = false;
      _timeout = false;
      _answers = []; // Inicializar lista de respostas
    });
    _startTimer();
  }

  Future<void> _registerUserQuiz() async {
    final user = ref.read(currentUserDataProvider).value;
    if (user == null) return;
    final supabase = SupabaseService();
    
    try {
      final existing = await supabase.client
          .from('user_quizzes')
          .select()
          .eq('user_id', user.id)
          .eq('quiz_id', widget.quizId)
          .maybeSingle();
      
      if (existing == null) {
        // Verificar se é um confronto (quiz com partner_id)
        final quiz = await supabase.client
            .from('quizzes')
            .select()
            .eq('id', widget.quizId)
            .single();
        
        // Se for um quiz de parceria, buscar o partner_id do usuário
        String? partnerId;
        if (quiz['type'] == 'partner') {
          final userData = await supabase.client
              .from('users')
              .select()
              .eq('id', user.id)
              .single();
          partnerId = userData['partner_id'];
        }
        
        // Inserir diretamente usando o cliente autenticado
        final insertData = {
          'user_id': user.id,
          'quiz_id': widget.quizId,
          'partner_id': partnerId,
          'score': 0,
          'total_questions': 0,
          'started_at': DateTime.now().toIso8601String(),
          'completed_at': null,
          'status': 'in_progress',
          'created_at': DateTime.now().toIso8601String(),
          'answers': [],
        };
        
        final result = await supabase.client
            .from('user_quizzes')
            .insert(insertData)
            .select()
            .single();
        
        setState(() {
          _userQuizId = result['id'] as String?;
        });
        
      } else {
        setState(() {
          _userQuizId = existing['id'] as String?;
        });
      }
    } catch (e) {
      // Erro silencioso
    }
  }

  Future<void> _finishUserQuiz() async {
    final user = ref.read(currentUserDataProvider).value;
    if (user == null || _userQuizId == null) return;
    final supabase = SupabaseService();
    // Garante que _userQuizId não é nulo
    if (_userQuizId == null) return;
    
    try {
      await supabase.client
          .from('user_quizzes')
          .update({
            'total_questions': _questions.length,
            'completed_at': DateTime.now().toIso8601String(),
            'status': 'completed',
            // Não sobrescrever o score que já foi atualizado em tempo real
            // 'score': _score,
            // 'answers': _answers, // Já foi atualizado em tempo real
          })
          .eq('id', _userQuizId!);
      
      // Verificar se foi salvo corretamente
      final saved = await supabase.client
          .from('user_quizzes')
          .select()
          .eq('id', _userQuizId!)
          .single();
      
    } catch (e) {
      // Erro silencioso
    }
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() {
      _progress = 1.0;
      _secondsLeft = _maxSeconds;
      _timeout = false;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft > 0) {
        setState(() {
          _secondsLeft--;
          _progress = _secondsLeft / _maxSeconds;
        });
      } else {
        _timer?.cancel();
        
        // Salvar resposta de timeout
        final question = _questions[_current];
        _answers.add({
          'question_id': question.id,
          'selected': -1, // -1 indica timeout
          'correct': false,
          'time': _maxSeconds,
        });
        

        
        setState(() {
          _timeout = true;
          _answered = true;
        });
      }
    });
  }

  void _answer(int idx) async {
    if (_answered) return;
    _timer?.cancel();
    
    final question = _questions[_current];
    final isCorrect = idx == question.correctAnswer;
    final responseTime = _maxSeconds - _secondsLeft;
    
    // Salvar a resposta
    _answers.add({
      'question_id': question.id,
      'selected': idx,
      'correct': isCorrect,
      'time': responseTime,
    });
    

    
    setState(() {
      _selected = idx;
      _answered = true;
      if (isCorrect) {
        _score++;
      }
    });
    
    // Atualizar score no banco de dados em tempo real
    if (_userQuizId != null) {
      try {
        final supabase = SupabaseService();
        await supabase.client
            .from('user_quizzes')
            .update({
              'score': _score,
              'answers': _answers,
            })
            .eq('id', _userQuizId!);
        
      } catch (e) {
        // Erro silencioso
      }
    }
  }

  void _next() async {
    if (_current < _questions.length - 1) {
      setState(() {
        _current++;
        _selected = null;
        _answered = false;
        _timeout = false;
      });
      _startTimer();
    } else {
      setState(() {
        _showResult = true;
      });
      _timer?.cancel();
      await _finishUserQuiz();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset(
            WelcomeConstants.backgroundImage,
            fit: BoxFit.cover,
          ),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.black.withOpacity(0.85),
            title: const Text('Quiz', style: TextStyle(color: Colors.white)),
            iconTheme: const IconThemeData(color: Colors.white),
            elevation: 0,
          ),
          body: Center(
            child: _showResult
                ? _buildResult()
                : _questions.isEmpty
                    ? const CircularProgressIndicator()
                    : _buildQuestion(),
          ),
        ),
      ],
    );
  }

  Widget _buildQuestion() {
    final q = _questions[_current];
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 520),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.65),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.18), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.18),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Pergunta ${_current + 1} de ${_questions.length}',
                style: const TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: _progress,
                minHeight: 10,
                backgroundColor: Colors.white24,
                color: _timeout ? Colors.red : Colors.pinkAccent,
              ),
              const SizedBox(height: 12),
              Text(
                q.question,
                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ...List.generate(q.options.length, (i) {
                Color bg;
                if (!_answered) {
                  bg = Colors.white10;
                } else if (_timeout) {
                  bg = Colors.grey[800]!;
                } else if (i == q.correctAnswer) {
                  bg = Colors.green;
                } else if (_selected == i) {
                  bg = Colors.red;
                } else {
                  bg = Colors.white10;
                }
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: bg,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 18),
                    ),
                    onPressed: !_answered ? () => _answer(i) : null,
                    child: Text(q.options[i], style: const TextStyle(fontSize: 16)),
                  ),
                );
              }),
              const SizedBox(height: 18),
              if (_answered && !_timeout)
                Text(
                  _selected == q.correctAnswer ? 'Correto!' : 'Errado!',
                  style: TextStyle(
                    color: _selected == q.correctAnswer ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                  textAlign: TextAlign.center,
                ),
              if (_answered && q.explanation != null && q.explanation!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    q.explanation!,
                    style: const TextStyle(color: Colors.white70, fontStyle: FontStyle.italic),
                    textAlign: TextAlign.center,
                  ),
                ),
              if (_answered)
                Padding(
                  padding: const EdgeInsets.only(top: 18),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pinkAccent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: _next,
                      child: Text(_current < _questions.length - 1 ? 'Próxima' : 'Finalizar', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                ),
              if (_timeout)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    'Tempo esgotado! Questão cancelada.',
                    style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResult() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.65),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.18), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.18),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text('Quiz Finalizado!', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 18),
            Text('Você acertou $_score de ${_questions.length} questões.', style: const TextStyle(color: Colors.white, fontSize: 18)),
            const SizedBox(height: 18),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pinkAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Voltar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
} 