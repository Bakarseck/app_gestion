import '../models/reclamation.dart';
import '../services/api_service.dart';

class ReclamationsRepository {
  static Future<List<Reclamation>> getReclamations() async {
    try {
      final result = await ApiService.getReclamations();

      if (result['success'] == true) {
        final List<dynamic> reclamationsData =
            result['reclamations'] ?? result['data'] ?? [];
        return reclamationsData
            .map((json) => Reclamation.fromJson(json))
            .toList();
      } else {
        throw Exception(
          result['message'] ??
              'Erreur lors de la récupération des réclamations',
        );
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  static Future<Reclamation> getReclamationById(int id) async {
    try {
      final result = await ApiService.get('claims/$id');

      if (result['success'] == true) {
        return Reclamation.fromJson(result['reclamation'] ?? result['data']);
      } else {
        throw Exception(
          result['message'] ??
              'Erreur lors de la récupération de la réclamation',
        );
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  static Future<Reclamation> createReclamation({
    required String objet,
    required String description,
  }) async {
    try {
      final result = await ApiService.post('claims', {
        'objet': objet,
        'description': description,
      });

      if (result['success'] == true) {
        return Reclamation.fromJson(result['reclamation'] ?? result['data']);
      } else {
        throw Exception(
          result['message'] ?? 'Erreur lors de la création de la réclamation',
        );
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  static Future<Reclamation> updateReclamation(
    int id,
    Map<String, dynamic> data,
  ) async {
    try {
      final result = await ApiService.put('claims/$id', data);

      if (result['success'] == true) {
        return Reclamation.fromJson(result['reclamation'] ?? result['data']);
      } else {
        throw Exception(
          result['message'] ??
              'Erreur lors de la modification de la réclamation',
        );
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  static Future<void> deleteReclamation(int id) async {
    try {
      final result = await ApiService.delete('claims/$id');

      if (result['success'] != true) {
        throw Exception(
          result['message'] ??
              'Erreur lors de la suppression de la réclamation',
        );
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  // Méthodes utilitaires pour filtrer les réclamations
  static List<Reclamation> filterByStatus(
    List<Reclamation> reclamations,
    String status,
  ) {
    return reclamations
        .where(
          (reclamation) =>
              reclamation.statut.toLowerCase() == status.toLowerCase(),
        )
        .toList();
  }

  static List<Reclamation> filterByCategorie(
    List<Reclamation> reclamations,
    String categorie,
  ) {
    return reclamations
        .where(
          (reclamation) =>
              reclamation.categorie.toLowerCase() == categorie.toLowerCase(),
        )
        .toList();
  }

  static List<Reclamation> getReclamationsEnValidation(
    List<Reclamation> reclamations,
  ) {
    return filterByStatus(reclamations, 'en cours de validation');
  }

  static List<Reclamation> getReclamationsChezTechnicien(
    List<Reclamation> reclamations,
  ) {
    return filterByStatus(reclamations, 'chez le technicien');
  }

  static List<Reclamation> getReclamationsResolues(
    List<Reclamation> reclamations,
  ) {
    return filterByStatus(reclamations, 'résolu');
  }

  static List<Reclamation> getReclamationsRejetees(
    List<Reclamation> reclamations,
  ) {
    return filterByStatus(reclamations, 'rejeté');
  }

  static List<Reclamation> getReclamationsParPriorite(
    List<Reclamation> reclamations,
    String priorite,
  ) {
    return reclamations
        .where(
          (reclamation) =>
              reclamation.priorite.toLowerCase() == priorite.toLowerCase(),
        )
        .toList();
  }

  // Méthode pour l'admin dashboard
  static Future<Map<String, dynamic>> getUserClaims() async {
    try {
      final result = await ApiService.getReclamations();
      print('Résultat getUserClaims: $result');

      if (result['success'] == true) {
        final reclamations = result['reclamations'] ?? result['data'] ?? [];
        return {'success': true, 'data': reclamations};
      } else {
        return {
          'success': false,
          'message':
              result['message'] ?? 'Erreur lors du chargement des réclamations',
          'data': [],
        };
      }
    } catch (e) {
      print('Exception getUserClaims: $e');
      return {
        'success': false,
        'message': 'Erreur lors du chargement des réclamations: $e',
        'data': [],
      };
    }
  }
}
