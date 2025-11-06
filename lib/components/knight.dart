import 'package:bonfire/bonfire.dart';
import '../util/player_sprite_sheet.dart';
import 'package:app/components/inventory/inventory.dart';

class Knight extends SimplePlayer with BlockMovementCollision {
  final Inventory inventory = Inventory();
  final bool invertControls;

  Knight(
    Vector2 position, {
    this.invertControls = false,
  }) : super(
          position: position,
          size: Vector2.all(16),
          speed: 40,
          animation: PlayerSpriteSheet.playerAnimations(),
        );

  void addKey(String keyId) => inventory.add(Item(id: keyId, type: 'key', quantity: 1));
  bool hasKey(String keyId) => inventory.has(keyId);
  bool useKey(String keyId) => inventory.consume(keyId);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(RectangleHitbox(size: Vector2(14, 14), position: Vector2(1, 1)));
  }

  @override
  void update(double dt) {
    super.update(dt);
  }

  // ✅ Bonfire ≥ 2.x : c'est cette méthode-là
  @override
  void onJoystickChangeDirectional(JoystickDirectionalEvent event) {
    // Inversion éventuelle
    final dir = invertControls ? _invert(event.directional) : event.directional;

    // ✅ Quand le joystick est relâché (ou presque), on stoppe TOUT
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
        // déjà géré au-dessus
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
