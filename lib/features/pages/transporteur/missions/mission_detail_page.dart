import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../routing/route_names.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../widgets/communs/snackbars.dart';

const Color _kPrimarySoft = Color(0xFFE8F5E9);
const Color _kMapBg = Color(0xFFE5F4E8);
const String _kPhoto =
    'https://images.unsplash.com/photo-1601493700631-2b16ec4b4716?w=200&h=200&fit=crop&auto=format';
const String _kAvatarProducteur =
    'https://images.unsplash.com/photo-1531123897727-8f129e1688ce?w=200&h=200&fit=crop&auto=format';
const String _kAvatarAcheteur =
    'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=200&h=200&fit=crop&auto=format';

/// Détail d'une mission transporteur — hero produit, trajet, montant,
/// producteur, acheteur, timeline de suivi et CTA "Démarrer la mission".
class MissionDetailPage extends ConsumerWidget {
  const MissionDetailPage({required this.missionId, super.key});

  final String missionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _Header(missionId: missionId),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
                children: const [
                  _HeroCard(),
                  AppDimens.vGap16,
                  _SectionTitle('Trajet'),
                  AppDimens.vGap8,
                  _TrajetCard(),
                  AppDimens.vGap16,
                  _SectionTitle('Montant'),
                  AppDimens.vGap8,
                  _MontantCard(),
                  AppDimens.vGap16,
                  _SectionTitle('Producteur'),
                  AppDimens.vGap8,
                  _PersonCard(
                    avatarUrl: _kAvatarProducteur,
                    name: 'Yao Konan',
                    role: 'Producteur · Yopougon',
                  ),
                  AppDimens.vGap16,
                  _SectionTitle('Acheteur'),
                  AppDimens.vGap8,
                  _PersonCard(
                    avatarUrl: _kAvatarAcheteur,
                    name: 'Restaurant Le Baoulé',
                    role: 'Acheteur · Cocody',
                  ),
                  AppDimens.vGap16,
                  _SectionTitle('Suivi'),
                  AppDimens.vGap8,
                  _TimelineCard(),
                ],
              ),
            ),
            _StickyBar(missionId: missionId),
          ],
        ),
      ),
    );
  }
}

// ─── Header ──────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({required this.missionId});

  final String missionId;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(
          bottom: BorderSide(
            color: AppColors.border,
            width: AppDimens.borderThin,
          ),
        ),
      ),
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
              'Mission #${missionId.isEmpty ? 'M-2026-0089' : missionId}',
              style: AppTextStyles.titleSmall.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Hero card ───────────────────────────────────────────────────────────

class _HeroCard extends StatelessWidget {
  const _HeroCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: AppDimens.borderThin),
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CachedNetworkImage(
              imageUrl: _kPhoto,
              width: 64,
              height: 64,
              fit: BoxFit.cover,
              placeholder: (_, _) => Container(
                width: 64,
                height: 64,
                color: AppColors.surfaceSoft,
              ),
              errorWidget: (_, _, _) => Container(
                width: 64,
                height: 64,
                color: AppColors.surfaceSoft,
                child: const Icon(Icons.image_outlined,
                    size: 22, color: AppColors.textSubtle),
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
                  '500 kg Maïs grain blanc',
                  style: AppTextStyles.titleSmall.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _kPrimarySoft,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check, size: 10, color: AppColors.primary),
                      const SizedBox(width: 4),
                      Text(
                        'Qualité Standard',
                        style: AppTextStyles.labelSmall.copyWith(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
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

// ─── Section title ──────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: AppTextStyles.labelSmall.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
        letterSpacing: 0.3,
      ),
    );
  }
}

// ─── Trajet ─────────────────────────────────────────────────────────────

