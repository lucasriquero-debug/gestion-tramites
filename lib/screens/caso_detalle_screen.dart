import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import 'caso_form_screen.dart';

class CasoDetalleScreen extends StatelessWidget {
  final String casoId;

  const CasoDetalleScreen({super.key, required this.casoId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: FirestoreService().getCasos(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final casos = snapshot.data ?? [];
        final caso = casos.firstWhere(
          (c) => c['id'] == casoId,
          orElse: () => {},
        );

        if (caso.isEmpty) {
          return const Scaffold(
            body: Center(child: Text('Caso no encontrado')),
          );
        }

        return _CasoDetalleView(caso: caso);
      },
    );
  }
}

class _CasoDetalleView extends StatelessWidget {
  final Map<String, dynamic> caso;

  const _CasoDetalleView({required this.caso});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final urgente = caso['urgente'] == true;
    final tramites = (caso['tramites'] as List?) ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text(caso['nombre'] ?? 'Detalle del caso'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check_circle_outline,
                color: Color(0xFF10B981)),
            onPressed: () async {
              final confirmar = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Cerrar caso'),
                  content: const Text(
                      '¿Estás seguro que querés cerrar este caso? Se archivará en la ficha del profesional.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancelar'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Cerrar caso',
                          style: TextStyle(color: Color(0xFF10B981))),
                    ),
                  ],
                ),
              );
              if (confirmar == true) {
                await FirestoreService().cerrarCaso(caso);
                if (context.mounted) {
                  Navigator.popUntil(context, (route) => route.isFirst);
                }
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CasoFormScreen(caso: caso),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () async {
              final confirmar = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Eliminar caso'),
                  content: const Text(
                      '¿Estás seguro que querés eliminar este caso?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancelar'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Eliminar',
                          style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
              if (confirmar == true) {
                await FirestoreService().eliminarCaso(caso['id']);
                if (context.mounted) Navigator.pop(context);
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: urgente
                      ? const Color(0xFFEF4444)
                      : Theme.of(context).dividerColor,
                  width: urgente ? 2 : 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          caso['nombre'] ?? '',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: cs.onSurface,
                          ),
                        ),
                      ),
                      if (urgente)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEE2E2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Urgente',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFFDC2626),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                  if ((caso['tipoCaso'] ?? '') != '')
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        caso['tipoCaso'] ?? '',
                        style: TextStyle(
                          fontSize: 14,
                          color: cs.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _SeccionCard(
              titulo: 'Datos del caso',
              children: [
                _DatoFila(
                  icono: Icons.person_outline,
                  label: 'Cliente',
                  valor: caso['clienteNombre'] ??
                      caso['profesionalNombre'] ??
                      '-',
                ),
                _DatoFila(
                  icono: Icons.category_outlined,
                  label: 'Tipo de cliente',
                  valor: caso['clienteTipo'] ?? '-',
                ),
                _DatoFila(
                  icono: Icons.person_pin_outlined,
                  label: 'Empleado asignado',
                  valor: caso['empleadoAsignado'] ?? '-',
                ),
                _DatoFila(
                  icono: Icons.calendar_today_outlined,
                  label: 'Fecha límite',
                  valor: caso['fechaLimite'] ?? '-',
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Theme.of(context).dividerColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Trámites (${tramites.length})',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (tramites.isEmpty)
                    Text(
                      'Sin trámites cargados',
                      style: TextStyle(
                          color: cs.onSurface.withOpacity(0.4)),
                    )
                  else
                    ...tramites.map((t) {
                      if (t is! Map) return const SizedBox();
                      final tramite =
                          Map<String, dynamic>.from(t as Map);
                      return _TramiteDetalle(tramite: tramite);
                    }),
                ],
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

class _SeccionCard extends StatelessWidget {
  final String titulo;
  final List<Widget> children;

  const _SeccionCard({required this.titulo, required this.children});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}

class _DatoFila extends StatelessWidget {
  final IconData icono;
  final String label;
  final String valor;

  const _DatoFila({
    required this.icono,
    required this.label,
    required this.valor,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icono, size: 18, color: cs.onSurface.withOpacity(0.5)),
          const SizedBox(width: 12),
          Text(
            '$label: ',
            style: TextStyle(
                fontSize: 13, color: cs.onSurface.withOpacity(0.6)),
          ),
          Expanded(
            child: Text(
              valor,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: cs.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TramiteDetalle extends StatelessWidget {
  final Map<String, dynamic> tramite;

  const _TramiteDetalle({required this.tramite});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final estado = tramite['estado'] ?? 'pendiente';
    Color estadoColor;
    switch (estado) {
      case 'completado':
        estadoColor = const Color(0xFF10B981);
        break;
      case 'en curso':
        estadoColor = const Color(0xFFF59E0B);
        break;
      default:
        estadoColor = cs.primary;
    }

    final novedades = List<String>.from(tramite['novedades'] ?? []);
    final documentacion = List<dynamic>.from(
        tramite['documentacion'] is List ? tramite['documentacion'] : []);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.primary.withOpacity(0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.primary.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  tramite['naturaleza'] ?? '',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: cs.onSurface,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: estadoColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  estado,
                  style: TextStyle(
                    fontSize: 11,
                    color: estadoColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          if ((tramite['oficinaNombre'] ?? '') != '')
            _ItemFila(
                icono: Icons.business_outlined,
                texto: tramite['oficinaNombre']),
          if ((tramite['fechaLimite'] ?? '') != '')
            _ItemFila(
                icono: Icons.calendar_today_outlined,
                texto: 'Vence: ${tramite['fechaLimite']}'),
          if ((tramite['revisionPeriodica'] ?? '') != '')
            _ItemFila(
                icono: Icons.refresh_outlined,
                texto: 'Revisión cada ${tramite['revisionPeriodica']} días'),
          if ((tramite['empleadoAsignado'] ?? '') != '')
            _ItemFila(
                icono: Icons.person_outline,
                texto: 'Empleado: ${tramite['empleadoAsignado']}'),
          if (documentacion.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Documentación:',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: cs.onSurface.withOpacity(0.7),
              ),
            ),
            ...documentacion.map((d) {
              final doc = d is Map
                  ? Map<String, dynamic>.from(d as Map)
                  : {'nombre': d.toString(), 'verificado': false};
              return Row(
                children: [
                  Icon(
                    doc['verificado'] == true
                        ? Icons.check_box_outlined
                        : Icons.check_box_outline_blank,
                    size: 16,
                    color: doc['verificado'] == true
                        ? const Color(0xFF10B981)
                        : cs.onSurface.withOpacity(0.4),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      doc['nombre']?.toString() ?? '',
                      style: TextStyle(
                        fontSize: 12,
                        color: cs.onSurface.withOpacity(0.7),
                        decoration: doc['verificado'] == true
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                  ),
                ],
              );
            }),
          ],
          if (novedades.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Novedades:',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: cs.primary,
              ),
            ),
            ...novedades.map((n) => Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    n,
                    style: TextStyle(
                      fontSize: 12,
                      color: cs.onSurface.withOpacity(0.6),
                    ),
                  ),
                )),
          ],
        ],
      ),
    );
  }
}

class _ItemFila extends StatelessWidget {
  final IconData icono;
  final String texto;

  const _ItemFila({required this.icono, required this.texto});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Icon(icono, size: 14, color: cs.onSurface.withOpacity(0.4)),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              texto,
              style: TextStyle(
                fontSize: 12,
                color: cs.onSurface.withOpacity(0.6),
              ),
            ),
          ),
        ],
      ),
    );
  }
}