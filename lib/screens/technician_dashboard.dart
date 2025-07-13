import 'package:flutter/material.dart';
import 'package:app_gestion/theme/colors.dart';
import 'package:app_gestion/services/auth_service.dart';
import 'package:app_gestion/models/demande.dart';
import 'package:app_gestion/repositories/demandes_repository.dart';
import 'package:app_gestion/repositories/reclamations_repository.dart';
import 'package:app_gestion/services/api_service.dart';

class TechnicianDashboard extends StatefulWidget {
  const TechnicianDashboard({super.key});

  @override
  State<TechnicianDashboard> createState() => _TechnicianDashboardState();
}

class _TechnicianDashboardState extends State<TechnicianDashboard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  bool _isApiConnected = true;

  // Données des tâches assignées
  List<Demande> _assignedTasks = [];
  String _technicianName = 'Technicien';

  // Statistiques
  Map<String, int> _stats = {'assignees': 0, 'en_cours': 0, 'resolues': 0};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Récupérer le nom du technicien connecté
      final userData = await AuthService.getUserData();
      if (userData != null) {
        _technicianName = userData['nom'] ?? 'Technicien';
      }

      // Charger les tâches assignées depuis l'API
      final demandesResult = await DemandesRepository.getUserDemandes();
      print('Technicien - Demandes result: $demandesResult');

      if (demandesResult['success'] == true) {
        final demandesData = demandesResult['data'] as List;
        _assignedTasks = demandesData
            .where((item) => item['technicien_id'] != null) // Filtrer les tâches assignées
            .map((item) {
              try {
                return Demande.fromJson(item);
              } catch (e) {
                print('Erreur conversion demande: $e');
                print('Données: $item');
                // Retourner une demande par défaut en cas d'erreur
                return Demande(
                  id: item['id'] ?? 0,
                  clientId: item['client_id'] ?? 0,
                  type: item['type'] ?? 'abonnement',
                  dateSoumission:
                      DateTime.tryParse(item['dateSoumission'] ?? '') ??
                      DateTime.now(),
                  statut: item['statut'] ?? 'ouvert',
                  description: item['description'] ?? '',
                  technicienId: item['technicien_id'],
                  createdAt:
                      DateTime.tryParse(item['created_at'] ?? '') ??
                      DateTime.now(),
                  updatedAt:
                      DateTime.tryParse(item['updated_at'] ?? '') ??
                      DateTime.now(),
                );
              }
            }).toList();
      }

      // Charger les réclamations assignées
      final reclamationsResult = await ReclamationsRepository.getUserClaims();
      print('Technicien - Réclamations result: $reclamationsResult');

      if (reclamationsResult['success'] == true) {
        final reclamationsData = reclamationsResult['data'] as List;
        final reclamationsAssignees = reclamationsData
            .where((item) => item['technicien_id'] != null) // Filtrer les réclamations assignées
            .map((item) {
              try {
                return Demande.fromJson(item);
              } catch (e) {
                print('Erreur conversion réclamation: $e');
                print('Données: $item');
                // Retourner une demande par défaut en cas d'erreur
                return Demande(
                  id: item['id'] ?? 0,
                  clientId: item['client_id'] ?? 0,
                  type: 'reclamation',
                  dateSoumission:
                      DateTime.tryParse(item['dateSoumission'] ?? '') ??
                      DateTime.now(),
                  statut: item['statut'] ?? 'ouvert',
                  description: item['description'] ?? '',
                  technicienId: item['technicien_id'],
                  createdAt:
                      DateTime.tryParse(item['created_at'] ?? '') ??
                      DateTime.now(),
                  updatedAt:
                      DateTime.tryParse(item['updated_at'] ?? '') ??
                      DateTime.now(),
                );
              }
            }).toList();
        
        // Ajouter les réclamations assignées à la liste des tâches
        _assignedTasks.addAll(reclamationsAssignees);
      }

      _updateStats();
      setState(() {
        _isApiConnected = true;
        _isLoading = false;
      });
    } catch (e) {
      print('Erreur _loadData technicien: $e');
      setState(() {
        _isApiConnected = false;
        _isLoading = false;
      });
      _loadMockData();
    }
  }

  void _loadMockData() {
    // Données de test pour démonstration
    _assignedTasks = [
      Demande(
        id: 1,
        clientId: 1,
        type: 'abonnement',
        dateSoumission: DateTime.now().subtract(const Duration(hours: 2)),
        statut: 'validé',
        description: 'Installation complète pour nouvelle construction',
        technicienId: 1,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      Demande(
        id: 2,
        clientId: 2,
        type: 'reclamation',
        dateSoumission: DateTime.now().subtract(const Duration(hours: 1)),
        statut: 'en cours',
        description: 'Coupure de courant depuis 3 heures',
        technicienId: 1,
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      Demande(
        id: 3,
        clientId: 3,
        type: 'abonnement',
        dateSoumission: DateTime.now().subtract(const Duration(days: 1)),
        statut: 'validé',
        description: 'Demande d\'extension pour commerce',
        technicienId: 1,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      Demande(
        id: 4,
        clientId: 4,
        type: 'reclamation',
        dateSoumission: DateTime.now().subtract(const Duration(days: 2)),
        statut: 'ouvert',
        description: 'Facture incorrecte pour le mois de juin',
        technicienId: 1,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        updatedAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      Demande(
        id: 5,
        clientId: 5,
        type: 'abonnement',
        dateSoumission: DateTime.now().subtract(const Duration(hours: 3)),
        statut: 'en cours',
        description: 'Nouvel abonnement pour résidence',
        technicienId: 1,
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 3)),
      ),
    ];

    _updateStats();
  }

  void _updateStats() {
    _stats = {
      'assignees': _assignedTasks.where((t) => t.technicienId != null).length,
      'en_cours': _assignedTasks.where((t) => t.statut == 'en cours').length,
      'resolues': _assignedTasks.where((t) => t.statut == 'validé').length,
    };
  }

  Future<void> _updateTaskStatus(Demande task) async {
    final String? newStatus = await showDialog<String>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Mettre à jour le statut'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: const Text('En cours'),
                  leading: const Icon(Icons.play_arrow, color: Colors.orange),
                  onTap: () => Navigator.of(context).pop('en cours'),
                ),
                ListTile(
                  title: const Text('Validé'),
                  leading: const Icon(Icons.check_circle, color: Colors.green),
                  onTap: () => Navigator.of(context).pop('validé'),
                ),
                ListTile(
                  title: const Text('Rejeté'),
                  leading: const Icon(Icons.cancel, color: Colors.red),
                  onTap: () => Navigator.of(context).pop('rejeté'),
                ),
              ],
            ),
          ),
    );

    if (newStatus != null) {
      try {
        print(
          'Tentative de mise à jour du statut: $newStatus pour la tâche: ${task.id}',
        );
        final result = await ApiService.updateStatus(
          task.id.toString(),
          newStatus,
        );

        print('Résultat mise à jour statut: $result');

        if (result['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                result['message'] ?? 'Statut mis à jour avec succès',
              ),
              backgroundColor: Colors.green,
            ),
          );
          // Recharger les données pour afficher les changements
          _loadData();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                result['message'] ?? 'Erreur lors de la mise à jour',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        print('Erreur lors de la mise à jour du statut: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _addTaskComment(Demande task) async {
    final TextEditingController commentController = TextEditingController();

    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Ajouter un rapport'),
            content: TextField(
              controller: commentController,
              decoration: const InputDecoration(
                labelText: 'Rapport d\'intervention',
                hintText: 'Décrivez votre intervention...',
              ),
              maxLines: 4,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Annuler'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (commentController.text.isNotEmpty) {
                    Navigator.of(context).pop();

                    try {
                      print(
                        'Tentative d\'ajout de commentaire pour la tâche: ${task.id}',
                      );
                      final result = await ApiService.addComment(
                        task.id.toString(),
                        commentController.text.trim(),
                      );

                      print('Résultat ajout commentaire: $result');

                      if (result['success']) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              result['message'] ?? 'Rapport ajouté avec succès',
                            ),
                            backgroundColor: Colors.green,
                          ),
                        );
                        // Recharger les données pour afficher les changements
                        _loadData();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              result['message'] ??
                                  'Erreur lors de l\'ajout du rapport',
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    } catch (e) {
                      print('Erreur lors de l\'ajout du commentaire: $e');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Erreur: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                child: const Text('Ajouter'),
              ),
            ],
          ),
    );
  }

  Widget _buildStatsCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.build, color: kSenelecBlue, size: 18),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Dashboard - $_technicianName',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: kSenelecBlue,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                return Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.spaceEvenly,
                  children: [
                    _buildStatItem(
                      'Assignées',
                      _stats['assignees']!,
                      Colors.blue,
                    ),
                    _buildStatItem(
                      'En cours',
                      _stats['en_cours']!,
                      Colors.orange,
                    ),
                    _buildStatItem(
                      'Résolues',
                      _stats['resolues']!,
                      Colors.green,
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, int count, Color color) {
    return Container(
      constraints: const BoxConstraints(minWidth: 80, maxWidth: 100),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 9, color: color),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildTaskTile(Demande task) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color:
            task.statut == 'en cours'
                ? Colors.orange.withOpacity(0.1)
                : Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: task.statut == 'en cours' ? Colors.orange : Colors.grey,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  task.typeDisplay,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(task.statut),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  task.statutDisplay.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            task.description,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.person, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  'Client ID: ${task.clientId}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                _formatDate(task.dateSoumission),
                style: TextStyle(fontSize: 10, color: Colors.grey[500]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'ouvert':
        return Colors.blue;
      case 'validé':
        return Colors.green;
      case 'en cours':
        return Colors.orange;
      case 'rejeté':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}j';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else {
      return '${difference.inMinutes}min';
    }
  }

  Widget _buildTasksList(
    List<Demande> tasks,
    String title, {
    IconData? icon,
    Color? color,
  }) {
    return Card(
      elevation: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                if (icon != null) Icon(icon, size: 16, color: color),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: kSenelecBlue,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Flexible(
                  child: Text(
                    '${tasks.length} tâches',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          if (tasks.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Aucune tâche assignée'),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                return ListTile(
                  title: Text(task.typeDisplay),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(task.description),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusColor(task.statut),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              task.statutDisplay,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                              ),
                            ),
                          ),
                          if (task.statut == 'en cours')
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.orange,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'EN COURS',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                  trailing: PopupMenuButton(
                    itemBuilder:
                        (context) => [
                          const PopupMenuItem(
                            value: 'status',
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.update, size: 16),
                                SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    'Mettre à jour',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'comment',
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.comment, size: 16),
                                SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    'Ajouter rapport',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                    onSelected: (value) {
                      switch (value) {
                        case 'status':
                          _updateTaskStatus(task);
                          break;
                        case 'comment':
                          _addTaskComment(task);
                          break;
                      }
                    },
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.electric_bolt, size: 18),
            const SizedBox(width: 4),
            const Text('SENELEC', style: TextStyle(fontSize: 14)),
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'TECH',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, size: 18),
            onPressed: _loadData,
            tooltip: 'Actualiser',
          ),
          IconButton(
            icon: const Icon(Icons.help, size: 18),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Aide - Dashboard Technicien')),
              );
            },
            tooltip: 'Aide',
          ),
          IconButton(
            icon: const Icon(Icons.logout, size: 18),
            onPressed: () async {
              await AuthService.logout();
              if (mounted) {
                Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil('/', (route) => false);
              }
            },
            tooltip: 'Déconnexion',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: Container(
            height: 4,
            color: _isApiConnected ? Colors.green : Colors.red,
          ),
        ),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  TabBar(
                    controller: _tabController,
                    labelColor: kSenelecBlue,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: kSenelecBlue,
                    isScrollable: true,
                    labelPadding: const EdgeInsets.symmetric(horizontal: 8),
                    tabs: const [
                      Tab(
                        icon: Icon(Icons.dashboard, size: 16),
                        text: 'Dashboard',
                      ),
                      Tab(
                        icon: Icon(Icons.assignment, size: 16),
                        text: 'Mes Tâches',
                      ),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        // Dashboard Tab
                        SingleChildScrollView(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              _buildStatsCard(),
                              const SizedBox(height: 16),
                              Card(
                                elevation: 4,
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.priority_high,
                                            color: Colors.orange,
                                            size: 18,
                                          ),
                                          const SizedBox(width: 6),
                                          const Text(
                                            'Tâches en cours',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.orange,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      // Abonnements en cours
                                      if (_assignedTasks
                                          .where(
                                            (t) =>
                                                t.statut == 'en cours' &&
                                                t.type == 'abonnement',
                                          )
                                          .isNotEmpty) ...[
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.power,
                                              size: 14,
                                              color: Colors.blue,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              'Abonnements',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.blue,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        ..._assignedTasks
                                            .where(
                                              (t) =>
                                                  t.statut == 'en cours' &&
                                                  t.type == 'abonnement',
                                            )
                                            .take(2)
                                            .map(
                                              (task) => _buildTaskTile(task),
                                            ),
                                        const SizedBox(height: 8),
                                      ],
                                      // Réclamations en cours
                                      if (_assignedTasks
                                          .where(
                                            (t) =>
                                                t.statut == 'en cours' &&
                                                t.type == 'reclamation',
                                          )
                                          .isNotEmpty) ...[
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.report_problem,
                                              size: 14,
                                              color: Colors.red,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              'Réclamations',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.red,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        ..._assignedTasks
                                            .where(
                                              (t) =>
                                                  t.statut == 'en cours' &&
                                                  t.type == 'reclamation',
                                            )
                                            .take(2)
                                            .map(
                                              (task) => _buildTaskTile(task),
                                            ),
                                      ],
                                      if (_assignedTasks
                                          .where((t) => t.statut == 'en cours')
                                          .isEmpty)
                                        const Text('Aucune tâche en cours'),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Mes Tâches Tab
                        SingleChildScrollView(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              // Section Abonnements
                              _buildTasksList(
                                _assignedTasks
                                    .where((t) => t.type == 'abonnement')
                                    .toList(),
                                'Abonnements',
                                icon: Icons.power,
                                color: Colors.blue,
                              ),
                              const SizedBox(height: 16),
                              // Section Réclamations
                              _buildTasksList(
                                _assignedTasks
                                    .where((t) => t.type == 'reclamation')
                                    .toList(),
                                'Réclamations',
                                icon: Icons.report_problem,
                                color: Colors.red,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
    );
  }
}
