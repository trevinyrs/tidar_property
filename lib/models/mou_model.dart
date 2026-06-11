import 'package:cloud_firestore/cloud_firestore.dart';

class MouDocument {
  final String id;
  final String title;
  final String fileName;
  final String fileSize;
  final String uploadedAt;
  final String type; 
  final String status; 

  MouDocument({
    required this.id,
    required this.title,
    required this.fileName,
    required this.fileSize,
    required this.uploadedAt,
    required this.type,
    this.status = "Pending",
  });

  factory MouDocument.fromMap(Map<String, dynamic> map, String id) {
    return MouDocument(
      id: id,
      title: map['title'] ?? '',
      fileName: map['fileName'] ?? '',
      fileSize: map['fileSize'] ?? '',
      uploadedAt: map['uploadedAt'] ?? '',
      type: map['type'] ?? 'Bank',
      status: map['status'] ?? 'Pending',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'fileName': fileName,
      'fileSize': fileSize,
      'uploadedAt': uploadedAt,
      'type': type,
      'status': status,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}