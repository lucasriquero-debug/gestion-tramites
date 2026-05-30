import 'package:cloud_firestore/cloud_firestore.dart';

class NotificacionService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

 Stream<List<Map<String, dynamic>>> getNotificaciones(String mail) {
  return _db
      .collection('notificaciones')
      .orderBy('fecha', descending: true)
      .snapshots()
      .map((snapshot) {
    return snapshot.docs
        .map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          return data;
        })
        .where((n) =>
            (n['destinatario'] ?? '').toString().toLowerCase().trim() ==
            mail.toLowerCase().trim())
        .toList();
  });
}

  Stream<int> getNoLeidas(String mail) {
  return _db
      .collection('notificaciones')
      .snapshots()
      .map((snapshot) {
    return snapshot.docs
        .where((doc) =>
            (doc.data()['destinatario'] ?? '').toString().toLowerCase().trim() ==
                mail.toLowerCase().trim() &&
            doc.data()['leida'] == false)
        .length;
  });
}

  Future<void> marcarLeida(String id) async {
    await _db.collection('notificaciones').doc(id).update({'leida': true});
  }

  Future<void> marcarTodasLeidas(String mail) async {
    final batch = _db.batch();
    final docs = await _db
        .collection('notificaciones')
        .where('destinatario', isEqualTo: mail)
        .where('leida', isEqualTo: false)
        .get();
    for (final doc in docs.docs) {
      batch.update(doc.reference, {'leida': true});
    }
    await batch.commit();
  }

  Future<void> crearNotificacion({
    required String tipo,
    required String mensaje,
    required String destinatario,
    String casoId = '',
    String tramiteId = '',
  }) async {
    await _db.collection('notificaciones').add({
      'tipo': tipo,
      'mensaje': mensaje,
      'destinatario': destinatario,
      'casoId': casoId,
      'tramiteId': tramiteId,
      'leida': false,
      'fecha': FieldValue.serverTimestamp(),
    });
  }

  Future<void> generarNotificacionesVencimiento(
      List<Map<String, dynamic>> casos) async {
    final hoy = DateTime.now();

    for (final caso in casos) {
      final tramites = (caso['tramites'] as List? ?? []);
      for (final t in tramites) {
        if (t is! Map) continue;
        final tramite = Map<String, dynamic>.from(t as Map);
        final fechaStr = tramite['fechaLimite'] ?? '';
        final empleado = tramite['empleadoAsignado'] ?? '';
        final estado = tramite['estado'] ?? '';

        if (fechaStr.isEmpty || estado == 'completado') continue;

        try {
          final partes = fechaStr.split('/');
          if (partes.length < 3) continue;
          final fecha = DateTime(
            int.parse(partes[2].length == 2
                ? '20${partes[2]}'
                : partes[2]),
            int.parse(partes[1]),
            int.parse(partes[0]),
          );

          final diasRestantes = fecha.difference(hoy).inDays;

          if (diasRestantes <= 3 && diasRestantes >= 0) {
            // Notificar al empleado asignado
            if (empleado.isNotEmpty) {
              await crearNotificacion(
                tipo: 'vencimiento',
                mensaje:
                    'El trámite "${tramite['naturaleza']}" del caso "${caso['nombre']}" vence en $diasRestantes día${diasRestantes != 1 ? 's' : ''}.',
                destinatario: empleado,
                casoId: caso['id'] ?? '',
              );
            }
          }
        } catch (_) {}
      }
    }
  }
}