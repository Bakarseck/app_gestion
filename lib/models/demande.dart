class Demande {
  final int id;
  final int clientId;
  final String type;
  final DateTime dateSoumission;
  final String statut;
  final String description;
  final String? piecesJointes;
  final int? administrateurId;
  final int? technicienId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Demande({
    required this.id,
    required this.clientId,
    required this.type,
    required this.dateSoumission,
    required this.statut,
    required this.description,
    this.piecesJointes,
    this.administrateurId,
    this.technicienId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Demande.fromJson(Map<String, dynamic> json) {
    return Demande(
      id: json['id'],
      clientId: json['client_id'],
      type: json['type'],
      dateSoumission: DateTime.parse(json['dateSoumission']),
      statut: json['statut'],
      description: json['description'],
      piecesJointes: json['piecesJointes'],
      administrateurId: json['administrateur_id'],
      technicienId: json['technicien_id'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'client_id': clientId,
      'type': type,
      'dateSoumission': dateSoumission.toIso8601String(),
      'statut': statut,
      'description': description,
      'piecesJointes': piecesJointes,
      'administrateur_id': administrateurId,
      'technicien_id': technicienId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Méthodes utilitaires
  bool get isEnAttente => statut.toLowerCase() == 'ouvert';
  bool get isValidee => statut.toLowerCase() == 'validé';
  bool get isRejetee => statut.toLowerCase() == 'rejeté';
  bool get isEnCours => statut.toLowerCase() == 'en cours';

  String get statutDisplay {
    switch (statut.toLowerCase()) {
      case 'ouvert':
        return 'En attente de validation';
      case 'validé':
        return 'Validé';
      case 'rejeté':
        return 'Rejeté';
      case 'en cours':
        return 'En cours de traitement';
      default:
        return statut;
    }
  }

  String get typeDisplay {
    switch (type.toLowerCase()) {
      case 'abonnement':
        return 'Nouvel abonnement';
      case 'modification':
        return 'Modification d\'abonnement';
      case 'resiliation':
        return 'Résiliation d\'abonnement';
      default:
        return type;
    }
  }
}
