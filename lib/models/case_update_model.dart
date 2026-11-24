import 'package:flutter/material.dart';

enum CaseUpdateType {
  criado,
  assumido,
  atualizacao,
  foto,
  concluido,
  reaberto;

  String get label {
    switch (this) {
      case CaseUpdateType.criado:
        return 'Pedido criado';
      case CaseUpdateType.assumido:
        return 'Voluntário assumiu';
      case CaseUpdateType.atualizacao:
        return 'Atualização';
      case CaseUpdateType.foto:
        return 'Nova foto';
      case CaseUpdateType.concluido:
        return 'Caso concluído';
      case CaseUpdateType.reaberto:
        return 'Pedido reaberto';
    }
  }

  IconData get icon {
    switch (this) {
      case CaseUpdateType.criado:
        return Icons.add_circle_outline_rounded;
      case CaseUpdateType.assumido:
        return Icons.volunteer_activism_outlined;
      case CaseUpdateType.atualizacao:
        return Icons.chat_bubble_outline_rounded;
      case CaseUpdateType.foto:
        return Icons.photo_camera_outlined;
      case CaseUpdateType.concluido:
        return Icons.check_circle_outline_rounded;
      case CaseUpdateType.reaberto:
        return Icons.replay_rounded;
    }
  }

  static CaseUpdateType fromString(String? value) {
    return CaseUpdateType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => CaseUpdateType.atualizacao,
    );
  }
}

class CaseUpdateModel {
  final String id;
  final String requestId;
  final String authorId;
  final String authorName;
  final CaseUpdateType type;
  final String message;
  final String? photoPath;
  final DateTime createdAt;

  const CaseUpdateModel({
    required this.id,
    required this.requestId,
    required this.authorId,
    required this.authorName,
    required this.type,
    required this.message,
    this.photoPath,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'requestId': requestId,
        'authorId': authorId,
        'authorName': authorName,
        'type': type.name,
        'message': message,
        'photoPath': photoPath,
        'createdAt': createdAt.toIso8601String(),
      };

  factory CaseUpdateModel.fromMap(Map<String, dynamic> map) {
    return CaseUpdateModel(
      id: map['id'].toString(),
      requestId: map['requestId']?.toString() ?? '',
      authorId: map['authorId']?.toString() ?? '',
      authorName: map['authorName']?.toString() ?? 'Voluntário',
      type: CaseUpdateType.fromString(map['type']?.toString()),
      message: map['message']?.toString() ?? '',
      photoPath: map['photoPath']?.toString(),
      createdAt:
          DateTime.tryParse(map['createdAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }
}
