import 'package:flutter/material.dart';
import 'package:app_gestion/theme/colors.dart';
import 'package:app_gestion/repositories/demandes_repository.dart';
import 'package:app_gestion/services/api_service.dart'; // Added import for ApiService

class NouvelAbonnementScreen extends StatefulWidget {
  const NouvelAbonnementScreen({super.key});

  @override
  State<NouvelAbonnementScreen> createState() => _NouvelAbonnementScreenState();
}

class _NouvelAbonnementScreenState extends State<NouvelAbonnementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _adresseController = TextEditingController();
  final _puissanceController = TextEditingController();

  String _selectedType = 'abonnement';
  bool _isLoading = false;

  final List<String> _types = ['abonnement', 'modification', 'resiliation'];

  final List<String> _puissances = [
    '3 kW',
    '6 kW',
    '9 kW',
    '12 kW',
    '15 kW',
    '18 kW',
    '21 kW',
    '24 kW',
  ];

  @override
  void dispose() {
    _descriptionController.dispose();
    _adresseController.dispose();
    _puissanceController.dispose();
    super.dispose();
  }

  Future<void> _submitDemande() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final description =
          '''
Type: ${_getTypeDisplay(_selectedType)}
Adresse: ${_adresseController.text}
Puissance: ${_puissanceController.text}

Description: ${_descriptionController.text}
      '''.trim();

      await ApiService.creerDemande({
        'type': _selectedType,
        'description': description,
        // 'piecesJointes': ... // à ajouter si besoin
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Demande d\'abonnement créée avec succès !'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true); // Retour avec succès
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _getTypeDisplay(String type) {
    switch (type) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Nouvel Abonnement'),
        backgroundColor: kSenelecBlue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: kSenelecBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: kSenelecBlue.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.add_circle,
                        color: kSenelecBlue,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Nouvelle demande',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: kSenelecBlue,
                            ),
                          ),
                          Text(
                            'Remplissez les informations ci-dessous',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Type de demande
              const Text(
                'Type de demande',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: InputDecoration(
                  labelText: 'Sélectionnez le type',
                  hintText: 'Choisissez le type de demande',
                  prefixIcon: const Icon(Icons.category),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: kSenelecBlue),
                  ),
                ),
                items:
                    _types.map((String type) {
                      return DropdownMenuItem<String>(
                        value: type,
                        child: Text(_getTypeDisplay(type)),
                      );
                    }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedType = newValue!;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez sélectionner un type';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // Adresse
              const Text(
                'Adresse d\'installation',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _adresseController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Adresse complète',
                  hintText: 'Entrez l\'adresse d\'installation',
                  prefixIcon: const Icon(Icons.location_on),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: kSenelecBlue),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez saisir l\'adresse';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // Puissance
              const Text(
                'Puissance souhaitée',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value:
                    _puissanceController.text.isEmpty
                        ? null
                        : _puissanceController.text,
                decoration: InputDecoration(
                  labelText: 'Sélectionnez la puissance',
                  hintText: 'Choisissez la puissance',
                  prefixIcon: const Icon(Icons.electric_bolt),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: kSenelecBlue),
                  ),
                ),
                items:
                    _puissances.map((String puissance) {
                      return DropdownMenuItem<String>(
                        value: puissance,
                        child: Text(puissance),
                      );
                    }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _puissanceController.text = newValue ?? '';
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez sélectionner une puissance';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // Description
              const Text(
                'Description détaillée',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: 'Description',
                  hintText: 'Décrivez votre demande en détail...',
                  prefixIcon: const Icon(Icons.description),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: kSenelecBlue),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez saisir une description';
                  }
                  if (value.length < 10) {
                    return 'La description doit contenir au moins 10 caractères';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 32),

              // Bouton de soumission
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitDemande,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kSenelecBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                  ),
                  child:
                      _isLoading
                          ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                          : const Text(
                            'Soumettre la demande',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                ),
              ),

              const SizedBox(height: 16),

              // Informations supplémentaires
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.blue.shade700,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Informations importantes',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '• Votre demande sera examinée par nos services\n'
                      '• Vous recevrez une notification une fois traitée\n'
                      '• Le délai de traitement est de 3 à 5 jours ouvrables\n'
                      '• Vous pouvez suivre l\'avancement dans "Mes Abonnements"',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.blue.shade700,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
