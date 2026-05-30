import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // CASOS
  Stream<List<Map<String, dynamic>>> getCasos() {
    return _db.collection('casos').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  Future<void> agregarCaso(Map<String, dynamic> caso) async {
    await _db.collection('casos').add(caso);
  }

  Future<void> actualizarCaso(String id, Map<String, dynamic> datos) async {
    await _db.collection('casos').doc(id).set(datos, SetOptions(merge: true));
  }

  Future<void> eliminarCaso(String id) async {
    await _db.collection('casos').doc(id).delete();
  }

  // PROFESIONALES
  Stream<List<Map<String, dynamic>>> getProfesionales() {
    return _db.collection('profesionales').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  Future<void> agregarProfesional(Map<String, dynamic> profesional) async {
    await _db.collection('profesionales').add(profesional);
  }

  Future<void> actualizarProfesional(String id, Map<String, dynamic> datos) async {
    await _db.collection('profesionales').doc(id).set(datos, SetOptions(merge: false));
  }

  Future<void> eliminarProfesional(String id) async {
    await _db.collection('profesionales').doc(id).delete();
  }

  // OFICINAS
  Stream<List<Map<String, dynamic>>> getOficinas() {
    return _db.collection('oficinas').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  Future<void> agregarOficina(Map<String, dynamic> oficina) async {
    await _db.collection('oficinas').add(oficina);
  }

  Future<void> actualizarOficina(String id, Map<String, dynamic> datos) async {
    await _db.collection('oficinas').doc(id).set(datos, SetOptions(merge: false));
  }

  Future<void> eliminarOficina(String id) async {
    await _db.collection('oficinas').doc(id).delete();
  }

  // EMPLEADOS
  Stream<List<Map<String, dynamic>>> getEmpleados() {
    return _db.collection('empleados').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  Future<void> agregarEmpleado(Map<String, dynamic> empleado) async {
    await _db.collection('empleados').add(empleado);
  }

  Future<void> actualizarEmpleado(String id, Map<String, dynamic> datos) async {
    await _db.collection('empleados').doc(id).set(datos, SetOptions(merge: false));
  }

  Future<void> eliminarEmpleado(String id) async {
    await _db.collection('empleados').doc(id).delete();
  }
}