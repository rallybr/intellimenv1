import 'package:flutter/material.dart';
import 'package:intellimen/features/welcome/presentation/pages/welcome_home_page.dart';
import 'package:intellimen/core/constants/welcome_constants.dart';

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

class PerfilAcademyPage extends StatelessWidget {
  const PerfilAcademyPage({super.key});

  @override
  Widget build(BuildContext context) {
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
                const SizedBox(height: 170), // espaço para header e foto flutuante
                _buildProfileCard(context),
                const SizedBox(height: 24),
                _buildDesafiosCarrossel(context),
                const SizedBox(height: 24),
                _buildReflexaoCard(),
                const SizedBox(height: 24),
                _buildAddButton(),
                const SizedBox(height: 24),
                _buildQuizCarrossel(context),
                const SizedBox(height: 100), // espaço extra para bottom nav bar
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavBar(context),
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
            child: Image.asset('assets/logos/logo-academy.png', height: 80),
          ),
          GestureDetector(
            onTap: () {
              // TODO: Implementar menu lateral
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Menu em desenvolvimento'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.menu, color: Colors.white, size: 32),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        // Card
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 24), // menos espaço no topo
          decoration: BoxDecoration(
            color: const Color(0xFFEE0E0E0),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.10),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            children: [
              const SizedBox(height: 40), // espaço para a foto sobreposta
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'João Fidelis',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF232323),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.verified_rounded,
                    color: Color(0xFFE65100), // laranja escuro
                    size: 28,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.location_on, color: Colors.black54, size: 20),
                  SizedBox(width: 4),
                  Text('São Paulo', style: TextStyle(fontSize: 18, color: Colors.black54)),
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
                      // TODO: Implementar funcionalidade de desafio
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
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFFEF6C00), // laranja claro
                            Color(0xFFE65100), // laranja escuro
                            Color(0xFFFF3D00), // laranja profundo
                            Color(0xFFDD2C00), // marrom vermelho
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.25),
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
          top: -70, // flutua a foto sobre o topo do card
          child: GestureDetector(
            onTap: () {
              // TODO: Implementar visualização da foto em tela cheia
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Visualizar foto em tela cheia'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(5), // largura da borda
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFEF6C00), // laranja claro
                    Color(0xFFE65100), // laranja escuro
                    Color(0xFFFF3D00), // laranja profundo
                    Color(0xFFDD2C00), // marrom vermelho
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
                  'https://randomuser.me/api/portraits/men/11.jpg',
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
            color: Colors.black.withValues(alpha: 0.12),
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
                progresso: progresso1,
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
                progresso: progresso2,
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
    required int progresso,
    required int total,
    required bool concluido,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(3),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                Color(0xFFEF6C00), // laranja claro
                Color(0xFFE65100), // laranja escuro
                Color(0xFFFF3D00), // laranja profundo
                Color(0xFFDD2C00), // marrom vermelho
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
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
            value: progresso / total,
            backgroundColor: Colors.grey[200],
            color: concluido ? Colors.green : Colors.red,
            minHeight: 20, // altura maior
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$progresso de $total',
          style: const TextStyle(fontSize: 14, color: Colors.black87),
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
    final bool user1NaFrente = pontos1 > pontos2;
    final bool empate = pontos1 == pontos2;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFEE0E0E0),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF0A3D91), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const Text(
            'BIBLE QUIZ',
            style: TextStyle(
              fontFamily: 'RobotoMono',
              fontWeight: FontWeight.w900,
              fontSize: 26,
              letterSpacing: 2,
              color: Color(0xFF232323),
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            'CONFRONTO DIRETO',
            style: TextStyle(
              fontSize: 15,
              color: Color(0xFF232323),
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _buildQuizPerfil(
                nome: nome1,
                url: url1,
                pontos: pontos1,
                total: total,
                cor: Colors.green,
              )),
              Container(
                width: 2,
                height: 80,
                color: Colors.grey[300],
                margin: const EdgeInsets.symmetric(horizontal: 8),
              ),
              Expanded(child: _buildQuizPerfil(
                nome: nome2,
                url: url2,
                pontos: pontos2,
                total: total,
                cor: Colors.red,
              )),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!empate)
                Text(
                  user1NaFrente
                      ? '@${nome1.toLowerCase().replaceAll(' ', '')} está na frente'
                      : '@${nome2.toLowerCase().replaceAll(' ', '')} está na frente',
                  style: const TextStyle(
                    color: Color(0xFFFF8800),
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    letterSpacing: 1.1,
                  ),
                )
              else
                const Text(
                  'Empate!'
                  ,
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
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
    required Color cor,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(3),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                Color(0xFFEF6C00), // laranja claro
                Color(0xFFE65100), // laranja escuro
                Color(0xFFFF3D00), // laranja profundo
                Color(0xFFDD2C00), // marrom vermelho
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: CircleAvatar(
            backgroundImage: NetworkImage(url),
            radius: 32,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          nome,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: LinearProgressIndicator(
            value: pontos / total,
            backgroundColor: Colors.grey[200],
            color: cor,
            minHeight: 20,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '$pontos de $total',
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
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
                color: Colors.black.withValues(alpha: 0.10),
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
            color: Colors.black.withValues(alpha: 0.12),
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
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22),
                        ),
                        elevation: 0,
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
                      child: Ink(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color(0xFFEF6C00), // laranja claro
                              Color(0xFFE65100), // laranja escuro
                              Color(0xFFFF3D00), // laranja profundo
                              Color(0xFFDD2C00), // marrom vermelho
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: Container(
                          alignment: Alignment.center,
                          child: const Text(
                            'LEIA MAIS',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              letterSpacing: 1.2,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
          Positioned(
            top: 0,
            right: 0,
            child: Builder(
              builder: (context) => PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Color(0xFF232323)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                onSelected: (value) {
                  if (value == 'Editar') {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Editar reflexão (em breve)')),
                    );
                  } else if (value == 'Excluir') {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Excluir reflexão (em breve)')),
                    );
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'Editar',
                    child: Text('Editar'),
                  ),
                  const PopupMenuItem(
                    value: 'Excluir',
                    child: Text('Excluir'),
                  ),
                ],
              ),
            ),
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
            color: Colors.black.withValues(alpha: 0.15),
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
} 