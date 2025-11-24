import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

class StoryIntroScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const StoryIntroScreen({Key? key, required this.onComplete}) : super(key: key);

  @override
  State<StoryIntroScreen> createState() => _StoryIntroScreenState();
}

class _StoryIntroScreenState extends State<StoryIntroScreen> with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  int _currentPage = 0;
  Timer? _autoAdvanceTimer;
  
  final List<StoryPage> _storyPages = [
    StoryPage(
      title: "Le Réveil dans les Ténèbres",
      text: "Serek se réveille brutalement dans l'obscurité d'un donjon humide et glacial. "
            "Ses souvenirs sont flous... Comment est-il arrivé ici ? Qui l'a enfermé ?",
      imagePath: null,
    ),
    StoryPage(
      title: "La Prophétie Oubliée",
      text: "Sur les murs du donjon, d'anciennes inscriptions révèlent une prophétie : "
            "Trois Clés Sacrées - la Clé d'Or de la Sagesse, la Clé Bleue du Courage, "
            "et la Clé Verte de l'Espoir - sont cachées dans ce labyrinthe.",
      imagePath: null,
    ),
    StoryPage(
      title: "Le Portail de la Liberté",
      text: "Seul celui qui réunit les trois clés pourra ouvrir le Portail Dimensionnel "
            "et s'échapper de ce donjon maudit vers un monde meilleur... "
            "C'est la seule issue possible !",
      imagePath: null,
    ),
    StoryPage(
      title: "Les Gardiens Corrompus",
      text: "Attention ! Des chevaliers corrompus par une magie obscure patrouillent dans le donjon. "
            "Ils protègent jalousement les clés et attaqueront tout prisonnier qui tente de s'échapper...",
      imagePath: null,
    ),
    StoryPage(
      title: "Votre Mission : S'Évader !",
      text: "Explorez le donjon, trouvez les trois clés cachées, affrontez les gardiens, "
            "et ouvrez le portail pour retrouver votre liberté ! "
            "Votre survie en dépend...",
      imagePath: null,
    ),
  ];

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );
    
    _fadeController.forward();
    
    // Auto-avance après 5 secondes
    _startAutoAdvanceTimer();
  }

  void _startAutoAdvanceTimer() {
    _autoAdvanceTimer?.cancel();
    _autoAdvanceTimer = Timer(const Duration(seconds: 5), () {
      if (mounted) {
        _nextPage();
      }
    });
  }

  @override
  void dispose() {
    _autoAdvanceTimer?.cancel();
    _fadeController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _storyPages.length - 1) {
      setState(() {
        _currentPage++;
      });
      _fadeController.forward(from: 0);
      _startAutoAdvanceTimer();
    } else {
      _finishIntro();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      setState(() {
        _currentPage--;
      });
      _fadeController.forward(from: 0);
      _startAutoAdvanceTimer();
    }
  }

  void _skipIntro() {
    _autoAdvanceTimer?.cancel();
    _finishIntro();
  }

  void _finishIntro() {
    _fadeController.reverse().then((_) {
      widget.onComplete();
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentStory = _storyPages[_currentPage];
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black,
              Colors.grey.shade900,
              Colors.black,
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Étoiles animées en arrière-plan
              ...List.generate(50, (index) {
                return Positioned(
                  left: (index * 37) % MediaQuery.of(context).size.width,
                  top: (index * 73) % MediaQuery.of(context).size.height,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Icon(
                      Icons.star,
                      color: Colors.white.withOpacity(0.3),
                      size: 8 + (index % 4) * 2,
                    ),
                  ),
                );
              }),
              
              // Contenu principal
              Center(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 40),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Titre
                        Text(
                          currentStory.title,
                          style: TextStyle(
                            fontSize: 42,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber.shade300,
                            shadows: [
                              Shadow(
                                color: Colors.amber.shade700,
                                blurRadius: 20,
                                offset: const Offset(0, 0),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        
                        const SizedBox(height: 40),
                        
                        // Texte de l'histoire
                        Container(
                          padding: const EdgeInsets.all(30),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.amber.shade700.withOpacity(0.5),
                              width: 2,
                            ),
                          ),
                          child: Text(
                            currentStory.text,
                            style: const TextStyle(
                              fontSize: 20,
                              height: 1.8,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        
                        const SizedBox(height: 40),
                        
                        // Indicateurs de page
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(_storyPages.length, (index) {
                            return Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              width: index == _currentPage ? 30 : 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: index == _currentPage 
                                    ? Colors.amber.shade400
                                    : Colors.grey.shade600,
                                borderRadius: BorderRadius.circular(5),
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              // Boutons de navigation
              Positioned(
                bottom: 30,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Bouton Précédent
                    Padding(
                      padding: const EdgeInsets.only(left: 40),
                      child: _currentPage > 0
                          ? ElevatedButton.icon(
                              onPressed: _previousPage,
                              icon: const Icon(Icons.arrow_back),
                              label: const Text('Précédent'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey.shade800,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 16,
                                ),
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                    
                    // Bouton Passer
                    TextButton(
                      onPressed: _skipIntro,
                      child: Text(
                        'Passer >>',
                        style: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    
                    // Bouton Suivant / Commencer
                    Padding(
                      padding: const EdgeInsets.only(right: 40),
                      child: ElevatedButton.icon(
                        onPressed: _nextPage,
                        icon: Icon(
                          _currentPage == _storyPages.length - 1
                              ? Icons.play_arrow
                              : Icons.arrow_forward,
                        ),
                        label: Text(
                          _currentPage == _storyPages.length - 1
                              ? 'Commencer !'
                              : 'Suivant',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber.shade700,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                          textStyle: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class StoryPage {
  final String title;
  final String text;
  final String? imagePath;

  StoryPage({
    required this.title,
    required this.text,
    this.imagePath,
  });
}
