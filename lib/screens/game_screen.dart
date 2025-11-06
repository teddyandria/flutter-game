// import 'package:app/components/game-items/inventory_overlay.dart';
// import 'package:app/components/game-items/key.dart';
// import 'package:bonfire/bonfire.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:app/components/ui/back_button_widget.dart';
// import 'package:app/components/knight.dart';

// class GameScreen extends StatefulWidget {
//   const GameScreen({super.key});

//   @override
//   State<GameScreen> createState() => _GameScreenState();
// }

// class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
//   late AnimationController _fadeController;

//   @override
//   void initState() {
//     super.initState();

//     // Orientation forcée en paysage
//     SystemChrome.setPreferredOrientations([
//       DeviceOrientation.landscapeLeft,
//       DeviceOrientation.landscapeRight,
//     ]);

//     _fadeController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 400),
//     );
//   }

//   @override
//   void dispose() {
//     // Retour au mode portrait à la fermeture
//     SystemChrome.setPreferredOrientations([
//       DeviceOrientation.portraitUp,
//       DeviceOrientation.portraitDown,
//     ]);
//     _fadeController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     const double tileSize = 16.0;

//     return Scaffold(
//       body: Container(
//         color: Colors.black,
//         child: Stack(
//           children: [
//             const Center(
//               child: Text(
//                 'Chargement de la carte...',
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                   color: Colors.white70,
//                   fontSize: 18,
//                   fontStyle: FontStyle.italic,
//                 ),
//               ),
//             ),

//             FadeTransition(
//               opacity: _fadeController,
//               child: BonfireWidget(
//                 map: WorldMapByTiled(
//                   WorldMapReader.fromAsset('tiled/map.json'),
//                 ),
//                 player: Knight(Vector2(tileSize * 5, tileSize * 5)),
//                 components: [
//                   KeyItem(Vector2(256, 128), color: KeyColor.gold),
//                   KeyItem(Vector2(288, 128), color: KeyColor.blue),
//                   KeyItem(Vector2(320, 128), color: KeyColor.green),                
//                 ],
//                 overlayBuilderMap: {
//                   'inventory': (context, game) => InventoryOverlay(game: game),
//                 },
//                 initialActiveOverlays: const ['inventory'],

//                 // Contrôles du joueur
//                 playerControllers: [
//                   Joystick(
//                     directional: JoystickDirectional(
//                       size: 100,
//                       isFixed: true,
//                       margin: const EdgeInsets.only(left: 30, bottom: 30),
//                       color: Colors.white.withOpacity(0.25),
//                     ),
//                   ),
                  
//                 ],

//                 cameraConfig: CameraConfig(
//                   moveOnlyMapArea: true,
//                   zoom: getZoomFromMaxVisibleTile(context, tileSize, 25),
//                   initPosition: Vector2(tileSize * 5, tileSize * 5),
//                 ),

//                 backgroundColor: Colors.black,

//                 onReady: (game) {
//                   Future.delayed(
//                     const Duration(milliseconds: 300),
//                     () => _fadeController.forward(),
//                   );
//                 },
//               ),
//             ),

//             const BackButtonWidget()
//           ],
//         ),
//       ),
//     );
//   }
// }



import 'package:app/components/game-items/inventory_overlay.dart';
import 'package:app/components/game-items/key.dart';
import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:app/components/game-items/tree_portal.dart';
import 'package:app/components/ui/back_button_widget.dart';
import '../components/knight.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({Key? key}) : super(key: key);

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const double tileSize = 16.0;

    return Scaffold(
      backgroundColor: Colors.black,
      body: MapNavigator(
        initialMap: '/map1',
        maps: {
          '/map1': (context, args) => MapItem(
                id: '/map1',
                map: WorldMapByTiled(
                  WorldMapReader.fromAsset('tiled/map.json'),
                ),
                properties: {
                  'player_position': Vector2(tileSize * 5, tileSize * 5),
                },
              ),
          '/map2': (context, args) => MapItem(
                id: '/map2',
                map: WorldMapByTiled(
                  WorldMapReader.fromAsset('tiled2/map2.json'),
                ),
                properties: {
                  'player_position': Vector2(tileSize * 5, tileSize * 5),
                },
              ),
        },
        builder: (context, arguments, map) {
          final id = map.id;
          final components = <GameComponent>[];

          if (id == '/map1') {
            components.addAll([
              KeyItem(Vector2(256, 128), color: KeyColor.gold),
              KeyItem(Vector2(288, 128), color: KeyColor.blue),
              KeyItem(Vector2(320, 128), color: KeyColor.green),                
              TreePortal(
                position: Vector2(tileSize * 2, tileSize * 5),
                onTeleport: () => MapNavigator.of(context).toNamed('/map2'),
              ),
            ]);
          } else if (id == '/map2') {
            components.addAll([
              KeyItem(Vector2(288, 128), color: KeyColor.blue),
              TreePortal(
                position: Vector2(tileSize * 2, tileSize * 5),
                onTeleport: () => MapNavigator.of(context).toNamed('/map1'),
              ),
            ]);
          }

          return Stack(
            children: [
              FadeTransition(
                opacity: _fadeController,
                child: BonfireWidget(
                  map: map.map,
                  player: Knight(map.properties['player_position']),
                  components: components,
                  overlayBuilderMap: {
                    'inventory': (context, game) => InventoryOverlay(game: game),
                  },
                  initialActiveOverlays: const ['inventory'],
                  playerControllers: [
                    Joystick(
                      directional: JoystickDirectional(
                        size: 100,
                        isFixed: true,
                        margin: const EdgeInsets.only(left: 30, bottom: 30),
                        color: Colors.white.withOpacity(0.25),
                      ),
                      actions: [
                        JoystickAction(
                          actionId: 0,
                          size: 60,
                          color: Colors.redAccent.withOpacity(0.8),
                          alignment: Alignment.bottomRight,
                          margin: const EdgeInsets.only(right: 60, bottom: 40),
                        ),
                        JoystickAction(
                          actionId: 1,
                          size: 50,
                          color: Colors.orangeAccent.withOpacity(0.8),
                          alignment: Alignment.bottomRight,
                          margin: const EdgeInsets.only(right: 20, bottom: 100),
                        ),
                      ],
                    ),
                  ],
                  cameraConfig: CameraConfig(
                    moveOnlyMapArea: true,
                    zoom: getZoomFromMaxVisibleTile(context, tileSize, 25),
                  ),
                  backgroundColor: Colors.black,
                  onReady: (game) {
                    Future.delayed(
                      const Duration(milliseconds: 300),
                      () => _fadeController.forward(),
                    );
                  },
                ),
              ),
              const BackButtonWidget()
            ],
          );
        },
      ),
    );
  }
}

