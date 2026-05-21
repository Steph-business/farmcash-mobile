import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../api_client/api_exception.dart';
import '../../../../services/providers.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../widgets/communs/chargement.dart';
import '../../../widgets/communs/snackbars.dart';
import '../../../widgets/communs/vue_erreur.dart';

// ─── Couleurs accent ─────────────────────────────────────────────────────

const Color _kPrimarySoft = Color(0xFFE8F5E9);
const Color _kBlueSoft = Color(0xFFE3F2FD);
const Color _kBlue = Color(0xFF1565C0);

enum _ReplyRole { membre, coop, indep, unknown }

enum _ReplyMode { now }

/// Une réponse fournisseur décodée depuis la Map riche `getSollicitation`.
class _SollicitationReply {
  final String? recipientId;
  final String nom;
  final _ReplyRole role;
  final double qtyKg;
  final _ReplyMode mode;

  /// True si le recipient a déjà répondu (ACCEPTED).
  final bool deja;

  /// True si la coop a confirmé l'engagement de ce recipient.
  final bool confirme;

  const _SollicitationReply({
    this.recipientId,
    required this.nom,
    required this.role,
    required this.qtyKg,
    required this.mode,
    required this.deja,
    required this.confirme,
  });
}

/// Données décodées depuis la Map riche `getSollicitation(id)`.
class _SollicitationDetail {
  final String? produitNom;
  final double? quantiteCibleKg;
  final double quantiteOfferteKg;
  final int totalRecipients;
  final int totalResponses;
  final String status;
  final List<_SollicitationReply> replies;

  const _SollicitationDetail({
    this.produitNom,
    this.quantiteCibleKg,
    required this.quantiteOfferteKg,
    required this.totalRecipients,
    required this.totalResponses,
    required this.status,
    required this.replies,
  });
}

final _sollicitationSuiviProvider = FutureProvider.autoDispose
    .family<_SollicitationDetail, String>((ref, id) async {
  final raw = await ref.read(cooperativesServiceProvider).getSollicitation(id);
  return _decodeSollicitation(raw);
});

_SollicitationDetail _decodeSollicitation(Map<String, dynamic> raw) {
  final annonce = raw['annonce'];
  String? produitNom;
  double? quantiteCibleKg;
  if (annonce is Map) {
    final a = annonce.cast<String, dynamic>();
    final p = a['produit'];
    if (p is Map) {
      produitNom = p['nom'] as String?;
    }
    quantiteCibleKg = _asDouble(a['quantite_kg']);
  }

  final replies = <_SollicitationReply>[];
  final recipients = raw['recipients'];
  if (recipients is List) {
    for (final r in recipients.whereType<Map>()) {
      final m = r.cast<String, dynamic>();
      final user = m['user'];
      String nom = 'Destinataire';
      if (user is Map) {
        final u = user.cast<String, dynamic>();
        nom = (u['full_name'] as String?) ??
            (u['fullName'] as String?) ??
            (u['phone'] as String?) ??
            'Destinataire';
      }
      final audience =
          (m['audience_segment'] as String? ?? 'UNKNOWN').toUpperCase();
      _ReplyRole role;
      switch (audience) {
        case 'MEMBRES':
        case 'MEMBRE':
          role = _ReplyRole.membre;
          break;
        case 'COOPS_VOISINES':
        case 'COOP':
          role = _ReplyRole.coop;
          break;
        case 'INDEPENDANTS':
        case 'INDEPENDANT':
          role = _ReplyRole.indep;
          break;
        default:
          role = _ReplyRole.unknown;
      }
      final action = (m['response_action'] as String? ?? '').toUpperCase();
      final accepted = action == 'ACCEPTED' || action == 'CONFIRMED_BY_COOP';
      final confirme = (m['confirmed_by_coop_at'] as Object?) != null ||
          action == 'CONFIRMED_BY_COOP';
      final qty = _asDouble(m['response_quantite_kg']) ?? 0;
      replies.add(_SollicitationReply(
        recipientId: m['id'] as String?,
        nom: nom,
        role: role,
        qtyKg: qty,
        mode: _ReplyMode.now,
        deja: accepted,
        confirme: confirme,
      ));
    }
  }

  final summary = raw['responses_summary'];
  double totalOfferte = 0;
  if (summary is Map) {
    final s = summary.cast<String, dynamic>();
    totalOfferte = _asDouble(s['total_quantite_offerte']) ??
        _asDouble(s['totalQuantiteOfferte']) ??
        0;
  }
  if (totalOfferte == 0) {
    totalOfferte = replies
        .where((r) => r.deja)
        .fold<double>(0, (acc, r) => acc + r.qtyKg);
  }

  return _SollicitationDetail(
    produitNom: produitNom,
    quantiteCibleKg: quantiteCibleKg,
    quantiteOfferteKg: totalOfferte,
    totalRecipients:
        (raw['total_recipients'] as num?)?.toInt() ?? replies.length,
    totalResponses: (raw['total_responses'] as num?)?.toInt() ??
        replies.where((r) => r.deja).length,
    status: (raw['status'] as String? ?? 'OPEN').toUpperCase(),
    replies: replies,
  );
}

