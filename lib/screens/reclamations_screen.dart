import 'package:flutter/material.dart';
import 'package:app_gestion/theme/colors.dart';
import 'package:app_gestion/models/reclamation.dart';
import 'package:app_gestion/services/api_service.dart';

class ReclamationsScreen extends StatefulWidget {
  const ReclamationsScreen({super.key});

  @override
  State<ReclamationsScreen> createState() => _ReclamationsScreenState();
}

class _ReclamationsScreenState extends State<ReclamationsScreen> {
  bool _isLoading = false;
  List<Reclamation> _reclamations = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadReclamations();
  }

  Future<void> _loadReclamations() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await ApiService.getReclamations();
      if (result['success'] == true) {
        final List<dynamic> reclamationsData = result['reclamations'] ?? [];
        setState(() {
          _reclamations =
              reclamationsData
                  .map((json) => Reclamation.fromJson(json))
                  .toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _error =
              result['message'] ??
              'Erreur lors de la récupération des réclamations';
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
      case 'résolu':
        return Colors.green;
      case 'ouvert':
        return Colors.orange;
      case 'en cours de validation':
        return Colors.orange;
      case 'chez le technicien':
        return Colors.blue;
      case 'rejeté':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'résolu':
        return Icons.check_circle;
      case 'ouvert':
        return Icons.hourglass_empty;
      case 'en cours de validation':
        return Icons.hourglass_empty;
      case 'chez le technicien':
        return Icons.engineering;
      case 'rejeté':
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'haute':
        return Colors.red;
      case 'moyenne':
        return Colors.orange;
      case 'basse':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Mes Réclamations'),
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
                      onPressed: _loadReclamations,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kSenelecBlue,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Réessayer'),
                    ),
                  ],
                ),
              )
              : _reclamations.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.report_problem_outlined,
                      size: 80,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Aucune réclamation',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Vous n\'avez pas encore de réclamations',
                      style: TextStyle(color: Colors.grey.shade500),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () async {
                        final result = await Navigator.pushNamed(
                          context,
                          '/nouvelle-reclamation',
                        );
                        if (result == true) {
                          _loadReclamations();
                        }
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Nouvelle Réclamation'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kSenelecViolet,
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
                onRefresh: _loadReclamations,
                color: kSenelecBlue,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _reclamations.length,
                  itemBuilder: (context, index) {
                    final reclamation = _reclamations[index];
                    final statusColor = _getStatusColor(reclamation.statut);
                    final statusIcon = _getStatusIcon(reclamation.statut);
                    final priorityColor = _getPriorityColor(
                      reclamation.priorite,
                    );

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
                                        'Réclamation #${reclamation.id}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      Text(
                                        reclamation.objet,
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
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
                                        reclamation.statutDisplay,
                                        style: TextStyle(
                                          color: statusColor,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: priorityColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        reclamation.priorite,
                                        style: TextStyle(
                                          color: priorityColor,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              reclamation.description,
                              style: const TextStyle(fontSize: 13),
                            ),
                            const SizedBox(height: 12),
                            _buildInfoRow('Catégorie', reclamation.categorie),
                            _buildInfoRow(
                              'Date de soumission',
                              '${reclamation.date.day}/${reclamation.date.month}/${reclamation.date.year}',
                            ),
                            if (reclamation.technicienId != null)
                              _buildInfoRow(
                                'Technicien assigné',
                                'Technicien #${reclamation.technicienId}',
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
            '/nouvelle-reclamation',
          );
          if (result == true) {
            _loadReclamations();
          }
        },
        backgroundColor: kSenelecViolet,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Nouvelle Réclamation'),
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
