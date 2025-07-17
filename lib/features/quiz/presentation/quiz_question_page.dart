import 'package:flutter/material.dart';
import '../../../core/services/supabase_service.dart';
import '../../../shared/models/quiz_model.dart';
import 'package:intellimen/shared/models/quiz_question_model.dart';
import '../../welcome/presentation/pages/welcome_home_page.dart';
import '../../../core/constants/welcome_constants.dart';

class QuizQuestionPage extends StatefulWidget {
  const QuizQuestionPage({Key? key}) : super(key: key);

  @override
  State<QuizQuestionPage> createState() => _QuizQuestionPageState();
}

class _QuizQuestionPageState extends State<QuizQuestionPage> {
  String? _selectedQuizId;
  List<QuizModel> _quizzes = [];
  List<QuizQuestionModel> _questions = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchQuizzes();
  }

  Future<void> _fetchQuizzes() async {
    setState(() => _isLoading = true);
    final quizzes = await SupabaseService().getQuizzes();
    setState(() {
      _quizzes = quizzes;
      _isLoading = false;
    });
  }

  Future<void> _fetchQuestions(String quizId) async {
    setState(() => _isLoading = true);
    final questions = await SupabaseService().getQuizQuestions(quizId);
    setState(() {
      _questions = questions;
      _isLoading = false;
    });
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
            title: const Text('Gerenciar Questões', style: TextStyle(color: Colors.white)),
            iconTheme: const IconThemeData(color: Colors.white),
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _fetchQuizzes,
              ),
            ],
          ),
          body: Center(
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
                  children: [
                    DropdownButtonFormField<String>(
                      value: _selectedQuizId,
                      dropdownColor: Colors.black87,
                      style: const TextStyle(color: Colors.white),
                      items: _quizzes
                          .map((q) => DropdownMenuItem(
                                value: q.id,
                                child: Text(q.title, style: TextStyle(color: Colors.white)),
                              ))
                          .toList(),
                      onChanged: (v) {
                        setState(() => _selectedQuizId = v);
                        if (v != null) _fetchQuestions(v);
                      },
                      decoration: _inputDecoration('Selecione o Quiz'),
                    ),
                    const SizedBox(height: 18),
                    Expanded(
                      child: _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : _questions.isEmpty
                              ? const Center(child: Text('Nenhuma questão encontrada.', style: TextStyle(color: Colors.white70)))
                              : ListView.builder(
                                  itemCount: _questions.length,
                                  itemBuilder: (context, index) {
                                    final q = _questions[index];
                                    return Card(
                                      color: Colors.white10,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                      child: ListTile(
                                        title: Text(q.question, style: const TextStyle(color: Colors.white)),
                                        subtitle: Text('Opções: ${q.options.join(", ")}', style: const TextStyle(color: Colors.white70)),
                                        trailing: Text('Correta: ${q.correctAnswer + 1}', style: const TextStyle(color: Colors.pinkAccent, fontWeight: FontWeight.bold)),
                                      ),
                                    );
                                  },
                                ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          floatingActionButton: _selectedQuizId == null
              ? null
              : FloatingActionButton(
                  backgroundColor: Colors.pinkAccent,
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Funcionalidade de adicionar questão em breve.')),
                    );
                  },
                  child: const Icon(Icons.add),
                  tooltip: 'Adicionar Questão',
                ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      filled: true,
      fillColor: Colors.white10,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.white24),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.pinkAccent, width: 2),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
} 