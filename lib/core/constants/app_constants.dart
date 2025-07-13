class AppConstants {
  // Nome do aplicativo
  static const String appName = 'IntelliMen';
  
  // Versão
  static const String appVersion = '1.0.0';
  
  // Limites de idade
  static const int minAgeTeen = 9;
  static const int maxAgeTeen = 14;
  static const int minAgeCampus = 17;
  static const int maxAgeCampus = 25;
  
  // Número de desafios
  static const int totalChallenges = 53;
  
  // Estados brasileiros
  static const List<String> brazilianStates = [
    'Acre', 'Alagoas', 'Amapá', 'Amazonas', 'Bahia', 'Ceará',
    'Distrito Federal', 'Espírito Santo', 'Goiás', 'Maranhão',
    'Mato Grosso', 'Mato Grosso do Sul', 'Minas Gerais', 'Pará',
    'Paraíba', 'Paraná', 'Pernambuco', 'Piauí', 'Rio de Janeiro',
    'Rio Grande do Norte', 'Rio Grande do Sul', 'Rondônia',
    'Roraima', 'Santa Catarina', 'São Paulo', 'Sergipe', 'Tocantins'
  ];
  
  // Tipos de acesso
  static const String accessGeneral = 'general';
  static const String accessMember = 'member';
  static const String accessCampus = 'campus';
  static const String accessAcademy = 'academy';
  
  // Status de solicitações
  static const String statusPending = 'pending';
  static const String statusApproved = 'approved';
  static const String statusRejected = 'rejected';
  
  // Tipos de quiz
  static const String quizTypePartner = 'partner';
  static const String quizTypeIndividual = 'individual';
} 