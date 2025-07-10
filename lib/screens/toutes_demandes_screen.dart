import 'package:flutter/material.dart';
import 'package:app_gestion/theme/colors.dart';
import 'package:app_gestion/services/api_service.dart';
import 'package:app_gestion/models/demande.dart';

class ToutesDemandesScreen extends StatefulWidget {
  const ToutesDemandesScreen({super.key});

  @override
  State<ToutesDemandesScreen> createState() => _ToutesDemandesScreenState();
}

class _ToutesDemandesScreenState extends State<ToutesDemandesScreen> {
  bool _isLoading = false;
  List<Demande> _demandes = [];
  List<Demande> _demandesFiltrees = [];
  String? _error;
  String _selectedStatus = 'Tous';
  final TextEditingController _searchController = TextEditingController();

  final List<String> _statusOptions = [
    'Tous',
    'Ouvert',
    'En cours',
    'Validé',
    'Rejeté',
  ];

  @override
  void initState() {
    super.initState();
    _loadDemandes();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadDemandes() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await ApiService.getDemandes();

      if (result['success'] == true) {
        final List<dynamic> demandesData = result['demandes'] ?? [];

        setState(() {
          _demandes =
              demandesData.map((json) => Demande.fromJson(json)).toList();
          _demandesFiltrees = _demandes;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error =
              result['message'] ??
              'Erreur lors de la récupération des demandes';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _filterDemandes() {
    setState(() {
      _demandesFiltrees =
          _demandes.where((demande) {
            // Filtre par statut
            bool statusMatch =
                _selectedStatus == 'Tous' ||
                demande.statut.toLowerCase() == _selectedStatus.toLowerCase();

            // Filtre par recherche
            bool searchMatch =
                _searchController.text.isEmpty ||
                demande.description.toLowerCase().contains(
                  _searchController.text.toLowerCase(),
                ) ||
                demande.typeDisplay.toLowerCase().contains(
                  _searchController.text.toLowerCase(),
                );

            return statusMatch && searchMatch;
          }).toList();
    });
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'validé':
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Toutes mes demandes'),
        backgroundColor: kSenelecBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadDemandes),
        ],
      ),
      body: Column(
        children: [
          // Filtres et recherche
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Column(
              children: [
                // Barre de recherche
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Rechercher une demande...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon:
                        _searchController.text.isNotEmpty
                            ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                _filterDemandes();
                              },
                            )
                            : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onChanged: (value) => _filterDemandes(),
                ),
                const SizedBox(height: 12),
                // Filtre par statut
                DropdownButtonFormField<String>(
                  value: _selectedStatus,
                  decoration: InputDecoration(
                    labelText: 'Filtrer par statut',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  items:
                      _statusOptions.map((status) {
                        return DropdownMenuItem<String>(
                          value: status,
                          child: Text(status),
                        );
                      }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedStatus = value!;
                    });
                    _filterDemandes();
                  },
                ),
              ],
            ),
          ),
          // Liste des demandes
          Expanded(
            child:
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
                            onPressed: _loadDemandes,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kSenelecBlue,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Réessayer'),
                          ),
                        ],
                      ),
                    )
                    : _demandesFiltrees.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inbox_outlined,
                            size: 80,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Aucune demande trouvée',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Aucune demande ne correspond à vos critères',
                            style: TextStyle(color: Colors.grey.shade500),
                          ),
                        ],
                      ),
                    )
                    : RefreshIndicator(
                      onRefresh: _loadDemandes,
                      color: kSenelecBlue,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _demandesFiltrees.length,
                        itemBuilder: (context, index) {
                          final demande = _demandesFiltrees[index];
                          final statusColor = _getStatusColor(demande.statut);
                          final statusIcon = _getStatusIcon(demande.statut);

                          return Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: InkWell(
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  '/demande-details',
                                  arguments: demande,
                                );
                              },
                              borderRadius: BorderRadius.circular(12),
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
                                            color: statusColor.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Icon(
                                            statusIcon,
                                            color: statusColor,
                                            size: 20,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Demande #${demande.id}',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              Text(
                                                demande.typeDisplay,
                                                style: TextStyle(
                                                  color: Colors.grey.shade600,
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
                                            color: statusColor.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Text(
                                            demande.statutDisplay,
                                            style: TextStyle(
                                              color: statusColor,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    _buildInfoRow(
                                      'Date de soumission',
                                      '${demande.dateSoumission.day}/${demande.dateSoumission.month}/${demande.dateSoumission.year}',
                                    ),
                                    _buildInfoRow(
                                      'Description',
                                      demande.description,
                                    ),
                                    if (demande.piecesJointes != null)
                                      _buildInfoRow(
                                        'Pièces jointes',
                                        demande.piecesJointes!,
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.pushNamed(
            context,
            '/nouvel-abonnement',
          );
          if (result == true) {
            _loadDemandes();
          }
        },
        backgroundColor: kSenelecBlue,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Nouvelle demande'),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label :',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }
}
