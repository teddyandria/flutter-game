# 🎮 Serek's Escape - Jeu d'Évasion de Donjon

Un jeu d'action-aventure 2D développé avec Flutter et le moteur Bonfire, où vous incarnez Serek, un prisonnier cherchant à s'échapper d'un donjon maudit.

## 📖 Histoire

Serek se réveille dans l'obscurité d'un donjon humide et glacial. Ses souvenirs sont flous... Comment est-il arrivé ici ? Selon une ancienne prophétie gravée sur les murs, trois Clés Sacrées (Or, Bleue et Verte) ouvriront un portail dimensionnel vers la liberté. Mais attention, des chevaliers corrompus patrouillent dans le donjon et protègent jalousement ces clés !

## 🎯 Objectif du Jeu

1. **Explorer le donjon** et trouver les 3 clés cachées (Or, Bleue, Verte)
2. **Combattre les gardiens corrompus** qui protègent les clés
3. **Débloquer le portail dimensionnel** en collectant les 3 clés
4. **Traverser vers la map 2** avec des contrôles inversés
5. **Atteindre la porte de sortie** pour terminer le jeu

## 🕹️ Contrôles

### 🖱️ Clavier + Souris (Recommandé)
- **Flèches directionnelles** : Déplacement (↑ ↓ ← →)
- **Clic gauche** : Attaque
- **Clic droit** : Attaque
- **Espace** : Attaque

### 📱 Écran Tactile / Joystick
- **Joystick gauche** : Déplacement
- **Bouton rouge (droite)** : Attaque
- **Bouton orange (droite)** : Action secondaire

## ⚙️ Spécificités Techniques

### 🏗️ Architecture
- **Framework** : Flutter (Dart)
- **Moteur de jeu** : Bonfire 3.x (basé sur Flame)
- **Éditeur de map** : Tiled Map Editor (fichiers JSON)
- **Système de navigation** : MapNavigator pour multi-maps
- **Gestion d'état** : StatefulWidget avec AnimationController

### 🎮 Systèmes de Gameplay

#### Combat
- **Santé du joueur** : 100 HP
- **Santé des ennemis** : 50 HP
- **Dégâts ennemis** : 10 HP par attaque
- **Intervalle d'attaque** : 0.8 secondes
- **Portée d'attaque** : 25 pixels

#### Intelligence Artificielle
- **Patrouille** : Les ennemis patrouillent dans un rayon défini
- **Détection** : Rayon de 90-120 pixels selon l'ennemi
- **Poursuite** : Les ennemis chassent le joueur s'il est détecté
- **Attaque continue** : Attaques répétées quand à portée

#### Système de Clés
- 3 clés sur la Map 1 (Or, Bleue, Verte)
- Collecte automatique au contact
- Affichage dans l'inventaire (HUD)
- Débloque le portail quand toutes collectées

### 🗺️ Maps et Navigation

#### Map 1 - Le Donjon Principal
- **Taille** : 50x50 tiles (16px par tile = 800x800px)
- **Contenu** :
  - 3 clés dispersées stratégiquement
  - 3 EnemyKnight avec zones de patrouille
  - 1 TreePortal (apparaît après collection des 3 clés)
- **Point de spawn** : (5, 5)

#### Map 2 - La Zone Dimensionnelle
- **Taille** : 50x50 tiles (16px par tile = 800x800px)
- **Particularité** : **Contrôles inversés !**
  - Haut → Bas
  - Bas → Haut
  - Gauche → Droite
  - Droite → Gauche
