import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class MouDocument {
  final String idMou;
  final String? idAgent;
  final String? idBank;
  final String jenisMou;
  final String fileMou;
  final String? fileMouFinal;
  final DateTime tanggalUpload;
  final String statusMou; // Terbatas pada: ["Draf", "Revisi", "Menunggu TTD", "Aktif"]
  final String? catatanRevisi;
  final String? catatan;
  final String? namaPrincipal;
  final String? logoUrl;
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
    this.fileMouFinal,
    required this.tanggalUpload,
    required this.statusMou,
    this.catatanRevisi,
    this.catatan,
    this.namaPrincipal,
    this.logoUrl,
    required this.createdAt,
    
    // Opsional untuk kompatibilitas
    this.title = '',
    this.fileName = '',
    this.fileSize = '',
  });

  static DateTime _parseTanggalUpload(dynamic val) {
    if (val == null) return DateTime.now();
    if (val is Timestamp) return val.toDate();
    if (val is DateTime) return val;
    if (val is String) {
      try {
        return DateFormat("d MMM yyyy").parse(val);
      } catch (_) {
        try {
          return DateTime.parse(val);
        } catch (_) {
          return DateTime.now();
        }
      }
    }
    return DateTime.now();
  }

  factory MouDocument.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return MouDocument(
      idMou: doc.id,
      idAgent: data['id_agent'],
      idBank: data['id_bank'],
      jenisMou: data['jenis_mou'] ?? data['type'] ?? 'Bank',
      fileMou: data['file_mou'] ?? data['fileName'] ?? '',
      fileMouFinal: data['file_mou_final'],
      tanggalUpload: _parseTanggalUpload(data['tanggal_upload']),
      statusMou: data['status_mou'] ?? data['status'] ?? 'Draf',
      catatanRevisi: data['catatan_revisi'],
      catatan: data['catatan'],
      namaPrincipal: data['nama_principal'],
      logoUrl: data['logo_url'],
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
      'file_mou_final': fileMouFinal,
      'tanggal_upload': Timestamp.fromDate(tanggalUpload),
      'status_mou': statusMou,
      'catatan_revisi': catatanRevisi,
      'catatan': catatan,
      'nama_principal': namaPrincipal,
      'logo_url': logoUrl,
      'created_at': Timestamp.fromDate(createdAt),
      
      'title': title,
      'fileName': fileName,
      'fileSize': fileSize,
    };
  }

  // Kompatibilitas dari fromMap & toMap
  factory MouDocument.fromMap(Map<String, dynamic> map, String id) {
    return MouDocument(
      idMou: id,
      idAgent: map['id_agent'],
      idBank: map['id_bank'],
      jenisMou: map['jenis_mou'] ?? map['type'] ?? 'Bank',
      fileMou: map['file_mou'] ?? map['fileName'] ?? '',
      fileMouFinal: map['file_mou_final'],
      tanggalUpload: _parseTanggalUpload(map['tanggal_upload'] ?? map['uploadedAt']),
      statusMou: map['status_mou'] ?? map['status'] ?? 'Draf',
      catatanRevisi: map['catatan_revisi'],
      catatan: map['catatan'],
      namaPrincipal: map['nama_principal'],
      logoUrl: map['logo_url'],
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

  MouDocument copyWith({
    String? idMou,
    String? idAgent,
    String? idBank,
    String? jenisMou,
    String? fileMou,
    String? fileMouFinal,
    DateTime? tanggalUpload,
    String? statusMou,
    String? catatanRevisi,
    String? catatan,
    String? namaPrincipal,
    String? logoUrl,
    DateTime? createdAt,
    String? title,
    String? fileName,
    String? fileSize,
  }) {
    return MouDocument(
      idMou: idMou ?? this.idMou,
      idAgent: idAgent ?? this.idAgent,
      idBank: idBank ?? this.idBank,
      jenisMou: jenisMou ?? this.jenisMou,
      fileMou: fileMou ?? this.fileMou,
      fileMouFinal: fileMouFinal ?? this.fileMouFinal,
      tanggalUpload: tanggalUpload ?? this.tanggalUpload,
      statusMou: statusMou ?? this.statusMou,
      catatanRevisi: catatanRevisi ?? this.catatanRevisi,
      catatan: catatan ?? this.catatan,
      namaPrincipal: namaPrincipal ?? this.namaPrincipal,
      logoUrl: logoUrl ?? this.logoUrl,
      createdAt: createdAt ?? this.createdAt,
      title: title ?? this.title,
      fileName: fileName ?? this.fileName,
      fileSize: fileSize ?? this.fileSize,
    );
  }
}