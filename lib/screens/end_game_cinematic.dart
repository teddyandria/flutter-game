import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

class EndGameCinematic extends StatefulWidget {
  const EndGameCinematic({Key? key}) : super(key: key);

  @override
  State<EndGameCinematic> createState() => _EndGameCinematicState();
}

class _EndGameCinematicState extends State<EndGameCinematic> with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  int _currentPage = 0;
  Timer? _autoAdvanceTimer;
  
  final List<EndingPage> _endingPages = [
    EndingPage(
      title: "La Porte de la Liberté",
      text: "Après avoir traversé les portails dimensionnels,\n"
            "Serek a finalement trouvé la porte de sortie...",
      isEnding: false,
    ),
    EndingPage(
      title: "Les Épreuves Surmontées",
      text: "Les défis étaient nombreux,\n"
            "les ennemis redoutables,\n"
            "mais rien ne pouvait arrêter sa détermination.",
      isEnding: false,
    ),
    EndingPage(
      title: "Le Courage Récompensé",
      text: "Grâce à son courage et sa persévérance,\n"
            "Serek a surmonté tous les obstacles\n"
            "et déjoué les pièges du donjon maudit.",
      isEnding: false,
    ),
    EndingPage(
      title: "Une Nouvelle Vie",
      text: "La porte s'ouvre enfin devant lui.\n"
            "La lumière du monde extérieur l'éblouit.\n"
            "Une nouvelle vie pleine d'espoir commence...",
      isEnding: false,
    ),
    EndingPage(
      title: "🏆 FÉLICITATIONS ! 🏆",
      text: "Vous avez terminé le jeu !\n\n"
            "Merci d'avoir accompagné Serek\n"
            "dans son évasion épique !",
      isEnding: true,
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
    _startAutoAdvanceTimer();
  }

  void _startAutoAdvanceTimer() {
    _autoAdvanceTimer?.cancel();
    _autoAdvanceTimer = Timer(const Duration(seconds: 4), () {
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
    if (_currentPage < _endingPages.length - 1) {
      setState(() {
        _currentPage++;
      });
      _fadeController.forward(from: 0);
      _startAutoAdvanceTimer();
    } else {
      _returnToMenu();
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

  void _skipToEnd() {
    setState(() {
      _currentPage = _endingPages.length - 1;
    });
    _fadeController.forward(from: 0);
    _autoAdvanceTimer?.cancel();
  }

  void _returnToMenu() {
    _autoAdvanceTimer?.cancel();
    Navigator.of(context).pushNamedAndRemoveUntil(
      '/',
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentPage = _endingPages[_currentPage];
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: currentPage.isEnding
                ? [
                    Colors.amber.shade900,
                    Colors.orange.shade800,
                    Colors.amber.shade900,
                  ]
                : [
                    Colors.black,
                    Colors.grey.shade900,
                    Colors.black,
                  ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              ...List.generate(40, (index) {
                return Positioned(
                  left: (index * 37) % MediaQuery.of(context).size.width,
                  top: (index * 73) % MediaQuery.of(context).size.height,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Icon(
                      currentPage.isEnding ? Icons.star : Icons.star_border,
                      color: Colors.white.withOpacity(currentPage.isEnding ? 0.7 : 0.2),
                      size: currentPage.isEnding ? 15 + (index % 5) * 4 : 8 + (index % 4) * 2,
                    ),
                  ),
                );
              }),
              
              Center(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 40),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (currentPage.isEnding)
                          Icon(
                            Icons.emoji_events,
                            size: 100,
                            color: Colors.amber.shade300,
                          ),
                        
                        if (currentPage.isEnding)
                          const SizedBox(height: 30),
                        
                        Text(
                          currentPage.title,
                          style: TextStyle(
                            fontSize: currentPage.isEnding ? 48 : 42,
                            fontWeight: FontWeight.bold,
                            color: currentPage.isEnding 
                                ? Colors.amber.shade300
                                : Colors.amber.shade400,
                            shadows: [
                              Shadow(
                                color: currentPage.isEnding 
                                    ? Colors.amber.shade700
                                    : Colors.amber.shade800,
                                blurRadius: 25,
                                offset: const Offset(0, 0),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        
                        const SizedBox(height: 40),
                        
                        Container(
                          padding: const EdgeInsets.all(35),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: currentPage.isEnding 
                                  ? Colors.amber.shade400
                                  : Colors.grey.shade600,
                              width: 2,
                            ),
                            boxShadow: currentPage.isEnding
                                ? [
                                    BoxShadow(
                                      color: Colors.amber.shade700.withOpacity(0.5),
                                      blurRadius: 30,
                                      spreadRadius: 5,
                                    ),
                                  ]
                                : null,
                          ),
                          child: Text(
                            currentPage.text,
                            style: TextStyle(
                              fontSize: currentPage.isEnding ? 24 : 20,
                              height: 1.8,
                              color: Colors.white,
                              letterSpacing: 0.5,
                              fontWeight: currentPage.isEnding 
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        
                        const SizedBox(height: 40),
                        
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(_endingPages.length, (index) {
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
              
              Positioned(
                bottom: 30,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
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
                    
                    TextButton(
                      onPressed: _currentPage == _endingPages.length - 1 
                          ? _returnToMenu 
                          : _skipToEnd,
                      child: Text(
                        _currentPage == _endingPages.length - 1
                            ? 'Retour au menu'
                            : 'Passer >>',
                        style: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    
                    Padding(
                      padding: const EdgeInsets.only(right: 40),
                      child: ElevatedButton.icon(
                        onPressed: _currentPage == _endingPages.length - 1
                            ? _returnToMenu
                            : _nextPage,
                        icon: Icon(
                          _currentPage == _endingPages.length - 1
                              ? Icons.home
                              : Icons.arrow_forward,
                        ),
                        label: Text(
                          _currentPage == _endingPages.length - 1
                              ? 'Menu Principal'
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

class EndingPage {
  final String title;
  final String text;
  final bool isEnding;

  EndingPage({
    required this.title,
    required this.text,
    this.isEnding = false,
  });
}
