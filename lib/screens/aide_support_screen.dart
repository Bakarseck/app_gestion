import 'package:flutter/material.dart';
import 'package:app_gestion/theme/colors.dart';

class AideSupportScreen extends StatefulWidget {
  const AideSupportScreen({super.key});

  @override
  State<AideSupportScreen> createState() => _AideSupportScreenState();
}

class _AideSupportScreenState extends State<AideSupportScreen> {
  final List<Map<String, dynamic>> _faqItems = [
    {
      'question': 'Comment créer un nouvel abonnement ?',
      'reponse':
          'Allez dans "Mes Abonnements" et cliquez sur le bouton "+" ou "Nouvel Abonnement". Remplissez le formulaire avec vos informations et soumettez votre demande.',
    },
    {
      'question': 'Comment signaler un problème ?',
      'reponse':
          'Allez dans "Mes Réclamations" et cliquez sur "Nouvelle Réclamation". Décrivez votre problème en détail et soumettez votre réclamation.',
    },
    {
      'question': 'Combien de temps pour traiter une demande ?',
      'reponse':
          'Les demandes d\'abonnement sont traitées sous 3 à 5 jours ouvrables. Les réclamations urgentes (coupures) sont traitées en priorité.',
    },
    {
      'question': 'Comment suivre l\'avancement de ma demande ?',
      'reponse':
          'Vous pouvez suivre l\'avancement dans les sections "Mes Abonnements" et "Mes Réclamations". Vous recevrez également des notifications.',
    },
    {
      'question': 'Que faire en cas d\'urgence ?',
      'reponse':
          'En cas d\'urgence (danger immédiat, incendie électrique), appelez directement le service d\'urgence au 33 839 33 33.',
    },
    {
      'question': 'Comment modifier mes informations personnelles ?',
      'reponse':
          'Allez dans "Paramètres" puis "Profil" pour modifier vos informations personnelles.',
    },
  ];

  final List<Map<String, dynamic>> _contacts = [
    {
      'titre': 'Service Client',
      'numero': '33 839 33 33',
      'description': 'Pour toutes vos questions générales',
      'icon': Icons.phone,
      'color': Colors.green,
    },
    {
      'titre': 'Urgences',
      'numero': '33 839 33 33',
      'description': 'En cas de danger immédiat',
      'icon': Icons.emergency,
      'color': Colors.red,
    },
    {
      'titre': 'Support Technique',
      'numero': '33 839 33 34',
      'description': 'Problèmes techniques avec l\'application',
      'icon': Icons.support_agent,
      'color': Colors.blue,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Aide & Support'),
        backgroundColor: kSenelecBlue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête
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
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.help_outline,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Besoin d\'aide ?',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Nous sommes là pour vous aider',
                          style: TextStyle(fontSize: 14, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Contacts d'urgence
            const Text(
              'Contacts d\'urgence',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: kSenelecBlue,
              ),
            ),
            const SizedBox(height: 12),

            ..._contacts.map((contact) => _buildContactCard(contact)),

            const SizedBox(height: 32),

            // FAQ
            const Text(
              'Questions fréquentes',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: kSenelecBlue,
              ),
            ),
            const SizedBox(height: 12),

            ..._faqItems.map((faq) => _buildFAQCard(faq)),

            const SizedBox(height: 32),

            // Guides utiles
            const Text(
              'Guides utiles',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: kSenelecBlue,
              ),
            ),
            const SizedBox(height: 12),

            _buildGuideCard(
              'Guide d\'utilisation',
              'Apprenez à utiliser toutes les fonctionnalités de l\'application',
              Icons.book,
              Colors.blue,
              () {
                // TODO: Ouvrir le guide d'utilisation
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Guide d\'utilisation bientôt disponible'),
                  ),
                );
              },
            ),

            const SizedBox(height: 12),

            _buildGuideCard(
              'Sécurité électrique',
              'Conseils pour une utilisation sûre de l\'électricité',
              Icons.security,
              Colors.orange,
              () {
                // TODO: Ouvrir le guide de sécurité
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Guide de sécurité bientôt disponible'),
                  ),
                );
              },
            ),

            const SizedBox(height: 12),

            _buildGuideCard(
              'Facturation',
              'Comprendre votre facture d\'électricité',
              Icons.receipt,
              Colors.green,
              () {
                // TODO: Ouvrir le guide de facturation
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Guide de facturation bientôt disponible'),
                  ),
                );
              },
            ),

            const SizedBox(height: 32),

            // Informations supplémentaires
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: kSenelecBlue, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Informations importantes',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: kSenelecBlue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• Horaires de service : Lundi-Vendredi 8h-18h\n'
                    '• Service d\'urgence disponible 24h/24\n'
                    '• Temps de réponse moyen : 2-4 heures\n'
                    '• Vous pouvez également nous contacter via notre site web',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade700,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard(Map<String, dynamic> contact) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: contact['color'].withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            contact['icon'],
            color: contact['color'],
            size: 24,
          ),
        ),
        title: Text(
          contact['titre'],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(contact['description']),
            const SizedBox(height: 8),
            Text(
              contact['numero'],
              style: TextStyle(
                color: contact['color'],
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
        trailing: IconButton(
          icon: Icon(Icons.phone, color: contact['color']),
          onPressed: () => _showCallDialog(contact['numero'], contact['titre']),
        ),
      ),
    );
  }

  Widget _buildFAQCard(Map<String, dynamic> faq) {
    return ExpansionTile(
      title: Text(
        faq['question'],
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            faq['reponse'],
            style: TextStyle(
              color: Colors.grey.shade700,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGuideCard(
    String title,
    String description,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(description),
        trailing: Icon(Icons.arrow_forward_ios, color: color),
        onTap: onTap,
      ),
    );
  }

  void _showCallDialog(String number, String service) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Appeler $service'),
          content: Text('Voulez-vous appeler le $service au $number ?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Appel vers $number...'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: kSenelecBlue,
                foregroundColor: Colors.white,
              ),
              child: const Text('Appeler'),
            ),
          ],
        );
      },
    );
  }
}
