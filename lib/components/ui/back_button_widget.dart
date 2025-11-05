import 'package:flutter/material.dart';

/// Bouton de retour réutilisable pour les écrans du jeu.
///
/// Ce composant peut être placé dans n’importe quel écran nécessitant
/// une navigation vers la page précédente ou le menu principal.
class BackButtonWidget extends StatelessWidget {
  final VoidCallback? onPressed;
  final String label;

  const BackButtonWidget({
    super.key,
    this.onPressed,
    this.label = 'Retour',
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: Alignment.topLeft,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black54,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: onPressed ?? () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back),
            label: Text(label),
          ),
        ),
      ),
    );
  }
}

