import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import 'caso_detalle_screen.dart';
import 'caso_form_screen.dart';

class CasosScreen extends StatefulWidget {
  const CasosScreen({super.key});

  @override
  State<CasosScreen> createState() => _CasosScreenState();
}

class _CasosScreenState extends State<CasosScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  String _busqueda = '';
  String _filtroUrgente = 'todos';

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Casos'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CasoFormScreen()),
        ),
        backgroundColor: cs.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Nuevo caso',
            style: TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: [
          Container(
            color: cs.surface,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  onChanged: (v) => setState(() => _busqueda = v),
                  decoration: InputDecoration(
                    hintText: 'Buscar casos...',
                    prefixIcon: Icon(Icons.search,
                        color: cs.onSurface.withOpacity(0.4)),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _FiltroChip(
                      label: 'Todos',
                      selected: _filtroUrgente == 'todos',
                      onTap: () =>
                          setState(() => _filtroUrgente = 'todos'),
                    ),
                    const SizedBox(width: 8),
                    _FiltroChip(
                      label: 'Urgentes',
                      selected: _filtroUrgente == 'urgentes',
                      onTap: () =>
                          setState(() => _filtroUrgente = 'urgentes'),
                    ),
                    const SizedBox(width: 8),
                    _FiltroChip(
                      label: 'Sin urgencia',
                      selected: _filtroUrgente == 'normales',
                      onTap: () =>
                          setState(() => _filtroUrgente = 'normales'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _firestoreService.getCasos(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                var casos = snapshot.data ?? [];

                if (_busqueda.isNotEmpty) {
                  casos = casos.where((c) {
                    final nombre = (c['nombre'] ?? '').toLowerCase();
                    final cliente =
                        (c['clienteNombre'] ?? c['profesionalNombre'] ?? '')
                            .toLowerCase();
                    final tipo =
                        (c['tipoCaso'] ?? c['tipo'] ?? '').toLowerCase();
                    final q = _busqueda.toLowerCase();
                    return nombre.contains(q) ||
                        cliente.contains(q) ||
                        tipo.contains(q);
                  }).toList();
                }

                if (_filtroUrgente == 'urgentes') {
                  casos = casos
                      .where((c) => c['urgente'] == true)
                      .toList();
                } else if (_filtroUrgente == 'normales') {
                  casos = casos
                      .where((c) => c['urgente'] != true)
                      .toList();
                }

                if (casos.isEmpty) {
                  return Center(
                    child: Text('No hay casos',
                        style: TextStyle(
                            color: cs.onBackground.withOpacity(0.5))),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: casos.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final caso = casos[index];
                    return _CasoCard(
                      caso: caso,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              CasoDetalleScreen(caso: caso),
                        ),
                      ),
                      onEliminar: () async {
                        final confirmar = await showDialog<bool>(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text('Eliminar caso'),
                            content: const Text(
                                '¿Estás seguro que querés eliminar este caso?'),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(context, false),
                                child: const Text('Cancelar'),
                              ),
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(context, true),
                                child: const Text('Eliminar',
                                    style:
                                        TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        );
                        if (confirmar == true) {
                          await _firestoreService
                              .eliminarCaso(caso['id']);
                        }
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FiltroChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FiltroChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? cs.primary : cs.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? cs.primary : Theme.of(context).dividerColor,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : cs.onSurface.withOpacity(0.6),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _CasoCard extends StatelessWidget {
  final Map<String, dynamic> caso;
  final VoidCallback onTap;
  final VoidCallback onEliminar;

  const _CasoCard({
    required this.caso,
    required this.onTap,
    required this.onEliminar,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final urgente = caso['urgente'] == true;
    final tramites =
        (caso['tramitesPendientes'] as num?)?.toInt() ?? 0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: urgente
                ? const Color(0xFFEF4444)
                : Theme.of(context).dividerColor,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        caso['nombre'] ?? '',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: cs.onSurface,
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (urgente)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEE2E2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Urgente',
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFFDC2626),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${caso['clienteNombre'] ?? caso['profesionalNombre'] ?? ''} · ${caso['tipoCaso'] ?? caso['tipo'] ?? ''}',
                    style: TextStyle(
                      fontSize: 13,
                      color: cs.onSurface.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Empleado: ${caso['empleadoAsignado'] ?? '-'}',
                    style: TextStyle(
                      fontSize: 12,
                      color: cs.onSurface.withOpacity(0.4),
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '$tramites trámites',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: cs.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Vence: ${caso['fechaLimite'] ?? '-'}',
                  style: TextStyle(
                    fontSize: 12,
                    color: cs.onSurface.withOpacity(0.5),
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: onEliminar,
                  child: Icon(
                    Icons.delete_outline,
                    size: 20,
                    color: cs.onSurface.withOpacity(0.3),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}