- **Contenu** :
  - Message "Je me sens étourdi..." (explique l'inversion)
  - 1 ExitDoor (porte de sortie finale)
- **Point de spawn** : (5, 5)

### 🎨 Graphismes et Animations

#### Sprite du Joueur (Serek)
- **Fichier** : `Serek.png` (64x496px)
- **Configuration** : Grille 4x31 de sprites 16x16
- **Animations** : 8 directions (idle + run pour down/left/right/up)
- **Framerate** : 0.15s par frame (idle), 0.08s (run)

#### Effets Visuels
- Barre de vie sur le personnage (verte → rouge)
- Barre de vie dans le HUD (en haut à gauche)
- Inventaire avec icônes de clés (en haut)
- Lumière verte autour du portail
- Lueur ambrée autour de la porte de sortie
- Étoiles animées dans les cinématiques

### 🎬 Écrans et UI

1. **Menu Principal** (`HomeScreen`)
   - Bouton "Commencer l'Aventure"
   - Lance l'intro narrative

2. **Synopsis Introductif** (`StoryIntroScreen`)
   - 5 pages d'histoire
   - Auto-avance après 5 secondes
   - Navigation manuelle (Précédent/Suivant/Passer)

3. **Écran de Jeu** (`GameScreen`)
   - Vue top-down avec caméra qui suit le joueur
   - Zoom : 25 tiles visibles
   - Overlays : Inventaire + Barre de vie
   - Messages contextuels (portail, dizzy)

4. **Game Over** (`GameOverOverlay`)
   - Apparaît à la mort du joueur
   - Bouton "Rejouer" pour recommencer

5. **Cinématique de Fin** (`EndGameCinematic`)
   - 5 pages de conclusion
   - Auto-avance après 4 secondes
   - Retour au menu après la fin

### 🐛 Corrections et Optimisations

#### Gestion du Focus Clavier
- FocusNode persistant pour maintenir le contrôle clavier
- Triple `clearKeys()` lors des messages (évite les touches bloquées)
- Gestion des KeyDown (bloqués pendant overlays) vs KeyUp (toujours traités)

#### Prévention de Bugs
- Flag `_hasTriggered` pour éviter déclenchements multiples de la porte
- `Future.microtask()` pour navigation dans le bon contexte
- Vérification `mounted` avant setState
- Auto-cancellation des timers dans dispose()

### 📂 Structure du Projet

```
lib/
├── main.dart                          # Point d'entrée
├── screens/
│   ├── home_screen.dart              # Menu principal
│   ├── game_screen.dart              # Écran de jeu principal
│   ├── story_intro_screen.dart       # Synopsis de début
│   └── end_game_cinematic.dart       # Cinématique de fin
├── components/
│   ├── knight.dart                   # Joueur (Serek)
│   ├── enemy_knight.dart             # Ennemis
│   ├── game-items/
│   │   ├── key.dart                  # Clés collectables
│   │   ├── tree_portal.dart          # Portail dimensionnel
│   │   └── exit_door.dart            # Porte de sortie
│   └── ui/
│       ├── player_life_bar.dart      # Barre de vie HUD
│       ├── game_over_overlay.dart    # Écran de mort
│       ├── portal_unlocked_message.dart
│       └── dizzy_message.dart        # Message contrôles inversés
└── util/
    └── player_sprite_sheet.dart      # Configuration sprites Serek

assets/
├── images/
│   ├── player/
│   │   └── Serek.png                 # Sprite du joueur
│   ├── items/
│   │   ├── key_*.png                 # Sprites des clés
│   │   └── escalier.png              # Portail
│   └── tiled/
│       ├── map.json                  # Map 1 (Tiled)
│       └── tile_set.png              # Tileset
└── images/tiled2/
    ├── map2.json                     # Map 2 (Tiled)
    └── tile_set.png                  # Tileset map 2
```

## 🚀 Installation et Lancement

### Prérequis
- Flutter SDK (version stable)
- Dart SDK
- Un éditeur (VS Code recommandé)

### Installation
```bash
# Cloner le projet
git clone <repository-url>
cd app

# Installer les dépendances
flutter pub get

# Lancer le jeu
flutter run
```

### Plateformes Supportées
- ✅ Windows
- ✅ macOS
- ✅ Linux
- ✅ Web
- ✅ Android
- ✅ iOS

## 🎮 Guide de Jeu

### Conseils Stratégiques
1. **Explorez méthodiquement** : Les clés sont dispersées dans tout le donjon
2. **Combattez prudemment** : Gardez un œil sur votre barre de vie
3. **Utilisez les murs** : Attirez les ennemis dans des espaces restreints
4. **Restez mobile** : Les ennemis attaquent toutes les 0.8 secondes
5. **Préparez-vous** : Les contrôles inversés sur la map 2 peuvent surprendre !

### Séquence Complète
1. ⚔️ **Début** : Synopsis de 5 pages racontant l'histoire
2. 🗺️ **Map 1** : Collecter 3 clés + combattre 3 gardiens
3. ✨ **Portail débloqué** : Message "Portail Débloqué !" (4 secondes)
4. 🌀 **Téléportation** : Passage vers la dimension alternative
5. 😵 **Map 2** : Message "Je me sens étourdi..." + contrôles inversés
6. 🚪 **Porte de sortie** : Trouver et atteindre la ExitDoor
7. 🎬 **Cinématique** : 5 scènes de conclusion
8. 🏠 **Retour** : Menu principal

## 🛠️ Technologies Utilisées

- **Flutter** : Framework UI cross-platform
- **Bonfire** : Moteur de jeu 2D RPG (basé sur Flame)
- **Tiled** : Éditeur de cartes 2D
- **Dart** : Langage de programmation

## 📝 Crédits

- **Développement** : Projet Flutter Game
- **Moteur** : Bonfire Engine
- **Assets** : Sprites personnalisés + Tileset

## 📄 Licence

Ce projet est un projet éducatif développé dans le cadre d'un apprentissage Flutter/Bonfire.

---

**Bon jeu et bonne évasion ! 🎮✨**
