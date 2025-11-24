# 🏗️ Architecture du Jeu - Serek's Escape

## 📊 Vue d'Ensemble

```
┌─────────────────────────────────────────────────────────────────┐
│                         APPLICATION FLUTTER                      │
│                                                                  │
│  ┌────────────────┐                                             │
│  │   main.dart    │  Point d'entrée                             │
│  │   (MyApp)      │  - Routes nommées                           │
│  └───────┬────────┘  - Theme global                             │
│          │                                                       │
│          ▼                                                       │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │                    ÉCRANS (Screens)                       │  │
│  ├──────────────────────────────────────────────────────────┤  │
│  │  HomeScreen → StoryIntroScreen → GameScreen → End        │  │
│  │     │              │                  │          │         │  │
│  │     │              │                  │          │         │  │
│  │  [Menu]      [Synopsis 5p]      [Jeu Multi-Map] │         │  │
│  │                                       │          │         │  │
│  │                              ┌────────┴──────┐  │         │  │
│  │                              │  MapNavigator │  │         │  │
│  │                              │  /map1 /map2  │  │         │  │
│  │                              └────────┬──────┘  │         │  │
│  │                                       │          │         │  │
│  │                              ┌────────┴──────────┴──────┐  │  │
│  │                              │  EndGameCinematic (5p)   │  │  │
│  │                              └──────────────────────────┘  │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

## 🎮 Architecture du GameScreen

```
┌──────────────────────────────────────────────────────────────────────┐
│                          GAME SCREEN                                  │
│  (StatefulWidget avec TickerProviderStateMixin)                      │
├──────────────────────────────────────────────────────────────────────┤
│                                                                       │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │                    STATE MANAGEMENT                          │   │
│  ├─────────────────────────────────────────────────────────────┤   │
│  │  • _fadeController (AnimationController)                     │   │
│  │  • _keyboardFocusNode (FocusNode)                           │   │
│  │  • _isGameOver (bool)                                       │   │
│  │  • _showPortalUnlocked (bool)                               │   │
│  │  • _showDizzyMessage (bool)                                 │   │
│  │  • _currentPlayer (Knight?)                                 │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                       │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │                    INPUT MANAGEMENT                          │   │
│  ├─────────────────────────────────────────────────────────────┤   │
│  │                                                              │   │
│  │  RawKeyboardListener ──────┐                                │   │
│  │    │                        │                                │   │
│  │    ├─ onKeyDown ────────────┼──► Knight.onKeyDown()         │   │
│  │    │  (bloqué si overlay)   │                                │   │
│  │    └─ onKeyUp ──────────────┼──► Knight.onKeyUp()           │   │
│  │       (toujours traité)     │                                │   │
│  │                             │                                │   │
│  │  GestureDetector ───────────┤                                │   │
│  │    ├─ onTap ────────────────┼──► Knight.triggerAttack()     │   │
│  │    └─ onSecondaryTap ───────┘                                │   │
│  │                                                              │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                       │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │                    MAP NAVIGATOR                             │   │
│  ├─────────────────────────────────────────────────────────────┤   │
│  │                                                              │   │
│  │  '/map1' ────► MapItem                                      │   │
│  │    │             ├─ WorldMapByTiled (tiled/map.json)        │   │
│  │    │             ├─ player_position: (5, 5)                 │   │
│  │    │             └─ Components:                              │   │
│  │    │                  • 3 × KeyItem                          │   │
│  │    │                  • 3 × EnemyKnight                      │   │
│  │    │                  • 1 × TreePortal                       │   │
│  │    │                                                         │   │
│  │  '/map2' ───► MapItem                                       │   │
│  │                ├─ WorldMapByTiled (tiled2/map2.json)        │   │
│  │                ├─ player_position: (5, 5)                   │   │
│  │                ├─ invertControls: true                      │   │
│  │                └─ Components:                                │   │
│  │                     • 1 × ExitDoor                           │   │
│  │                                                              │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                       │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │                    UI OVERLAYS                               │   │
│  ├─────────────────────────────────────────────────────────────┤   │
│  │                                                              │   │
│  │  Stack:                                                      │   │
│  │    ├─ BonfireWidget (jeu)                                   │   │
│  │    ├─ BackButtonWidget                                      │   │
│  │    ├─ PortalUnlockedMessage (si _showPortalUnlocked)        │   │
│  │    ├─ DizzyMessage (si _showDizzyMessage)                   │   │
│  │    └─ GameOverOverlay (si _isGameOver)                      │   │
│  │                                                              │   │
│  │  BonfireWidget overlays:                                    │   │
│  │    ├─ InventoryOverlay (clés collectées)                    │   │
│  │    └─ PlayerLifeBar (HP en temps réel)                      │   │
│  │                                                              │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                       │
└──────────────────────────────────────────────────────────────────────┘
```

## 🎭 Hiérarchie des Composants de Jeu

```
┌────────────────────────────────────────────────────────────────┐
│                      BONFIRE COMPONENTS                         │
├────────────────────────────────────────────────────────────────┤
│                                                                 │
│  SimplePlayer                                                  │
│  └─ Knight                                                     │
│       ├─ Position: Vector2                                     │
│       ├─ Health: 100 HP                                        │
│       ├─ Speed: 100 pixels/sec                                 │
│       ├─ Animations: SerekSpriteSheet                          │
│       │    ├─ idleDown, idleLeft, idleRight, idleUp           │
│       │    └─ runDown, runLeft, runRight, runUp               │
│       ├─ Controls: _keysPressed (Set<LogicalKeyboardKey>)     │
│       ├─ Inventory: Map<String, bool>                          │
│       └─ Methods:                                              │
│            ├─ onKeyDown/onKeyUp (gestion clavier)             │
│            ├─ triggerAttack() (attaque externe)               │
│            ├─ addKey/hasKey/useKey (gestion clés)             │
│            ├─ clearKeys() (reset contrôles)                   │
│            └─ receiveDamage() (gestion dégâts)                │
│                                                                 │
│  SimpleEnemy                                                   │
│  └─ EnemyKnight                                                │
│       ├─ Health: 50 HP                                         │
│       ├─ Speed: 50 pixels/sec                                  │
│       ├─ AI States:                                            │
│       │    ├─ PATROL (patrouille circulaire)                  │
│       │    ├─ CHASE (poursuite du joueur)                     │
│       │    └─ ATTACK (attaque toutes les 0.8s)                │
│       ├─ Detection: 90-120px radius                            │
│       ├─ Patrol: 50-80px radius                                │
│       └─ Damage: 10 HP per attack                              │
│                                                                 │
│  GameDecoration                                                │
│  ├─ KeyItem (collectables)                                    │
│  │    ├─ Colors: Gold, Blue, Green                            │
│  │    ├─ Size: 16x16                                          │
│  │    └─ onContact → addKey()                                 │
│  │                                                             │
│  ├─ TreePortal (with Sensor)                                  │
│  │    ├─ Appearance: canAppear() callback                     │
│  │    ├─ Teleport: canTeleport() validation                   │
│  │    ├─ Lighting: Green glow (40px radius)                   │
│  │    └─ Trigger: Left-side collision detection               │
│  │                                                             │
│  └─ ExitDoor (with Sensor)                                    │
│       ├─ Visibility: canOpen() callback                       │
│       ├─ Rendering: Brown door + golden handle                │
│       ├─ Effect: Amber glow when visible                      │
│       ├─ Trigger: _hasTriggered flag (once)                   │
│       └─ onContact → onPlayerEnter()                          │
│                                                                 │
└────────────────────────────────────────────────────────────────┘
```

## 🔄 Flux de Données et État

```
┌─────────────────────────────────────────────────────────────────┐
│                        DATA FLOW                                 │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  USER INPUT                                                      │
│      │                                                           │
│      ├─ Keyboard ──────► RawKeyboardListener                   │
│      │                      │                                    │
│      │                      ├─ KeyDown ──► _keysPressed.add()  │
│      │                      │                 │                 │
│      │                      │                 ▼                 │
│      │                      │          Knight.update()          │
│      │                      │          _handleKeyboardMovement()│
│      │                      │                 │                 │
│      │                      │                 ▼                 │
│      │                      │          moveUp/Down/Left/Right() │
│      │                      │                                    │
│      │                      └─ KeyUp ──► _keysPressed.remove() │
│      │                                                           │
│      └─ Mouse ──────────► GestureDetector                       │
│                              │                                   │
│                              └─ onTap ──► triggerAttack()       │
│                                                                  │
│  GAME STATE                                                      │
│      │                                                           │
│      ├─ Health Change ──► Knight.receiveDamage()               │
│      │                       │                                   │
│      │                       ├─ HP <= 0 ──► onDeath() callback │
│      │                       │                  │                │
│      │                       │                  ▼                │
│      │                       │           setState(() {          │
│      │                       │             _isGameOver = true   │
│      │                       │           })                     │
│      │                       │                                   │
│      │                       └─ HP > 0 ──► Continue game        │
│      │                                                           │
│      ├─ Key Collected ──► Knight.addKey()                      │
│      │                       │                                   │
│      │                       └─ 3 keys? ──► Portal appears      │
│      │                                                           │
│      ├─ Portal Enter ──► canTeleport() validation              │
│      │                      │                                   │
│      │                      └─ OK ──► setState() + navigate    │
│      │                                                           │
│      └─ Exit Door ──► onPlayerEnter()                          │
│                           │                                      │
│                           └─► Navigator.push(EndGameCinematic)  │
│                                                                  │
│  UI UPDATES                                                      │
│      │                                                           │
│      ├─ Inventory ──► InventoryOverlay rebuilds                │
│      ├─ Health ──► PlayerLifeBar rebuilds                      │
│      ├─ Messages ──► Conditional Stack widgets                 │
│      └─ Game Over ──► GameOverOverlay appears                  │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

