import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

class ClienteScreen extends StatelessWidget {
  const ClienteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);
    final cs = Theme.of(context).colorScheme;
    final userData = auth.userData;
    final firestoreService = FirestoreService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Trámites'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: cs.onSurface.withOpacity(0.6)),
            onPressed: () => auth.signOut(),
          ),
        ],
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: firestoreService.getCasos(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final casos = snapshot.data ?? [];
          final nombreProfesional =
              '${userData['nombre'] ?? ''} ${userData['apellido'] ?? ''}'
                  .trim();

          // Filtrar casos que pertenecen a este profesional
          final misCasos = casos.where((c) {
            final clienteNombre =
                (c['clienteNombre'] ?? '').toLowerCase();
            final profesionalNombre =
                (c['profesionalNombre'] ?? '').toLowerCase();
            final nombre = nombreProfesional.toLowerCase();
            return clienteNombre.contains(nombre) ||
                profesionalNombre.contains(nombre);
          }).toList();

          if (misCasos.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/Isotipo.png', height: 80),
                  const SizedBox(height: 24),
                  Text(
                    'No tenés trámites asignados',
                    style: TextStyle(
                      fontSize: 16,
                      color: cs.onBackground.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: cs.primary,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hola, ${userData['nombre'] ?? ''}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${misCasos.length} caso${misCasos.length != 1 ? 's' : ''} activo${misCasos.length != 1 ? 's' : ''}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Tus casos',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: cs.onBackground,
                  ),
                ),
                const SizedBox(height: 12),
                ...misCasos.map((caso) {
                  final tramites =
                      (caso['tramites'] as List? ?? []);
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: cs.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: Theme.of(context).dividerColor),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      caso['nombre'] ?? '',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: cs.onSurface,
                                      ),
                                    ),
                                    if ((caso['tipoCaso'] ?? '') != '')
                                      Text(
                                        caso['tipoCaso'] ?? '',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: cs.onSurface
                                              .withOpacity(0.6),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              if (caso['urgente'] == true)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFEE2E2),
                                    borderRadius:
                                        BorderRadius.circular(20),
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
                        ),
                        if (tramites.isNotEmpty) ...[
                          Divider(
                              height: 1,
                              color: Theme.of(context).dividerColor),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Trámites',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: cs.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                ...tramites.map((t) {
                                  if (t is! Map) return const SizedBox();
                                  final tramite =
                                      Map<String, dynamic>.from(
                                          t as Map);
                                  final estado =
                                      tramite['estado'] ?? 'pendiente';
                                  Color estadoColor;
                                  switch (estado) {
                                    case 'completado':
                                      estadoColor =
                                          const Color(0xFF10B981);
                                      break;
                                    case 'en curso':
                                      estadoColor =
                                          const Color(0xFFF59E0B);
                                      break;
                                    default:
                                      estadoColor = cs.primary;
                                  }

                                  final novedades = List<String>.from(
                                      tramite['novedades'] ?? []);

                                  return Container(
                                    margin:
                                        const EdgeInsets.only(bottom: 8),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color:
                                          cs.primary.withOpacity(0.05),
                                      borderRadius:
                                          BorderRadius.circular(10),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                tramite['naturaleza'] ??
                                                    '',
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight:
                                                      FontWeight.w500,
                                                  color: cs.onSurface,
                                                ),
                                              ),
                                            ),
                                            Container(
                                              padding: const EdgeInsets
                                                  .symmetric(
                                                  horizontal: 8,
                                                  vertical: 2),
                                              decoration: BoxDecoration(
                                                color: estadoColor
                                                    .withOpacity(0.1),
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        20),
                                              ),
                                              child: Text(
                                                estado,
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: estadoColor,
                                                  fontWeight:
                                                      FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        if ((tramite['fechaLimite'] ??
                                                '') !=
                                            '')
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(
                                                    top: 4),
                                            child: Text(
                                              'Vence: ${tramite['fechaLimite']}',
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: cs.onSurface
                                                    .withOpacity(0.5),
                                              ),
                                            ),
                                          ),
                                        if (novedades.isNotEmpty) ...[
                                          const SizedBox(height: 8),
                                          Text(
                                            'Novedades:',
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              color: cs.primary,
                                            ),
                                          ),
                                          ...novedades.map((n) => Padding(
                                                padding:
                                                    const EdgeInsets.only(
                                                        top: 2),
                                                child: Text(
                                                  n,
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    color: cs.onSurface
                                                        .withOpacity(0.7),
                                                  ),
                                                ),
                                              )),
                                        ],
                                      ],
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }
}