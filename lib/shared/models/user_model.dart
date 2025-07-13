class UserModel {
  final String id;
  final String name;
  final String email;
  final String? whatsapp;
  final String? photoUrl;
  final DateTime? birthDate;
  final String? state;
  final String accessLevel;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;
  final String? partnerId;
  final bool hasCompletedProfile;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.whatsapp,
    this.photoUrl,
    this.birthDate,
    this.state,
    required this.accessLevel,
    required this.createdAt,
    required this.updatedAt,
    required this.isActive,
    this.partnerId,
    required this.hasCompletedProfile,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      whatsapp: json['whatsapp'],
      photoUrl: json['photo_url'],
      birthDate: json['birth_date'] != null 
          ? DateTime.parse(json['birth_date']) 
          : null,
      state: json['state'],
      accessLevel: json['access_level'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      isActive: json['is_active'] ?? true,
      partnerId: json['partner_id'],
      hasCompletedProfile: json['has_completed_profile'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'whatsapp': whatsapp,
      'photo_url': photoUrl,
      'birth_date': birthDate?.toIso8601String(),
      'state': state,
      'access_level': accessLevel,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_active': isActive,
      'partner_id': partnerId,
      'has_completed_profile': hasCompletedProfile,
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? whatsapp,
    String? photoUrl,
    DateTime? birthDate,
    String? state,
    String? accessLevel,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    String? partnerId,
    bool? hasCompletedProfile,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      whatsapp: whatsapp ?? this.whatsapp,
      photoUrl: photoUrl ?? this.photoUrl,
      birthDate: birthDate ?? this.birthDate,
      state: state ?? this.state,
      accessLevel: accessLevel ?? this.accessLevel,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      partnerId: partnerId ?? this.partnerId,
      hasCompletedProfile: hasCompletedProfile ?? this.hasCompletedProfile,
    );
  }

  int? get age {
    if (birthDate == null) return null;
    final now = DateTime.now();
    int age = now.year - birthDate!.year;
    if (now.month < birthDate!.month || 
        (now.month == birthDate!.month && now.day < birthDate!.day)) {
      age--;
    }
    return age;
  }

  bool get isTeen => age != null && age! >= 9 && age! <= 14;
  bool get isCampusEligible => age != null && age! >= 17 && age! <= 25;
} 