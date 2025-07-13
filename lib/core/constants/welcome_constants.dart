import 'package:flutter/material.dart';

class WelcomeConstants {
  // Cores do gradiente
  static const List<Color> gradientColors = [
    Color(0xFFFF8E44),
    Color(0xFFF91362),
    Color(0xFF35126A),
  ];

  // Cores das abas
  static const List<List<Color>> tabGradients = [
    [Color(0xFF8F2D8A), Color(0xFFFF4062)], // Academy
    [Color(0xFF8F2D8A), Color(0xFFFF4062)], // IntelliMen
    [Color(0xFFFF4062), Color(0xFF4B2067)], // Campus
  ];

  // Cores dos ícones de navegação
  static const List<Color> navIconColors = [
    Color(0xFFFF4062), // Home
    Color(0xFFF91362), // Search
    Color(0xFFFF8E44), // Video
  ];

  // Conteúdo das abas
  static const List<Map<String, String>> tabContents = [
    {
      'title': 'O que é o Academy?',
      'desc': 'O Academy é a área de formação avançada do projeto, voltada para quem deseja se aprofundar em temas de liderança, propósito e desenvolvimento pessoal. Aqui você encontra conteúdos exclusivos, desafios especiais e acompanhamento de mentores.'
    },
    {
      'title': 'O que é o IntelliMen?',
      'desc': 'Você já deve ter sacado que o nome do projeto é uma junção das palavras em inglês intelligent (inteligentes) e men (homens). Escolhemos esse nome porque além de soar como um super-herói, que todo homem secretamente aspira ser desde criança, ele engloba tudo o que o projeto aspira: formar homens inteligentes e melhores em tudo. Não prometemos superpoderes como levantar ônibus com um dedo, voar ou invisibilidade — mas estamos trabalhando nisso.'
    },
    {
      'title': 'O que é o Campus?',
      'desc': 'Você já conhece o IntelliMen Campus? Trata-se de um projeto com a missão de forjar rapazes entre 18 e 25 anos para que tenham um espírito excelente, assim como foi com o profeta Daniel, na Bíblia.'
    },
  ];

  // Labels das abas
  static const List<String> tabLabels = ['ACADEMY', 'INTELLIMEN', 'CAMPUS'];

  // Configurações de layout
  static const double headerHeight = 90.0;
  static const double avatarRadius = 32.0;
  static const double avatarInnerRadius = 29.0;
  static const double gradientLineHeight = 4.0;
  static const double tabGradientHeight = 2.0;
  static const double bannerHeight = 200.0;
  static const double bottomNavHeight = 80.0;
  static const double centralNavButtonSize = 60.0;
  static const double profileAvatarRadius = 18.0;

  // Padding e margins
  static const EdgeInsets headerPadding = EdgeInsets.only(top: 5, left: 24, right: 24, bottom: 8);
  static const EdgeInsets contentPadding = EdgeInsets.symmetric(horizontal: 16, vertical: 4);
  static const EdgeInsets cardPadding = EdgeInsets.symmetric(horizontal: 24, vertical: 16);
  static const EdgeInsets bannerPadding = EdgeInsets.symmetric(horizontal: 16, vertical: 8);

  // Border radius
  static const double cardBorderRadius = 12.0;
  static const double bannerBorderRadius = 16.0;
  static const double buttonBorderRadius = 8.0;
  static const double tabBorderRadius = 20.0;

  // Shadows
  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color(0x0F000000), // black06 equivalent
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
  ];

  static const List<BoxShadow> tabShadow = [
    BoxShadow(
      color: Color(0x14000000), // black08 equivalent
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];

  static const List<BoxShadow> bottomNavShadow = [
    BoxShadow(
      color: Colors.black54,
      blurRadius: 10,
      offset: Offset(0, -2),
    ),
  ];

  // Text styles
  static const TextStyle titleStyle = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w300,
    color: Color(0xFF444444),
    letterSpacing: 2,
  );

  static const TextStyle titleBoldStyle = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: Color(0xFF444444),
    letterSpacing: 2,
  );

  static const TextStyle descriptionStyle = TextStyle(
    fontSize: 16,
    color: Color(0xFF444444),
    height: 1.5,
    letterSpacing: 1.1,
  );

  static const TextStyle buttonTextStyle = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.bold,
    letterSpacing: 1.2,
  );

  static const TextStyle bannerTitleStyle = TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.bold,
    fontSize: 24,
    letterSpacing: 1.2,
  );

  static const TextStyle bannerSubtitleStyle = TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.w400,
    fontSize: 14,
    letterSpacing: 0.8,
  );

  static const TextStyle tabTextStyle = TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 16,
    letterSpacing: 2,
  );

  // URLs e assets
  static const String backgroundImage = 'assets/images/bg-intellimen.jpg';
  static const String logoImage = 'assets/logos/logo-intellimen.png';
  static const String bannerImage = 'assets/images/bg-intellimen-renato-cardoso.jpg';
  static const String defaultAvatarUrl = 'https://randomuser.me/api/portraits/men/1.jpg';

  // Lista de avatares
  static const List<String> avatarUrls = [
    'https://randomuser.me/api/portraits/men/1.jpg',
    'https://randomuser.me/api/portraits/men/2.jpg',
    'https://randomuser.me/api/portraits/men/3.jpg',
    'https://randomuser.me/api/portraits/men/4.jpg',
    'https://randomuser.me/api/portraits/men/5.jpg',
    'https://randomuser.me/api/portraits/men/6.jpg',
    'https://randomuser.me/api/portraits/men/7.jpg',
    'https://randomuser.me/api/portraits/men/8.jpg',
    'https://randomuser.me/api/portraits/men/9.jpg',
    'https://randomuser.me/api/portraits/men/10.jpg',
  ];
} 