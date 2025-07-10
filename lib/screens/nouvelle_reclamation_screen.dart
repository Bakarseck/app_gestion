import 'package:flutter/material.dart';
import 'package:app_gestion/theme/colors.dart';
import 'package:app_gestion/repositories/reclamations_repository.dart';
import 'package:app_gestion/services/api_service.dart'; // Added import for ApiService

class NouvelleReclamationScreen extends StatefulWidget {
  const NouvelleReclamationScreen({super.key});

  @override
  State<NouvelleReclamationScreen> createState() =>
      _NouvelleReclamationScreenState();
}

class _NouvelleReclamationScreenState extends State<NouvelleReclamationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _objetController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _adresseController = TextEditingController();

  String _selectedCategorie = 'Coupure';
  bool _isLoading = false;

  final List<String> _categories = [
    'Coupure',
    'Compteur',
    'Facturation',
    'Installation',
    'Autre',
  ];

  @override
  void dispose() {
    _objetController.dispose();
    _descriptionController.dispose();
    _adresseController.dispose();
    super.dispose();
  }

  Future<void> _submitReclamation() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final description =
          '''
Catégorie: $_selectedCategorie
Adresse: ${_adresseController.text}

Description: ${_descriptionController.text}
      '''.trim();

      await ApiService.creerReclamation({
        'objet': _objetController.text,
        'description': description,
        // 'categorie': _selectedCategorie, // à ajouter si le backend le gère
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Réclamation créée avec succès !'),
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

  String _getPriorite(String categorie) {
    switch (categorie.toLowerCase()) {
      case 'coupure':
        return 'Haute';
      case 'compteur':
      case 'facturation':
        return 'Moyenne';
      default:
        return 'Basse';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Nouvelle Réclamation'),
        backgroundColor: kSenelecViolet,
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
                  color: kSenelecViolet.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: kSenelecViolet.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.report_problem,
                        color: kSenelecViolet,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Nouvelle réclamation',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: kSenelecViolet,
                            ),
                          ),
                          Text(
                            'Décrivez votre problème en détail',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Objet de la réclamation
              const Text(
                'Objet de la réclamation',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _objetController,
                decoration: InputDecoration(
                  labelText: 'Titre de la réclamation',
                  hintText: 'Ex: Coupure de courant, Problème de compteur...',
                  prefixIcon: const Icon(Icons.title),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: kSenelecViolet),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez saisir l\'objet de la réclamation';
                  }
                  if (value.length < 5) {
                    return 'L\'objet doit contenir au moins 5 caractères';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // Catégorie
              const Text(
                'Catégorie',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedCategorie,
                decoration: InputDecoration(
                  labelText: 'Sélectionnez la catégorie',
                  hintText: 'Choisissez la catégorie',
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
                    borderSide: const BorderSide(color: kSenelecViolet),
                  ),
                ),
                items:
                    _categories.map((String categorie) {
                      return DropdownMenuItem<String>(
                        value: categorie,
                        child: Row(
                          children: [
                            Text(categorie),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    _getPriorite(categorie) == 'Haute'
                                        ? Colors.red.withOpacity(0.1)
                                        : _getPriorite(categorie) == 'Moyenne'
                                        ? Colors.orange.withOpacity(0.1)
                                        : Colors.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                _getPriorite(categorie),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      _getPriorite(categorie) == 'Haute'
                                          ? Colors.red
                                          : _getPriorite(categorie) == 'Moyenne'
                                          ? Colors.orange
                                          : Colors.green,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedCategorie = newValue!;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez sélectionner une catégorie';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // Adresse
              const Text(
                'Adresse concernée',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _adresseController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Adresse complète',
                  hintText: 'Entrez l\'adresse concernée par le problème',
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
                    borderSide: const BorderSide(color: kSenelecViolet),
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

              // Description
              const Text(
                'Description détaillée',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                maxLines: 6,
                decoration: InputDecoration(
                  labelText: 'Description du problème',
                  hintText:
                      'Décrivez votre problème en détail...\n\nExemples:\n• Quand le problème a-t-il commencé ?\n• Quels sont les symptômes observés ?\n• Avez-vous déjà contacté nos services ?',
                  prefixIcon: const Icon(Icons.description),
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: kSenelecViolet),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez saisir une description';
                  }
                  if (value.length < 20) {
                    return 'La description doit contenir au moins 20 caractères';
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
                  onPressed: _isLoading ? null : _submitReclamation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kSenelecViolet,
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
                            'Soumettre la réclamation',
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
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.orange.shade700,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Informations importantes',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '• Les réclamations urgentes (coupures) sont traitées en priorité\n'
                      '• Vous recevrez une notification une fois traitée\n'
                      '• Un technicien peut être envoyé sur place si nécessaire\n'
                      '• Vous pouvez suivre l\'avancement dans "Mes Réclamations"',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.orange.shade700,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Urgences
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.emergency,
                          color: Colors.red.shade700,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Urgences',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.red.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'En cas d\'urgence (danger immédiat, incendie électrique), appelez directement le service d\'urgence au 33 839 33 33',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.red.shade700,
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
