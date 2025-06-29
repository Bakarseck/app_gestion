import '../models/demande.dart';
import '../services/api_service.dart';

class DemandesRepository {
  static Future<List<Demande>> getDemandes() async {
    try {
      final result = await ApiService.get('demandes');

      if (result['success'] == true) {
        final List<dynamic> demandesData = result['demandes'] ?? [];
        return demandesData.map((json) => Demande.fromJson(json)).toList();
      } else {
        throw Exception(
          result['message'] ?? 'Erreur lors de la récupération des demandes',
        );
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  static Future<Demande> getDemandeById(int id) async {
    try {
      final result = await ApiService.get('demandes/$id');

      if (result['success'] == true) {
        return Demande.fromJson(result['demande']);
      } else {
        throw Exception(
          result['message'] ?? 'Erreur lors de la récupération de la demande',
        );
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  static Future<Demande> createDemande({
    required String type,
    required String description,
    String? piecesJointes,
  }) async {
    try {
      final result = await ApiService.post('demandes', {
        'type': type,
        'description': description,
        if (piecesJointes != null) 'piecesJointes': piecesJointes,
      });

      if (result['success'] == true) {
        return Demande.fromJson(result['demande']);
      } else {
        throw Exception(
          result['message'] ?? 'Erreur lors de la création de la demande',
        );
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  static Future<Demande> updateDemande(
    int id,
    Map<String, dynamic> data,
  ) async {
    try {
      final result = await ApiService.put('demandes/$id', data);

      if (result['success'] == true) {
        return Demande.fromJson(result['demande']);
      } else {
        throw Exception(
          result['message'] ?? 'Erreur lors de la modification de la demande',
        );
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  static Future<void> deleteDemande(int id) async {
    try {
      final result = await ApiService.delete('demandes/$id');

      if (result['success'] != true) {
        throw Exception(
          result['message'] ?? 'Erreur lors de la suppression de la demande',
        );
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  // Méthodes utilitaires pour filtrer les demandes
  static List<Demande> filterByStatus(List<Demande> demandes, String status) {
    return demandes
        .where(
          (demande) => demande.statut.toLowerCase() == status.toLowerCase(),
        )
        .toList();
  }

  static List<Demande> filterByType(List<Demande> demandes, String type) {
    return demandes
        .where((demande) => demande.type.toLowerCase() == type.toLowerCase())
        .toList();
  }

  static List<Demande> getDemandesEnAttente(List<Demande> demandes) {
    return filterByStatus(demandes, 'ouvert');
  }

  static List<Demande> getDemandesValidees(List<Demande> demandes) {
    return filterByStatus(demandes, 'validé');
  }

  static List<Demande> getDemandesRejetees(List<Demande> demandes) {
    return filterByStatus(demandes, 'rejeté');
  }
}
