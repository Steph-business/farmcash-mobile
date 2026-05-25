import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../models/commande.dart';
import '../../../models/enums.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_dimens.dart';
import '../../../theme/app_text_styles.dart';

/// Couleur pastel vert utilisée pour le fond de la carte « étape en
/// cours ». Single source of truth — pas de rainbow ailleurs.
const Color _kPastelVert = Color(0xFFE8F5E9);

/// Suivi de commande low-tech : **stepper horizontal** en haut (pills
/// numérotés, vert pour passé/courant, gris pour futur) + **une seule
/// grosse carte** en dessous qui décrit l'étape courante.
///
/// Conçu pour un utilisateur peu scolarisé : il lit UN message à la
/// fois (l'étape actuelle), pas une liste à scroller. Le stepper sert
/// uniquement de repère visuel « où on en est dans le parcours ».
///
/// Palette unique : **brand vert** (`AppColors.primary`) pour tout ce
/// qui est validé/courant, gris pour tout ce qui est futur. Pas de mix
/// bleu/violet/orange — l'app a une identité verte, on la respecte.
///
/// IMPORTANT escrow : l'argent est libéré à la dernière étape (livraison
/// confirmée par l'acheteur), PAS à l'enlèvement par le transporteur.
/// Le backend déclenche `DELIVERY_CONFIRMED` à ce moment-là.
///
/// Visibilité par rôle :
///   - **acheteur** : voit les 6 étapes (Commande → Argent vendeur payé).
///   - **producteur** : voit seulement à partir de « Paiement bloqué en
///     escrow » (5 étapes) — l'étape « Commande passée » est purement
///     acheteur, le producteur n'a pas à la voir.
class SuiviCommande extends StatelessWidget {
  const SuiviCommande({
    required this.commande,
    required this.viewerIsBuyer,
    this.montantNet,
    super.key,
  });

  /// Commande à afficher.
  final Commande commande;

  /// `true` côté acheteur, `false` côté producteur (change le wording
  /// et filtre la première étape, qui ne concerne que l'acheteur).
  final bool viewerIsBuyer;

  /// Montant net affiché sur la dernière étape côté producteur (« tu
  /// reçois X F »). Si null, on retombe sur `commande.montantTotal`.
  /// Ignoré côté acheteur.
  final double? montantNet;

