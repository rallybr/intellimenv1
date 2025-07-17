import 'package:flutter/material.dart';
import '../../../core/services/supabase_service.dart';
import '../../../shared/models/quiz_model.dart';
import '../../welcome/presentation/pages/welcome_home_page.dart';
import '../../../core/constants/welcome_constants.dart';

class QuizCategoryPage extends StatefulWidget {
  const QuizCategoryPage({Key? key}) : super(key: key);

  @override
  State<QuizCategoryPage> createState() => _QuizCategoryPageState();
}

class _QuizCategoryPageState extends State<QuizCategoryPage> {
  List<String> _categories = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    setState(() => _isLoading = true);
    final quizzes = await SupabaseService().getQuizzes();
    setState(() {
      _categories = quizzes.map((q) => q.category).toSet().toList();
      _isLoading = false;
    });
  }

  Future<void> _addCategory() async {
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
    if (newCat != null && newCat.isNotEmpty && !_categories.contains(newCat)) {
      setState(() {
        _categories.add(newCat);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Categoria "$newCat" adicionada localmente. Para persistir, crie um quiz com essa categoria.')),
      );
    }
  }

  Future<void> _editCategory(int index) async {
    final oldCat = _categories[index];
    final newCat = await showDialog<String>(
      context: context,
      builder: (ctx) {
        final ctrl = TextEditingController(text: oldCat);
        return AlertDialog(
          backgroundColor: Colors.black87,
          title: const Text('Editar Categoria', style: TextStyle(color: Colors.white)),
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
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );
    if (newCat != null && newCat.isNotEmpty && !_categories.contains(newCat)) {
      setState(() {
        _categories[index] = newCat;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Categoria editada localmente. Para persistir, edite os quizzes com essa categoria.')),
      );
    }
  }

  void _removeCategory(int index) {
    final cat = _categories[index];
    setState(() {
      _categories.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Categoria "$cat" removida localmente. Para persistir, remova/edite os quizzes com essa categoria.')),
    );
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
            title: const Text('Gerenciar Categorias', style: TextStyle(color: Colors.white)),
            iconTheme: const IconThemeData(color: Colors.white),
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _fetchCategories,
              ),
            ],
          ),
          body: Center(
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
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: _categories.length,
                        itemBuilder: (context, index) {
                          final cat = _categories[index];
                          return ListTile(
                            title: Text(cat, style: const TextStyle(color: Colors.white)),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.white70),
                                  onPressed: () => _editCategory(index),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.pinkAccent),
                                  onPressed: () => _removeCategory(index),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: Colors.pinkAccent,
            onPressed: _addCategory,
            child: const Icon(Icons.add),
            tooltip: 'Adicionar Categoria',
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