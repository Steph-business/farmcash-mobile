import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../api_client/api_exception.dart';
import '../../../../models/cooperative.dart';
import '../../../../routing/route_names.dart';
import '../../../../services/providers.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../widgets/communs/chargement.dart';
import '../../../widgets/communs/snackbars.dart';

/// Provider : liste publique des coopératives (annuaire), avec filtre
/// search. On garde la famille sur (search) pour invalidation fine
/// pendant la frappe utilisateur.
final _coopsProvider = FutureProvider.autoDispose
    .family<List<Cooperative>, String>((ref, search) async {
  return ref
      .read(cooperativesServiceProvider)
      .listPublicCoops(search: search.isEmpty ? null : search);
});

/// Page « Trouver une coopérative » — annuaire public côté producteur.
///
/// Phase 1 du chantier « rejoindre une coop » :
///   - Le producteur (non rattaché) découvre les coops actives
///   - Tap sur une carte → bottom sheet avec détails + bouton
///     « Demander à rejoindre » qui appelle `requestToJoin`
///   - La coop reçoit une notif + voit la demande dans sa page
///     « Demandes d'adhésion » (existante côté coop)
///
/// Pas de filtre région pour la V1 (la liste est petite en CI au
/// démarrage). Ajoutable plus tard.
class TrouverCoopPage extends ConsumerStatefulWidget {
  const TrouverCoopPage({super.key});

  @override
  ConsumerState<TrouverCoopPage> createState() => _TrouverCoopPageState();
}

class _TrouverCoopPageState extends ConsumerState<TrouverCoopPage> {
  final _searchCtrl = TextEditingController();
  String _search = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(_coopsProvider(_search));
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _Header(onBack: () => context.pop()),
            _BarreRecherche(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _search = v),
            ),
            Expanded(
              child: async.when(
                loading: () => const Padding(
                  padding: EdgeInsets.only(top: 48),
                  child: Chargement(size: 22),
                ),
                error: (e, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'Impossible de charger les coopératives.\n$e',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
                data: (coops) => coops.isEmpty
                    ? const _EtatVide()
                    : RefreshIndicator(
                        color: AppColors.primary,
                        onRefresh: () async {
                          ref.invalidate(_coopsProvider(_search));
                          await ref.read(_coopsProvider(_search).future);
                        },
                        child: ListView.separated(
                          padding: const EdgeInsets.fromLTRB(
                            AppDimens.pagePaddingH,
                            AppDimens.space12,
                            AppDimens.pagePaddingH,
                            AppDimens.space24,
                          ),
                          itemCount: coops.length,
                          separatorBuilder: (_, _) => AppDimens.vGap12,
                          itemBuilder: (_, i) => _CarteCoop(
                            coop: coops[i],
                            onTap: () => _ouvrirDetail(coops[i]),
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

  void _ouvrirDetail(Cooperative coop) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _SheetDemandeAdhesion(
        coop: coop,
        onConfirme: (message) async {
          Navigator.of(context).pop();
          await _demanderAdhesion(coop, message);
        },
      ),
    );
  }

  Future<void> _demanderAdhesion(Cooperative coop, String? message) async {
    try {
      await ref.read(cooperativesServiceProvider).requestToJoin(
            cooperativeId: coop.id,
            message: message,
          );
      if (!mounted) return;
      Snackbars.showSucces(
        context,
        'Demande envoyée à ${coop.nom}. Tu seras notifié dès la réponse.',
      );
      // Redirige vers la page « Mes invitations & demandes » pour suivi.
      context.pushReplacement(RouteNames.producteurInvitationsCoopPath);
    } on ApiException catch (e) {
      if (mounted) Snackbars.showErreur(context, e.message);
    } catch (e) {
      if (mounted) Snackbars.showErreurInattendue(context, e);
    }
  }
}

// ─── Header + barre recherche ─────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({required this.onBack});
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 6, 16, 4),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_rounded, color: AppColors.text),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              'Trouver une coopérative',
              style: AppTextStyles.titleLarge.copyWith(
                fontFamily: 'Poppins',
                fontSize: 17,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
                color: AppColors.text,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BarreRecherche extends StatelessWidget {
  const _BarreRecherche({required this.controller, required this.onChanged});
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimens.pagePaddingH,
        4,
        AppDimens.pagePaddingH,
        12,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: TextField(
          controller: controller,
          onChanged: onChanged,
          decoration: const InputDecoration(
            hintText: 'Rechercher (nom, ville, agrément…)',
            border: InputBorder.none,
            prefixIcon: Icon(
              Icons.search_rounded,
              color: AppColors.textSubtle,
              size: 20,
            ),
            contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          ),
        ),
      ),
    );
  }
}

