import 'package:flutter/material.dart';
import 'package:app_gestion/theme/colors.dart';

class LoginPage extends StatelessWidget {
  final String role;
  const LoginPage({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text('Connexion $role'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: kSenelecBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(32),
                      ),
                      child: Icon(
                        role == 'Administrateur'
                            ? Icons.admin_panel_settings
                            : Icons.engineering,
                        size: 64,
                        color: kSenelecBlue,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Connexion $role',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      'Formulaire de connexion en cours de développement',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
