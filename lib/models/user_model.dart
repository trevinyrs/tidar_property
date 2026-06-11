import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole {
  agent('Agent'),
  br('BR'),
  legal('Legal'),
  manager('Manager');

  final String value;
  const UserRole(this.value);

  factory UserRole.fromString(String val) {
    return UserRole.values.firstWhere(
      (e) => e.value.toLowerCase() == val.toLowerCase(),
      orElse: () => UserRole.agent,
    );
  }
}

class AppUser {
  final String idUser;
  final String nama;
  final String email;
  final UserRole role;
  final String noHp;
  final String status;
  final DateTime createdAt;
  final String? password;
  final String? fotoProfil;

  AppUser({
    required this.idUser,
    required this.nama,
    required this.email,
    required this.role,
    required this.noHp,
    required this.status,
    required this.createdAt,
    this.password,
    this.fotoProfil,
  });

  factory AppUser.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return AppUser(
      idUser: doc.id,
      nama: data['nama'] ?? '',
      email: data['email'] ?? '',
      role: UserRole.fromString(data['role'] ?? ''),
      noHp: data['no_hp'] ?? '',
      status: data['status'] ?? 'Aktif',
      createdAt: (data['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
      password: data['password'],
      fotoProfil: data['foto_profil'],
    );
  }

  Map<String, dynamic> toFirestore() {
    final map = {
      'nama': nama,
      'email': email,
      'role': role.value,
      'no_hp': noHp,
      'status': status,
      'created_at': Timestamp.fromDate(createdAt),
      'foto_profil': fotoProfil ?? '',
    };
    if (password != null) {
      map['password'] = password!;
    }
    return map;
  }

  // Menjaga kompatibilitas dengan model lama
  factory AppUser.fromMap(Map<String, dynamic> map, String uid) {
    return AppUser(
      idUser: uid,
      nama: map['nama'] ?? map['name'] ?? '',
      email: map['email'] ?? '',
      role: UserRole.fromString(map['role'] ?? ''),
      noHp: map['no_hp'] ?? map['phone'] ?? '',
      status: map['status'] ?? 'Aktif',
      createdAt: (map['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
      password: map['password'],
      fotoProfil: map['foto_profil'] ?? map['photoUrl'] ?? map['photo_url'],
    );
  }

  Map<String, dynamic> toMap() {
    return toFirestore();
  }

  // Helper untuk model lama
  String get uid => idUser;
  String get name => nama;
  String get phone => noHp;
}