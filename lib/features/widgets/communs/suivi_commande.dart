import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../models/commande.dart';
import '../../../models/enums.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';

/// Couleur pastel vert utilisée pour le fond de la carte « étape en
/// cours ». Single source of truth — pas de rainbow ailleurs.
const Color _kPastelVert = Color(0xFFE8F5E9);

/// Suivi de commande low-tech : **stepper horizontal** en haut (4 pills
/// numérotés, vert pour passé/courant, gris pour futur) + **une seule
/// grosse carte** en dessous qui décrit l'étape courante.
///
/// 4 étapes alignées sur le cycle de vie utilisateur :
///
/// ```
/// ①────②────③────④
/// Payée Prép  Livr  Livrée
/// ```
///
/// Mapping `OrderStatus` → étape :
/// - `sent` → ① Payée (paiement confirmé, en attente du vendeur)
/// - `accepted` → ② Préparation (vendeur prépare le colis)
/// - `inProgress` → ③ En livraison (transporteur en route)
/// - `delivered`, `completed` → ④ Livrée (livraison confirmée)
///
/// États terminaux **non représentés dans le stepper** mais affichés
/// comme un bandeau plein (la commande est figée, plus d'étape à venir) :
/// - `rejected` (producteur refuse) OU `cancelled` (acheteur annule) →
///   **Annulée** unifié (un seul libellé, peu importe qui a annulé).
/// - `disputed` → **Litige** (orange, indique l'intervention du support).
///
/// Visibilité par rôle :
/// - **acheteur** : voit les 4 étapes complètes.
/// - **producteur** : voit les 4 étapes — la première (« Payée ») est
///   sa garantie que l'acheteur a réellement déposé l'argent en escrow.
class SuiviCommande extends StatelessWidget {
  const SuiviCommande({
    required this.commande,
    required this.viewerIsBuyer,
    this.montantNet,
    super.key,
  });

  /// Commande à afficher.
  final Commande commande;

  /// `true` côté acheteur, `false` côté producteur. Change uniquement
  /// les libellés ("ton paiement" vs "le paiement de l'acheteur") —
  /// les 4 étapes restent identiques pour les deux rôles.
  final bool viewerIsBuyer;

  /// Montant net affiché sur la dernière étape côté producteur (« tu
  /// reçois X F »). Si null, on retombe sur `commande.montantTotal`.
  /// Ignoré côté acheteur.
  final double? montantNet;

  @override
  Widget build(BuildContext context) {
    // Cas terminaux : on remplace TOUT le stepper par un bandeau plein,
    // ces commandes n'ont plus de cycle de vie en cours.
    if (_estAnnulee(commande.status)) {
      return _BandeauAnnulee(viewerIsBuyer: viewerIsBuyer);
    }
    if (commande.status == OrderStatus.disputed) {
      return _BandeauLitige(viewerIsBuyer: viewerIsBuyer);
    }

    // Cycle normal : stepper 4 étapes + carte de l'étape courante.
    final steps = _stepsFor();
    final currentIndex = _resolveCurrentIndex(commande.status);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Stepper(steps: steps, currentIndex: currentIndex),
        const SizedBox(height: 16),
        _CurrentStepCard(
          step: _safeStep(steps, currentIndex),
          isFinished: currentIndex >= steps.length - 1 &&
              (commande.status == OrderStatus.completed ||
                  commande.status == OrderStatus.delivered),
        ),
      ],
    );
  }

  /// Vrai pour tous les statuts qu'on regroupe sous "Annulée" — qu'ils
  /// soient initiés par le producteur (rejected) ou l'acheteur
  /// (cancelled). Du point de vue utilisateur, c'est le même résultat.
  bool _estAnnulee(OrderStatus s) =>
      s == OrderStatus.rejected || s == OrderStatus.cancelled;

  /// Renvoie l'étape active. Bornes : [0, steps.length - 1].
  int _resolveCurrentIndex(OrderStatus status) {
    switch (status) {
      case OrderStatus.sent:
        return 0; // Payée — vendeur n'a pas encore accepté
      case OrderStatus.accepted:
        return 1; // Préparation
      case OrderStatus.inProgress:
        return 2; // En livraison
      case OrderStatus.delivered:
      case OrderStatus.completed:
        return 3; // Livrée
      case OrderStatus.cancelled:
      case OrderStatus.rejected:
      case OrderStatus.disputed:
      case OrderStatus.unknown:
        // Inatteignable normalement : les cas terminaux sont gérés en
        // amont via le bandeau plein. Sécurité : on retombe sur l'étape
        // 0 pour éviter un crash.
        return 0;
    }
  }

  _Etape _safeStep(List<_Etape> steps, int currentIndex) {
    if (currentIndex < 0) return steps.first;
    if (currentIndex >= steps.length) return steps.last;
    return steps[currentIndex];
  }

  List<_Etape> _stepsFor() {
    final df = DateFormat('d MMM · HH\'h\'mm', 'fr_FR');
    final createdLabel = commande.createdAt != null
        ? df.format(commande.createdAt!)
        : '—';
    final livraisonLabel = commande.livraisonDate != null
        ? 'Prévu ${DateFormat('d MMM', 'fr_FR').format(commande.livraisonDate!)}'
        : 'À planifier';
    final montant = montantNet ?? commande.montantTotal;
    final netLabel =
        NumberFormat('#,##0', 'fr_FR').format(montant.round());
    final totalLabel =
        NumberFormat('#,##0', 'fr_FR').format(commande.montantTotal.round());

    return <_Etape>[
      // ① Payée — paiement reçu en escrow, attend le vendeur.
      _Etape(
        icone: Icons.lock_outline,
        labelCourt: 'Payée',
        titre: viewerIsBuyer
            ? 'Paiement confirmé'
            : 'Paiement reçu en escrow',
        message: viewerIsBuyer
            ? 'Ton paiement de $totalLabel F est sécurisé chez FarmCash '
                'depuis le $createdLabel. Le vendeur va l\'accepter sous '
                'peu et préparer ton colis.'
            : 'L\'acheteur a déposé $totalLabel F en escrow le '
                '$createdLabel. À toi d\'accepter et de préparer le colis.',
      ),
      // ② Préparation — le vendeur prépare le colis.
      _Etape(
        icone: Icons.inventory_2_outlined,
        labelCourt: 'Préparation',
        titre: viewerIsBuyer
            ? 'Le vendeur prépare ton colis'
            : 'Prépare le colis',
        message: viewerIsBuyer
            ? 'Le vendeur a accepté ta commande. Il prépare l\'envoi. '
                'Tu seras notifié quand un transporteur prendra le colis.'
            : 'Tu as accepté la commande. Prépare le colis pour le '
                'transporteur qui viendra l\'enlever bientôt.',
      ),
      // ③ En livraison — transporteur en route avec le colis.
      _Etape(
        icone: Icons.local_shipping_outlined,
        labelCourt: 'En livraison',
        titre: 'Transporteur en route',
        message: viewerIsBuyer
            ? 'Le transporteur a pris le colis chez le vendeur et roule '
                'vers toi. $livraisonLabel.'
            : 'Le transporteur a récupéré le colis et roule vers '
                'l\'acheteur. $livraisonLabel.',
      ),
      // ④ Livrée — livraison confirmée par scan QR, escrow libéré.
      _Etape(
        icone: Icons.check_circle_outline,
        labelCourt: 'Livrée',
        titre: viewerIsBuyer
            ? 'Commande livrée · paiement libéré'
            : 'Livraison confirmée · tu es payé',
        message: viewerIsBuyer
            ? 'Tu as scanné ton QR de réception. Le paiement a été '
                'libéré au vendeur. Merci pour ta commande !'
            : 'L\'acheteur a confirmé la réception. → Tu reçois '
                '$netLabel F dans ton wallet.',
      ),
    ];
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

  /// Libellé court affiché sous le numéro dans le stepper horizontal.
  /// Doit tenir sur une ligne ≤ 12 chars.
  final String labelCourt;

  final String titre;
  final String message;
}

