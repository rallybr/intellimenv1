import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intellimen/features/welcome/presentation/pages/welcome_home_page.dart';

class ManifestoPage extends StatefulWidget {
  const ManifestoPage({super.key});

  @override
  State<ManifestoPage> createState() => _ManifestoPageState();
}

class _ManifestoPageState extends State<ManifestoPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController _mainScrollController = ScrollController();
  final ScrollController _manifestoScrollController = ScrollController();

  @override
  void dispose() {
    _mainScrollController.dispose();
    _manifestoScrollController.dispose();
    super.dispose();
  }

  Widget _buildBackgroundImage() {
    return Positioned.fill(
      child: IgnorePointer(
        child: Image.asset(
          'assets/images/manifesto-bg.jpg',
          fit: BoxFit.cover,
          alignment: Alignment.center,
          color: Colors.black.withOpacity(0.7),
          colorBlendMode: BlendMode.darken,
          errorBuilder: (context, error, stackTrace) {
            // Fallback para outra imagem se a primeira falhar
            return Image.asset(
              'assets/images/bg-intellimen.jpg',
              fit: BoxFit.cover,
              alignment: Alignment.center,
              color: Colors.black.withOpacity(0.7),
              colorBlendMode: BlendMode.darken,
              errorBuilder: (context, error, stackTrace) {
                // Fallback final - fundo preto simples
                return Container(
                  color: Colors.black,
                  child: const Center(
                    child: Icon(
                      Icons.error,
                      color: Colors.white,
                      size: 48,
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.black87),
              child: Text('Menu', style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
            ListTile(
              leading: const Icon(Icons.arrow_back),
              title: const Text('Voltar para o início'),
              onTap: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const WelcomeHomePage()),
                  (route) => false,
                );
              },
            ),
          ],
        ),
      ),
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Imagem de fundo com blend
          _buildBackgroundImage(),
          SingleChildScrollView(
            controller: _mainScrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                SafeArea(
                  child: Container(
                    // Remover a cor de fundo para deixar transparente
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            // Ícone de menu com ação para abrir o Drawer
                            IconButton(
                              icon: const Icon(Icons.menu, color: Colors.white, size: 32),
                              onPressed: () {
                                _scaffoldKey.currentState?.openDrawer();
                              },
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'MENU',
                              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w400, letterSpacing: 1.2),
                            ),
                          ],
                        ),
                        Image.asset(
                          'assets/logos/logo-intellimen.png',
                          height: 38,
                          fit: BoxFit.contain,
                        ),
                      ],
                    ),
                  ),
                ),
                // Remover qualquer SizedBox ou Padding entre header e título
                Text(
                  'MANIFESTO',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Container(
                  width: 60,
                  height: 1,
                  color: Colors.white,
                ),
                const SizedBox(height: 24),
                // REMOVIDO O BLOCO DE PERGUNTA E BOTÕES DAQUI
                // Card do Manifesto
                Container(
                  constraints: const BoxConstraints(
                    maxHeight: 320,
                    minWidth: double.infinity,
                  ),
                  margin: const EdgeInsets.only(top: 8),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.white24, width: 1),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Título removido conforme solicitado
                      Expanded(
                        child: Scrollbar(
                          controller: _manifestoScrollController,
                          thumbVisibility: true,
                          child: SingleChildScrollView(
                            controller: _manifestoScrollController,
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                RichText(
                                  textAlign: TextAlign.justify,
                                  text: const TextSpan(
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      height: 1.6,
                                      letterSpacing: 0.5,
                                    ),
                                    children: [
                                      TextSpan(text: 'Ser homem antigamente era algo muito simples. Você aprendia duas coisas desde cedo: lutar para se defender e caçar para se alimentar. Quem fazia isso muito bem, se dava muito bem. E levava a garota para casa.\n\nEsse era o critério básico quando o pai considerava um rapaz para casar com sua filha. E ela também. Em muitos casos, amor era secundário. Você não ouvia mulheres detalhando uma longa lista de atributos que queriam no futuro marido: "Ele tem que ser carinhoso, bem humorado, gostar de passear, romântico, atencioso, cheirar bem, amar os animais, me aceitar como eu sou, me pegar no colo quando eu estiver cansada, notar quando eu mudar o meu cabelo, sensível, bom de conversa, amigo, se vestir bem…"\n\nNada disso.\n"Você pode e está pronto para me proteger com a sua vida? Pode me sustentar tão bem quanto ou melhor que o meu pai? Então ponha um anel aqui…" Simples assim.\n\nSer homem no século 21 já é outra história. O mundo mudou. As mulheres mudaram. E muitos homens ainda estão com a cabeça lá atrás. O resultado disso está aí para ser assistido em 3D: homens Deslocados, Despreparados e Desacreditados.\n\n'),
                                      TextSpan(text: 'Apresentando o Intellimen', style: TextStyle(fontWeight: FontWeight.bold)),
                                      TextSpan(text: '\nVocê já deve ter sacado que o nome do projeto é uma junção das palavras em inglês intelligent (inteligentes) e men (homens). Escolhemos esse nome porque além de soar como um super-herói, que todo homem secretamente aspira ser desde criança, ele engloba tudo o que o projeto aspira: formar homens inteligentes e melhores em tudo. Não prometemos superpoderes como levantar ônibus com um dedo, voar ou invisibilidade — mas estamos trabalhando nisso.\n\nPor enquanto, o projeto focará em formar homens melhores de 8 a 88 anos (depois disso amigo, talvez seja melhor você aceitar que já está bem formadinho e que a forma não vai mais melhorar… Mas se quiser tentar, sempre há lugar para mais um 🙂\n\nFormar homens melhores será o nosso lema. Ser homens inteligentes nossa missão. Vamos caminhar juntos, aprender uns com os outros. Mas espere DESAFIOS. Nós vamos lhe desafiar a ser melhor em todas as áreas de sua vida. E para ser um dos IntelliMen, você nunca poderá fugir dos desafios nem deixar de cumpri-los. E acima de tudo, precisará do ingrediente fundamental para aprender: humildade. Se você não reconhece que precisa melhorar, não podemos lhe ajudar. Ainda que você já seja forte e bem sucedido em muitas coisas, é preciso entender que:'),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 18),
                                // Versículo destacado
                                Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  decoration: BoxDecoration(
                                    color: Color(0xFFE0E0E0),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 6,
                                        height: 40,
                                        color: Colors.black,
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                          child: Text(
                                            'O homem não prevalece pela força.\n1 Samuel 2.9',
                                            style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 16,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'É preciso mais que músculos para ser homem. Caráter, inteligência e fé são muito mais importantes.',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontStyle: FontStyle.italic,
                                    height: 1.5,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Adicionar espaçamento de 20px entre o card e o título do FAQ
                const SizedBox(height: 30),
                // Título do FAQ
                const Text(
                  'Vamos então agora às perguntas básicas sobre o projeto e como participar.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                // FAQ Accordion
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 32),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: _ManifestoFAQ(),
                ),
                // Card de Condições de Participação
                Container(
                  constraints: const BoxConstraints(
                    maxHeight: 320,
                    minWidth: double.infinity,
                  ),
                  margin: const EdgeInsets.only(top: 8, bottom: 32),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.white24, width: 1),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 16, left: 18, right: 18, bottom: 8),
                        child: Text(
                          'CONDIÇÕES DE PARTICIPAÇÃO',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Expanded(
                        child: Scrollbar(
                          thumbVisibility: true,
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                            child: Text(
                              'Condições de participação\n'
                              '– Ser humilde para aprender e ser orientado pelo grupo.\n'
                              '– Ter total comprometimento com a realização de todas as tarefas e desafios nos prazos determinados.\n'
                              '– Praticar o espírito de compartilhar, especialmente sendo atuante nas redes sociais e blog do grupo.\n'
                              '– Fazer seu melhor esforço para comparecer aos eventos oficiais do grupo na sua área que poderão ocorrer de tempo em tempo. (A princípio, a participação será basicamente através da Internet, mas encontros presenciais estão nos planos.)\n'
                              '– Manter o respeito e bom humor com todos no grupo.\n'
                              '– Representar bem o grupo a todo o tempo, dando bom exemplo de comportamento e caráter.\n'
                              '– Promover o grupo para que outros homens fiquem sabendo e possam participar também — começando com a escolha de um Parceiro Oficial (explicado no Desafio #1)\n'
                              '– Se você tem críticas construtivas para os organizadores do grupo, são bem-vindas. Porém, comentários com a intenção de denegrir o grupo resultará na sua exclusão.\n'
                              '– Isso mesmo, reservamos o direito de lhe excluir com ou sem explicação. Porém, esperamos nunca ter de usar esse direito.\n'
                              '– Se for começar, é para terminar. São 52 Desafios, um por semana, por um ano. Se não estiver disposto, não comece. Aqui, desistência não é inteligência.\n\n'
                              'Usando o nome do grupo corretamente\n'
                              'IntelliMen — com dois eles “ll” e o M maiúsculo no meio do nome. Certifique-se de usar o nome corretamente.\n\n'
                              'Atenção para uma variante importante do nome. Homens em inglês, no plural, é “Men” — e Homem, no singular, é “Man”. Portanto, quando se referir ao grupo, use sempre IntelliMen. Mas quando for se referir a apenas um membro do grupo, use sempre IntelliMan. Por exemplo:\n\n'
                              '– Eu faço parte do IntelliMen.\n'
                              '– Eu sou um IntelliMan.\n\n'
                              'Há também uma pequena diferença na pronúncia, mas não se preocupe com isso agora. Essa aulinha fica para depois…\n\n'
                              'Está pronto para se tornar um IntelliMan e se juntar ao IntelliMen? Então aceite os termos deste manifesto clicando no inicio ou no fim dessa página, cadastre-se no site e vamos ao primeiro desafio!',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                height: 1.6,
                                letterSpacing: 0.5,
                              ),
                              textAlign: TextAlign.justify,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Card de redes sociais oficiais
                // ANTES DESTE CARD, ADICIONAR O BLOCO DE PERGUNTA E BOTÕES
                // Bloco de pergunta e botões movido para cá
                const SizedBox(height: 24),
                const Text(
                  'VOCÊ ACEITA TODOS OS TERMOS DO MANIFESTO E DESEJA\nSE TORNAR UM HOMEM MELHOR?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 36),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 150, // largura reduzida
                      height: 54,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3CB371),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          minimumSize: const Size(0, 54),
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                        ),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Você aceitou o manifesto!')),
                          );
                        },
                        child: const Text(
                          'SIM, ACEITO',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                        ),
                      ),
                    ),
                    const SizedBox(width: 24),
                    SizedBox(
                      width: 150, // largura reduzida
                      height: 54,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEB4A4A),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          minimumSize: const Size(0, 54),
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                        ),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Você não aceitou o manifesto.')),
                          );
                        },
                        child: const Text(
                          'NÃO, NÃO ACEITO',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 36),
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 32, top: 8),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.white24, width: 1),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 18),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        'Nossos sites oficiais:',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.facebook, color: Colors.white, size: 32),
                            onPressed: () async {
                              final url = Uri.parse('https://www.facebook.com/intellimen');
                              if (await canLaunchUrl(url)) {
                                await launchUrl(url, mode: LaunchMode.externalApplication);
                              }
                            },
                            tooltip: 'Facebook',
                          ),
                          const SizedBox(width: 24),
                          IconButton(
                            icon: const Icon(Icons.alternate_email, color: Colors.white, size: 32),
                            onPressed: () async {
                              final url = Uri.parse('https://www.twitter.com/intellimen27');
                              if (await canLaunchUrl(url)) {
                                await launchUrl(url, mode: LaunchMode.externalApplication);
                              }
                            },
                            tooltip: 'Twitter',
                          ),
                          const SizedBox(width: 24),
                          IconButton(
                            icon: const Icon(Icons.language, color: Colors.white, size: 32),
                            onPressed: () async {
                              final url = Uri.parse('https://www.renatocardoso.com');
                              if (await canLaunchUrl(url)) {
                                await launchUrl(url, mode: LaunchMode.externalApplication);
                              }
                            },
                            tooltip: 'Site oficial',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Accordion FAQ Widget
class _ManifestoFAQ extends StatefulWidget {
  @override
  State<_ManifestoFAQ> createState() => _ManifestoFAQState();
}

class _ManifestoFAQState extends State<_ManifestoFAQ> {
  int _openIndex = -1;

  final List<Map<String, String>> _faq = [
    {
      'question': '1. O que é o IntelliMen?',
      'answer': 'É um grupo exclusivamente para homens que querem ser melhores em todas as áreas de sua vida. Homens ajudando homens, compartilhando o que é bom, trabalhando duro para melhorar a cada dia — e se divertindo enquanto o fazem',
    },
    {
      'question': '2. Quem pode participar?',
      'answer': 'Homens de qualquer idade que estejam dispostos a se submeterem às regras do grupo, detalhadas em nosso Manifesto.',
    },
    {
      'question': '3. Como posso participar?',
      'answer': 'Ler todo este Manifesto com atenção, entender as condições, comprometer-se com o projeto, cadastrar-se no site e cumprir os Desafios já disponibilizados semanalmente.',
    },
    {
      'question': '4. Quando vai começar?',
      'answer': 'Só depende de você. Se você está entrando no grupo agora, saiba que você deve começar desde o início, fazendo o primeiro Desafio.',
    },
    {
      'question': '5. Onde posso participar?',
      'answer': 'Em qualquer lugar do mundo. O IntelliMen não está limitado a uma cidade, estado ou país. Basta que você tenha acesso pela Internet aos sites do grupo.',
    },
    {
      'question': '6. O que tenho que fazer agora?',
      'answer': 'Ler as Condições de Participação abaixo, e se aceitá-las, cadastrar-se no site e começar imediatamente a fazer o primeiro Desafio.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Removido o ListView.builder, substituído por Column
        ..._faq.asMap().entries.map((entry) {
          final i = entry.key;
          final faq = entry.value;
          final isOpen = _openIndex == i;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 1.5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                GestureDetector(
                  onTap: () => setState(() => _openIndex = _openIndex == i ? -1 : i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: isOpen ? const Color(0xFF464545) : const Color(0xFF464545),
                      borderRadius: BorderRadius.vertical(
                        top: const Radius.circular(5),
                        bottom: Radius.circular(isOpen ? 0 : 5),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    child: Text(
                      faq['question']!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                if (isOpen)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(5)),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: Text(
                      faq['answer']!,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                        height: 1.5,
                      ),
                    ),
                  ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }
} 