import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/supabase_service.dart';
import '../../../shared/models/quiz_model.dart';
import '../../welcome/presentation/pages/welcome_home_page.dart';
import '../../../core/constants/welcome_constants.dart';

class QuizCreatePage extends ConsumerStatefulWidget {
  const QuizCreatePage({Key? key}) : super(key: key);

  @override
  ConsumerState<QuizCreatePage> createState() => _QuizCreatePageState();
}

class _QuizCreatePageState extends ConsumerState<QuizCreatePage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _selectedType;
  String? _selectedCategory;
  int? _selectedDifficulty;
  bool _isActive = true;
  bool _isLoading = false;
  List<String> _categories = [];

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    final supabase = SupabaseService();
    final quizzes = await supabase.getQuizzes();
    final cats = quizzes.map((q) => q.category).toSet().toList();
    setState(() {
      _categories = cats;
    });
  }

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final quiz = QuizModel(
        id: '',
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        type: _selectedType!,
        category: _selectedCategory ?? '',
        difficulty: _selectedDifficulty ?? 1,
        createdAt: DateTime.now(),
        isActive: _isActive,
      );
      await SupabaseService().createQuiz(quiz);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Quiz criado com sucesso!')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao criar quiz: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
            title: const Text('Criar Quiz', style: TextStyle(color: Colors.white)),
            iconTheme: const IconThemeData(color: Colors.white),
            elevation: 0,
          ),
          body: Center(
            child: SingleChildScrollView(
              child: Padding(
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
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          controller: _titleController,
                          style: const TextStyle(color: Colors.white),
                          decoration: _inputDecoration('Título'),
                          validator: (v) => v == null || v.isEmpty ? 'Informe o título' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _descriptionController,
                          style: const TextStyle(color: Colors.white),
                          decoration: _inputDecoration('Descrição'),
                          maxLines: 2,
                          validator: (v) => v == null || v.isEmpty ? 'Informe a descrição' : null,
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: _selectedType,
                          dropdownColor: Colors.black87,
                          style: const TextStyle(color: Colors.white),
                          items: const [
                            DropdownMenuItem(value: 'partner', child: Text('Quiz em Dupla', style: TextStyle(color: Colors.white))),
                            DropdownMenuItem(value: 'individual', child: Text('Quiz Individual', style: TextStyle(color: Colors.white))),
                          ],
                          onChanged: (v) => setState(() => _selectedType = v),
                          decoration: _inputDecoration('Tipo'),
                          validator: (v) => v == null ? 'Selecione o tipo' : null,
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: _selectedCategory,
                          dropdownColor: Colors.black87,
                          style: const TextStyle(color: Colors.white),
                          items: [
                            ..._categories.map((c) => DropdownMenuItem(value: c, child: Text(c, style: TextStyle(color: Colors.white)))),
                            const DropdownMenuItem(value: '', child: Text('Nova categoria...', style: TextStyle(color: Colors.white70))),
                          ],
                          onChanged: (v) async {
                            if (v == '') {
                              final newCat = await showDialog<String>(
                                context: context,
                                builder: (ctx) {
                                  final ctrl = TextEditingController();
                                  return AlertDialog(
                                    backgroundColor: Colors.black87,
                                    title: const Text('Nova Categoria', style: TextStyle(color: Colors.white)),
                                    content: TextField(
                                      controller: ctrl,
                                      style: const TextStyle(color: Colors.white),
                                      decoration: _inputDecoration('Nome da categoria'),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(ctx),
                                        child: const Text('Cancelar', style: TextStyle(color: Colors.white)),
                                      ),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(backgroundColor: Colors.pinkAccent),
                                        onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
                                        child: const Text('Adicionar'),
                                      ),
                                    ],
                                  );
                                },
                              );
                              if (newCat != null && newCat.isNotEmpty) {
                                setState(() {
                                  _categories.add(newCat);
                                  _selectedCategory = newCat;
                                });
                              }
                            } else {
                              setState(() => _selectedCategory = v);
                            }
                          },
                          decoration: _inputDecoration('Categoria'),
                          validator: (v) => v == null || v.isEmpty ? 'Selecione ou crie uma categoria' : null,
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<int>(
                          value: _selectedDifficulty,
                          dropdownColor: Colors.black87,
                          style: const TextStyle(color: Colors.white),
                          items: List.generate(5, (i) => DropdownMenuItem(value: i+1, child: Text('Dificuldade ${i+1}', style: TextStyle(color: Colors.white)))),
                          onChanged: (v) => setState(() => _selectedDifficulty = v),
                          decoration: _inputDecoration('Dificuldade'),
                          validator: (v) => v == null ? 'Selecione a dificuldade' : null,
                        ),
                        const SizedBox(height: 16),
                        SwitchListTile(
                          value: _isActive,
                          onChanged: (v) => setState(() => _isActive = v),
                          title: const Text('Ativo', style: TextStyle(color: Colors.white)),
                          activeColor: Colors.pinkAccent,
                          inactiveThumbColor: Colors.grey,
                          inactiveTrackColor: Colors.white24,
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
                                : const Text('Salvar Quiz', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
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