import 'package:flutter/material.dart';

enum UserRole {
  citizen,
  volunteer,
  organization;

  String get label {
    switch (this) {
      case UserRole.citizen:
        return 'Cidadão';
      case UserRole.volunteer:
        return 'Voluntário';
      case UserRole.organization:
        return 'ONG / Protetor';
    }
  }

  String get description {
    switch (this) {
      case UserRole.citizen:
        return 'Quero registrar animais que precisam de ajuda e acompanhar o atendimento.';
      case UserRole.volunteer:
        return 'Quero assumir pedidos, levar água/ração, oferecer lar temporário ou participar de mutirões.';
      case UserRole.organization:
        return 'Represento uma ONG ou grupo protetor e quero painel de gestão, adoção, eventos e campanhas.';
    }
  }

  IconData get icon {
    switch (this) {
      case UserRole.citizen:
        return Icons.person_outline_rounded;
      case UserRole.volunteer:
        return Icons.volunteer_activism_outlined;
      case UserRole.organization:
        return Icons.apartment_outlined;
    }
  }

  static UserRole fromString(String? value) {
    return UserRole.values.firstWhere(
      (e) => e.name == value,
      orElse: () => UserRole.citizen,
    );
  }
}

class UserModel {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String defaultCity;
  final UserRole role;
  final String? organizationId;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.defaultCity = 'Rio do Sul',
    this.role = UserRole.citizen,
    this.organizationId,
  });

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? defaultCity,
    UserRole? role,
    String? organizationId,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      defaultCity: defaultCity ?? this.defaultCity,
      role: role ?? this.role,
      organizationId: organizationId ?? this.organizationId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'defaultCity': defaultCity,
      'role': role.name,
      'organizationId': organizationId,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> map) {
    return UserModel(
      id: map['id']?.toString() ?? 'user_demo',
      name: map['name']?.toString() ?? 'Voluntário Comunitário',
      email: map['email']?.toString() ?? 'voluntario@redepatas.org',
      phone: map['phone']?.toString(),
      defaultCity: map['defaultCity']?.toString() ?? 'Rio do Sul',
      role: UserRole.fromString(map['role']?.toString()),
      organizationId: map['organizationId']?.toString(),
    );
  }
}
