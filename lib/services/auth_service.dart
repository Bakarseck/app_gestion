import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../services/api_service.dart';

class AuthService {
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';

  // Vérifier si l'utilisateur est connecté
  static Future<bool> isLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(tokenKey);
      return token != null && token.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // Obtenir le token d'authentification
  static Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(tokenKey);
    } catch (e) {
      return null;
    }
  }

  // Obtenir les données utilisateur
  static Future<Map<String, dynamic>?> getUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userData = prefs.getString(userKey);
      if (userData != null) {
        return json.decode(userData);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Sauvegarder les données d'authentification
  static Future<void> saveAuthData(
    String token,
    Map<String, dynamic> userData,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(tokenKey, token);
      await prefs.setString(userKey, json.encode(userData));
    } catch (e) {
      print('Erreur lors de la sauvegarde des données: $e');
    }
  }

  // Supprimer les données d'authentification
  static Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(tokenKey);
      await prefs.remove(userKey);
    } catch (e) {
      print('Erreur lors de la déconnexion: $e');
    }
  }

  // Connexion
  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    try {
      print('Tentative de connexion pour: $email');

      final response = await http
          .post(
            Uri.parse('${ApiConfig.baseUrl}/${ApiConfig.loginEndpoint}'),
            headers: ApiConfig.defaultHeaders,
            body: json.encode({'email': email, 'motDePasse': password}),
          )
          .timeout(Duration(seconds: ApiConfig.connectionTimeout));

      final data = json.decode(response.body);
      print('Réponse de l\'API: $data');

      if (response.statusCode == 200 && data['success'] == true) {
        // Sauvegarder les données d'authentification
        final userData = data['user'] ?? data['utilisateur'] ?? data;
        print('Données utilisateur à sauvegarder: $userData');

        await saveAuthData(data['token'], userData);

        return {
          'success': true,
          'message': data['message'] ?? 'Connexion réussie',
          'user': userData,
          'token': data['token'],
        };
      } else {
        print('Erreur de connexion: ${data['message']}');
        return {
          'success': false,
          'message': data['message'] ?? 'Erreur de connexion',
        };
      }
    } catch (e) {
      print('Exception lors de la connexion: $e');
      return {'success': false, 'message': 'Erreur de connexion: $e'};
    }
  }

  // Inscription
  static Future<Map<String, dynamic>> register(
    String nom,
    String prenom,
    String email,
    String motDePasse,
    String numeroCNI,
    String dateNaissance,
    String adresse,
    String numeroTelephone,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse('${ApiConfig.baseUrl}/${ApiConfig.registerEndpoint}'),
            headers: ApiConfig.defaultHeaders,
            body: json.encode({
              'nom': nom,
              'prenom': prenom,
              'email': email,
              'motDePasse': motDePasse,
              'numeroCNI': numeroCNI,
              'dateNaissance': dateNaissance,
              'adresse': adresse,
              'numeroTelephone': numeroTelephone,
            }),
          )
          .timeout(Duration(seconds: ApiConfig.connectionTimeout));

      final data = json.decode(response.body);

      if (response.statusCode == 201 && data['success'] == true) {
        // Sauvegarder les données d'authentification
        await saveAuthData(data['token'], data['user']);
        return {
          'success': true,
          'message': data['message'] ?? 'Inscription réussie',
          'user': data['user'],
          'token': data['token'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Erreur d\'inscription',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Erreur d\'inscription: $e'};
    }
  }

  // Vérifier le token
  static Future<Map<String, dynamic>> verifyToken() async {
    try {
      final token = await getToken();
      if (token == null) {
        return {'success': false, 'message': 'Token non trouvé'};
      }

      final response = await http
          .get(
            Uri.parse('${ApiConfig.baseUrl}/${ApiConfig.verifyEndpoint}'),
            headers: {
              'Authorization': 'Bearer $token',
              ...ApiConfig.defaultHeaders,
            },
          )
          .timeout(Duration(seconds: ApiConfig.connectionTimeout));

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'message': data['message'] ?? 'Token valide',
          'user': data['user'],
        };
      } else {
        // Token invalide, déconnecter l'utilisateur
        await logout();
        return {
          'success': false,
          'message': data['message'] ?? 'Token invalide',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Erreur de vérification: $e'};
    }
  }

  // Obtenir les headers d'authentification pour les requêtes API
  static Future<Map<String, String>> getAuthHeaders() async {
    final token = await getToken();
    return {'Authorization': 'Bearer $token', ...ApiConfig.defaultHeaders};
  }

  static Future<Map<String, dynamic>> getProfile() async {
    try {
      final result = await ApiService.get('auth/profile');
      return result;
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur lors de la récupération du profil: $e',
      };
    }
  }
}
