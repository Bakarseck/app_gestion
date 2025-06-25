import 'package:app_gestion/screens/dashboard_screen.dart';
import 'package:app_gestion/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:app_gestion/theme/colors.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Image.asset(
                  'assets/images/logo.png',
                  width: 38,
                  height: 38,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
                border: Border.all(
                  color: kSenelecBlue.withOpacity(0.2),
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.account_circle,
                  color: kSenelecBlue,
                  size: 28,
                ),
              ),
            ),
            onSelected: (value) {
              if (value == 'admin') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const LoginPage(role: 'Administrateur'),
                  ),
                );
              } else if (value == 'technicien') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const LoginPage(role: 'Technicien'),
                  ),
                );
              }
            },
            itemBuilder:
                (context) => [
                  PopupMenuItem(
                    value: 'admin',
                    child: Row(
                      children: [
                        Icon(Icons.admin_panel_settings, color: kSenelecBlue),
                        SizedBox(width: 8),
                        Text('Administrateur'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'technicien',
                    child: Row(
                      children: [
                        Icon(Icons.engineering, color: kSenelecBlue),
                        SizedBox(width: 8),
                        Text('Technicien'),
                      ],
                    ),
                  ),
                ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            Container(
              height: 200,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [kSenelecBlue, kSenelecViolet],
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.10),
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Image.asset(
                            'assets/images/logo.png',
                            width: 38,
                            height: 38,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Bakar SECK',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        'Client Senelec',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 50),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildDrawerItem(Icons.dashboard, 'Tableau de bord', () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const DashboardPage()),
                    );
                  }),
                  _buildDrawerItem(Icons.show_chart, 'Consommation', null),
                  _buildDrawerItem(Icons.history, 'Historique', null),
                  const Divider(height: 32),
                  _buildDrawerItem(Icons.settings, 'Paramètres', null),
                  _buildDrawerItem(Icons.help_outline, 'Aide & Support', null),
                  const Divider(height: 32),
                  const SizedBox(height: 100),
                  ListTile(
                    leading: const Icon(Icons.logout, color: Color(0xFFE53935)),
                    title: const Text(
                      'Déconnexion',
                      style: TextStyle(color: kSenelecPink),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _showLogoutDialog(context);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero Section
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [kSenelecBlue, kSenelecViolet],
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Bienvenue chez SENELEC',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Votre partenaire énergétique de confiance',
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                      const SizedBox(height: 24),
                      Card(
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: kSenelecBlue.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(24),
                                    ),
                                    child: Icon(
                                      Icons.account_circle,
                                      size: 32,
                                      color: kSenelecBlue,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Bakar SECK',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.check_circle,
                                            size: 16,
                                            color: kSenelecBlue,
                                          ),
                                          SizedBox(width: 4),
                                          Text(
                                            'Abonnement Actif',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: kSenelecBlue,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Services Section
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Nos Services',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Service Cards Grid
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.0,
                    children: [
                      _buildServiceCard(
                        Icons.add_box_outlined,
                        'Nouvel\nAbonnement',
                        kSenelecBlue,
                        'Demandez votre\nraccordement',
                      ),
                      _buildServiceCard(
                        Icons.report_problem_outlined,
                        'Réclamation',
                        kSenelecPink,
                        'Signalez un\nproblème',
                      ),
                      _buildServiceCard(
                        Icons.track_changes,
                        'Suivi\nRequêtes',
                        kSenelecViolet,
                        'Suivez vos\ndemandes',
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Quick Actions
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Actions Rapides',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2C3E50),
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildQuickAction(
                            Icons.edit_outlined,
                            'Mettre à jour mes informations',
                            'Modifiez vos données personnelles',
                            kSenelecViolet,
                          ),
                          const Divider(height: 24, color: kSenelecYellow),
                          _buildQuickAction(
                            Icons.support_agent,
                            'Contacter le support',
                            'Besoin d\'aide ? Contactez-nous',
                            kSenelecPink,
                          ),
                          const Divider(height: 24, color: kSenelecOrange),
                          _buildQuickAction(
                            Icons.info_outline,
                            'Infos Senelec',
                            'Découvrez nos nouveautés',
                            kSenelecYellow,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, VoidCallback? onTap) {
    Color color;
    switch (title) {
      case 'Tableau de bord':
        color = kSenelecBlue;
        break;
      case 'Mes factures':
        color = kSenelecViolet;
        break;
      case 'Consommation':
        color = kSenelecOrange;
        break;
      case 'Historique':
        color = kSenelecYellow;
        break;
      case 'Paramètres':
        color = kSenelecPink;
        break;
      case 'Aide & Support':
        color = kSenelecViolet;
        break;
      default:
        color = kSenelecBlue;
    }
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title),
      onTap: onTap,
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
    );
  }

  Widget _buildServiceCard(
    IconData icon,
    String title,
    Color color,
    String subtitle,
  ) {
    return Card(
      child: InkWell(
        onTap: () {
          // Ajoutez la logique de navigation ici
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 32, color: color),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 11, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAction(
    IconData icon,
    String title,
    String subtitle,
    Color color,
  ) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: Colors.grey, fontSize: 14),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {
        // Ajoutez la logique ici
      },
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Row(
              children: [
                Icon(Icons.logout, color: Color(0xFFE53935)),
                SizedBox(width: 8),
                Text('Déconnexion'),
              ],
            ),
            content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Annuler'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  // Logique de déconnexion
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: kSenelecPink,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Déconnexion'),
              ),
            ],
          ),
    );
  }
}
