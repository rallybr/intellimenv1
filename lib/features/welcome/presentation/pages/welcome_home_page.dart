import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/welcome_constants.dart';
import 'dart:async'; // Import para Timer
import '../../../profile/presentation/pages/perfil_intellimen.dart';
import 'manifesto_page.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../../../auth/presentation/pages/signup_page.dart';
import '../../../auth/presentation/pages/complete_profile_page.dart';
import 'package:intellimen/shared/models/user_model.dart';

class WelcomeHomePage extends StatefulWidget {
  const WelcomeHomePage({super.key});

  @override
  State<WelcomeHomePage> createState() => _WelcomeHomePageState();
}

class _WelcomeHomePageState extends State<WelcomeHomePage> {
  int _selectedTab = 1; // 0: Academy, 1: IntelliMen, 2: Campus
  int _currentBanner = 0;
  bool _isLoading = false;
  String? _errorMessage;

  // Usar constantes do WelcomeConstants

  // Controller e timer para o carrossel automático
  final ScrollController _avatarScrollController = ScrollController();
  final PageController _bannerPageController = PageController();
  Timer? _avatarScrollTimer;
  Timer? _bannerScrollTimer;
  bool _isAvatarHovered = false;

  // Lista de banners
  final List<Map<String, dynamic>> _banners = [
    {
      'title': 'ACEITE O DESAFIO',
      'subtitle': 'CLIQUE AQUI PARA LER O MANIFESTO E PARTICIPE!',
      'image': WelcomeConstants.bannerImage,
    },
    {
      'title': 'COMUNIDADE INTELIMEN',
      'subtitle': 'CONECTE-SE COM OUTROS HOMENS INTELIGENTES',
      'image': WelcomeConstants.bannerImage,
    },
    {
      'title': 'DESENVOLVIMENTO PESSOAL',
      'subtitle': 'CRESÇA JUNTO COM NOSSA COMUNIDADE',
      'image': WelcomeConstants.bannerImage,
    },
    {
      'title': 'LIDERANÇA E PROPÓSITO',
      'subtitle': 'DESCUBRA SEU VERDADEIRO POTENCIAL',
      'image': WelcomeConstants.bannerImage,
    },
  ];

  @override
  void initState() {
    super.initState();
    _startAvatarAutoScroll();
    _startBannerAutoScroll();
  }

  void _startAvatarAutoScroll() {
    _avatarScrollTimer?.cancel();
    _avatarScrollTimer = Timer.periodic(const Duration(milliseconds: 40), (_) {
      if (_avatarScrollController.hasClients) {
        final maxScroll = _avatarScrollController.position.maxScrollExtent;
        final current = _avatarScrollController.offset;
        double next = current + 1.0;
        if (next >= maxScroll) {
          // Volta para o início suavemente
          _avatarScrollController.jumpTo(0);
        } else {
          _avatarScrollController.jumpTo(next);
        }
      }
    });
  }

