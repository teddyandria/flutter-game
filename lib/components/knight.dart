import 'package:bonfire/bonfire.dart';
import '../util/player_sprite_sheet.dart';
import 'package:app/components/inventory/inventory.dart';

/// Classe représentant le joueur (Knight)
/// Gère les animations, collisions et inventaire.
class Knight extends SimplePlayer with BlockMovementCollision {
  // --- Inventaire du joueur ---
  final Inventory inventory = Inventory();

  Knight(Vector2 position)
      : super(
          position: position,
          size: Vector2.all(16), // Sprite et hitbox à l’échelle de la carte
          speed: 60,
          animation: PlayerSpriteSheet.playerAnimations(),
        );

  // Helpers pratiques
  void addKey(String keyId) {
    inventory.add(Item(id: keyId, type: 'key', quantity: 1));
  }

  bool hasKey(String keyId) => inventory.has(keyId);
  bool useKey(String keyId) => inventory.consume(keyId);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // --- Hitbox native pour collisions physiques ---
    add(
      RectangleHitbox(
        size: Vector2(14, 14),
        position: Vector2(1, 1),
      ),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    // Future : interactions, attaques, IA, etc.
  }
}
