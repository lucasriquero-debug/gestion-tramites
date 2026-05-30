import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/notificacion_service.dart';

class NotificacionesScreen extends StatelessWidget {
  const NotificacionesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);
    final mail = auth.currentUser?.email ?? '';
    final cs = Theme.of(context).colorScheme;
    final notificacionService = NotificacionService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificaciones'),
        actions: [
          TextButton(
            onPressed: () => notificacionService.marcarTodasLeidas(mail),
            child: Text(
              'Marcar todas leídas',
              style: TextStyle(color: cs.primary, fontSize: 13),
            ),
          ),
        ],
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: notificacionService.getNotificaciones(mail),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final notificaciones = snapshot.data ?? [];

          if (notificaciones.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_none_outlined,
                    size: 64,
                    color: cs.onBackground.withOpacity(0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No hay notificaciones',
                    style: TextStyle(
                      fontSize: 16,
                      color: cs.onBackground.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: notificaciones.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final n = notificaciones[index];
              final leida = n['leida'] == true;
              final tipo = n['tipo'] ?? '';

              IconData icono;
              Color color;
              switch (tipo) {
                case 'vencimiento':
                  icono = Icons.timer_outlined;
                  color = const Color(0xFFEF4444);
                  break;
                case 'novedad':
                  icono = Icons.note_outlined;
                  color = cs.primary;
                  break;
                case 'revision':
                  icono = Icons.refresh_outlined;
                  color = const Color(0xFFF59E0B);
                  break;
                case 'nuevo_caso':
                  icono = Icons.folder_outlined;
                  color = cs.secondary;
                  break;
                default:
                  icono = Icons.notifications_outlined;
                  color = cs.primary;
              }

              return GestureDetector(
                onTap: () {
                  if (!leida) {
                    notificacionService.marcarLeida(n['id']);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: leida
                        ? cs.surface
                        : cs.primary.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: leida
                          ? Theme.of(context).dividerColor
                          : cs.primary.withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(icono, color: color, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              n['mensaje'] ?? '',
                              style: TextStyle(
                                fontSize: 13,
                                color: cs.onSurface,
                                fontWeight: leida
                                    ? FontWeight.normal
                                    : FontWeight.w600,
                              ),
                            ),
                            if (n['fecha'] != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  _formatFecha(n['fecha']),
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: cs.onSurface.withOpacity(0.4),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      if (!leida)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: cs.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _formatFecha(dynamic fecha) {
    try {
      final dt = fecha.toDate();
      return '${dt.day}/${dt.month}/${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return '';
    }
  }
}