// ─── Carte coop ───────────────────────────────────────────────────

class _CarteCoop extends StatelessWidget {
  const _CarteCoop({required this.coop, required this.onTap});
  final Cooperative coop;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  _monogramme(coop.nom),
                  style: AppTextStyles.titleSmall.copyWith(
                    fontFamily: 'Poppins',
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      coop.nom,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontFamily: 'Poppins',
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        const Icon(
                          Icons.groups_outlined,
                          size: 13,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          coop.nbMembres > 1
                              ? '${coop.nbMembres} membres'
                              : (coop.nbMembres == 1 ? '1 membre' : 'Nouvelle'),
                          style: AppTextStyles.bodySmall.copyWith(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        if (coop.numeroAgrement != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            width: 3,
                            height: 3,
                            decoration: const BoxDecoration(
                              color: AppColors.textSubtle,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.verified_rounded,
                            size: 13,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            'Vérifiée',
                            style: AppTextStyles.bodySmall.copyWith(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textSubtle,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _monogramme(String nom) {
    final mots = nom.trim().split(RegExp(r'\s+'));
    if (mots.isEmpty) return '?';
    if (mots.length == 1) return mots.first.substring(0, 1).toUpperCase();
    return (mots[0].substring(0, 1) + mots[1].substring(0, 1)).toUpperCase();
  }
}

// ─── Bottom sheet « Demander à rejoindre » ─────────────────────────

class _SheetDemandeAdhesion extends StatefulWidget {
  const _SheetDemandeAdhesion({
    required this.coop,
    required this.onConfirme,
  });
  final Cooperative coop;
  final ValueChanged<String?> onConfirme;

  @override
  State<_SheetDemandeAdhesion> createState() => _SheetDemandeAdhesionState();
}

class _SheetDemandeAdhesionState extends State<_SheetDemandeAdhesion> {
  final _msgCtrl = TextEditingController();

  @override
  void dispose() {
    _msgCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
        padding: EdgeInsets.fromLTRB(
          20,
          12,
          20,
          MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Rejoindre ${widget.coop.nom}',
              style: AppTextStyles.titleLarge.copyWith(
                fontFamily: 'Poppins',
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.text,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Ta demande sera envoyée à la coopérative. '
              'Elle pourra accepter ou refuser. Tu seras notifié.',
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Message (optionnel)',
              style: AppTextStyles.labelMedium.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _msgCtrl,
              minLines: 3,
              maxLines: 5,
              decoration: InputDecoration(
                hintText:
                    'Ex : Je cultive du manioc sur 2 ha à Bouaké, j\'aimerais rejoindre ta coop.',
                hintMaxLines: 3,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: AppDimens.buttonHeight,
              child: ElevatedButton(
                onPressed: () {
                  final m = _msgCtrl.text.trim();
                  widget.onConfirme(m.isEmpty ? null : m);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: const RoundedRectangleBorder(
                    borderRadius: AppDimens.brButton,
                  ),
                ),
                child: Text(
                  'Envoyer la demande',
                  style: AppTextStyles.button.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
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

// ─── État vide ────────────────────────────────────────────────────

class _EtatVide extends StatelessWidget {
  const _EtatVide();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.groups_outlined,
                size: 32,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Aucune coopérative trouvée',
              style: AppTextStyles.titleLarge.copyWith(
                fontFamily: 'Poppins',
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              'Essaie une autre recherche ou attends qu\'une coopérative '
              's\'inscrive dans ta région.',
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.45,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
