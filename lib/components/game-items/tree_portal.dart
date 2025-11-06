// lib/components/game-items/tree_portal.dart
import 'package:bonfire/bonfire.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';

typedef CanTeleport = Future<bool> Function(SimplePlayer player);

class TreePortal extends GameDecoration {
  final VoidCallback onTeleport;
  final CanTeleport? canTeleport; // ⟵ décision déléguée au GameScreen
  bool _triggered = false;

  TreePortal({
    required Vector2 position,
    required this.onTeleport,
    this.canTeleport, // optionnel
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

    add(
      RectangleHitbox(
        size: size.clone(),
        position: Vector2.zero(),
      )..collisionType = CollisionType.passive,
    );

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

    final Rect portal = Rect.fromLTWH(position.x, position.y, size.x, size.y);
    final Rect leftHalf = Rect.fromLTWH(portal.left, portal.top, portal.width / 2, portal.height);

    final Rect pr = Rect.fromLTWH(
      player.position.x,
      player.position.y,
      player.size.x,
      player.size.y,
    );

    final bool verticalOverlap = pr.top < leftHalf.bottom && pr.bottom > leftHalf.top;

    double hDist = 0;
    if (pr.right < leftHalf.left) {
      hDist = leftHalf.left - pr.right;
    } else if (pr.left > leftHalf.right) {
      hDist = pr.left - leftHalf.right;
    }

    final bool isLeftSide = pr.center.dx <= leftHalf.right;

    if (verticalOverlap && hDist <= 1.0 && isLeftSide) {
      _tryActivate(player as SimplePlayer);
    }
  }

  Future<void> _tryActivate(SimplePlayer player) async {
    // Demande au GameScreen si on peut téléporter
    if (canTeleport != null) {
      final ok = await canTeleport!(player);
      if (!ok) return; // ⟵ on ne déclenche pas, et on NE bloque PAS _triggered
    }

    _triggered = true;
    await _activatePortal();
    onTeleport();
  }

  Future<void> _activatePortal() async {
    gameRef.add(
      RectangleComponent(
        size: gameRef.size,
        paint: Paint()..color = Colors.black.withOpacity(0.8),
      ),
    );
    await Future.delayed(const Duration(milliseconds: 600));
  }
}
