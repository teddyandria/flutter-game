import 'package:bonfire/bonfire.dart';

class PlayerSpriteSheet {
  // --- Animations d'attente ---
  static Future<SpriteAnimation> idleRight() => SpriteAnimation.load(
        'player/knight_idle.png',
        SpriteAnimationData.sequenced(
          amount: 4,
          stepTime: 0.15,
          textureSize: Vector2(16, 16),
        ),
      );

  static Future<SpriteAnimation> idleLeft() => SpriteAnimation.load(
        'player/knight_idle_left.png',
        SpriteAnimationData.sequenced(
          amount: 4,
          stepTime: 0.15,
          textureSize: Vector2(16, 16),
        ),
      );

  // --- Animations de course ---
  static Future<SpriteAnimation> runRight() => SpriteAnimation.load(
        'player/knight_run.png',
        SpriteAnimationData.sequenced(
          amount: 6,
          stepTime: 0.10,
          textureSize: Vector2(16, 16),
        ),
      );

  static Future<SpriteAnimation> runLeft() => SpriteAnimation.load(
        'player/knight_run_left.png',
        SpriteAnimationData.sequenced(
          amount: 6,
          stepTime: 0.10,
          textureSize: Vector2(16, 16),
        ),
      );

  // --- Assemblage global pour Bonfire ---
  static SimpleDirectionAnimation playerAnimations() => SimpleDirectionAnimation(
        idleRight: idleRight(),
        idleLeft: idleLeft(),
        runRight: runRight(),
        runLeft: runLeft(),
      );
}