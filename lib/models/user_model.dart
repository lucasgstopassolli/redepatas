class UserModel {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String defaultCity;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.defaultCity = 'Rio do Sul',
  });

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? defaultCity,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      defaultCity: defaultCity ?? this.defaultCity,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'defaultCity': defaultCity,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> map) {
    return UserModel(
      id: map['id']?.toString() ?? 'user_demo',
      name: map['name']?.toString() ?? 'Voluntário Comunitário',
      email: map['email']?.toString() ?? 'voluntario@redepatas.org',
      phone: map['phone']?.toString(),
      defaultCity: map['defaultCity']?.toString() ?? 'Rio do Sul',
    );
  }
}
