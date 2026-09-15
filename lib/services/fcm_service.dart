import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

/// Handler de mensajes en background (debe ser función top-level)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Firebase ya inicializado antes de llegar aquí.
  // No podemos mostrar UI aquí, pero la notificación del sistema
  // ya se muestra automáticamente por FCM.
  debugPrint('Mensaje en background: ${message.notification?.title}');
}

class FCMService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Clave global del Navigator para mostrar SnackBars sin contexto
  static final GlobalKey<ScaffoldMessengerState> messengerKey =
      GlobalKey<ScaffoldMessengerState>();

  Future<void> inicializar() async {
    // Registrar handler para mensajes en background
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Pedir permiso al usuario
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional) {
      await _guardarToken();
    }

    // Mensajes recibidos con la app en primer plano → mostrar SnackBar
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final titulo = message.notification?.title ?? '';
      final cuerpo = message.notification?.body ?? '';
      if (titulo.isNotEmpty || cuerpo.isNotEmpty) {
        messengerKey.currentState?.showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (titulo.isNotEmpty)
                  Text(
                    titulo,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                if (cuerpo.isNotEmpty) Text(cuerpo),
              ],
            ),
            duration: const Duration(seconds: 5),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });

    // Tap en notificación que abrió la app desde background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('Notificación abierta: ${message.notification?.title}');
      // Aquí se puede navegar a la pantalla de notificaciones si se desea
    });
  }

  Future<void> _guardarToken() async {
    try {
      final token = await _messaging.getToken(
        vapidKey:
            'BMme4v1HodcMkg8j6qinJ2HI72TX9bLljNgWeyiLtEzOHKrSmNkXih-d6EXsUTYmLZEdijfKpCcVp6VAjzpEy1Q',
      );

      if (token != null) {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          final email = user.email ?? '';

          // Buscar si es empleado o profesional y guardar el token
          final empleados = await _db
              .collection('empleados')
              .where('mail', isEqualTo: email)
              .get();

          if (empleados.docs.isNotEmpty) {
            await _db
                .collection('empleados')
                .doc(empleados.docs.first.id)
                .update({'fcmToken': token});
            return;
          }

          final profesionales = await _db
              .collection('profesionales')
              .where('mail', isEqualTo: email)
              .get();

          if (profesionales.docs.isNotEmpty) {
            await _db
                .collection('profesionales')
                .doc(profesionales.docs.first.id)
                .update({'fcmToken': token});
          }
        }
      }
    } catch (e) {
      debugPrint('Error guardando token FCM: $e');
    }
  }
}