  void _startBannerAutoScroll() {
    _bannerScrollTimer?.cancel();
    _bannerScrollTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (_bannerPageController.hasClients) {
        final nextPage = (_currentBanner + 1) % _banners.length;
        _bannerPageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
        setState(() {
          _currentBanner = nextPage;
        });
      }
    });
  }

  // Pausar e retomar o carrossel
  void _pauseAvatarAutoScroll() {
    if (!_isAvatarHovered) {
      _isAvatarHovered = true;
      _avatarScrollTimer?.cancel();
    }
  }
  void _resumeAvatarAutoScroll() {
    if (_isAvatarHovered) {
      _isAvatarHovered = false;
      _startAvatarAutoScroll();
    }
  }

  @override
  void dispose() {
    _avatarScrollTimer?.cancel();
    _bannerScrollTimer?.cancel();
    _avatarScrollController.dispose();
    _bannerPageController.dispose();
    super.dispose();
  }

  Widget _buildStatusBarBackground(BuildContext context) {
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).padding.top,
      color: Colors.black,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.black,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppColors.primary,
        body: Stack(
          children: [
            _buildStatusBarBackground(context),
            _buildBackgroundImage(),
            _buildMainContent(),
            _buildBottomNavigation(),
            _buildLoadingOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildBackgroundImage() {
    return Positioned.fill(
      child: Image.asset(
        WelcomeConstants.backgroundImage,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildMainContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 90),
      child: Column(
        children: [
          _buildHeader(),
          _buildAvatarCarousel(),
          _buildTabNavigation(),
          _buildContentCard(),
          _buildBannerSlider(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return SafeArea(
      bottom: false,
              child: Container(
          color: Colors.black,
          padding: WelcomeConstants.headerPadding,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Center(
                  child: Image.asset(
                    WelcomeConstants.logoImage,
                    height: WelcomeConstants.headerHeight,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            IconButton(
              icon: const Icon(Icons.menu, color: Colors.white, size: 32),
              onPressed: () => _showMenuOptions(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarCarousel() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0),
      child: MouseRegion(
        onEnter: (_) => _pauseAvatarAutoScroll(),
        onExit: (_) => _resumeAvatarAutoScroll(),
        child: SizedBox(
          height: WelcomeConstants.avatarRadius * 2 + 16 + 15, // 80 + 10(top) + 5(bottom)
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Fundo preenchendo toda a área entre as linhas
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Color(0xFF333333),
                      Color(0xFF434343),
                      Color(0xFF333333),
                    ],
                  ),
                ),
              ),
              _buildGradientLine(Alignment.topCenter),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: ListView.builder(
                    controller: _avatarScrollController,
                    scrollDirection: Axis.horizontal,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    itemCount: 10000, // Repete infinitamente
                    itemBuilder: (context, index) => _buildAvatarItem(index % WelcomeConstants.avatarUrls.length),
                  ),
                ),
              ),
              _buildGradientLine(Alignment.bottomCenter),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGradientLine(Alignment alignment) {
    return Align(
      alignment: alignment,
      child: Container(
        height: 2, // Espessura reduzida para 2px
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: WelcomeConstants.gradientColors,
          ),
        ),
      ),
    );
  }



  Widget _buildAvatarItem(int index) {
    return MouseRegion(
      onEnter: (_) => _pauseAvatarAutoScroll(),
      onExit: (_) => _resumeAvatarAutoScroll(),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 14),
        child: SizedBox(
          height: WelcomeConstants.avatarRadius * 2 + 16,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: WelcomeConstants.avatarRadius,
                backgroundColor: Colors.white,
                child: CircleAvatar(
                  radius: WelcomeConstants.avatarInnerRadius,
                  backgroundColor: const Color(0xFFE3F6FF),
                  backgroundImage: NetworkImage(WelcomeConstants.avatarUrls[index]),
                ),
              ),
              const SizedBox(height: 2),
              Expanded(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: SizedBox(
                    width: WelcomeConstants.avatarRadius * 2 + 10,
                    child: Text(
                      WelcomeConstants.avatarNames[index],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        shadows: [Shadow(blurRadius: 2, color: Colors.black)],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 5),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabNavigation() {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        // Linha sólida 1px abaixo das tabs
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 1), // Espaço de 1px
              Container(
                height: 1,
                color: const Color(0xFFD81B60),
              ),
            ],
          ),
        ),
        // As tabs
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (int i = 0; i < 3; i++)
                    Expanded(
                      flex: i == 1 ? 6 : 4,
                      child: Padding(
                        padding: EdgeInsets.only(
                          top: i == 1 ? 22 : 10,
                          bottom: 0,
                          left: i == 0 ? 8 : 3,
                          right: i == 2 ? 8 : 3,
                        ),
                        child: _buildTabButton(i),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Não precisa mais do gradiente para a linha das tabs
  Widget _buildTabGradientLine() {
    return const SizedBox.shrink();
  }

  Widget _buildTabButtons() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (int i = 0; i < 3; i++)
          Expanded(
            flex: i == 1 ? 6 : 4,
            child: Padding(
              padding: EdgeInsets.only(
                top: i == 1 ? 22 : 10,
                bottom: 10,
                left: 8,
                right: 8,
              ),
              child: _buildTabButton(i),
            ),
          ),
      ],
    );
  }

  Widget _buildTabButton(int index) {
    final isSelected = _selectedTab == index;
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: 10,
            horizontal: index == 1 ? 20 : 8,
          ),
          decoration: BoxDecoration(
            gradient: isSelected
                ? null
                : LinearGradient(
                    colors: WelcomeConstants.tabGradients[index],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
            color: isSelected ? const Color(0xFFE5F7FF) : null,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(index == 0 ? WelcomeConstants.tabBorderRadius : WelcomeConstants.tabBorderRadius),
              topRight: Radius.circular(index == 2 ? WelcomeConstants.tabBorderRadius : WelcomeConstants.tabBorderRadius),
              bottomLeft: const Radius.circular(0),
              bottomRight: const Radius.circular(0),
            ),
            boxShadow: isSelected ? WelcomeConstants.tabShadow : [],
          ),
          child: Center(
            child: Text(
              WelcomeConstants.tabLabels[index],
              style: TextStyle(
                color: isSelected ? const Color(0xFF232323) : Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: index == 1 ? 20 : 16, // INTELLIMEN maior
                letterSpacing: 2,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Resumos para os cards principais
  static const String _resumoAcademy =
      'O Academy é a área de formação avançada do projeto, voltada para quem deseja se aprofundar em temas de liderança, propósito e desenvolvimento pessoal. Aqui você encontra conteúdos exclusivos, desafios especiais e acompanhamento.';
  static const String _resumoIntellimen =
      'Você já deve ter sacado que o nome do projeto é uma junção das palavras em inglês intelligent (inteligentes) e men (homens). Escolhemos esse nome porque além de soar como um super-herói, que todo homem secretamente aspira ser...';
  static const String _resumoCampus =
      'Você já conhece o IntelliMen Campus? Trata-se de um projeto com a missão de forjar rapazes entre 18 e 25 anos para que tenham um espírito excelente, assim como foi com o profeta Daniel, na Bíblia.';

  Widget _buildContentCard() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 3, 16, 1), // 5px em cima (3+2), 1px embaixo
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0x80333333), // #333333 com 50% de opacidade
          border: Border.all(color: const Color(0xFF546E7A), width: 1),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(0),
            topRight: Radius.circular(0),
            bottomLeft: Radius.circular(42),
            bottomRight: Radius.circular(42),
          ),
          boxShadow: WelcomeConstants.cardShadow,
        ),
        child: Padding(
          padding: WelcomeConstants.cardPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildContentTitleWhite(),
              const SizedBox(height: 20),
              _buildContentDescriptionResumo(),
              const SizedBox(height: 18),
              _buildActionButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContentTitleWhite() {
    final title = WelcomeConstants.tabContents[_selectedTab]['title']!;
    final isIntelliMen = _selectedTab == 1;
    final isCampus = _selectedTab == 2;
    final isAcademy = _selectedTab == 0;
    return Text.rich(
      TextSpan(
        children: [
          if (isAcademy)
            ...[
              TextSpan(
                text: 'O que é o ',
                style: WelcomeConstants.titleStyle.copyWith(color: Colors.white),
              ),
              TextSpan(
                text: 'Academy',
                style: WelcomeConstants.titleBoldStyle.copyWith(color: Colors.white),
              ),
              TextSpan(
                text: '?',
                style: WelcomeConstants.titleStyle.copyWith(color: Colors.white),
              ),
            ]
          else if (isCampus)
            ...[
              TextSpan(
                text: 'O que é o ',
                style: WelcomeConstants.titleStyle.copyWith(color: Colors.white),
              ),
              TextSpan(
                text: 'Campus',
                style: WelcomeConstants.titleBoldStyle.copyWith(color: Colors.white),
              ),
              TextSpan(
                text: '?',
                style: WelcomeConstants.titleStyle.copyWith(color: Colors.white),
              ),
            ]
          else ...[
            TextSpan(
              text: isIntelliMen ? title.split('IntelliMen')[0] : title,
              style: WelcomeConstants.titleStyle.copyWith(color: Colors.white),
            ),
            if (isIntelliMen)
              TextSpan(
                text: 'IntelliMen',
                style: WelcomeConstants.titleBoldStyle.copyWith(color: Colors.white),
              ),
          ],
        ],
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildContentDescriptionWhite() {
    return Text(
      WelcomeConstants.tabContents[_selectedTab]['desc']!,
      style: WelcomeConstants.descriptionStyle.copyWith(color: Colors.white),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildContentDescriptionResumo() {
    // Mostra o resumo de acordo com a aba selecionada
    if (_selectedTab == 0) {
      return Text(
        _resumoAcademy,
        style: WelcomeConstants.descriptionStyle.copyWith(color: Colors.white),
        textAlign: TextAlign.center,
      );
    } else if (_selectedTab == 1) {
      return Text(
        _resumoIntellimen,
        style: WelcomeConstants.descriptionStyle.copyWith(color: Colors.white),
        textAlign: TextAlign.center,
      );
    } else if (_selectedTab == 2) {
      return Text(
        _resumoCampus,
        style: WelcomeConstants.descriptionStyle.copyWith(color: Colors.white),
        textAlign: TextAlign.center,
      );
    } else {
      return _buildContentDescriptionWhite();
    }
  }

  Widget _buildActionButton() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: SizedBox(
        width: 120,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(WelcomeConstants.buttonBorderRadius),
            ),
            padding: const EdgeInsets.symmetric(vertical: 10),
            elevation: 4,
          ),
          onPressed: () => _handleActionButton(),
          child: Text(
            'SAIBA MAIS',
            style: WelcomeConstants.buttonTextStyle,
          ),
        ),
      ),
    );
  }

  Widget _buildBannerSlider() {
    return Padding(
      padding: WelcomeConstants.bannerPadding,
      child: SizedBox(
        height: WelcomeConstants.bannerHeight,
        child: Stack(
          children: [
            _buildBannerPageView(),
            _buildBannerIndicators(),
          ],
        ),
      ),
    );
  }

  Widget _buildBannerPageView() {
    return PageView.builder(
      controller: _bannerPageController,
      onPageChanged: (index) {
        setState(() {
          _currentBanner = index;
        });
      },
      itemCount: _banners.length,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          child: Stack(
            children: [
              _buildBannerBackground(index),
              _buildBannerOverlay(),
              _buildBannerContent(index),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBannerBackground(int index) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(WelcomeConstants.bannerBorderRadius),
        image: DecorationImage(
          image: AssetImage(_banners[index]['image']),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildBannerOverlay() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(WelcomeConstants.bannerBorderRadius),
        color: Colors.black.withValues(alpha: 0.5),
      ),
    );
  }

  Widget _buildBannerContent(int index) {
    return Positioned.fill(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _banners[index]['title']!,
            style: WelcomeConstants.bannerTitleStyle,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            _banners[index]['subtitle']!,
            style: WelcomeConstants.bannerSubtitleStyle,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(WelcomeConstants.buttonBorderRadius),
              ),
            ),
            onPressed: () => _handleBannerAction(index),
            child: const Text('SAIBA MAIS'),
          ),
        ],
      ),
    );
  }

  Widget _buildBannerIndicators() {
    return Positioned(
      bottom: 12,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(_banners.length, (index) => Container(
          width: 10,
          height: 10,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: _currentBanner == index ? Colors.pinkAccent : Colors.white24,
            shape: BoxShape.circle,
          ),
        )),
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        height: WelcomeConstants.bottomNavHeight,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.black,
          boxShadow: WelcomeConstants.bottomNavShadow,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
              _buildNavIcon(Icons.home, WelcomeConstants.navIconColors[0]),
              _buildNavIcon(Icons.search, WelcomeConstants.navIconColors[1]),
              _buildCentralNavButton(),
              _buildNavIcon(Icons.ondemand_video, WelcomeConstants.navIconColors[2]),
              _buildProfileAvatar(),
            ],
        ),
      ),
    );
  }

  Widget _buildNavIcon(IconData icon, Color color) {
    return GestureDetector(
      onTap: () => _handleNavIconTap(icon),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 32),
      ),
    );
  }

  Widget _buildCentralNavButton() {
    return GestureDetector(
      onTap: () => _handleCentralNavTap(),
      child: Container(
        height: WelcomeConstants.centralNavButtonSize,
        width: WelcomeConstants.centralNavButtonSize,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFF232343), width: 6),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
            ),
          ],
        ),
        child: const Center(
          child: Icon(Icons.add, color: Color(0xFF232343), size: 38),
        ),
      ),
    );
  }

  Widget _buildProfileAvatar() {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const PerfilIntellimenPage(),
          ),
        );
      },
      child: CircleAvatar(
        radius: WelcomeConstants.profileAvatarRadius,
        backgroundImage: NetworkImage(WelcomeConstants.defaultAvatarUrl),
      ),
    );
  }

  // Métodos de ação
  void _showMenuOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildMenuSheet(),
    );
  }

  Widget _buildMenuSheet() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF232323),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[600],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          _buildMenuItem(Icons.login, 'Entrar', () => _handleLoginTap()),
          _buildMenuItem(Icons.person_add, 'Criar Conta', () => _handleSignupTap()),
          _buildMenuItem(Icons.assignment_ind, 'Completar Perfil', () => _handleCompleteProfileTap()),
          _buildMenuItem(Icons.person, 'Perfil', () => _handleProfileTap()),
          _buildMenuItem(Icons.settings, 'Configurações', () => _handleSettingsTap()),
          _buildMenuItem(Icons.help, 'Ajuda', () => _handleHelpTap()),
          _buildMenuItem(Icons.info, 'Sobre', () => _handleAboutTap()),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.white, size: 24),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
    );
  }

  void _handleSettingsTap() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Abrindo configurações...')),
    );
  }

  void _handleHelpTap() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Abrindo ajuda...')),
    );
  }

  void _handleAboutTap() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Abrindo informações sobre o app...')),
    );
  }

  void _handleActionButton() {
    // Abre a tela de detalhes de acordo com a aba
    setState(() {
      _isLoading = true;
    });
    
    // Simular carregamento
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      
      setState(() {
        _isLoading = false;
      });
      
      if (_selectedTab == 0) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const _AcademyDetailPage(),
          ),
        );
      } else if (_selectedTab == 1) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const _IntellimenDetailPage(),
          ),
        );
      } else if (_selectedTab == 2) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const _CampusDetailPage(),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Navegando para mais informações...')),
        );
      }
    });
  }

  Widget _buildLoadingOverlay() {
    if (!_isLoading) return const SizedBox.shrink();
    
    return Container(
      color: Colors.black.withValues(alpha: 0.5),
      child: const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      ),
    );
  }

  void _showError(String message) {
    setState(() {
      _errorMessage = message;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
    
    // Limpar erro após 3 segundos
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _errorMessage = null;
        });
      }
    });
  }

  void _handleNetworkError() {
    _showError('Erro de conexão. Verifique sua internet.');
  }

  void _handleGeneralError() {
    _showError('Algo deu errado. Tente novamente.');
  }

  void _handleBannerAction(int index) {
    // Implementar ação do banner
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Abrindo manifesto ${_banners[index]['title']}...')),
    );
  }

  // Métodos de navegação
  void _handleNavIconTap(IconData icon) {
    switch (icon) {
      case Icons.home:
        // Se já estiver na home, apenas faz pop até a primeira tela
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
        break;
      case Icons.search:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Abrindo busca...')),
        );
        break;
      case Icons.ondemand_video:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Abrindo vídeos...')),
        );
        break;
    }
  }

  void _handleCentralNavTap() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Criando novo conteúdo...')),
    );
  }

  void _handleProfileTap() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Abrindo perfil...')),
    );
  }

  void _handleLoginTap() {
    Navigator.pop(context);
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  void _handleSignupTap() {
    Navigator.pop(context);
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const SignupPage()),
    );
  }

  void _handleCompleteProfileTap() {
    Navigator.pop(context);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CompleteProfilePage(
          userModel: UserModel(
            id: 'teste',
            name: 'Usuário Teste',
            email: 'teste@email.com',
            accessLevel: 'general',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            isActive: true,
            hasCompletedProfile: false,
          ),
        ),
      ),
    );
  }
} 

