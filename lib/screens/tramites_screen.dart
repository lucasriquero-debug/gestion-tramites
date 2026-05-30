import 'package:flutter/material.dart';
import '../services/firestore_service.dart';

class TramitesScreen extends StatefulWidget {
  const TramitesScreen({super.key});

  @override
  State<TramitesScreen> createState() => _TramitesScreenState();
}

class _TramitesScreenState extends State<TramitesScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  String _busqueda = '';
  String _filtroEstado = 'todos';
  String _filtroOficina = 'todas';

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trámites'),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _firestoreService.getCasos(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final casos = snapshot.data ?? [];
          final List<Map<String, dynamic>> todosTramites = [];

          for (final caso in casos) {
            final tramites = caso['tramites'] as List? ?? [];
            for (final t in tramites) {
              if (t is Map) {
                final tramite = Map<String, dynamic>.from(t as Map);
                tramite['casoNombre'] = caso['nombre'] ?? '';
                tramite['casoId'] = caso['id'] ?? '';
                todosTramites.add(tramite);
              }
            }
          }

          final oficinas = todosTramites
              .map((t) => t['oficinaNombre']?.toString() ?? '')
              .where((o) => o.isNotEmpty)
              .toSet()
              .toList();

          var tramitesFiltrados = todosTramites;

          if (_busqueda.isNotEmpty) {
            tramitesFiltrados = tramitesFiltrados.where((t) {
              final naturaleza = (t['naturaleza'] ?? '').toLowerCase();
              final oficina = (t['oficinaNombre'] ?? '').toLowerCase();
              final caso = (t['casoNombre'] ?? '').toLowerCase();
              final q = _busqueda.toLowerCase();
              return naturaleza.contains(q) ||
                  oficina.contains(q) ||
                  caso.contains(q);
            }).toList();
          }

          if (_filtroEstado != 'todos') {
            tramitesFiltrados = tramitesFiltrados
                .where((t) => t['estado'] == _filtroEstado)
                .toList();
          }

          if (_filtroOficina != 'todas') {
            tramitesFiltrados = tramitesFiltrados
                .where((t) => t['oficinaNombre'] == _filtroOficina)
                .toList();
          }

          final pendientes = todosTramites
              .where((t) => t['estado'] == 'pendiente')
              .length;
          final enCurso = todosTramites
              .where((t) => t['estado'] == 'en curso')
              .length;
          final completados = todosTramites
              .where((t) => t['estado'] == 'completado')
              .length;

          return Column(
            children: [
              Container(
                color: cs.surface,
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        _ContadorChip(
                          label: 'Pendientes',
                          valor: pendientes,
                          color: cs.primary,
                          selected: _filtroEstado == 'pendiente',
                          onTap: () => setState(() => _filtroEstado =
                              _filtroEstado == 'pendiente'
                                  ? 'todos'
                                  : 'pendiente'),
                        ),
                        const SizedBox(width: 8),
                        _ContadorChip(
                          label: 'En curso',
                          valor: enCurso,
                          color: const Color(0xFFF59E0B),
                          selected: _filtroEstado == 'en curso',
                          onTap: () => setState(() => _filtroEstado =
                              _filtroEstado == 'en curso'
                                  ? 'todos'
                                  : 'en curso'),
                        ),
                        const SizedBox(width: 8),
                        _ContadorChip(
                          label: 'Completados',
                          valor: completados,
                          color: const Color(0xFF10B981),
                          selected: _filtroEstado == 'completado',
                          onTap: () => setState(() => _filtroEstado =
                              _filtroEstado == 'completado'
                                  ? 'todos'
                                  : 'completado'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      onChanged: (v) => setState(() => _busqueda = v),
                      decoration: InputDecoration(
                        hintText: 'Buscar trámites...',
                        prefixIcon: Icon(Icons.search,
                            color: cs.onSurface.withOpacity(0.4)),
                      ),
                    ),
                    if (oficinas.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _FiltroChip(
                              label: 'Todas',
                              selected: _filtroOficina == 'todas',
                              onTap: () => setState(
                                  () => _filtroOficina = 'todas'),
                            ),
                            ...oficinas.map((o) => Padding(
                                  padding:
                                      const EdgeInsets.only(left: 8),
                                  child: _FiltroChip(
                                    label: o,
                                    selected: _filtroOficina == o,
                                    onTap: () => setState(
                                        () => _filtroOficina = o),
                                  ),
                                )),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Expanded(
                child: tramitesFiltrados.isEmpty
                    ? Center(
                        child: Text('No hay trámites',
                            style: TextStyle(
                                color:
                                    cs.onBackground.withOpacity(0.5))),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: tramitesFiltrados.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final t = tramitesFiltrados[index];
                          return _TramiteCard(
                            tramite: t,
                            onCompletar: () async {
                              await _completarTramite(t);
                            },
                            onNovedad: () =>
                                _mostrarNovedad(context, t),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _completarTramite(
      Map<String, dynamic> tramite) async {
    final casos = await _firestoreService.getCasos().first;
    final caso = casos.firstWhere(
      (c) => c['id'] == tramite['casoId'],
      orElse: () => {},
    );
    if (caso.isEmpty) return;

    final tramites = List<Map<String, dynamic>>.from(
      (caso['tramites'] as List? ?? [])
          .map((t) => Map<String, dynamic>.from(t as Map)),
    );

    final idx = tramites.indexWhere(
      (t) => t['naturaleza'] == tramite['naturaleza'],
    );

    if (idx != -1) {
      tramites[idx]['estado'] = 'completado';
      final pendientes =
          tramites.where((t) => t['estado'] != 'completado').length;
      await _firestoreService.actualizarCaso(caso['id'], {
        'tramites': tramites,
        'tramitesPendientes': pendientes,
      });
    }
  }

  void _mostrarNovedad(
      BuildContext context, Map<String, dynamic> tramite) {
    final controller = TextEditingController();
    final cs = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Novedad: ${tramite['naturaleza'] ?? ''}'),
        content: TextField(
          controller: controller,
          maxLines: 4,
          decoration: const InputDecoration(
            hintText: 'Escribí lo que encontraste o lo que hay que tener en cuenta...',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.trim().isNotEmpty) {
                await _guardarNovedad(tramite, controller.text.trim());
              }
              if (context.mounted) Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: cs.primary),
            child: const Text('Guardar',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _guardarNovedad(
      Map<String, dynamic> tramite, String novedad) async {
    final casos = await _firestoreService.getCasos().first;
    final caso = casos.firstWhere(
      (c) => c['id'] == tramite['casoId'],
      orElse: () => {},
    );
    if (caso.isEmpty) return;

    final tramites = List<Map<String, dynamic>>.from(
      (caso['tramites'] as List? ?? [])
          .map((t) => Map<String, dynamic>.from(t as Map)),
    );

    final idx = tramites.indexWhere(
      (t) => t['naturaleza'] == tramite['naturaleza'],
    );

    if (idx != -1) {
      final novedades =
          List<String>.from(tramites[idx]['novedades'] ?? []);
      novedades.add(
          '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}: $novedad');
      tramites[idx]['novedades'] = novedades;
      await _firestoreService.actualizarCaso(caso['id'], {
        'tramites': tramites,
      });
    }
  }
}

class _ContadorChip extends StatelessWidget {
  final String label;
  final int valor;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _ContadorChip({
    required this.label,
    required this.valor,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: selected ? color : color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Text(
                '$valor',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: selected ? Colors.white : color,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: selected ? Colors.white : color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
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
            color: selected
                ? cs.primary
                : Theme.of(context).dividerColor,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected
                ? Colors.white
                : cs.onSurface.withOpacity(0.6),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _TramiteCard extends StatelessWidget {
  final Map<String, dynamic> tramite;
  final VoidCallback onCompletar;
  final VoidCallback onNovedad;

  const _TramiteCard({
    required this.tramite,
    required this.onCompletar,
    required this.onNovedad,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final estado = tramite['estado'] ?? 'pendiente';
    final completado = estado == 'completado';

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

    final novedades =
        List<String>.from(tramite['novedades'] ?? []);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
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
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: estadoColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  estado,
                  style: TextStyle(
                    fontSize: 12,
                    color: estadoColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Caso: ${tramite['casoNombre']}',
            style: TextStyle(
              fontSize: 13,
              color: cs.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
          if ((tramite['oficinaNombre'] ?? '') != '')
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'Oficina: ${tramite['oficinaNombre']}',
                style: TextStyle(
                    fontSize: 12,
                    color: cs.onSurface.withOpacity(0.6)),
              ),
            ),
          if ((tramite['fechaLimite'] ?? '') != '')
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'Vence: ${tramite['fechaLimite']}',
                style: TextStyle(
                    fontSize: 12,
                    color: cs.onSurface.withOpacity(0.6)),
              ),
            ),
          if ((tramite['empleadoAsignado'] ?? '') != '')
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'Empleado: ${tramite['empleadoAsignado']}',
                style: TextStyle(
                    fontSize: 12,
                    color: cs.onSurface.withOpacity(0.4)),
              ),
            ),

          // Novedades previas
          if (novedades.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: cs.primary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Novedades',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: cs.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  ...novedades.map((n) => Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          n,
                          style: TextStyle(
                            fontSize: 12,
                            color: cs.onSurface.withOpacity(0.7),
                          ),
                        ),
                      )),
                ],
              ),
            ),
          ],

          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onNovedad,
                  icon: Icon(Icons.note_add_outlined,
                      size: 16, color: cs.primary),
                  label: Text('Novedad',
                      style: TextStyle(color: cs.primary)),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: cs.primary),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: completado ? null : onCompletar,
                  icon: Icon(
                    completado
                        ? Icons.check_circle
                        : Icons.check_circle_outline,
                    size: 16,
                    color: Colors.white,
                  ),
                  label: Text(
                    completado ? 'Completado' : 'Completar',
                    style: const TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: completado
                        ? const Color(0xFF10B981)
                        : cs.primary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}