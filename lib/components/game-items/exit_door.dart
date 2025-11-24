import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';
import '../knight.dart';

class ExitDoor extends GameDecoration with Sensor {
  final VoidCallback? onPlayerEnter;
  final bool Function()? canOpen;
  bool _isVisible = false;
  bool _hasTriggered = false;

  ExitDoor({
    required Vector2 position,
    this.onPlayerEnter,
    this.canOpen,
  }) : super(
          position: position,
          size: Vector2(32, 32),
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(RectangleHitbox(size: Vector2(32, 32)));
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    if (canOpen != null) {
      final shouldBeVisible = canOpen!();
      if (shouldBeVisible != _isVisible) {
        _isVisible = shouldBeVisible;
      }
    }
  }

  @override
  void render(Canvas canvas) {
    if (!_isVisible) return;
    
    super.render(canvas);
    
    final paint = Paint()
      ..color = Colors.brown.shade800
      ..style = PaintingStyle.fill;
    
    canvas.drawRect(Rect.fromLTWH(0, 0, 32, 32), paint);
    
    final doorPaint = Paint()
      ..color = Colors.brown.shade600
      ..style = PaintingStyle.fill;
    
    canvas.drawRect(Rect.fromLTWH(2, 2, 28, 28), doorPaint);
    
    final handlePaint = Paint()
      ..color = Colors.yellow.shade700
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(const Offset(24, 16), 3, handlePaint);
    
    final borderPaint = Paint()
      ..color = Colors.amber.shade400
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    canvas.drawRect(Rect.fromLTWH(0, 0, 32, 32), borderPaint);
    
    if (_isVisible) {
      final glowPaint = Paint()
        ..color = Colors.amber.withOpacity(0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
      
      canvas.drawRect(Rect.fromLTWH(-5, -5, 42, 42), glowPaint);
    }
  }

  @override
  void onContact(GameComponent component) {
    if (component is Knight && _isVisible && !_hasTriggered) {
      _hasTriggered = true;
      onPlayerEnter?.call();
    }
  }
}
