import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/notificacion_service.dart';

class MainLayout extends StatelessWidget {
  final Widget child;
  final String currentRoute;

  const MainLayout({
    super.key,
    required this.child,
    required this.currentRoute,
  });

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);
    final mail = auth.currentUser?.email ?? '';
    final notificacionService = NotificacionService();
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: Row(
        children: [
          if (MediaQuery.of(context).size.width > 600)
            NavigationRail(
              backgroundColor: cs.surface,
              selectedIndex: _getSelectedIndex(currentRoute),
              onDestinationSelected: (i) => _navegarA(context, i),
              labelType: NavigationRailLabelType.all,
              leading: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Image.asset(
                  'assets/Isotipo.png',
                  height: 36,
                ),
              ),
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home),
                  label: Text('Home'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.folder_outlined),
                  selectedIcon: Icon(Icons.folder),
                  label: Text('Casos'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.assignment_outlined),
                  selectedIcon: Icon(Icons.assignment),
                  label: Text('Trámites'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.people_outline),
                  selectedIcon: Icon(Icons.people),
                  label: Text('Profesionales'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.business_outlined),
                  selectedIcon: Icon(Icons.business),
                  label: Text('Oficinas'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.badge_outlined),
                  selectedIcon: Icon(Icons.badge),
                  label: Text('Empleados'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.notifications_outlined),
                  selectedIcon: Icon(Icons.notifications),
                  label: Text('Avisos'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.settings_outlined),
                  selectedIcon: Icon(Icons.settings),
                  label: Text('Ajustes'),
                ),
              ],
            ),
          const VerticalDivider(width: 1),
          Expanded(
            child: Scaffold(
              appBar: AppBar(
                backgroundColor: cs.surface,
                elevation: 0,
                actions: [
                  StreamBuilder<int>(
                    stream: notificacionService.getNoLeidas(mail),
                    builder: (context, snapshot) {
                      final noLeidas = snapshot.data ?? 0;
                      return Stack(
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.notifications_outlined,
                              color: cs.onSurface.withOpacity(0.7),
                            ),
                            onPressed: () => context.go('/notificaciones'),
                          ),
                          if (noLeidas > 0)
                            Positioned(
                              right: 8,
                              top: 8,
                              child: Container(
                                width: 16,
                                height: 16,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFEF4444),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    '$noLeidas',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                ],
              ),
              body: child,
            ),
          ),
        ],
      ),
      bottomNavigationBar: MediaQuery.of(context).size.width <= 600
          ? NavigationBar(
              selectedIndex: _getSelectedIndex(currentRoute),
              onDestinationSelected: (i) => _navegarA(context, i),
              backgroundColor: cs.surface,
              indicatorColor: cs.primary.withOpacity(0.1),
              destinations: [
                const NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home),
                  label: 'Home',
                ),
                const NavigationDestination(
                  icon: Icon(Icons.folder_outlined),
                  selectedIcon: Icon(Icons.folder),
                  label: 'Casos',
                ),
                const NavigationDestination(
                  icon: Icon(Icons.assignment_outlined),
                  selectedIcon: Icon(Icons.assignment),
                  label: 'Trámites',
                ),
                const NavigationDestination(
                  icon: Icon(Icons.people_outline),
                  selectedIcon: Icon(Icons.people),
                  label: 'Profesionales',
                ),
                const NavigationDestination(
                  icon: Icon(Icons.business_outlined),
                  selectedIcon: Icon(Icons.business),
                  label: 'Oficinas',
                ),
                const NavigationDestination(
                  icon: Icon(Icons.badge_outlined),
                  selectedIcon: Icon(Icons.badge),
                  label: 'Empleados',
                ),
                NavigationDestination(
                  icon: StreamBuilder<int>(
                    stream: notificacionService.getNoLeidas(mail),
                    builder: (context, snapshot) {
                      final noLeidas = snapshot.data ?? 0;
                      return Stack(
                        children: [
                          const Icon(Icons.notifications_outlined),
                          if (noLeidas > 0)
                            Positioned(
                              right: 0,
                              top: 0,
                              child: Container(
                                width: 12,
                                height: 12,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFEF4444),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                  selectedIcon: const Icon(Icons.notifications),
                  label: 'Avisos',
                ),
                const NavigationDestination(
                  icon: Icon(Icons.settings_outlined),
                  selectedIcon: Icon(Icons.settings),
                  label: 'Ajustes',
                ),
              ],
            )
          : null,
    );
  }

  int _getSelectedIndex(String route) {
    switch (route) {
      case '/home':
        return 0;
      case '/casos':
        return 1;
      case '/tramites':
        return 2;
      case '/profesionales':
        return 3;
      case '/oficinas':
        return 4;
      case '/empleados':
        return 5;
      case '/notificaciones':
        return 6;
      case '/ajustes':
        return 7;
      default:
        return 0;
    }
  }

  void _navegarA(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/casos');
        break;
      case 2:
        context.go('/tramites');
        break;
      case 3:
        context.go('/profesionales');
        break;
      case 4:
        context.go('/oficinas');
        break;
      case 5:
        context.go('/empleados');
        break;
      case 6:
        context.go('/notificaciones');
        break;
      case 7:
        context.go('/ajustes');
        break;
    }
  }
}