import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../shared/models/user_model.dart';
import '../pages/home_page.dart';

class CompleteProfilePage extends ConsumerStatefulWidget {
  final UserModel userModel;

  const CompleteProfilePage({
    super.key,
    required this.userModel,
  });

  @override
  ConsumerState<CompleteProfilePage> createState() => _CompleteProfilePageState();
}

class _CompleteProfilePageState extends ConsumerState<CompleteProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _whatsappController = TextEditingController();
  final _birthDateController = TextEditingController();
  String? _selectedState;
  DateTime? _selectedDate;
  bool _isLoading = false;

  @override
  void dispose() {
    _whatsappController.dispose();
    _birthDateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 6570)), // 18 anos atrás
      firstDate: DateTime.now().subtract(const Duration(days: 25550)), // 70 anos atrás
      lastDate: DateTime.now().subtract(const Duration(days: 3650)), // 10 anos atrás
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _birthDateController.text = '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
      });
    }
  }

  Future<void> _completeProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final updatedUser = widget.userModel.copyWith(
        whatsapp: _whatsappController.text.trim(),
        birthDate: _selectedDate,
        state: _selectedState,
        hasCompletedProfile: true,
        updatedAt: DateTime.now(),
      );

      await SupabaseService().updateUser(updatedUser);

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao completar perfil: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Completar Perfil',
          style: TextStyle(color: AppColors.white),
        ),
      ),
      body: SafeArea(
        child: Container(
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),
                  
                  // Título
                  const Text(
                    'Complete seu perfil',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Forneça algumas informações adicionais para personalizar sua experiência',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Campo de WhatsApp
                  TextFormField(
                    controller: _whatsappController,
                    keyboardType: TextInputType.phone,
                    style: const TextStyle(color: AppColors.white),
                    decoration: const InputDecoration(
                      labelText: 'WhatsApp (opcional)',
                      labelStyle: TextStyle(color: AppColors.white),
                      prefixIcon: Icon(Icons.phone, color: AppColors.white),
                      hintText: '(11) 99999-9999',
                      hintStyle: TextStyle(color: AppColors.mediumGray),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Campo de data de nascimento
                  TextFormField(
                    controller: _birthDateController,
                    readOnly: true,
                    style: const TextStyle(color: AppColors.white),
                    decoration: InputDecoration(
                      labelText: 'Data de nascimento *',
                      labelStyle: const TextStyle(color: AppColors.white),
                      prefixIcon: const Icon(Icons.calendar_today, color: AppColors.white),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.date_range, color: AppColors.white),
                        onPressed: () => _selectDate(context),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, selecione sua data de nascimento';
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Campo de estado
                  DropdownButtonFormField<String>(
                    value: _selectedState,
                    style: const TextStyle(color: AppColors.white),
                    dropdownColor: AppColors.secondary,
                    decoration: const InputDecoration(
                      labelText: 'Estado *',
                      labelStyle: TextStyle(color: AppColors.white),
                      prefixIcon: Icon(Icons.location_on, color: AppColors.white),
                    ),
                    items: AppConstants.brazilianStates.map((String state) {
                      return DropdownMenuItem<String>(
                        value: state,
                        child: Text(
                          state,
                          style: const TextStyle(color: AppColors.white),
                        ),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedState = newValue;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, selecione seu estado';
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Informações sobre idade
                  if (_selectedDate != null) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.secondary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'Informações baseadas na sua idade:',
                            style: TextStyle(
                              color: AppColors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildAgeInfo(),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                  
                  // Botão de completar perfil
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _completeProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.gold,
                        foregroundColor: AppColors.primary,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                              ),
                            )
                          : const Text(
                              'Completar Perfil',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Link para pular
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => const HomePage()),
                      );
                    },
                    child: const Text(
                      'Pular por enquanto',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAgeInfo() {
    if (_selectedDate == null) return const SizedBox.shrink();

    final age = DateTime.now().year - _selectedDate!.year;
    final isTeen = age >= AppConstants.minAgeTeen && age <= AppConstants.maxAgeTeen;
    final isCampusEligible = age >= AppConstants.minAgeCampus && age <= AppConstants.maxAgeCampus;

    return Column(
      children: [
        Text(
          'Idade: $age anos',
          style: const TextStyle(color: AppColors.white),
        ),
        if (isTeen) ...[
          const SizedBox(height: 4),
          const Text(
            '✅ Pode solicitar parcerias para desafios',
            style: TextStyle(color: AppColors.success, fontSize: 12),
          ),
        ],
        if (isCampusEligible) ...[
          const SizedBox(height: 4),
          const Text(
            '✅ Pode solicitar acesso ao Campus',
            style: TextStyle(color: AppColors.success, fontSize: 12),
          ),
        ],
        if (!isTeen && !isCampusEligible) ...[
          const SizedBox(height: 4),
          const Text(
            'ℹ️ Acesso básico ao aplicativo',
            style: TextStyle(color: AppColors.info, fontSize: 12),
          ),
        ],
      ],
    );
  }
} 