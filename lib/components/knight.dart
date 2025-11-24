import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../util/serek_sprite_sheet.dart';
import 'package:app/components/inventory/inventory.dart';

class Knight extends SimplePlayer with BlockMovementCollision {
  final Inventory inventory = Inventory();
  final bool invertControls;
  static const double _maxLife = 100.0;
  final VoidCallback? onDeath;
  bool _isDead = false;
  
  final Set<LogicalKeyboardKey> _keysPressed = {};

  Knight(
    Vector2 position, {
    this.invertControls = false,
    this.onDeath,
  }) : super(
          position: position,
          size: Vector2.all(16),
          speed: 40,
          life: _maxLife,
          animation: SerekSpriteSheet.serekAnimations(),
        ) {
    setupKeyboardListener();
  }

  void addKey(String keyId) => inventory.add(Item(id: keyId, type: 'key', quantity: 1));
  bool hasKey(String keyId) => inventory.has(keyId);
  bool useKey(String keyId) => inventory.consume(keyId);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(RectangleHitbox(size: Vector2(14, 14), position: Vector2(1, 1)));
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    _drawLifeBar(canvas);
  }

  void _drawLifeBar(Canvas canvas) {
    if (life <= 0) return;

    final lifePercent = life / _maxLife;
    final barWidth = 14.0;
    final barHeight = 3.0;
    final barX = 1.0;
    final barY = -6.0;

    canvas.drawRect(
      Rect.fromLTWH(barX, barY, barWidth, barHeight),
      Paint()..color = Colors.red.withOpacity(0.5),
    );

    canvas.drawRect(
      Rect.fromLTWH(barX, barY, barWidth * lifePercent, barHeight),
      Paint()..color = Colors.greenAccent,
    );

    canvas.drawRect(
      Rect.fromLTWH(barX, barY, barWidth, barHeight),
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5,
    );
  }

  @override
  void update(double dt) {
    if (_isDead) return;
    
    super.update(dt);
    
    _handleKeyboardMovement();
    
    if (life <= 0) {
      _handleDeath();
    }
  }

  void _handleKeyboardMovement() {
    if (_keysPressed.isEmpty) {
      stopMove();
      idle();
      return;
    }

    bool up = _keysPressed.contains(LogicalKeyboardKey.arrowUp);
    bool down = _keysPressed.contains(LogicalKeyboardKey.arrowDown);
    bool left = _keysPressed.contains(LogicalKeyboardKey.arrowLeft);
    bool right = _keysPressed.contains(LogicalKeyboardKey.arrowRight);

    if (!up && !down && !left && !right) {
      stopMove();
      idle();
      return;
    }

    if (up && left) {
      moveUpLeft();
    } else if (up && right) {
      moveUpRight();
    } else if (down && left) {
      moveDownLeft();
    } else if (down && right) {
      moveDownRight();
    } else if (up) {
      moveUp();
    } else if (down) {
      moveDown();
    } else if (left) {
      moveLeft();
    } else if (right) {
      moveRight();
    }
  }

  void setupKeyboardListener() {
  }

  void onKeyDown(LogicalKeyboardKey key) {
    if (_isDead) return;
    
    _keysPressed.add(key);
    
    if (key == LogicalKeyboardKey.space) {
      performAttack();
    }
  }

  void onKeyUp(LogicalKeyboardKey key) {
    _keysPressed.remove(key);
    
    if (!_keysPressed.contains(LogicalKeyboardKey.arrowUp) &&
        !_keysPressed.contains(LogicalKeyboardKey.arrowDown) &&
        !_keysPressed.contains(LogicalKeyboardKey.arrowLeft) &&
        !_keysPressed.contains(LogicalKeyboardKey.arrowRight)) {
      stopMove();
      idle();
    }
  }

  void clearKeys() {
    _keysPressed.clear();
    stopMove();
    idle();
  }

  void triggerAttack() {
    if (_isDead) return;
    performAttack();
  }

  void _handleDeath() {
    if (_isDead) return;
    
    _isDead = true;
    
    stopMove();
    idle();
    
    onDeath?.call();
    
    Future.delayed(const Duration(milliseconds: 500), () {
      removeFromParent();
    });
  }

  @override
  void onReceiveDamage(AttackOriginEnum attacker, double damage, identify) {
    if (_isDead) return;
    
    super.onReceiveDamage(attacker, damage, identify);
    
    showDamage(
      damage,
      config: const TextStyle(
        fontSize: 10,
        color: Colors.red,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  void performAttack() {
    if (_isDead) return;
    
    simpleAttackMelee(
      size: Vector2.all(16),
      damage: 15,
      direction: lastDirection,
      animationRight: SpriteAnimation.load(
        'player/attack_effect_right.png',
        SpriteAnimationData.sequenced(
          amount: 3,
          stepTime: 0.1,
          textureSize: Vector2(16, 16),
        ),
      ),
    );
  }

  @override
  void onJoystickAction(JoystickActionEvent event) {
    if (_isDead) return;
    
    if (event.id == 0 && event.event == ActionEvent.DOWN) {
      performAttack();
    }
  }

  @override
  void onJoystickChangeDirectional(JoystickDirectionalEvent event) {
    if (_isDead) return;
    
    final dir = invertControls ? _invert(event.directional) : event.directional;

    if (dir == JoystickMoveDirectional.IDLE || event.intensity == 0) {
      stopMove();
      idle();
      return;
    }

    switch (dir) {
      case JoystickMoveDirectional.MOVE_LEFT:
        moveLeft();
        break;
      case JoystickMoveDirectional.MOVE_RIGHT:
        moveRight();
        break;
      case JoystickMoveDirectional.MOVE_UP:
        moveUp();
        break;
      case JoystickMoveDirectional.MOVE_DOWN:
        moveDown();
        break;
      case JoystickMoveDirectional.MOVE_UP_LEFT:
        moveUpLeft();
        break;
      case JoystickMoveDirectional.MOVE_UP_RIGHT:
        moveUpRight();
        break;
      case JoystickMoveDirectional.MOVE_DOWN_LEFT:
        moveDownLeft();
        break;
      case JoystickMoveDirectional.MOVE_DOWN_RIGHT:
        moveDownRight();
        break;
      case JoystickMoveDirectional.IDLE:
        break;
    }
  }

  JoystickMoveDirectional _invert(JoystickMoveDirectional d) {
    switch (d) {
      case JoystickMoveDirectional.MOVE_LEFT:
        return JoystickMoveDirectional.MOVE_RIGHT;
      case JoystickMoveDirectional.MOVE_RIGHT:
        return JoystickMoveDirectional.MOVE_LEFT;
      case JoystickMoveDirectional.MOVE_UP:
        return JoystickMoveDirectional.MOVE_DOWN;
      case JoystickMoveDirectional.MOVE_DOWN:
        return JoystickMoveDirectional.MOVE_UP;
      case JoystickMoveDirectional.MOVE_UP_LEFT:
        return JoystickMoveDirectional.MOVE_DOWN_RIGHT;
      case JoystickMoveDirectional.MOVE_UP_RIGHT:
        return JoystickMoveDirectional.MOVE_DOWN_LEFT;
      case JoystickMoveDirectional.MOVE_DOWN_LEFT:
        return JoystickMoveDirectional.MOVE_UP_RIGHT;
      case JoystickMoveDirectional.MOVE_DOWN_RIGHT:
        return JoystickMoveDirectional.MOVE_UP_LEFT;
      case JoystickMoveDirectional.IDLE:
        return JoystickMoveDirectional.IDLE;
    }
  }
}
