import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../models/enums.dart';
import '../../../../models/negociation.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import 'carte_garanties_coop.dart';

const Color _kPrimarySoft = Color(0xFFE8F5E9);

final NumberFormat _nf = NumberFormat('#,##0', 'fr_FR');

/// Apparence du badge statut sur une proposition (couleur + libellé
/// humanisés). On évite l'enum brut « ACCEPTED » qui n'est pas naturel
/// pour un acheteur low-tech.
class _StatutVisuel {
  const _StatutVisuel({
    required this.label,
    required this.background,
    required this.foreground,
  });
  final String label;
  final Color background;
  final Color foreground;
}

_StatutVisuel _visuelPourStatut(NegotiationStatus s) {
  switch (s) {
    case NegotiationStatus.accepted:
      return const _StatutVisuel(
        label: 'Acceptée',
        background: _kPrimarySoft,
        foreground: AppColors.primary,
      );
    case NegotiationStatus.rejected:
      return const _StatutVisuel(
        label: 'Refusée',
        background: Color(0xFFFEE2E2),
        foreground: AppColors.error,
      );
    case NegotiationStatus.cancelled:
      return const _StatutVisuel(
        label: 'Annulée',
        background: Color(0xFFE5E7EB),
        foreground: Color(0xFF6B7280),
      );
    case NegotiationStatus.counterOffered:
      return const _StatutVisuel(
        label: 'Contre-offre',
        background: Color(0xFFDBEAFE),
        foreground: Color(0xFF1D4ED8),
      );
    case NegotiationStatus.pending:
    case NegotiationStatus.unknown:
      return const _StatutVisuel(
        label: 'En attente',
        background: Color(0xFFFEF3C7),
        foreground: Color(0xFFB45309),
      );
  }
}

/// Une proposition n'est plus actionnable une fois qu'elle a quitté l'état
/// PENDING/COUNTER_OFFERED. Dans ces cas-là on retire les boutons
/// Accepter / Refuser (qui généreraient une « Transition impossible » côté
/// backend) — on garde juste Discuter, qui reste utile pour échanger sur
/// la commande déjà créée.
bool _peutAccepterOuRefuser(NegotiationStatus s) =>
    s == NegotiationStatus.pending ||
    s == NegotiationStatus.counterOffered;

/// Carte d'une proposition recue sur une demande d'achat.
/// Affiche photo + nom du produit en en-tête, puis prix, quantité, note
/// du producteur et actions accepter/refuser/discuter.
class CartePropositionDemande extends StatelessWidget {
  const CartePropositionDemande({
    super.key,
    required this.proposition,
    required this.isBest,
    required this.busy,
    required this.onAccepter,
    required this.onRefuser,
    required this.onDiscuter,
    this.produitNom,
    this.produitPhotoUrl,
  });

  final Proposition proposition;
  final bool isBest;
  final bool busy;
  final VoidCallback onAccepter;
  final VoidCallback onRefuser;
  final VoidCallback onDiscuter;

  /// Nom du produit demandé (issu de la `AnnonceAchat` source). Null si
  /// l'appelant n'a pas pu le résoudre — on affiche alors "Produit" en
  /// placeholder.
  final String? produitNom;

  /// URL de la photo du produit (catalogue ou hint visuel). Null →
  /// icône eco_outlined verte.
  final String? produitPhotoUrl;