// Widget base para detalhes com visual igual ao da tela principal
class WelcomeDetailScaffold extends StatelessWidget {
  final Widget child;
  const WelcomeDetailScaffold({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset(
            WelcomeConstants.backgroundImage,
            fit: BoxFit.cover,
          ),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(WelcomeConstants.headerHeight),
            child: SafeArea(
              bottom: false,
              child: Container(
                color: Colors.black,
                padding: WelcomeConstants.headerPadding,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    if (Navigator.canPop(context))
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    Expanded(
                      child: Center(
                        child: Image.asset(
                          WelcomeConstants.logoImage,
                          height: WelcomeConstants.headerHeight - 20,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          body: Center(
            child: child,
          ),
        ),
      ],
    );
  }
} 

// Nova tela de detalhes para Academy
class _AcademyDetailPage extends StatelessWidget {
  const _AcademyDetailPage({super.key});

  static const String _textoCompleto =
      'O IntelliMen Academy é uma extensão do projeto IntelliMen, voltado para garotos de 9 a 14 anos.\n\nO objetivo do grupo é desenvolver nesses garotos um caráter íntegro e determinado através do ensinamento da Palavra de Deus e de atividades práticas, buscando formar homens exemplares em uma sociedade que tem corrompido os valores masculinos.\n\nO curso está dividido em duas fases: ALPHA e BETA, cada uma contendo sete (7) oficinas, sendo a ALPHA teórica e a BETA prática. É fundamental destacar que somente os cadetes que concluírem ambas as fases poderão se formar.\n\nAs aulas têm duração de 1 hora e 30 minutos e ocorrem às quartas-feiras, às 20h (para a faixa etária de 9 a 11 anos), e aos domingos, às 9h30 (para a faixa etária de 12 a 14 anos), no 11º andar do Templo de Salomão. É imprescindível que as turmas respeitem os horários de entrada e saída.\n\nPara a conclusão bem-sucedida do curso, os cadetes devem realizar todas as tarefas e entregá-las dentro do prazo estipulado, ser pontuais, comparecer a todas as oficinas, manter a disciplina, respeitar os demais cadetes, adotar uma postura correta e obedecer às instruções fornecidas no curso.\n\nCada turma deverá ter, no máximo, 15 cadetes. No início de cada oficina, eles receberão um resumo da aula para facilitar a revisão do conteúdo ao final do curso. Além disso, eles receberão deveres de casa, que deverão ser entregues ao instrutor na aula seguinte.';

  @override
  Widget build(BuildContext context) {
    return WelcomeDetailScaffold(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0x66000000),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white.withOpacity(0.25), width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.10),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 28),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'O que é o Academy?',
                          style: WelcomeConstants.titleBoldStyle.copyWith(
                            color: Color(0xFFEEEEEE),
                            fontSize: WelcomeConstants.titleBoldStyle.fontSize! + 2,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        RichText(
                          textAlign: TextAlign.justify,
                          text: TextSpan(
                            style: WelcomeConstants.descriptionStyle.copyWith(
                              color: Color(0xFFEEEEEE),
                              fontSize: WelcomeConstants.descriptionStyle.fontSize! + 2,
                              fontWeight: FontWeight.w400,
                              height: 1.7,
                              letterSpacing: 1.3,
                            ),
                            children: [
                              const TextSpan(text: 'O '),
                              const TextSpan(text: 'IntelliMen Academy', style: TextStyle(fontWeight: FontWeight.bold)),
                              const TextSpan(text: ' é uma extensão do projeto IntelliMen, voltado para garotos de 9 a 14 anos.\n\nO objetivo do grupo é desenvolver nesses garotos um caráter íntegro e determinado através do ensinamento da Palavra de Deus e de atividades práticas, buscando formar homens exemplares em uma sociedade que tem corrompido os valores masculinos.\n\nO curso está dividido em duas fases: '),
                              const TextSpan(text: 'ALPHA', style: TextStyle(fontWeight: FontWeight.bold)),
                              const TextSpan(text: ' e '),
                              const TextSpan(text: 'BETA', style: TextStyle(fontWeight: FontWeight.bold)),
                              const TextSpan(text: ', cada uma contendo sete (7) oficinas, sendo a '),
                              const TextSpan(text: 'ALPHA', style: TextStyle(fontWeight: FontWeight.bold)),
                              const TextSpan(text: ' teórica e a '),
                              const TextSpan(text: 'BETA', style: TextStyle(fontWeight: FontWeight.bold)),
                              const TextSpan(text: ' prática. É fundamental destacar que somente os cadetes que concluírem ambas as fases poderão se formar.\n\nAs aulas têm duração de 1 hora e 30 minutos e ocorrem às '),
                              const TextSpan(text: 'quartas-feiras, às 20h (para a faixa etária de 9 a 11 anos)', style: TextStyle(fontWeight: FontWeight.bold)),
                              const TextSpan(text: ', e aos '),
                              const TextSpan(text: 'domingos, às 9h30 (para a faixa etária de 12 a 14 anos)', style: TextStyle(fontWeight: FontWeight.bold)),
                              const TextSpan(text: ', no '),
                              const TextSpan(text: '11º andar do Templo de Salomão', style: TextStyle(fontWeight: FontWeight.bold)),
                              const TextSpan(text: '. É imprescindível que as turmas respeitem os horários de entrada e saída.\n\nPara a conclusão bem-sucedida do curso, os cadetes devem realizar '),
                              const TextSpan(text: 'todas as tarefas', style: TextStyle(fontWeight: FontWeight.bold)),
                              const TextSpan(text: ' e entregá-las dentro do prazo estipulado, ser pontuais, comparecer a '),
                              const TextSpan(text: 'todas as oficinas', style: TextStyle(fontWeight: FontWeight.bold)),
                              const TextSpan(text: ', manter a '),
                              const TextSpan(text: 'disciplina', style: TextStyle(fontWeight: FontWeight.bold)),
                              const TextSpan(text: ', respeitar os '),
                              const TextSpan(text: 'demais cadetes', style: TextStyle(fontWeight: FontWeight.bold)),
                              const TextSpan(text: ', adotar uma '),
                              const TextSpan(text: 'postura correta', style: TextStyle(fontWeight: FontWeight.bold)),
                              const TextSpan(text: ' e '),
                              const TextSpan(text: 'obedecer às instruções', style: TextStyle(fontWeight: FontWeight.bold)),
                              const TextSpan(text: ' fornecidas no curso.\n\nCada turma deverá ter, no máximo, '),
                              const TextSpan(text: '15 cadetes', style: TextStyle(fontWeight: FontWeight.bold)),
                              const TextSpan(text: '. No início de cada oficina, eles receberão um '),
                              const TextSpan(text: 'resumo da aula', style: TextStyle(fontWeight: FontWeight.bold)),
                              const TextSpan(text: ' para facilitar a revisão do conteúdo ao final do curso. Além disso, eles receberão '),
                              const TextSpan(text: 'deveres de casa', style: TextStyle(fontWeight: FontWeight.bold)),
                              const TextSpan(text: ', que deverão ser entregues ao instrutor na aula seguinte.'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                        SizedBox(
                          width: 200,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFFFF8E44),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 6,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                                  title: const Text('Atenção'),
                                  content: const Text(
                                    'O IntelliMen Academy é exclusivo para crianças e adolescentes de 9 a 14 anos.\n\nOs pais ou responsáveis devem fazer o contato.\n\nSe você é pai ou responsável, clique em ENVIAR MENSAGEM para falar com o coordenador do Academy.',
                                    textAlign: TextAlign.justify,
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(),
                                      child: const Text('Fechar'),
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.black,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      ),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Abrir formulário de contato...')),
                                        );
                                      },
                                      child: const Text('ENVIAR MENSAGEM'),
                                    ),
                                  ],
                                ),
                              );
                            },
                            child: const Text(
                              'QUERO PARTICIPAR',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
} 

// Nova tela de detalhes para Campus
class _CampusDetailPage extends StatelessWidget {
  const _CampusDetailPage({super.key});

