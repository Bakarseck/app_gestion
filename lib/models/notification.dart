import 'package:flutter/material.dart';

class AppNotification {
  final int id;
  final String message;
  final DateTime dateEnvoi;
  final bool lu;
  final String type;
  final int? clientId;
  final int? technicienId;
  final int? administrateurId;
  final int? demandeId;
  final int? reclamationId;
  final DateTime createdAt;

  AppNotification({
    required this.id,
    required this.message,
    required this.dateEnvoi,
    required this.lu,
    required this.type,
    this.clientId,
    this.technicienId,
    this.administrateurId,
    this.demandeId,
    this.reclamationId,
    required this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'],
      message: json['message'],
      dateEnvoi: DateTime.parse(json['dateEnvoi']),
      lu: json['lu'] == 1 || json['lu'] == true,
      type: json['type'],
      clientId: json['client_id'],
      technicienId: json['technicien_id'],
      administrateurId: json['administrateur_id'],
      demandeId: json['demande_id'],
      reclamationId: json['reclamation_id'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'message': message,
      'dateEnvoi': dateEnvoi.toIso8601String(),
      'lu': lu ? 1 : 0,
      'type': type,
      'client_id': clientId,
      'technicien_id': technicienId,
      'administrateur_id': administrateurId,
      'demande_id': demandeId,
      'reclamation_id': reclamationId,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Méthodes utilitaires
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(dateEnvoi);

    if (difference.inDays > 0) {
      return '${difference.inDays}j';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}min';
    } else {
      return 'À l\'instant';
    }
  }

  String get typeDisplay {
    switch (type.toLowerCase()) {
      case 'demande':
        return 'Demande d\'abonnement';
      case 'reclamation':
        return 'Réclamation';
      case 'system':
        return 'Système';
      default:
        return type;
    }
  }

  IconData get typeIcon {
    switch (type.toLowerCase()) {
      case 'demande':
        return Icons.subscriptions;
      case 'reclamation':
        return Icons.report_problem;
      case 'system':
        return Icons.info;
      default:
        return Icons.notifications;
    }
  }
}
