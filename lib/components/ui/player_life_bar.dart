import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';

class PlayerLifeBar extends StatelessWidget {
  final BonfireGame game;

  const PlayerLifeBar({Key? key, required this.game}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 20,
      left: 20,
      child: StreamBuilder<double>(
        stream: _getPlayerLifeStream(),
        builder: (context, snapshot) {
          final life = snapshot.data ?? 100.0;
          final lifePercent = life / 100.0;

          return Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
            ),
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.favorite,
                      color: Colors.red,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${life.toInt()} / 100',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Container(
                  width: 150,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.white.withOpacity(0.5), width: 1),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: lifePercent.clamp(0.0, 1.0),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: lifePercent > 0.5
                              ? [Colors.greenAccent, Colors.green]
                              : lifePercent > 0.25
                                  ? [Colors.orange, Colors.orangeAccent]
                                  : [Colors.red, Colors.redAccent],
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Stream<double> _getPlayerLifeStream() async* {
    while (true) {
      await Future.delayed(const Duration(milliseconds: 100));
      final player = game.player;
      if (player != null) {
        yield player.life;
      } else {
        yield 0.0;
      }
    }
  }
}
