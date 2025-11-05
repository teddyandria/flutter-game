import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';
import '../components/ui/back_button_widget.dart';

/// Écran principal du moteur de jeu Bonfire.
///
/// Charge une carte Tiled et initialise un joystick directionnel.
/// Ajoute un effet de fondu d’apparition et un bouton de retour réutilisable.
class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const double tileSize = 32.0;

    return Scaffold(
      body: Container(
        color: Colors.black,
        child: Stack(
          children: [
            // Écran de chargement
            const Center(
              child: Text(
                'Chargement de la carte...',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 18,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),

            // Carte Bonfire avec fondu d’apparition
            FadeTransition(
              opacity: _fadeController,
              child: BonfireWidget(
                map: WorldMapByTiled(
                  WorldMapReader.fromAsset('tiled/map.json'),
                ),
                playerControllers: [
                  Joystick(
                    directional: JoystickDirectional(),
                  ),
                ],
                cameraConfig: CameraConfig(
                  zoom: getZoomFromMaxVisibleTile(context, tileSize, 20),
                  initPosition: Vector2(tileSize * 5, tileSize * 5),
                ),
                onReady: (game) {
                  Future.delayed(
                    const Duration(milliseconds: 300),
                    () => _fadeController.forward(),
                  );
                },
              ),
            ),

            // Bouton de retour via composant réutilisable
            const BackButtonWidget(),
          ],
        ),
      ),
    );
  }
}

