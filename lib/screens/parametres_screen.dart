import 'package:flutter/material.dart';
import 'package:app_gestion/theme/colors.dart';
import 'package:app_gestion/services/auth_service.dart';

class ParametresScreen extends StatefulWidget {
  final VoidCallback onLogout;

  const ParametresScreen({super.key, required this.onLogout});

  @override
  State<ParametresScreen> createState() => _ParametresScreenState();
}

class _ParametresScreenState extends State<ParametresScreen> {
  Map<String, dynamic>? _userProfile;
  bool _isLoading = true;
  bool _notificationsEnabled = true;
  bool _biometricEnabled = false;
  String _selectedLanguage = 'Français';
  String _selectedTheme = 'Système';

  final List<String> _languages = ['Français', 'English', 'Wolof'];
  final List<String> _themes = ['Système', 'Clair', 'Sombre'];

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final result = await AuthService.getProfile();
      if (mounted) {
        setState(() {
          if (result['success'] == true) {
            _userProfile = result['user'];
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _getFullName() {
    if (_userProfile == null) return 'Utilisateur';
    final prenom = _userProfile!['prenom'] ?? '';
    final nom = _userProfile!['nom'] ?? '';
    return '$prenom $nom'.trim().isEmpty ? 'Utilisateur' : '$prenom $nom'.trim();
  }

  String _getEmail() {
    return _userProfile?['email'] ?? 'email@example.com';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Paramètres'),
        backgroundColor: kSenelecBlue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(kSenelecBlue),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profil utilisateur
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [kSenelecBlue, kSenelecViolet],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.white.withOpacity(0.2),
                          child: const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _getFullName(),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _getEmail(),
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.white),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Modification du profil bientôt disponible'),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Section Compte
                  _buildSectionTitle('Compte'),
                  _buildSettingTile(
                    'Modifier le profil',
                    'Modifier vos informations personnelles',
                    Icons.person_outline,
                    () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Modification du profil bientôt disponible'),
                        ),
                      );
                    },
                  ),
                  _buildSettingTile(
                    'Changer le mot de passe',
                    'Mettre à jour votre mot de passe',
                    Icons.lock_outline,
                    () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Changement de mot de passe bientôt disponible'),
                        ),
                      );
                    },
                  ),
                  _buildSettingTile(
                    'Informations de sécurité',
                    'Gérer la sécurité de votre compte',
                    Icons.security,
                    () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Sécurité bientôt disponible'),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  // Section Notifications
                  _buildSectionTitle('Notifications'),
                  _buildSwitchTile(
                    'Notifications push',
                    'Recevoir des notifications sur votre appareil',
                    Icons.notifications_outlined,
                    _notificationsEnabled,
                    (value) {
                      setState(() {
                        _notificationsEnabled = value;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            value ? 'Notifications activées' : 'Notifications désactivées',
                          ),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                  ),
                  _buildSettingTile(
                    'Préférences de notifications',
                    'Personnaliser vos notifications',
                    Icons.settings,
                    () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Préférences bientôt disponibles'),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  // Section Apparence
                  _buildSectionTitle('Apparence'),
                  _buildDropdownTile(
                    'Langue',
                    'Choisir la langue de l\'application',
                    Icons.language,
                    _selectedLanguage,
                    _languages,
                    (value) {
                      setState(() {
                        _selectedLanguage = value!;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Langue changée vers $value'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                  ),
                  _buildDropdownTile(
                    'Thème',
                    'Choisir le thème de l\'application',
                    Icons.palette,
                    _selectedTheme,
                    _themes,
                    (value) {
                      setState(() {
                        _selectedTheme = value!;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Thème changé vers $value'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  // Section Sécurité
                  _buildSectionTitle('Sécurité'),
                  _buildSwitchTile(
                    'Authentification biométrique',
                    'Utiliser l\'empreinte digitale ou Face ID',
                    Icons.fingerprint,
                    _biometricEnabled,
                    (value) {
                      setState(() {
                        _biometricEnabled = value;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            value ? 'Biométrie activée' : 'Biométrie désactivée',
                          ),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                  ),
                  _buildSettingTile(
                    'Historique de connexion',
                    'Voir vos connexions récentes',
                    Icons.history,
                    () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Historique bientôt disponible'),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  // Section À propos
                  _buildSectionTitle('À propos'),
                  _buildSettingTile(
                    'Version de l\'application',
                    'v1.0.0',
                    Icons.info_outline,
                    null,
                  ),
                  _buildSettingTile(
                    'Conditions d\'utilisation',
                    'Lire les conditions d\'utilisation',
                    Icons.description,
                    () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Conditions d\'utilisation bientôt disponibles'),
                        ),
                      );
                    },
                  ),
                  _buildSettingTile(
                    'Politique de confidentialité',
                    'Lire la politique de confidentialité',
                    Icons.privacy_tip_outlined,
                    () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Politique de confidentialité bientôt disponible'),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 32),

                  // Bouton de déconnexion
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Déconnexion'),
                              content: const Text(
                                'Êtes-vous sûr de vouloir vous déconnecter ?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text('Annuler'),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    widget.onLogout();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                  ),
                                  child: const Text('Déconnexion'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      icon: const Icon(Icons.logout),
                      label: const Text('Se déconnecter'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: kSenelecBlue,
        ),
      ),
    );
  }

  Widget _buildSettingTile(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback? onTap,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: kSenelecBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: kSenelecBlue, size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
        ),
        trailing: onTap != null
            ? const Icon(Icons.arrow_forward_ios, size: 16)
            : null,
        onTap: onTap,
      ),
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: kSenelecBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: kSenelecBlue, size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
        ),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeColor: kSenelecBlue,
        ),
      ),
    );
  }

  Widget _buildDropdownTile(
    String title,
    String subtitle,
    IconData icon,
    String value,
    List<String> options,
    ValueChanged<String?> onChanged,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: kSenelecBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: kSenelecBlue, size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
        ),
        trailing: DropdownButton<String>(
          value: value,
          underline: Container(),
          items: options.map((String option) {
            return DropdownMenuItem<String>(
              value: option,
              child: Text(option),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
} 