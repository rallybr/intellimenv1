import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/supabase_service.dart';
import '../models/user_model.dart';
import '../providers/auth_provider.dart';

class UserSearchModal extends ConsumerStatefulWidget {
  final String title;
  final String searchHint;
  final Function(UserModel) onUserSelected;
  final bool isConfrontation;

  const UserSearchModal({
    Key? key,
    required this.title,
    required this.searchHint,
    required this.onUserSelected,
    this.isConfrontation = false,
  }) : super(key: key);

  @override
  ConsumerState<UserSearchModal> createState() => _UserSearchModalState();
}

class _UserSearchModalState extends ConsumerState<UserSearchModal> {
  final TextEditingController _controller = TextEditingController();
  String _termo = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final buscaAsync = _termo.isNotEmpty
        ? ref.watch(buscaUsuariosProvider(_termo))
        : null;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(24),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: LinearGradient(
            colors: [
              const Color.fromRGBO(30, 80, 255, 1.0),
              const Color.fromRGBO(50, 0, 255, 1.0),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2
              ),
            ),
            const SizedBox(height: 18),
            TextField(
              controller: _controller,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: widget.searchHint,
                labelStyle: const TextStyle(color: Colors.white70),
                prefixIcon: const Icon(Icons.search, color: Colors.white70),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.white24),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.white),
                ),
                fillColor: Colors.white10,
                filled: true,
              ),
              onChanged: (value) => setState(() => _termo = value),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 350,
              width: 300,
              child: _termo.isEmpty
                  ? const Center(
                      child: Text(
                        'Digite um nome para buscar',
                        style: TextStyle(color: Colors.white70),
                      ),
                    )
                  : buscaAsync == null
                      ? const SizedBox.shrink()
                      : buscaAsync.when(
                          data: (usuarios) => usuarios.isEmpty
                              ? const Center(
                                  child: Text(
                                    'Nenhum usuário encontrado',
                                    style: TextStyle(color: Colors.white70),
                                  ),
                                )
                              : ListView.builder(
                                  itemCount: usuarios.length,
                                  itemBuilder: (context, index) {
                                    final user = usuarios[index];
                                    return ListTile(
                                      leading: CircleAvatar(
                                        backgroundImage: user.photoUrl != null
                                            ? NetworkImage(user.photoUrl!)
                                            : null,
                                        child: user.photoUrl == null
                                            ? const Icon(Icons.person, color: Colors.white)
                                            : null,
                                      ),
                                      title: Text(
                                        user.name,
                                        style: const TextStyle(color: Colors.white),
                                      ),
                                      onTap: () => _handleUserSelection(user),
                                    );
                                  },
                                ),
                          loading: () => const Center(
                              child: CircularProgressIndicator(color: Colors.white)),
                          error: (e, _) => Center(
                              child: Text('Erro: $e',
                                  style: const TextStyle(color: Colors.white))),
                        ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Fechar', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleUserSelection(UserModel user) {
    if (widget.isConfrontation) {
      _handleConfrontationSelection(user);
    } else {
      widget.onUserSelected(user);
    }
  }

  void _handleConfrontationSelection(UserModel user) async {
    final currentUser = ref.read(currentUserDataProvider).value;
    if (currentUser == null) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro: usuário não autenticado!')),
      );
      return;
    }

    final supabaseService = ref.read(supabaseServiceProvider);
    try {
      await supabaseService.enviarConviteDesafio(
        fromUserId: currentUser.id,
        toUserId: user.id,
      );
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Convite de confronto enviado para ${user.name}!')),
      );
    } catch (e) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().contains('convite pendente')
                ? 'Já existe um convite pendente entre vocês.'
                : 'Erro ao enviar convite: $e',
          ),
        ),
      );
    }
  }
}

Future<UserModel?> showUserSearchModal(
  BuildContext context,
  WidgetRef ref, {
  required String title,
  required String searchHint,
  required Function(UserModel) onUserSelected,
  bool isConfrontation = false,
}) {
  return showDialog<UserModel>(
    context: context,
    builder: (context) => UserSearchModal(
      title: title,
      searchHint: searchHint,
      onUserSelected: onUserSelected,
      isConfrontation: isConfrontation,
    ),
  );
} 