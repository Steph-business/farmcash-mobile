import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../routing/route_names.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../widgets/communs/snackbars.dart';

// ─── Couleurs & photos (alignées maquette HTML) ─────────────────────────

const Color _kPrimarySoft = Color(0xFFE8F5E9);

// Photo membre (Unsplash — portrait farmer neutre).
const String _kPhotoMembre =
    'https://images.unsplash.com/photo-1531123897727-8f129e1688ce'
    '?w=200&h=200&fit=crop&auto=format';

/// Modèle local d'un membre coop sélectionné pour l'avance.
/// FULL — la coop voit ses membres en clair (règle 3b).
class _MembreSelection {
  final String id;
  final String nom; // FULL ("Yao Konan", pas "Yao K.")
  final String walletFmt; // ex : "25 000 F"
  final String photo;
  const _MembreSelection({
    required this.id,
    required this.nom,
    required this.walletFmt,
    required this.photo,
  });
}

/// Page Verser une avance — sélection membre, montant centré, motif,
/// CTA dynamique. Reproduction fidèle de
/// `mockups/cooperative/verser_avance.html`.
class VerserAvancePage extends StatefulWidget {
  const VerserAvancePage({super.key, this.membreIdInitial});

  /// ID du membre pré-sélectionné (passé en query param via la fiche
  /// membre, ou null si ouverture directe depuis le menu coop).
  final String? membreIdInitial;

  @override
  State<VerserAvancePage> createState() => _VerserAvancePageState();
}

class _VerserAvancePageState extends State<VerserAvancePage> {
  late final TextEditingController _montantCtrl;
  late final TextEditingController _motifCtrl;
  late _MembreSelection? _membre;

  @override
  void initState() {
    super.initState();
    // Si membreIdInitial est passé, on simule la sélection avec Yao Konan
    // (mock fidèle à la maquette). Sinon on démarre vide.
    _membre = widget.membreIdInitial == null
        ? const _MembreSelection(
            id: 'm-yao-konan',
            nom: 'Yao Konan',
            walletFmt: '25 000 F',
            photo: _kPhotoMembre,
          )
        : const _MembreSelection(
            id: 'm-yao-konan',
            nom: 'Yao Konan',
            walletFmt: '25 000 F',
            photo: _kPhotoMembre,
          );
    _montantCtrl = TextEditingController(text: '50 000 F');
    _motifCtrl = TextEditingController(text: 'Avance récolte juin');
  }

  @override
  void dispose() {
    _montantCtrl.dispose();
    _motifCtrl.dispose();
    super.dispose();
  }

  void _choisirMembre() {
    setState(() {
      _membre = const _MembreSelection(
        id: 'm-yao-konan',
        nom: 'Yao Konan',
        walletFmt: '25 000 F',
        photo: _kPhotoMembre,
      );
    });
    Snackbars.showInfo(context, 'Sélection membre — à venir');
  }

  void _verser() {
    Snackbars.showSucces(context, 'Avance versée — à venir');
  }

  @override
  Widget build(BuildContext context) {
    final montantAffiche = _montantCtrl.text.trim().isEmpty
        ? '0 F'
        : _montantCtrl.text.trim();
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const _Header(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppDimens.pagePaddingH,
                  0,
                  AppDimens.pagePaddingH,
                  AppDimens.space16,
                ),
                children: [
                  const _FieldLabel('Membre'),
                  AppDimens.vGap8,
                  if (_membre == null)
                    _ChoisirMembreButton(onTap: _choisirMembre)
                  else
                    _SelectedMember(
                      membre: _membre!,
                      onChange: _choisirMembre,
                    ),
                  AppDimens.vGap16,
                  const _CoopBalanceCard(soldeFmt: '84 500 F'),
                  AppDimens.vGap24,
                  _AmountBlock(controller: _montantCtrl),
                  AppDimens.vGap24,
                  const _FieldLabel('Motif (optionnel)'),
                  AppDimens.vGap8,
                  _MotifInput(controller: _motifCtrl),
                ],
              ),
            ),
            _StickyVerserButton(
              label: 'Verser $montantAffiche maintenant',
              onTap: _verser,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Header ──────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header();

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
                : context.go(RouteNames.accueilCooperativePath),
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
              'Verser une avance',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.titleSmall.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          _NotifsButton(
            onTap: () => context.push(RouteNames.cooperativeNotificationsPath),
          ),
        ],
      ),
    );
  }
}

