import 'package:bonfire/bonfire.dart';

/// Classe utilitaire pour tester différentes configurations du sprite sheet Serek
/// Utilisez cette classe pour identifier quelle ligne correspond à quelle direction
class SerekSpriteSheetTest {
  
  // Test avec configuration alternative 1 : ordre différent
  static SimpleDirectionAnimation testConfig1() => SimpleDirectionAnimation(
        idleDown: _loadAnimation(0),   // Ligne 0
        idleLeft: _loadAnimation(16),  // Ligne 1
        idleRight: _loadAnimation(32), // Ligne 2
        idleUp: _loadAnimation(48),    // Ligne 3
        runDown: _loadAnimation(64),   // Ligne 4
        runLeft: _loadAnimation(80),   // Ligne 5
        runRight: _loadAnimation(96),  // Ligne 6
        runUp: _loadAnimation(112),    // Ligne 7
      );

  // Test avec configuration alternative 2 : si right et left sont inversés
  static SimpleDirectionAnimation testConfig2() => SimpleDirectionAnimation(
        idleDown: _loadAnimation(0),   // Ligne 0
        idleLeft: _loadAnimation(32),  // Ligne 2 (inversé)
        idleRight: _loadAnimation(16), // Ligne 1 (inversé)
        idleUp: _loadAnimation(48),    // Ligne 3
        runDown: _loadAnimation(64),   // Ligne 4
        runLeft: _loadAnimation(96),   // Ligne 6 (inversé)
        runRight: _loadAnimation(80),  // Ligne 5 (inversé)
        runUp: _loadAnimation(112),    // Ligne 7
      );

  // Test avec configuration alternative 3 : ordre down/up inversé
  static SimpleDirectionAnimation testConfig3() => SimpleDirectionAnimation(
        idleDown: _loadAnimation(48),  // Ligne 3 (inversé)
        idleLeft: _loadAnimation(16),  // Ligne 1
        idleRight: _loadAnimation(32), // Ligne 2
        idleUp: _loadAnimation(0),     // Ligne 0 (inversé)
        runDown: _loadAnimation(112),  // Ligne 7 (inversé)
        runLeft: _loadAnimation(80),   // Ligne 5
        runRight: _loadAnimation(96),  // Ligne 6
        runUp: _loadAnimation(64),     // Ligne 4 (inversé)
      );

  static Future<SpriteAnimation> _loadAnimation(double yPosition) {
    return SpriteAnimation.load(
      'player/Serek.png',
      SpriteAnimationData.sequenced(
        amount: 4,
        stepTime: 0.08,
        textureSize: Vector2(16, 16),
        texturePosition: Vector2(0, yPosition),
      ),
    );
  }
}