  static const String _textoCompleto =
      'Durante a primeira edição do projeto, o grupo percorreu diversas localidades no estado da Bahia, na Região Centro-Norte, com o intuito de exercitar os aprendizados adquiridos e alcançar experiência ao longo do treinamento.\nEles passaram por lugares como a Fazenda Nova Canaã – em Irecê, no interior do estado -, um presídio, um lar para idosos, um centro de reabilitação e participaram de um curso completo de primeiros socorros, só para ilustrar.';

  @override
  Widget build(BuildContext context) {
    return WelcomeDetailScaffold(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0x66000000),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white.withOpacity(0.25), width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.10),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 28),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'O IntelliMen Campus:',
                          style: WelcomeConstants.titleBoldStyle.copyWith(
                            color: Color(0xFFEEEEEE),
                            fontSize: WelcomeConstants.titleBoldStyle.fontSize! + 2,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          _textoCompleto,
                          style: WelcomeConstants.descriptionStyle.copyWith(
                            color: Color(0xFFEEEEEE),
                            fontSize: WelcomeConstants.descriptionStyle.fontSize! + 2,
                            fontWeight: FontWeight.w400,
                            height: 1.7,
                            letterSpacing: 1.3,
                          ),
                          textAlign: TextAlign.justify,
                        ),
                        const SizedBox(height: 32),
                        // Card COMO PARTICIPAR
                        ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: const Color(0x99000000),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(color: Colors.white.withOpacity(0.18), width: 1.2),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.10),
                                    blurRadius: 16,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    'COMO PARTICIPAR',
                                    style: WelcomeConstants.titleBoldStyle.copyWith(
                                      color: Color(0xFFEEEEEE),
                                      fontSize: WelcomeConstants.titleBoldStyle.fontSize! - 2,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 2.2,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 16),
                                  SizedBox(
                                    width: 240,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Color(0xFFFF8E44),
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        elevation: 6,
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                      ),
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) {
                                            final TextEditingController _controller = TextEditingController();
                                            return AlertDialog(
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                                              title: const Text('Fale com o coordenador'),
                                              content: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const Text(
                                                    'Envie sua dúvida ou mensagem para o coordenador do Campus:',
                                                    textAlign: TextAlign.justify,
                                                  ),
                                                  const SizedBox(height: 16),
                                                  TextField(
                                                    controller: _controller,
                                                    maxLines: 4,
                                                    decoration: const InputDecoration(
                                                      hintText: 'Digite sua mensagem...',
                                                      border: OutlineInputBorder(),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () => Navigator.of(context).pop(),
                                                  child: const Text('Fechar'),
                                                ),
                                                ElevatedButton(
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: Colors.black,
                                                    foregroundColor: Colors.white,
                                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                                  ),
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      const SnackBar(content: Text('Mensagem enviada para o coordenador!')),
                                                    );
                                                  },
                                                  child: const Text('ENVIAR'),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                      child: const Text(
                                        'MAIS INFORMAÇÕES!',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          letterSpacing: 1.2,
                                        ),
                                      ),
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
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
} 

