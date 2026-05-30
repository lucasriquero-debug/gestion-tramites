import 'package:flutter/material.dart';
import '../services/firestore_service.dart';

class OficinaFormScreen extends StatefulWidget {
  final Map<String, dynamic>? oficina;

  const OficinaFormScreen({super.key, this.oficina});

  @override
  State<OficinaFormScreen> createState() => _OficinaFormScreenState();
}

class _OficinaFormScreenState extends State<OficinaFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirestoreService _firestoreService = FirestoreService();

  late TextEditingController _nombreController;
  late TextEditingController _ubicacionController;
  late TextEditingController _mailController;
  late TextEditingController _telefonoController;

  List<Map<String, dynamic>> _contactos = [];
  List<Map<String, dynamic>> _tramites = [];
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    final o = widget.oficina;
    _nombreController = TextEditingController(text: o?['nombre'] ?? '');
    _ubicacionController = TextEditingController(text: o?['ubicacion'] ?? '');
    _mailController = TextEditingController(text: o?['mail'] ?? '');
    _telefonoController = TextEditingController(text: o?['telefono'] ?? '');

    if (o?['contactos'] != null) {
      _contactos = List<Map<String, dynamic>>.from(
        (o!['contactos'] as List).map((c) => Map<String, dynamic>.from(c)),
      );
    }

    if (o?['tramites'] != null) {
      _tramites = (o!['tramites'] as List).map((t) {
        if (t is Map) return Map<String, dynamic>.from(t);
        return {'nombre': t.toString(), 'area': '', 'documentacion': ''};
      }).toList();
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _ubicacionController.dispose();
    _mailController.dispose();
    _telefonoController.dispose();
    super.dispose();
  }

  void _agregarContacto() {
    showDialog(
      context: context,
      builder: (_) {
        final nombreC = TextEditingController();
        final areaC = TextEditingController();
        final telefonoC = TextEditingController();
        final cumpleanosC = TextEditingController();

        return AlertDialog(
          title: const Text('Agregar contacto'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _CampoDialog(label: 'Nombre', controller: nombreC),
                _CampoDialog(label: 'Área', controller: areaC),
                _CampoDialog(label: 'Teléfono', controller: telefonoC),
                _CampoDialog(label: 'Cumpleaños', controller: cumpleanosC),
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
                  _contactos.add({
                    'nombre': nombreC.text.trim(),
                    'area': areaC.text.trim(),
                    'telefono': telefonoC.text.trim(),
                    'cumpleanos': cumpleanosC.text.trim(),
                  });
                });
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1)),
              child: const Text('Agregar',
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _agregarTramite() {
    showDialog(
      context: context,
      builder: (_) {
        final nombreC = TextEditingController();
        final areaC = TextEditingController();
        final documentacionC = TextEditingController();

        return AlertDialog(
          title: const Text('Agregar trámite'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _CampoDialog(label: 'Nombre', controller: nombreC),
                _CampoDialog(label: 'Área', controller: areaC),
                _CampoDialog(
                    label: 'Documentación requerida',
                    controller: documentacionC),
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
                  _tramites.add({
                    'nombre': nombreC.text.trim(),
                    'area': areaC.text.trim(),
                    'documentacion': documentacionC.text.trim(),
                  });
                });
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1)),
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
      'ubicacion': _ubicacionController.text.trim(),
      'mail': _mailController.text.trim(),
      'telefono': _telefonoController.text.trim(),
      'contactos': _contactos,
      'tramites': _tramites,
    };

    if (widget.oficina != null) {
      await _firestoreService.actualizarOficina(
          widget.oficina!['id'], datos);
    } else {
      await _firestoreService.agregarOficina(datos);
    }

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final esEdicion = widget.oficina != null;

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
          esEdicion ? 'Editar oficina' : 'Nueva oficina',
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
                label: 'Nombre de la oficina',
                controller: _nombreController,
                requerido: true,
              ),
              _Campo(label: 'Ubicación', controller: _ubicacionController),
              _Campo(label: 'Mail', controller: _mailController),
              _Campo(label: 'Teléfono', controller: _telefonoController),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Contactos estratégicos',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1F2937))),
                  TextButton.icon(
                    onPressed: _agregarContacto,
                    icon: const Icon(Icons.add, color: Color(0xFF6366F1)),
                    label: const Text('Agregar',
                        style: TextStyle(color: Color(0xFF6366F1))),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (_contactos.isEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: const Center(
                    child: Text('Sin contactos',
                        style: TextStyle(color: Color(0xFF9CA3AF))),
                  ),
                )
              else
                ..._contactos.asMap().entries.map((entry) {
                  final i = entry.key;
                  final c = entry.value;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(c['nombre'] ?? '',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF1F2937))),
                              Text('${c['area']} · ${c['telefono']}',
                                  style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF6B7280))),
                              if ((c['cumpleanos'] ?? '') != '')
                                Text(c['cumpleanos'] ?? '',
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF9CA3AF))),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline,
                              color: Color(0xFF9CA3AF)),
                          onPressed: () =>
                              setState(() => _contactos.removeAt(i)),
                        ),
                      ],
                    ),
                  );
                }),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Trámites',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1F2937))),
                  TextButton.icon(
                    onPressed: _agregarTramite,
                    icon: const Icon(Icons.add, color: Color(0xFF6366F1)),
                    label: const Text('Agregar',
                        style: TextStyle(color: Color(0xFF6366F1))),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (_tramites.isEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: const Center(
                    child: Text('Sin trámites',
                        style: TextStyle(color: Color(0xFF9CA3AF))),
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
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(t['nombre'] ?? '',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF1F2937))),
                              if ((t['area'] ?? '') != '')
                                Text(t['area'] ?? '',
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF6B7280))),
                              if ((t['documentacion'] ?? '') != '')
                                Text(t['documentacion'] ?? '',
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF9CA3AF))),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline,
                              color: Color(0xFF9CA3AF)),
                          onPressed: () =>
                              setState(() => _tramites.removeAt(i)),
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
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _guardando
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          esEdicion ? 'Guardar cambios' : 'Crear oficina',
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
            ? (v) => v == null || v.isEmpty ? 'Campo requerido' : null
            : null,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF6366F1))),
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF6366F1))),
        ),
      ),
    );
  }
}