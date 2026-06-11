import 'package:cloud_firestore/cloud_firestore.dart';

class Property {
  final String idProperti;
  final String idProyek;
  final String kodeUnit;
  final String tipeRumah;
  final double luasTanah;
  final double luasBangunan;
  final int kamarTidur;
  final int kamarMandi;
  final double harga;
  final String statusProperti; // Terbatas pada: ["Available", "Sold"]
  final DateTime createdAt;

  // Properti tambahan untuk kompatibilitas UI lama (jika ada)
  final String title;
  final String description;
  final String address;
  final String location;
  final String agentId;
  final String? brId;
  final List<String> imageUrls;
  final double? latitude;
  final double? longitude;

  Property({
    required this.idProperti,
    required this.idProyek,
    required this.kodeUnit,
    required this.tipeRumah,
    required this.luasTanah,
    required this.luasBangunan,
    required this.kamarTidur,
    required this.kamarMandi,
    required this.harga,
    required this.statusProperti,
    required this.createdAt,
    
    // Opsional untuk kompatibilitas
    this.title = '',
    this.description = '',
    this.address = '',
    this.location = '',
    this.agentId = '',
    this.brId,
    this.imageUrls = const [],
    this.latitude,
    this.longitude,
  });

  factory Property.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return Property(
      idProperti: doc.id,
      idProyek: data['id_proyek'] ?? '',
      kodeUnit: data['kode_unit'] ?? '',
      tipeRumah: data['tipe_rumah'] ?? data['type'] ?? '',
      luasTanah: (data['luas_tanah'] ?? data['landArea'] ?? 0).toDouble(),
      luasBangunan: (data['luas_bangunan'] ?? data['buildingArea'] ?? 0).toDouble(),
      kamarTidur: (data['kamar_tidur'] ?? data['bedrooms'] ?? 0).toInt(),
      kamarMandi: (data['kamar_mandi'] ?? data['bathrooms'] ?? 0).toInt(),
      harga: (data['harga'] ?? data['price'] ?? 0).toDouble(),
      statusProperti: data['status_properti'] ?? data['status'] ?? 'Available',
      createdAt: (data['created_at'] as Timestamp?)?.toDate() ?? (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      address: data['address'] ?? '',
      location: data['location'] ?? '',
      agentId: data['agentId'] ?? '',
      brId: data['brId'],
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      latitude: (data['latitude'] as num?)?.toDouble(),
      longitude: (data['longitude'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id_proyek': idProyek,
      'kode_unit': kodeUnit,
      'tipe_rumah': tipeRumah,
      'luas_tanah': luasTanah,
      'luas_bangunan': luasBangunan,
      'kamar_tidur': kamarTidur,
      'kamar_mandi': kamarMandi,
      'harga': harga,
      'status_properti': statusProperti,
      'created_at': Timestamp.fromDate(createdAt),
      
      'title': title,
      'description': description,
      'address': address,
      'location': location,
      'agentId': agentId,
      'brId': brId,
      'imageUrls': imageUrls,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  // Kompatibilitas dari fromMap & toMap
  factory Property.fromMap(Map<String, dynamic> map, String id) {
    return Property(
      idProperti: id,
      idProyek: map['id_proyek'] ?? '',
      kodeUnit: map['kode_unit'] ?? '',
      tipeRumah: map['tipe_rumah'] ?? map['type'] ?? '',
      luasTanah: (map['luas_tanah'] ?? map['landArea'] ?? 0).toDouble(),
      luasBangunan: (map['luas_bangunan'] ?? map['buildingArea'] ?? 0).toDouble(),
      kamarTidur: (map['kamar_tidur'] ?? map['bedrooms'] ?? 0).toInt(),
      kamarMandi: (map['kamar_mandi'] ?? map['bathrooms'] ?? 0).toInt(),
      harga: (map['harga'] ?? map['price'] ?? 0).toDouble(),
      statusProperti: map['status_properti'] ?? map['status'] ?? 'Available',
      createdAt: (map['created_at'] as Timestamp?)?.toDate() ?? (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      address: map['address'] ?? '',
      location: map['location'] ?? '',
      agentId: map['agentId'] ?? '',
      brId: map['brId'],
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return toFirestore();
  }

  // Getter pembantu kompatibilitas UI
  String get id => idProperti;
  String get type => tipeRumah;
  double get landArea => luasTanah;
  double get buildingArea => luasBangunan;
  int get bedrooms => kamarTidur;
  int get bathrooms => kamarMandi;
  double get price => harga;
  String get status => statusProperti;

  Property copyWith({
    String? idProperti,
    String? idProyek,
    String? kodeUnit,
    String? tipeRumah,
    double? luasTanah,
    double? luasBangunan,
    int? kamarTidur,
    int? kamarMandi,
    double? harga,
    String? statusProperti,
    DateTime? createdAt,
    String? title,
    String? description,
    String? address,
    String? location,
    String? agentId,
    String? brId,
    List<String>? imageUrls,
    double? latitude,
    double? longitude,
  }) {
    return Property(
      idProperti: idProperti ?? this.idProperti,
      idProyek: idProyek ?? this.idProyek,
      kodeUnit: kodeUnit ?? this.kodeUnit,
      tipeRumah: tipeRumah ?? this.tipeRumah,
      luasTanah: luasTanah ?? this.luasTanah,
      luasBangunan: luasBangunan ?? this.luasBangunan,
      kamarTidur: kamarTidur ?? this.kamarTidur,
      kamarMandi: kamarMandi ?? this.kamarMandi,
      harga: harga ?? this.harga,
      statusProperti: statusProperti ?? this.statusProperti,
      createdAt: createdAt ?? this.createdAt,
      title: title ?? this.title,
      description: description ?? this.description,
      address: address ?? this.address,
      location: location ?? this.location,
      agentId: agentId ?? this.agentId,
      brId: brId ?? this.brId,
      imageUrls: imageUrls ?? this.imageUrls,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }
}

class PropertyPhoto {
  final String idFoto;
  final String idProperti;
  final String urlFile;
  final String namaFile;
  final DateTime createdAt;

  PropertyPhoto({
    required this.idFoto,
    required this.idProperti,
    required this.urlFile,
    required this.namaFile,
    required this.createdAt,
  });

  factory PropertyPhoto.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return PropertyPhoto(
      idFoto: doc.id,
      idProperti: data['id_properti'] ?? '',
      urlFile: data['url_file'] ?? '',
      namaFile: data['nama_file'] ?? '',
      createdAt: (data['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id_properti': idProperti,
      'url_file': urlFile,
      'nama_file': namaFile,
      'created_at': Timestamp.fromDate(createdAt),
    };
  }
}