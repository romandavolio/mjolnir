import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mjolnir/models/assigned_routine.dart';
import 'package:mjolnir/models/exercise.dart';
import 'package:mjolnir/models/routine.dart';
import 'package:mjolnir/models/weight_entry.dart';
import 'package:mjolnir/services/auth_service.dart';
import 'package:mjolnir/models/routine_exercise.dart';

class RoutineService {
  static final _db = FirebaseFirestore.instance;

  // --- Rutinas del trainer ---

  static Future<void> saveRoutine(Routine routine) async {
    final uid = AuthService.currentUser?.uid;
    if (uid == null) return;
    await _db
        .collection('usuarios')
        .doc(uid)
        .collection('rutinas')
        .doc(routine.id)
        .set(routine.toJson());
  }

  static Future<void> deleteRoutine(String rutinaId) async {
    final uid = AuthService.currentUser?.uid;
    if (uid == null) return;
    await _db
        .collection('usuarios')
        .doc(uid)
        .collection('rutinas')
        .doc(rutinaId)
        .delete();
  }

  static Future<List<Routine>> loadMyRoutines() async {
    final uid = AuthService.currentUser?.uid;
    if (uid == null) return [];
    final snapshot = await _db
        .collection('usuarios')
        .doc(uid)
        .collection('rutinas')
        .get();
    return snapshot.docs.map((d) => Routine.fromJson(d.data())).toList();
  }

  static Future<Routine?> loadRoutine(String trainerId, String rutinaId) async {
    final doc = await _db
        .collection('usuarios')
        .doc(trainerId)
        .collection('rutinas')
        .doc(rutinaId)
        .get();
    if (!doc.exists) return null;
    return Routine.fromJson(doc.data()!);
  }

  // --- Asignaciones ---

  static Future<void> assignRoutine({
    required String alumnoId,
    required String alumnoName,
    required String rutinaId,
  }) async {
    final trainerId = AuthService.currentUser?.uid;
    if (trainerId == null) return;

    final trainerDoc = await _db.collection('usuarios').doc(trainerId).get();
    final trainerName = trainerDoc.data()?['name'] ?? '';

    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final assignment = AssignedRoutine(
      id: id,
      trainerId: trainerId,
      trainerName: trainerName,
      alumnoId: alumnoId,
      alumnoName: alumnoName,
      rutinaId: rutinaId,
      fechaAsignacion: DateTime.now(),
    );
    await _db.collection('rutinas_asignadas').doc(id).set(assignment.toJson());
  }

  static Future<void> unassignRoutine(String asignacionId) async {
    await _db.collection('rutinas_asignadas').doc(asignacionId).delete();
  }

  static Future<List<AssignedRoutine>> getAssignedToAlumno(
    String alumnoId,
  ) async {
    final snapshot = await _db
        .collection('rutinas_asignadas')
        .where('alumnoId', isEqualTo: alumnoId)
        .get();
    return snapshot.docs
        .map((d) => AssignedRoutine.fromJson(d.data()))
        .toList();
  }

  static Future<List<AssignedRoutine>> getAssignedByTrainer(
    String trainerId,
    String alumnoId,
  ) async {
    final snapshot = await _db
        .collection('rutinas_asignadas')
        .where('trainerId', isEqualTo: trainerId)
        .where('alumnoId', isEqualTo: alumnoId)
        .get();
    return snapshot.docs
        .map((d) => AssignedRoutine.fromJson(d.data()))
        .toList();
  }

  // --- Pesos por usuario ---

  static Future<void> saveSerieWeight({
    required String exerciseName,
    required int serieIndex,
    required double weight,
    required String rutinaId,
  }) async {
    final uid = AuthService.currentUser?.uid;
    if (uid == null) return;
    await _db
        .collection('pesos')
        .doc('${uid}_${rutinaId}_${exerciseName}_$serieIndex')
        .set({'weight': weight, 'updatedAt': DateTime.now().toIso8601String()});
  }

  static Future<double> loadSerieWeight({
    required String exerciseName,
    required int serieIndex,
    required String rutinaId,
    String? uid,
  }) async {
    final userId = uid ?? AuthService.currentUser?.uid;
    if (userId == null) return 0;
    final doc = await _db
        .collection('pesos')
        .doc('${userId}_${rutinaId}_${exerciseName}_$serieIndex')
        .get();
    if (!doc.exists) return 0;
    return (doc.data()!['weight'] as num).toDouble();
  }

  static Future<bool> routineHasWeights({
    required String alumnoId,
    required String rutinaId,
    required List<RoutineExercise> exercises,
  }) async {
    for (final routineExercise in exercises) {
      for (int i = 0; i < routineExercise.series.length; i++) {
        final weight = await loadSerieWeight(
          exerciseName: routineExercise.exercise.name,
          serieIndex: i,
          rutinaId: rutinaId,
          uid: alumnoId,
        );
        if (weight > 0) return true;
      }
    }
    return false;
  }

  static Future<void> saveUnit(String unit) async {
    final uid = AuthService.currentUser?.uid;
    if (uid == null) return;
    await _db.collection('usuarios').doc(uid).update({'weightUnit': unit});
  }