// Nova tela de detalhes para IntelliMen
class _IntellimenDetailPage extends StatelessWidget {
  const _IntellimenDetailPage({super.key});

  static const String _textoCompleto =
      'Você já deve ter sacado que o nome do projeto é uma junção das palavras em inglês intelligent (inteligentes) e men (homens). Escolhemos esse nome porque além de soar como um super-herói, que todo homem secretamente aspira ser desde criança, ele engloba tudo o que o projeto aspira: formar homens inteligentes e melhores em tudo. Não prometemos superpoderes como levantar ônibus com um dedo, voar ou invisibilidade — mas estamos trabalhando nisso.';

  @override
  Widget build(BuildContext context) {
    return WelcomeDetailScaffold(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0x66000000),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white.withOpacity(0.25), width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.10),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'O que é O Intellimen?',
                        style: WelcomeConstants.titleBoldStyle.copyWith(
                          color: Color(0xFFEEEEEE),
                          fontSize: WelcomeConstants.titleBoldStyle.fontSize! + 2,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        _textoCompleto,
                        style: WelcomeConstants.descriptionStyle.copyWith(
                          color: Color(0xFFEEEEEE),
                          fontSize: WelcomeConstants.descriptionStyle.fontSize! + 2,
                          fontWeight: FontWeight.w400,
                          height: 1.7,
                          letterSpacing: 1.3,
                        ),
                        textAlign: TextAlign.justify,
                      ),
                      const SizedBox(height: 32),
                      // Novo card desafio
                      ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: const Color(0x99000000),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: Colors.white.withOpacity(0.18), width: 1.2),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.10),
                                  blurRadius: 16,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  'ACEITA O DESAFIO?',
                                  style: WelcomeConstants.titleBoldStyle.copyWith(
                                    color: Color(0xFFEEEEEE),
                                    fontSize: WelcomeConstants.titleBoldStyle.fontSize! + 1,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 2.2,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 18),
                                SizedBox(
                                  width: 180,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.black,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 6,
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                    ),
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => const ManifestoPage(),
                                        ),
                                      );
                                    },
                                    child: const Text(
                                      'LEIA O MANIFESTO',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
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
              ),
            ),
          ),
        ),
      ),
    );
  }
} 