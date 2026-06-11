enum UserRole {
  agent,
  br,
  legal,
  manager,
}

class AppUser {
  final String uid;
  final String email;
  final String name;
  final UserRole role;
  final String? phone;
  final String? photoUrl;

  AppUser({
    required this.uid,
    required this.email,
    required this.name,
    required this.role,
    this.phone,
    this.photoUrl,
  });

  factory AppUser.fromMap(Map<String, dynamic> map, String uid) {
    return AppUser(
      uid: uid,
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      role: UserRole.values.byName(map['role'] ?? 'agent'),
      phone: map['phone'],
      photoUrl: map['photoUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'role': role.name,
      'phone': phone,
      'photoUrl': photoUrl,
    };
  }
}