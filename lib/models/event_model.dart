import 'package:flutter/material.dart';

enum EventType {
  mutirao,
  feiraAdocao,
  vacinacao,
  campanha;

  String get label {
    switch (this) {
      case EventType.mutirao:
        return 'Mutirão';
      case EventType.feiraAdocao:
        return 'Feira de Adoção';
      case EventType.vacinacao:
        return 'Vacinação / Castração';
      case EventType.campanha:
        return 'Campanha';
    }
  }

  IconData get icon {
    switch (this) {
      case EventType.mutirao:
        return Icons.groups_outlined;
      case EventType.feiraAdocao:
        return Icons.pets_outlined;
      case EventType.vacinacao:
        return Icons.vaccines_outlined;
      case EventType.campanha:
        return Icons.campaign_outlined;
    }
  }

  static EventType fromString(String? value) {
    if (value == 'feira_adocao') return EventType.feiraAdocao;
    return EventType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => EventType.mutirao,
    );
  }
}

class CommunityEventModel {
  final String id;
  final String organizationId;
  final String title;
  final EventType type;
  final String description;
  final String city;
  final String address;
  final double? latitude;
  final double? longitude;
  final DateTime startsAt;
  final DateTime? endsAt;
  final int capacity;
  final DateTime createdAt;

  const CommunityEventModel({
    required this.id,
    required this.organizationId,
    required this.title,
    required this.type,
    required this.description,
    required this.city,
    required this.address,
    this.latitude,
    this.longitude,
    required this.startsAt,
    this.endsAt,
    this.capacity = 20,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'organizationId': organizationId,
        'title': title,
        'type': type.name,
        'description': description,
        'city': city,
        'address': address,
        'latitude': latitude,
        'longitude': longitude,
        'startsAt': startsAt.toIso8601String(),
        'endsAt': endsAt?.toIso8601String(),
        'capacity': capacity,
        'createdAt': createdAt.toIso8601String(),
      };

  factory CommunityEventModel.fromMap(Map<String, dynamic> map) {
    double? parseDouble(dynamic v) =>
        v == null ? null : (v is num ? v.toDouble() : double.tryParse(v.toString()));

    return CommunityEventModel(
      id: map['id'].toString(),
      organizationId: map['organizationId']?.toString() ?? 'org_apad_demo',
      title: map['title']?.toString() ?? '',
      type: EventType.fromString(map['type']?.toString()),
      description: map['description']?.toString() ?? '',
      city: map['city']?.toString() ?? 'Rio do Sul',
      address: map['address']?.toString() ?? '',
      latitude: parseDouble(map['latitude']),
      longitude: parseDouble(map['longitude']),
      startsAt:
          DateTime.tryParse(map['startsAt']?.toString() ?? '') ?? DateTime.now(),
      endsAt: map['endsAt'] != null
          ? DateTime.tryParse(map['endsAt'].toString())
          : null,
      capacity: int.tryParse(map['capacity']?.toString() ?? '') ?? 20,
      createdAt:
          DateTime.tryParse(map['createdAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }
}

class EventSignupModel {
  final String id;
  final String eventId;
  final String userId;
  final String userName;
  final String? phone;
  final bool attended;
  final DateTime createdAt;

  const EventSignupModel({
    required this.id,
    required this.eventId,
    required this.userId,
    required this.userName,
    this.phone,
    this.attended = false,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'eventId': eventId,
        'userId': userId,
        'userName': userName,
        'phone': phone,
        'attended': attended ? 1 : 0,
        'createdAt': createdAt.toIso8601String(),
      };

  factory EventSignupModel.fromMap(Map<String, dynamic> map) {
    return EventSignupModel(
      id: map['id'].toString(),
      eventId: map['eventId']?.toString() ?? '',
      userId: map['userId']?.toString() ?? '',
      userName: map['userName']?.toString() ?? '',
      phone: map['phone']?.toString(),
      attended: map['attended'] == 1 || map['attended'] == true,
      createdAt:
          DateTime.tryParse(map['createdAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }
}
