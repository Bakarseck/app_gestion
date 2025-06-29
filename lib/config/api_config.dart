class ApiConfig {
  // URL du backend - changez selon votre environnement
  static const String baseUrl = 'https://backend.vision-optique.com/api';

  // Timeouts
  static const int connectionTimeout = 30; // secondes
  static const int receiveTimeout = 30; // secondes

  // Headers par défaut
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Endpoints
  static const String loginEndpoint = 'auth/login';
  static const String registerEndpoint = 'auth/register';
  static const String verifyEndpoint = 'auth/verify';
  static const String logoutEndpoint = 'auth/logout';

  // Messages d'erreur
  static const String networkError = 'Erreur de connexion réseau';
  static const String timeoutError = 'Délai d\'attente dépassé';
  static const String serverError = 'Erreur du serveur';
  static const String unauthorizedError = 'Non autorisé';
  static const String sessionExpiredError =
      'Session expirée. Veuillez vous reconnecter.';
}
