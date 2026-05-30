import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import 'oficina_detalle_screen.dart';
import 'oficina_form_screen.dart';

class OficinasScreen extends StatefulWidget {
  const OficinasScreen({super.key});

  @override
  State<OficinasScreen> createState() => _OficinasScreenState();
}

class _OficinasScreenState extends State<OficinasScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  String _busqueda = '';

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Oficinas')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const OficinaFormScreen()),
        ),
        backgroundColor: cs.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Nueva oficina',
            style: TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: [
          Container(
            color: cs.surface,
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (v) => setState(() => _busqueda = v),
              decoration: InputDecoration(
                hintText: 'Buscar oficinas...',
                prefixIcon: Icon(Icons.search,
                    color: cs.onSurface.withOpacity(0.4)),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _firestoreService.getOficinas(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                var oficinas = snapshot.data ?? [];

                if (_busqueda.isNotEmpty) {
                  oficinas = oficinas.where((o) {
                    final nombre = (o['nombre'] ?? '').toLowerCase();
                    return nombre
                        .contains(_busqueda.toLowerCase());
                  }).toList();
                }

                if (oficinas.isEmpty) {
                  return Center(
                    child: Text('No hay oficinas cargadas',
                        style: TextStyle(
                            color:
                                cs.onBackground.withOpacity(0.5))),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: oficinas.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final oficina = oficinas[index];
                    final tramites =
                        (oficina['tramites'] as List?)?.length ?? 0;
                    final contactos =
                        (oficina['contactos'] as List?)?.length ?? 0;

                    return GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              OficinaDetalleScreen(oficina: oficina),
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
                                color: cs.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.business_outlined,
                                color: cs.primary,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    oficina['nombre'] ?? '',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: cs.onSurface,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    oficina['ubicacion'] ?? '',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color:
                                          cs.onSurface.withOpacity(0.6),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '$tramites trámites',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: cs.primary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '$contactos contactos',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color:
                                        cs.onSurface.withOpacity(0.5),
                                  ),
                                ),
                              ],
                            ),
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
}