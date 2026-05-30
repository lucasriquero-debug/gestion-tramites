import 'package:flutter/material.dart';
import '../services/firestore_service.dart';

class ProfesionalFormScreen extends StatefulWidget {
  final Map<String, dynamic>? profesional;

  const ProfesionalFormScreen({super.key, this.profesional});

  @override
  State<ProfesionalFormScreen> createState() => _ProfesionalFormScreenState();
}

class _ProfesionalFormScreenState extends State<ProfesionalFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirestoreService _firestoreService = FirestoreService();

  late TextEditingController _nombreController;
  late TextEditingController _apellidoController;
  late TextEditingController _cuilController;
  late TextEditingController _telefonoController;
  late TextEditingController _mailController;
  late TextEditingController _domicilioController;
  late TextEditingController _fechaCumpleanosController;
  late TextEditingController _matriculaController;
  late TextEditingController _registroController;
  String _profesion = 'Agrimensor';
  List<Map<String, dynamic>> _cuentas = [];
  bool _guardando = false;

  final List<String> _profesiones = [
    'Agrimensor',
    'Abogado',
    'Escribano',
    'Otro',
  ];

  @override
  void initState() {
    super.initState();
    final p = widget.profesional;
    _nombreController = TextEditingController(text: p?['nombre'] ?? '');
    _apellidoController =
        TextEditingController(text: p?['apellido'] ?? '');
    _cuilController = TextEditingController(text: p?['cuil'] ?? '');
    _telefonoController =
        TextEditingController(text: p?['telefono'] ?? '');
    _mailController = TextEditingController(text: p?['mail'] ?? '');
    _domicilioController =
        TextEditingController(text: p?['domicilio'] ?? '');
    _fechaCumpleanosController =
        TextEditingController(text: p?['fechaCumpleanos'] ?? '');
    _matriculaController =
        TextEditingController(text: p?['matricula'] ?? '');
    _registroController =
        TextEditingController(text: p?['registro'] ?? '');
    _profesion = p?['profesion'] ?? 'Agrimensor';

    if (p?['cuentas'] != null) {
      _cuentas = List<Map<String, dynamic>>.from(
        (p!['cuentas'] as List).map((c) => Map<String, dynamic>.from(c)),
      );
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoController.dispose();
    _cuilController.dispose();
    _telefonoController.dispose();
    _mailController.dispose();
    _domicilioController.dispose();
    _fechaCumpleanosController.dispose();
    _matriculaController.dispose();
    _registroController.dispose();
    super.dispose();
  }

  void _agregarCuenta() {
    showDialog(
      context: context,
      builder: (_) {
        final oficinaC = TextEditingController();
        final usuarioC = TextEditingController();
        final contrasenaC = TextEditingController();

        return AlertDialog(
          title: const Text('Agregar cuenta de oficina'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _CampoDialog(label: 'Oficina', controller: oficinaC),
                _CampoDialog(label: 'Usuario', controller: usuarioC),
                _CampoDialog(
                    label: 'Contraseña', controller: contrasenaC),
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
                setState(() {
                  _cuentas.add({
                    'oficina': oficinaC.text.trim(),
                    'usuario': usuarioC.text.trim(),
                    'contrasena': contrasenaC.text.trim(),
                  });
                });
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
              ),
              child: const Text('Agregar',
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _guardando = true);

    final datos = {
      'nombre': _nombreController.text.trim(),
      'apellido': _apellidoController.text.trim(),
      'cuil': _cuilController.text.trim(),
      'telefono': _telefonoController.text.trim(),
      'mail': _mailController.text.trim(),
      'domicilio': _domicilioController.text.trim(),
      'fechaCumpleanos': _fechaCumpleanosController.text.trim(),
      'matricula': _matriculaController.text.trim(),
      'registro': _registroController.text.trim(),
      'profesion': _profesion,
      'cuentas': _cuentas,
    };

    if (widget.profesional != null) {
      await _firestoreService.actualizarProfesional(
          widget.profesional!['id'], datos);
    } else {
      await _firestoreService.agregarProfesional(datos);
    }

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final esEdicion = widget.profesional != null;

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
          esEdicion ? 'Editar profesional' : 'Nuevo profesional',
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
              // Profesión
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: DropdownButtonFormField<String>(
                  value: _profesion,
                  decoration: InputDecoration(
                    labelText: 'Profesión',
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
                  items: _profesiones
                      .map((p) =>
                          DropdownMenuItem(value: p, child: Text(p)))
                      .toList(),
                  onChanged: (v) => setState(() => _profesion = v!),
                ),
              ),

              _Campo(
                  label: 'Nombre',
                  controller: _nombreController,
                  requerido: true),
              _Campo(
                  label: 'Apellido',
                  controller: _apellidoController,
                  requerido: true),
              _Campo(label: 'CUIL', controller: _cuilController),
              _Campo(
                  label: 'Teléfono',
                  controller: _telefonoController),
              _Campo(label: 'Mail', controller: _mailController),
              _Campo(
                  label: 'Domicilio',
                  controller: _domicilioController),
              _Campo(
                  label: 'Fecha de cumpleaños',
                  controller: _fechaCumpleanosController),
              _Campo(
                  label: 'Matrícula',
                  controller: _matriculaController),
              _Campo(
                  label: 'Registro',
                  controller: _registroController),
              const SizedBox(height: 8),

              // Cuentas de oficina
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Cuentas de oficina',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _agregarCuenta,
                    icon: const Icon(Icons.add,
                        color: Color(0xFF6366F1)),
                    label: const Text('Agregar',
                        style: TextStyle(color: Color(0xFF6366F1))),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (_cuentas.isEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border:
                        Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: const Center(
                    child: Text('Sin cuentas',
                        style: TextStyle(color: Color(0xFF9CA3AF))),
                  ),
                )
              else
                ..._cuentas.asMap().entries.map((entry) {
                  final i = entry.key;
                  final c = entry.value;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: const Color(0xFFE5E7EB)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                c['oficina'] ?? '',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1F2937),
                                ),
                              ),
                              Text(
                                'Usuario: ${c['usuario']}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline,
                              color: Color(0xFF9CA3AF)),
                          onPressed: () =>
                              setState(() => _cuentas.removeAt(i)),
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
                              : 'Crear profesional',
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

class _CampoDialog extends StatelessWidget {
  final String label;
  final TextEditingController controller;

  const _CampoDialog(
      {required this.label, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
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