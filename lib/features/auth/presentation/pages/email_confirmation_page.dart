import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../shared/models/user_model.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/supabase_service.dart';
import 'complete_profile_page.dart';

class EmailConfirmationPage extends ConsumerStatefulWidget {
  final String email;
  final String password;
  final String name;
  const EmailConfirmationPage({required this.email, required this.password, required this.name, super.key});

  @override
  ConsumerState<EmailConfirmationPage> createState() => _EmailConfirmationPageState();
}

class _EmailConfirmationPageState extends ConsumerState<EmailConfirmationPage> {
  bool _checking = false;

  Future<void> _openEmailApp() async {
    final Uri emailLaunchUri = Uri(scheme: 'mailto');
    if (await canLaunchUrl(emailLaunchUri)) {
      await launchUrl(emailLaunchUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível abrir o app de e-mail.')),
      );
    }
  }

  Future<void> _checkEmailConfirmed() async {
    setState(() => _checking = true);
    try {
      // Tenta fazer login
      final signInResponse = await SupabaseService().signIn(
        email: widget.email,
        password: widget.password,
      );
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null && user.emailConfirmedAt != null) {
        // Cria o registro na tabela users
        final userModel = UserModel(
          id: user.id,
          name: widget.name,
          email: widget.email,
          accessLevel: AppConstants.accessGeneral,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isActive: true,
          hasCompletedProfile: false,
        );
        await SupabaseService().createUser(userModel);
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => CompleteProfilePage(userModel: userModel),
            ),
          );
        }
      } else {
        setState(() => _checking = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('E-mail ainda não confirmado!')),
        );
      }
    } catch (e) {
      setState(() => _checking = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao confirmar e-mail: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.email, size: 80, color: Colors.amber),
              const SizedBox(height: 24),
              const Text(
                'Confirme seu e-mail para continuar',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _openEmailApp,
                child: const Text('CONFIRME O E-MAIL'),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _checking ? null : _checkEmailConfirmed,
                child: _checking
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('JÁ CONFIRMEI'),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 