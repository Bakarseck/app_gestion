import 'package:flutter/material.dart';
import 'package:app_gestion/theme/colors.dart';
import 'package:app_gestion/services/auth_service.dart';

class RegisterPage extends StatefulWidget {
  final VoidCallback onLoginSuccess;

  const RegisterPage({super.key, required this.onLoginSuccess});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _emailController = TextEditingController();
  final _motDePasseController = TextEditingController();
  final _numeroCNIController = TextEditingController();
  final _dateNaissanceController = TextEditingController();
  final _adresseController = TextEditingController();
  final _numeroTelephoneController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  DateTime? _selectedDate;

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _emailController.dispose();
    _motDePasseController.dispose();
    _numeroCNIController.dispose();
    _dateNaissanceController.dispose();
    _adresseController.dispose();
    _numeroTelephoneController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(
        const Duration(days: 6570),
      ), // 18 ans
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateNaissanceController.text =
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      
      final result = await AuthService.register(
        _nomController.text.trim(),
        _prenomController.text.trim(),
        _emailController.text.trim(),
        _motDePasseController.text,
        _numeroCNIController.text.trim(),
        _dateNaissanceController.text,
        _adresseController.text.trim(),
        _numeroTelephoneController.text.trim(),
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        if (result['success'] == true) {
          // Afficher un message de succès
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] as String),
              backgroundColor: Colors.green,
            ),
          );

          // Notifier le parent que la connexion a réussi
          widget.onLoginSuccess();
        } else {
          // Afficher l'erreur
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] as String),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur d\'inscription: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Inscription'),
        backgroundColor: kSenelecBlue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),

                // Logo et titre
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: kSenelecBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/images/logo.png',
                        width: 60,
                        height: 60,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Créer un compte',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: kSenelecBlue,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Rejoignez SENELEC',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Formulaire d'inscription
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Informations personnelles',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Remplissez les informations ci-dessous',
                          style: TextStyle(fontSize: 13, color: Colors.grey),
                        ),
                        const SizedBox(height: 20),

                        // Champ Nom
                        TextFormField(
                          controller: _nomController,
                          keyboardType: TextInputType.name,
                          decoration: InputDecoration(
                            labelText: 'Nom',
                            hintText: 'Votre nom de famille',
                            hintStyle: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                            ),
                            prefixIcon: const Icon(Icons.person),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: kSenelecBlue),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez saisir votre nom';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 12),

                        // Champ Prénom
                        TextFormField(
                          controller: _prenomController,
                          keyboardType: TextInputType.name,
                          decoration: InputDecoration(
                            labelText: 'Prénom',
                            hintText: 'Votre prénom',
                            hintStyle: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                            ),
                            prefixIcon: const Icon(Icons.person_outline),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: kSenelecBlue),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez saisir votre prénom';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 12),

                        // Champ Email
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            hintText: 'votre@email.com',
                            hintStyle: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                            ),
                            prefixIcon: const Icon(Icons.email),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: kSenelecBlue),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez saisir votre email';
                            }
                            if (!RegExp(
                              r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                            ).hasMatch(value)) {
                              return 'Veuillez saisir un email valide';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 12),

                        // Champ Mot de passe
                        TextFormField(
                          controller: _motDePasseController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: 'Mot de passe',
                            hintText: 'Votre mot de passe',
                            hintStyle: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                            ),
                            prefixIcon: const Icon(Icons.lock),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: kSenelecBlue),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez saisir votre mot de passe';
                            }
                            if (value.length < 6) {
                              return 'Le mot de passe doit contenir au moins 6 caractères';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 12),

                        // Champ Numéro de CNI
                        TextFormField(
                          controller: _numeroCNIController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Numéro de CNI',
                            hintText: 'Entrez votre numéro de CNI',
                            hintStyle: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                            ),
                            prefixIcon: const Icon(Icons.credit_card),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: kSenelecBlue),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez saisir votre numéro de CNI';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 12),

                        // Champ Date de naissance
                        TextFormField(
                          controller: _dateNaissanceController,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            labelText: 'Date de naissance',
                            hintText: 'jj/mm/aaaa',
                            hintStyle: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                            ),
                            prefixIcon: const Icon(Icons.date_range),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: kSenelecBlue),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez saisir votre date de naissance';
                            }
                            return null;
                          },
                          onTap: _selectDate,
                        ),

                        const SizedBox(height: 12),

                        // Champ Adresse
                        TextFormField(
                          controller: _adresseController,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            labelText: 'Adresse',
                            hintText: 'Entrez votre adresse',
                            hintStyle: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                            ),
                            prefixIcon: const Icon(Icons.location_on),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: kSenelecBlue),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez saisir votre adresse';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 12),

                        // Champ Numéro de téléphone
                        TextFormField(
                          controller: _numeroTelephoneController,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            labelText: 'Numéro de téléphone',
                            hintText: 'Entrez votre numéro de téléphone',
                            hintStyle: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                            ),
                            prefixIcon: const Icon(Icons.phone),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: kSenelecBlue),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez saisir votre numéro de téléphone';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 20),

                        // Bouton d'inscription
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _register,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kSenelecBlue,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child:
                                _isLoading
                                    ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                    )
                                    : const Text(
                                      'S\'inscrire',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Lien vers la connexion
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Déjà un compte ? ',
                              style: TextStyle(color: Colors.grey),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text(
                                'Se connecter',
                                style: TextStyle(
                                  color: kSenelecBlue,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
