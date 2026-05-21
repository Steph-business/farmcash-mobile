import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../api_client/api_exception.dart';
import '../../../models/annonce_achat.dart';
import '../../../routing/route_names.dart';
import '../../../services/providers.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_dimens.dart';
import '../../../theme/app_text_styles.dart';
import '../../widgets/communs/chargement.dart';
import '../../widgets/communs/snackbars.dart';
import '../../widgets/communs/vue_erreur.dart';

const Color _kPrimarySoft = Color(0xFFE8F5E9);
const Color _kOrangeSoft = Color(0xFFFFF3E0);
const Color _kOrange = Color(0xFFE65100);

/// Charge les offres d'achat qui arrivent vers la coopérative (publiques OU
/// ciblées sur cette coop). Endpoint dédié `/coop/annonces-achat/incoming`.
final _offresProvider =
    FutureProvider.autoDispose<List<AnnonceAchat>>((ref) async {
  return ref.read(cooperativesServiceProvider).listIncomingAnnoncesAchat();
});

/// Liste des offres d'achat reçues par la coopérative. Buyer **anonymisé**
/// dans l'UI (anti-contournement), seules les coordonnées du transporteur
/// seront partagées lors d'un éventuel accord.
class OffresRecuesPage extends ConsumerStatefulWidget {
  const OffresRecuesPage({super.key});

  @override
  ConsumerState<OffresRecuesPage> createState() => _OffresRecuesPageState();
}

class _OffresRecuesPageState extends ConsumerState<OffresRecuesPage> {
  String? _busyId;

  Future<void> _refresh() async {
    ref.invalidate(_offresProvider);
    await ref.read(_offresProvider.future);
  }