## 🗺️ Architecture des Maps

```
┌────────────────────────────────────────────────────────────────┐
│                        MAP STRUCTURE                            │
├────────────────────────────────────────────────────────────────┤
│                                                                 │
│  MAP 1 - Le Donjon Principal                                   │
│  ┌─────────────────────────────────────────────────────────┐  │
│  │                                                          │  │
│  │  📂 tiled/map.json                                       │  │
│  │    ├─ Layers:                                           │  │
│  │    │   ├─ Sol (ground tiles)                            │  │
│  │    │   ├─ Decorations (objects)                         │  │
│  │    │   └─ Objects (collision/entities)                  │  │
│  │    │                                                     │  │
│  │    ├─ Size: 50x50 tiles × 16px = 800×800px             │  │
│  │    │                                                     │  │
│  │    └─ Assets:                                           │  │
│  │        ├─ tile_set.png (tileset principal)              │  │
│  │        └─ decorative.png (décorations)                  │  │
│  │                                                          │  │
│  │  🎮 Components dynamiques:                              │  │
│  │    ├─ Knight @ (80, 80)                                 │  │
│  │    ├─ KeyItem (gold) @ (560, 128)                       │  │
│  │    ├─ KeyItem (blue) @ (160, 560)                       │  │
│  │    ├─ KeyItem (green) @ (320, 320)                      │  │
│  │    ├─ EnemyKnight #1 @ (240, 160)                       │  │
│  │    ├─ EnemyKnight #2 @ (480, 320)                       │  │
│  │    ├─ EnemyKnight #3 @ (192, 480)                       │  │
│  │    └─ TreePortal @ (32, 80) [appears with 3 keys]      │  │
│  │                                                          │  │
│  └─────────────────────────────────────────────────────────┘  │
│                                                                 │
│  MAP 2 - Zone Dimensionnelle                                   │
│  ┌─────────────────────────────────────────────────────────┐  │
│  │                                                          │  │
│  │  📂 tiled2/map2.json                                     │  │
│  │    ├─ Layers: Same structure                            │  │
│  │    ├─ Size: 50x50 tiles × 16px = 800×800px             │  │
│  │    └─ Layout: Corridor/labyrinth design                │  │
│  │                                                          │  │
│  │  ⚙️ Spécificité: invertControls = true                  │  │
│  │    ├─ Up ↔ Down                                         │  │
│  │    └─ Left ↔ Right                                      │  │
│  │                                                          │  │
│  │  🎮 Components:                                         │  │
│  │    ├─ Knight @ (80, 80)                                 │  │
│  │    └─ ExitDoor @ (192, 288)                             │  │
│  │                                                          │  │
│  │  💬 UI Messages:                                        │  │
│  │    └─ DizzyMessage (auto, 3s, once)                    │  │
│  │                                                          │  │
│  └─────────────────────────────────────────────────────────┘  │
│                                                                 │
└────────────────────────────────────────────────────────────────┘
```

