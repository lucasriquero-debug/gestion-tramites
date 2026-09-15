import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import 'oficina_form_screen.dart';

class OficinaDetalleScreen extends StatelessWidget {
  final String oficinaId;

  const OficinaDetalleScreen({super.key, required this.oficinaId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: FirestoreService().getOficinas(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final oficinas = snapshot.data ?? [];
        final oficina = oficinas.firstWhere(
          (o) => o['id'] == oficinaId,
          orElse: () => {},
        );

        if (oficina.isEmpty) {
          return const Scaffold(
            body: Center(child: Text('Oficina no encontrada')),
          );
        }

        return _OficinaDetalleView(oficina: oficina);
      },
    );
  }
}

class _OficinaDetalleView extends StatelessWidget {
  final Map<String, dynamic> oficina;

  const _OficinaDetalleView({required this.oficina});

  @override
  Widget build(BuildContext context) {
    final contactos = (oficina['contactos'] as List?) ?? [];
    final tramites = (oficina['tramites'] as List?) ?? [];
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(oficina['nombre'] ?? 'Detalle oficina'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => OficinaFormScreen(oficina: oficina),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () async {
              final confirmar = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Eliminar oficina'),
                  content: const Text(
                      '¿Estás seguro que querés eliminar esta oficina?'),
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
                await FirestoreService().eliminarOficina(oficina['id']);
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
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Theme.of(context).dividerColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    oficina['nombre'] ?? '',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _DatoFila(
                    icono: Icons.location_on_outlined,
                    label: 'Ubicación',
                    valor: oficina['ubicacion'] ?? '-',
                  ),
                  _DatoFila(
                    icono: Icons.phone_outlined,
                    label: 'Teléfono',
                    valor: oficina['telefono'] ?? '-',
                  ),
                  _DatoFila(
                    icono: Icons.mail_outline,
                    label: 'Mail',
                    valor: oficina['mail'] ?? '-',
                  ),
                ],
              ),
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
                    'Contactos estratégicos',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (contactos.isEmpty)
                    Text(
                      'Sin contactos cargados',
                      style: TextStyle(
                          color: cs.onSurface.withOpacity(0.4)),
                    )
                  else
                    ...contactos.map((c) {
                      final contacto = c as Map<String, dynamic>;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: cs.primary.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.person_outline,
                                color: cs.primary, size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    contacto['nombre'] ?? '',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                      color: cs.onSurface,
                                    ),
                                  ),
                                  Text(
                                    contacto['area'] ?? '',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color:
                                          cs.onSurface.withOpacity(0.6),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  contacto['telefono'] ?? '',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color:
                                        cs.onSurface.withOpacity(0.6),
                                  ),
                                ),
                                Text(
                                  contacto['cumpleanos'] ?? '',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color:
                                        cs.onSurface.withOpacity(0.4),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }),
                ],
              ),
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
                    'Trámites',
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
                      final tramite = t is Map
                          ? t as Map<String, dynamic>
                          : {'nombre': t.toString()};
                      final docs =
                          (tramite['documentacion'] as List?) ?? [];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: cs.primary.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.assignment_outlined,
                                    color: cs.primary, size: 20),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        tramite['nombre'] ??
                                            t.toString(),
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                          color: cs.onSurface,
                                        ),
                                      ),
                                      if ((tramite['area'] ?? '') != '')
                                        Text(
                                          tramite['area'] ?? '',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: cs.onSurface
                                                .withOpacity(0.6),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            if (docs.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text(
                                'Documentación:',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: cs.onSurface.withOpacity(0.6),
                                ),
                              ),
                              ...docs.map((d) {
                                final doc = d is Map
                                    ? Map<String, dynamic>.from(
                                        d as Map)
                                    : {
                                        'nombre': d.toString(),
                                        'verificado': false
                                      };
                                return Padding(
                                  padding:
                                      const EdgeInsets.only(top: 4),
                                  child: Row(
                                    children: [
                                      Icon(Icons.article_outlined,
                                          size: 14,
                                          color: cs.onSurface
                                              .withOpacity(0.4)),
                                      const SizedBox(width: 6),
                                      Text(
                                        doc['nombre']?.toString() ?? '',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: cs.onSurface
                                              .withOpacity(0.6),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ],
                          ],
                        ),
                      );
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