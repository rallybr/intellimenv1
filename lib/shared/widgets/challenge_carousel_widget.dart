import 'package:flutter/material.dart';
import '../../core/services/supabase_service.dart';
import '../models/user_model.dart';
import '../models/user_challenge_model.dart';
import '../models/challenge_model.dart';

class ChallengeCarouselWidget extends StatefulWidget {
  final List<UserChallengeModel> desafios;
  final int totalDesafios;
  final UserModel user;
  final String? partnerId;
  final VoidCallback? onUpdate;

  const ChallengeCarouselWidget({
    Key? key,
    required this.desafios,
    required this.totalDesafios,
    required this.user,
    this.partnerId,
    this.onUpdate,
  }) : super(key: key);

  @override
  State<ChallengeCarouselWidget> createState() => _ChallengeCarouselWidgetState();
}

class _ChallengeCarouselWidgetState extends State<ChallengeCarouselWidget> {
  final PageController _pageController = PageController(viewportFraction: 0.92);
  int _currentPage = 0;
  final SupabaseService _supabaseService = SupabaseService();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.desafios.isEmpty || widget.partnerId == null) {
      return _buildEmptyState();
    }

    return Column(
      children: [
        SizedBox(
          height: 400,
          child: PageView.builder(
            itemCount: widget.desafios.length,
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              final desafio = widget.desafios[index];
              return _buildChallengeCard(desafio, index);
            },
          ),
        ),
        const SizedBox(height: 16),
        _buildPageIndicators(),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFEE0E0E0),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 25,
            offset: const Offset(0, 12),
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.sports_mma,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhum desafio encontrado',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Complete desafios com seu parceiro para ver o progresso aqui',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildChallengeCard(UserChallengeModel desafio, int index) {
    return FutureBuilder(
      future: Future.wait([
        _supabaseService.getUser(desafio.userId),
        _supabaseService.getUser(desafio.partnerId),
        _supabaseService.getUserChallenge(desafio.userId, desafio.partnerId, desafio.challengeId),
        _supabaseService.getUserChallenge(desafio.partnerId, desafio.userId, desafio.challengeId),
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

        final progressoAtual = index + 1;
        final total = widget.totalDesafios;

        return FutureBuilder<List<UserChallengeModel>>(
          future: _supabaseService.getUserChallenges(user1.id),
          builder: (context, snapshotUser1) {
            return FutureBuilder<List<UserChallengeModel>>(
              future: _supabaseService.getUserChallenges(user2.id),
              builder: (context, snapshotUser2) {
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
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 25,
                        offset: const Offset(0, 12),
                        spreadRadius: 2,
                      ),
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 40,
                        offset: const Offset(0, 20),
                        spreadRadius: 4,
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
                                 _buildChallengeProfile(
                                     nome: user1.name,
                                     url: user1.photoUrl ?? '',
                                     progresso: progressoBarra1,
                                     concluido: userChallenge1?.status == 'completed',
                                   ),
                                  const SizedBox(height: 4),
                                  Text('$progressoAtual de $total', 
                                    style: const TextStyle(fontSize: 14, color: Colors.black87)),
                                  const SizedBox(height: 4),
                                  Text(status1, 
                                    style: TextStyle(fontSize: 14, 
                                      color: status1 == 'CONCLUÍDO' ? Colors.green : Colors.red, 
                                      fontWeight: FontWeight.bold)),
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
                                 _buildChallengeProfile(
                                     nome: user2.name,
                                     url: user2.photoUrl ?? '',
                                     progresso: progressoBarra2,
                                     concluido: userChallenge2?.status == 'completed',
                                   ),
                                  const SizedBox(height: 4),
                                  Text('$progressoAtual de $total', 
                                    style: const TextStyle(fontSize: 14, color: Colors.black87)),
                                  const SizedBox(height: 4),
                                  Text(status2, 
                                    style: TextStyle(fontSize: 14, 
                                      color: status2 == 'CONCLUÍDO' ? Colors.green : Colors.red, 
                                      fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            _showEditChallengeModal(context, desafio, user1, user2);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF000256),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
  }

  Widget _buildChallengeProfile({
    required String nome,
    required String url,
    required double progresso,
    required bool concluido,
  }) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFF00256d), width: 2),
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
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: progresso,
            backgroundColor: Colors.grey[200],
            color: concluido ? Colors.green : Colors.red,
            minHeight: 20,
          ),
        ),
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

  Widget _buildPageIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(10, (index) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: index == _currentPage ? const Color(0xFF0256) : Colors.grey[300],
          ),
        );
      }),
    );
  }

  void _showEditChallengeModal(BuildContext context, UserChallengeModel desafio, UserModel user1, UserModel user2) {
    // Implementar modal de edição de desafio
    // Esta funcionalidade pode ser implementada conforme necessário
  }
} 