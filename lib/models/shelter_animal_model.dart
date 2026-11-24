import 'help_request_model.dart';

enum AnimalStatus {
  acolhido,
  disponivel,
  larTemporario,
  reservado,
  adotado;

  String get label {
    switch (this) {
      case AnimalStatus.acolhido:
        return 'Acolhido';
      case AnimalStatus.disponivel:
        return 'Disponível para adoção';
      case AnimalStatus.larTemporario:
        return 'Precisa de lar temporário';
      case AnimalStatus.reservado:
        return 'Reservado';
      case AnimalStatus.adotado:
        return 'Adotado';
    }
  }

  static AnimalStatus fromString(String? value) {
    if (value == 'lar_temporario') return AnimalStatus.larTemporario;
    return AnimalStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => AnimalStatus.disponivel,
    );
  }
}

class ShelterAnimalModel {
  final String id;
  final String organizationId;
  final String name;
  final AnimalSpecies species;
  final String sex; // Macho / Fêmea / Não informado
  final String ageGroup; // Filhote / Adulto / Idoso
  final String size; // Pequeno / Médio / Grande
  final String temperament;
  final String health;
  final bool vaccinated;
  final bool castrated;
  final AnimalStatus status;
  final String? photoPath;
  final String description;
  final String? originRequestId;
  final DateTime createdAt;

  const ShelterAnimalModel({
    required this.id,
    required this.organizationId,
    required this.name,
    required this.species,
    required this.sex,
    required this.ageGroup,
    required this.size,
    required this.temperament,
    required this.health,
    this.vaccinated = false,
    this.castrated = false,
    this.status = AnimalStatus.disponivel,
    this.photoPath,
    required this.description,
    this.originRequestId,
    required this.createdAt,
  });

  ShelterAnimalModel copyWith({
    String? id,
    String? organizationId,
    String? name,
    AnimalSpecies? species,
    String? sex,
    String? ageGroup,
    String? size,
    String? temperament,
    String? health,
    bool? vaccinated,
    bool? castrated,
    AnimalStatus? status,
    String? photoPath,
    String? description,
    String? originRequestId,
    DateTime? createdAt,
  }) {
    return ShelterAnimalModel(
      id: id ?? this.id,
      organizationId: organizationId ?? this.organizationId,
      name: name ?? this.name,
      species: species ?? this.species,
      sex: sex ?? this.sex,
      ageGroup: ageGroup ?? this.ageGroup,
      size: size ?? this.size,
      temperament: temperament ?? this.temperament,
      health: health ?? this.health,
      vaccinated: vaccinated ?? this.vaccinated,
      castrated: castrated ?? this.castrated,
      status: status ?? this.status,
      photoPath: photoPath ?? this.photoPath,
      description: description ?? this.description,
      originRequestId: originRequestId ?? this.originRequestId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'organizationId': organizationId,
        'name': name,
        'species': species.name,
        'sex': sex,
        'ageGroup': ageGroup,
        'size': size,
        'temperament': temperament,
        'health': health,
        'vaccinated': vaccinated ? 1 : 0,
        'castrated': castrated ? 1 : 0,
        'status': status.name,
        'photoPath': photoPath,
        'description': description,
        'originRequestId': originRequestId,
        'createdAt': createdAt.toIso8601String(),
      };

  factory ShelterAnimalModel.fromMap(Map<String, dynamic> map) {
    return ShelterAnimalModel(
      id: map['id'].toString(),
      organizationId: map['organizationId']?.toString() ?? 'org_apad_demo',
      name: map['name']?.toString() ?? '',
      species: AnimalSpecies.fromString(map['species']?.toString() ?? 'dog'),
      sex: map['sex']?.toString() ?? 'Não informado',
      ageGroup: map['ageGroup']?.toString() ?? 'Adulto',
      size: map['size']?.toString() ?? 'Médio',
      temperament: map['temperament']?.toString() ?? 'Dócil',
      health: map['health']?.toString() ?? 'Saudável',
      vaccinated: map['vaccinated'] == 1 || map['vaccinated'] == true,
      castrated: map['castrated'] == 1 || map['castrated'] == true,
      status: AnimalStatus.fromString(map['status']?.toString()),
      photoPath: map['photoPath']?.toString(),
      description: map['description']?.toString() ?? '',
      originRequestId: map['originRequestId']?.toString(),
      createdAt:
          DateTime.tryParse(map['createdAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }
}

class AdoptionInterestModel {
  final String id;
  final String animalId;
  final String name;
  final String phone;
  final String message;
  final String status; // pendente / contatado / aprovado
  final DateTime createdAt;

  const AdoptionInterestModel({
    required this.id,
    required this.animalId,
    required this.name,
    required this.phone,
    required this.message,
    this.status = 'pendente',
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'animalId': animalId,
        'name': name,
        'phone': phone,
        'message': message,
        'status': status,
        'createdAt': createdAt.toIso8601String(),
      };

  factory AdoptionInterestModel.fromMap(Map<String, dynamic> map) {
    return AdoptionInterestModel(
      id: map['id'].toString(),
      animalId: map['animalId']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      phone: map['phone']?.toString() ?? '',
      message: map['message']?.toString() ?? '',
      status: map['status']?.toString() ?? 'pendente',
      createdAt:
          DateTime.tryParse(map['createdAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }
}
