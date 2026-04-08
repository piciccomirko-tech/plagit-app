class User {
  final String id;
  final String email;
  final String role;
  final String? name;
  final String? firstName;
  final String? lastName;
  final String? photoUrl;
  final DateTime? createdAt;

  const User({
    required this.id,
    required this.email,
    required this.role,
    this.name,
    this.firstName,
    this.lastName,
    this.photoUrl,
    this.createdAt,
  });

  String get fullName {
    if (name != null && name!.isNotEmpty) return name!;
    return [firstName, lastName].whereType<String>().join(' ');
  }

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'].toString(),
    email: json['email'] as String,
    role: json['role'] as String,
    name: json['name'] as String?,
    firstName: (json['first_name'] ?? json['firstName']) as String?,
    lastName: (json['last_name'] ?? json['lastName']) as String?,
    photoUrl: (json['photo_url'] ?? json['photoUrl']) as String?,
    createdAt: json['created_at'] != null
        ? DateTime.tryParse(json['created_at'].toString())
        : json['createdAt'] != null
            ? DateTime.tryParse(json['createdAt'].toString())
            : null,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'role': role,
    'name': name,
    'first_name': firstName,
    'last_name': lastName,
    'photo_url': photoUrl,
    if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
  };
}
