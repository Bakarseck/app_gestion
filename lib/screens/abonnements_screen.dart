import 'package:flutter/material.dart';
import 'package:app_gestion/theme/colors.dart';
import 'package:app_gestion/repositories/demandes_repository.dart';
import 'package:app_gestion/models/demande.dart';
import 'package:app_gestion/services/api_service.dart';

class AbonnementsScreen extends StatefulWidget {
  const AbonnementsScreen({super.key});

  @override
  State<AbonnementsScreen> createState() => _AbonnementsScreenState();
}

class _AbonnementsScreenState extends State<AbonnementsScreen> {
  bool _isLoading = false;
  List<Demande> _demandes = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDemandes();
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
          _isLoading = false;
        });
      } else {
        setState(() {
          _error =
              result['message'] ??
              'Erreur lors de la récupération des abonnements';
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
        title: const Text('Mes Abonnements'),
        backgroundColor: kSenelecBlue,
        foregroundColor: Colors.white,
        elevation: 0,
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
              : _demandes.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.subscriptions_outlined,
                      size: 80,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Aucun abonnement',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Vous n\'avez pas encore d\'abonnements',
                      style: TextStyle(color: Colors.grey.shade500),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () async {
                        final result = await Navigator.pushNamed(
                          context,
                          '/nouvel-abonnement',
                        );
                        if (result == true) {
                          _loadDemandes();
                        }
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Nouvel Abonnement'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kSenelecBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              )
              : RefreshIndicator(
                onRefresh: _loadDemandes,
                color: kSenelecBlue,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _demandes.length,
                  itemBuilder: (context, index) {
                    final demande = _demandes[index];
                    final statusColor = _getStatusColor(demande.statut);
                    final statusIcon = _getStatusIcon(demande.statut);

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
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
                                    borderRadius: BorderRadius.circular(8),
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
                                    borderRadius: BorderRadius.circular(8),
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
                            _buildInfoRow('Description', demande.description),
                            if (demande.piecesJointes != null)
                              _buildInfoRow(
                                'Pièces jointes',
                                demande.piecesJointes!,
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
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
        label: const Text('Nouvel Abonnement'),
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