## 🎨 Système d'Animation

```
┌────────────────────────────────────────────────────────────────┐
│                    ANIMATION SYSTEM                             │
├────────────────────────────────────────────────────────────────┤
│                                                                 │
│  SerekSpriteSheet (64×496px)                                   │
│  ┌─────────────────────────────────────────────────────────┐  │
│  │                                                          │  │
│  │  Grid: 4 columns × 31 rows of 16×16 sprites            │  │
│  │                                                          │  │
│  │  Column Layout:                                         │  │
│  │    ├─ Col 0 (x=0):  Idle Right + Run Right             │  │
│  │    ├─ Col 1 (x=16): Idle Left + Run Left               │  │
│  │    ├─ Col 2 (x=32): Idle Down + Run Down               │  │
│  │    └─ Col 3 (x=48): Idle Up + Run Up                   │  │
│  │                                                          │  │
│  │  Row Layout:                                            │  │
│  │    ├─ Idle animations (4 frames each):                 │  │
│  │    │   ├─ Right: y=0   (frames 0-3)                    │  │
│  │    │   ├─ Left:  y=16  (frames 0-3)                    │  │
│  │    │   ├─ Down:  y=32  (frames 0-3)                    │  │
│  │    │   └─ Up:    y=48  (frames 0-3)                    │  │
│  │    │                                                     │  │
│  │    └─ Run animations (4 frames each):                  │  │
│  │        ├─ Right: y=64  (frames 0-3)                    │  │
│  │        ├─ Left:  y=80  (frames 0-3)                    │  │
│  │        ├─ Down:  y=96  (frames 0-3)                    │  │
│  │        └─ Up:    y=112 (frames 0-3)                    │  │
│  │                                                          │  │
│  │  Timing:                                                │  │
│  │    ├─ Idle: 0.15s per frame                            │  │
│  │    └─ Run:  0.08s per frame                            │  │
│  │                                                          │  │
│  └─────────────────────────────────────────────────────────┘  │
│                                                                 │
│  SimpleDirectionAnimation                                      │
│  ┌─────────────────────────────────────────────────────────┐  │
│  │                                                          │  │
│  │  Combines all 8 animations:                             │  │
│  │    runRight, runLeft, runDown, runUp,                  │  │
│  │    idleRight, idleLeft, idleDown, idleUp               │  │
│  │                                                          │  │
│  │  Auto-switch based on:                                  │  │
│  │    ├─ Movement state (moving vs stationary)            │  │
│  │    └─ Last direction faced                              │  │
│  │                                                          │  │
│  └─────────────────────────────────────────────────────────┘  │
│                                                                 │
└────────────────────────────────────────────────────────────────┘
```

