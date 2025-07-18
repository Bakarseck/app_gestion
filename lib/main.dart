import 'package:app_gestion/screens/login_screen.dart';
import 'package:app_gestion/screens/home_screen.dart';
import 'package:app_gestion/screens/admin_dashboard.dart';
import 'package:app_gestion/screens/technician_dashboard.dart';
import 'package:app_gestion/screens/abonnements_screen.dart';
import 'package:app_gestion/screens/reclamations_screen.dart';
import 'package:app_gestion/screens/notifications_screen.dart';
import 'package:app_gestion/screens/nouvel_abonnement_screen.dart';
import 'package:app_gestion/screens/nouvelle_reclamation_screen.dart';
import 'package:app_gestion/screens/aide_support_screen.dart';
import 'package:app_gestion/screens/parametres_screen.dart';
import 'package:app_gestion/screens/toutes_demandes_screen.dart';
import 'package:app_gestion/screens/demande_details_screen.dart';
import 'package:app_gestion/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'theme/colors.dart';
import 'models/demande.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Senelec',
      theme: ThemeData(
        primarySwatch: kSenelecBlue,
        colorScheme: ColorScheme(
          primary: kSenelecBlue,
          onPrimary: Colors.white,
          secondary: kSenelecViolet,
          onSecondary: Colors.white,
          surface: Colors.white,
          onSurface: Colors.black,
          background: Colors.white,
          onBackground: Colors.black,
          error: kSenelecPink,
          onError: Colors.white,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: true,
          backgroundColor: kSenelecBlue,
          foregroundColor: Colors.white,
        ),
        cardTheme: CardThemeData(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 4,
            backgroundColor: kSenelecViolet,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          ),
        ),
      ),
      home: const AuthWrapper(),
      routes: {
        '/admin-dashboard': (context) => const AdminDashboard(),
        '/technician-dashboard': (context) => const TechnicianDashboard(),
        '/abonnements': (context) => const AbonnementsScreen(),
        '/reclamations': (context) => const ReclamationsScreen(),
        '/notifications': (context) => const NotificationsScreen(),
        '/nouvel-abonnement': (context) => const NouvelAbonnementScreen(),
        '/nouvelle-reclamation': (context) => const NouvelleReclamationScreen(),
        '/aide-support': (context) => const AideSupportScreen(),
        '/parametres':
            (context) => ParametresScreen(
              onLogout: () {
                // Navigation vers la page de login
                Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil('/', (route) => false);
              },
            ),
        '/toutes-demandes': (context) => const ToutesDemandesScreen(),
        '/demande-details': (context) {
          final demande = ModalRoute.of(context)!.settings.arguments as Demande;
          return DemandeDetailsScreen(demande: demande);
        },
      },
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isLoading = true;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    try {
      // Vérifier si l'utilisateur est connecté
      final isLoggedIn = await AuthService.isLoggedIn();

      if (isLoggedIn) {
        // Vérifier si le token est toujours valide
        final verifyResult = await AuthService.verifyToken();
        if (verifyResult['success'] == true) {
          setState(() {
            _isLoggedIn = true;
            _isLoading = false;
          });
        } else {
          // Token invalide, déconnecter l'utilisateur
          await AuthService.logout();
          setState(() {
            _isLoggedIn = false;
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _isLoggedIn = false;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoggedIn = false;
        _isLoading = false;
      });
    }
  }

  // Méthode pour forcer la déconnexion
  Future<void> _logout() async {
    await AuthService.logout();
    setState(() {
      _isLoggedIn = false;
    });
  }

  // Méthode pour forcer la connexion (appelée depuis LoginPage)
  void _onLoginSuccess() {
    setState(() {
      _isLoggedIn = true;
    });
  }

  // Méthode pour déterminer le rôle de l'utilisateur
  String _determineUserRole(Map<String, dynamic> userData) {
    // Vérifier différents champs possibles pour le rôle
    final role =
        userData['role']?.toString().toLowerCase() ??
        userData['type']?.toString().toLowerCase() ??
        userData['userType']?.toString().toLowerCase() ??
        userData['typeUtilisateur']?.toString().toLowerCase() ??
        'client';

    print('Données utilisateur: $userData');
    print('Rôle déterminé: $role');

    return role;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Icon(Icons.electric_bolt, size: 64, color: kSenelecBlue),
                    const SizedBox(height: 16),
                    const Text(
                      'SENELEC',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: kSenelecBlue,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(kSenelecBlue),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Vérification de l\'authentification...',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Si l'utilisateur est connecté, vérifier le rôle et rediriger
    // Sinon, afficher la page de login
    if (_isLoggedIn) {
      return FutureBuilder<Map<String, dynamic>?>(
        future: AuthService.getUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final userData = snapshot.data;
          if (userData != null) {
            final userRole = _determineUserRole(userData);

            print('Redirection vers le dashboard pour le rôle: $userRole');

            if (userRole == 'admin' || userRole == 'administrateur') {
              return const AdminDashboard();
            } else if (userRole == 'technicien' || userRole == 'technician') {
              return const TechnicianDashboard();
            } else {
              // Clients
              return HomeScreen(onLogout: _logout);
            }
          } else {
            // Si pas de données utilisateur, rediriger vers HomeScreen
            print(
              'Aucune donnée utilisateur trouvée, redirection vers HomeScreen',
            );
            return HomeScreen(onLogout: _logout);
          }
        },
      );
    } else {
      return LoginPage(onLoginSuccess: _onLoginSuccess);
    }
  }
}