class _TrajetCard extends StatelessWidget {
  const _TrajetCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: AppDimens.borderThin),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 80,
            decoration: BoxDecoration(
              color: _kMapBg,
              borderRadius: BorderRadius.circular(10),
              border:
                  Border.all(color: AppColors.border, width: AppDimens.borderThin),
            ),
          ),
          const SizedBox(height: 12),
          const _Pin(
            color: AppColors.primary,
            title: 'Yopougon · Yao Konan',
            subtitle: 'Producteur · Champ derrière la maison',
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(11, 6, 0, 6),
            child: Icon(Icons.arrow_downward,
                size: 14, color: AppColors.textSubtle),
          ),
          const _Pin(
            color: AppColors.error,
            title: 'Cocody · Restaurant Le Baoulé',
            subtitle: 'Acheteur · Rue des Jardins',
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.only(top: 12),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(
                    color: AppColors.border, width: AppDimens.borderThin),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.access_time,
                    size: 14, color: AppColors.textSecondary),
                const SizedBox(width: 6),
                Text(
                  '12 km · ~35 min · 4.2 L estimés',
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 12,
                    color: AppColors.textSecondary,
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

class _Pin extends StatelessWidget {
  const _Pin({
    required this.color,
    required this.title,
    required this.subtitle,
  });

  final Color color;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          alignment: Alignment.center,
          child: const Icon(Icons.place, size: 12, color: Colors.white),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: AppTextStyles.bodySmall.copyWith(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Montant ─────────────────────────────────────────────────────────────

class _MontantCard extends StatelessWidget {
  const _MontantCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _kPrimarySoft,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _kPrimarySoft, width: AppDimens.borderThin),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          Text(
            'TA COMMISSION',
            style: AppTextStyles.labelSmall.copyWith(
              fontSize: 11,
              color: AppColors.textSecondary,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '+18 500 F',
            style: AppTextStyles.displayLarge.copyWith(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Versée après livraison confirmée',
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Person card ────────────────────────────────────────────────────────

class _PersonCard extends StatelessWidget {
  const _PersonCard({
    required this.avatarUrl,
    required this.name,
    required this.role,
  });

  final String avatarUrl;
  final String name;
  final String role;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: AppDimens.borderThin),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          ClipOval(
            child: CachedNetworkImage(
              imageUrl: avatarUrl,
              width: 40,
              height: 40,
              fit: BoxFit.cover,
              placeholder: (_, _) => Container(
                width: 40,
                height: 40,
                color: AppColors.surfaceSoft,
              ),
              errorWidget: (_, _, _) => Container(
                width: 40,
                height: 40,
                color: AppColors.surfaceSoft,
                child: const Icon(Icons.person,
                    size: 20, color: AppColors.textSubtle),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  name,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  role,
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _IconBtn(
                icon: Icons.phone,
                onTap: () =>
                    Snackbars.showInfo(context, 'Appel — à venir'),
              ),
              const SizedBox(width: 6),
              _IconBtn(
                icon: Icons.chat_bubble_outline,
                onTap: () =>
                    Snackbars.showInfo(context, 'Message — à venir'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  const _IconBtn({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: _kPrimarySoft,
          borderRadius: BorderRadius.circular(10),
          border:
              Border.all(color: _kPrimarySoft, width: AppDimens.borderThin),
        ),
        alignment: Alignment.center,
        child: Icon(icon, size: 16, color: AppColors.primary),
      ),
    );
  }
}

// ─── Timeline ───────────────────────────────────────────────────────────

class _TimelineCard extends StatelessWidget {
  const _TimelineCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: AppDimens.borderThin),
      ),
      padding: const EdgeInsets.all(14),
      child: const Column(
        children: [
          _TlItem(
            done: true,
            title: 'Mission acceptée',
            time: '10h12',
            isLast: false,
          ),
          _TlItem(
            done: false,
            title: 'En route vers producteur',
            time: 'départ 10h30',
            isLast: false,
          ),
          _TlItem(
            done: false,
            title: 'Scan QR enlèvement chez producteur',
            isLast: false,
          ),
          _TlItem(
            done: false,
            title: 'En route vers acheteur',
            isLast: false,
          ),
          _TlItem(
            done: false,
            title: 'Scan QR livraison chez acheteur',
            isLast: true,
          ),
        ],
      ),
    );
  }
}

class _TlItem extends StatelessWidget {
  const _TlItem({
    required this.done,
    required this.title,
    required this.isLast,
    this.time,
  });

  final bool done;
  final String title;
  final String? time;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: done ? AppColors.primary : AppColors.surfaceSoft,
                  shape: BoxShape.circle,
                  border: done
                      ? null
                      : Border.all(
                          color: AppColors.border,
                          width: AppDimens.borderThin),
                ),
                alignment: Alignment.center,
                child: done
                    ? const Icon(Icons.check, size: 12, color: Colors.white)
                    : const Icon(Icons.access_time,
                        size: 11, color: AppColors.textSubtle),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 1.5,
                    color: AppColors.border,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 14, top: 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: 13,
                      fontWeight: done ? FontWeight.w600 : FontWeight.w500,
                      color: done ? AppColors.text : AppColors.textSecondary,
                    ),
                  ),
                  if (time != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      time!,
                      style: AppTextStyles.labelSmall.copyWith(
                        fontSize: 11,
                        color: AppColors.textSubtle,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Sticky bar ─────────────────────────────────────────────────────────

class _StickyBar extends StatelessWidget {
  const _StickyBar({required this.missionId});

  final String missionId;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(
          top: BorderSide(
              color: AppColors.border, width: AppDimens.borderThin),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 46,
              child: OutlinedButton.icon(
                onPressed: () =>
                    Snackbars.showInfo(context, 'Navigation — à venir'),
                icon: const Icon(Icons.navigation_outlined, size: 16),
                label: Text(
                  'Naviguer',
                  style: AppTextStyles.button.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(
                      color: AppColors.primary, width: AppDimens.borderThin),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  padding: EdgeInsets.zero,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: SizedBox(
              height: 46,
              child: ElevatedButton(
                onPressed: () => context.push(
                  RouteNames.transporteurMissionEnRoutePathFor(
                      missionId.isEmpty ? 'M-2026-0089' : missionId),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: Text(
                  'Démarrer la mission',
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

