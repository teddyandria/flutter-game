import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';
import '../util/player_sprite_sheet.dart';
import 'knight.dart';

class EnemyKnight extends SimpleEnemy with BlockMovementCollision {
  final double detectionRadius;
  final Vector2 patrolCenter;
  final double patrolRadius;
  double _idleTimer = 0;
  bool _isChasing = false;
  static const double _maxLife = 100.0;
  double _lastAttackTime = 0;

  EnemyKnight({
    required Vector2 position,
    this.detectionRadius = 80.0,
    this.patrolRadius = 50.0,
    Vector2? patrolCenter,
  })  : patrolCenter = patrolCenter ?? position,
        super(
          position: position,
          size: Vector2.all(16),
          speed: 30,
          life: _maxLife,
          animation: SimpleDirectionAnimation(
            idleRight: PlayerSpriteSheet.idleRight(),
            idleLeft: PlayerSpriteSheet.idleLeft(),
            runRight: PlayerSpriteSheet.runRight(),
            runLeft: PlayerSpriteSheet.runLeft(),
          ),
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(RectangleHitbox(size: Vector2(14, 14), position: Vector2(1, 1)));
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    // Dessiner la barre de vie manuellement
    _drawLifeBar(canvas);
  }

  void _drawLifeBar(Canvas canvas) {
    if (life <= 0) return;

    final lifePercent = life / _maxLife;
    final barWidth = 14.0;
    final barHeight = 3.0;
    final barX = -1.0;
    final barY = -6.0;

    // Fond de la barre
    canvas.drawRect(
      Rect.fromLTWH(barX, barY, barWidth, barHeight),
      Paint()..color = Colors.red.withOpacity(0.5),
    );

    // Barre de vie
    canvas.drawRect(
      Rect.fromLTWH(barX, barY, barWidth * lifePercent, barHeight),
      Paint()..color = Colors.green,
    );

    // Bordure
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
    super.update(dt);

    if (life <= 0) {
      removeFromParent();
      return;
    }

    // Toujours incrémenter le timer d'attaque
    _lastAttackTime += dt;

    // Cherche le joueur
    final player = gameRef.player;
    if (player != null && player is Knight) {
      final distanceToPlayer = position.distanceTo(player.position);

      // Si le joueur est dans le rayon de détection
      if (distanceToPlayer <= detectionRadius) {
        _isChasing = true;
        
        // Si très proche (distance d'attaque), on stoppe et on attaque
        if (distanceToPlayer <= 25.0) {
          stopMove();
          idle();
          // Attaque en continu tant qu'on est proche
          _attackPlayer(player);
        } else {
          // Sinon on se déplace vers le joueur
          seeAndMoveToPlayer(
            closePlayer: (p) {
              // On ne fait rien ici car la logique est dans le if ci-dessus
            },
            radiusVision: detectionRadius,
          );
        }
      } else {
        // Si on était en train de chasser mais le joueur est trop loin
        if (_isChasing) {
          _isChasing = false;
          stopMove();
          idle();
        } else {
          // Patrouille normale
          _patrol(dt);
        }
      }
    }
  }

  void _attackPlayer(Player player) {
    // Attaque toutes les 0.8 secondes
    if (_lastAttackTime >= 0.8) {
      _lastAttackTime = 0;  // Réinitialise le timer
      
      print('[EnemyKnight] Attaque le joueur! Vie joueur avant: ${player.life}');
      
      // Inflige directement des dégâts au joueur
      player.handleAttack(
        AttackOriginEnum.ENEMY,
        10,
        this,
      );
      
      print('[EnemyKnight] Vie joueur après: ${player.life}');
      
      // Animation d'attaque visuelle (optionnelle)
      simpleAttackMelee(
        size: Vector2.all(20),
        damage: 0,  // On met 0 car on a déjà infligé les dégâts ci-dessus
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
  }

  void _patrol(double dt) {
    _idleTimer += dt;

    // Change de direction toutes les 2 secondes
    if (_idleTimer >= 2.0) {
      _idleTimer = 0;

      // Vérifie si on est trop loin du centre de patrouille
      final distanceFromCenter = position.distanceTo(patrolCenter);

      if (distanceFromCenter > patrolRadius) {
        // Retourne vers le centre
        final direction = patrolCenter - position;
        moveFromAngle(direction.angleToSigned(Vector2(1, 0)));
      } else {
        // Se déplace aléatoirement
        final random = DateTime.now().millisecond % 5;
        switch (random) {
          case 0:
            moveUp();
            break;
          case 1:
            moveDown();
            break;
          case 2:
            moveLeft();
            break;
          case 3:
            moveRight();
            break;
          default:
            stopMove();
            idle();
        }
      }
    }
  }

  @override
  void onReceiveDamage(AttackOriginEnum attacker, double damage, identify) {
    super.onReceiveDamage(attacker, damage, identify);
    
    // Affiche les dégâts
    showDamage(
      damage,
      config: const TextStyle(
        fontSize: 10,
        color: Colors.red,
        fontWeight: FontWeight.bold,
      ),
    );

    // Si mort, on retire l'ennemi
    if (life <= 0) {
      removeFromParent();
    }
  }
}
