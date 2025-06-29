class Reclamation {
  final int id;
  final int clientId;
  final String objet;
  final DateTime date;
  final String statut;
  final String description;
  final int? technicienId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Reclamation({
    required this.id,
    required this.clientId,
    required this.objet,
    required this.date,
    required this.statut,
    required this.description,
    this.technicienId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Reclamation.fromJson(Map<String, dynamic> json) {
    return Reclamation(
      id: json['id'],
      clientId: json['client_id'],
      objet: json['objet'],
      date: DateTime.parse(json['date']),
      statut: json['statut'],
      description: json['description'],
      technicienId: json['technicien_id'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'client_id': clientId,
      'objet': objet,
      'date': date.toIso8601String(),
      'statut': statut,
      'description': description,
      'technicien_id': technicienId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Méthodes utilitaires
  bool get isOuverte => statut.toLowerCase() == 'ouvert';
  bool get isEnValidation => statut.toLowerCase() == 'en cours de validation';
  bool get isChezTechnicien => statut.toLowerCase() == 'chez le technicien';
  bool get isResolue => statut.toLowerCase() == 'résolu';
  bool get isRejetee => statut.toLowerCase() == 'rejeté';

  String get statutDisplay {
    switch (statut.toLowerCase()) {
      case 'ouvert':
        return 'En cours de validation';
      case 'en cours de validation':
        return 'En cours de validation';
      case 'chez le technicien':
        return 'Chez le technicien';
      case 'résolu':
        return 'Résolu';
      case 'rejeté':
        return 'Rejeté';
      default:
        return statut;
    }
  }

  String get priorite {
    // Logique pour déterminer la priorité basée sur l'objet
    final objetLower = objet.toLowerCase();
    if (objetLower.contains('coupure') || objetLower.contains('urgence')) {
      return 'Haute';
    } else if (objetLower.contains('compteur') ||
        objetLower.contains('facture')) {
      return 'Moyenne';
    } else {
      return 'Basse';
    }
  }

  String get categorie {
    final objetLower = objet.toLowerCase();
    if (objetLower.contains('coupure')) {
      return 'Coupure';
    } else if (objetLower.contains('compteur')) {
      return 'Compteur';
    } else if (objetLower.contains('facture')) {
      return 'Facturation';
    } else if (objetLower.contains('installation')) {
      return 'Installation';
    } else {
      return 'Autre';
    }
  }
}
