import 'package:cloud_firestore/cloud_firestore.dart';

class Project {
  final String idProyek;
  final String namaProyek;
  final String lokasi;
  final String deskripsi;
  final String statusProyek;
  final DateTime createdAt;

  Project({
    required this.idProyek,
    required this.namaProyek,
    required this.lokasi,
    required this.deskripsi,
    required this.statusProyek,
    required this.createdAt,
  });

  factory Project.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return Project(
      idProyek: doc.id,
      namaProyek: data['nama_proyek'] ?? '',
      lokasi: data['lokasi'] ?? '',
      deskripsi: data['deskripsi'] ?? '',
      statusProyek: data['status_proyek'] ?? 'Aktif',
      createdAt: (data['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'nama_proyek': namaProyek,
      'lokasi': lokasi,
      'deskripsi': deskripsi,
      'status_proyek': statusProyek,
      'created_at': Timestamp.fromDate(createdAt),
    };
  }

  // Kompatibilitas helper dari Map
  factory Project.fromMap(Map<String, dynamic> map, String id) {
    return Project(
      idProyek: id,
      namaProyek: map['nama_proyek'] ?? '',
      lokasi: map['lokasi'] ?? '',
      deskripsi: map['deskripsi'] ?? '',
      statusProyek: map['status_proyek'] ?? 'Aktif',
      createdAt: (map['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return toFirestore();
  }

  // Getter pembantu kompatibilitas UI
  String get id => idProyek;
  String get name => namaProyek;
}
