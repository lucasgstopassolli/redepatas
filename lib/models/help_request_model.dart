import 'package:flutter/material.dart';

enum AnimalSpecies {
  dog,
  cat,
  other;

  String get label {
    switch (this) {
      case AnimalSpecies.dog:
        return 'Cão';
      case AnimalSpecies.cat:
        return 'Gato';
      case AnimalSpecies.other:
        return 'Outro';
    }
  }

  IconData get icon {
    switch (this) {
      case AnimalSpecies.dog:
        return Icons.pets_outlined;
      case AnimalSpecies.cat:
        return Icons.pets_outlined;
      case AnimalSpecies.other:
        return Icons.cruelty_free_outlined;
    }
  }

  static AnimalSpecies fromString(String value) {
    return AnimalSpecies.values.firstWhere(
      (e) => e.name == value,
      orElse: () => AnimalSpecies.dog,
    );
  }
}

enum NeedType {
  water,
  food,
  shelter,
  medical;

  String get label {
    switch (this) {
      case NeedType.water:
        return 'Água';
      case NeedType.food:
        return 'Alimento';
      case NeedType.shelter:
        return 'Abrigo';
      case NeedType.medical:
        return 'Socorro/Cuidados';
    }
  }

  IconData get icon {
    switch (this) {
      case NeedType.water:
        return Icons.water_drop_outlined;
      case NeedType.food:
        return Icons.restaurant_outlined;
      case NeedType.shelter:
        return Icons.home_outlined;
      case NeedType.medical:
        return Icons.medical_services_outlined;
    }
  }

  static NeedType fromString(String value) {
    return NeedType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => NeedType.food,
    );
  }
}

enum RequestStatus {
  open,
  inProgress,
  completed;

  String get label {
    switch (this) {
      case RequestStatus.open:
        return 'Aberto';
      case RequestStatus.inProgress:
        return 'Em atendimento';
      case RequestStatus.completed:
        return 'Concluído';
    }
  }

  static RequestStatus fromString(String value) {
    return RequestStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => RequestStatus.open,
    );
  }
}

enum UrgencyLevel {
  normal,
  high,
  critical;

  String get label {
    switch (this) {
      case UrgencyLevel.normal:
        return 'Normal';
      case UrgencyLevel.high:
        return 'Alta';
      case UrgencyLevel.critical:
        return 'Crítica';
    }
  }

  static UrgencyLevel fromString(String value) {
    return UrgencyLevel.values.firstWhere(
      (e) => e.name == value,
      orElse: () => UrgencyLevel.normal,
    );
  }
}

class HelpRequestModel {
  final String id;
  final String title;
  final AnimalSpecies species;
  final List<NeedType> needs;
  final UrgencyLevel urgency;
  final String city;
  final String neighborhood;
  final String referencePoint;
  final String description;
  final String? photoPath;
  final RequestStatus status;
  final String authorId;
  final String authorName;
  final String? authorPhone;
  final String? helperId;
  final String? helperName;
  final String? helperCommitment;
  final DateTime createdAt;

  // Campos v2 (todos opcionais / com padrão seguro para retrocompatibilidade)
  final double? latitude;
  final double? longitude;
  final String? organizationId;
  final DateTime? updatedAt;
  final DateTime? completedAt;
  final List<String> photos;
  final int animalCount;
  final String? afterPhotoPath;
  final String? reportedReason;

  const HelpRequestModel({
    required this.id,
    required this.title,
    required this.species,
    required this.needs,
    required this.urgency,
    required this.city,
    required this.neighborhood,
    required this.referencePoint,
    required this.description,
    this.photoPath,
    required this.status,
    required this.authorId,
    required this.authorName,
    this.authorPhone,
    this.helperId,
    this.helperName,
    this.helperCommitment,
    required this.createdAt,
    this.latitude,
    this.longitude,
    this.organizationId,
    this.updatedAt,
    this.completedAt,
    this.photos = const [],
    this.animalCount = 1,
    this.afterPhotoPath,
    this.reportedReason,
  });

  bool get hasCoordinates => latitude != null && longitude != null;

  List<String> get allPhotos {
    final result = <String>[];
    if (photoPath != null && photoPath!.trim().isNotEmpty) {
      result.add(photoPath!.trim());
    }
    for (final p in photos) {
      if (p.trim().isNotEmpty && !result.contains(p.trim())) {
        result.add(p.trim());
      }
    }
    return result;
  }

  String get needsSummary {
    if (needs.isEmpty) return 'Apoio geral';
    return 'Precisa de ${needs.map((n) => n.label).join(' • ')}';
  }

