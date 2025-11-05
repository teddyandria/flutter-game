import 'package:shared_preferences/shared_preferences.dart';

/// Service de gestion du stockage local des joueurs.
///
/// Cette classe encapsule toutes les opérations de lecture et d’écriture
/// concernant la liste des joueurs. Les données sont sauvegardées
/// de manière persistante grâce à l’API SharedPreferences.
class StorageService {
  // Clé d’identification utilisée pour sauvegarder les joueurs
  static const _keyPlayers = 'players';

  /// Récupère la liste des joueurs enregistrés localement
  Future<List<String>> getPlayers() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_keyPlayers) ?? [];
  }

  /// Ajoute un joueur s’il n’existe pas déjà
  Future<void> addPlayer(String name) async {
    final prefs = await SharedPreferences.getInstance();
    final players = prefs.getStringList(_keyPlayers) ?? [];
    if (!players.contains(name)) {
      players.add(name);
      await prefs.setStringList(_keyPlayers, players);
    }
  }

  /// Supprime un joueur existant de la liste
  Future<void> deletePlayer(String name) async {
    final prefs = await SharedPreferences.getInstance();
    final players = prefs.getStringList(_keyPlayers) ?? [];
    players.remove(name);
    await prefs.setStringList(_keyPlayers, players);
  }

  /// Supprime toutes les données liées aux joueurs
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyPlayers);
  }
}