  @override
  Widget build(BuildContext context) {
    final steps = _stepsFor(commande, viewerIsBuyer);
    final currentIndex = _resolveCurrentIndex(commande.status, viewerIsBuyer);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Stepper(steps: steps, currentIndex: currentIndex),
        const SizedBox(height: 16),
        _CurrentStepCard(
          step: _safeStep(steps, currentIndex),
          isFinished: currentIndex >= steps.length,
        ),
      ],
    );
  }

  /// Renvoie l'étape à afficher dans la carte. Quand la commande est
  /// terminée, `currentIndex == steps.length` → on affiche la dernière
  /// étape comme « tout est fini ».
  _Etape _safeStep(List<_Etape> steps, int currentIndex) {
    if (currentIndex < 0) return steps.first;
    if (currentIndex >= steps.length) return steps.last;
    return steps[currentIndex];
  }

  /// Index de l'étape **active** dans la séquence visible par le rôle.
  /// `0` = première étape visible, `steps.length` = parcours terminé.
  int _resolveCurrentIndex(OrderStatus status, bool isBuyer) {
    // Séquence canonique (côté acheteur) : 0=Commande passée,
    // 1=Paiement escrow, 2=Préparation, 3=Transporteur, 4=Livraison QR,
    // 5=Argent libéré.
    final int absIndex;
    switch (status) {
      case OrderStatus.sent:
      case OrderStatus.accepted:
        absIndex = 2; // vendeur prépare
        break;
      case OrderStatus.inProgress:
        absIndex = 3; // transporteur en route
        break;
      case OrderStatus.delivered:
        absIndex = 4; // livraison faite, attente confirmation
        break;
      case OrderStatus.completed:
        absIndex = 5; // escrow libéré
        break;
      case OrderStatus.cancelled:
      case OrderStatus.rejected:
      case OrderStatus.disputed:
      case OrderStatus.unknown:
        absIndex = 0;
        break;
    }
    // Côté producteur, on cache la 1ère étape ("commande passée") →
    // on décale tous les index de 1 vers le bas.
    if (!isBuyer) {
      final shifted = absIndex - 1;
      return shifted < 0 ? 0 : shifted;
    }
    return absIndex;
  }

  List<_Etape> _stepsFor(Commande c, bool isBuyer) {
    final df = DateFormat('d MMM · HH\'h\'mm', 'fr_FR');
    final createdLabel = c.createdAt != null ? df.format(c.createdAt!) : '—';
    final livraisonLabel = c.livraisonDate != null
        ? 'Prévu ${DateFormat('d MMM', 'fr_FR').format(c.livraisonDate!)}'
        : 'À planifier';
    final montant = montantNet ?? c.montantTotal;
    final netLabel = NumberFormat('#,##0', 'fr_FR').format(montant.round());
    final totalLabel =
        NumberFormat('#,##0', 'fr_FR').format(c.montantTotal.round());

    final all = <_Etape>[
      // 0 — Commande passée : VISIBLE acheteur uniquement.
      _Etape(
        icone: Icons.shopping_bag_outlined,
        labelCourt: 'Commande',
        titre: 'Commande passée',
        message: 'Ta commande a été envoyée au vendeur le $createdLabel.',
      ),
      // 1 — Paiement bloqué.
      _Etape(
        icone: Icons.lock_outline,
        labelCourt: 'Escrow',
        titre: 'Paiement bloqué en escrow',
        message: isBuyer
            ? "Ton paiement de $totalLabel F est sécurisé. Il sera libéré au vendeur quand tu confirmeras la réception."
            : "$totalLabel F sont sécurisés chez FarmCash. Tu les recevras après la livraison confirmée.",
      ),
      // 2 — Préparation.
      _Etape(
        icone: Icons.inventory_2_outlined,
        labelCourt: 'Préparation',
        titre: isBuyer ? 'Vendeur prépare l\'envoi' : 'Prépare le colis',
        message: isBuyer
            ? 'Le vendeur prépare ta commande. Tu seras notifié dès l\'expédition.'
            : 'À ton tour. Quand le colis est prêt, marque la commande comme expédiée.',
      ),
      // 3 — Transporteur.
      _Etape(
        icone: Icons.local_shipping_outlined,
        labelCourt: 'Transport',
        titre: 'Transporteur en route',
        message: 'Le colis a été pris en charge. $livraisonLabel.',
      ),
      // 4 — Livraison.
      _Etape(
        icone: Icons.place_outlined,
        labelCourt: 'Livraison',
        titre: isBuyer
            ? 'Livraison + scan de mon QR'
            : 'Livraison à l\'acheteur',
        message: isBuyer
            ? 'Le transporteur te livre. Montre ton QR pour confirmer la réception et libérer le paiement.'
            : 'L\'acheteur scanne son QR pour confirmer la réception. Tu seras crédité juste après.',
      ),
      // 5 — Argent libéré.
      _Etape(
        icone: Icons.account_balance_wallet_outlined,
        labelCourt: 'Payé',
        titre: isBuyer
            ? 'Vendeur payé · commande terminée'
            : 'Argent dans ton wallet',
        message: isBuyer
            ? 'Tu as confirmé la réception. Le vendeur a été crédité et la commande est terminée.'
            : '→ Tu reçois $netLabel F. L\'argent est disponible dans ton wallet.',
      ),
    ];

    if (isBuyer) return all;
    // Producteur : on saute « Commande passée » (étape 0).
    return all.sublist(1);
  }
}

// ─── Internes ──────────────────────────────────────────────────────────

class _Etape {
  const _Etape({
    required this.icone,
    required this.labelCourt,
    required this.titre,
    required this.message,
  });

  final IconData icone;

  /// Libellé court affiché sous le numéro dans le stepper horizontal
  /// (« Commande », « Escrow », « Préparation », « Transport »,
  /// « Livraison », « Payé »). Doit tenir sur une ligne ≤ 10 chars.
  final String labelCourt;

  final String titre;
  final String message;
}

