import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/project_model.dart';

class ProjectService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Ambil Semua Proyek (Real-time Stream)
  Stream<List<Project>> getProjects() {
    return _db.collection('tb_proyek')
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Project.fromFirestore(doc))
            .toList());
  }

  // Tambah Proyek Baru
  Future<String?> addProject(Project project) async {
    try {
      DocumentReference doc = await _db.collection('tb_proyek').add(project.toFirestore());
      return doc.id;
    } catch (e) {
      print("Error adding project: $e");
      return null;
    }
  }

  // Ambil Single Proyek
  Future<Project?> getProject(String idProyek) async {
    try {
      DocumentSnapshot doc = await _db.collection('tb_proyek').doc(idProyek).get();
      if (doc.exists) {
        return Project.fromFirestore(doc);
      }
    } catch (e) {
      print("Error getting project: $e");
    }
    return null;
  }
}
