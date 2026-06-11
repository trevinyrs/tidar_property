import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/property_model.dart';

class PropertyService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Tambah Properti Baru
  Future<String?> addProperty(Property property) async {
    try {
      DocumentReference doc = await _db.collection('properties').add(property.toMap());
      return doc.id;
    } catch (e) {
      print("Error add property: $e");
      return null;
    }
  }

  // Update Properti (Real-time)
  Future<bool> updateProperty(Property property) async {
    try {
      await _db.collection('properties').doc(property.id).update(property.toMap());
      print("Property updated successfully: ${property.id}");
      return true;
    } catch (e) {
      print("Error update property: $e");
      return false;
    }
  }

  // Ambil Semua Properti (Real-time)
  Stream<List<Property>> getProperties() {
    return _db.collection('properties')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Property.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Ambil Properti berdasarkan Agent
  Stream<List<Property>> getAgentProperties(String agentId) {
    return _db.collection('properties')
        .where('agentId', isEqualTo: agentId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Property.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Hapus Properti (Opsional)
  Future<bool> deleteProperty(String propertyId) async {
    try {
      await _db.collection('properties').doc(propertyId).delete();
      return true;
    } catch (e) {
      print("Error delete property: $e");
      return false;
    }
  }
}