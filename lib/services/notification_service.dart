import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:mjolnir/services/auth_service.dart';

class NotificationService {
  static final _messaging = FirebaseMessaging.instance;
  static final _db = FirebaseFirestore.instance;

  static Future<void> initialize() async {
    // Pedir permisos
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Guardar token del dispositivo en Firestore
    await saveToken();

    // Escuchar cuando llega una notificación con la app abierta
    FirebaseMessaging.onMessage.listen((message) {
      // Por ahora solo lo logueamos
      print('Notificación recibida: ${message.notification?.title}');
    });
  }

  static Future<void> saveToken() async {
    final uid = AuthService.currentUser?.uid;
    if (uid == null) return;
    final token = await _messaging.getToken();
    if (token == null) return;
    await _db.collection('usuarios').doc(uid).update({
      'fcmToken': token,
    });
  }

  static Future<void> sendLinkRequestNotification({
    required String alumnoId,
    required String trainerName,
  }) async {
    // Guardamos la notificación en Firestore
    // Un Cloud Function la enviaría como push — por ahora la guardamos
    await _db.collection('notificaciones').add({
      'userId': alumnoId,
      'title': 'Nueva solicitud de vinculación',
      'body': '$trainerName quiere vincularse con vos como trainer',
      'type': 'link_request',
      'read': false,
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  static Future<List<Map<String, dynamic>>> getUnreadNotifications() async {
    final uid = AuthService.currentUser?.uid;
    if (uid == null) return [];
    final snapshot = await _db
        .collection('notificaciones')
        .where('userId', isEqualTo: uid)
        .where('read', isEqualTo: false)
        .get();
    return snapshot.docs.map((d) => {...d.data(), 'id': d.id}).toList();
  }

  static Future<void> markAsRead(String notificationId) async {
    await _db
        .collection('notificaciones')
        .doc(notificationId)
        .update({'read': true});
  }
}