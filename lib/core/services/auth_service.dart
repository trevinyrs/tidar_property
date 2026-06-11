import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ================== STREAM USER ==================
  Stream<AppUser?> get userStream {
    return _auth.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) return null;

      try {
        final docSnapshot = await _db
            .collection('users')
            .doc(firebaseUser.uid!)  // ← pakai ! karena sudah dicek null
            .get();

        if (docSnapshot.exists && docSnapshot.data() != null) {
          return AppUser.fromMap(docSnapshot.data()!, firebaseUser.uid!);
        } else {
          // Buat user default jika belum ada
          final defaultUser = AppUser(
            uid: firebaseUser.uid!,
            name: firebaseUser.displayName ?? "User Baru",
            email: firebaseUser.email ?? "",
            role: UserRole.agent,
          );

          await _db.collection('users').doc(firebaseUser.uid!).set(defaultUser.toMap());
          return defaultUser;
        }
      } catch (e) {
        print("Error fetching user data: $e");
        return null;
      }
    });
  }

  // ================== REGISTER ==================
  Future<AppUser?> register({
    required String name,
    required String email,
    required String password,
    required UserRole role,
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final newUser = AppUser(
        uid: result.user!.uid,
        name: name,
        email: email,
        role: role,
      );

      await _db.collection('users').doc(result.user!.uid).set(newUser.toMap());
      return newUser;
    } catch (e) {
      print("Register Error: $e");
      return null;
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
      final doc = await _db.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return AppUser.fromMap(doc.data()!, uid);
      }
    } catch (e) {
      print("Get User Data Error: $e");
    }
    return null;
  }

  // ================== LOGOUT ==================
  Future<void> logout() async {
    await _auth.signOut();
  }
}