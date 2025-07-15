import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intellimen/features/welcome/presentation/pages/welcome_home_page.dart';
import 'package:intellimen/core/constants/welcome_constants.dart';
import 'package:intellimen/features/profile/presentation/pages/perfil_academy.dart';
import 'package:intellimen/features/profile/presentation/pages/perfil_campus.dart';
import 'package:intellimen/core/services/supabase_service.dart';
import 'package:intellimen/shared/providers/auth_provider.dart';
import 'package:intellimen/shared/models/user_model.dart';
import 'package:intellimen/shared/models/user_challenge_model.dart';
import 'package:intellimen/shared/models/challenge_model.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path/path.dart' as path;

// Modelo simples para desafio
class Desafio {
  final String titulo;
  final String nome1;
  final String url1;
  final int progresso1;
  final int total1;
  final bool concluido1;
  final String nome2;
  final String url2;
  final int progresso2;
  final int total2;
  final bool concluido2;
  Desafio({
    required this.titulo,
    required this.nome1,
    required this.url1,
    required this.progresso1,
    required this.total1,
    required this.concluido1,
    required this.nome2,
    required this.url2,
    required this.progresso2,
    required this.total2,
    required this.concluido2,
  });
}

final List<Desafio> desafios = List.generate(10, (i) => Desafio(
  titulo: 'DESAFIO #${i + 1}',
  nome1: 'João Fidelis',
  url1: 'https://randomuser.me/api/portraits/men/11.jpg',
  progresso1: 5 + i,
  total1: 53,
  concluido1: i % 2 == 0,
  nome2: 'Lucas Barbosa',
  url2: 'https://randomuser.me/api/portraits/men/12.jpg',
  progresso2: 4 + i,
  total2: 53,
  concluido2: i % 2 != 0,
));

// Modelo simples para quiz
class QuizConfronto {
  final String titulo;
  final String nome1;
  final String url1;
  final int pontos1;
  final int total;
  final String nome2;
  final String url2;
  final int pontos2;
  QuizConfronto({
    required this.titulo,
    required this.nome1,
    required this.url1,
    required this.pontos1,
    required this.total,
    required this.nome2,
    required this.url2,
    required this.pontos2,
  });
}

final List<QuizConfronto> quizzes = List.generate(5, (i) => QuizConfronto(
  titulo: 'BIBLE QUIZ',
  nome1: 'Juan Lucas',
  url1: 'https://randomuser.me/api/portraits/men/13.jpg',
  pontos1: 5 + i,
  total: 23,
  nome2: 'Mateus Mello',
  url2: 'https://randomuser.me/api/portraits/men/14.jpg',
  pontos2: 4 + i,
));

class PerfilIntellimenPage extends ConsumerWidget {
  final UserModel? outroUsuario;
  const PerfilIntellimenPage({Key? key, this.outroUsuario}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserDataProvider);
    final convitesPendentesAsync = ref.watch(convitesPendentesProvider);