## 🔐 Gestion de la Sécurité et Performance

```
┌────────────────────────────────────────────────────────────────┐
│                  OPTIMIZATIONS & SAFETY                         │
├────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Focus Management                                              │
│  ┌─────────────────────────────────────────────────────────┐  │
│  │  • Persistent FocusNode across rebuilds                 │  │
│  │  • Auto-request focus in didUpdateWidget()              │  │
│  │  • Clear keys on focus loss                             │  │
│  │  • Triple clearKeys() on overlays:                      │  │
│  │     ├─ Before overlay shows                             │  │
│  │     ├─ 50ms after (setState settled)                    │  │
│  │     └─ After overlay hides                              │  │
│  └─────────────────────────────────────────────────────────┘  │
│                                                                 │
│  Navigation Safety                                             │
│  ┌─────────────────────────────────────────────────────────┐  │
│  │  • Check mounted before setState()                      │  │
│  │  • Future.microtask() for context-safe navigation       │  │
│  │  • pushNamedAndRemoveUntil() for clean stack            │  │
│  │  • _hasTriggered flags prevent duplicate triggers       │  │
│  └─────────────────────────────────────────────────────────┘  │
│                                                                 │
│  Memory Management                                             │
│  ┌─────────────────────────────────────────────────────────┐  │
│  │  • dispose() all controllers and listeners              │  │
│  │  • Cancel timers in dispose()                           │  │
│  │  • Clear collections on restart                         │  │
│  │  • Proper lifecycle management                          │  │
│  └─────────────────────────────────────────────────────────┘  │
│                                                                 │
│  Performance Optimizations                                     │
│  ┌─────────────────────────────────────────────────────────┐  │
│  │  • Camera follows player (800×800 → ~400×400 visible)   │  │
│  │  • Collision detection on relevant components only      │  │
│  │  • Enemy AI states (only chase when in range)           │  │
│  │  • Conditional rendering (overlays, messages)           │  │
│  │  • Sprite sheet reuse (one load, multiple animations)   │  │
│  └─────────────────────────────────────────────────────────┘  │
│                                                                 │
└────────────────────────────────────────────────────────────────┘
```

