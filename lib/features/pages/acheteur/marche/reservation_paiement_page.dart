import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../api_client/api_exception.dart';
import '../../../../models/prevision.dart';
import '../../../../routing/route_names.dart';
import '../../../../services/providers.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../widgets/acheteur/marche/boites_montants_reservation_marche.dart';
import '../../../widgets/acheteur/marche/cgv_row_reservation_marche.dart';
import '../../../widgets/acheteur/marche/grille_methodes_reservation_marche.dart';
import '../../../widgets/acheteur/marche/header_reservation_marche.dart';
import '../../../widgets/acheteur/marche/recap_card_reservation_marche.dart';
import '../../../widgets/acheteur/marche/sticky_bottom_reservation_marche.dart';
import '../../../widgets/acheteur/marche/titre_section_reservation_marche.dart';
import '../../../widgets/communs/chargement.dart';
import '../../../widgets/communs/snackbars.dart';
import '../../../widgets/communs/vue_erreur.dart';

// ─── Provider ─────────────────────────────────────────────────────────

final _previsionByIdProvider = FutureProvider.autoDispose
    .family<Prevision, String>((ref, id) async {
  final all = await ref.read(marketplaceServiceProvider).listPrevisions();
  return all.firstWhere(
    (p) => p.id == id,
    orElse: () => throw StateError(
      'Prévision introuvable. Elle n\'est plus active ou tu n\'y as pas accès.',
    ),
  );
});

// ─── Page ─────────────────────────────────────────────────────────────

/// Écran de confirmation de réservation (acompte 10% + reste à livraison).
/// Charge la `Prevision` cible et appelle `reserverPrevision` au submit.
class ReservationPaiementPage extends ConsumerStatefulWidget {
  const ReservationPaiementPage({required this.previsionId, super.key});

  final String previsionId;

  @override
  ConsumerState<ReservationPaiementPage> createState() =>
      _ReservationPaiementPageState();
}

class _ReservationPaiementPageState
    extends ConsumerState<ReservationPaiementPage> {
  MethodePaiementReservation _method = MethodePaiementReservation.wallet;
  bool _cgvAccepted = true;
  bool _busy = false;

  /// Quantité à réserver (kg). On part sur la totalité de la prévision par
  /// défaut, ajustable plus tard si la UI propose un picker.
  double? _quantiteReservee;

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(_previsionByIdProvider(widget.previsionId));
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: async.when(
          loading: () => const Column(
            children: [
              HeaderReservationMarche(title: 'Confirmer la réservation'),
              Expanded(child: Chargement(size: 22)),
            ],
          ),
          error: (e, _) => Column(
            children: [
              const HeaderReservationMarche(title: 'Confirmer la réservation'),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(AppDimens.pagePaddingH),
                  child: VueErreur(
                    message: 'Impossible de charger la prévision. $e',
                    onRetry: () => ref
                        .invalidate(_previsionByIdProvider(widget.previsionId)),
                  ),
                ),
              ),
            ],
          ),
          data: (p) => _buildContent(p),
        ),
      ),
    );
  }

  Widget _buildContent(Prevision p) {
    final qte = _quantiteReservee ?? p.quantitePrevKg;
    final prixUnitaire = p.prixCibleKg ?? 0;
    final montantTotal = qte * prixUnitaire;
    final acompte = (montantTotal * 0.10).round();
    final reste = (montantTotal - acompte).round();
    final dispoLabel = p.dateRecoltePrev != null
        ? DateFormat('d MMM yyyy', 'fr_FR').format(p.dateRecoltePrev!)
        : 'À la récolte';

    return Column(
      children: [
        const HeaderReservationMarche(title: 'Confirmer la réservation'),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            children: [
              RecapCardReservationMarche(
                qte: qte,
                prixUnitaire: prixUnitaire,
                dispoLabel: dispoLabel,
              ),
              const SizedBox(height: 18),
              const TitreSectionReservationMarche(
                  'Acompte à payer maintenant (10%)'),
              const SizedBox(height: 8),
              AcompteBoxReservationMarche(montant: acompte),
              const SizedBox(height: 14),
              const TitreSectionReservationMarche(
                  'Reste à payer à la livraison (90%)'),
              const SizedBox(height: 8),
              ResteBoxReservationMarche(
                  montant: reste, libelle: 'Le $dispoLabel'),
              const SizedBox(height: 18),
              const TitreSectionReservationMarche('Méthode de paiement'),
              const SizedBox(height: 10),
              GrilleMethodesReservationMarche(
                selected: _method,
                onSelect: (m) => setState(() => _method = m),
              ),
              const SizedBox(height: 16),
              CgvRowReservationMarche(
                accepted: _cgvAccepted,
                onToggle: () =>
                    setState(() => _cgvAccepted = !_cgvAccepted),
              ),
            ],
          ),
        ),
        StickyBottomReservationMarche(
          acompte: acompte,
          enabled: _cgvAccepted && !_busy && qte > 0,
          busy: _busy,
          onPay: () => _onPay(p, qte),
        ),
      ],
    );
  }

  Future<void> _onPay(Prevision p, double qte) async {
    if (_busy) return;
    if (!_cgvAccepted) {
      Snackbars.showErreur(context, 'Tu dois accepter les CGV.');
      return;
    }
    setState(() => _busy = true);
    try {
      // Le backend exige `payment_method_id` (UUID du moyen de
      // paiement enregistré du BUYER). On prend le moyen marqué
      // `is_default` ; à défaut le premier de la liste.
      final moyens = await ref
          .read(financeServiceProvider)
          .listMoyensPayement();
      if (moyens.isEmpty) {
        if (mounted) {
          Snackbars.showErreur(
            context,
            'Ajoute un moyen de paiement avant de réserver.',
          );
        }
        return;
      }
      final defaultMp = moyens.firstWhere(
        (m) => m.isDefault,
        orElse: () => moyens.first,
      );
      await ref.read(marketplaceServiceProvider).reserverPrevision(
            previsionId: p.id,
            quantiteKg: qte,
            paymentMethodId: defaultMp.id,
          );
      if (!mounted) return;
      Snackbars.showSucces(context, 'Réservation confirmée');
      context.go(RouteNames.acheteurMesReservationsPath);
    } on ApiException catch (e) {
      if (mounted) Snackbars.showErreur(context, e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}
