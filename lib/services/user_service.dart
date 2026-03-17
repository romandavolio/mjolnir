import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mjolnir/models/user_profile.dart';
import 'package:mjolnir/services/auth_service.dart';

class UserService {
  static final _db = FirebaseFirestore.instance;

  static Future<UserProfile?> getCurrentProfile() async {
    final user = AuthService.currentUser;
    if (user == null) return null;
    return await AuthService.getProfile(user.uid);
  }

  static Future<List<UserProfile>> searchUsers(String query) async {
    final snapshot = await _db
        .collection('usuarios')
        .where('name', isGreaterThanOrEqualTo: query)
        .where('name', isLessThanOrEqualTo: '$query\uf8ff')
        .get();

    return snapshot.docs
        .map((doc) => UserProfile.fromJson(doc.data()))
        .where((u) => u.uid != AuthService.currentUser?.uid)
        .toList();
  }
}