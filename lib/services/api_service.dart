import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_service.dart';

class ApiService {
  static const String baseUrl = 'https://backend.vision-optique.com/api';
  static const String _tokenKey = 'auth_token';

  static Future<String?> _getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_tokenKey);
    } catch (e) {
      return null;
    }
  }

  static Map<String, String> _getHeaders() {
    return {'Content-Type': 'application/json', 'Accept': 'application/json'};
  }

  static Future<Map<String, String>> _getAuthHeaders() async {
    final token = await _getToken();
    final headers = _getHeaders();
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  // Fonction pour mapper les rôles selon les besoins du backend
  static String _mapRoleForBackend(String originalRole) {
    switch (originalRole) {
      case 'administrateur':
        return 'admin';
      case 'technicien':
        return 'technicien';
      case 'client':
        return 'client';
      default:
        return originalRole;
    }
  }

  static Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    try {
      final url = Uri.parse('$baseUrl/$endpoint');

      // Use basic headers for login/register, auth headers for other endpoints
      final headers =
          (endpoint == 'auth/login' || endpoint == 'auth/register')
              ? _getHeaders()
              : await _getAuthHeaders();

      final response = await http
          .post(url, headers: headers, body: jsonEncode(data))
          .timeout(const Duration(seconds: 30));

      final responseData = jsonDecode(response.body);

      // For login, save the new token if successful
      if (endpoint == 'auth/login' &&
          response.statusCode == 200 &&
          responseData['success'] == true) {
        try {
          if (responseData['token'] != null) {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString(_tokenKey, responseData['token']);
          }
        } catch (e) {
          print('Failed to save token from login response: $e');
        }
      }

      // Check for 401 only for non-auth endpoints
      if (response.statusCode == 401 && !endpoint.startsWith('auth/')) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(_tokenKey);
        return {
          'success': false,
          'message': 'Session expirée. Veuillez vous reconnecter.',
        };
      }

      return responseData;
    } catch (e) {
      return {'success': false, 'message': 'Erreur de requête: $e'};
    }
  }

  static Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      final url = Uri.parse('$baseUrl/$endpoint');
      final headers = await _getAuthHeaders();

      final response = await http
          .get(url, headers: headers)
          .timeout(const Duration(seconds: 30));

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 401) {
        // Token expired or invalid
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(_tokenKey);
        return {
          'success': false,
          'message': 'Session expirée. Veuillez vous reconnecter.',
        };
      }

      return responseData;
    } catch (e) {
      return {'success': false, 'message': 'Erreur de requête: $e'};
    }
  }

  static Future<Map<String, dynamic>> delete(String endpoint) async {
    try {
      final url = Uri.parse('$baseUrl/$endpoint');
      final headers = await _getAuthHeaders();

      final response = await http
          .delete(url, headers: headers)
          .timeout(const Duration(seconds: 30));

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 401) {
        // Token expired or invalid
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(_tokenKey);
        return {
          'success': false,
          'message': 'Session expirée. Veuillez vous reconnecter.',
        };
      }

      return responseData;
    } catch (e) {
      return {'success': false, 'message': 'Erreur de suppression: $e'};
    }
  }

  static Future<Map<String, dynamic>> put(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    try {
      final url = Uri.parse('$baseUrl/$endpoint');
      final headers = await _getAuthHeaders();

      final response = await http
          .put(url, headers: headers, body: jsonEncode(data))
          .timeout(const Duration(seconds: 30));

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 401) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(_tokenKey);
        return {
          'success': false,
          'message': 'Session expirée. Veuillez vous reconnecter.',
        };
      }

      return responseData;
    } catch (e) {
      return {'success': false, 'message': 'Erreur de modification: $e'};
    }
  }

  // === DEMANDES ===
  static Future<Map<String, dynamic>> creerDemande(
    Map<String, dynamic> data,
  ) async {
    // POST vers l'endpoint 'demandes'
    return await post('demandes', data);
  }

  static Future<Map<String, dynamic>> getDemandes() async {
    // GET vers l'endpoint 'demandes'
    final result = await get('demandes');

    // Si le backend renvoie directement un tableau
    if (result is List) {
      return {'success': true, 'demandes': result};
    }

    // Si la réponse contient 'data' au lieu de 'demandes', on l'adapte
    if (result['success'] == true &&
        result['data'] != null &&
        result['demandes'] == null) {
      result['demandes'] = result['data'];
    }

    return result;
  }

  // === RECLAMATIONS ===
  static Future<Map<String, dynamic>> creerReclamation(
    Map<String, dynamic> data,
  ) async {
    return await post('claims', data);
  }

  static Future<Map<String, dynamic>> getReclamations() async {
    // GET vers l'endpoint 'claims'
    final result = await get('claims');

    print('API getReclamations result: $result');

    // Si le backend renvoie directement un tableau
    if (result is List) {
      return {'success': true, 'reclamations': result};
    }

    // Si la réponse contient 'data' au lieu de 'reclamations', on l'adapte
    if (result['success'] == true &&
        result['data'] != null &&
        result['reclamations'] == null) {
      result['reclamations'] = result['data'];
    }

    return result;
  }

  // === TECHNICIENS ===
  static Future<List<Map<String, dynamic>>> getTechniciens() async {
    try {
      print('Tentative de récupération des techniciens...');
      final result = await get('technicians');

      print('Résultat getTechniciens: $result');

      if (result['success'] == true && result['data'] != null) {
        final techniciens = List<Map<String, dynamic>>.from(result['data']);
        print('Techniciens récupérés: ${techniciens.length}');
        return techniciens;
      }

      print('Aucun technicien trouvé ou erreur dans la réponse');
      return [];
    } catch (e) {
      print('Erreur lors du chargement des techniciens: $e');
      return [];
    }
  }

  // === ACTIONS ADMIN ===
  static Future<Map<String, dynamic>> assignTechnicien(
    String demandeId,
    String technicienId,
  ) async {
    print(
      'Tentative d\'assignation du technicien $technicienId à la demande $demandeId',
    );

    // Récupérer les données utilisateur pour mapper le rôle
    final userData = await AuthService.getUserData();
    final userRole = userData?['typeUtilisateur'] ?? 'administrateur';
    final mappedRole = _mapRoleForBackend(userRole);

    print('Rôle utilisateur: $userRole, Rôle mappé: $mappedRole');
    print('Données utilisateur complètes: $userData');

    // Vérifier le token
    final token = await AuthService.getToken();
    print('Token disponible: ${token != null ? "Oui" : "Non"}');
    if (token != null) {
      print('Token (premiers caractères): ${token.substring(0, 20)}...');
    }

    final result = await put('demandes/$demandeId/assign', {
      'technicien_id': technicienId,
    });
    print('Résultat assignTechnicien: $result');
    return result;
  }

  static Future<Map<String, dynamic>> updateStatus(
    String demandeId,
    String status,
  ) async {
    print(
      'Tentative de mise à jour du statut $status pour la demande $demandeId',
    );

    // Récupérer les données utilisateur pour mapper le rôle
    final userData = await AuthService.getUserData();
    final userRole = userData?['typeUtilisateur'] ?? 'technicien';
    final mappedRole = _mapRoleForBackend(userRole);

    print('Rôle utilisateur: $userRole, Rôle mappé: $mappedRole');

    final result = await put('demandes/$demandeId/status', {'statut': status});
    print('Résultat updateStatus: $result');
    return result;
  }

  static Future<Map<String, dynamic>> addComment(
    String demandeId,
    String comment,
  ) async {
    print('Tentative d\'ajout de commentaire pour la demande $demandeId');

    // Récupérer les données utilisateur pour mapper le rôle
    final userData = await AuthService.getUserData();
    final userRole = userData?['typeUtilisateur'] ?? 'technicien';
    final mappedRole = _mapRoleForBackend(userRole);

    print('Rôle utilisateur: $userRole, Rôle mappé: $mappedRole');

    final result = await put('demandes/$demandeId/comment', {
      'commentaire': comment,
    });
    print('Résultat addComment: $result');
    return result;
  }

  // === NOTIFICATIONS ===
  static Future<Map<String, dynamic>> getNotifications() async {
    try {
      final result = await get('users/notifications');
      print('Résultat getNotifications: $result');
      return result;
    } catch (e) {
      print('Erreur lors de la récupération des notifications: $e');
      return {
        'success': false,
        'message': 'Erreur lors de la récupération des notifications',
      };
    }
  }

  static Future<Map<String, dynamic>> markNotificationAsRead(
    int notificationId,
  ) async {
    try {
      final result = await put('users/notifications/$notificationId/read', {});
      print('Résultat markNotificationAsRead: $result');
      return result;
    } catch (e) {
      print('Erreur lors de la mise à jour de la notification: $e');
      return {
        'success': false,
        'message': 'Erreur lors de la mise à jour de la notification',
      };
    }
  }
}
