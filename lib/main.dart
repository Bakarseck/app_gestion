import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.blue,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Senelec - Abonnement'),
        actions: [
          IconButton(
            icon: Icon(Icons.account_circle),
            onPressed: () {
              // Go to Profile Page
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // Header du drawer
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.blue, Colors.blue.shade700],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, size: 35, color: Colors.blue),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Bakar SECK',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Client Senelec',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),

            // Options du menu
            ListTile(
              leading: Icon(Icons.dashboard, color: Colors.blue),
              title: Text('Tableau de bord'),
              onTap: () {
                Navigator.pop(context); // Ferme le drawer
                // Navigation vers le tableau de bord
              },
            ),

            ListTile(
              leading: Icon(Icons.receipt, color: Colors.orange),
              title: Text('Mes factures'),
              onTap: () {
                Navigator.pop(context);
                // Navigation vers les factures
              },
            ),

            ListTile(
              leading: Icon(Icons.show_chart, color: Colors.green),
              title: Text('Consommation'),
              onTap: () {
                Navigator.pop(context);
                // Navigation vers la consommation
              },
            ),

            ListTile(
              leading: Icon(Icons.payment, color: Colors.purple),
              title: Text('Paiements'),
              onTap: () {
                Navigator.pop(context);
                // Navigation vers les paiements
              },
            ),

            ListTile(
              leading: Icon(Icons.history, color: Colors.grey),
              title: Text('Historique'),
              onTap: () {
                Navigator.pop(context);
                // Navigation vers l'historique
              },
            ),

            Divider(), // Séparateur

            ListTile(
              leading: Icon(Icons.settings, color: Colors.grey),
              title: Text('Paramètres'),
              onTap: () {
                Navigator.pop(context);
                // Navigation vers les paramètres
              },
            ),

            ListTile(
              leading: Icon(Icons.help, color: Colors.grey),
              title: Text('Aide'),
              onTap: () {
                Navigator.pop(context);
                // Navigation vers l'aide
              },
            ),

            Divider(), // Séparateur

            ListTile(
              leading: Icon(Icons.logout, color: Colors.red),
              title: Text('Déconnexion'),
              onTap: () {
                Navigator.pop(context);
                // Logique de déconnexion
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Déconnexion'),
                      content: Text(
                        'Êtes-vous sûr de vouloir vous déconnecter ?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('Annuler'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context); // Ferme le dialog
                            // Logique de déconnexion ici
                          },
                          child: Text(
                            'Déconnexion',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting and User Info
            Text(
              'Bakar SECK',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              'Abonnement Actif',
              style: TextStyle(fontSize: 16, color: Colors.green),
            ),

            SizedBox(height: 20),

            // Consumption Chart (Placeholder)
            Text(
              'Consommation mensuelle',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            Container(
              width: double.infinity,
              height: 200,
              color: Colors.blue[100],
              child: Center(
                child: Text(
                  'Graphique de consommation ici',
                  style: TextStyle(fontSize: 20, color: Colors.blue),
                ),
              ),
            ),

            SizedBox(height: 20),

            // Buttons for actions
            ElevatedButton(
              onPressed: () {
                // Handle Pay Bill action
              },
              child: Text('Payer la facture'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.yellow, // Button color
                foregroundColor: Colors.black, // Text color
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 100),
              ),
            ),

            SizedBox(height: 10),

            ElevatedButton(
              onPressed: () {
                // Handle Update Info action
              },
              child: Text('Mettre à jour les informations'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue, // Button color
                foregroundColor: Colors.white, // Text color
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 40),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
