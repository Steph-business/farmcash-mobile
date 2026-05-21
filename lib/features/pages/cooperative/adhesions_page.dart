import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../models/membre_coop.dart';
import '../../../routing/route_names.dart';
import '../../../services/providers.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_dimens.dart';
import '../../../theme/app_text_styles.dart';
import '../../widgets/communs/chargement.dart';
import '../../widgets/communs/snackbars.dart';
import '../../widgets/communs/vue_erreur.dart';

// ─── COULEURS LOCALES ───────────────────────────────────────────────────

const Color _kPrimarySoft = Color(0xFFE8F5E9);

// Radius des cards (14 — comme la maquette HTML).
const BorderRadius _kBrCard = BorderRadius.all(Radius.circular(14));

// ─── Provider racine — appel API uniquement ─────────────────────────────

/// Liste des demandes d'adhésion en attente côté coop. Aucune fallback
/// mock : si la liste est vide, l'UI affiche un empty-state honnête.
final _adhesionsCoopProvider =
    FutureProvider.autoDispose<List<_AdhesionView>>((ref) async {
  final coopSvc = ref.read(cooperativesServiceProvider);
  final api = await coopSvc.listJoinRequests();
  return api
      .where((r) => r.status.toUpperCase() == 'PENDING')
      .map((r) => _AdhesionView.fromApi(r))
      .toList(growable: false);
});

/// Vue d'affichage d'une demande d'adhésion. Le backend ne renvoie pas
/// encore le profil complet du demandeur — on affiche un id court en
/// attendant l'enrichissement back.
class _AdhesionView {
  final String id;
  final String nom;
  final String? avatarUrl;
  final String? ville;
  final String? tel;
  final String? time;

  _AdhesionView({
    required this.id,
    required this.nom,
    required this.avatarUrl,
    required this.ville,
    required this.tel,
    required this.time,
  });

  factory _AdhesionView.fromApi(CoopJoinRequest r) => _AdhesionView(
        id: r.id,
        nom: 'Demandeur ${_short(r.farmerId)}',
        avatarUrl: null,
        ville: null,
        tel: null,
        time: r.message,
      );

  static String _short(String id) {
    final t = id.trim();
    if (t.isEmpty) return '?';
    final tail = t.contains('_') ? t.split('_').last : t;
    return tail.length > 6 ? tail.substring(0, 6) : tail;
  }
}