  @override
  Widget build(BuildContext context) {
    final note = proposition.message?.trim();
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isBest ? AppColors.primary : AppColors.border,
              width: AppDimens.borderThin,
            ),
          ),
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Carte unique : produit (photo + nom) + quantité + prix
              // réunis dans une seule boîte pour scannabilité maximale.
              _OfferBox(
                proposition: proposition,
                produitNom: produitNom?.trim().isNotEmpty == true
                    ? produitNom!.trim()
                    : 'Produit',
                produitPhotoUrl: produitPhotoUrl,
              ),
              // Bandeau « Garanties » UNIQUEMENT si la proposition vient
              // d'une coopérative (vs un farmer individuel). Affiche le
              // nb de membres, la note + rappel escrow pour rassurer
              // l'acheteur sur les gros engagements coop.
              if (proposition.isFromCooperative &&
                  proposition.vendeur != null) ...[
                const SizedBox(height: 10),
                CarteGarantiesCoop(vendeur: proposition.vendeur!),
              ],
              if (note != null && note.isNotEmpty) ...[
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSoft,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.border,
                      width: AppDimens.borderThin,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  child: Text(
                    '« $note »',
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 10),
              _Actions(
                busy: busy,
                statut: proposition.status,
                onRefuser: onRefuser,
                onDiscuter: onDiscuter,
                onAccepter: onAccepter,
              ),
            ],
          ),
        ),
        if (isBest)
          Positioned(
            top: -9,
            left: 14,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: _kPrimarySoft,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: AppColors.primary,
                  width: AppDimens.borderThin,
                ),
              ),
              child: Text(
                'Meilleur prix',
                style: AppTextStyles.labelSmall.copyWith(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Carte unique de la proposition : à gauche photo+nom du produit puis
/// quantité + statut empilés ; à droite le prix mis en avant. Tout est
/// dans un seul container pastel pour lisibilité maximale low-tech.
class _OfferBox extends StatelessWidget {
  const _OfferBox({
    required this.proposition,
    required this.produitNom,
    required this.produitPhotoUrl,
  });

  final Proposition proposition;
  final String produitNom;
  final String? produitPhotoUrl;

  @override
  Widget build(BuildContext context) {
    final hasPhoto =
        produitPhotoUrl != null && produitPhotoUrl!.trim().isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── Photo / icône produit (gauche) ────────────────────────
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: 52,
              height: 52,
              child: hasPhoto
                  ? CachedNetworkImage(
                      imageUrl: produitPhotoUrl!,
                      fit: BoxFit.cover,
                      placeholder: (_, _) => Container(
                        color: _kPrimarySoft,
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.eco_outlined,
                          size: 22,
                          color: AppColors.primary,
                        ),
                      ),
                      errorWidget: (_, _, _) => Container(
                        color: _kPrimarySoft,
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.eco_outlined,
                          size: 22,
                          color: AppColors.primary,
                        ),
                      ),
                    )
                  : Container(
                      color: _kPrimarySoft,
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.eco_outlined,
                        size: 24,
                        color: AppColors.primary,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          // ── Bloc central (nom + quantité + statut) ────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  produitNom,
                  style: AppTextStyles.titleMedium.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.text,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${_nf.format(proposition.quantiteKg.round())} kg dispo',
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                // Badge statut humanisé (« Acceptée » plutôt que « ACCEPTED »).
                // Pastille colorée pour qu'un coup d'œil suffise.
                () {
                  final v = _visuelPourStatut(proposition.status);
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: v.background,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        v.label,
                        style: AppTextStyles.labelSmall.copyWith(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: v.foreground,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  );
                }(),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // ── Prix (droite) ─────────────────────────────────────────
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${_nf.format(proposition.prixProposeKg.round())} F',
                style: AppTextStyles.displaySmall.copyWith(
                  fontFamily: 'Poppins',
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                  letterSpacing: -0.3,
                ),
              ),
              Text(
                '/kg',
                style: AppTextStyles.labelSmall.copyWith(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Actions extends StatelessWidget {
  const _Actions({
    required this.busy,
    required this.statut,
    required this.onRefuser,
    required this.onDiscuter,
    required this.onAccepter,
  });
  final bool busy;
  final NegotiationStatus statut;
  final VoidCallback onRefuser;
  final VoidCallback onDiscuter;
  final VoidCallback onAccepter;

  @override
  Widget build(BuildContext context) {
    // Quand la proposition n'est plus dans un état actionnable
    // (acceptée / refusée / annulée), on ne montre QUE « Discuter ».
    // Inutile (et trompeur) d'afficher Accepter/Refuser : le backend
    // refuse les transitions sortantes de ces états.
    if (!_peutAccepterOuRefuser(statut)) {
      return Row(
        children: [
          Expanded(
            child: _ActionBtn(
              label: 'Discuter',
              onTap: busy ? null : onDiscuter,
              color: AppColors.primary,
              background: AppColors.background,
              borderColor: AppColors.primary,
            ),
          ),
        ],
      );
    }
    return Row(
      children: [
        Expanded(
          child: _ActionBtn(
            label: 'Refuser',
            onTap: busy ? null : onRefuser,
            color: AppColors.textSecondary,
            background: AppColors.background,
            borderColor: AppColors.border,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _ActionBtn(
            label: 'Discuter',
            onTap: busy ? null : onDiscuter,
            color: AppColors.primary,
            background: AppColors.background,
            borderColor: AppColors.primary,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _ActionBtn(
            label: busy ? '…' : 'Accepter',
            onTap: busy ? null : onAccepter,
            color: AppColors.onPrimary,
            background: AppColors.primary,
            borderColor: AppColors.primary,
          ),
        ),
      ],
    );
  }
}

class _ActionBtn extends StatelessWidget {
  const _ActionBtn({
    required this.label,
    required this.onTap,
    required this.color,
    required this.background,
    required this.borderColor,
  });
  final String label;
  final VoidCallback? onTap;
  final Color color;
  final Color background;
  final Color borderColor;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: borderColor,
            width: AppDimens.borderThin,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: onTap == null ? AppColors.textSubtle : color,
          ),
        ),
      ),
    );
  }
}
