import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mjolnir/models/link_request.dart';
import 'package:mjolnir/models/user_profile.dart';
import 'package:mjolnir/services/auth_service.dart';

class LinkService {
  static final _db = FirebaseFirestore.instance;

  // Enviar solicitud de vinculación
  static Future<void> sendRequest({
    required UserProfile trainer,
    required UserProfile alumno,
  }) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final request = LinkRequest(
      id: id,
      trainerId: trainer.uid,
      trainerName: trainer.name,
      alumnoId: alumno.uid,
      alumnoName: alumno.name,
      status: 'pending',
    );
    await _db
        .collection('solicitudes')
        .doc(id)
        .set(request.toJson());
  }

  // Solicitudes recibidas por el alumno
  static Future<List<LinkRequest>> getReceivedRequests() async {
    final uid = AuthService.currentUser?.uid;
    if (uid == null) return [];
    final snapshot = await _db
        .collection('solicitudes')
        .where('alumnoId', isEqualTo: uid)
        .where('status', isEqualTo: 'pending')
        .get();
    return snapshot.docs
        .map((d) => LinkRequest.fromJson(d.data()))
        .toList();
  }

  // Aceptar o rechazar solicitud
  static Future<void> updateRequest(String id, String status) async {
    await _db.collection('solicitudes').doc(id).update({'status': status});
  }

  // Alumnos vinculados a un trainer
  static Future<List<UserProfile>> getLinkedAlumnos(String trainerId) async {
    final snapshot = await _db
        .collection('solicitudes')
        .where('trainerId', isEqualTo: trainerId)
        .where('status', isEqualTo: 'accepted')
        .get();

    final requests = snapshot.docs
        .map((d) => LinkRequest.fromJson(d.data()))
        .toList();

    final List<UserProfile> alumnos = [];
    for (final req in requests) {
      final doc =
          await _db.collection('usuarios').doc(req.alumnoId).get();
      if (doc.exists) alumnos.add(UserProfile.fromJson(doc.data()!));
    }
    return alumnos;
  }

  // Verificar si ya existe solicitud
  static Future<bool> requestExists({
    required String trainerId,
    required String alumnoId,
  }) async {
    final snapshot = await _db
        .collection('solicitudes')
        .where('trainerId', isEqualTo: trainerId)
        .where('alumnoId', isEqualTo: alumnoId)
        .get();
    return snapshot.docs.isNotEmpty;
  }
}