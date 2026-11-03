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
  final String title;              // Ex: "Cão caramelo", "Gata cinza"
  final AnimalSpecies species;     // Cão, Gato, Outro
  final List<NeedType> needs;      // Múltiplas necessidades (Água, Alimento, Abrigo, Socorro)
  final UrgencyLevel urgency;      // Normal, Alta, Crítica
  final String city;               // Padrão: "Rio do Sul" ou vindo da API IBGE
  final String neighborhood;       // Bairro (da lista de Rio do Sul ou digitado)
  final String referencePoint;     // Ponto de referência próximo
  final String description;        // Descrição detalhada da situação
  final String? photoPath;         // Caminho local da foto ou URL futura do Firebase Storage
  final RequestStatus status;      // Aberto, Em atendimento, Concluído
  final String authorId;
  final String authorName;
  final String? authorPhone;       // Para contato opcional via WhatsApp
  final String? helperId;          // ID do voluntário que assumiu o pedido
  final String? helperName;        // Nome do voluntário que está ajudando
  final String? helperCommitment;  // O que o voluntário informou que vai fornecer
  final DateTime createdAt;

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
  });

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
    };
  }

  factory HelpRequestModel.fromMap(Map<String, dynamic> map) {
    final rawNeeds = (map['needs']?.toString() ?? '')
        .split(',')
        .where((s) => s.trim().isNotEmpty)
        .map(NeedType.fromString)
        .toList();

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
    );
  }
}