double? _asDouble(Object? v) {
  if (v == null) return null;
  if (v is num) return v.toDouble();
  if (v is String) return double.tryParse(v);
  return null;
}

/// Suivi d'une sollicitation envoyée par la coop : progression du
/// remplissage, liste des réponses, actions (clôturer).
class SollicitationSuiviPage extends ConsumerWidget {
  const SollicitationSuiviPage({required this.sollicitationId, super.key});

  final String sollicitationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(_sollicitationSuiviProvider(sollicitationId));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const _Header(),
            Expanded(
              child: async.when(
                loading: () => const Padding(
                  padding: EdgeInsets.only(top: AppDimens.space32),
                  child: Chargement(size: 22),
                ),
                error: (e, _) => Padding(
                  padding: const EdgeInsets.all(AppDimens.pagePaddingH),
                  child: VueErreur(
                    message: 'Impossible de charger la sollicitation. $e',
                    onRetry: () => ref.invalidate(
                      _sollicitationSuiviProvider(sollicitationId),
                    ),
                  ),
                ),
                data: (detail) =>
                    _Body(detail: detail, sollicitationId: sollicitationId),
              ),
            ),
            _Sticky(sollicitationId: sollicitationId),
          ],
        ),
      ),
    );
  }
}

// ─── Header (avec menu ⋮) ────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header();

  void _menuStub(BuildContext context) {
    Snackbars.showInfo(context, 'Menu — à venir');
  }

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
              'Suivi sollicitation',
              style: AppTextStyles.titleSmall.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          InkWell(
            onTap: () => _menuStub(context),
            borderRadius: BorderRadius.circular(20),
            child: const SizedBox(
              width: 40,
              height: 40,
              child: Icon(
                Icons.more_vert,
                size: 22,
                color: AppColors.text,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Body ────────────────────────────────────────────────────────────────

class _Body extends StatelessWidget {
  const _Body({required this.detail, required this.sollicitationId});

  final _SollicitationDetail detail;
  final String sollicitationId;

  @override
  Widget build(BuildContext context) {
    final replies = detail.replies;
    final cible = detail.quantiteCibleKg ?? 0;
    final offerte = detail.quantiteOfferteKg;
    final pct = (cible > 0) ? (offerte / cible).clamp(0.0, 1.0) : 0.0;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppDimens.pagePaddingH,
        0,
        AppDimens.pagePaddingH,
        AppDimens.space16,
      ),
      children: [
        _SectionTitle(title: 'Récap'),
        AppDimens.vGap12,
        _RecapCard(
          produit: detail.produitNom ?? 'Produit',
          quantiteCibleKg: cible,
          totalRecipients: detail.totalRecipients,
          status: detail.status,
        ),
        AppDimens.vGap24,
        _SectionTitle(title: 'Progression du remplissage'),
        AppDimens.vGap12,
        _ProgressCard(
          quantiteOfferteKg: offerte,
          quantiteCibleKg: cible,
          pct: pct,
        ),
        AppDimens.vGap24,
        _SectionTitle(title: 'Réponses reçues (${replies.length})'),
        AppDimens.vGap12,
        if (replies.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Text(
                'Aucune réponse pour le moment.',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          )
        else
          for (final r in replies) ...[
            _ReplyTile(reply: r, sollicitationId: sollicitationId),
            AppDimens.vGap8,
          ],
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: AppTextStyles.titleSmall.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: AppColors.text,
      ),
    );
  }
}

// ─── Récap card ──────────────────────────────────────────────────────────

class _RecapCard extends StatelessWidget {
  const _RecapCard({
    required this.produit,
    required this.quantiteCibleKg,
    required this.totalRecipients,
    required this.status,
  });

  final String produit;
  final double quantiteCibleKg;
  final int totalRecipients;
  final String status;

  @override
  Widget build(BuildContext context) {
    final cibleLabel = quantiteCibleKg > 0
        ? '$produit · ${_fmt(quantiteCibleKg)} kg'
        : produit;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppDimens.radiusCard),
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            cibleLabel,
            style: AppTextStyles.titleLarge.copyWith(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Statut : $status',
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.surfaceSoft,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.border,
                width: AppDimens.borderThin,
              ),
            ),
            child: Text(
              'Sollicitation envoyée à $totalRecipients destinataire(s)',
              style: AppTextStyles.labelSmall.copyWith(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Progress card ────────────────────────────────────────────────────────

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({
    required this.quantiteOfferteKg,
    required this.quantiteCibleKg,
    required this.pct,
  });

  final double quantiteOfferteKg;
  final double quantiteCibleKg;
  final double pct;

  @override
  Widget build(BuildContext context) {
    final pctLabel = '${(pct * 100).round()}%';
    final mainLabel = quantiteCibleKg > 0
        ? '${_fmt(quantiteOfferteKg)} / ${_fmt(quantiteCibleKg)} kg engagés'
        : '${_fmt(quantiteOfferteKg)} kg engagés';
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppDimens.radiusCard),
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  mainLabel,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                pctLabel,
                style: AppTextStyles.titleLarge.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            height: 16,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: pct,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Reply tile ──────────────────────────────────────────────────────────

class _ReplyTile extends ConsumerStatefulWidget {
  const _ReplyTile({required this.reply, required this.sollicitationId});

  final _SollicitationReply reply;
  final String sollicitationId;

  @override
  ConsumerState<_ReplyTile> createState() => _ReplyTileState();
}

class _ReplyTileState extends ConsumerState<_ReplyTile> {
  bool _busy = false;

  Future<void> _confirmer() async {
    if (_busy) return;
    final recipientId = widget.reply.recipientId;
    if (recipientId == null || recipientId.isEmpty) {
      Snackbars.showErreur(context, 'Identifiant de destinataire manquant');
      return;
    }
    setState(() => _busy = true);
    try {
      await ref.read(cooperativesServiceProvider).confirmRecipientResponse(
            sollicitationId: widget.sollicitationId,
            recipientId: recipientId,
          );
      if (!mounted) return;
      ref.invalidate(_sollicitationSuiviProvider(widget.sollicitationId));
      Snackbars.showSucces(context, 'Engagement confirmé');
    } on ApiException catch (e) {
      if (!mounted) return;
      Snackbars.showErreur(context, e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final reply = widget.reply;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppDimens.radiusCard),
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _kPrimarySoft,
              border: Border.all(
                color: AppColors.border,
                width: AppDimens.borderThin,
              ),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              _initiales(reply.nom),
              style: AppTextStyles.labelSmall.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        reply.nom,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    _RoleTag(role: reply.role),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '${_fmt(reply.qtyKg)} kg',
                      style: AppTextStyles.titleLarge.copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const _ModeChip(label: 'Maintenant'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (reply.confirme)
            const _ConfirmedChip()
          else if (reply.deja)
            _AcceptBtn(
              label: _busy ? '…' : 'Confirmer',
              onTap: _busy ? null : _confirmer,
            )
          else
            const _DoneChip(label: 'En attente'),
        ],
      ),
    );
  }
}

class _RoleTag extends StatelessWidget {
  const _RoleTag({required this.role});

  final _ReplyRole role;

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    String label;
    BoxBorder? border;
    switch (role) {
      case _ReplyRole.membre:
        bg = _kPrimarySoft;
        fg = AppColors.primary;
        label = 'Membre';
        border = null;
        break;
      case _ReplyRole.coop:
        bg = _kBlueSoft;
        fg = _kBlue;
        label = 'Coop';
        border = null;
        break;
      case _ReplyRole.indep:
        bg = AppColors.surfaceSoft;
        fg = AppColors.textSecondary;
        label = 'Indépendant';
        border = Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        );
        break;
      case _ReplyRole.unknown:
        bg = AppColors.surfaceSoft;
        fg = AppColors.textSecondary;
        label = 'Destinataire';
        border = Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        );
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: border,
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: fg,
        ),
      ),
    );
  }
}

