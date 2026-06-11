import 'package:cloud_firestore/cloud_firestore.dart';

class MouDocument {
  final String idMou;
  final String? idAgent;
  final String? idBank;
  final String jenisMou;
  final String fileMou;
  final DateTime tanggalUpload;
  final String statusMou; // Terbatas pada: ["Draf", "Revisi", "Menunggu TTD", "Aktif"]
  final String? catatanRevisi;
  final DateTime createdAt;

  // Properti tambahan untuk kompatibilitas UI lama (jika ada)
  final String title;
  final String fileName;
  final String fileSize;

  MouDocument({
    required this.idMou,
    this.idAgent,
    this.idBank,
    required this.jenisMou,
    required this.fileMou,
    required this.tanggalUpload,
    required this.statusMou,
    this.catatanRevisi,
    required this.createdAt,
    
    // Opsional untuk kompatibilitas
    this.title = '',
    this.fileName = '',
    this.fileSize = '',
  });

  factory MouDocument.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return MouDocument(
      idMou: doc.id,
      idAgent: data['id_agent'],
      idBank: data['id_bank'],
      jenisMou: data['jenis_mou'] ?? data['type'] ?? 'Bank',
      fileMou: data['file_mou'] ?? data['fileName'] ?? '',
      tanggalUpload: (data['tanggal_upload'] as Timestamp?)?.toDate() ?? DateTime.now(),
      statusMou: data['status_mou'] ?? data['status'] ?? 'Draf',
      catatanRevisi: data['catatan_revisi'],
      createdAt: (data['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
      
      title: data['title'] ?? data['fileName'] ?? '',
      fileName: data['fileName'] ?? data['file_mou'] ?? '',
      fileSize: data['fileSize'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id_agent': idAgent,
      'id_bank': idBank,
      'jenis_mou': jenisMou,
      'file_mou': fileMou,
      'tanggal_upload': Timestamp.fromDate(tanggalUpload),
      'status_mou': statusMou,
      'catatan_revisi': catatanRevisi,
      'created_at': Timestamp.fromDate(createdAt),
      
      'title': title,
      'fileName': fileName,
      'fileSize': fileSize,
    };
  }

  // Kompatibilitas dari fromMap & toMap
  factory MouDocument.fromMap(Map<String, dynamic> map, String id) {
    DateTime parsedUpload;
    if (map['tanggal_upload'] is Timestamp) {
      parsedUpload = (map['tanggal_upload'] as Timestamp).toDate();
    } else if (map['uploadedAt'] is String) {
      parsedUpload = DateTime.tryParse(map['uploadedAt']) ?? DateTime.now();
    } else {
      parsedUpload = DateTime.now();
    }

    return MouDocument(
      idMou: id,
      idAgent: map['id_agent'],
      idBank: map['id_bank'],
      jenisMou: map['jenis_mou'] ?? map['type'] ?? 'Bank',
      fileMou: map['file_mou'] ?? map['fileName'] ?? '',
      tanggalUpload: parsedUpload,
      statusMou: map['status_mou'] ?? map['status'] ?? 'Draf',
      catatanRevisi: map['catatan_revisi'],
      createdAt: (map['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
      
      title: map['title'] ?? map['fileName'] ?? '',
      fileName: map['fileName'] ?? map['file_mou'] ?? '',
      fileSize: map['fileSize'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return toFirestore();
  }

  // Getter pembantu kompatibilitas UI
  String get id => idMou;
  String get type => jenisMou;
  String get status => statusMou;
  String get uploadedAt => tanggalUpload.toIso8601String();
}