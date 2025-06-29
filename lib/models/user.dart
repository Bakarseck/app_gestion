class User {
  final String id;
  final String name;
  final String email;
  final String role;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    // Gestion de différents formats possibles de l'API
    String id = '';
    String name = '';
    String email = '';
    String role = '';

    // ID
    id = json['ID']?.toString() ?? json['id']?.toString() ?? '';

    // Nom complet (nom + prénom)
    final nom = json['nom'] ?? '';
    final prenom = json['prenom'] ?? '';
    name = '$prenom $nom'.trim();
    if (name.isEmpty) {
      name = json['name'] ?? '';
    }

    // Email
    email = json['email'] ?? '';

    // Rôle
    role = json['role'] ?? '';

    return User(id: id, name: name, email: email, role: role);
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'email': email, 'role': role};
  }
}