/// Stepper horizontal : 4 cercles numérotés reliés par une ligne, avec
/// libellé court sous chaque cercle. Brand vert pour passé + courant,
/// gris pour futur. Aucune palette additive.
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
        final leftIndex = (i - 1) ~/ 2;
        final done = leftIndex < currentIndex;
        return SizedBox(
          width: 12,
          child: Padding(
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
            width: 1,
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

// ─── États terminaux (remplacent le stepper) ──────────────────────────

/// Bandeau plein "Annulée" — unifie rejected (producteur refuse) et
/// cancelled (acheteur annule) en un seul état terminal. Du point de
/// vue utilisateur, le résultat est le même : commande arrêtée,
/// paiement remboursé.
class _BandeauAnnulee extends StatelessWidget {
  const _BandeauAnnulee({required this.viewerIsBuyer});

  final bool viewerIsBuyer;

  @override
  Widget build(BuildContext context) {
    return _BandeauTerminal(
      icone: Icons.cancel_outlined,
      couleur: AppColors.error,
      fond: const Color(0xFFFEE2E2),
      titre: 'Commande annulée',
      message: viewerIsBuyer
          ? 'Cette commande a été annulée. Ton paiement a été remboursé '
              'automatiquement sur ton wallet.'
          : 'Cette commande a été annulée. L\'acheteur a été remboursé.',
    );
  }
}

/// Bandeau plein "Litige" — la commande est gelée jusqu'à résolution
/// par le support FarmCash. Couleur orange (attention, action requise)
/// pour la distinguer d'annulée (rouge, état définitif).
class _BandeauLitige extends StatelessWidget {
  const _BandeauLitige({required this.viewerIsBuyer});

  final bool viewerIsBuyer;

  @override
  Widget build(BuildContext context) {
    return _BandeauTerminal(
      icone: Icons.warning_amber_outlined,
      couleur: const Color(0xFFB45309),
      fond: const Color(0xFFFFF3CD),
      titre: 'Litige en cours',
      message: viewerIsBuyer
          ? 'Un litige a été ouvert sur cette commande. Le support '
              'FarmCash est en train de l\'examiner — tu seras contacté '
              'sous peu.'
          : 'Un litige a été ouvert sur cette commande. Le support '
              'FarmCash s\'en occupe et te contactera si besoin.',
    );
  }
}

/// Layout commun pour les bandeaux d'état terminal (annulée / litige).
class _BandeauTerminal extends StatelessWidget {
  const _BandeauTerminal({
    required this.icone,
    required this.couleur,
    required this.fond,
    required this.titre,
    required this.message,
  });

  final IconData icone;
  final Color couleur;
  final Color fond;
  final String titre;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: fond,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: couleur.withValues(alpha: 0.3),
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
            child: Icon(icone, size: 22, color: couleur),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  titre,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: couleur,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  message,
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
