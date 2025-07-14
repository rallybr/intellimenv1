import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
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
  File? _userPhoto;

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

  Future<void> _pickUserPhoto() async {
    final picker = ImagePicker();
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Tirar foto'),
                onTap: () async {
                  Navigator.of(context).pop();
                  final pickedFile = await picker.pickImage(source: ImageSource.camera);
                  if (pickedFile != null) {
                    final croppedFile = await ImageCropper().cropImage(
                      sourcePath: pickedFile.path,
                      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
                      uiSettings: [
                        AndroidUiSettings(
                          toolbarTitle: 'Cortar imagem',
                          toolbarColor: Colors.black,
                          toolbarWidgetColor: Colors.white,
                          lockAspectRatio: false,
                        ),
                        IOSUiSettings(
                          title: 'Cortar imagem',
                        ),
                      ],
                    );
                    if (croppedFile != null) {
                      setState(() {
                        _userPhoto = File(croppedFile.path);
                      });
                    }
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Escolher da galeria'),
                onTap: () async {
                  Navigator.of(context).pop();
                  final pickedFile = await picker.pickImage(source: ImageSource.gallery);
                  if (pickedFile != null) {
                    final croppedFile = await ImageCropper().cropImage(
                      sourcePath: pickedFile.path,
                      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
                      uiSettings: [
                        AndroidUiSettings(
                          toolbarTitle: 'Cortar imagem',
                          toolbarColor: Colors.black,
                          toolbarWidgetColor: Colors.white,
                          lockAspectRatio: false,
                        ),
                        IOSUiSettings(
                          title: 'Cortar imagem',
                        ),
                      ],
                    );
                    if (croppedFile != null) {
                      setState(() {
                        _userPhoto = File(croppedFile.path);
                      });
                    }
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _completeProfile() async {
    if (_userPhoto == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, adicione uma foto de perfil'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
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
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(left: 20),
              child: Image.asset(
                'assets/logos/logo-intellimen-square.png',
                width: 48,
                height: 48,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'COMPLETAR SEU PERFIL',
              style: TextStyle(color: AppColors.white),
            ),
          ],
        ),
      ),
      body: SizedBox.expand(
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/images/bg-intellimen.jpg',
                fit: BoxFit.cover,
              ),
            ),
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.7),
              ),
            ),
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 20),
                      Center(
                        child: Column(
                          children: [
                            const SizedBox(height: 24),
                            // Campo de foto do usuário (novo local)
                            Center(
                              child: Column(
                                children: [
                                  GestureDetector(
                                    onTap: _pickUserPhoto,
                                    child: Container(
                                      width: 150,
                                      height: 150,
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.white, width: 1),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: _userPhoto != null
                                          ? ClipRRect(
                                              borderRadius: BorderRadius.circular(10),
                                              child: Image.file(
                                                _userPhoto!,
                                                width: 150,
                                                height: 150,
                                                fit: BoxFit.cover,
                                              ),
                                            )
                                          : ClipRRect(
                                              borderRadius: BorderRadius.circular(10),
                                              child: Image.asset(
                                                'assets/logos/camera.png',
                                                width: 150,
                                                height: 150,
                                                fit: BoxFit.contain,
                                              ),
                                            ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'ADD FOTO DE PERFIL',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 30),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            // Campo de WhatsApp
                            TextFormField(
                              controller: _whatsappController,
                              keyboardType: TextInputType.phone,
                              style: const TextStyle(color: AppColors.gold),
                              decoration: const InputDecoration(
                                labelText: 'WhatsApp',
                                labelStyle: TextStyle(color: AppColors.gold),
                                prefixIcon: Icon(Icons.phone, color: AppColors.gold),
                                filled: true,
                                fillColor: Color(0xFF222222),
                                hintText: '(11) 99999-9999',
                                hintStyle: TextStyle(color: AppColors.mediumGray),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor, preencha o WhatsApp';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            // Campo de data de nascimento
                            TextFormField(
                              controller: _birthDateController,
                              readOnly: true,
                              style: const TextStyle(color: AppColors.gold),
                              decoration: InputDecoration(
                                labelText: 'Data de nascimento *',
                                labelStyle: const TextStyle(color: AppColors.gold),
                                prefixIcon: const Icon(Icons.calendar_today, color: AppColors.gold),
                                suffixIcon: IconButton(
                                  icon: const Icon(Icons.date_range, color: AppColors.gold),
                                  onPressed: () => _selectDate(context),
                                ),
                                filled: true,
                                fillColor: const Color(0xFF222222),
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
                              style: const TextStyle(color: AppColors.gold),
                              dropdownColor: Color(0xFF222222),
                              decoration: const InputDecoration(
                                labelText: 'Estado *',
                                labelStyle: TextStyle(color: AppColors.gold),
                                prefixIcon: Icon(Icons.location_on, color: AppColors.gold),
                                filled: true,
                                fillColor: Color(0xFF222222),
                              ),
                              items: AppConstants.brazilianStates.map((String state) {
                                return DropdownMenuItem<String>(
                                  value: state,
                                  child: Text(
                                    state,
                                    style: const TextStyle(color: AppColors.gold),
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
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
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