  static Future<String> loadUnit() async {
    final uid = AuthService.currentUser?.uid;
    if (uid == null) return 'kg';
    final doc = await _db.collection('usuarios').doc(uid).get();
    if (!doc.exists) return 'kg';
    return doc.data()?['weightUnit'] ?? 'kg';
  }

  static Future<void> addWeightEntry(String exerciseName, double weight) async {
    final uid = AuthService.currentUser?.uid;
    if (uid == null) return;
    await _db.collection('historial').add({
      'uid': uid,
      'exerciseName': exerciseName,
      'weight': weight,
      'date': DateTime.now().toIso8601String(),
    });
  }

  static Future<List<WeightEntry>> loadWeightHistory(
    String exerciseName, {
    String? uid,
  }) async {
    final userId = uid ?? AuthService.currentUser?.uid;
    if (userId == null) return [];
    final snapshot = await _db
        .collection('historial')
        .where('uid', isEqualTo: userId)
        .where('exerciseName', isEqualTo: exerciseName)
        .orderBy('date')
        .get();
    return snapshot.docs
        .map(
          (d) => WeightEntry(
            date: DateTime.parse(d.data()['date']),
            weight: (d.data()['weight'] as num).toDouble(),
          ),
        )
        .toList();
  }

  static Future<void> saveExercises(List<Exercise> exercises) async {
    final uid = AuthService.currentUser?.uid;
    if (uid == null) return;
    final batch = _db.batch();

    // Primero eliminamos todos los ejercicios existentes
    final existing = await _db
        .collection('usuarios')
        .doc(uid)
        .collection('ejercicios')
        .get();
    for (final doc in existing.docs) {
      batch.delete(doc.reference);
    }

    // Luego guardamos los nuevos
    for (final exercise in exercises) {
      final ref = _db
          .collection('usuarios')
          .doc(uid)
          .collection('ejercicios')
          .doc(exercise.name);
      batch.set(ref, exercise.toJson());
    }

    await batch.commit();
  }

  static Future<List<Exercise>> loadExercises() async {
    final uid = AuthService.currentUser?.uid;
    if (uid == null) return [];
    final snapshot = await _db
        .collection('usuarios')
        .doc(uid)
        .collection('ejercicios')
        .get();
    return snapshot.docs.map((d) => Exercise.fromJson(d.data())).toList();
  }

  // Compartir rutina del alumno con un trainer
  static Future<void> shareRoutineWithTrainer({
    required String trainerId,
    required String trainerName,
    required String alumnoId,
    required String alumnoName,
    required String rutinaId,
  }) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final assignment = AssignedRoutine(
      id: id,
      trainerId: trainerId,
      trainerName: trainerName,
      alumnoId: alumnoId,
      alumnoName: alumnoName,
      rutinaId: rutinaId,
      fechaAsignacion: DateTime.now(),
      sharedByAlumno: true,
    );
    await _db.collection('rutinas_asignadas').doc(id).set(assignment.toJson());
  }

  // Verificar si ya está compartida
  static Future<bool> isRoutineSharedWithTrainer({
    required String trainerId,
    required String alumnoId,
    required String rutinaId,
  }) async {
    final snapshot = await _db
        .collection('rutinas_asignadas')
        .where('trainerId', isEqualTo: trainerId)
        .where('alumnoId', isEqualTo: alumnoId)
        .where('rutinaId', isEqualTo: rutinaId)
        .get();
    return snapshot.docs.isNotEmpty;
  }

  static Future<void> deleteAssignedRoutinesByTrainer({
    required String trainerId,
    required String alumnoId,
  }) async {
    final snapshot = await _db
        .collection('rutinas_asignadas')
        .where('trainerId', isEqualTo: trainerId)
        .where('alumnoId', isEqualTo: alumnoId)
        .get();
    for (final doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }

  static Future<void> updateExerciseInRoutines(
    Exercise oldExercise,
    Exercise newExercise,
  ) async {
    final uid = AuthService.currentUser?.uid;
    if (uid == null) return;

    final snapshot = await _db
        .collection('usuarios')
        .doc(uid)
        .collection('rutinas')
        .get();

    for (final doc in snapshot.docs) {
      final routine = Routine.fromJson(doc.data());
      bool changed = false;

      for (final re in routine.exercises) {
        if (re.exercise.name == oldExercise.name) {
          re.exercise = newExercise;
          changed = true;
        }
      }

      if (changed) {
        await _db
            .collection('usuarios')
            .doc(uid)
            .collection('rutinas')
            .doc(routine.id)
            .set(routine.toJson());
      }
    }
  }

  static Future<DateTime?> getLastTrainingDate() async {
    final uid = AuthService.currentUser?.uid;
    if (uid == null) return null;

    final snapshot = await _db
        .collection('historial')
        .where('uid', isEqualTo: uid)
        .orderBy('date', descending: true)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;
    return DateTime.parse(snapshot.docs.first.data()['date'] as String);
  }
}
