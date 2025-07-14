# Processus d'Assignation et Gestion des Statuts par les Admins

## Vue d'ensemble

Ce document décrit le processus complet pour permettre aux administrateurs d'assigner des techniciens aux demandes (abonnements et réclamations) et de mettre à jour leurs statuts depuis le dashboard admin.

## Flux Utilisateur

### 1. Interface Utilisateur (Frontend Flutter)

#### Déclenchement
- L'admin accède à son dashboard (`admin_dashboard.dart`)
- Dans la liste des demandes/réclamations, chaque item affiche un menu contextuel (trois points)
- L'admin clique sur "Assigner technicien" dans le menu

#### Dialog d'Assignation
```dart
// Interface d'assignation de technicien
AlertDialog(
  title: Text('Assigner un technicien'),
  content: Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      // Dropdown pour sélectionner le technicien
      DropdownButtonFormField<int>(
        value: selectedTechnicianId,
        decoration: InputDecoration(
          labelText: 'Sélectionner un technicien',
          border: OutlineInputBorder(),
        ),
        items: technicians.map((tech) {
          return DropdownMenuItem(
            value: tech['id'],
            child: Text(tech['nom']),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            selectedTechnicianId = value;
          });
        },
      ),
      SizedBox(height: 16),
      // Dropdown pour le statut
      DropdownButtonFormField<String>(
        value: selectedStatus,
        decoration: InputDecoration(
          labelText: 'Statut',
          border: OutlineInputBorder(),
        ),
        items: [
          DropdownMenuItem(value: 'ouvert', child: Text('Ouvert')),
          DropdownMenuItem(value: 'en_cours', child: Text('En cours')),
          DropdownMenuItem(value: 'bloque', child: Text('Bloqué')),
          DropdownMenuItem(value: 'ferme', child: Text('Fermé')),
        ],
        onChanged: (value) {
          setState(() {
            selectedStatus = value;
          });
        },
      ),
    ],
  ),
  actions: [
    TextButton(
      onPressed: () => Navigator.pop(),
      child: Text('Annuler'),
    ),
    ElevatedButton(
      onPressed: () => _assignTechnician(),
      child: Text('Assigner'),
    ),
  ],
)
```

### 2. Appel API (Frontend)

#### Méthode d'Assignation
```dart
// Dans ApiService.assignTechnician()
final result = await ApiService.assignTechnician(
  task.id.toString(),           // ID de la demande
  selectedTechnicianId.toString(), // ID du technicien
  selectedStatus,               // Nouveau statut
  type: task.type,              // 'abonnement' ou 'reclamation'
);
```

#### Logique de Sélection d'Endpoint
```dart
// Dans ApiService.assignTechnician()
String endpoint;
if (type == 'abonnement') {
  endpoint = '/api/demandes/$id/assign';
} else if (type == 'reclamation') {
  endpoint = '/api/claims/$id/assign';
}

// Requête HTTP PUT
final response = await http.put(
  Uri.parse('$baseUrl$endpoint'),
  headers: {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
  },
  body: jsonEncode({
    'technicien_id': technicienId,
    'statut': statut,
  }),
);
```

## Endpoints Backend Requis

### 1. Pour les Abonnements
```
PUT /api/demandes/{id}/assign
```

#### Headers Requis
```
Content-Type: application/json
Authorization: Bearer {token}
```

#### Body JSON
```json
{
  "technicien_id": 123,
  "statut": "en_cours"
}
```

#### Réponse Succès (200)
```json
{
  "success": true,
  "message": "Technicien assigné avec succès",
  "data": {
    "id": 456,
    "client_id": 789,
    "type": "abonnement",
    "statut": "en_cours",
    "technicien_id": 123,
    "description": "Installation complète pour nouvelle construction",
    "dateSoumission": "2024-01-15T10:30:00Z",
    "created_at": "2024-01-15T10:30:00Z",
    "updated_at": "2024-01-15T10:30:00Z"
  }
}
```

#### Réponse Erreur (400/401/404)
```json
{
  "success": false,
  "message": "Erreur: [description de l'erreur]"
}
```

### 2. Pour les Réclamations
```
PUT /api/claims/{id}/assign
```

#### Headers Requis
```
Content-Type: application/json
Authorization: Bearer {token}
```

#### Body JSON
```json
{
  "technicien_id": 123,
  "statut": "en_cours"
}
```

