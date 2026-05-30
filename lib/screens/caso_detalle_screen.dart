import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import 'caso_form_screen.dart';

class CasoDetalleScreen extends StatelessWidget {
  final Map<String, dynamic> caso;

  const CasoDetalleScreen({super.key, required this.caso});

  @override
  Widget build(BuildContext context) {
    final urgente = caso['urgente'] == true;
    final tramites = (caso['tramitesPendientes'] as num?)?.toInt() ?? 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1F2937)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          caso['nombre'] ?? 'Detalle del caso',
          style: const TextStyle(
            color: Color(0xFF1F2937),
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: Color(0xFF6366F1)),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CasoFormScreen(caso: caso),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: urgente
                      ? const Color(0xFFEF4444)
                      : const Color(0xFFE5E7EB),
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
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1F2937),
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
                  const SizedBox(height: 8),
                  Text(
                    caso['tipo'] ?? '',
                    style: const TextStyle(
                      fontSize: 15,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Datos principales
            _SeccionCard(
              titulo: 'Datos del caso',
              children: [
                _DatoFila(
                    icono: Icons.person_outline,
                    label: 'Profesional',
                    valor: caso['profesionalNombre'] ?? '-'),
                _DatoFila(
                    icono: Icons.badge_outlined,
                    label: 'Naturaleza',
                    valor: caso['naturaleza'] ?? '-'),
                _DatoFila(
                    icono: Icons.person_pin_outlined,
                    label: 'Empleado asignado',
                    valor: caso['empleadoAsignado'] ?? '-'),
                _DatoFila(
                    icono: Icons.calendar_today_outlined,
                    label: 'Fecha límite',
                    valor: caso['fechaLimite'] ?? '-'),
                _DatoFila(
                    icono: Icons.refresh_outlined,
                    label: 'Revisión periódica',
                    valor: caso['revisionPeriodica'] ?? '-'),
              ],
            ),
            const SizedBox(height: 16),

            // Trámites
            _SeccionCard(
              titulo: 'Trámites ($tramites pendientes)',
              children: [
                if (caso['tramites'] != null &&
    (caso['tramites'] as List).isNotEmpty)
  ...(caso['tramites'] as List).map((t) {
    final tramite = t is Map ? Map<String, dynamic>.from(t as Map) : <String, dynamic>{};
    return _TramiteDetalle(tramite: tramite);
  })
                else
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'Sin trámites cargados',
                      style: TextStyle(color: Color(0xFF9CA3AF)),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Oficina
            if (caso['oficina'] != null)
              _SeccionCard(
                titulo: 'Oficina',
                children: [
                  _DatoFila(
                      icono: Icons.business_outlined,
                      label: 'Oficina',
                      valor: caso['oficina'] ?? '-'),
                ],
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icono, size: 18, color: const Color(0xFF6B7280)),
          const SizedBox(width: 12),
          Text(
            '$label: ',
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF6B7280),
            ),
          ),
          Expanded(
            child: Text(
              valor,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1F2937),
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
        estadoColor = const Color(0xFF6366F1);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  tramite['naturaleza'] ?? '',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Color(0xFF1F2937),
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
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'Oficina: ${tramite['oficinaNombre']}',
                style: const TextStyle(
                    fontSize: 12, color: Color(0xFF6B7280)),
              ),
            ),
          if ((tramite['fechaLimite'] ?? '') != '')
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                'Vence: ${tramite['fechaLimite']}',
                style: const TextStyle(
                    fontSize: 12, color: Color(0xFF6B7280)),
              ),
            ),
          if ((tramite['empleadoAsignado'] ?? '') != '')
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                'Empleado: ${tramite['empleadoAsignado']}',
                style: const TextStyle(
                    fontSize: 12, color: Color(0xFF6B7280)),
              ),
            ),
          if ((tramite['revisionPeriodica'] ?? '') != '')
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                'Revisión cada ${tramite['revisionPeriodica']} días',
                style: const TextStyle(
                    fontSize: 12, color: Color(0xFF9CA3AF)),
              ),
            ),
          if ((tramite['documentacion'] ?? '') != '')
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                'Documentación: ${tramite['documentacion']}',
                style: const TextStyle(
                    fontSize: 12, color: Color(0xFF9CA3AF)),
              ),
            ),
        ],
      ),
    );
  }
}