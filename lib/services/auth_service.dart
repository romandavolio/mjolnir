import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mjolnir/models/user_profile.dart';

class AuthService {
  static final _auth = FirebaseAuth.instance;
  static final _db = FirebaseFirestore.instance;

  static User? get currentUser => _auth.currentUser;

  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Registro
  static Future<UserProfile> register({
    required String email,
    required String password,
    required String name,
    required String role,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final profile = UserProfile(
      uid: credential.user!.uid,
      name: name,
      email: email,
      role: role,
    );

    await _db
        .collection('usuarios')
        .doc(credential.user!.uid)
        .set(profile.toJson());

    return profile;
  }

  // Login
  static Future<UserProfile> login({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final doc = await _db
        .collection('usuarios')
        .doc(credential.user!.uid)
        .get();

    return UserProfile.fromJson(doc.data()!);
  }

  // Obtener perfil
  static Future<UserProfile?> getProfile(String uid) async {
    final doc = await _db.collection('usuarios').doc(uid).get();
    if (!doc.exists) return null;
    return UserProfile.fromJson(doc.data()!);
  }

  // Logout
  static Future<void> logout() async {
    await _auth.signOut();
  }

  // Actualizar perfil
  static Future<void> updateProfile(UserProfile profile) async {
    await _db.collection('usuarios').doc(profile.uid).update(profile.toJson());
  }
}
