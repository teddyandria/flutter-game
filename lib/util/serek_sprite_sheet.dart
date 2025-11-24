import 'package:bonfire/bonfire.dart';

class SerekSpriteSheet {
  static Future<SpriteAnimation> idleDown() => SpriteAnimation.load(
        'player/Serek.png',
        SpriteAnimationData.sequenced(
          amount: 4,
          stepTime: 0.15,
          textureSize: Vector2(16, 16),
          texturePosition: Vector2(0, 32),
        ),
      );

  static Future<SpriteAnimation> idleLeft() => SpriteAnimation.load(
        'player/Serek.png',
        SpriteAnimationData.sequenced(
          amount: 4,
          stepTime: 0.15,
          textureSize: Vector2(16, 16),
          texturePosition: Vector2(0, 16),
        ),
      );

  static Future<SpriteAnimation> idleRight() => SpriteAnimation.load(
        'player/Serek.png',
        SpriteAnimationData.sequenced(
          amount: 4,
          stepTime: 0.15,
          textureSize: Vector2(16, 16),
          texturePosition: Vector2(0, 0),
        ),
      );

  static Future<SpriteAnimation> idleUp() => SpriteAnimation.load(
        'player/Serek.png',
        SpriteAnimationData.sequenced(
          amount: 4,
          stepTime: 0.15,
          textureSize: Vector2(16, 16),
          texturePosition: Vector2(0, 48),
        ),
      );

  static Future<SpriteAnimation> runDown() => SpriteAnimation.load(
        'player/Serek.png',
        SpriteAnimationData.sequenced(
          amount: 4,
          stepTime: 0.08,
          textureSize: Vector2(16, 16),
          texturePosition: Vector2(0, 96),
        ),
      );

  static Future<SpriteAnimation> runLeft() => SpriteAnimation.load(
        'player/Serek.png',
        SpriteAnimationData.sequenced(
          amount: 4,
          stepTime: 0.08,
          textureSize: Vector2(16, 16),
          texturePosition: Vector2(0, 80),
        ),
      );

  static Future<SpriteAnimation> runRight() => SpriteAnimation.load(
        'player/Serek.png',
        SpriteAnimationData.sequenced(
          amount: 4,
          stepTime: 0.08,
          textureSize: Vector2(16, 16),
          texturePosition: Vector2(0, 64),
        ),
      );

  static Future<SpriteAnimation> runUp() => SpriteAnimation.load(
        'player/Serek.png',
        SpriteAnimationData.sequenced(
          amount: 4,
          stepTime: 0.08,
          textureSize: Vector2(16, 16),
          texturePosition: Vector2(0, 112),
        ),
      );

  static SimpleDirectionAnimation serekAnimations() => SimpleDirectionAnimation(
        idleDown: idleDown(),
        idleLeft: idleLeft(),
        idleRight: idleRight(),
        idleUp: idleUp(),
        runDown: runDown(),
        runLeft: runLeft(),
        runRight: runRight(),
        runUp: runUp(),
      );
}
