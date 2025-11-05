import 'package:flutter/material.dart';
import '../services/storage_service.dart';

/// Écran de gestion des joueurs avec thématisation complète.
///
/// Cette version introduit un fond d’écran, un filtre visuel et un design
/// homogène avec le reste du projet pour renforcer l’immersion.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _username = TextEditingController();
  final StorageService _storage = StorageService();
  List<String> _players = [];

  @override
  void initState() {
    super.initState();
    _loadPlayers();
  }

  /// Chargement initial des joueurs depuis le stockage local
  void _loadPlayers() async {
    final list = await _storage.getPlayers();
    setState(() {
      _players = list;
    });
  }

  /// Création d’un nouveau joueur
  void _createPlayer() async {
    if (_formKey.currentState!.validate()) {
      await _storage.addPlayer(_username.text);
      if (!mounted) return;
      Navigator.pushNamed(context, '/profile', arguments: _username.text);
    }
  }

  /// Chargement d’un joueur existant
  void _loadPlayer(String name) {
    Navigator.pushNamed(context, '/profile', arguments: name);
  }

  /// Suppression d’un joueur
  void _deletePlayer(String name) async {
    await _storage.deletePlayer(name);
    _loadPlayers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Pas d’AppBar : affichage plein écran pour l’immersion
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/bg.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          // Filtre semi-transparent pour lisibilité
          color: Colors.black.withOpacity(0.4),
          child: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 20),

                // Titre principal
                const Text(
                  'Créer ou Charger une partie',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        blurRadius: 6,
                        color: Colors.black87,
                        offset: Offset(2, 2),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 20),

                // Zone principale scrollable
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Formulaire de création
                        const Text(
                          'Créer une nouvelle partie',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 10),

                        Form(
                          key: _formKey,
                          child: Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _username,
                                  decoration: InputDecoration(
                                    labelText: 'Nom du joueur',
                                    labelStyle:
                                        const TextStyle(color: Colors.white70),
                                    filled: true,
                                    fillColor: Colors.black26,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  style: const TextStyle(color: Colors.white),
                                  validator: (value) => value == null ||
                                          value.isEmpty
                                      ? 'Entrez un pseudo'
                                      : null,
                                ),
                              ),
                              const SizedBox(width: 10),
                              ElevatedButton.icon(
                                onPressed: _createPlayer,
                                icon: const Icon(Icons.add),
                                label: const Text('Créer'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.tealAccent[700],
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 30),
                        const Divider(color: Colors.white70),
                        const SizedBox(height: 10),

                        // Liste des parties existantes
                        const Text(
                          'Parties existantes',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 10),

                        if (_players.isEmpty)
                          const Padding(
                            padding: EdgeInsets.only(bottom: 20),
                            child: Text(
                              'Aucune partie sauvegardée.',
                              style: TextStyle(color: Colors.white70),
                            ),
                          )
                        else
                          ListView.builder(
                            shrinkWrap: true,
                            physics:
                                const NeverScrollableScrollPhysics(),
                            itemCount: _players.length,
                            itemBuilder: (context, index) {
                              final player = _players[index];
                              return Card(
                                color: Colors.white.withOpacity(0.9),
                                elevation: 3,
                                margin:
                                    const EdgeInsets.symmetric(vertical: 6),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: ListTile(
                                  leading: const Icon(Icons.person,
                                      color: Colors.teal),
                                  title: Text(
                                    player,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600),
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.play_arrow,
                                            color: Colors.green),
                                        onPressed: () => _loadPlayer(player),
                                        tooltip: 'Charger la partie',
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete,
                                            color: Colors.redAccent),
                                        onPressed: () => _deletePlayer(player),
                                        tooltip: 'Supprimer',
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        const SizedBox(height: 40),
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

