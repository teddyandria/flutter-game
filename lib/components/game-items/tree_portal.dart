// lib/components/game-items/tree_portal.dart
import 'package:bonfire/bonfire.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';

/// Portail/escalier: collision solide + téléportation
/// quand le joueur touche la MOITIÉ GAUCHE du sprite.
class TreePortal extends GameDecoration {
  final VoidCallback onTeleport;
  bool _triggered = false;

  TreePortal({
    required Vector2 position,
    required this.onTeleport,
    String spritePath = 'items/escalier.png',
    Vector2? size,
  }) : super.withSprite(
          sprite: Sprite.load(spritePath),
          size: size ?? Vector2.all(16),
          position: position,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // --- Collision solide pour bloquer le joueur ---
    add(
      RectangleHitbox(
        // couvre tout le sprite (ajuste si besoin)
        size: size.clone(),
        position: Vector2.zero(),
      )..collisionType = CollisionType.passive, // "solide" côté joueur (BlockMovementCollision)
    );

    // --- Effet de lumière (optionnel) ---
    setupLighting(
      LightingConfig(
        radius: 40,
        blurBorder: 20,
        color: Colors.greenAccent.withOpacity(0.4),
      ),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_triggered) return;

    final player = gameRef.player;
    if (player == null) return;

    // Rect du portail et sa moitié gauche
    final Rect portal = Rect.fromLTWH(position.x, position.y, size.x, size.y);
    final Rect leftHalf = Rect.fromLTWH(portal.left, portal.top, portal.width / 2, portal.height);

    // Rect du joueur
    final Rect pr = Rect.fromLTWH(
      player.position.x,
      player.position.y,
      player.size.x,
      player.size.y,
    );

    // Overlap vertical ?
    final bool verticalOverlap = pr.top < leftHalf.bottom && pr.bottom > leftHalf.top;

    // Distance horizontale entre le joueur et la moitié gauche (0 si déjà en recouvrement)
    double hDist = 0;
    if (pr.right < leftHalf.left) {
      hDist = leftHalf.left - pr.right;
    } else if (pr.left > leftHalf.right) {
      hDist = pr.left - leftHalf.right;
    }

    // Le joueur "touche" la moitié gauche (≤1px) ET est aligné verticalement
    // + s’assure qu’il est bien du côté gauche (centre du joueur avant la médiane)
    final bool isLeftSide = pr.center.dx <= leftHalf.right;
    if (verticalOverlap && hDist <= 1.0 && isLeftSide) {
      _triggered = true;
      _activatePortal();
    }
  }

  Future<void> _activatePortal() async {
    // Petit fondu sombre
    gameRef.add(
      RectangleComponent(
        size: gameRef.size,
        paint: Paint()..color = Colors.black.withOpacity(0.8),
      ),
    );
    await Future.delayed(const Duration(milliseconds: 600));
    onTeleport();
  }
}
