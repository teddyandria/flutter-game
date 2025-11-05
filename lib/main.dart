import 'package:app/screens/game_screen.dart';
import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/profile_screen.dart';

void main() {
  runApp(const MyApp());
}

/// Point d’entrée principal de l’application Flutter.
///
/// Configure les routes principales et applique le thème global.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter RPG Base',

      // Thème global pour une cohérence visuelle
      theme: ThemeData(primarySwatch: Colors.teal),

      // Écran affiché au démarrage de l’application
      initialRoute: '/',

      // Définition des routes nommées principales
      routes: {
        '/': (context) => const HomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/game': (context) => const GameScreen()
      },
    );
  }
}