#### Réponse Succès (200)
```json
{
  "success": true,
  "message": "Technicien assigné avec succès",
  "data": {
    "id": 457,
    "client_id": 790,
    "type": "reclamation",
    "statut": "en_cours",
    "technicien_id": 123,
    "description": "Coupure de courant depuis 3 heures",
    "dateSoumission": "2024-01-15T10:30:00Z",
    "created_at": "2024-01-15T10:30:00Z",
    "updated_at": "2024-01-15T10:30:00Z"
  }
}
```

## Logique Backend Requise

### 1. Validation
- Vérifier que l'utilisateur est authentifié (token valide)
- Vérifier que l'utilisateur est un administrateur
- Vérifier que la demande/réclamation existe
- Vérifier que le technicien existe et est bien un technicien
- Vérifier que le statut est valide
- Vérifier que les données ne sont pas vides

### 2. Base de Données

#### Mise à Jour des Tables Existantes
```sql
-- Table demandes (abonnements)
ALTER TABLE demandes 
ADD COLUMN technicien_id INT NULL,
ADD COLUMN statut VARCHAR(20) DEFAULT 'ouvert',
ADD FOREIGN KEY (technicien_id) REFERENCES users(id);

-- Table claims (réclamations)
ALTER TABLE claims 
ADD COLUMN technicien_id INT NULL,
ADD COLUMN statut VARCHAR(20) DEFAULT 'ouvert',
ADD FOREIGN KEY (technicien_id) REFERENCES users(id);
```

#### Table des Statuts Valides
```sql
CREATE TABLE statuts_valides (
  id INT PRIMARY KEY AUTO_INCREMENT,
  nom VARCHAR(20) NOT NULL UNIQUE,
  description TEXT,
  couleur VARCHAR(7) DEFAULT '#000000',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO statuts_valides (nom, description, couleur) VALUES
('ouvert', 'Demande ouverte en attente', '#007bff'),
('en_cours', 'Demande en cours de traitement', '#ffc107'),
('bloque', 'Demande bloquée', '#dc3545'),
('ferme', 'Demande fermée/résolue', '#28a745');
```

### 3. Algorithme de Traitement

```php
// Pseudo-code pour le traitement
function assignTechnician($requestId, $technicienId, $statut, $type) {
    // 1. Validation de l'authentification
    $user = getAuthenticatedUser();
    if (!$user || $user->role !== 'admin') {
        return errorResponse('Accès non autorisé', 401);
    }
    
    // 2. Validation de la demande/réclamation
    if ($type === 'abonnement') {
        $item = Demande::find($requestId);
        $table = 'demandes';
    } else {
        $item = Claim::find($requestId);
        $table = 'claims';
    }
    
    if (!$item) {
        return errorResponse('Demande/Réclamation non trouvée', 404);
    }
    
    // 3. Validation du technicien
    $technicien = User::where('id', $technicienId)
                     ->where('role', 'technicien')
                     ->first();
    
    if (!$technicien) {
        return errorResponse('Technicien non trouvé ou invalide', 404);
    }
    
    // 4. Validation du statut
    $statutsValides = ['ouvert', 'en_cours', 'bloque', 'ferme'];
    if (!in_array($statut, $statutsValides)) {
        return errorResponse('Statut invalide', 400);
    }
    
    // 5. Mise à jour de la demande/réclamation
    $updateData = [
        'technicien_id' => $technicienId,
        'statut' => $statut,
        'updated_at' => now()
    ];
    
    $updated = DB::table($table)
                 ->where('id', $requestId)
                 ->update($updateData);
    
    if (!$updated) {
        return errorResponse('Erreur lors de la mise à jour', 500);
    }
    
    // 6. Récupérer les données mises à jour
    $updatedItem = DB::table($table)->where('id', $requestId)->first();
    
    // 7. Retour de la réponse
    return successResponse('Technicien assigné avec succès', $updatedItem);
}
```

## Gestion des Erreurs

### Codes d'Erreur HTTP
- **400 Bad Request**: Données invalides (statut invalide, technicien invalide)
- **401 Unauthorized**: Token manquant ou invalide
- **403 Forbidden**: Utilisateur non-admin
- **404 Not Found**: Demande/réclamation ou technicien inexistant
- **500 Internal Server Error**: Erreur serveur

