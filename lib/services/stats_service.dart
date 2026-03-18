import 'package:mjolnir/models/weight_entry.dart';
import 'package:mjolnir/services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StatsService {
  static final _db = FirebaseFirestore.instance;

  // Récord personal por ejercicio
  static Future<Map<String, double>> getPersonalRecords({
    String? uid,
  }) async {
    final userId = uid ?? AuthService.currentUser?.uid;
    if (userId == null) return {};

    final snapshot = await _db
        .collection('historial')
        .where('uid', isEqualTo: userId)
        .get();

    final Map<String, double> records = {};
    for (final doc in snapshot.docs) {
      final name = doc.data()['exerciseName'] as String;
      final weight = (doc.data()['weight'] as num).toDouble();
      if (!records.containsKey(name) || records[name]! < weight) {
        records[name] = weight;
      }
    }
    return records;
  }

  // Volumen total por día (series x reps x peso)
  static Future<Map<String, double>> getVolumeByDay({
    String? uid,
  }) async {
    final userId = uid ?? AuthService.currentUser?.uid;
    if (userId == null) return {};

    final snapshot = await _db
        .collection('historial')
        .where('uid', isEqualTo: userId)
        .get();

    final Map<String, double> volume = {};
    for (final doc in snapshot.docs) {
      final date = DateTime.parse(doc.data()['date'] as String);
      final key =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final weight = (doc.data()['weight'] as num).toDouble();
      volume[key] = (volume[key] ?? 0) + weight;
    }
    return volume;
  }

  // Progreso mensual — promedio de peso por ejercicio este mes vs mes anterior
  static Future<Map<String, Map<String, double>>> getMonthlyProgress({
    String? uid,
  }) async {
    final userId = uid ?? AuthService.currentUser?.uid;
    if (userId == null) return {};

    final now = DateTime.now();
    final thisMonthStart = DateTime(now.year, now.month, 1);
    final lastMonthStart = DateTime(now.year, now.month - 1, 1);

    final snapshot = await _db
        .collection('historial')
        .where('uid', isEqualTo: userId)
        .get();

    final Map<String, List<double>> thisMonth = {};
    final Map<String, List<double>> lastMonth = {};

    for (final doc in snapshot.docs) {
      final date = DateTime.parse(doc.data()['date'] as String);
      final name = doc.data()['exerciseName'] as String;
      final weight = (doc.data()['weight'] as num).toDouble();

      if (date.isAfter(thisMonthStart)) {
        thisMonth.putIfAbsent(name, () => []).add(weight);
      } else if (date.isAfter(lastMonthStart) &&
          date.isBefore(thisMonthStart)) {
        lastMonth.putIfAbsent(name, () => []).add(weight);
      }
    }

    final Map<String, Map<String, double>> result = {};
    for (final name in thisMonth.keys) {
      if (lastMonth.containsKey(name)) {
        final thisAvg =
            thisMonth[name]!.reduce((a, b) => a + b) / thisMonth[name]!.length;
        final lastAvg =
            lastMonth[name]!.reduce((a, b) => a + b) / lastMonth[name]!.length;
        result[name] = {
          'thisMonth': thisAvg,
          'lastMonth': lastAvg,
          'diff': thisAvg - lastAvg,
        };
      }
    }
    return result;
  }
}