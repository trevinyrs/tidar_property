import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/mou_model.dart';

class MouService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Tambah MOU Baru
  Future<String?> addMou(MouDocument mou) async {
    try {
      DocumentReference doc = await _db.collection('tb_mou').add(mou.toFirestore());
      return doc.id;
    } catch (e) {
      print("Error add MOU: $e");
      return null;
    }
  }

  // Update MOU
  Future<bool> updateMou(MouDocument mou) async {
    try {
      await _db.collection('tb_mou').doc(mou.idMou).update(mou.toFirestore());
      return true;
    } catch (e) {
      print("Error update MOU: $e");
      return false;
    }
  }

  // Ambil Semua MOU (Real-time Stream)
  Stream<List<MouDocument>> getMousStream() {
    return _db.collection('tb_mou')
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MouDocument.fromFirestore(doc))
            .toList());
  }

  // Ambil MOU Berdasarkan Tipe/Jenis (Real-time Stream)
  Stream<List<MouDocument>> getMousByTypeStream(String type) {
    return _db.collection('tb_mou')
        .where('jenis_mou', isEqualTo: type)
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MouDocument.fromFirestore(doc))
            .toList());
  }

  // Ambil MOU Berdasarkan Tipe & Status
  Stream<List<MouDocument>> getMousByTypeAndStatusStream(String type, String status) {
    String prdStatus = status;
    if (status.toUpperCase() == 'ACTIVE' || status.toUpperCase() == 'AKTIF') prdStatus = 'Aktif';
    if (status.toUpperCase() == 'PROCESS' || status.toUpperCase() == 'PENDING') prdStatus = 'Draf';
    
    return _db.collection('tb_mou')
        .where('jenis_mou', isEqualTo: type)
        .where('status_mou', isEqualTo: prdStatus)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MouDocument.fromFirestore(doc))
            .toList());
  }

  // Ambil Limit MOU untuk Aktivitas Terbaru
  Stream<List<MouDocument>> getRecentMousStream({int limit = 5}) {
    return _db.collection('tb_mou')
        .orderBy('created_at', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MouDocument.fromFirestore(doc))
            .toList());
  }

  // Ambil MOU Berdasarkan Agen
  Stream<List<MouDocument>> getMousByAgentStream(String agentIdOrName) {
    return _db.collection('tb_mou')
        .where('jenis_mou', isEqualTo: 'Agent')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => MouDocument.fromFirestore(doc))
              .where((mou) => mou.idAgent == agentIdOrName || mou.title == agentIdOrName || mou.fileName == agentIdOrName)
              .toList();
        });
  }

  // Ambil MOU Berdasarkan Bank
  Stream<List<MouDocument>> getMousByBankStream(String bankName) {
    return _db.collection('tb_mou')
        .where('jenis_mou', isEqualTo: 'Bank')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => MouDocument.fromFirestore(doc))
              .where((mou) => mou.idBank == bankName || mou.title == bankName || mou.fileName == bankName)
              .toList();
        });
  }

  // Ambil Single MOU (Real-time Stream)
  Stream<MouDocument?> getMouStream(String idMou) {
    return _db.collection('tb_mou')
        .doc(idMou)
        .snapshots()
        .map((doc) => doc.exists ? MouDocument.fromFirestore(doc) : null);
  }

  // Hapus MOU
  Future<bool> deleteMou(String idMou) async {
    try {
      await _db.collection('tb_mou').doc(idMou).delete();
      return true;
    } catch (e) {
      print("Error delete MOU: $e");
      return false;
    }
  }

  // Aksi A: Berikan Revisi (Menggunakan WriteBatch)
  Future<bool> submitRevision({
    required String idMou,
    required String idUser,
    required String catatan,
  }) async {
    try {
      final WriteBatch batch = _db.batch();
      
      final DocumentReference mouRef = _db.collection('tb_mou').doc(idMou);
      batch.update(mouRef, {
        'status_mou': 'Revisi',
        'catatan_revisi': catatan,
      });

      final DocumentReference reviewRef = _db.collection('tb_review_mou').doc();
      batch.set(reviewRef, {
        'id_mou': idMou,
        'id_user': idUser,
        'tanggal_review': Timestamp.now(),
        'hasil_review': 'Revisi',
        'catatan': catatan,
      });

      await batch.commit();
      return true;
    } catch (e) {
      print("Error committing revision batch: $e");
      return false;
    }
  }

  // Aksi B: Setujui & Teruskan (Menggunakan WriteBatch)
  Future<bool> approveAndForward({
    required String idMou,
    required String idUser,
  }) async {
    try {
      final WriteBatch batch = _db.batch();

      final DocumentReference mouRef = _db.collection('tb_mou').doc(idMou);
      batch.update(mouRef, {
        'status_mou': 'Menunggu TTD',
      });

      final DocumentReference reviewRef = _db.collection('tb_review_mou').doc();
      batch.set(reviewRef, {
        'id_mou': idMou,
        'id_user': idUser,
        'tanggal_review': Timestamp.now(),
        'hasil_review': 'Disetujui',
        'catatan': '-',
      });

      await batch.commit();
      return true;
    } catch (e) {
      print("Error committing approval batch: $e");
      return false;
    }
  }
}
