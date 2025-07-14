import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/config/supabase_config.dart';
import 'core/services/supabase_service.dart';
import 'core/constants/app_colors.dart';
import 'core/constants/app_constants.dart';
import 'features/auth/presentation/pages/splash_page.dart';
import 'features/welcome/presentation/pages/welcome_home_page.dart';
import 'shared/providers/auth_provider.dart';
import 'features/profile/presentation/pages/complete_profile_page.dart';
import 'features/dashboard/presentation/pages/dashboard_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar Supabase
  await SupabaseService().initialize();
  
  runApp(const ProviderScope(child: IntelliMenApp()));
}

class IntelliMenApp extends ConsumerWidget {
  const IntelliMenApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.blue,
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.blue,
            foregroundColor: AppColors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.mediumGray),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.blue, width: 2),
          ),
          filled: true,
          fillColor: AppColors.lightGray,
        ),
      ),
      home: authState.when(
        data: (user) {
          if (user == null) {
            // Usuário não autenticado - mostrar tela de welcome
            return const WelcomeHomePage();
          } else if (!user.hasCompletedProfile) {
            // Usuário autenticado mas perfil incompleto
            return CompleteProfilePage(userModel: user);
          } else {
            // Usuário autenticado e perfil completo - mostrar dashboard
            return const DashboardPage();
          }
        },
        loading: () => const SplashPage(),
        error: (error, stackTrace) => const WelcomeHomePage(),
      ),
    );
  }
}