class _ModeChip extends StatelessWidget {
  const _ModeChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _kPrimarySoft,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

class _AcceptBtn extends StatelessWidget {
  const _AcceptBtn({required this.onTap, this.label = 'Confirmer'});

  final VoidCallback? onTap;
  final String label;

  @override
  Widget build(BuildContext context) {
    final disabled = onTap == null;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(9),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: disabled
              ? AppColors.primary.withValues(alpha: 0.5)
              : AppColors.primary,
          borderRadius: BorderRadius.circular(9),
          border: Border.all(
            color: AppColors.primary,
            width: AppDimens.borderThin,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.button.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class _DoneChip extends StatelessWidget {
  const _DoneChip({this.label = 'Acceptée'});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

/// Chip vert "Confirmé" — engagement scellé par la coop.
class _ConfirmedChip extends StatelessWidget {
  const _ConfirmedChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: _kPrimarySoft,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.primary,
          width: AppDimens.borderThin,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.check_circle,
            size: 12,
            color: AppColors.primary,
          ),
          const SizedBox(width: 4),
          Text(
            'Confirmé',
            style: AppTextStyles.labelSmall.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Sticky 2 boutons ────────────────────────────────────────────────────

class _Sticky extends ConsumerStatefulWidget {
  const _Sticky({required this.sollicitationId});

  final String sollicitationId;

  @override
  ConsumerState<_Sticky> createState() => _StickyState();
}

class _StickyState extends ConsumerState<_Sticky> {
  bool _busy = false;

  Future<void> _cloturer() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await ref
          .read(cooperativesServiceProvider)
          .closeSollicitation(widget.sollicitationId);
      if (!mounted) return;
      ref.invalidate(_sollicitationSuiviProvider(widget.sollicitationId));
      Snackbars.showSucces(context, 'Sollicitation clôturée');
    } on ApiException catch (e) {
      if (!mounted) return;
      Snackbars.showErreur(context, e.message);
    } catch (e) {
      if (!mounted) return;
      Snackbars.showErreur(context, 'Erreur : $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _relancer() {
    Snackbars.showInfo(context, 'Relance — à venir');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(
          top: BorderSide(
            color: AppColors.border,
            width: AppDimens.borderThin,
          ),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(24, 14, 24, 12),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: _busy ? null : _relancer,
              borderRadius: BorderRadius.circular(AppDimens.radiusCard),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 13),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius:
                      BorderRadius.circular(AppDimens.radiusCard),
                  border: Border.all(
                    color: AppColors.primary,
                    width: AppDimens.borderThin,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Relancer non-répondants',
                  style: AppTextStyles.button.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: InkWell(
              onTap: _busy ? null : _cloturer,
              borderRadius: BorderRadius.circular(AppDimens.radiusCard),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 13),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius:
                      BorderRadius.circular(AppDimens.radiusCard),
                  border: Border.all(
                    color: AppColors.primary,
                    width: AppDimens.borderThin,
                  ),
                ),
                alignment: Alignment.center,
                child: _busy
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        'Clôturer',
                        style: AppTextStyles.button.copyWith(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Helpers ─────────────────────────────────────────────────────────────

String _fmt(double v) {
  final i = v.round();
  if (i < 1000) return '$i';
  final s = '$i';
  final buf = StringBuffer();
  for (var k = 0; k < s.length; k++) {
    if (k > 0 && (s.length - k) % 3 == 0) buf.write(' ');
    buf.write(s[k]);
  }
  return buf.toString();
}

String _initiales(String s) {
  final t = s.trim();
  if (t.isEmpty) return '?';
  final parts = t.split(RegExp(r'[\s\-_]+'))..removeWhere((p) => p.isEmpty);
  if (parts.length >= 2) {
    return (parts[0].substring(0, 1) + parts[1].substring(0, 1)).toUpperCase();
  }
  if (t.length == 1) return t.toUpperCase();
  return t.substring(0, 2).toUpperCase();
}
