import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
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
    Consumer<AuthService>(
      builder: (context, auth, _) {
        final esAdmin = auth.userData['permisos']?['agregarEmpleados'] == true
            || auth.userData['rol']?.toString().toLowerCase() == 'ceo'
            || auth.userData['rol']?.toString().toLowerCase() == 'administrador';
        final esMismoPerfil = auth.currentUser?.email == empleado['mail'];

        if (!esAdmin || esMismoPerfil) return const SizedBox();

        return Row(
          children: [
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
                    content: const Text('¿Estás seguro?'),
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
        );
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
                  _GrupoPermisosDetalle(
  titulo: 'Casos',
  icono: Icons.folder_outlined,
  permisos: permisos,
  keys: {
    'casos_agregar': 'Agregar casos',
    'casos_editar': 'Editar casos',
    'casos_eliminar': 'Eliminar casos',
    'casos_verNoAsignados': 'Ver casos no asignados',
  },
),
const SizedBox(height: 8),
_GrupoPermisosDetalle(
  titulo: 'Profesionales',
  icono: Icons.people_outline,
  permisos: permisos,
  keys: {
    'profesionales_agregar': 'Agregar profesionales',
    'profesionales_editar': 'Editar profesionales',
    'profesionales_eliminar': 'Eliminar profesionales',
    'profesionales_verDatos': 'Ver datos sensibles',
  },
),
const SizedBox(height: 8),
_GrupoPermisosDetalle(
  titulo: 'Oficinas',
  icono: Icons.business_outlined,
  permisos: permisos,
  keys: {
    'oficinas_agregar': 'Agregar oficinas',
    'oficinas_editar': 'Editar oficinas',
    'oficinas_eliminar': 'Eliminar oficinas',
  },
),
const SizedBox(height: 8),
_GrupoPermisosDetalle(
  titulo: 'Empleados',
  icono: Icons.badge_outlined,
  permisos: permisos,
  keys: {
    'empleados_agregar': 'Agregar empleados',
    'empleados_editar': 'Editar empleados',
    'empleados_eliminar': 'Eliminar empleados',
    'empleados_verDatos': 'Ver datos de empleados',
  },
),
const SizedBox(height: 8),
_GrupoPermisosDetalle(
  titulo: 'Trámites',
  icono: Icons.assignment_outlined,
  permisos: permisos,
  keys: {
    'tramites_agregar': 'Agregar trámites',
    'tramites_editar': 'Editar trámites',
    'tramites_eliminar': 'Eliminar trámites',
    'tramites_completar': 'Completar trámites',
    'tramites_novedad': 'Agregar novedades',
  },
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
class _GrupoPermisosDetalle extends StatelessWidget {
  final String titulo;
  final IconData icono;
  final Map<String, dynamic> permisos;
  final Map<String, String> keys;

  const _GrupoPermisosDetalle({
    required this.titulo,
    required this.icono,
    required this.permisos,
    required this.keys,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              children: [
                Icon(icono, size: 18, color: cs.primary),
                const SizedBox(width: 8),
                Text(
                  titulo,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ...keys.entries.map((entry) {
            final activo = permisos[entry.key] == true;
            return Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Icon(
                    activo
                        ? Icons.check_circle
                        : Icons.cancel_outlined,
                    size: 16,
                    color: activo
                        ? const Color(0xFF10B981)
                        : cs.onSurface.withOpacity(0.3),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    entry.value,
                    style: TextStyle(
                      fontSize: 13,
                      color: activo
                          ? cs.onSurface
                          : cs.onSurface.withOpacity(0.4),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}