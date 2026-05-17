import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../routing/route_names.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_dimens.dart';
import '../../../theme/app_text_styles.dart';
import '../../widgets/communs/snackbars.dart';

// ─── Constantes locales ─────────────────────────────────────────────────
const Color _kPrimarySoft = Color(0xFFE8F5E9);
const BorderRadius _kBrInput = BorderRadius.all(Radius.circular(10));
const BorderRadius _kBrCard12 = BorderRadius.all(Radius.circular(12));
const BorderRadius _kBrCard14 = BorderRadius.all(Radius.circular(14));

/// Modèle local d'une invitation envoyée (mock).
class _InvitationMock {
  final String nom;
  final String tel;
  final String time;
  const _InvitationMock({
    required this.nom,
    required this.tel,
    required this.time,
  });
}

const List<_InvitationMock> _kInvitations = [
  _InvitationMock(
    nom: 'Yao Konaté',
    tel: '+225 07 11 22 33 44',
    time: 'envoyée il y a 3j',
  ),
  _InvitationMock(
    nom: 'Aminata Bah',
    tel: '+225 05 99 88 77 66',
    time: 'envoyée il y a 3j',
  ),
  _InvitationMock(
    nom: 'Kouadio Kouamé',
    tel: '+225 01 44 55 66 77',
    time: 'envoyée il y a 5j',
  ),
  _InvitationMock(
    nom: 'Mariam Sanogo',
    tel: '+225 07 88 99 00 11',
    time: 'envoyée il y a 7j',
  ),
];

/// Page Inviter un farmer — formulaire SMS d'invitation + historique.
/// Reproduction fidèle de `mockups/cooperative/inviter_farmer.html`.
class InviterFarmerPage extends StatefulWidget {
  const InviterFarmerPage({super.key});

  @override
  State<InviterFarmerPage> createState() => _InviterFarmerPageState();
}

class _InviterFarmerPageState extends State<InviterFarmerPage> {
  final TextEditingController _telCtrl =
      TextEditingController(text: '07 65 43 21 09');
  final TextEditingController _nomCtrl =
      TextEditingController(text: 'Sékou Traoré');
  final TextEditingController _villeCtrl =
      TextEditingController(text: 'Songon');

  @override
  void dispose() {
    _telCtrl.dispose();
    _nomCtrl.dispose();
    _villeCtrl.dispose();
    super.dispose();
  }

  void _envoyer() {
    Snackbars.showSucces(context, 'Invitation envoyée par SMS');
  }

  @override
  Widget build(BuildContext context) {
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
                  // ── Carte info ──────────────────────────────────────
                  const _InfoCard(),
                  const SizedBox(height: 20),
                  // ── Champ téléphone (préfixe +225) ─────────────────
                  _FieldLabel('Téléphone'),
                  const SizedBox(height: 6),
                  _PhoneInput(controller: _telCtrl),
                  const SizedBox(height: 14),
                  // ── Champ Nom ──────────────────────────────────────
                  _FieldLabel('Nom (optionnel)'),
                  const SizedBox(height: 6),
                  _SimpleInput(
                    controller: _nomCtrl,
                    placeholder: 'Nom du farmer',
                  ),
                  const SizedBox(height: 14),
                  // ── Champ Ville ────────────────────────────────────
                  _FieldLabel('Village/Ville (optionnel)'),
                  const SizedBox(height: 6),
                  _SimpleInput(
                    controller: _villeCtrl,
                    placeholder: 'Ex : Dabou',
                  ),
                  const SizedBox(height: 20),
                  // ── Bouton envoyer ─────────────────────────────────
                  _FullButton(
                    label: "Envoyer l'invitation",
                    onTap: _envoyer,
                  ),
                  const SizedBox(height: 24),
                  // ── Section invitations envoyées ───────────────────
                  Text(
                    'Invitations envoyées (${_kInvitations.length})',
                    style: AppTextStyles.titleSmall.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _InvitationsList(invitations: _kInvitations),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Header (back + titre + cloche notifs) ──────────────────────────────

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
              'Inviter un farmer',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.titleSmall.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          _NotifsButton(
            onTap: () =>
                context.push(RouteNames.cooperativeNotificationsPath),
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

// ─── Carte info (icône + message d'aide) ────────────────────────────────

class _InfoCard extends StatelessWidget {
  const _InfoCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: _kBrCard12,
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: _kPrimarySoft,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(
                Icons.info_outline,
                size: 18,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "Indique le numéro de ton farmer. Il recevra un SMS "
              "d'invitation pour rejoindre ta coopérative.",
              style: AppTextStyles.bodySmall.copyWith(
                fontSize: 12,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Inputs ─────────────────────────────────────────────────────────────

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

class _PhoneInput extends StatelessWidget {
  const _PhoneInput({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: _kBrInput,
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
            decoration: const BoxDecoration(
              color: AppColors.surfaceSoft,
              border: Border(
                right: BorderSide(
                  color: AppColors.border,
                  width: AppDimens.borderThin,
                ),
              ),
            ),
            child: Text(
              '+225',
              style: AppTextStyles.titleSmall.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9 ]')),
              ],
              decoration: InputDecoration(
                hintText: '07 12 34 56 78',
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
          ),
        ],
      ),
    );
  }
}

class _SimpleInput extends StatelessWidget {
  const _SimpleInput({required this.controller, required this.placeholder});

  final TextEditingController controller;
  final String placeholder;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: _kBrInput,
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: placeholder,
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

// ─── Bouton plein largeur vert ──────────────────────────────────────────

class _FullButton extends StatelessWidget {
  const _FullButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          elevation: 0,
          shape: const RoundedRectangleBorder(borderRadius: _kBrCard12),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelLarge.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.onPrimary,
          ),
        ),
      ),
    );
  }
}

// ─── Liste des invitations envoyées ─────────────────────────────────────

class _InvitationsList extends StatelessWidget {
  const _InvitationsList({required this.invitations});

  final List<_InvitationMock> invitations;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: _kBrCard14,
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (int i = 0; i < invitations.length; i++) ...[
            _InvitationTile(invitation: invitations[i]),
            if (i != invitations.length - 1)
              const Divider(
                height: 1,
                thickness: AppDimens.borderThin,
                color: AppColors.border,
              ),
          ],
        ],
      ),
    );
  }
}

class _InvitationTile extends StatelessWidget {
  const _InvitationTile({required this.invitation});

  final _InvitationMock invitation;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: AppColors.surfaceSoft,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              _initiales(invitation.nom),
              style: AppTextStyles.titleSmall.copyWith(
                fontFamily: 'Poppins',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
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
                  invitation.nom,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.titleSmall.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  invitation.tel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            invitation.time,
            style: AppTextStyles.labelSmall.copyWith(
              fontSize: 11,
              color: AppColors.textSubtle,
            ),
          ),
        ],
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
