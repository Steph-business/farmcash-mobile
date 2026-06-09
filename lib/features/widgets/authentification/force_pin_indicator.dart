import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';

/// Niveau de robustesse calculé pour un PIN saisi.
enum NiveauForcePin { vide, faible, moyen, fort }

/// Indicateur visuel sous le 1er PavePin (page « Définir un code PIN »).
/// Reflète la force du PIN tapé :
///   • Vide (caché)
///   • Faible : PIN court (<4) OU pattern évident (1111, 1234, 0000, 4321…)
///   • Moyen : PIN ok mais pas optimal (4-5 chiffres sans pattern)
///   • Fort : 6 chiffres sans pattern
///
/// Permet à l'utilisateur de comprendre AVANT submit que son PIN est
/// faible (vs erreur post-submit floue). Pattern banque/fintech sérieux.
class ForcePinIndicator extends StatelessWidget {
  const ForcePinIndicator({super.key, required this.pin});

  final String pin;

  @override
  Widget build(BuildContext context) {
    final niveau = _calculerNiveau(pin);
    if (niveau == NiveauForcePin.vide) {
      return const SizedBox.shrink();
    }

    final (couleur, label, ratio) = _visuelPourNiveau(niveau);

    return AnimatedSize(
      duration: const Duration(milliseconds: 150),
      child: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Row(
          children: [
            // Barre de progression à 3 segments
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: Container(
                  height: 6,
                  color: AppColors.border,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOut,
                      width: MediaQuery.of(context).size.width * ratio * 0.5,
                      color: couleur,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: AppTextStyles.labelSmall.copyWith(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: couleur,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Couleur + label + ratio largeur de la barre (0..1).
  (Color, String, double) _visuelPourNiveau(NiveauForcePin n) {
    switch (n) {
      case NiveauForcePin.faible:
        return (AppColors.error, 'Faible', 0.33);
      case NiveauForcePin.moyen:
        return (const Color(0xFFF59E0B), 'Moyen', 0.66);
      case NiveauForcePin.fort:
        return (AppColors.primary, 'Fort', 1.0);
      case NiveauForcePin.vide:
        return (AppColors.border, '', 0.0);
    }
  }
}

/// Calcule le niveau de force d'un PIN. Pure function — exposée pour
/// pouvoir tester indépendamment (rien à mocker).
@visibleForTesting
NiveauForcePin calculerNiveauForcePin(String pin) => _calculerNiveau(pin);

NiveauForcePin _calculerNiveau(String pin) {
  if (pin.isEmpty) return NiveauForcePin.vide;
  if (pin.length < 4) return NiveauForcePin.faible;

  // Pattern : tous les chiffres identiques (0000, 1111, 9999…)
  final tousIdentiques = pin.split('').toSet().length == 1;
  if (tousIdentiques) return NiveauForcePin.faible;

  // Pattern : séquence croissante ou décroissante (1234, 4321, 0123…)
  bool estSequence(String s) {
    for (var i = 1; i < s.length; i++) {
      final diff = s.codeUnitAt(i) - s.codeUnitAt(i - 1);
      if (diff != 1 && diff != -1) return false;
    }
    return true;
  }
  if (estSequence(pin)) return NiveauForcePin.faible;

  // Pattern courant CI : année naissance fréquente (19xx, 20xx) — on
  // pénalise pas ici (trop souvent légitime), mais on pourrait l'ajouter.

  // Sinon : moyen si 4-5 chiffres, fort si 6.
  if (pin.length < 6) return NiveauForcePin.moyen;
  return NiveauForcePin.fort;
}
