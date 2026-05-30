import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../screens/login_screen.dart';
import '../screens/home_screen.dart';
import '../screens/casos_screen.dart';
import '../screens/oficinas_screen.dart';
import '../screens/profesionales_screen.dart';
import '../screens/empleados_screen.dart';
import '../screens/tramites_screen.dart';
import '../screens/ajustes_screen.dart';
import '../screens/sin_acceso_screen.dart';
import '../screens/cliente_screen.dart';
import '../widgets/main_layout.dart';
import '../screens/notificaciones_screen.dart';


final appRouter = GoRouter(
  initialLocation: '/login',
  refreshListenable: FirebaseAuthNotifier(),
  redirect: (context, state) {
    final isLoggedIn = FirebaseAuth.instance.currentUser != null;
    final isLoginRoute = state.matchedLocation == '/login';
    final isSinAcceso = state.matchedLocation == '/sin-acceso';
    final isCliente = state.matchedLocation == '/cliente';
    final isCargando = state.matchedLocation == '/cargando';

    if (!isLoggedIn && !isLoginRoute) return '/login';
    if (isLoggedIn && isLoginRoute) return '/cargando';

    if (isLoggedIn &&
        !isLoginRoute &&
        !isSinAcceso &&
        !isCliente &&
        !isCargando) {
      final auth = Provider.of<AuthService>(context, listen: false);
      switch (auth.role) {
        case UserRole.cargando:
          return '/cargando';
        case UserRole.empleado:
          return null;
        case UserRole.profesional:
          return '/cliente';
        case UserRole.sinAcceso:
          return '/sin-acceso';
      }
    }
    return null;
  },
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),GoRoute(
  path: '/notificaciones',
  builder: (context, state) => MainLayout(
    currentRoute: '/notificaciones',
    child: const NotificacionesScreen(),
  ),
),
    GoRoute(
      path: '/cargando',
      builder: (context, state) => const _CargandoScreen(),
    ),
    GoRoute(
      path: '/sin-acceso',
      builder: (context, state) => const SinAccesoScreen(),
    ),
    GoRoute(
      path: '/cliente',
      builder: (context, state) => const ClienteScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => MainLayout(
        currentRoute: '/home',
        child: const HomeScreen(),
      ),
    ),
    GoRoute(
      path: '/casos',
      builder: (context, state) => MainLayout(
        currentRoute: '/casos',
        child: const CasosScreen(),
      ),
    ),
    GoRoute(
      path: '/tramites',
      builder: (context, state) => MainLayout(
        currentRoute: '/tramites',
        child: const TramitesScreen(),
      ),
    ),
    GoRoute(
      path: '/profesionales',
      builder: (context, state) => MainLayout(
        currentRoute: '/profesionales',
        child: const ProfesionalesScreen(),
      ),
    ),
    GoRoute(
      path: '/oficinas',
      builder: (context, state) => MainLayout(
        currentRoute: '/oficinas',
        child: const OficinasScreen(),
      ),
    ),
    GoRoute(
      path: '/empleados',
      builder: (context, state) => MainLayout(
        currentRoute: '/empleados',
        child: const EmpleadosScreen(),
      ),
    ),
    GoRoute(
      path: '/ajustes',
      builder: (context, state) => MainLayout(
        currentRoute: '/ajustes',
        child: const AjustesScreen(),
      ),
    ),
  ],
);

class FirebaseAuthNotifier extends ChangeNotifier {
  FirebaseAuthNotifier() {
    FirebaseAuth.instance.authStateChanges().listen((_) {
      notifyListeners();
    });
  }
}

class _CargandoScreen extends StatefulWidget {
  const _CargandoScreen();

  @override
  State<_CargandoScreen> createState() => _CargandoScreenState();
}

class _CargandoScreenState extends State<_CargandoScreen> {
  @override
  void initState() {
    super.initState();
    _verificarRol();
  }

  Future<void> _verificarRol() async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    final auth = Provider.of<AuthService>(context, listen: false);
    switch (auth.role) {
      case UserRole.cargando:
        await Future.delayed(const Duration(milliseconds: 500));
        _verificarRol();
        break;
      case UserRole.empleado:
        if (mounted) context.go('/home');
        break;
      case UserRole.profesional:
        if (mounted) context.go('/cliente');
        break;
      case UserRole.sinAcceso:
        if (mounted) context.go('/sin-acceso');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xE6E5E1D9),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/Isotipo.png', height: 80),
            const SizedBox(height: 32),
            const CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}