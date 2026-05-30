import 'package:flutter/material.dart';
import '../services/firestore_service.dart';

class EmpleadoFormScreen extends StatefulWidget {
  final Map<String, dynamic>? empleado;

  const EmpleadoFormScreen({super.key, this.empleado});

  @override
  State<EmpleadoFormScreen> createState() => _EmpleadoFormScreenState();
}

class _EmpleadoFormScreenState extends State<EmpleadoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirestoreService _firestoreService = FirestoreService();

  late TextEditingController _nombreController;
  late TextEditingController _aliasController;
  late TextEditingController _mailController;
  late TextEditingController _telefonoController;
  late TextEditingController _rolController;
  bool _guardando = false;

  Map<String, bool> _permisos = {
    'agregarCasos': false,
    'agregarProfesionales': false,
    'agregarTramites': false,
    'agregarOficinas': false,
    'verCasosNoAsignados': false,
    'verDatosProfesionales': false,
    'verDatosEmpleados': false,
  };

  final Map<String, String> _permisosLabels = {
    'agregarCasos': 'Agregar, editar o quitar casos',
    'agregarProfesionales': 'Agregar, editar o quitar profesionales',
    'agregarTramites': 'Agregar, editar o quitar trámites',
    'agregarOficinas': 'Agregar, editar o quitar oficinas',
    'verCasosNoAsignados': 'Ver casos no asignados',
    'verDatosProfesionales': 'Ver datos de profesionales',
    'verDatosEmpleados': 'Ver datos de empleados',
  };

  @override
  void initState() {
    super.initState();
    final e = widget.empleado;
    _nombreController = TextEditingController(text: e?['nombre'] ?? '');
    _aliasController = TextEditingController(text: e?['alias'] ?? '');
    _mailController = TextEditingController(text: e?['mail'] ?? '');
    _telefonoController =
        TextEditingController(text: e?['telefono'] ?? '');
    _rolController = TextEditingController(text: e?['rol'] ?? '');

    if (e?['permisos'] != null) {
      final p = e!['permisos'] as Map<String, dynamic>;
      _permisos = _permisos.map(
        (key, _) => MapEntry(key, p[key] == true),
      );
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _aliasController.dispose();
    _mailController.dispose();
    _telefonoController.dispose();
    _rolController.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _guardando = true);

    final datos = {
      'nombre': _nombreController.text.trim(),
      'alias': _aliasController.text.trim(),
      'mail': _mailController.text.trim(),
      'telefono': _telefonoController.text.trim(),
      'rol': _rolController.text.trim(),
      'permisos': _permisos,
    };

    if (widget.empleado != null) {
      await _firestoreService.actualizarEmpleado(
          widget.empleado!['id'], datos);
    } else {
      await _firestoreService.agregarEmpleado(datos);
    }

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final esEdicion = widget.empleado != null;

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
          esEdicion ? 'Editar empleado' : 'Nuevo empleado',
          style: const TextStyle(
            color: Color(0xFF1F2937),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Campo(
                label: 'Nombre',
                controller: _nombreController,
                requerido: true,
              ),
              _Campo(
                label: 'Alias',
                controller: _aliasController,
              ),
              _Campo(
                label: 'Mail',
                controller: _mailController,
              ),
              _Campo(
                label: 'Teléfono',
                controller: _telefonoController,
              ),
              _Campo(
                label: 'Rol',
                controller: _rolController,
              ),
              const SizedBox(height: 8),

              // Permisos
              const Text(
                'Permisos',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Column(
                  children: _permisos.entries.map((entry) {
                    final label =
                        _permisosLabels[entry.key] ?? entry.key;
                    return SwitchListTile(
                      title: Text(
                        label,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      value: entry.value,
                      activeColor: const Color(0xFF6366F1),
                      onChanged: (v) => setState(
                          () => _permisos[entry.key] = v),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _guardando ? null : _guardar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    padding:
                        const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _guardando
                      ? const CircularProgressIndicator(
                          color: Colors.white)
                      : Text(
                          esEdicion
                              ? 'Guardar cambios'
                              : 'Crear empleado',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        validator: requerido
            ? (v) =>
                v == null || v.isEmpty ? 'Campo requerido' : null
            : null,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                const BorderSide(color: Color(0xFFE5E7EB)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                const BorderSide(color: Color(0xFFE5E7EB)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                const BorderSide(color: Color(0xFF6366F1)),
          ),
        ),
      ),
    );
  }
}