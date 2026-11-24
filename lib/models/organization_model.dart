class OrganizationModel {
  final String id;
  final String name;
  final String description;
  final String city;
  final String? phone;
  final String? whatsapp;
  final String? email;
  final String? instagram;
  final String? pixKey;
  final String? pixName;
  final String? logoPath;
  final bool verified;
  final DateTime createdAt;

  const OrganizationModel({
    required this.id,
    required this.name,
    required this.description,
    required this.city,
    this.phone,
    this.whatsapp,
    this.email,
    this.instagram,
    this.pixKey,
    this.pixName,
    this.logoPath,
    this.verified = false,
    required this.createdAt,
  });

  OrganizationModel copyWith({
    String? id,
    String? name,
    String? description,
    String? city,
    String? phone,
    String? whatsapp,
    String? email,
    String? instagram,
    String? pixKey,
    String? pixName,
    String? logoPath,
    bool? verified,
    DateTime? createdAt,
  }) {
    return OrganizationModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      city: city ?? this.city,
      phone: phone ?? this.phone,
      whatsapp: whatsapp ?? this.whatsapp,
      email: email ?? this.email,
      instagram: instagram ?? this.instagram,
      pixKey: pixKey ?? this.pixKey,
      pixName: pixName ?? this.pixName,
      logoPath: logoPath ?? this.logoPath,
      verified: verified ?? this.verified,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'description': description,
        'city': city,
        'phone': phone,
        'whatsapp': whatsapp,
        'email': email,
        'instagram': instagram,
        'pixKey': pixKey,
        'pixName': pixName,
        'logoPath': logoPath,
        'verified': verified ? 1 : 0,
        'createdAt': createdAt.toIso8601String(),
      };

  factory OrganizationModel.fromMap(Map<String, dynamic> map) {
    return OrganizationModel(
      id: map['id'].toString(),
      name: map['name']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      city: map['city']?.toString() ?? 'Rio do Sul',
      phone: map['phone']?.toString(),
      whatsapp: map['whatsapp']?.toString(),
      email: map['email']?.toString(),
      instagram: map['instagram']?.toString(),
      pixKey: map['pixKey']?.toString(),
      pixName: map['pixName']?.toString(),
      logoPath: map['logoPath']?.toString(),
      verified: (map['verified'] == 1 || map['verified'] == true),
      createdAt:
          DateTime.tryParse(map['createdAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }
}

class VolunteerProfileModel {
  final String id;
  final String userId;
  final String? userName;
  final String? userPhone;
  final String? organizationId;
  final List<String> skills;
  final List<String> availability;
  final bool hasVehicle;
  final int radiusKm;
  final DateTime createdAt;

  const VolunteerProfileModel({
    required this.id,
    required this.userId,
    this.userName,
    this.userPhone,
    this.organizationId,
    this.skills = const [],
    this.availability = const [],
    this.hasVehicle = false,
    this.radiusKm = 10,
    required this.createdAt,
  });

  static const List<String> availableSkills = [
    'Transporte',
    'Abrigo temporário',
    'Alimentação',
    'Veterinário',
    'Resgate',
    'Divulgação',
  ];

  static const List<String> availableShifts = [
    'Manhã',
    'Tarde',
    'Noite',
    'Fins de semana',
  ];

  VolunteerProfileModel copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userPhone,
    String? organizationId,
    List<String>? skills,
    List<String>? availability,
    bool? hasVehicle,
    int? radiusKm,
    DateTime? createdAt,
  }) {
    return VolunteerProfileModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userPhone: userPhone ?? this.userPhone,
      organizationId: organizationId ?? this.organizationId,
      skills: skills ?? this.skills,
      availability: availability ?? this.availability,
      hasVehicle: hasVehicle ?? this.hasVehicle,
      radiusKm: radiusKm ?? this.radiusKm,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'userId': userId,
        'userName': userName,
        'userPhone': userPhone,
        'organizationId': organizationId,
        'skills': skills.join(','),
        'availability': availability.join(','),
        'hasVehicle': hasVehicle ? 1 : 0,
        'radiusKm': radiusKm,
        'createdAt': createdAt.toIso8601String(),
      };

  factory VolunteerProfileModel.fromMap(Map<String, dynamic> map) {
    List<String> splitCsv(dynamic raw) {
      if (raw == null) return [];
      return raw
          .toString()
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();
    }

    return VolunteerProfileModel(
      id: map['id'].toString(),
      userId: map['userId']?.toString() ?? '',
      userName: map['userName']?.toString(),
      userPhone: map['userPhone']?.toString(),
      organizationId: map['organizationId']?.toString(),
      skills: splitCsv(map['skills']),
      availability: splitCsv(map['availability']),
      hasVehicle: map['hasVehicle'] == 1 || map['hasVehicle'] == true,
      radiusKm: int.tryParse(map['radiusKm']?.toString() ?? '') ?? 10,
      createdAt:
          DateTime.tryParse(map['createdAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }
}
