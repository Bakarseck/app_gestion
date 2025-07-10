import 'package:flutter/material.dart';
import 'package:app_gestion/theme/colors.dart';
import 'package:app_gestion/services/auth_service.dart';
import 'package:app_gestion/repositories/notifications_repository.dart';
import 'package:app_gestion/services/api_service.dart';
import 'package:app_gestion/models/demande.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback onLogout;

  const HomeScreen({super.key, required this.onLogout});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic>? _userProfile;
  bool _isLoading = true;
  String? _error;
  int _notificationCount = 0;
  List<Demande> _demandesAcceptees = [];

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    _loadNotificationCount();
    _loadDemandesAcceptees();
  }

  Future<void> _loadUserProfile() async {
    try {
      final result = await AuthService.getProfile();
      if (mounted) {
        setState(() {
          if (result['success'] == true) {
            _userProfile = result['user'];
            _error = null;
          } else {
            _error = result['message'];
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Erreur lors du chargement du profil: $e';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadNotificationCount() async {
    try {
      final notifications = await NotificationsRepository.getNotifications();
      if (mounted) {
        setState(() {
          _notificationCount = NotificationsRepository.getUnreadCount(
            notifications,
          );
        });
      }
    } catch (e) {
      // En cas d'erreur, on garde le compteur à 0
      print('Erreur lors du chargement des notifications: $e');
    }
  }

  Future<void> _loadDemandesAcceptees() async {
    try {
      final result = await ApiService.getDemandes();
      if (result['success'] == true) {
        final List<dynamic> demandesData = result['demandes'] ?? [];
        final allDemandes =
            demandesData.map((json) => Demande.fromJson(json)).toList();

        // Filtrer seulement les demandes avec des statuts acceptés
        final demandesAcceptees =
            allDemandes.where((demande) {
              final statut = demande.statut.toLowerCase();
              return statut == 'validé' ||
                  statut == 'accepté' ||
                  statut == 'actif';
            }).toList();

        if (mounted) {
          setState(() {
            _demandesAcceptees = demandesAcceptees;
          });
        }
      }
    } catch (e) {
      print('Erreur lors du chargement des demandes acceptées: $e');
    }
  }

  String _getFullName() {
    if (_userProfile == null) return 'Utilisateur';
    final prenom = _userProfile!['prenom'] ?? '';
    final nom = _userProfile!['nom'] ?? '';
    return '$prenom $nom'.trim().isEmpty
        ? 'Utilisateur'
        : '$prenom $nom'.trim();
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'validé':
      case 'accepté':
      case 'actif':
        return Colors.green;
      case 'ouvert':
        return Colors.orange;
      case 'rejeté':
        return Colors.red;
      case 'en cours':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'validé':
      case 'accepté':
      case 'actif':
        return Icons.check_circle;
      case 'ouvert':
        return Icons.pending;
      case 'rejeté':
        return Icons.cancel;
      case 'en cours':
        return Icons.engineering;
      default:
        return Icons.info;
    }
  }

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
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications),
                onPressed: () async {
                  final result = await Navigator.pushNamed(
                    context,
                    '/notifications',
                  );
                  // Rafraîchir le compteur de notifications après retour
                  if (result == true) {
                    _loadNotificationCount();
                  }
                },
              ),
              if (_notificationCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      _notificationCount > 99
                          ? '99+'
                          : _notificationCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Déconnexion'),
                    content: const Text(
                      'Êtes-vous sûr de vouloir vous déconnecter ?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Annuler'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          widget.onLogout();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Déconnexion'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
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
                      Text(
                        _isLoading ? 'Chargement...' : _getFullName(),
                        style: const TextStyle(
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
                  }),
                  _buildDrawerItem(Icons.subscriptions, 'Abonnements', () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/abonnements');
                  }),
                  _buildDrawerItem(Icons.list_alt, 'Toutes mes demandes', () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/toutes-demandes');
                  }),
                  _buildDrawerItem(Icons.report_problem, 'Réclamations', () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/reclamations');
                  }),
                  const Divider(height: 32),
                  _buildDrawerItem(Icons.settings, 'Paramètres', () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/parametres');
                  }),
                  _buildDrawerItem(Icons.help_outline, 'Aide & Support', () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/aide-support');
                  }),
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
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Déconnexion'),
                            content: const Text(
                              'Êtes-vous sûr de vouloir vous déconnecter ?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('Annuler'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  widget.onLogout();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text('Déconnexion'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      body:
          _isLoading
              ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(kSenelecBlue),
                ),
              )
              : _error != null
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Erreur de chargement',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey.shade500),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadUserProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kSenelecBlue,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Réessayer'),
                    ),
                  ],
                ),
              )
              : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // En-tête avec nom d'utilisateur
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: kSenelecBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: kSenelecBlue,
                            child: const Icon(
                              Icons.person,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Bienvenue, ${_getFullName()} !',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: kSenelecBlue,
                                  ),
                                ),
                                const Text(
                                  'Gérez vos abonnements et réclamations',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Section Abonnements
                    const Text(
                      'Mes Abonnements',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: kSenelecBlue,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Affichage des vraies demandes acceptées
                    if (_demandesAcceptees.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.subscriptions_outlined,
                              color: Colors.grey.shade400,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Aucun abonnement actif',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      ..._demandesAcceptees.map((demande) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildAbonnementCard(
                            'Demande #${demande.id}',
                            '${demande.typeDisplay} - ${demande.dateSoumission.day}/${demande.dateSoumission.month}/${demande.dateSoumission.year}',
                            demande.statutDisplay,
                            _getStatusIcon(demande.statut),
                            _getStatusColor(demande.statut),
                          ),
                        );
                      }).toList(),

                    const SizedBox(height: 24),

                    // Section Réclamations
                    const Text(
                      'Mes Réclamations',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: kSenelecBlue,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Réclamation en cours de validation
                    _buildReclamationCard(
                      'Réclamation #001',
                      'Coupure de courant',
                      'En cours de validation',
                      'Soumise le 25/06/2024',
                      Icons.hourglass_empty,
                      Colors.orange,
                    ),

                    const SizedBox(height: 12),

                    // Réclamation chez le technicien
                    _buildReclamationCard(
                      'Réclamation #002',
                      'Problème de compteur',
                      'Chez le technicien',
                      'Assignée le 26/06/2024',
                      Icons.engineering,
                      Colors.blue,
                    ),

                    const SizedBox(height: 12),

                    // Réclamation résolue
                    _buildReclamationCard(
                      'Réclamation #003',
                      'Facture incorrecte',
                      'Résolu',
                      'Résolu le 27/06/2024',
                      Icons.check_circle,
                      Colors.green,
                    ),

                    const SizedBox(height: 24),

                    // Boutons d'action
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                '/nouvel-abonnement',
                              );
                            },
                            icon: const Icon(Icons.add),
                            label: const Text('Nouvel Abonnement'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kSenelecBlue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                '/nouvelle-reclamation',
                              );
                            },
                            icon: const Icon(Icons.report_problem),
                            label: const Text('Nouvelle Réclamation'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kSenelecViolet,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
    );
  }

  Widget _buildAbonnementCard(
    String title,
    String subtitle,
    String status,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                status,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReclamationCard(
    String title,
    String description,
    String status,
    String date,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        description,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: color,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              date,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
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
}