    convitesPendentesAsync.whenData((convites) async {
      if (convites != null && convites.isNotEmpty) {
        final convite = convites.first;
        // Buscar nome do desafiante
        final supabaseService = ref.read(supabaseServiceProvider);
        final desafiante = await supabaseService.getUser(convite['from_user_id']);
        final desafianteNome = desafiante?.name ?? 'outro usuário';
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              backgroundColor: Colors.white.withOpacity(0.95),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              title: const Text(
                'VOCÊ FOI DESAFIADO!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0A3D91),
                  letterSpacing: 1.2,
                ),
              ),
              content: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Text(
                  'Você foi desafiado por $desafianteNome.\nAceita o desafio?',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Color(0xFF232323),
                  ),
                ),
              ),
              actionsAlignment: MainAxisAlignment.center,
              actionsPadding: const EdgeInsets.only(bottom: 12),
              actions: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF0A3D91),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () async {
                    await _aceitarDesafio(context, convite, ref);
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Desafio aceito com sucesso!')),
                    );
                  },
                  child: const Text('Aceitar Desafio'),
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () async {
                    await _recusarDesafio(context, convite, ref);
                    Navigator.of(context).pop();
                  },
                  child: const Text('Recusar Desafio'),
                ),
              ],
            ),
          );
        });
      }
    });

    return userAsync.when(
      data: (userLogado) {
        final user = outroUsuario ?? userLogado;
        if (user == null) {
          Future.microtask(() {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const WelcomeHomePage()),
              (route) => false,
            );
          });
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final isMeuPerfil = outroUsuario == null || user.id == userLogado?.id;
        // Buscar desafios da dupla se houver parceiro
        final supabaseService = ref.read(supabaseServiceProvider);
        final partnerId = user.partnerId;
        return FutureBuilder<List<UserChallengeModel>>(
          future: (partnerId != null)
              ? supabaseService.getDesafiosDaDupla(user.id, partnerId) as Future<List<UserChallengeModel>>
              : Future.value(<UserChallengeModel>[]),
          builder: (context, snapshot) {
            final desafiosDupla = snapshot.data ?? <UserChallengeModel>[];
            return Scaffold(
              backgroundColor: const Color(0xFFE6F4FF),
              body: Stack(
                children: [
                  // Background image
                  Positioned.fill(
                    child: Image.asset(
                      WelcomeConstants.backgroundImage,
                      fit: BoxFit.cover,
                    ),
                  ),
                  // Header preto fixo
                  Container(
                    width: double.infinity,
                    height: 340,
                    color: Colors.black,
                    child: _buildHeaderContent(context),
                  ),
                  // Conteúdo rolável
                  SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(height: 170),
                        _buildProfileCard(context, user),
                        const SizedBox(height: 24),
                        // NOVO: Botão e texto de adicionar desafio
                        Center(
                          child: Column(
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  // Abrir modal de postagem de desafio
                                  _showPostagemDesafioModal(context, ref);
                                },
                                style: ElevatedButton.styleFrom(
                                  shape: const CircleBorder(),
                                  backgroundColor: Color(0xFF002147),
                                  padding: const EdgeInsets.all(28),
                                  elevation: 8,
                                  shadowColor: Colors.black45,
                                ),
                                child: const Icon(Icons.add, size: 48, color: Colors.white),
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                'ADICIONAR DESAFIO',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF002147),
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        _buildDesafiosCarrosselReal(context, desafiosDupla, user, partnerId),
                        const SizedBox(height: 24),
                        _buildQuizCarrossel(context),
                        const SizedBox(height: 24),
                        _buildAddButton(),
                        const SizedBox(height: 24),
                        _buildReflexaoCard(),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                  // Remover o Positioned com o ElevatedButton pequeno 'Desafiar'.
                  // Menu flutuante no canto superior direito (sempre por último)
                  Consumer(
                    builder: (context, ref, _) => Positioned(
                      top: MediaQuery.of(context).padding.top + 12,
                      right: 16,
                      child: Material(
                        color: Colors.transparent,
                        child: IconButton(
                          icon: const Icon(Icons.menu, color: Colors.white, size: 32),
                          onPressed: () async {
                            // TESTE: Mostra um dialog simples para garantir que o clique está funcionando
                            // Se aparecer, troque para o showMenu abaixo
                            final selected = await showMenu<String>(
                              context: context,
                              position: RelativeRect.fromLTRB(1000, MediaQuery.of(context).padding.top + 60, 16, 0),
                              items: [
                                const PopupMenuItem(
                                  value: 'Editar',
                                  child: Text('Editar'),
                                ),
                                const PopupMenuItem(
                                  value: 'Excluir',
                                  child: Text('Excluir'),
                                ),
                                const PopupMenuItem(
                                  value: 'Academy',
                                  child: Text('Academy'),
                                ),
                                const PopupMenuItem(
                                  value: 'Campus',
                                  child: Text('Campus'),
                                ),
                                const PopupMenuItem(
                                  value: 'Logout',
                                  child: Text('Logout'),
                                ),
                              ],
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            );
                            if (selected == null) return;
                            if (selected == 'Editar') {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Editar reflexão (em breve)')),
                              );
                            } else if (selected == 'Excluir') {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Excluir reflexão (em breve)')),
                              );
                            } else if (selected == 'Academy') {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => PerfilAcademyPage(),
                                ),
                              );
                            } else if (selected == 'Campus') {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => PerfilCampusPage(),
                                ),
                              );
                            } else if (selected == 'Logout') {
                              await ref.read(authNotifierProvider.notifier).signOut();
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(builder: (context) => const WelcomeHomePage()),
                                (route) => false,
                              );
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              // Botão desafiar no card de perfil
              floatingActionButton: (user.partnerId == null)
                  ? Stack(
                      children: [
                        Align(
                          alignment: Alignment.bottomLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 24, bottom: 16),
                            child: FloatingActionButton.extended(
                              icon: const Icon(Icons.sports_mma, color: Colors.white),
                              label: const Text('Desafiar', style: TextStyle(color: Colors.white)),
                              onPressed: () async {
                                final selectedUser = await showBuscaUsuarioModal(context, ref);
                                if (selectedUser != null && selectedUser.id != user.id) {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Confirmar desafio'),
                                      content: Text('Deseja realmente enviar um convite de desafio para ${selectedUser.name}?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.of(context).pop(false),
                                          child: const Text('Cancelar'),
                                        ),
                                        ElevatedButton(
                                          onPressed: () => Navigator.of(context).pop(true),
                                          child: const Text('Continuar'),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (confirm == true) {
                                    final supabaseService = ref.read(supabaseServiceProvider);
                                    final currentUser = ref.read(currentUserProvider).value;
                                    if (currentUser != null) {
                                      await supabaseService.enviarConviteDesafio(
                                        fromUserId: user.id,
                                        toUserId: selectedUser.id,
                                      );
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Convite enviado para ${selectedUser.name}!')),
                                      );
                                    }
                                  }
                                }
                              },
                              backgroundColor: const Color(0xFF002147),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(32),
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : null,
              bottomNavigationBar: _buildBottomNavBar(context),
            );
          },
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Erro ao carregar usuário'))),
    );
  }

  // Novo método para o conteúdo do header
  Widget _buildHeaderContent(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        left: 16,
        right: 16,
        bottom: 8,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Image.asset('assets/logos/logo-intellimen-square.png', height: 60),
          ),
          // Removido o menu daqui
        ],
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context, user) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        // Card
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
          decoration: BoxDecoration(
            color: const Color(0xFFEE0E0E0),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.10),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            children: [
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    user.name,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF232323),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.verified_rounded,
                    color: Color(0xFF1976D2),
                    size: 28,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.location_on, color: Colors.black54, size: 20),
                  const SizedBox(width: 4),
                  Text(user.state ?? '', style: const TextStyle(fontSize: 18, color: Colors.black54)),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: 220,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(24),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Funcionalidade de desafio em desenvolvimento'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0A3D91),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.25),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Text(
                        'DESAFIAR',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 4,
                          fontFamily: 'RobotoMono',
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Foto sobreposta
        Positioned(
          top: -70,
          child: GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Visualizar foto em tela cheia'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF002BC4),
                    Color(0xFF0088FF),
                    Color(0xFF002BC4),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.18),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  user.photoUrl ?? 'https://randomuser.me/api/portraits/men/11.jpg',
                  width: 140,
                  height: 140,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 140,
                      height: 140,
                      color: Colors.grey[300],
                      child: const Icon(Icons.person, size: 60, color: Colors.grey),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Novo carrossel real dos desafios da dupla
  Widget _buildDesafiosCarrosselReal(BuildContext context, List<UserChallengeModel> desafios, UserModel user, String? partnerId) {
    if (desafios.isEmpty || partnerId == null) {
      return const SizedBox.shrink();
    }
    final supabaseService = SupabaseService();
    return FutureBuilder<List<ChallengeModel>>(
      future: supabaseService.getChallenges(),
      builder: (context, snapshotChallenges) {
        if (!snapshotChallenges.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final totalDesafios = snapshotChallenges.data!.length;
        return SizedBox(
          height: 400, // altura aumentada para evitar rolagem
          child: PageView.builder(
            itemCount: desafios.length,
            controller: PageController(viewportFraction: 0.92),
            itemBuilder: (context, index) {
              final desafio = desafios[index];
              return FutureBuilder(
                future: Future.wait([
                  supabaseService.getUser(desafio.userId),
                  supabaseService.getUser(desafio.partnerId),
                  supabaseService.getUserChallenge(desafio.userId, desafio.partnerId, desafio.challengeId),
                  supabaseService.getUserChallenge(desafio.partnerId, desafio.userId, desafio.challengeId),
                ]),
                builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final user1 = snapshot.data![0] as UserModel?;
                  final user2 = snapshot.data![1] as UserModel?;
                  final userChallenge1 = snapshot.data![2] as UserChallengeModel?;
                  final userChallenge2 = snapshot.data![3] as UserChallengeModel?;
                  if (user1 == null || user2 == null) {
                    return const Center(child: Text('Erro ao carregar usuários'));
                  }
                  // Progresso: N de 53
                  final progressoAtual = index + 1;
                  final total = totalDesafios;

                  // Buscar todos os desafios concluídos de cada usuário
                  return FutureBuilder<List<UserChallengeModel>>(
                    future: supabaseService.getUserChallenges(user1.id),
                    builder: (context, snapshotUser1) {
                      return FutureBuilder<List<UserChallengeModel>>(
                        future: supabaseService.getUserChallenges(user2.id),
                        builder: (context, snapshotUser2) {
                          // Calcular progresso baseado nos desafios realmente concluídos
                          int concluidosUser1 = 0;
                          int concluidosUser2 = 0;
                          
                          if (snapshotUser1.hasData) {
                            concluidosUser1 = snapshotUser1.data!
                                .where((uc) => uc.status == 'completed' && uc.partnerId == user2.id)
                                .length;
                          }
                          
                          if (snapshotUser2.hasData) {
                            concluidosUser2 = snapshotUser2.data!
                                .where((uc) => uc.status == 'completed' && uc.partnerId == user1.id)
                                .length;
                          }
                          
                          double progressoBarra1 = concluidosUser1 / total;
                          double progressoBarra2 = concluidosUser2 / total;
                          
                          // Status e progresso individuais
                          String status1 = userChallenge1?.status == 'completed' ? 'CONCLUÍDO' : 'PENDENTE';
                          String status2 = userChallenge2?.status == 'completed' ? 'CONCLUÍDO' : 'PENDENTE';
                          
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 16),
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEE0E0E0),
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.12),
                                  blurRadius: 18,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: SingleChildScrollView(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'DESAFIO #$progressoAtual',
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 2,
                                      color: Color(0xFF232323),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          children: [
                                            _buildDesafioPerfil(
                                              nome: user1.name,
                                              url: user1.photoUrl ?? '',
                                              progresso: progressoBarra1,
                                              total: 1,
                                              concluido: userChallenge1?.status == 'completed',
                                            ),
                                            const SizedBox(height: 4),
                                            Text('$progressoAtual de $total', style: const TextStyle(fontSize: 14, color: Colors.black87)),
                                            const SizedBox(height: 4),
                                            Text(status1, style: TextStyle(fontSize: 14, color: status1 == 'CONCLUÍDO' ? Colors.green : Colors.red, fontWeight: FontWeight.bold)),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        width: 1,
                                        height: 80,
                                        color: Colors.grey[300],
                                        margin: const EdgeInsets.symmetric(horizontal: 8),
                                      ),
                                      Expanded(
                                        child: Column(
                                          children: [
                                            _buildDesafioPerfil(
                                              nome: user2.name,
                                              url: user2.photoUrl ?? '',
                                              progresso: progressoBarra2,
                                              total: 1,
                                              concluido: userChallenge2?.status == 'completed',
                                            ),
                                            const SizedBox(height: 4),
                                            Text('$progressoAtual de $total', style: const TextStyle(fontSize: 14, color: Colors.black87)),
                                            const SizedBox(height: 4),
                                            Text(status2, style: TextStyle(fontSize: 14, color: status2 == 'CONCLUÍDO' ? Colors.green : Colors.red, fontWeight: FontWeight.bold)),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  ElevatedButton(
                                    onPressed: () {
                                      // TODO: Implementar ação de revisar desafio
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Revisar desafio (em breve)')),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF0A3D91),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                      textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                    ),
                                    child: const Text('Revisar Desafio'),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildDesafiosCarrossel(BuildContext context) {
    return SizedBox(
      height: 340,
      child: PageView.builder(
        itemCount: desafios.length,
        controller: PageController(viewportFraction: 0.92),
        itemBuilder: (context, index) {
          final desafio = desafios[index];
          return _buildDesafioCard(
            context,
            titulo: desafio.titulo,
            nome1: desafio.nome1,
            url1: desafio.url1,
            progresso1: desafio.progresso1,
            total1: desafio.total1,
            concluido1: desafio.concluido1,
            nome2: desafio.nome2,
            url2: desafio.url2,
            progresso2: desafio.progresso2,
            total2: desafio.total2,
            concluido2: desafio.concluido2,
          );
        },
      ),
    );
  }

  Widget _buildDesafioCard(
    BuildContext context, {
    required String titulo,
    required String nome1,
    required String url1,
    required int progresso1,
    required int total1,
    required bool concluido1,
    required String nome2,
    required String url2,
    required int progresso2,
    required int total2,
    required bool concluido2,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Color(0xFFEE0E0E0),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            titulo,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
              color: Color(0xFF232323),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildDesafioPerfil(
                nome: nome1,
                url: url1,
                progresso: progresso1.toDouble(),
                total: total1,
                concluido: concluido1,
              )),
              Container(
                width: 1,
                height: 80,
                color: Colors.grey[300],
                margin: const EdgeInsets.symmetric(horizontal: 8),
              ),
              Expanded(child: _buildDesafioPerfil(
                nome: nome2,
                url: url2,
                progresso: progresso2.toDouble(),
                total: total2,
                concluido: concluido2,
              )),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDesafioPerfil({
    required String nome,
    required String url,
    required double progresso,
    required int total,
    required bool concluido,
  }) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Color(0xFF002BC4), width: 2),
          ),
          child: CircleAvatar(
            backgroundImage: NetworkImage(url),
            radius: 32,
            onBackgroundImageError: (exception, stackTrace) {
              // Tratamento de erro para imagem
            },
          ),
        ),
        const SizedBox(height: 8),
        Text(
          nome,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10), // borda arredondada
          child: LinearProgressIndicator(
            value: progresso,
            backgroundColor: Colors.grey[200],
            color: concluido ? Colors.green : Colors.red,
            minHeight: 20, // altura maior
          ),
        ),
        const SizedBox(height: 4),
        // O texto "N de 53" já está fora deste widget, então pode remover aqui
        const SizedBox(height: 4),
        Text(
          concluido ? 'CONCLUÍDO' : 'PENDENTE',
          style: TextStyle(
            fontSize: 14,
            color: concluido ? Colors.green : Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Icon(
          concluido ? Icons.check_circle : Icons.cancel,
          color: concluido ? Colors.green : Colors.red,
          size: 35,
        ),
      ],
    );
  }

  Widget _buildQuizCarrossel(BuildContext context) {
    return SizedBox(
      height: 320,
      child: PageView.builder(
        itemCount: quizzes.length,
        controller: PageController(viewportFraction: 0.92),
        itemBuilder: (context, index) {
          final quiz = quizzes[index];
          return _buildQuizCard(
            context,
            titulo: quiz.titulo,
            nome1: quiz.nome1,
            url1: quiz.url1,
            pontos1: quiz.pontos1,
            total: quiz.total,
            nome2: quiz.nome2,
            url2: quiz.url2,
            pontos2: quiz.pontos2,
          );
        },
      ),
    );
  }

  Widget _buildQuizCard(
    BuildContext context, {
    required String titulo,
    required String nome1,
    required String url1,
    required int pontos1,
    required int total,
    required String nome2,
    required String url2,
    required int pontos2,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Color(0xFFEE0E0E0),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            titulo,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
              color: Color(0xFF232323),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildQuizPerfil(
                nome: nome1,
                url: url1,
                pontos: pontos1,
                total: total,
              )),
              Container(
                width: 1,
                height: 80,
                color: Colors.grey[300],
                margin: const EdgeInsets.symmetric(horizontal: 8),
              ),
              Expanded(child: _buildQuizPerfil(
                nome: nome2,
                url: url2,
                pontos: pontos2,
                total: total,
              )),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuizPerfil({
    required String nome,
    required String url,
    required int pontos,
    required int total,
  }) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Color(0xFF002BC4), width: 2),
          ),
          child: CircleAvatar(
            backgroundImage: NetworkImage(url),
            radius: 32,
            onBackgroundImageError: (exception, stackTrace) {},
          ),
        ),
        const SizedBox(height: 8),
        Text(
          nome,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: pontos / total,
            backgroundColor: Colors.grey[200],
            color: Colors.blue,
            minHeight: 20,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          ' 24pontos de  24total',
          style: const TextStyle(fontSize: 14, color: Colors.black87),
        ),
      ],
    );
  }

  Widget _buildAddButton() {
    return Builder(
      builder: (context) => GestureDetector(
        onTap: () {
          // TODO: Implementar funcionalidade de adicionar
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Funcionalidade de adicionar em desenvolvimento'),
              duration: Duration(seconds: 1),
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.10),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const CircleAvatar(
            radius: 32,
            backgroundColor: Colors.white,
            child: Icon(Icons.add, color: Color(0xFF0A3D91), size: 40),
          ),
        ),
      ),
    );
  }

  Widget _buildReflexaoCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      decoration: BoxDecoration(
        color: Color(0xFFEE0E0E0),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 8),
              const Text(
                'Reflexão',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF232323),
                  letterSpacing: 1.2,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 18),
              const Text(
                '"porquanto espírito excelente, conhecimento e inteligência, interpretação de sonhos, declaração de enigmas e solução de casos difíceis se acharam neste Daniel"',
                style: TextStyle(
                  fontSize: 17,
                  color: Color(0xFF444444),
                  height: 1.5,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              Center(
                child: Builder(
                  builder: (context) => SizedBox(
                    width: 140,
                    height: 44,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF002BC4),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22),
                        ),
                        elevation: 6,
                      ),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            title: const Text('Reflexão Completa'),
                            content: const Text(
                              '"porquanto espírito excelente, conhecimento e inteligência, interpretação de sonhos, declaração de enigmas e solução de casos difíceis se acharam neste Daniel"',
                              style: TextStyle(fontSize: 17, height: 1.5),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('Fechar'),
                              ),
                            ],
                          ),
                        );
                      },
                      child: const Text(
                        'LEIA MAIS',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavBar(BuildContext context) {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: Colors.black,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const WelcomeHomePage()),
                (route) => false,
              );
            },
            child: const Icon(Icons.home, color: Colors.pinkAccent, size: 36),
          ),
          GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Busca em desenvolvimento'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
            child: const Icon(Icons.search, color: Colors.pinkAccent, size: 36),
          ),
          GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Criar novo conteúdo'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
            child: Icon(Icons.add_circle, color: Colors.blue, size: 44),
          ),
          GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Vídeos em desenvolvimento'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
            child: const Icon(Icons.ondemand_video, color: Colors.pinkAccent, size: 36),
          ),
          GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Você já está no perfil'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
            child: const CircleAvatar(
              radius: 20,
              backgroundImage: NetworkImage('https://randomuser.me/api/portraits/men/11.jpg'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _aceitarDesafio(BuildContext context, dynamic convite, WidgetRef ref) async {
    final supabaseService = ref.read(supabaseServiceProvider);
    final fromUserId = convite['from_user_id'] as String;
    final toUserId = convite['to_user_id'] as String;
    // Atualiza status do convite
    await supabaseService.client
        .from('challenge_invites')
        .update({'status': 'accepted'})
        .eq('id', convite['id']);
    // Atualiza partner_id dos dois usuários
    await supabaseService.client.from('users').update({'partner_id': fromUserId}).eq('id', toUserId);
    await supabaseService.client.from('users').update({'partner_id': toUserId}).eq('id', fromUserId);
    // Busca os desafios reais do banco
    final desafios = await supabaseService.getChallenges();
    if (desafios.isNotEmpty) {
      final primeiroDesafio = desafios.first;
      await supabaseService.client.from('user_challenges').insert({
        'user_id': fromUserId,
        'partner_id': toUserId,
        'challenge_id': primeiroDesafio.id,
        'status': 'pending',
      });
      await supabaseService.client.from('user_challenges').insert({
        'user_id': toUserId,
        'partner_id': fromUserId,
        'challenge_id': primeiroDesafio.id,
        'status': 'pending',
      });
    }
    // Força refresh do usuário logado para atualizar o partnerId
    await ref.read(authNotifierProvider.notifier).refreshUserData();
  }

  Future<void> _recusarDesafio(BuildContext context, dynamic convite, WidgetRef ref) async {
    final supabaseService = ref.read(supabaseServiceProvider);
    await supabaseService.client
        .from('challenge_invites')
        .update({'status': 'declined'})
        .eq('id', convite['id']);
  }

  void _showPostagemDesafioModal(BuildContext context, WidgetRef ref) async {
    final TextEditingController tituloController = TextEditingController();
    final TextEditingController descricaoController = TextEditingController();
    List<XFile> imagensSelecionadas = [];
    String? imagemUrl;
    bool isUploading = false;
    // Buscar desafios disponíveis
    final supabaseService = ref.read(supabaseServiceProvider);
    final desafiosAtivos = await supabaseService.getChallenges();
    String? desafioSelecionadoId = desafiosAtivos.isNotEmpty ? desafiosAtivos.first.id : null;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.white.withOpacity(0.95),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              title: const Text(
                'NOVO DESAFIO',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0A3D91),
                  letterSpacing: 1.2,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Dropdown de desafios
                    if (desafiosAtivos.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Escolha o desafio',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            value: desafioSelecionadoId,
                            items: desafiosAtivos.map((d) => DropdownMenuItem(
                              value: d.id,
                              child: Text(d.title),
                            )).toList(),
                            onChanged: (val) {
                              setState(() {
                                desafioSelecionadoId = val;
                              });
                            },
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              filled: true,
                              fillColor: Colors.white10,
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    TextField(
                      controller: tituloController,
                      decoration: const InputDecoration(
                        labelText: 'Título do Desafio',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white10,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: descricaoController,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: 'Descrição',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white10,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.grey[50],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Imagens do Desafio (até 3)',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 12),
                          if (imagensSelecionadas.isNotEmpty)
                            Wrap(
                              spacing: 8,
                              children: List.generate(imagensSelecionadas.length, (i) => Stack(
                                alignment: Alignment.topRight,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.file(
                                      File(imagensSelecionadas[i].path),
                                      height: 80,
                                      width: 80,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Positioned(
                                    top: 0,
                                    right: 0,
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          imagensSelecionadas.removeAt(i);
                                        });
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.red,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: const Icon(Icons.close, color: Colors.white, size: 18),
                                      ),
                                    ),
                                  ),
                                ],
                              )),
                            ),
                          if (imagensSelecionadas.length < 3)
                            Padding(
                              padding: const EdgeInsets.only(top: 12.0),
                              child: ElevatedButton.icon(
                                onPressed: isUploading
                                    ? null
                                    : () async {
                                        final picker = ImagePicker();
                                        final option = await showDialog<String>(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: const Text('Escolha uma opção'),
                                            content: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                ListTile(
                                                  leading: const Icon(Icons.camera_alt),
                                                  title: const Text('Tirar foto'),
                                                  onTap: () => Navigator.of(context).pop('camera'),
                                                ),
                                                ListTile(
                                                  leading: const Icon(Icons.photo_library),
                                                  title: const Text('Selecionar da galeria'),
                                                  onTap: () => Navigator.of(context).pop('gallery'),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                        if (option == null) return;
                                        XFile? picked;
                                        if (option == 'camera') {
                                          picked = await picker.pickImage(source: ImageSource.camera);
                                        } else if (option == 'gallery') {
                                          picked = await picker.pickImage(source: ImageSource.gallery);
                                        }
                                        if (picked != null) {
                                          final XFile pickedFile = picked;
                                          setState(() {
                                            imagensSelecionadas.add(pickedFile);
                                          });
                                        }
                                      },
                                icon: const Icon(Icons.upload_file),
                                label: const Text('Adicionar Imagem'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF0A3D91),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('Cancelar'),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0A3D91),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          onPressed: isUploading
                              ? null
                              : () async {
                                  final descricao = descricaoController.text.trim();
                                  if (descricao.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('A descrição é obrigatória!')),
                                    );
                                    return;
                                  }
                                  setState(() => isUploading = true);
                                  List<String> imageUrls = [];
                                  try {
                                    if (imagensSelecionadas.isNotEmpty) {
                                      final supabaseService = ref.read(supabaseServiceProvider);
                                      for (final img in imagensSelecionadas) {
                                        final file = File(img.path);
                                        final fileName = path.basename(img.path);
                                        print('Tentando fazer upload: ' + fileName);
                                        final url = await supabaseService.uploadFile(
                                          file: file,
                                          bucketName: 'desafio-images',
                                          fileName: '${DateTime.now().millisecondsSinceEpoch}_$fileName',
                                        );
                                        print('URL retornada: $url');
                                        if (url != null) imageUrls.add(url);
                                        else print('Falha ao obter URL para $fileName');
                                      }
                                    }
                                  } catch (e, st) {
                                    print('Erro no upload: $e');
                                    print(st);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Erro ao fazer upload: $e')),
                                    );
                                    setState(() => isUploading = false);
                                    return;
                                  }
                                  // Salvar no banco
                                  final user = ref.read(currentUserDataProvider).value;
                                  if (user == null || user.partnerId == null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Usuário/parceiro não encontrado!')),
                                    );
                                    setState(() => isUploading = false);
                                    return;
                                  }
                                  if (desafioSelecionadoId == null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Selecione um desafio!')),
                                    );
                                    setState(() => isUploading = false);
                                    return;
                                  }
                                  final supabaseService = ref.read(supabaseServiceProvider);
                                  // Atualizar o registro existente do user_challenges para este usuário/parceiro/desafio
                                  await supabaseService.client.from('user_challenges')
                                    .update({
                                      'notes': descricao,
                                      'image_url': imageUrls.join(','),
                                      'status': 'completed',
                                      'completed_at': DateTime.now().toIso8601String(),
                                    })
                                    .eq('user_id', user.id)
                                    .eq('partner_id', user.partnerId!)
                                    .eq('challenge_id', desafioSelecionadoId!);
                                  setState(() => isUploading = false);
                                  Navigator.of(context).pop();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Desafio postado com sucesso!')),
                                  );
                                  await ref.read(authNotifierProvider.notifier).refreshUserData();
                                },
                          child: isUploading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : const Text('Postar Desafio'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class BuscaUsuarioModal extends ConsumerStatefulWidget {
  const BuscaUsuarioModal({Key? key}) : super(key: key);

  @override
  ConsumerState<BuscaUsuarioModal> createState() => _BuscaUsuarioModalState();
}

class _BuscaUsuarioModalState extends ConsumerState<BuscaUsuarioModal> {
  final TextEditingController controller = TextEditingController();
  String termo = '';

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final buscaAsync = termo.isNotEmpty
        ? ref.watch(buscaUsuariosProvider(termo))
        : null;
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(24),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: LinearGradient(
            colors: [
              const Color.fromRGBO(30, 30, 30, 0.80),
              const Color.fromRGBO(50, 50, 50, 0.80),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'DESAFIAR UM PARCEIRO',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 18),
            TextField(
              controller: controller,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Digite o nome',
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
              onChanged: (value) => setState(() => termo = value),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 350,
              width: 300,
              child: (termo.isEmpty)
                  ? const Center(child: Text('Digite um nome para buscar', style: TextStyle(color: Colors.white70)))
                  : buscaAsync == null
                      ? const SizedBox.shrink()
                      : buscaAsync.when(
                          data: (usuarios) => usuarios.isEmpty
                              ? const Center(child: Text('Nenhum usuário encontrado', style: TextStyle(color: Colors.white70)))
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
                                      title: Text(user.name, style: const TextStyle(color: Colors.white)),
                                      onTap: () => Navigator.of(context).pop(user),
                                    );
                                  },
                                ),
                          loading: () => const Center(child: CircularProgressIndicator(color: Colors.white)),
                          error: (e, _) => Center(child: Text('Erro: $e', style: const TextStyle(color: Colors.white))),
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
}

Future<UserModel?> showBuscaUsuarioModal(BuildContext context, WidgetRef ref) {
  return showDialog<UserModel>(
    context: context,
    builder: (context) => const BuscaUsuarioModal(),
  );
} 