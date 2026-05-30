import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole { empleado, profesional, sinAcceso, cargando }

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;
  bool get isLoggedIn => _auth.currentUser != null;

  UserRole _role = UserRole.cargando;
  UserRole get role => _role;

  Map<String, dynamic> _userData = {};
  Map<String, dynamic> get userData => _userData;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  AuthService() {
    _auth.authStateChanges().listen((user) async {
      if (user != null) {
        await _detectarRol(user.email ?? '');
      } else {
        _role = UserRole.sinAcceso;
        _userData = {};
        notifyListeners();
      }
    });
  }

  Future<void> _detectarRol(String email) async {
    _role = UserRole.cargando;
    notifyListeners();

    // Buscar en empleados
    final empleados = await _db
        .collection('empleados')
        .where('mail', isEqualTo: email)
        .get();

    if (empleados.docs.isNotEmpty) {
      _role = UserRole.empleado;
      _userData = empleados.docs.first.data();
      _userData['id'] = empleados.docs.first.id;
      notifyListeners();
      return;
    }

    // Buscar en profesionales
    final profesionales = await _db
        .collection('profesionales')
        .where('mail', isEqualTo: email)
        .get();

    if (profesionales.docs.isNotEmpty) {
      _role = UserRole.profesional;
      _userData = profesionales.docs.first.data();
      _userData['id'] = profesionales.docs.first.id;
      notifyListeners();
      return;
    }

    // Sin acceso
    _role = UserRole.sinAcceso;
    _userData = {};
    notifyListeners();
  }

  Future<void> signInWithGoogle() async {
    try {
      GoogleAuthProvider googleProvider = GoogleAuthProvider();
      googleProvider.addScope('email');
      googleProvider.addScope('profile');
      await _auth.signInWithPopup(googleProvider);
      notifyListeners();
    } catch (e) {
      debugPrint('Error en login: $e');
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    _role = UserRole.sinAcceso;
    _userData = {};
    notifyListeners();
  }
}