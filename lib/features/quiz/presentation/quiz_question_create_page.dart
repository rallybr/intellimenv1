import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../shared/providers/auth_provider.dart';
import '../../../../shared/models/quiz_category_model.dart';
import '../../../../shared/models/quiz_model.dart';
import '../../../../shared/models/quiz_question_model.dart';

class QuizQuestionCreatePage extends ConsumerStatefulWidget {
  const QuizQuestionCreatePage({Key? key}) : super(key: key);

  @override
  ConsumerState<QuizQuestionCreatePage> createState() => _QuizQuestionCreatePageState();
}

class _QuizQuestionCreatePageState extends ConsumerState<QuizQuestionCreatePage> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedQuizId;
  List<QuizModel> _quizzes = [];
  final _questionController = TextEditingController();
  final List<TextEditingController> _optionControllers = [TextEditingController(), TextEditingController()];
  int? _correctIndex;
  final _explanationController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchQuizzes();
  }

  Future<void> _fetchQuizzes() async {
    final quizzes = await SupabaseService().getQuizzes();
    setState(() {
      _quizzes = quizzes;
    });
  }

  void _addOptionField() {
    setState(() {
      _optionControllers.add(TextEditingController());
    });
  }

  void _removeOptionField(int index) {
    if (_optionControllers.length > 2) {
      setState(() {
        _optionControllers.removeAt(index);
        if (_correctIndex != null && _correctIndex! >= _optionControllers.length) {
          _correctIndex = null;
        }
      });
    }
  }

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) return;
    if (_correctIndex == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Selecione a opção correta.')));
      return;
    }
    setState(() => _isLoading = true);
    try {
      final options = _optionControllers.map((c) => c.text.trim()).toList();
      final question = QuizQuestionModel(
        id: '',
        quizId: _selectedQuizId!,
        question: _questionController.text.trim(),
        options: options,
        correctAnswer: _correctIndex!,
        explanation: _explanationController.text.trim().isEmpty ? null : _explanationController.text.trim(),
        createdAt: DateTime.now(),
      );
      await SupabaseService().createQuizQuestion(question);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Questão criada com sucesso!')));
      _questionController.clear();
      _optionControllers.forEach((c) => c.clear());
      _correctIndex = null;
      _explanationController.clear();
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao criar questão: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserDataProvider).value;
    if (user == null || !(user.accessLevel == 'adm' || user.accessLevel == 'editor')) {
      return Scaffold(
        appBar: AppBar(title: const Text('Criar Questão')),
        body: const Center(child: Text('Acesso restrito!')),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Criar Questão'),
        backgroundColor: Colors.black.withOpacity(0.85),
      ),
      body: Center(
        child: SingleChildScrollView(
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
              child: Form(
                key: _formKey,
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
                      onChanged: (v) => setState(() => _selectedQuizId = v),
                      decoration: _inputDecoration('Selecione o Quiz'),
                      validator: (v) => v == null ? 'Selecione o quiz' : null,
                    ),
                    const SizedBox(height: 18),
                    TextFormField(
                      controller: _questionController,
                      style: const TextStyle(color: Colors.white),
                      decoration: _inputDecoration('Pergunta'),
                      validator: (v) => v == null || v.isEmpty ? 'Digite a pergunta' : null,
                    ),
                    const SizedBox(height: 18),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _optionControllers.length,
                      itemBuilder: (context, index) {
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          color: Colors.white10,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Radio<int>(
                                      value: index,
                                      groupValue: _correctIndex,
                                      onChanged: (v) => setState(() => _correctIndex = v),
                                      activeColor: Colors.pinkAccent,
                                      fillColor: MaterialStateProperty.all(Colors.white),
                                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      visualDensity: VisualDensity.compact,
                                    ),
                                    Expanded(
                                      child: TextFormField(
                                        controller: _optionControllers[index],
                                        style: const TextStyle(color: Colors.white),
                                        decoration: _inputDecoration('Opção ${index + 1}'),
                                        validator: (v) => v == null || v.isEmpty ? 'Digite a opção' : null,
                                        maxLines: 1,
                                        textAlignVertical: TextAlignVertical.center,
                                      ),
                                    ),
                                  ],
                                ),
                                if (_optionControllers.length > 2)
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: IconButton(
                                      icon: const Icon(Icons.remove_circle, color: Colors.red, size: 20),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      onPressed: () => _removeOptionField(index),
                                      tooltip: 'Remover opção',
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _optionControllers.length < 5 ? _addOptionField : null,
                          icon: const Icon(Icons.add),
                          label: const Text('Adicionar Opção'),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.pinkAccent),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Mínimo 2, máximo 5 opções',
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    TextFormField(
                      controller: _explanationController,
                      style: const TextStyle(color: Colors.white),
                      decoration: _inputDecoration('Explicação (opcional)'),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.pinkAccent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        onPressed: _isLoading ? null : _onSave,
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text('Salvar Questão', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
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