/// Page Demandes d'adhésion — coop voit la liste des farmers qui
/// souhaitent rejoindre. Reproduction fidèle de
/// `mockups/cooperative/adhesions.html`.
class AdhesionsCooperativePage extends ConsumerWidget {
  const AdhesionsCooperativePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(_adhesionsCoopProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _Header(
              count: async.maybeWhen(
                data: (list) => list.length,
                orElse: () => 0,
              ),
            ),
            Expanded(
              child: async.when(
                loading: () => const Chargement(size: 22),
                error: (_, __) => Padding(
                  padding: const EdgeInsets.all(AppDimens.pagePaddingH),
                  child: VueErreur(
                    message: "Impossible de charger les demandes.",
                    onRetry: () => ref.invalidate(_adhesionsCoopProvider),
                  ),
                ),
                data: (items) => items.isEmpty
                    ? const _EmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(
                          AppDimens.pagePaddingH,
                          AppDimens.space16,
                          AppDimens.pagePaddingH,
                          AppDimens.space16,
                        ),
                        itemCount: items.length,
                        itemBuilder: (_, i) => _AdhesionCard(
                          adhesion: items[i],
                          onAccepter: () => _handle(
                            context,
                            ref,
                            items[i],
                            accept: true,
                          ),
                          onRefuser: () => _handle(
                            context,
                            ref,
                            items[i],
                            accept: false,
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

  Future<void> _handle(
    BuildContext context,
    WidgetRef ref,
    _AdhesionView a, {
    required bool accept,
  }) async {
    try {
      await ref.read(cooperativesServiceProvider).handleJoinRequest(
            id: a.id,
            accept: accept,
          );
      if (context.mounted) {
        Snackbars.showSucces(
          context,
          accept ? 'Demande acceptée' : 'Demande refusée',
        );
      }
      ref.invalidate(_adhesionsCoopProvider);
    } catch (e) {
      if (context.mounted) {
        Snackbars.showErreur(context, 'Erreur : ${e.toString()}');
      }
    }
  }
}

// ─── Header (back + titre + compteur) ───────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimens.pagePaddingH,
        AppDimens.space8,
        AppDimens.pagePaddingH,
        AppDimens.space12,
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () => context.canPop()
                ? context.pop()
                : context.go(RouteNames.cooperativeMembresPath),
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
                  ? "Demandes d'adhésion ($count)"
                  : "Demandes d'adhésion",
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

// ─── Card d'une demande ─────────────────────────────────────────────────

class _AdhesionCard extends StatelessWidget {
  const _AdhesionCard({
    required this.adhesion,
    required this.onAccepter,
    required this.onRefuser,
  });

  final _AdhesionView adhesion;
  final VoidCallback onAccepter;
  final VoidCallback onRefuser;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(AppDimens.space16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: _kBrCard,
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Tête : avatar + nom + ville/tel + temps
          Row(
            children: [
              _Avatar(url: adhesion.avatarUrl, nom: adhesion.nom),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      adhesion.nom,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.titleSmall.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (_meta(adhesion).isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        _meta(adhesion),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodySmall.copyWith(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                    if (adhesion.time != null &&
                        adhesion.time!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        adhesion.time!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.labelSmall.copyWith(
                          fontSize: 11,
                          color: AppColors.textSubtle,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Actions : Refuser (rouge léger) + Accepter (vert primaire)
          Row(
            children: [
              Expanded(
                child: _OutlineButton(
                  label: 'Refuser',
                  textColor: AppColors.error,
                  onTap: onRefuser,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _FilledButton(
                  label: 'Accepter',
                  onTap: onAccepter,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _meta(_AdhesionView a) {
    final parts = <String>[];
    if (a.ville != null && a.ville!.isNotEmpty) parts.add(a.ville!);
    if (a.tel != null && a.tel!.isNotEmpty) parts.add(a.tel!);
    return parts.join(' · ');
  }
}

// ─── Avatar (Unsplash si dispo, sinon initiales) ────────────────────────

class _Avatar extends StatelessWidget {
  const _Avatar({required this.url, required this.nom});

  final String? url;
  final String nom;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: _kPrimarySoft,
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: (url == null || url!.isEmpty)
          ? Center(
              child: Text(
                _initiales(nom),
                style: AppTextStyles.titleSmall.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            )
          : CachedNetworkImage(
              imageUrl: url!,
              fit: BoxFit.cover,
              placeholder: (_, __) => const ColoredBox(color: _kPrimarySoft),
              errorWidget: (_, __, ___) => Center(
                child: Text(
                  _initiales(nom),
                  style: AppTextStyles.titleSmall.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
    );
  }
}

// ─── Boutons ────────────────────────────────────────────────────────────

class _OutlineButton extends StatelessWidget {
  const _OutlineButton({
    required this.label,
    required this.textColor,
    required this.onTap,
  });

  final String label;
  final Color textColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.background,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: AppColors.border,
              width: AppDimens.borderThin,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: AppTextStyles.labelMedium.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }
}

class _FilledButton extends StatelessWidget {
  const _FilledButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: AppColors.primary,
              width: AppDimens.borderThin,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: AppTextStyles.labelMedium.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.onPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── État vide ──────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.space24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.group_add_outlined,
              size: 40,
              color: AppColors.textSubtle.withValues(alpha: 0.9),
            ),
            const SizedBox(height: AppDimens.space12),
            Text(
              'Aucune demande en attente',
              style: AppTextStyles.titleSmall,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Helpers ────────────────────────────────────────────────────────────

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
