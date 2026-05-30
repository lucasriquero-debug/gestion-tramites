import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

class SinAccesoScreen extends StatelessWidget {
  const SinAccesoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: const Color(0xE6E5E1D9),
      body: Center(
        child: Container(
          width: 360,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('assets/Isotipo.png', height: 80),
              const SizedBox(height: 24),
              const Icon(
                Icons.lock_outline,
                size: 48,
                color: Color(0xFF1B4F72),
              ),
              const SizedBox(height: 16),
              const Text(
                'Sin acceso',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1B4F72),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tu cuenta no tiene acceso al sistema. Contactá al administrador para que te registre.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade500,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => auth.signOut(),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: Color(0xFF1B4F72)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Cerrar sesión',
                    style: TextStyle(color: Color(0xFF1B4F72)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}