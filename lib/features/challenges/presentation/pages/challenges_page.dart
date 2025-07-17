import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intellimen/core/services/supabase_service.dart';
import 'package:intellimen/shared/models/challenge_model.dart';
import 'package:intellimen/shared/models/user_challenge_model.dart';
import 'package:intellimen/shared/providers/auth_provider.dart';

enum ChallengeFilter { todos, completos, pendentes }

class ChallengesPage extends ConsumerStatefulWidget {
  const ChallengesPage({Key? key}) : super(key: key);

  @override
  ConsumerState<ChallengesPage> createState() => _ChallengesPageState();
}

class _ChallengesPageState extends ConsumerState<ChallengesPage> {
  ChallengeFilter _currentFilter = ChallengeFilter.todos;
  List<ChallengeModel> _allChallenges = [];
  List<UserChallengeModel> _userChallenges = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadChallenges();
  }

  Future<void> _loadChallenges() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final supabaseService = ref.read(supabaseServiceProvider);
      final currentUser = ref.read(currentUserDataProvider).value;

      // Carregar todos os desafios
      final challenges = await supabaseService.getChallenges();
      
      // Carregar desafios do usuário se estiver logado
      List<UserChallengeModel> userChallenges = [];
      if (currentUser != null) {
        userChallenges = await supabaseService.getUserChallenges(currentUser.id);
      }

      setState(() {
        _allChallenges = challenges;
        _userChallenges = userChallenges;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<ChallengeModel> get _filteredChallenges {
    List<ChallengeModel> filteredChallenges;
    
    if (_currentFilter == ChallengeFilter.todos) {
      filteredChallenges = _allChallenges;
    } else {
      // Para COMPLETOS e PENDENTES, precisamos verificar o status do usuário
      final currentUser = ref.read(currentUserDataProvider).value;
      if (currentUser == null) {
        filteredChallenges = _allChallenges;
      } else {
        final completedChallengeIds = _userChallenges
            .where((uc) => uc.status == 'completed')
            .map((uc) => uc.challengeId)
            .toSet();

        final pendingChallengeIds = _userChallenges
            .where((uc) => uc.status == 'pending')
            .map((uc) => uc.challengeId)
            .toSet();

        if (_currentFilter == ChallengeFilter.completos) {
          filteredChallenges = _allChallenges.where((challenge) => 
            completedChallengeIds.contains(challenge.id)).toList();
        } else if (_currentFilter == ChallengeFilter.pendentes) {
          filteredChallenges = _allChallenges.where((challenge) => 
            pendingChallengeIds.contains(challenge.id)).toList();
        } else {
          filteredChallenges = _allChallenges;
        }
      }
    }

    // Ordenar por número do desafio (extrair número do título)
    filteredChallenges.sort((a, b) {
      final aNumber = _extractChallengeNumber(a.title);
      final bNumber = _extractChallengeNumber(b.title);
      return aNumber.compareTo(bNumber);
    });

    return filteredChallenges;
  }

  int _extractChallengeNumber(String title) {
    // Extrair número do título (ex: "Desafio #1" -> 1)
    final regex = RegExp(r'#(\d+)');
    final match = regex.firstMatch(title);
    if (match != null) {
      return int.tryParse(match.group(1) ?? '0') ?? 0;
    }
    return 0;
  }

  bool _isChallengeCompleted(String challengeId) {
    return _userChallenges.any((uc) => 
      uc.challengeId == challengeId && uc.status == 'completed');
  }

  bool _isChallengePending(String challengeId) {
    return _userChallenges.any((uc) => 
      uc.challengeId == challengeId && uc.status == 'pending');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          // Header
          _buildHeader(),
          
          // Filter Tabs
          _buildFilterTabs(),
          
          // Content
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  )
                : _buildChallengesGrid(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        left: 16,
        right: 16,
        bottom: 16,
      ),
      child: Row(
        children: [
          // Botão voltar
          GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: Row(
              children: [
                const Icon(Icons.arrow_back, color: Colors.white, size: 24),
                const SizedBox(width: 8),
                const Text(
                  'VOLTAR',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          const Spacer(),
          
          // Logo
          Row(
            children: [
              Image.asset(
                'assets/logos/logo-intellimen-square.png',
                height: 32,
                width: 32,
              ),
              const SizedBox(width: 8),
              const Text(
                'PROJETO INTELLIMEN',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildTab(
              'TODOS',
              _currentFilter == ChallengeFilter.todos,
              () => setState(() => _currentFilter = ChallengeFilter.todos),
            ),
          ),
          const SizedBox(width: 1),
          Expanded(
            child: _buildTab(
              'COMPLETOS',
              _currentFilter == ChallengeFilter.completos,
              () => setState(() => _currentFilter = ChallengeFilter.completos),
            ),
          ),
          const SizedBox(width: 1),
          Expanded(
            child: _buildTab(
              'PENDENTES',
              _currentFilter == ChallengeFilter.pendentes,
              () => setState(() => _currentFilter = ChallengeFilter.pendentes),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String title, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.white,
          border: Border.all(
            color: Colors.white,
            width: 1,
          ),
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildChallengesGrid() {
    final challenges = _filteredChallenges;
    
    if (challenges.isEmpty) {
      return const Center(
        child: Text(
          'Nenhum desafio encontrado',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
          ),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.75,
      ),
      itemCount: challenges.length,
      itemBuilder: (context, index) {
        final challenge = challenges[index];
        final isCompleted = _isChallengeCompleted(challenge.id);
        final isPending = _isChallengePending(challenge.id);
        
        return _buildChallengeCard(challenge, isCompleted, isPending);
      },
    );
  }

  Widget _buildChallengeCard(ChallengeModel challenge, bool isCompleted, bool isPending) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F0F), // Cor mais escura similar à imagem
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey[800]!,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Icon area with completion indicator
          Expanded(
            flex: 3,
            child: Stack(
              children: [
                // Background image
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                    image: const DecorationImage(
                      image: AssetImage('assets/images/Projeto-IntelliMen-217x122.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                
                // Overlay for better text visibility
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
                  ),
                ),
                
                // Completion indicator
                if (isCompleted)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                
                // Challenge title
                Positioned(
                  bottom: 8,
                  left: 8,
                  right: 8,
                  child: Text(
                    challenge.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          
          // Description
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                challenge.description,
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 12,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          
          // Access button
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(8, 0, 8, 8),
            child: ElevatedButton(
              onPressed: () {
                _showChallengeDetails(challenge);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2A2A2A), // Cor mais escura para o botão
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                padding: const EdgeInsets.symmetric(vertical: 8),
                elevation: 2,
              ),
              child: const Text(
                'ACESSAR',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showChallengeDetails(ChallengeModel challenge) {
    final isCompleted = _isChallengeCompleted(challenge.id);
    final isPending = _isChallengePending(challenge.id);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            if (isCompleted)
              Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            Expanded(
              child: Text(
                challenge.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Challenge image
              Container(
                width: double.infinity,
                height: 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: const DecorationImage(
                    image: AssetImage('assets/images/Projeto-IntelliMen-217x122.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Description
              Text(
                challenge.description,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
              
              // Status
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isCompleted 
                      ? Colors.green.withOpacity(0.2)
                      : isPending 
                          ? Colors.orange.withOpacity(0.2)
                          : Colors.grey.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  isCompleted 
                      ? 'CONCLUÍDO'
                      : isPending 
                          ? 'EM ANDAMENTO'
                          : 'NÃO INICIADO',
                  style: TextStyle(
                    color: isCompleted 
                        ? Colors.green
                        : isPending 
                            ? Colors.orange
                            : Colors.grey,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'FECHAR',
              style: TextStyle(color: Colors.white),
            ),
          ),
          if (!isCompleted)
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _startChallenge(challenge);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: const Text('INICIAR DESAFIO'),
            ),
        ],
      ),
    );
  }

  void _startChallenge(ChallengeModel challenge) {
    // Implementar lógica para iniciar o desafio
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Iniciando desafio: ${challenge.title}'),
        backgroundColor: Colors.green,
      ),
    );
  }
} 