### Messages d'Erreur Utilisateur
- "Vous devez être administrateur pour effectuer cette action"
- "Demande/Réclamation non trouvée"
- "Technicien non trouvé ou invalide"
- "Statut invalide"
- "Erreur lors de l'assignation"

## Sécurité

### Vérifications Obligatoires
1. **Authentification**: Token JWT valide
2. **Autorisation**: Utilisateur doit être administrateur
3. **Validation des Données**: Technicien et statut valides
4. **Intégrité**: Vérification de l'existence des entités
5. **Sanitisation**: Nettoyer les données d'entrée

### Protection contre les Attaques
- Validation des entrées utilisateur
- Protection contre les injections SQL
- Vérification des permissions
- Rate limiting pour éviter le spam

## Tests Recommandés

### Tests Unitaires
- Validation des données d'entrée
- Vérification des permissions admin
- Gestion des erreurs de validation

### Tests d'Intégration
- Assignation de technicien sur abonnement
- Assignation de technicien sur réclamation
- Mise à jour de statut avec assignation
- Tentative d'assignation par un utilisateur non-admin
- Tentative avec un technicien inexistant

### Tests de Performance
- Temps de réponse < 500ms
- Gestion de plusieurs assignations simultanées

## Intégration avec le Frontend

### Feedback Utilisateur
- Message de succès avec SnackBar vert
- Message d'erreur avec SnackBar rouge
- Indicateur de chargement pendant l'opération
- Rechargement automatique des données après succès

### États de l'Interface
1. **Initial**: Menu contextuel disponible
2. **Sélection**: Dialog ouvert avec dropdowns
3. **Validation**: Vérification des champs requis
4. **Envoi**: Bouton désactivé, indicateur de chargement
5. **Succès**: Message de confirmation, fermeture dialog
6. **Erreur**: Message d'erreur, dialog reste ouvert

## Fonctionnalités Supplémentaires

### 1. Récupération des Techniciens
```
GET /api/techniciens
```

#### Réponse
```json
{
  "success": true,
  "data": [
    {
      "id": 123,
      "nom": "Jean Dupont",
      "email": "jean.dupont@senelec.sn",
      "telephone": "+221 77 123 45 67",
      "specialite": "Électricité",
      "disponibilite": true
    }
  ]
}
```

### 2. Historique des Assignations
```sql
CREATE TABLE assignation_history (
  id INT PRIMARY KEY AUTO_INCREMENT,
  demande_id INT NULL,
  claim_id INT NULL,
  technicien_id INT NOT NULL,
  admin_id INT NOT NULL,
  statut_avant VARCHAR(20),
  statut_apres VARCHAR(20),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (technicien_id) REFERENCES users(id),
  FOREIGN KEY (admin_id) REFERENCES users(id)
);
```

### 3. Notifications
- Notification par email au technicien assigné
- Notification par SMS (optionnel)
- Notification push dans l'application

## Notes d'Implémentation

### Priorités
1. **Haute**: Endpoints d'assignation fonctionnels
2. **Moyenne**: Gestion des erreurs et validation
3. **Basse**: Historique et notifications

### Compatibilité
- Compatible avec l'API existante
- Respect des conventions de nommage
- Intégration avec le système d'authentification existant

### Évolutivité
- Support pour les équipes de techniciens
- Gestion des priorités
- Système de rotation automatique
- Intégration avec un système de géolocalisation

## Workflow Complet

### 1. Processus d'Assignation
1. Admin ouvre le dashboard
2. Admin sélectionne une demande/réclamation
3. Admin clique sur "Assigner technicien"
4. Dialog s'ouvre avec liste des techniciens disponibles
5. Admin sélectionne un technicien et un statut
6. Admin valide l'assignation
7. API traite la demande
8. Demande/réclamation mise à jour
9. Technicien notifié de sa nouvelle tâche

### 2. Gestion des Statuts
- **Ouvert**: Demande créée, en attente d'assignation
- **En cours**: Technicien assigné, intervention en cours
- **Bloqué**: Problème rencontré, intervention suspendue
- **Fermé**: Intervention terminée, demande résolue

### 3. Règles Métier
- Seuls les admins peuvent assigner des techniciens
- Un technicien peut être assigné à plusieurs tâches
- Le statut peut être modifié lors de l'assignation
- L'historique des assignations est conservé 