import 'package:flutter/material.dart';
import 'package:app_gestion/theme/colors.dart';
import 'package:app_gestion/services/auth_service.dart';
import 'package:app_gestion/models/demande.dart';
import 'package:app_gestion/repositories/demandes_repository.dart';
import 'package:app_gestion/repositories/reclamations_repository.dart';
import 'package:app_gestion/services/api_service.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  bool _isApiConnected = true;

  // Données des demandes et réclamations
  List<Demande> _demandes = [];
  List<Demande> _reclamations = [];

  // Statistiques
  Map<String, int> _stats = {
    'nouvelles': 0,
    'en_cours': 0,
    'assignees': 0,
    'resolues': 0,
  };

  // Techniciens par région
  final Map<String, List<String>> _techniciens = {
    'Dakar': ['Tech_Dakar_1', 'Tech_Dakar_2', 'Tech_Dakar_3'],
    'Thiès': ['Tech_Thies_1', 'Tech_Thies_2'],
    'Saint-Louis': ['Tech_SaintLouis_1', 'Tech_SaintLouis_2'],
    'Kaolack': ['Tech_Kaolack_1'],
    'Ziguinchor': ['Tech_Ziguinchor_1'],
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
      // Charger les demandes d'abonnement
      final demandesResult = await DemandesRepository.getUserDemandes();
      print('Admin - Demandes result: $demandesResult');

      if (demandesResult['success'] == true) {
        final demandesData = demandesResult['data'] as List;
        _demandes =
            demandesData.map((item) {
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

      // Charger les réclamations
      final reclamationsResult = await ReclamationsRepository.getUserClaims();
      print('Admin - Réclamations result: $reclamationsResult');

      if (reclamationsResult['success'] == true) {
        final reclamationsData = reclamationsResult['data'] as List;
        _reclamations =
            reclamationsData.map((item) {
              try {
                return Demande.fromJson(item);
              } catch (e) {
                print('Erreur conversion réclamation: $e');
                print('Données: $item');
                // Retourner une demande par défaut en cas d'erreur
                return Demande(
                  id: item['id'] ?? 0,
                  clientId: item['client_id'] ?? 0,
                  type: item['type'] ?? 'reclamation',
                  dateSoumission:
                      DateTime.tryParse(item['dateSoumission'] ?? '') ??
                      DateTime.now(),
                  statut: item['statut'] ?? 'ouvert',
                  description: item['description'] ?? '',
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

      _updateStats();
      setState(() {
        _isApiConnected = true;
        _isLoading = false;
      });
    } catch (e) {
      print('Erreur _loadData: $e');
      setState(() {
        _isApiConnected = false;
        _isLoading = false;
      });
      _loadMockData();
    }
  }

  void _loadMockData() {
    // Données de test pour démonstration
    _demandes = [
      Demande(
        id: 1,
        clientId: 1,
        type: 'abonnement',
        dateSoumission: DateTime.now().subtract(const Duration(hours: 2)),
        statut: 'ouvert',
        description:
            'Demande d\'installation électrique pour nouvelle construction',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      Demande(
        id: 2,
        clientId: 2,
        type: 'abonnement',
        dateSoumission: DateTime.now().subtract(const Duration(days: 1)),
        statut: 'validé',
        description: 'Demande d\'extension pour commerce',
        technicienId: 1,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];

    _reclamations = [
      Demande(
        id: 3,
        clientId: 3,
        type: 'reclamation',
        dateSoumission: DateTime.now().subtract(const Duration(hours: 1)),
        statut: 'en_cours',
        description: 'Coupure de courant depuis 3 heures',
        technicienId: 2,
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      Demande(
        id: 4,
        clientId: 4,
        type: 'reclamation',
        dateSoumission: DateTime.now().subtract(const Duration(days: 2)),
        statut: 'ouvert',
        description: 'Facture incorrecte pour le mois de juin',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        updatedAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      Demande(
        id: 5,
        clientId: 5,
        type: 'reclamation',
        dateSoumission: DateTime.now().subtract(const Duration(days: 3)),
        statut: 'bloque',
        description: 'Problème de compteur électrique',
        technicienId: 1,
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        updatedAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      Demande(
        id: 6,
        clientId: 6,
        type: 'reclamation',
        dateSoumission: DateTime.now().subtract(const Duration(days: 5)),
        statut: 'ferme',
        description: 'Demande de changement de puissance résolue',
        technicienId: 2,
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        updatedAt: DateTime.now().subtract(const Duration(days: 4)),
      ),
    ];

    _updateStats();
  }

  void _updateStats() {
    final allDemandes = [..._demandes, ..._reclamations];
    _stats = {
      'nouvelles': allDemandes.where((d) => d.statut == 'ouvert').length,
      'en_cours': allDemandes.where((d) => d.statut == 'en_cours').length,
      'assignees': allDemandes.where((d) => d.technicienId != null).length,
      'resolues': allDemandes.where((d) => d.statut == 'ferme').length,
    };
  }

  Future<void> _assignTechnician(Demande demande) async {
    try {
      // Récupérer la liste des techniciens disponibles
      final techniciens = await ApiService.getTechniciens();

      print('Techniciens récupérés dans le dashboard: ${techniciens.length}');

      // Si aucun technicien n'est trouvé, utiliser des données de test
      List<Map<String, dynamic>> techniciensDisponibles = techniciens;
      if (techniciens.isEmpty) {
        print('Aucun technicien trouvé, utilisation des données de test');
        techniciensDisponibles = [
          {
            'id': 1,
            'nom': 'Diallo',
            'prenom': 'Mamadou',
            'specialisation': 'Électricité générale',
            'statut': 'disponible',
            'numeroTelephone': '783456789',
          },
          {
            'id': 2,
            'nom': 'Sy',
            'prenom': 'Fatou',
            'specialisation': 'Installation électrique',
            'statut': 'disponible',
            'numeroTelephone': '784567890',
          },
          {
            'id': 3,
            'nom': 'Ba',
            'prenom': 'Ousmane',
            'specialisation': 'Maintenance réseau',
            'statut': 'disponible',
            'numeroTelephone': '785678901',
          },
        ];
      }

      if (techniciensDisponibles.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Aucun technicien disponible'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      String? selectedTechnicienId;
      String? selectedStatus;

      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('Assigner un technicien'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Demande: ${demande.typeDisplay}'),
                  Text('Client ID: ${demande.clientId}'),
                  const SizedBox(height: 16),
                  Flexible(
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Sélectionner un technicien',
                        border: OutlineInputBorder(),
                      ),
                      value: selectedTechnicienId,
                      items:
                          techniciensDisponibles
                              .where((tech) => tech['statut'] == 'disponible')
                              .map(
                                (tech) => DropdownMenuItem(
                                  value: tech['id'].toString(),
                                  child: Text(
                                    '${tech['prenom']} ${tech['nom']}',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              )
                              .toList(),
                      onChanged: (value) {
                        selectedTechnicienId = value;
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  Flexible(
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Statut après assignation',
                        border: OutlineInputBorder(),
                      ),
                      value: selectedStatus,
                      items: [
                        DropdownMenuItem(
                          value: 'en_cours',
                          child: Row(
                            children: [
                              Icon(
                                Icons.play_arrow,
                                color: Colors.orange,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              const Text('En cours'),
                            ],
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'bloque',
                          child: Row(
                            children: [
                              Icon(Icons.block, color: Colors.red, size: 16),
                              const SizedBox(width: 8),
                              const Text('Bloqué'),
                            ],
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'ferme',
                          child: Row(
                            children: [
                              Icon(
                                Icons.done_all,
                                color: Colors.green,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              const Text('Fermé'),
                            ],
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        selectedStatus = value;
                      },
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Annuler'),
                ),
                ElevatedButton(
                  onPressed: () {
                    print(
                      'Bouton Assigner - selectedTechnicienId: $selectedTechnicienId, selectedStatus: $selectedStatus',
                    );
                    if (selectedTechnicienId == null) {
                      print('Aucun technicien sélectionné');
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Veuillez sélectionner un technicien'),
                          backgroundColor: Colors.orange,
                        ),
                      );
                      return;
                    }

                    if (selectedStatus == null) {
                      print('Aucun statut sélectionné');
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Veuillez sélectionner un statut'),
                          backgroundColor: Colors.orange,
                        ),
                      );
                      return;
                    }

                    () async {
                      print('Bouton Assigner cliqué');
                      print('Demande ID: ${demande.id}');
                      print('Technicien ID sélectionné: $selectedTechnicienId');
                      print('Statut sélectionné: $selectedStatus');

                      try {
                        // Assigner le technicien
                        final assignResult = await ApiService.assignTechnicien(
                          demande.id.toString(),
                          selectedTechnicienId!,
                          type: demande.type, // Passer le type de demande
                        );

                        print('Résultat assignation: $assignResult');

                        if (assignResult['success']) {
                          // Mettre à jour le statut
                          final statusResult = await ApiService.updateStatus(
                            demande.id.toString(),
                            selectedStatus!,
                            type: demande.type, // Passer le type de demande
                          );

                          print('Résultat mise à jour statut: $statusResult');

                          if (statusResult['success']) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Technicien assigné et statut mis à jour avec succès',
                                ),
                                backgroundColor: Colors.green,
                              ),
                            );
                            _loadData(); // Recharger les données
                          } else {
                            print(
                              'Erreur dans la mise à jour du statut: ${statusResult['message']}',
                            );
                            throw Exception(statusResult['message']);
                          }
                        } else {
                          print(
                            'Erreur dans l\'assignation: ${assignResult['message']}',
                          );
                          throw Exception(assignResult['message']);
                        }
                      } catch (e) {
                        print('Erreur lors de l\'assignation: $e');
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Erreur: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }();
                  },
                  child: const Text('Assigner'),
                ),
              ],
            ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors du chargement des techniciens: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _updateStatus(Demande demande) async {
    String? selectedStatus;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Modifier le statut'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Demande: ${demande.typeDisplay}'),
                Text('Statut actuel: ${demande.statutDisplay}'),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Nouveau statut',
                    border: OutlineInputBorder(),
                  ),
                  value: selectedStatus,
                  items: [
                    DropdownMenuItem(
                      value: 'ouvert',
                      child: Row(
                        children: [
                          Icon(Icons.folder_open, color: Colors.blue, size: 16),
                          const SizedBox(width: 8),
                          const Text('Ouvert'),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'en_cours',
                      child: Row(
                        children: [
                          Icon(
                            Icons.play_arrow,
                            color: Colors.orange,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          const Text('En cours'),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'bloque',
                      child: Row(
                        children: [
                          Icon(Icons.block, color: Colors.red, size: 16),
                          const SizedBox(width: 8),
                          const Text('Bloqué'),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'ferme',
                      child: Row(
                        children: [
                          Icon(Icons.done_all, color: Colors.green, size: 16),
                          const SizedBox(width: 8),
                          const Text('Fermé'),
                        ],
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    selectedStatus = value;
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Annuler'),
              ),
              ElevatedButton(
                onPressed:
                    selectedStatus == null
                        ? null
                        : () async {
                          try {
                            final result = await ApiService.updateStatus(
                              demande.id.toString(),
                              selectedStatus!,
                              type: demande.type, // Passer le type de demande
                            );

                            if (result['success']) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(result['message']),
                                  backgroundColor: Colors.green,
                                ),
                              );
                              _loadData(); // Recharger les données
                            } else {
                              throw Exception(result['message']);
                            }
                          } catch (e) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Erreur: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                child: const Text('Modifier'),
              ),
            ],
          ),
    );
  }

  void _addComment(Demande demande) {
    final commentController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Ajouter un commentaire'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Demande: ${demande.typeDisplay}'),
                Text('Client ID: ${demande.clientId}'),
                const SizedBox(height: 16),
                TextField(
                  controller: commentController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Commentaire',
                    hintText: 'Entrez votre commentaire...',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Annuler'),
              ),
              ElevatedButton(
                onPressed:
                    commentController.text.trim().isEmpty
                        ? null
                        : () async {
                          try {
                            final result = await ApiService.addComment(
                              demande.id.toString(),
                              commentController.text.trim(),
                              type: demande.type, // Passer le type de demande
                            );

                            if (result['success']) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(result['message']),
                                  backgroundColor: Colors.green,
                                ),
                              );
                              _loadData(); // Recharger les données
                            } else {
                              throw Exception(result['message']);
                            }
                          } catch (e) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Erreur: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                child: const Text('Ajouter'),
              ),
            ],
          ),
    );
  }

  String _getStatusDisplay(String status) {
    switch (status) {
      case 'ouvert':
        return 'Ouvert';
      case 'en_cours':
        return 'En cours';
      case 'resolu':
        return 'Résolu';
      case 'annule':
        return 'Annulé';
      default:
        return status;
    }
  }

  Widget _buildStatsCard() {
    return Card(
      elevation: 6,
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.analytics, color: kSenelecBlue, size: 20),
                const SizedBox(width: 6),
                Expanded(
                  child: const Text(
                    'Statistiques en temps réel',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: kSenelecBlue,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            LayoutBuilder(
              builder: (context, constraints) {
                return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  alignment: WrapAlignment.spaceEvenly,
                  children: [
                    _buildStatItem(
                      'Nouvelles',
                      _stats['nouvelles']!,
                      Colors.blue,
                    ),
                    _buildStatItem(
                      'En cours',
                      _stats['en_cours']!,
                      Colors.orange,
                    ),
                    _buildStatItem(
                      'Assignées',
                      _stats['assignees']!,
                      Colors.purple,
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
      width: 120,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildUrgentDemandes() {
    final urgentDemandes =
        [..._demandes, ..._reclamations]
            .where((d) => d.statut == 'ouvert' && d.type == 'reclamation')
            .toList();

    if (urgentDemandes.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('Aucune demande urgente'),
        ),
      );
    }

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.priority_high, color: Colors.red, size: 18),
                const SizedBox(width: 4),
                Expanded(
                  child: const Text(
                    'Demandes urgentes',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...urgentDemandes
                .take(3)
                .map((demande) => _buildDemandeTile(demande)),
          ],
        ),
      ),
    );
  }

  Widget _buildDemandeTile(Demande demande) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color:
            demande.statut == 'ouvert'
                ? Colors.red.withOpacity(0.1)
                : Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: demande.statut == 'ouvert' ? Colors.red : Colors.grey,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  demande.typeDisplay,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(demande.statut),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  demande.statutDisplay.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            demande.description,
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
                  'Client ID: ${demande.clientId}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Spacer(),
              Text(
                _formatDate(demande.dateSoumission),
                style: TextStyle(fontSize: 10, color: Colors.grey[500]),
              ),
            ],
          ),
          if (demande.technicienId != null) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.build, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'Tech ID: ${demande.technicienId}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'ouvert':
        return Colors.blue;
      case 'en_cours':
        return Colors.orange;
      case 'bloque':
        return Colors.red;
      case 'ferme':
        return Colors.green;
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

  Widget _buildDemandesList(List<Demande> demandes, String title) {
    return Card(
      elevation: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: kSenelecBlue,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Flexible(
                  child: Text(
                    '${demandes.length} demandes',
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          if (demandes.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Aucune demande'),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: demandes.length,
              itemBuilder: (context, index) {
                final demande = demandes[index];
                return ListTile(
                  title: Text(
                    demande.typeDisplay,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        demande.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
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
                              color: _getStatusColor(demande.statut),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              demande.statutDisplay,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                              ),
                            ),
                          ),
                          if (demande.statut == 'ouvert')
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'NOUVEAU',
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
                            value: 'assign',
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.person_add, size: 18),
                                SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    'Assigner technicien',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'status',
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.update, size: 18),
                                SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    'Modifier statut',
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
                                Icon(Icons.comment, size: 18),
                                SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    'Ajouter commentaire',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                    onSelected: (value) {
                      switch (value) {
                        case 'assign':
                          _assignTechnician(demande);
                          break;
                        case 'status':
                          _updateStatus(demande);
                          break;
                        case 'comment':
                          _addComment(demande);
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
            const Icon(Icons.electric_bolt, size: 20),
            const SizedBox(width: 6),
            const Text('SENELEC', style: TextStyle(fontSize: 16)),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'ADMIN',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 9,
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
                const SnackBar(
                  content: Text('Aide - Dashboard Administrateur'),
                ),
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
                        icon: Icon(Icons.power, size: 16),
                        text: 'Abonnements',
                      ),
                      Tab(
                        icon: Icon(Icons.report_problem, size: 16),
                        text: 'Réclamations',
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
                              _buildUrgentDemandes(),
                            ],
                          ),
                        ),
                        // Abonnements Tab
                        SingleChildScrollView(
                          padding: const EdgeInsets.all(16),
                          child: _buildDemandesList(
                            _demandes
                                .where((d) => d.type == 'abonnement')
                                .toList(),
                            'Demandes d\'abonnement',
                          ),
                        ),
                        // Réclamations Tab
                        SingleChildScrollView(
                          padding: const EdgeInsets.all(16),
                          child: _buildDemandesList(
                            _reclamations
                                .where((d) => d.type == 'reclamation')
                                .toList(),
                            'Réclamations',
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
