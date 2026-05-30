import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import 'profesional_detalle_screen.dart';
import 'profesional_form_screen.dart';

class ProfesionalesScreen extends StatefulWidget {
  const ProfesionalesScreen({super.key});

  @override
  State<ProfesionalesScreen> createState() => _ProfesionalesScreenState();
}

class _ProfesionalesScreenState extends State<ProfesionalesScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  String _busqueda = '';
  String _filtroProfesion = 'todos';

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Profesionales')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ProfesionalFormScreen()),
        ),
        backgroundColor: cs.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Nuevo profesional',
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
                    hintText: 'Buscar profesionales...',
                    prefixIcon: Icon(Icons.search,
                        color: cs.onSurface.withOpacity(0.4)),
                  ),
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _FiltroChip(
                        label: 'Todos',
                        selected: _filtroProfesion == 'todos',
                        onTap: () =>
                            setState(() => _filtroProfesion = 'todos'),
                      ),
                      const SizedBox(width: 8),
                      _FiltroChip(
                        label: 'Agrimensores',
                        selected: _filtroProfesion == 'Agrimensor',
                        onTap: () => setState(
                            () => _filtroProfesion = 'Agrimensor'),
                      ),
                      const SizedBox(width: 8),
                      _FiltroChip(
                        label: 'Abogados',
                        selected: _filtroProfesion == 'Abogado',
                        onTap: () =>
                            setState(() => _filtroProfesion = 'Abogado'),
                      ),
                      const SizedBox(width: 8),
                      _FiltroChip(
                        label: 'Escribanos',
                        selected: _filtroProfesion == 'Escribano',
                        onTap: () => setState(
                            () => _filtroProfesion = 'Escribano'),
                      ),
                      const SizedBox(width: 8),
                      _FiltroChip(
                        label: 'Otros',
                        selected: _filtroProfesion == 'Otro',
                        onTap: () =>
                            setState(() => _filtroProfesion = 'Otro'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _firestoreService.getProfesionales(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                var profesionales = snapshot.data ?? [];

                if (_busqueda.isNotEmpty) {
                  profesionales = profesionales.where((p) {
                    final nombre =
                        '${p['nombre']} ${p['apellido']}'.toLowerCase();
                    final profesion =
                        (p['profesion'] ?? '').toLowerCase();
                    final q = _busqueda.toLowerCase();
                    return nombre.contains(q) || profesion.contains(q);
                  }).toList();
                }

                if (_filtroProfesion != 'todos') {
                  profesionales = profesionales
                      .where((p) => p['profesion'] == _filtroProfesion)
                      .toList();
                }

                if (profesionales.isEmpty) {
                  return Center(
                    child: Text('No hay profesionales',
                        style: TextStyle(
                            color: cs.onBackground.withOpacity(0.5))),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: profesionales.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final p = profesionales[index];
                    return GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              ProfesionalDetalleScreen(profesional: p),
                        ),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: cs.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: Theme.of(context).dividerColor),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: _colorProfesion(
                                    p['profesion'] ?? '', cs),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text(
                                  _inicialesProfesion(
                                      p['profesion'] ?? ''),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${p['nombre']} ${p['apellido']}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: cs.onSurface,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    p['profesion'] ?? '',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color:
                                          cs.onSurface.withOpacity(0.6),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(Icons.chevron_right,
                                color: cs.onSurface.withOpacity(0.3)),
                          ],
                        ),
                      ),
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

  Color _colorProfesion(String profesion, ColorScheme cs) {
    switch (profesion) {
      case 'Agrimensor':
        return cs.secondary;
      case 'Abogado':
        return cs.primary;
      case 'Escribano':
        return const Color(0xFFF59E0B);
      default:
        return cs.onSurface.withOpacity(0.4);
    }
  }

  String _inicialesProfesion(String profesion) {
    switch (profesion) {
      case 'Agrimensor':
        return 'Ag';
      case 'Abogado':
        return 'Dr';
      case 'Escribano':
        return 'Not';
      default:
        return 'Cl';
    }
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