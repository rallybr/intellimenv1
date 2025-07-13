import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/supabase_service.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        title: const Text(
          'Perfil',
          style: TextStyle(color: AppColors.white),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: AppColors.white),
            onPressed: () {
              // Implementar configurações
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Header do perfil
              _buildProfileHeader(),
              
              const SizedBox(height: 24),
              
              // Estatísticas
              _buildStats(),
              
              const SizedBox(height: 24),
              
              // Menu de opções
              _buildMenuOptions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Avatar
          CircleAvatar(
            radius: 50,
            backgroundColor: AppColors.gold,
            child: const Icon(
              Icons.person,
              size: 50,
              color: AppColors.primary,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Nome do usuário
          const Text(
            'Nome do Usuário',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.white,
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Email
          const Text(
            'usuario@email.com',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.mediumGray,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Botão editar perfil
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                // Implementar editar perfil
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.gold,
                side: const BorderSide(color: AppColors.gold),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('Editar Perfil'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStats() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Desafios', '0'),
          _buildStatItem('Concluídos', '0'),
          _buildStatItem('Parceiros', '0'),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.gold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuOptions() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildMenuItem(
            icon: Icons.fitness_center,
            title: 'Meus Desafios',
            subtitle: 'Ver todos os desafios',
            onTap: () {
              // Implementar meus desafios
            },
          ),
          _buildMenuItem(
            icon: Icons.quiz,
            title: 'Meus Quizzes',
            subtitle: 'Histórico de quizzes',
            onTap: () {
              // Implementar meus quizzes
            },
          ),
          _buildMenuItem(
            icon: Icons.people,
            title: 'Parceiros',
            subtitle: 'Gerenciar parcerias',
            onTap: () {
              // Implementar parceiros
            },
          ),
          _buildMenuItem(
            icon: Icons.notifications,
            title: 'Notificações',
            subtitle: 'Configurar notificações',
            onTap: () {
              // Implementar notificações
            },
          ),
          _buildMenuItem(
            icon: Icons.help,
            title: 'Ajuda',
            subtitle: 'Suporte e FAQ',
            onTap: () {
              // Implementar ajuda
            },
          ),
          _buildMenuItem(
            icon: Icons.logout,
            title: 'Sair',
            subtitle: 'Fazer logout da conta',
            onTap: () {
              _showLogoutDialog();
            },
            isDestructive: true,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? AppColors.error : AppColors.gold,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? AppColors.error : AppColors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          color: AppColors.mediumGray,
          fontSize: 12,
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        color: AppColors.mediumGray,
        size: 16,
      ),
      onTap: onTap,
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.secondary,
        title: const Text(
          'Sair da conta',
          style: TextStyle(color: AppColors.white),
        ),
        content: const Text(
          'Tem certeza que deseja sair da sua conta?',
          style: TextStyle(color: AppColors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: AppColors.mediumGray),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              await SupabaseService().signOut();
              if (mounted) {
                Navigator.of(context).pop();
                // Navegar para tela de login
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.white,
            ),
            child: const Text('Sair'),
          ),
        ],
      ),
    );
  }
} 