class UserModel {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? country;
  final String role;
  final String? avatar;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.country,
    required this.role,
    this.avatar,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        email: json['email']?.toString() ?? '',
        phone: json['phone']?.toString(),
        country: json['country']?.toString(),
        role: json['role']?.toString() ?? 'user',
        avatar: json['avatar']?.toString(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'phone': phone,
        'country': country,
        'role': role,
        'avatar': avatar,
      };

  bool get isAdmin => role == 'admin';
}
