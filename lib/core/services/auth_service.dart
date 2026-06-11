import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // ================== STREAM USER ==================
  Stream<AppUser?> get userStream {
    return _auth.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) return null;

      try {
        final docSnapshot = await _db
            .collection('tb_user')
            .doc(firebaseUser.uid)
            .get();

        if (docSnapshot.exists && docSnapshot.data() != null) {
          return AppUser.fromFirestore(docSnapshot);
        } else {
          // Buat user default jika belum ada
          final defaultUser = AppUser(
            idUser: firebaseUser.uid,
            nama: firebaseUser.displayName ?? "User Baru",
            email: firebaseUser.email ?? "",
            role: UserRole.agent,
            noHp: "",
            status: "Aktif",
            createdAt: DateTime.now(),
          );

          await _db.collection('tb_user').doc(firebaseUser.uid).set(defaultUser.toFirestore());
          return defaultUser;
        }
      } catch (e) {
        print("Error fetching user data: $e");
        return null;
      }
    });
  }

  // ================== GET USERS STREAM ==================
  Stream<List<AppUser>> getUsersStream({String? roleFilter}) {
    Query query = _db.collection('tb_user');
    if (roleFilter != null) {
      // Ingat: roleFilter di UI adalah string ("agent", dll). Kita harus mencocokkan ke string PRD (e.g. "Agent", "BR", "Legal", "Manager")
      String prdRole = roleFilter;
      if (roleFilter.toLowerCase() == 'agent') prdRole = 'Agent';
      if (roleFilter.toLowerCase() == 'br') prdRole = 'BR';
      if (roleFilter.toLowerCase() == 'legal') prdRole = 'Legal';
      if (roleFilter.toLowerCase() == 'manager') prdRole = 'Manager';
      query = query.where('role', isEqualTo: prdRole);
    }
    return query.snapshots().map((snapshot) => snapshot.docs
        .map((doc) => AppUser.fromFirestore(doc))
        .toList());
  }

  // ================== REGISTER ==================
  Future<AppUser?> register({
    required String name,
    required String email,
    required String password,
    required UserRole role,
    required String phone,
    Uint8List? profileImageBytes,
    String? profileImageName,
  }) async {
    try {
      print("AuthService.register: Starting registration for $email");
      print("AuthService.register: profileImageBytes status: ${profileImageBytes != null ? 'NOT NULL (${profileImageBytes.length} bytes)' : 'NULL'}");
      
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final String uid = result.user!.uid;
      String? fotoProfilUrl;

      if (profileImageBytes != null && profileImageName != null) {
        try {
          final String extension = profileImageName.contains('.')
              ? profileImageName.split('.').last
              : 'jpg';
          final String sanitizedName = 'profile_${DateTime.now().millisecondsSinceEpoch}.$extension';
          final String pathFolder = 'profile_images/$uid/$sanitizedName';
          print("AuthService.register: Uploading to path: $pathFolder");
          final Reference ref = _storage.ref().child(pathFolder);
          final UploadTask uploadTask = ref.putData(profileImageBytes);
          final TaskSnapshot taskSnapshot = await uploadTask;
          fotoProfilUrl = await taskSnapshot.ref.getDownloadURL();
          print("AuthService.register: Upload successful. URL: $fotoProfilUrl");
        } catch (storageError) {
          print("AuthService.register: Storage Upload Failed (CORS or Rules): $storageError");
          // Tetap lanjutkan registrasi tanpa foto profil agar pendaftaran berhasil
          fotoProfilUrl = null;
        }
      }

      final hashedPassword = _hashPassword(password);

      final newUser = AppUser(
        idUser: uid,
        nama: name,
        email: email,
        role: role,
        noHp: phone,
        status: "Aktif",
        createdAt: DateTime.now(),
        password: hashedPassword,
        fotoProfil: fotoProfilUrl,
      );

      await _db.collection('tb_user').doc(uid).set(newUser.toFirestore());
      print("AuthService.register: User document saved to Firestore tb_user collection.");

      // Sign out immediately so they are not auto-logged in
      await _auth.signOut();

      return newUser;
    } catch (e) {
      print("Register Error: $e");
      rethrow;
    }
  }

  // ================== LOGIN ==================
  Future<AppUser?> login(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return await getUserData(result.user!.uid);
    } catch (e) {
      print("Login Error: $e");
      return null;
    }
  }

  // ================== GET USER DATA ==================
  Future<AppUser?> getUserData(String uid) async {
    try {
      final doc = await _db.collection('tb_user').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return AppUser.fromFirestore(doc);
      }
    } catch (e) {
      print("Get User Data Error: $e");
    }
    return null;
  }

  // ================== ADD AGENT USER ==================
  Future<String?> addAgentUser(AppUser user) async {
    try {
      DocumentReference doc = await _db.collection('tb_user').add(user.toFirestore());
      return doc.id;
    } catch (e) {
      print("Error adding agent: $e");
      return null;
    }
  }

  // ================== LOGOUT ==================
  Future<void> logout() async {
    await _auth.signOut();
  }

  // ================== UPDATE PROFILE ==================
  Future<void> updateUserProfile({
    required String uid,
    required String name,
    required String phone,
  }) async {
    try {
      await _db.collection('tb_user').doc(uid).update({
        'nama': name,
        'no_hp': phone,
      });
    } catch (e) {
      print("Error in updateUserProfile: $e");
      rethrow;
    }
  }
}