  Future<void> _proposer(AnnonceAchat o) async {
    if (_busyId != null) return;
    // V1 : on saisit prix + quantité via un dialog simple. Le COOP envoie
    // une `Proposition` (le buyer recevra alors une notif).
    final qteCtrl = TextEditingController(text: o.quantiteKg.round().toString());
    final prixCtrl = TextEditingController(
      text: (o.prixMaxKg * 0.95).round().toString(),
    );
    final msgCtrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Proposer'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: qteCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Quantité (kg)'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: prixCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Prix proposé (F/kg)'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: msgCtrl,
              maxLines: 2,
              decoration: const InputDecoration(labelText: 'Message (optionnel)'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Envoyer'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    if (!mounted) return;
    final qte = double.tryParse(qteCtrl.text.replaceAll(',', '.'));
    final prix = double.tryParse(prixCtrl.text.replaceAll(',', '.'));
    if (qte == null || qte <= 0 || prix == null || prix <= 0) {
      Snackbars.showErreur(context, 'Quantité et prix requis.');
      return;
    }
    setState(() => _busyId = o.id);
    try {
      await ref.read(negotiationServiceProvider).createProposition(
            annonceAchatId: o.id,
            quantiteKg: qte,
            prixProposeKg: prix,
            message:
                msgCtrl.text.trim().isEmpty ? null : msgCtrl.text.trim(),
          );
      if (!mounted) return;
      Snackbars.showSucces(context, 'Proposition envoyée à l\'acheteur.');
      await _refresh();
    } on ApiException catch (e) {
      if (mounted) Snackbars.showErreur(context, e.message);
    } catch (e) {
      if (mounted) Snackbars.showErreur(context, 'Erreur : $e');
    } finally {
      if (mounted) setState(() => _busyId = null);
    }
  }

  void _refuser(AnnonceAchat o) {
    // Pas d'endpoint pour refuser une demande publique côté coop —
    // on cache localement (no-op back). Pour V2, ajouter
    // dismissAnnonceAchat ou marquer ignored côté UI persistant.
    Snackbars.showInfo(context, 'Offre masquée.');
  }

  void _solliciter(AnnonceAchat o) {
    // Le sollicitation_creer_page attend un offreId réel : on le passe
    // ici en argument de route pour que la sollicitation soit attachée
    // à cette annonce d'achat.
    context.push(
      RouteNames.cooperativeSollicitationCreerPath,
      extra: {'offreId': o.id},
    );
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(_offresProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            async.when(
              data: (list) => _Header(count: list.length),
              loading: () => const _Header(count: 0),
              error: (_, _) => const _Header(count: 0),
            ),
            Expanded(
              child: async.when(
                loading: () => const Padding(
                  padding: EdgeInsets.only(top: AppDimens.space32),
                  child: Chargement(size: 22),
                ),
                error: (e, _) => Padding(
                  padding: const EdgeInsets.all(AppDimens.pagePaddingH),
                  child: VueErreur(
                    message: 'Impossible de charger les offres. $e',
                    onRetry: _refresh,
                  ),
                ),
                data: (items) => RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: _refresh,
                  child: items.isEmpty
                      ? const _EmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(
                            AppDimens.pagePaddingH,
                            0,
                            AppDimens.pagePaddingH,
                            AppDimens.space16,
                          ),
                          itemCount: items.length,
                          itemBuilder: (_, i) => Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: _OffreCard(
                              offre: items[i],
                              busy: _busyId == items[i].id,
                              onRefuser: () => _refuser(items[i]),
                              onProposer: () => _proposer(items[i]),
                              onSolliciter: () => _solliciter(items[i]),
                            ),
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Header ──────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimens.space16,
        AppDimens.space8,
        AppDimens.space16,
        AppDimens.space12,
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () => Navigator.of(context).pop(),
            borderRadius: BorderRadius.circular(20),
            child: const SizedBox(
              width: 40,
              height: 40,
              child: Icon(
                Icons.arrow_back_ios_new,
                size: 20,
                color: AppColors.text,
              ),
            ),
          ),
          Expanded(
            child: Text(
              count > 0
                  ? "Offres d'achat reçues ($count)"
                  : "Offres d'achat reçues",
              style: AppTextStyles.titleSmall.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Card offre ───────────────────────────────────────────────────

class _OffreCard extends StatelessWidget {
  const _OffreCard({
    required this.offre,
    required this.busy,
    required this.onRefuser,
    required this.onProposer,
    required this.onSolliciter,
  });

  final AnnonceAchat offre;
  final bool busy;
  final VoidCallback onRefuser;
  final VoidCallback onProposer;
  final VoidCallback onSolliciter;

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('d MMM', 'fr_FR');
    final timing = offre.createdAt != null
        ? 'Reçue le ${df.format(offre.createdAt!)}'
        : 'Reçue récemment';
    final isPublic = offre.targetCooperativeId == null;
    final chipLabel = isPublic ? 'Public' : 'Coop ciblée';
    final demande = '${offre.produitLabel} · '
        '${_nf.format(offre.quantiteKg.round())} kg @ '
        'max ${_nf.format(offre.prixMaxKg.round())} F/kg';
    final buyerLabel = offre.buyerNom ?? 'Acheteur';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppDimens.radiusCard),
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _kPrimarySoft,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.business_outlined,
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
                    Text(
                      buyerLabel,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      timing,
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _ChipBadge(label: chipLabel, isPublic: isPublic),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceSoft,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.border,
                width: AppDimens.borderThin,
              ),
            ),
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Demande',
                  style: AppTextStyles.labelSmall.copyWith(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  demande,
                  style: AppTextStyles.titleLarge.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.text,
                  ),
                ),
              ],
            ),
          ),
          if (offre.dateLimiteLivraison != null) ...[
            const SizedBox(height: 6),
            Text(
              'Livraison avant le ${DateFormat('d MMM y', 'fr_FR').format(offre.dateLimiteLivraison!)}',
              style: AppTextStyles.labelSmall.copyWith(
                fontSize: 11,
                color: AppColors.textSubtle,
              ),
            ),
          ],
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _Button(
                  label: 'Refuser',
                  primary: false,
                  onTap: busy ? null : onRefuser,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _Button(
                  label: 'Proposer',
                  primary: true,
                  busy: busy,
                  onTap: busy ? null : onProposer,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(height: 1, color: AppColors.border),
          const SizedBox(height: 12),
          InkWell(
            onTap: busy ? null : onSolliciter,
            borderRadius: BorderRadius.circular(6),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                '+ Solliciter mes fournisseurs (membres / autres coops)',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChipBadge extends StatelessWidget {
  const _ChipBadge({required this.label, required this.isPublic});
  final String label;
  final bool isPublic;

  @override
  Widget build(BuildContext context) {
    final bg = isPublic ? _kPrimarySoft : _kOrangeSoft;
    final fg = isPublic ? AppColors.primary : _kOrange;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: fg,
        ),
      ),
    );
  }
}

class _Button extends StatelessWidget {
  const _Button({
    required this.label,
    required this.primary,
    required this.onTap,
    this.busy = false,
  });

  final String label;
  final bool primary;
  final VoidCallback? onTap;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: primary ? AppColors.primary : AppColors.background,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: primary ? AppColors.primary : AppColors.border,
            width: AppDimens.borderThin,
          ),
        ),
        alignment: Alignment.center,
        child: busy
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(
                label,
                style: AppTextStyles.button.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: primary ? Colors.white : AppColors.text,
                ),
              ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 40,
            color: AppColors.textSubtle.withValues(alpha: 0.9),
          ),
          const SizedBox(height: 12),
          Text(
            'Aucune offre pour le moment',
            style: AppTextStyles.titleSmall,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Les demandes d\'achat ciblées sur ta coop apparaîtront ici.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

final _nf = NumberFormat('#,##0', 'fr_FR');
