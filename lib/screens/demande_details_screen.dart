import 'package:flutter/material.dart';
import 'package:app_gestion/theme/colors.dart';
import 'package:app_gestion/models/demande.dart';

class DemandeDetailsScreen extends StatelessWidget {
  final Demande demande;

  const DemandeDetailsScreen({super.key, required this.demande});

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
    final statusColor = _getStatusColor(demande.statut);
    final statusIcon = _getStatusIcon(demande.statut);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Demande #${demande.id}'),
        backgroundColor: kSenelecBlue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête avec statut
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: statusColor.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(statusIcon, color: statusColor, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          demande.typeDisplay,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: kSenelecBlue,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          demande.statutDisplay,
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Informations générales
            const Text(
              'Informations générales',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: kSenelecBlue,
              ),
            ),
            const SizedBox(height: 12),

            _buildInfoCard([
              _buildInfoRow('Numéro de demande', '#${demande.id}'),
              _buildInfoRow('Type', demande.typeDisplay),
              _buildInfoRow('Statut', demande.statutDisplay),
              _buildInfoRow(
                'Date de soumission',
                '${demande.dateSoumission.day}/${demande.dateSoumission.month}/${demande.dateSoumission.year} à ${demande.dateSoumission.hour}:${demande.dateSoumission.minute.toString().padLeft(2, '0')}',
              ),
              _buildInfoRow(
                'Dernière modification',
                '${demande.updatedAt.day}/${demande.updatedAt.month}/${demande.updatedAt.year} à ${demande.updatedAt.hour}:${demande.updatedAt.minute.toString().padLeft(2, '0')}',
              ),
            ]),

            const SizedBox(height: 24),

            // Description
            const Text(
              'Description',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: kSenelecBlue,
              ),
            ),
            const SizedBox(height: 12),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Text(
                demande.description,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ),

            if (demande.piecesJointes != null) ...[
              const SizedBox(height: 24),
              const Text(
                'Pièces jointes',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: kSenelecBlue,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.attach_file, color: Colors.blue.shade700),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        demande.piecesJointes!,
                        style: TextStyle(
                          color: Colors.blue.shade700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Assignations (si disponibles)
            if (demande.administrateurId != null || demande.technicienId != null) ...[
              const Text(
                'Assignations',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: kSenelecBlue,
                ),
              ),
              const SizedBox(height: 12),

              _buildInfoCard([
                if (demande.administrateurId != null)
                  _buildInfoRow('Administrateur assigné', 'Admin #${demande.administrateurId}'),
                if (demande.technicienId != null)
                  _buildInfoRow('Technicien assigné', 'Technicien #${demande.technicienId}'),
              ]),
            ],

            const SizedBox(height: 32),

            // Actions
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Action pour modifier la demande
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Fonctionnalité à venir'),
                          backgroundColor: Colors.orange,
                        ),
                      );
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('Modifier'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kSenelecBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // Action pour supprimer la demande
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Supprimer la demande'),
                            content: const Text(
                              'Êtes-vous sûr de vouloir supprimer cette demande ?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('Annuler'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Fonctionnalité à venir'),
                                      backgroundColor: Colors.orange,
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text('Supprimer'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    icon: const Icon(Icons.delete),
                    label: const Text('Supprimer'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 12),
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

  Widget _buildInfoCard(List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              '$label :',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
} 