/// Stepper horizontal : cercles numérotés reliés par une ligne, avec
/// libellé court (« Commande », « Escrow »…) **sous** chaque cercle.
/// Brand vert pour passé + courant, gris pour futur. Aucune palette
/// additive.
class _Stepper extends StatelessWidget {
  const _Stepper({required this.steps, required this.currentIndex});

  final List<_Etape> steps;
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(steps.length * 2 - 1, (i) {
        if (i.isEven) {
          final stepIndex = i ~/ 2;
          return Expanded(
            child: _StepCell(
              number: stepIndex + 1,
              labelCourt: steps[stepIndex].labelCourt,
              state: _stateFor(stepIndex),
            ),
          );
        }
        // Connecteur entre deux dots — aligné sur la hauteur du dot
        // (30/24 px) pour rester droit visuellement.
        final leftIndex = (i - 1) ~/ 2;
        final done = leftIndex < currentIndex;
        return SizedBox(
          width: 12,
          child: Padding(
            // Décale le connecteur pour qu'il soit aligné avec le centre
            // vertical des dots (qui sont à hauteur 30px max).
            padding: const EdgeInsets.only(top: 14),
            child: Container(
              height: 2,
              color: done ? AppColors.primary : AppColors.border,
            ),
          ),
        );
      }),
    );
  }

  _DotState _stateFor(int index) {
    if (index < currentIndex) return _DotState.done;
    if (index == currentIndex) return _DotState.current;
    return _DotState.future;
  }
}

/// Une « cellule » de stepper = un cercle numéroté + un libellé court
/// dessous. Permet d'aligner les libellés en colonnes régulières.
class _StepCell extends StatelessWidget {
  const _StepCell({
    required this.number,
    required this.labelCourt,
    required this.state,
  });

  final int number;
  final String labelCourt;
  final _DotState state;

  @override
  Widget build(BuildContext context) {
    Color labelColor;
    FontWeight labelWeight;
    switch (state) {
      case _DotState.done:
        labelColor = AppColors.primary;
        labelWeight = FontWeight.w600;
        break;
      case _DotState.current:
        labelColor = AppColors.primary;
        labelWeight = FontWeight.w800;
        break;
      case _DotState.future:
        labelColor = AppColors.textSubtle;
        labelWeight = FontWeight.w500;
        break;
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _StepDot(number: number, state: state),
        const SizedBox(height: 6),
        Text(
          labelCourt,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: AppTextStyles.labelSmall.copyWith(
            fontSize: 11,
            fontWeight: labelWeight,
            color: labelColor,
            height: 1.1,
          ),
        ),
      ],
    );
  }
}

enum _DotState { done, current, future }

class _StepDot extends StatelessWidget {
  const _StepDot({required this.number, required this.state});

  final int number;
  final _DotState state;

  @override
  Widget build(BuildContext context) {
    switch (state) {
      case _DotState.done:
        return _circle(
          size: 24,
          color: AppColors.primary,
          child: const Icon(Icons.check, size: 14, color: Colors.white),
        );
      case _DotState.current:
        return _circle(
          size: 30,
          color: AppColors.primary,
          border: Border.all(color: _kPastelVert, width: 3),
          child: Text(
            '$number',
            style: AppTextStyles.labelSmall.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        );
      case _DotState.future:
        return _circle(
          size: 24,
          color: AppColors.background,
          border: Border.all(
            color: AppColors.border,
            width: AppDimens.borderThin,
          ),
          child: Text(
            '$number',
            style: AppTextStyles.labelSmall.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textSubtle,
            ),
          ),
        );
    }
  }

  Widget _circle({
    required double size,
    required Color color,
    required Widget child,
    Border? border,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: border,
      ),
      alignment: Alignment.center,
      child: child,
    );
  }
}

/// Carte « étape en cours » : icône + titre + message clair. Une seule
/// info à la fois pour ne pas noyer l'utilisateur.
class _CurrentStepCard extends StatelessWidget {
  const _CurrentStepCard({required this.step, required this.isFinished});

  final _Etape step;
  final bool isFinished;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _kPastelVert,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.25),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: const BoxDecoration(
              color: AppColors.background,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(
              step.icone,
              size: 20,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        step.titre,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        isFinished ? 'Terminé' : 'En cours',
                        style: AppTextStyles.labelSmall.copyWith(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  step.message,
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 14,
                    color: AppColors.text,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