## 📱 Support Multi-Plateforme

```
┌────────────────────────────────────────────────────────────────┐
│                    PLATFORM SUPPORT                             │
├────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Desktop (Windows, macOS, Linux)                               │
│  ┌─────────────────────────────────────────────────────────┐  │
│  │  • Keyboard: Arrow keys + Space                         │  │
│  │  • Mouse: Click to attack                               │  │
│  │  • Focus: RawKeyboardListener                           │  │
│  │  • Orientation: Landscape enforced                      │  │
│  └─────────────────────────────────────────────────────────┘  │
│                                                                 │
│  Mobile (Android, iOS)                                         │
│  ┌─────────────────────────────────────────────────────────┐  │
│  │  • Touch: Virtual Joystick                              │  │
│  │  • Controls: Directional pad + 2 action buttons         │  │
│  │  • Orientation: Landscape enforced                      │  │
│  │  • SystemChrome: setPreferredOrientations()             │  │
│  └─────────────────────────────────────────────────────────┘  │
│                                                                 │
│  Web                                                           │
│  ┌─────────────────────────────────────────────────────────┐  │
│  │  • Keyboard: Same as desktop                            │  │
│  │  • Mouse: Full support                                  │  │
│  │  • Performance: WebGL rendering                         │  │
│  │  • Deployment: flutter build web                        │  │
│  └─────────────────────────────────────────────────────────┘  │
│                                                                 │
└────────────────────────────────────────────────────────────────┘
```

## 🎯 Décisions d'Architecture Clés

### 1. **Bonfire Engine**
- **Pourquoi** : Framework spécialisé RPG 2D, basé sur Flame
- **Avantages** : SimplePlayer, MapNavigator, collision built-in
- **Trade-off** : Learning curve, mais gain de temps énorme

### 2. **StatefulWidget avec Mixins**
- **Pourquoi** : Contrôle total sur le lifecycle et animations
- **Mixins** : TickerProviderStateMixin pour AnimationController
- **Alternative** : BLoC pattern (trop complexe pour ce projet)

### 3. **Tiled Map Editor**
- **Pourquoi** : Séparation design/code, édition visuelle
- **Format** : JSON pour facilité de parsing
- **Workflow** : Designer → Export JSON → Load in Flutter

### 4. **Multi-Input Support**
- **Pourquoi** : Accessibilité multi-plateforme
- **Implémentation** : 
  - RawKeyboardListener (desktop)
  - GestureDetector (mouse/touch)
  - Joystick (mobile)
- **Coordination** : Tous appellent les mêmes méthodes Knight

### 5. **Navigation basée sur Routes**
- **Pourquoi** : Séparation écrans, back button support
- **Structure** : Named routes dans main.dart
- **Stack** : pushReplacement pour éviter accumulation

### 6. **Component-Based Game Objects**
- **Pourquoi** : Réutilisabilité, modularité
- **Pattern** : Composition over inheritance
- **Exemples** : 
  - Knight extends SimplePlayer
  - ExitDoor extends GameDecoration with Sensor