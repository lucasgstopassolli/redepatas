enum CampaignKind {
  item,
  dinheiro;

  String get label {
    switch (this) {
      case CampaignKind.item:
        return 'Itens / Suprimentos';
      case CampaignKind.dinheiro:
        return 'Financeira (Pix)';
    }
  }

  static CampaignKind fromString(String? value) {
    return CampaignKind.values.firstWhere(
      (e) => e.name == value,
      orElse: () => CampaignKind.item,
    );
  }
}

class CampaignModel {
  final String id;
  final String organizationId;
  final String title;
  final String description;
  final CampaignKind kind;
  final double goalAmount;
  final double currentAmount;
  final String unit; // kg, unidades, R$
  final DateTime? deadline;
  final String status; // ativa / encerrada
  final DateTime createdAt;

  const CampaignModel({
    required this.id,
    required this.organizationId,
    required this.title,
    required this.description,
    required this.kind,
    required this.goalAmount,
    this.currentAmount = 0,
    required this.unit,
    this.deadline,
    this.status = 'ativa',
    required this.createdAt,
  });

  double get progress {
    if (goalAmount <= 0) return 0;
    return (currentAmount / goalAmount).clamp(0.0, 1.0);
  }

  int get progressPercent => (progress * 100).round();

  CampaignModel copyWith({
    String? id,
    String? organizationId,
    String? title,
    String? description,
    CampaignKind? kind,
    double? goalAmount,
    double? currentAmount,
    String? unit,
    DateTime? deadline,
    String? status,
    DateTime? createdAt,
  }) {
    return CampaignModel(
      id: id ?? this.id,
      organizationId: organizationId ?? this.organizationId,
      title: title ?? this.title,
      description: description ?? this.description,
      kind: kind ?? this.kind,
      goalAmount: goalAmount ?? this.goalAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      unit: unit ?? this.unit,
      deadline: deadline ?? this.deadline,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'organizationId': organizationId,
        'title': title,
        'description': description,
        'kind': kind.name,
        'goalAmount': goalAmount,
        'currentAmount': currentAmount,
        'unit': unit,
        'deadline': deadline?.toIso8601String(),
        'status': status,
        'createdAt': createdAt.toIso8601String(),
      };

  factory CampaignModel.fromMap(Map<String, dynamic> map) {
    double parseDouble(dynamic v) =>
        v == null ? 0.0 : (v is num ? v.toDouble() : double.tryParse(v.toString()) ?? 0.0);

    return CampaignModel(
      id: map['id'].toString(),
      organizationId: map['organizationId']?.toString() ?? 'org_apad_demo',
      title: map['title']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      kind: CampaignKind.fromString(map['kind']?.toString()),
      goalAmount: parseDouble(map['goalAmount']),
      currentAmount: parseDouble(map['currentAmount']),
      unit: map['unit']?.toString() ?? 'un',
      deadline: map['deadline'] != null
          ? DateTime.tryParse(map['deadline'].toString())
          : null,
      status: map['status']?.toString() ?? 'ativa',
      createdAt:
          DateTime.tryParse(map['createdAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }
}

class DonationModel {
  final String id;
  final String campaignId;
  final String donorName;
  final double amount;
  final String? note;
  final DateTime createdAt;

  const DonationModel({
    required this.id,
    required this.campaignId,
    required this.donorName,
    required this.amount,
    this.note,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'campaignId': campaignId,
        'donorName': donorName,
        'amount': amount,
        'note': note,
        'createdAt': createdAt.toIso8601String(),
      };

  factory DonationModel.fromMap(Map<String, dynamic> map) {
    double parseDouble(dynamic v) =>
        v == null ? 0.0 : (v is num ? v.toDouble() : double.tryParse(v.toString()) ?? 0.0);

    return DonationModel(
      id: map['id'].toString(),
      campaignId: map['campaignId']?.toString() ?? '',
      donorName: map['donorName']?.toString() ?? 'Apoiador',
      amount: parseDouble(map['amount']),
      note: map['note']?.toString(),
      createdAt:
          DateTime.tryParse(map['createdAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }
}