class _NotifsButton extends StatelessWidget {
  const _NotifsButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: SizedBox(
        width: 40,
        height: 40,
        child: Stack(
          children: [
            const Center(
              child: Icon(
                Icons.notifications_none,
                size: 22,
                color: AppColors.text,
              ),
            ),
            Positioned(
              top: 6,
              right: 6,
              child: Container(
                constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                padding: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: AppColors.error,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.background,
                    width: 1.5,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  '5',
                  style: AppTextStyles.labelSmall.copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onPrimary,
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

// ─── Label réutilisable ─────────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: AppTextStyles.labelMedium.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.text,
      ),
    );
  }
}

// ─── Sélection membre ───────────────────────────────────────────────────

class _ChoisirMembreButton extends StatelessWidget {
  const _ChoisirMembreButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppDimens.brCard,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: AppDimens.brCard,
          border: Border.all(
            color: AppColors.borderStrong,
            width: AppDimens.borderThin,
          ),
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.person_add_alt_1, size: 18, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(
              'Choisir un membre',
              style: AppTextStyles.labelLarge.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SelectedMember extends StatelessWidget {
  const _SelectedMember({required this.membre, required this.onChange});

  final _MembreSelection membre;
  final VoidCallback onChange;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: AppDimens.brCard,
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _kPrimarySoft,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.border,
                width: AppDimens.borderThin,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: CachedNetworkImage(
              imageUrl: membre.photo,
              fit: BoxFit.cover,
              placeholder: (_, _) => const ColoredBox(color: _kPrimarySoft),
              errorWidget: (_, _, _) => Center(
                child: Text(
                  _initiales(membre.nom),
                  style: AppTextStyles.titleSmall.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // FULL — coop voit ses membres en clair
                Text(
                  membre.nom,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.titleSmall.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Solde wallet · ${membre.walletFmt}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: onChange,
            borderRadius: BorderRadius.circular(6),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 4,
                vertical: 4,
              ),
              child: Text(
                'Changer',
                style: AppTextStyles.labelMedium.copyWith(
                  fontSize: 12,
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

// ─── Carte solde coop ───────────────────────────────────────────────────

class _CoopBalanceCard extends StatelessWidget {
  const _CoopBalanceCard({required this.soldeFmt});

  final String soldeFmt;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: AppDimens.brCard,
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
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.credit_card_outlined,
              size: 18,
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
                  'Ton solde',
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  soldeFmt,
                  style: AppTextStyles.titleLarge.copyWith(
                    fontFamily: AppTextStyles.displayLarge.fontFamily,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text,
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

// ─── Bloc montant (input centré grandes lettres) ────────────────────────

class _AmountBlock extends StatelessWidget {
  const _AmountBlock({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Montant à verser',
          style: AppTextStyles.bodySmall.copyWith(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          textAlign: TextAlign.center,
          keyboardType: TextInputType.text,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9 F]')),
          ],
          style: AppTextStyles.displayLarge.copyWith(
            fontSize: 36,
            fontWeight: FontWeight.w700,
            letterSpacing: -1,
            color: AppColors.text,
          ),
          decoration: const InputDecoration(
            isDense: true,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 4),
            hintText: '0 F',
          ),
        ),
      ],
    );
  }
}

// ─── Input motif ────────────────────────────────────────────────────────

class _MotifInput extends StatelessWidget {
  const _MotifInput({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: AppDimens.brInput,
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: 'Ex : Avance récolte juin',
          border: InputBorder.none,
          isDense: true,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          hintStyle: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSubtle,
          ),
        ),
        style: AppTextStyles.bodyMedium.copyWith(fontSize: 14),
      ),
    );
  }
}

// ─── Sticky bottom (CTA plein vert dynamique) ───────────────────────────

class _StickyVerserButton extends StatelessWidget {
  const _StickyVerserButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

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
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
      child: SizedBox(
        width: double.infinity,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppDimens.brCard,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: AppDimens.brCard,
              border: Border.all(
                color: AppColors.primary,
                width: AppDimens.borderThin,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              label,
              style: AppTextStyles.labelLarge.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.onPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Helpers ─────────────────────────────────────────────────────────────

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
