import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/providers/auth_provider.dart';
import '../../../../shared/models/user_model.dart';
import '../../../welcome/presentation/pages/welcome_home_page.dart';
import '../../../quiz/presentation/pages/quiz_list_page.dart';
import '../../../quiz/presentation/pages/quiz_create_page.dart';
import '../../../quiz/presentation/pages/quiz_category_page.dart';
import '../../../quiz/presentation/pages/quiz_question_create_page.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserDataProvider);
    
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(authNotifierProvider.notifier).signOut();
            },
          ),
        ],
      ),
      drawer: userAsync.when(
        data: (user) => user != null ? _buildDrawer(context, ref, user) : const Drawer(),
        loading: () => const Drawer(),
        error: (error, stackTrace) => const Drawer(),
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
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header com informações do usuário
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundImage: user.photoUrl != null 
                            ? NetworkImage(user.photoUrl!)
                            : null,
                        child: user.photoUrl == null 
                            ? const Icon(Icons.person, size: 40, color: Colors.white)
                            : null,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Bem-vindo, ${user.name}!',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Nível de acesso: ${user.accessLevel.toUpperCase()}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (user.age != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Idade: ${user.age} anos',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Seção de funcionalidades
                const Text(
                  'Funcionalidades',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Grid de funcionalidades
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.2,
                  children: [
                    _buildFeatureCard(
                      context,
                      'Desafios',
                      Icons.fitness_center,
                      Colors.orange,
                      () {
                        // TODO: Navegar para tela de desafios
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Funcionalidade em desenvolvimento')),
                        );
                      },
                    ),
                    _buildFeatureCard(
                      context,
                      'Quizzes',
                      Icons.quiz,
                      Colors.blue,
                      () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const QuizListPage(),
                          ),
                        );
                      },
                    ),
                    _buildFeatureCard(
                      context,
                      'Feed',
                      Icons.feed,
                      Colors.green,
                      () {
                        // TODO: Navegar para tela de feed
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Funcionalidade em desenvolvimento')),
                        );
                      },
                    ),
                    _buildFeatureCard(
                      context,
                      'Perfil',
                      Icons.person,
                      Colors.purple,
                      () {
                        // TODO: Navegar para tela de perfil
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Funcionalidade em desenvolvimento')),
                        );
                      },
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Botão para voltar ao welcome
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => const WelcomeHomePage(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'Voltar ao Welcome',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error,
                color: Colors.white,
                size: 64,
              ),
              const SizedBox(height: 16),
              const Text(
                'Erro ao carregar dados',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildFeatureCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      color: color,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 48,
                color: Colors.white,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, WidgetRef ref, UserModel user) {
    return Drawer(
      child: Container(
        color: AppColors.primary,
        child: Column(
          children: [
            // Header do Drawer
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 50, bottom: 20, left: 20, right: 20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: user.photoUrl != null 
                        ? NetworkImage(user.photoUrl!)
                        : null,
                    child: user.photoUrl == null 
                        ? const Icon(Icons.person, size: 40, color: Colors.white)
                        : null,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.email,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
            // Menu items
            Expanded(
              child: Container(
                color: Colors.white,
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    // Seção Quiz
                    _buildSectionHeader('Quiz'),
                    
                    // Criar Quiz
                    _buildDrawerItem(
                      icon: Icons.quiz,
                      title: 'Criar Quiz',
                      onTap: () {
                        Navigator.pop(context); // Fechar drawer
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const QuizCreatePage(),
                          ),
                        );
                      },
                    ),
                    
                    // Criar Categorias
                    _buildDrawerItem(
                      icon: Icons.category,
                      title: 'Criar Categorias',
                      onTap: () {
                        Navigator.pop(context); // Fechar drawer
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const QuizCategoryPage(),
                          ),
                        );
                      },
                    ),
                    
                    // Criar Questões
                    _buildDrawerItem(
                      icon: Icons.question_answer,
                      title: 'Criar Questões',
                      onTap: () {
                        Navigator.pop(context); // Fechar drawer
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const QuizQuestionCreatePage(),
                          ),
                        );
                      },
                    ),
                    
                    const Divider(),
                    
                    // Seção Geral
                    _buildSectionHeader('Geral'),
                    
                    // Listar Quizzes
                    _buildDrawerItem(
                      icon: Icons.list,
                      title: 'Listar Quizzes',
                      onTap: () {
                        Navigator.pop(context); // Fechar drawer
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const QuizListPage(),
                          ),
                        );
                      },
                    ),
                    
                    // Perfil
                    _buildDrawerItem(
                      icon: Icons.person,
                      title: 'Perfil',
                      onTap: () {
                        Navigator.pop(context); // Fechar drawer
                        // TODO: Navegar para perfil
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Funcionalidade em desenvolvimento')),
                        );
                      },
                    ),
                    
                    // Configurações
                    _buildDrawerItem(
                      icon: Icons.settings,
                      title: 'Configurações',
                      onTap: () {
                        Navigator.pop(context); // Fechar drawer
                        // TODO: Navegar para configurações
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Funcionalidade em desenvolvimento')),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            
            // Footer do Drawer
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Divider(color: Colors.white24),
                  const SizedBox(height: 8),
                  Text(
                    'IntelliMen v1.0',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title,
        style: const TextStyle(
          color: AppColors.primary,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.black87,
          fontSize: 16,
        ),
      ),
      onTap: onTap,
      dense: true,
    );
  }
} 