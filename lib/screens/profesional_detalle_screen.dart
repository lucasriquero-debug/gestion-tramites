import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import 'profesional_form_screen.dart';

class ProfesionalDetalleScreen extends StatelessWidget {
  final Map<String, dynamic> profesional;

  const ProfesionalDetalleScreen({super.key, required this.profesional});

  @override
  Widget build(BuildContext context) {
    final cuentas = (profesional['cuentas'] as List?) ?? [];
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
            '${profesional['nombre']} ${profesional['apellido']}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    ProfesionalFormScreen(profesional: profesional),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () async {
              final confirmar = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Eliminar profesional'),
                  content: const Text(
                      '¿Estás seguro que querés eliminar este profesional?'),
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
                await FirestoreService()
                    .eliminarProfesional(profesional['id']);
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
              child: Row(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: _colorProfesion(
                          profesional['profesion'] ?? '', cs),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Text(
                        _inicialesProfesion(
                            profesional['profesion'] ?? ''),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${profesional['nombre']} ${profesional['apellido']}',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: cs.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          profesional['profesion'] ?? '',
                          style: TextStyle(
                            fontSize: 14,
                            color: cs.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _SeccionCard(
              titulo: 'Datos personales',
              children: [
                _DatoFila(
                    icono: Icons.badge_outlined,
                    label: 'CUIL',
                    valor: profesional['cuil'] ?? '-'),
                _DatoFila(
                    icono: Icons.phone_outlined,
                    label: 'Teléfono',
                    valor: profesional['telefono'] ?? '-'),
                _DatoFila(
                    icono: Icons.mail_outline,
                    label: 'Mail',
                    valor: profesional['mail'] ?? '-'),
                _DatoFila(
                    icono: Icons.home_outlined,
                    label: 'Domicilio',
                    valor: profesional['domicilio'] ?? '-'),
                _DatoFila(
                    icono: Icons.cake_outlined,
                    label: 'Cumpleaños',
                    valor: profesional['fechaCumpleanos'] ?? '-'),
              ],
            ),
            const SizedBox(height: 16),
            _SeccionCard(
              titulo: 'Datos profesionales',
              children: [
                _DatoFila(
                    icono: Icons.numbers_outlined,
                    label: 'Matrícula',
                    valor: profesional['matricula'] ?? '-'),
                _DatoFila(
                    icono: Icons.app_registration_outlined,
                    label: 'Registro',
                    valor: profesional['registro'] ?? '-'),
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
                    'Cuentas de oficina',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (cuentas.isEmpty)
                    Text(
                      'Sin cuentas cargadas',
                      style: TextStyle(
                          color: cs.onSurface.withOpacity(0.4)),
                    )
                  else
                    ...cuentas.map((c) {
                      final cuenta = c as Map<String, dynamic>;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: cs.primary.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.lock_outline,
                                color: cs.primary, size: 18),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    cuenta['oficina'] ?? '',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                      color: cs.onSurface,
                                    ),
                                  ),
                                  Text(
                                    'Usuario: ${cuenta['usuario'] ?? '-'}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color:
                                          cs.onSurface.withOpacity(0.6),
                                    ),
                                  ),
                                  Text(
                                    'Contraseña: ${cuenta['contrasena'] ?? '-'}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color:
                                          cs.onSurface.withOpacity(0.4),
                                    ),
                                  ),
                                ],
                              ),
                            ),
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