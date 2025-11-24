import 'package:app/components/game-items/inventory_overlay.dart';
import 'package:app/components/game-items/key.dart';
import 'package:app/components/enemy_knight.dart';
import 'package:app/components/ui/player_life_bar.dart';
import 'package:app/components/ui/game_over_overlay.dart';
import 'package:app/components/ui/portal_unlocked_message.dart';
import 'package:app/components/ui/dizzy_message.dart';
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
  late FocusNode _keyboardFocusNode;
  bool _isGameOver = false;
  String _currentMapId = '/map1';
  bool _showPortalUnlocked = false;
  bool _portalWasUnlocked = false;
  bool _showDizzyMessage = false;
  bool _dizzyMessageShown = false;
  Knight? _currentPlayer;

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
    _keyboardFocusNode = FocusNode();
    _keyboardFocusNode.addListener(() {
      if (!_keyboardFocusNode.hasFocus && _currentPlayer != null) {
        _currentPlayer!.clearKeys();
      }
    });
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _keyboardFocusNode.requestFocus();
      }
    });
  }

  @override
  void didUpdateWidget(GameScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (mounted && !_showPortalUnlocked && !_showDizzyMessage && !_isGameOver) {
      Future.microtask(() {
        if (mounted) {
          _keyboardFocusNode.requestFocus();
        }
      });
    }
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    _fadeController.dispose();
    _keyboardFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const double tileSize = 16.0;

    return RawKeyboardListener(
      autofocus: true,
      focusNode: _keyboardFocusNode,
      onKey: (RawKeyEvent event) {
        if (_currentPlayer == null) return;
        
        if (event is RawKeyDownEvent) {
          if (_showPortalUnlocked) return;
          _currentPlayer!.onKeyDown(event.logicalKey);
        } else if (event is RawKeyUpEvent) {
          _currentPlayer!.onKeyUp(event.logicalKey);
        }
      },
      child: Scaffold(
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

          final player = Knight(
            map.properties['player_position'],
            invertControls: id == '/map2',
            onDeath: () {
              setState(() {
                _isGameOver = true;
                _currentMapId = id;
              });
            },
          );
          
          _currentPlayer = player;

          if (id == '/map1') {
            components.addAll([
              KeyItem(Vector2(tileSize * 35, tileSize * 8), color: KeyColor.gold),
              KeyItem(Vector2(tileSize * 10, tileSize * 35), color: KeyColor.blue),
              KeyItem(Vector2(tileSize * 20, tileSize * 20), color: KeyColor.green),
              
              EnemyKnight(
                position: Vector2(tileSize * 15, tileSize * 10),
                detectionRadius: 100.0,
                patrolRadius: 60.0,
                patrolCenter: Vector2(tileSize * 15, tileSize * 10),
              ),
              EnemyKnight(
                position: Vector2(tileSize * 30, tileSize * 20),
                detectionRadius: 120.0,
                patrolRadius: 80.0,
                patrolCenter: Vector2(tileSize * 30, tileSize * 20),
              ),
              EnemyKnight(
                position: Vector2(tileSize * 12, tileSize * 30),
                detectionRadius: 90.0,
                patrolRadius: 50.0,
                patrolCenter: Vector2(tileSize * 12, tileSize * 30),
              ),
              
              TreePortal(
                position: Vector2(tileSize * 2, tileSize * 5),
                canAppear: () {
                  final hasAll = player.hasKey('key_gold') &&
                         player.hasKey('key_blue') &&
                         player.hasKey('key_green');
                  
                  if (hasAll && !_portalWasUnlocked) {
                    _portalWasUnlocked = true;
                    _currentPlayer?.clearKeys();
                    setState(() {
                      _showPortalUnlocked = true;
                    });
                    Future.delayed(const Duration(seconds: 4), () {
                      if (mounted) {
                        _currentPlayer?.clearKeys();
                        setState(() {
                          _showPortalUnlocked = false;
                        });
                        Future.delayed(const Duration(milliseconds: 100), () {
                          if (mounted) {
                            _keyboardFocusNode.requestFocus();
                            _currentPlayer?.clearKeys();
                          }
                        });
                      }
                    });
                  }
                  
                  return hasAll;
                },
                canTeleport: (_) async {
                  final hasAll = player.hasKey('key_gold') &&
                                player.hasKey('key_blue') &&
                                player.hasKey('key_green');

                  if (!hasAll) {
                    final missing = [
                      if (!player.hasKey('key_gold')) 'or',
                      if (!player.hasKey('key_blue')) 'bleue',
                      if (!player.hasKey('key_green')) 'verte',
                    ].join(', ');
                    player.showDamage(
                      0,
                      config: const TextStyle(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                    print('[Portal] Clés manquantes: $missing');
                    return false;
                  }

                  print('[Portal] Toutes les clés collectées! Téléportation...');
                  player.useKey('key_gold');
                  player.useKey('key_blue');
                  player.useKey('key_green');
                  return true;
                },
                onTeleport: () {
                  MapNavigator.of(context).toNamed('/map2');
                  
                  Future.delayed(const Duration(milliseconds: 500), () {
                    if (mounted && !_dizzyMessageShown) {
                      setState(() {
                        _showDizzyMessage = true;
                        _dizzyMessageShown = true;
                      });
                      
                      Future.delayed(const Duration(seconds: 3), () {
                        if (mounted) {
                          setState(() {
                            _showDizzyMessage = false;
                          });
                        }
                      });
                    }
                  });
                },
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
              // GestureDetector pour détecter les clics souris (attaque)
              GestureDetector(
                onTap: () {
                  // Clic gauche pour attaquer
                  _currentPlayer?.triggerAttack();
                },
                onSecondaryTap: () {
                  // Clic droit pour attaquer aussi
                  _currentPlayer?.triggerAttack();
                },
                child: FadeTransition(
                  opacity: _fadeController,
                  child: BonfireWidget(
                  map: map.map,
                  player: player,
                  components: components,
                  overlayBuilderMap: {
                    'inventory': (context, game) => InventoryOverlay(game: game),
                    'lifebar': (context, game) => PlayerLifeBar(game: game),
                  },
                  initialActiveOverlays: const ['inventory', 'lifebar'],
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
                          enableDirection: false,
                          sprite: Sprite.load('player/attack_effect_right.png'),
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
              ),
              const BackButtonWidget(),
              if (_showPortalUnlocked)
                const PortalUnlockedMessage(),
              if (_showDizzyMessage)
                const DizzyMessage(),
              if (_isGameOver)
                GameOverOverlay(
                  onRestart: () {
                    setState(() {
                      _isGameOver = false;
                      _showPortalUnlocked = false;
                      _portalWasUnlocked = false;
                    });
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => const GameScreen()),
                    );
                  },
                ),
            ],
          );
        },
        ),
      ),
    );
  }
}