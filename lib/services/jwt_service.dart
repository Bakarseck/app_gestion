import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';
import '../models/user.dart';

class JwtService {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';
  final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 50,
      colors: true,
      printEmojis: true,
      // ignore: deprecated_member_use
      printTime: true,
    ),
  );

  // Sauvegarder le token JWT
  Future<void> saveToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
      _logger.i('✅ Token JWT sauvegardé avec succès');
    } catch (e) {
      _logger.e('❌ Erreur lors de la sauvegarde du token JWT', error: e);
      rethrow;
    }
  }

  // Récupérer le token JWT
  Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_tokenKey);
      if (token != null) {
        _logger.i('✅ Token JWT récupéré avec succès');
      } else {
        _logger.w('⚠️ Aucun token JWT trouvé');
      }
      return token;
    } catch (e) {
      _logger.e('❌ Erreur lors de la récupération du token JWT', error: e);
      return null;
    }
  }

  // Sauvegarder les données utilisateur
  Future<void> saveUser(User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userKey, jsonEncode(user.toJson()));
      _logger.i(
        '✅ Données utilisateur sauvegardées avec succès',
          error: user.toJson(),
      );  
    } catch (e) {
      _logger.e(
        '❌ Erreur lors de la sauvegarde des données utilisateur',
        error: e,
      );
      rethrow;
    }
  }

  // Récupérer les données utilisateur
  Future<User?> getUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_userKey);
      if (userJson != null) {
        final user = User.fromJson(jsonDecode(userJson));
        _logger.i(
          '✅ Données utilisateur récupérées avec succès',
          error: user.toJson(),
        );
        return user;
      }
      _logger.w('⚠️ Aucune donnée utilisateur trouvée');
      return null;
    } catch (e) {
      _logger.e(
        '❌ Erreur lors de la récupération des données utilisateur',
        error: e,
      );
      return null;
    }
  }

  // Vérifier si l'utilisateur est connecté
  Future<bool> isAuthenticated() async {
    try {
      final token = await getToken();
      final isAuth = token != null;
      _logger.i(
        '🔍 État d\'authentification: ${isAuth ? "Connecté" : "Non connecté"}',
      );
      return isAuth;
    } catch (e) {
      _logger.e(
        '❌ Erreur lors de la vérification de l\'authentification',
        error: e,
      );
      return false;
    }
  }

  // Déconnexion
  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      await prefs.remove(_userKey);
      _logger.i('✅ Déconnexion réussie');
    } catch (e) {
      _logger.e('❌ Erreur lors de la déconnexion', error: e);
      rethrow;
    }
  }

  // Décoder le token JWT
  Map<String, dynamic>? decodeToken(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) {
        _logger.w('⚠️ Token JWT mal formé');
        return null;
      }

      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final resp = utf8.decode(base64Url.decode(normalized));
      final payloadMap = json.decode(resp);
      _logger.i('✅ Token JWT décodé avec succès', error: payloadMap);
      return payloadMap;
    } catch (e) {
      _logger.e('❌ Erreur lors du décodage du token JWT', error: e);
      return null;
    }
  }

  // Vérifier si le token est expiré
  bool isTokenExpired(String token) {
    try {
      final decodedToken = decodeToken(token);
      if (decodedToken == null) {
        _logger.w(
          '⚠️ Impossible de vérifier l\'expiration du token - token invalide',
        );
        return true;
      }

      final expiry = decodedToken['exp'] as int?;
      if (expiry == null) {
        _logger.w(
          '⚠️ Impossible de vérifier l\'expiration du token - pas de date d\'expiration',
        );
        return true;
      }

      final expiryDate = DateTime.fromMillisecondsSinceEpoch(expiry * 1000);
      final isExpired = DateTime.now().isAfter(expiryDate);
      _logger.i(
        '🔍 État d\'expiration du token: ${isExpired ? "Expiré" : "Valide"}',
      );
      return isExpired;
    } catch (e) {
      _logger.e(
        '❌ Erreur lors de la vérification de l\'expiration du token',
        error: e,
      );
      return true;
    }
  }
}
