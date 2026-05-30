import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import 'empleado_form_screen.dart';

class EmpleadoDetalleScreen extends StatelessWidget {
  final Map<String, dynamic> empleado;

  const EmpleadoDetalleScreen({super.key, required this.empleado});

  @override
  Widget build(BuildContext context) {
    final permisos = (empleado['permisos'] as Map<String, dynamic>?) ?? {};
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(empleado['nombre'] ?? 'Detalle empleado'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => EmpleadoFormScreen(empleado: empleado),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () async {
              final confirmar = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Eliminar empleado'),
                  content: const Text(
                      '¿Estás seguro que querés eliminar este empleado?'),
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
                await FirestoreService().eliminarEmpleado(empleado['id']);
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
                      color: cs.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Text(
                        (empleado['nombre'] ?? 'E')
                            .substring(0, 1)
                            .toUpperCase(),
                        style: TextStyle(
                          color: cs.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 24,
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
                          empleado['nombre'] ?? '',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: cs.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          empleado['rol'] ?? '',
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
                    'Datos de contacto',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _DatoFila(
                    icono: Icons.alternate_email,
                    label: 'Alias',
                    valor: empleado['alias'] ?? '-',
                  ),
                  _DatoFila(
                    icono: Icons.mail_outline,
                    label: 'Mail',
                    valor: empleado['mail'] ?? '-',
                  ),
                  _DatoFila(
                    icono: Icons.phone_outlined,
                    label: 'Teléfono',
                    valor: empleado['telefono'] ?? '-',
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
                    'Permisos',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _PermisoFila(
                    label: 'Agregar, editar o quitar casos',
                    activo: permisos['agregarCasos'] == true,
                  ),
                  _PermisoFila(
                    label: 'Agregar, editar o quitar profesionales',
                    activo: permisos['agregarProfesionales'] == true,
                  ),
                  _PermisoFila(
                    label: 'Agregar, editar o quitar trámites',
                    activo: permisos['agregarTramites'] == true,
                  ),
                  _PermisoFila(
                    label: 'Agregar, editar o quitar oficinas',
                    activo: permisos['agregarOficinas'] == true,
                  ),
                  _PermisoFila(
                    label: 'Ver casos no asignados',
                    activo: permisos['verCasosNoAsignados'] == true,
                  ),
                  _PermisoFila(
                    label: 'Ver datos de profesionales',
                    activo: permisos['verDatosProfesionales'] == true,
                  ),
                  _PermisoFila(
                    label: 'Ver datos de empleados',
                    activo: permisos['verDatosEmpleados'] == true,
                  ),
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

class _PermisoFila extends StatelessWidget {
  final String label;
  final bool activo;

  const _PermisoFila({required this.label, required this.activo});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            activo ? Icons.check_circle : Icons.cancel_outlined,
            size: 18,
            color: activo
                ? const Color(0xFF10B981)
                : cs.onSurface.withOpacity(0.3),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: activo
                    ? cs.onSurface
                    : cs.onSurface.withOpacity(0.4),
              ),
            ),
          ),
        ],
      ),
    );
  }
}