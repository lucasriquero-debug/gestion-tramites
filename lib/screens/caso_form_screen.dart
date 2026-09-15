import 'package:flutter/material.dart';
import '../services/firestore_service.dart';

class CasoFormScreen extends StatefulWidget {
  final Map<String, dynamic>? caso;

  const CasoFormScreen({super.key, this.caso});

  @override
  State<CasoFormScreen> createState() => _CasoFormScreenState();
}

class _CasoFormScreenState extends State<CasoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirestoreService _firestoreService = FirestoreService();

  late TextEditingController _nombreController;
  late TextEditingController _tipoCasoController;
  late TextEditingController _clienteNombreController;

  String _clienteTipo = 'Agrimensor';
  String? _clienteId;
  bool _urgente = false;
  bool _guardando = false;

  List<Map<String, dynamic>> _tramites = [];
  List<Map<String, dynamic>> _profesionales = [];
  List<Map<String, dynamic>> _oficinas = [];
  List<Map<String, dynamic>> _empleados = [];

  final List<String> _tiposCliente = [
    'Agrimensor',
    'Abogado',
    'Escribano',
    'Otro',
  ];

  @override
  void initState() {
    super.initState();
    final c = widget.caso;
    _nombreController = TextEditingController(text: c?['nombre'] ?? '');
    _tipoCasoController = TextEditingController(text: c?['tipoCaso'] ?? '');
    _clienteNombreController =
        TextEditingController(text: c?['clienteNombre'] ?? '');
    _clienteTipo = c?['clienteTipo'] ?? 'Agrimensor';
    _clienteId = c?['clienteId'];
    _urgente = c?['urgente'] == true;

    if (c?['tramites'] != null) {
      _tramites = List<Map<String, dynamic>>.from(
        (c!['tramites'] as List).map((t) => Map<String, dynamic>.from(t)),
      );
    }

    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    _firestoreService.getProfesionales().listen((data) {
      if (mounted) setState(() => _profesionales = data);
    });
    _firestoreService.getOficinas().listen((data) {
      if (mounted) setState(() => _oficinas = data);
    });
    _firestoreService.getEmpleados().listen((data) {
      if (mounted) setState(() => _empleados = data);
    });
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _tipoCasoController.dispose();
    _clienteNombreController.dispose();
    super.dispose();
  }

  void _agregarTramite() {
    showDialog(
      context: context,
      builder: (_) => _TramiteDialog(
        oficinas: _oficinas,
        empleados: _empleados,
        onGuardar: (tramite) {
          setState(() => _tramites.add(tramite));
        },
      ),
    );
  }

  void _editarTramite(int index) {
    showDialog(
      context: context,
      builder: (_) => _TramiteDialog(
        oficinas: _oficinas,
        empleados: _empleados,
        tramiteExistente: _tramites[index],
        onGuardar: (tramite) {
          setState(() => _tramites[index] = tramite);
        },
      ),
    );
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _guardando = true);

    final datos = {
      'nombre': _nombreController.text.trim(),
      'tipoCaso': _tipoCasoController.text.trim(),
      'clienteNombre': _clienteNombreController.text.trim(),
      'clienteTipo': _clienteTipo,
      'clienteId': _clienteId ?? '',
      'urgente': _urgente,
      'tramites': _tramites,
      'tramitesPendientes':
          _tramites.where((t) => t['estado'] != 'completado').length,
    };

    if (widget.caso != null) {
      await _firestoreService.actualizarCaso(widget.caso!['id'], datos);
    } else {
      await _firestoreService.agregarCaso(datos);
    }

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final esEdicion = widget.caso != null;
    final profesionalesFiltrados = _profesionales
        .where((p) => p['profesion'] == _clienteTipo)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(esEdicion ? 'Editar caso' : 'Nuevo caso'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Campo(
                label: 'Nombre del caso',
                controller: _nombreController,
                requerido: true,
              ),
              _Campo(
                label: 'Tipo de caso (ej: Transferencia)',
                controller: _tipoCasoController,
              ),
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cs.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Theme.of(context).dividerColor),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Caso urgente',
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: cs.onSurface)),
                          Text('Se marcará con borde rojo',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: cs.onSurface.withOpacity(0.6))),
                        ],
                      ),
                    ),
                    Switch(
                      value: _urgente,
                      onChanged: (v) => setState(() => _urgente = v),
                      activeColor: cs.primary,
                    ),
                  ],
                ),
              ),
              Text('Cliente',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: cs.onSurface)),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: DropdownButtonFormField<String>(
                  value: _clienteTipo,
                  decoration: InputDecoration(
                    labelText: 'Tipo de cliente',
                    filled: true,
                    fillColor: cs.surface,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  items: _tiposCliente
                      .map((t) =>
                          DropdownMenuItem(value: t, child: Text(t)))
                      .toList(),
                  onChanged: (v) => setState(() {
                    _clienteTipo = v!;
                    _clienteId = null;
                    _clienteNombreController.clear();
                  }),
                ),
              ),
              if (_clienteTipo != 'Otro' &&
                  profesionalesFiltrados.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: DropdownButtonFormField<String>(
                    value: _clienteId,
                    decoration: InputDecoration(
                      labelText: 'Seleccionar $_clienteTipo',
                      filled: true,
                      fillColor: cs.surface,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    items: [
                      const DropdownMenuItem(
                          value: null,
                          child: Text('Escribir manualmente')),
                      ...profesionalesFiltrados.map((p) =>
                          DropdownMenuItem(
                            value: p['id'],
                            child: Text(
                                '${p['nombre']} ${p['apellido']}'),
                          )),
                    ],
                    onChanged: (v) {
                      setState(() {
                        _clienteId = v;
                        if (v != null) {
                          final prof = profesionalesFiltrados
                              .firstWhere((p) => p['id'] == v);
                          _clienteNombreController.text =
                              '${prof['nombre']} ${prof['apellido']}';
                        } else {
                          _clienteNombreController.clear();
                        }
                      });
                    },
                  ),
                ),
              if (_clienteId == null)
                _Campo(
                  label: 'Nombre del cliente',
                  controller: _clienteNombreController,
                  requerido: true,
                ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Trámites',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: cs.onSurface)),
                  TextButton.icon(
                    onPressed: _agregarTramite,
                    icon: Icon(Icons.add, color: cs.primary),
                    label: Text('Agregar',
                        style: TextStyle(color: cs.primary)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (_tramites.isEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cs.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: Theme.of(context).dividerColor),
                  ),
                  child: Center(
                    child: Text('Sin trámites cargados',
                        style: TextStyle(
                            color: cs.onSurface.withOpacity(0.4))),
                  ),
                )
              else
                ..._tramites.asMap().entries.map((entry) {
                  final i = entry.key;
                  final t = entry.value;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cs.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: Theme.of(context).dividerColor),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                t['naturaleza'] ?? '',
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: cs.onSurface),
                              ),
                              if ((t['oficinaNombre'] ?? '') != '')
                                Text(t['oficinaNombre'],
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: cs.onSurface
                                            .withOpacity(0.6))),
                              if ((t['fechaLimite'] ?? '') != '')
                                Text('Vence: ${t['fechaLimite']}',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: cs.onSurface
                                            .withOpacity(0.5))),
                              if ((t['empleadoAsignado'] ?? '') != '')
                                Text(
                                    'Empleado: ${t['empleadoAsignado']}',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: cs.onSurface
                                            .withOpacity(0.4))),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit_outlined,
                                  color: cs.primary, size: 20),
                              onPressed: () => _editarTramite(i),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete_outline,
                                  color: cs.onSurface.withOpacity(0.3),
                                  size: 20),
                              onPressed: () => setState(
                                  () => _tramites.removeAt(i)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _guardando ? null : _guardar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cs.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _guardando
                      ? const CircularProgressIndicator(
                          color: Colors.white)
                      : Text(
                          esEdicion ? 'Guardar cambios' : 'Crear caso',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class _TramiteDialog extends StatefulWidget {
  final List<Map<String, dynamic>> oficinas;
  final List<Map<String, dynamic>> empleados;
  final Map<String, dynamic>? tramiteExistente;
  final Function(Map<String, dynamic>) onGuardar;

  const _TramiteDialog({
    required this.oficinas,
    required this.empleados,
    required this.onGuardar,
    this.tramiteExistente,
  });

  @override
  State<_TramiteDialog> createState() => _TramiteDialogState();
}

class _TramiteDialogState extends State<_TramiteDialog> {
  late TextEditingController _naturalezaController;
  late TextEditingController _fechaLimiteController;
  late TextEditingController _revisionController;
  late TextEditingController _oficinaNombreLibreController;
  late TextEditingController _docController;

  String? _oficinaId;
  String _oficinaNombre = '';
  String? _tramitePrecargado;
  String? _empleadoAsignado;
  String _estado = 'pendiente';
  bool _oficinaLibre = false;
  List<String> _tramitesPrecargados = [];
  List<Map<String, dynamic>> _documentacion = [];

  @override
  void initState() {
    super.initState();
    final t = widget.tramiteExistente;
    _naturalezaController =
        TextEditingController(text: t?['naturaleza'] ?? '');
    _fechaLimiteController =
        TextEditingController(text: t?['fechaLimite'] ?? '');
    _revisionController =
        TextEditingController(text: t?['revisionPeriodica'] ?? '');
    _oficinaNombreLibreController =
        TextEditingController(text: t?['oficinaNombreLibre'] ?? '');
    _docController = TextEditingController();
    _oficinaId = t?['oficinaId'];
    _oficinaNombre = t?['oficinaNombre'] ?? '';
    _empleadoAsignado = t?['empleadoAsignado'];
    _estado = t?['estado'] ?? 'pendiente';
    _oficinaLibre = t?['oficinaLibre'] == true;

    if (t?['documentacion'] != null && t!['documentacion'] is List) {
      _documentacion = List<Map<String, dynamic>>.from(
        (t['documentacion'] as List).map((d) {
          if (d is Map) return Map<String, dynamic>.from(d as Map);
          return {'nombre': d.toString(), 'verificado': false};
        }),
      );
    }
  }

  @override
  void dispose() {
    _naturalezaController.dispose();
    _fechaLimiteController.dispose();
    _revisionController.dispose();
    _oficinaNombreLibreController.dispose();
    _docController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return AlertDialog(
      title: Text(widget.tramiteExistente != null
          ? 'Editar trámite'
          : 'Agregar trámite'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _CampoDialog(
                label: 'Naturaleza del trámite',
                controller: _naturalezaController),
            const Text('Oficina',
                style: TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _oficinaLibre = false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: !_oficinaLibre
                            ? cs.primary
                            : const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text('Del sistema',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 13,
                              color: !_oficinaLibre
                                  ? Colors.white
                                  : const Color(0xFF6B7280))),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _oficinaLibre = true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: _oficinaLibre
                            ? cs.primary
                            : const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text('Libre',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 13,
                              color: _oficinaLibre
                                  ? Colors.white
                                  : const Color(0xFF6B7280))),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (!_oficinaLibre) ...[
              DropdownButtonFormField<String>(
                value: _oficinaId,
                decoration: InputDecoration(
                  labelText: 'Seleccionar oficina',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                items: [
                  const DropdownMenuItem(
                      value: null, child: Text('Sin oficina')),
                  ...widget.oficinas.map((o) => DropdownMenuItem(
                        value: o['id'],
                        child: Text(o['nombre'] ?? ''),
                      )),
                ],
                onChanged: (v) {
                  setState(() {
                    _oficinaId = v;
                    _tramitePrecargado = null;
                    _documentacion = [];
                    if (v != null) {
                      final of = widget.oficinas
                          .firstWhere((o) => o['id'] == v);
                      _oficinaNombre = of['nombre'] ?? '';
                      final tramites = of['tramites'] as List? ?? [];
                      _tramitesPrecargados = tramites.map((t) {
                        if (t is Map)
                          return t['nombre']?.toString() ?? '';
                        return t.toString();
                      }).toList();
                    } else {
                      _oficinaNombre = '';
                      _tramitesPrecargados = [];
                    }
                  });
                },
              ),
              if (_tramitesPrecargados.isNotEmpty) ...[
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _tramitePrecargado,
                  decoration: InputDecoration(
                    labelText: 'Trámite precargado (opcional)',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  items: [
                    const DropdownMenuItem(
                        value: null, child: Text('Ninguno')),
                    ..._tramitesPrecargados.map((t) =>
                        DropdownMenuItem(value: t, child: Text(t))),
                  ],
                  onChanged: (v) {
                    setState(() {
                      _tramitePrecargado = v;
                      if (v != null) {
                        if (_naturalezaController.text.isEmpty) {
                          _naturalezaController.text = v;
                        }
                        // Traer documentación de la oficina
                        if (_oficinaId != null) {
                          final oficina = widget.oficinas.firstWhere(
                              (o) => o['id'] == _oficinaId,
                              orElse: () => {});
                          if (oficina.isNotEmpty) {
                            final tramites =
                                (oficina['tramites'] as List? ?? []);
                            for (final t in tramites) {
                              if (t is Map &&
                                  (t['nombre']?.toString() ?? '') == v) {
                                final docs = t['documentacion'];
                                if (docs is List && docs.isNotEmpty) {
                                  _documentacion =
                                      List<Map<String, dynamic>>.from(
                                    docs.map((d) {
                                      if (d is Map)
                                        return Map<String, dynamic>.from(
                                            d as Map);
                                      return {
                                        'nombre': d.toString(),
                                        'verificado': false
                                      };
                                    }),
                                  );
                                }
                                break;
                              }
                            }
                          }
                        }
                      }
                    });
                  },
                ),
              ],
            ] else ...[
              _CampoDialog(
                  label: 'Nombre de la oficina',
                  controller: _oficinaNombreLibreController),
            ],
            const SizedBox(height: 4),
            _CampoDialog(
                label: 'Fecha límite (dd/mm/aa)',
                controller: _fechaLimiteController),
            _CampoDialog(
                label: 'Revisión periódica (cada X días)',
                controller: _revisionController),

            // Documentación checklist
            const SizedBox(height: 4),
            const Text('Documentación requerida',
                style: TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            ..._documentacion.asMap().entries.map((entry) {
              final i = entry.key;
              final d = entry.value;
              return Row(
                children: [
                  Checkbox(
                    value: d['verificado'] == true,
                    activeColor: cs.primary,
                    onChanged: (v) {
                      setState(() {
                        _documentacion[i]['verificado'] = v;
                      });
                    },
                  ),
                  Expanded(
                    child: Text(
                      d['nombre'] ?? '',
                      style: TextStyle(
                        fontSize: 13,
                        decoration: d['verificado'] == true
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline,
                        size: 18, color: Color(0xFF9CA3AF)),
                    onPressed: () =>
                        setState(() => _documentacion.removeAt(i)),
                  ),
                ],
              );
            }),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _docController,
                    decoration: InputDecoration(
                      hintText: 'Agregar documento...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.add_circle, color: cs.primary),
                  onPressed: () {
                    if (_docController.text.trim().isNotEmpty) {
                      setState(() {
                        _documentacion.add({
                          'nombre': _docController.text.trim(),
                          'verificado': false,
                        });
                        _docController.clear();
                      });
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Empleado asignado
            DropdownButtonFormField<String>(
              value: _empleadoAsignado,
              decoration: InputDecoration(
                labelText: 'Empleado asignado',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              items: [
                const DropdownMenuItem(
                    value: null, child: Text('Sin asignar')),
                ...widget.empleados.map((e) => DropdownMenuItem(
                      value: e['nombre'],
                      child:
                          Text('${e['nombre']} · ${e['rol'] ?? ''}'),
                    )),
              ],
              onChanged: (v) => setState(() => _empleadoAsignado = v),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _estado,
              decoration: InputDecoration(
                labelText: 'Estado',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              items: const [
                DropdownMenuItem(
                    value: 'pendiente', child: Text('Pendiente')),
                DropdownMenuItem(
                    value: 'en curso', child: Text('En curso')),
                DropdownMenuItem(
                    value: 'completado', child: Text('Completado')),
              ],
              onChanged: (v) => setState(() => _estado = v!),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onGuardar({
              'naturaleza': _naturalezaController.text.trim(),
              'oficinaNombre': _oficinaLibre
                  ? _oficinaNombreLibreController.text.trim()
                  : _oficinaNombre,
              'oficinaId': _oficinaId ?? '',
              'oficinaLibre': _oficinaLibre,
              'tramitePrecargado': _tramitePrecargado ?? '',
              'fechaLimite': _fechaLimiteController.text.trim(),
              'revisionPeriodica': _revisionController.text.trim(),
              'documentacion': _documentacion,
              'empleadoAsignado': _empleadoAsignado ?? '',
              'estado': _estado,
            });
            Navigator.pop(context);
          },
          style:
              ElevatedButton.styleFrom(backgroundColor: cs.primary),
          child: const Text('Guardar',
              style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}

class _Campo extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool requerido;

  const _Campo({
    required this.label,
    required this.controller,
    this.requerido = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        validator: requerido
            ? (v) => v == null || v.isEmpty ? 'Campo requerido' : null
            : null,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: cs.surface,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  BorderSide(color: Theme.of(context).dividerColor)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  BorderSide(color: Theme.of(context).dividerColor)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: cs.primary)),
        ),
      ),
    );
  }
}

class _CampoDialog extends StatelessWidget {
  final String label;
  final TextEditingController controller;

  const _CampoDialog({required this.label, required this.controller});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: cs.primary)),
        ),
      ),
    );
  }
}