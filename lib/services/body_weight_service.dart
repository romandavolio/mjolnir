import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mjolnir/models/body_weight_entry.dart';
import 'package:mjolnir/services/auth_service.dart';

class BodyWeightService {
  static final _db = FirebaseFirestore.instance;

  static Future<void> addEntry(double weight, {String? uid}) async {
    final userId = uid ?? AuthService.currentUser?.uid;
    if (userId == null) return;
    await _db.collection('peso_corporal').add({
      'uid': userId,
      'weight': weight,
      'date': DateTime.now().toIso8601String(),
    });
  }

  static Future<List<BodyWeightEntry>> loadHistory({String? uid}) async {
    final userId = uid ?? AuthService.currentUser?.uid;
    if (userId == null) return [];
    final snapshot = await _db
        .collection('peso_corporal')
        .where('uid', isEqualTo: userId)
        .orderBy('date')
        .get();
    return snapshot.docs
        .map((d) => BodyWeightEntry.fromJson(d.data()))
        .toList();
  }
}