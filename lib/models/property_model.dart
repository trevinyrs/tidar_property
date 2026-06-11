import 'package:cloud_firestore/cloud_firestore.dart';

class Property {
  final String id;
  final String title;
  final String description;
  final String address;
  final String location;
  final double price;
  final String type;
  
  // Field spesifikasi baru sesuai Figma
  final int bedrooms;        // Kamar Tidur
  final int bathrooms;       // Kamar Mandi
  final double landArea;     // Luas Tanah (m²)
  final double buildingArea; // Luas Bangunan (m²)
  
  final String status;
  final String agentId;
  final String? brId;
  final List<String> imageUrls;
  final DateTime createdAt;

  Property({
    required this.id,
    required this.title,
    required this.description,
    required this.address,
    required this.location,
    required this.price,
    required this.type,
    required this.bedrooms,
    required this.bathrooms,
    required this.landArea,
    required this.buildingArea,
    required this.status,
    required this.agentId,
    this.brId,
    this.imageUrls = const [],
    required this.createdAt,
  });

  factory Property.fromMap(Map<String, dynamic> map, String id) {
    return Property(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      address: map['address'] ?? '',
      location: map['location'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      type: map['type'] ?? 'rumah',
      bedrooms: map['bedrooms'] ?? 0,
      bathrooms: map['bathrooms'] ?? 0,
      landArea: (map['landArea'] ?? 0).toDouble(),
      buildingArea: (map['buildingArea'] ?? 0).toDouble(),
      status: map['status'] ?? 'AVAILABLE',
      agentId: map['agentId'] ?? '',
      brId: map['brId'],
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  get area => null;

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'address': address,
      'location': location,
      'price': price,
      'type': type,
      'bedrooms': bedrooms,
      'bathrooms': bathrooms,
      'landArea': landArea,
      'buildingArea': buildingArea,
      'status': status,
      'agentId': agentId,
      'brId': brId,
      'imageUrls': imageUrls,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}