  HelpRequestModel copyWith({
    String? id,
    String? title,
    AnimalSpecies? species,
    List<NeedType>? needs,
    UrgencyLevel? urgency,
    String? city,
    String? neighborhood,
    String? referencePoint,
    String? description,
    String? photoPath,
    RequestStatus? status,
    String? authorId,
    String? authorName,
    String? authorPhone,
    String? helperId,
    String? helperName,
    String? helperCommitment,
    DateTime? createdAt,
    double? latitude,
    double? longitude,
    String? organizationId,
    DateTime? updatedAt,
    DateTime? completedAt,
    List<String>? photos,
    int? animalCount,
    String? afterPhotoPath,
    String? reportedReason,
  }) {
    return HelpRequestModel(
      id: id ?? this.id,
      title: title ?? this.title,
      species: species ?? this.species,
      needs: needs ?? this.needs,
      urgency: urgency ?? this.urgency,
      city: city ?? this.city,
      neighborhood: neighborhood ?? this.neighborhood,
      referencePoint: referencePoint ?? this.referencePoint,
      description: description ?? this.description,
      photoPath: photoPath ?? this.photoPath,
      status: status ?? this.status,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      authorPhone: authorPhone ?? this.authorPhone,
      helperId: helperId ?? this.helperId,
      helperName: helperName ?? this.helperName,
      helperCommitment: helperCommitment ?? this.helperCommitment,
      createdAt: createdAt ?? this.createdAt,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      organizationId: organizationId ?? this.organizationId,
      updatedAt: updatedAt ?? this.updatedAt,
      completedAt: completedAt ?? this.completedAt,
      photos: photos ?? this.photos,
      animalCount: animalCount ?? this.animalCount,
      afterPhotoPath: afterPhotoPath ?? this.afterPhotoPath,
      reportedReason: reportedReason ?? this.reportedReason,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'species': species.name,
      'needs': needs.map((e) => e.name).join(','),
      'urgency': urgency.name,
      'city': city,
      'neighborhood': neighborhood,
      'referencePoint': referencePoint,
      'description': description,
      'photoPath': photoPath,
      'status': status.name,
      'authorId': authorId,
      'authorName': authorName,
      'authorPhone': authorPhone,
      'helperId': helperId,
      'helperName': helperName,
      'helperCommitment': helperCommitment,
      'createdAt': createdAt.toIso8601String(),
      'latitude': latitude,
      'longitude': longitude,
      'organizationId': organizationId,
      'updatedAt': updatedAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'photos': photos.isEmpty ? null : photos.join(','),
      'animalCount': animalCount,
      'afterPhotoPath': afterPhotoPath,
      'reportedReason': reportedReason,
    };
  }

  factory HelpRequestModel.fromMap(Map<String, dynamic> map) {
    final rawNeeds = (map['needs']?.toString() ?? '')
        .split(',')
        .where((s) => s.trim().isNotEmpty)
        .map(NeedType.fromString)
        .toList();

    final rawPhotos = (map['photos']?.toString() ?? '')
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    double? parseDouble(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString());
    }

    int parseInt(dynamic v, int fallback) {
      if (v == null) return fallback;
      if (v is int) return v;
      return int.tryParse(v.toString()) ?? fallback;
    }

    return HelpRequestModel(
      id: map['id'].toString(),
      title: map['title']?.toString() ?? '',
      species: AnimalSpecies.fromString(map['species']?.toString() ?? 'dog'),
      needs: rawNeeds.isEmpty ? [NeedType.food] : rawNeeds,
      urgency: UrgencyLevel.fromString(map['urgency']?.toString() ?? 'normal'),
      city: map['city']?.toString() ?? 'Rio do Sul',
      neighborhood: map['neighborhood']?.toString() ?? 'Centro',
      referencePoint: map['referencePoint']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      photoPath: map['photoPath']?.toString(),
      status: RequestStatus.fromString(map['status']?.toString() ?? 'open'),
      authorId: map['authorId']?.toString() ?? '',
      authorName: map['authorName']?.toString() ?? 'Morador da Comunidade',
      authorPhone: map['authorPhone']?.toString(),
      helperId: map['helperId']?.toString(),
      helperName: map['helperName']?.toString(),
      helperCommitment: map['helperCommitment']?.toString(),
      createdAt: DateTime.tryParse(map['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      latitude: parseDouble(map['latitude']),
      longitude: parseDouble(map['longitude']),
      organizationId: map['organizationId']?.toString(),
      updatedAt: map['updatedAt'] != null
          ? DateTime.tryParse(map['updatedAt'].toString())
          : null,
      completedAt: map['completedAt'] != null
          ? DateTime.tryParse(map['completedAt'].toString())
          : null,
      photos: rawPhotos,
      animalCount: parseInt(map['animalCount'], 1),
      afterPhotoPath: map['afterPhotoPath']?.toString(),
      reportedReason: map['reportedReason']?.toString(),
    );
  }
}
