// lib/components/game-items/key.dart
import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';
import 'package:app/components/knight.dart';

enum KeyColor { gold, blue, green }

class KeyItem extends GameDecoration with Sensor {
  final KeyColor color;

  KeyItem(
    Vector2 position, {
    this.color = KeyColor.gold,
    Vector2? size,
  }) : super.withSprite(
          sprite: Sprite.load(_spritePath(color)), // sprite spécifique
          position: position,
          size: size ?? Vector2.all(16),
        );

  static String _spritePath(KeyColor c) {
    // ⚠️ adapte si tu charges avec un prefix "assets/images/"
    switch (c) {
      case KeyColor.gold:
        return 'items/key_gold.png';
      case KeyColor.blue:
        return 'items/key_blue.png';
      case KeyColor.green:
        return 'items/key_green.png';
    }
  }

  // On garde un id lisible pour l’inventaire/portes
  String get id => switch (color) {
        KeyColor.gold => 'key_gold',
        KeyColor.blue => 'key_blue',
        KeyColor.green => 'key_green',
      };

  bool _collected = false;

  @override
  void onContact(GameComponent component) {
    if (_collected) return;
    if (component is! Knight) return;
    _collected = true;

    // Ajoute la clé à l’inventaire
    component.addKey(id);

    // Petit feedback visuel
    component.showDamage(
      1,
      config: const TextStyle(
        color: Colors.amber,
        fontSize: 12,
        fontWeight: FontWeight.bold,
      )
      ,
    );

    // Disparition fluide
    add(
      OpacityEffect.fadeOut(
        EffectController(duration: 0.25),
        onComplete: () => removeFromParent(),
      ),
    );

    // ignore: avoid_print
    print('[KeyItem] Clé ramassée: $id');
  }
}
