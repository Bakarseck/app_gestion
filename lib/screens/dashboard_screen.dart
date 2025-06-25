import 'package:flutter/material.dart';
import 'package:app_gestion/theme/colors.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text('Tableau de Bord'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stats Cards
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Facture Actuelle',
                    '45,250 FCFA',
                    Icons.receipt,
                    kSenelecBlue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    'Consommation',
                    '324 kWh',
                    Icons.flash_on,
                    kSenelecViolet,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Options du tableau de bord
            const Text(
              'Gestion de Compte',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: kSenelecBlue,
              ),
            ),
            const SizedBox(height: 16),

            _buildDashboardOption(
              Icons.receipt_long,
              'Mes Factures',
              'Consultez l\'historique de vos factures',
              kSenelecBlue,
            ),
            _buildDashboardOption(
              Icons.show_chart,
              'Consommation Détaillée',
              'Analysez votre consommation énergétique',
              kSenelecViolet,
            ),
            _buildDashboardOption(
              Icons.notifications,
              'Notifications',
              'Gérez vos alertes et notifications',
              kSenelecPink,
            ),
            _buildDashboardOption(
              Icons.settings,
              'Paramètres du Compte',
              'Configurez vos préférences',
              kSenelecYellow,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardOption(
    IconData icon,
    String title,
    String subtitle,
    Color color,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: Colors.grey, fontSize: 14),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          // Ajoutez la navigation vers les différentes sections
        },
      ),
    );
  }
}
