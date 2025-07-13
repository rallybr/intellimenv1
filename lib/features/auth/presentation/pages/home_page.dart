import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../feed/presentation/pages/feed_page.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../../../dashboard/presentation/pages/dashboard_page.dart';
import '../../../../shared/models/user_model.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int _currentIndex = 0;
  UserModel? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    final user = await SupabaseService().getCurrentUser();
    if (mounted) {
      setState(() {
        _currentUser = user;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF333333),
              Color(0xFF434343),
              Color(0xFF333333),
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
        child: IndexedStack(
          index: _currentIndex,
          children: [
            _buildAcademyTab(),
            _buildIntelliMenTab(),
            _buildCampusTab(),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.secondary,
          border: Border(
            top: BorderSide(color: AppColors.darkGray, width: 1),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          backgroundColor: AppColors.secondary,
          selectedItemColor: AppColors.gold,
          unselectedItemColor: AppColors.white,
          type: BottomNavigationBarType.fixed,
          items: [
            _buildNavItem('Academy', Icons.school, 0),
            _buildNavItem('IntelliMen', Icons.fitness_center, 1),
            _buildNavItem('Campus', Icons.business, 2),
          ],
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(String label, IconData icon, int index) {
    final hasAccess = _hasAccessToTab(index);
    
    return BottomNavigationBarItem(
      icon: Stack(
        children: [
          Icon(icon),
          if (!hasAccess)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.gold,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
      label: label,
    );
  }

  bool _hasAccessToTab(int tabIndex) {
    if (_currentUser == null) return false;
    
    switch (tabIndex) {
      case 0: // Academy
        return _currentUser!.accessLevel == AppConstants.accessAcademy;
      case 1: // IntelliMen
        return _currentUser!.accessLevel != AppConstants.accessGeneral;
      case 2: // Campus
        return _currentUser!.accessLevel == AppConstants.accessCampus;
      default:
        return false;
    }
  }

  Widget _buildAcademyTab() {
    if (!_hasAccessToTab(0)) {
      return _buildAccessDeniedTab(
        'Academy',
        'Conteúdo exclusivo para membros selecionados',
        'Solicitar Acesso',
        () => _requestAccess(AppConstants.accessAcademy),
      );
    }
    
    return const FeedPage(); // Placeholder - será implementado
  }

  Widget _buildIntelliMenTab() {
    if (!_hasAccessToTab(1)) {
      return _buildAccessDeniedTab(
        'IntelliMen',
        'Complete seu cadastro para acessar os desafios',
        'Completar Cadastro',
        () => _completeProfile(),
      );
    }
    
    return const DashboardPage(); // Página principal com desafios
  }

  Widget _buildCampusTab() {
    if (!_hasAccessToTab(2)) {
      return _buildAccessDeniedTab(
        'Campus',
        'Exclusivo para jovens entre 17 e 25 anos',
        'Solicitar Acesso',
        () => _requestAccess(AppConstants.accessCampus),
      );
    }
    
    return const ProfilePage(); // Placeholder - será implementado
  }

  Widget _buildAccessDeniedTab(String title, String description, String buttonText, VoidCallback onPressed) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Ícone
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.gold.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(60),
                ),
                child: Icon(
                  _getIconForTab(title),
                  size: 60,
                  color: AppColors.gold,
                ),
              ),
              const SizedBox(height: 32),
              
              // Título
              Text(
                title,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              
              // Descrição
              Text(
                description,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.white,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              
              // Botão de ação
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.gold,
                    foregroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    buttonText,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIconForTab(String title) {
    switch (title) {
      case 'Academy':
        return Icons.school;
      case 'IntelliMen':
        return Icons.fitness_center;
      case 'Campus':
        return Icons.business;
      default:
        return Icons.lock;
    }
  }

  void _requestAccess(String accessType) {
    // Implementar solicitação de acesso
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Solicitação de acesso enviada para $accessType'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _completeProfile() {
    // Navegar para completar perfil
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Navegando para completar perfil...'),
        backgroundColor: AppColors.info,
      ),
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
                Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
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