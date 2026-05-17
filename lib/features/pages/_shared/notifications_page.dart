import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../models/enums.dart';
import '../../../routing/route_names.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_dimens.dart';
import '../../../theme/app_text_styles.dart';
import '../../state/auth_state.dart';
import '../../widgets/communs/snackbars.dart';

// ─── Couleurs accent (conformes aux mockups) ────────────────────────────

const Color _kPrimarySoft = Color(0xFFE8F5E9);
const Color _kWarnSoft = Color(0xFFFEF3C7);
const Color _kWarn = Color(0xFFB45309);
const Color _kInfoSoft = Color(0xFFDBEAFE);
const Color _kInfo = Color(0xFF1D4ED8);

/// Type sémantique pour piloter la couleur de la bulle d'icône.
enum _NotifKind { primary, warn, info }

/// Modèle local pour une notification mock.
class _MockNotif {
  final String emoji;
  final _NotifKind kind;
  final String titre;
  final String sousTitre;
  final String temps;
  final bool unread;

  const _MockNotif({
    required this.emoji,
    required this.kind,
    required this.titre,
    required this.sousTitre,
    required this.temps,
    required this.unread,
  });
}

// ─── Mocks par rôle (1:1 avec les anciennes pages spécifiques) ──────────

const List<_MockNotif> _kMockNotifsProducteur = [
  _MockNotif(
    emoji: '🛒',
    kind: _NotifKind.primary,
    titre: 'Commande reçue · Restaurant Le Baoulé',
    sousTitre: '500 kg de maïs commandés · 175 000 F',
    temps: 'il y a 8 min',
    unread: true,
  ),
  _MockNotif(
    emoji: '🤝',
    kind: _NotifKind.primary,
    titre: 'Sollicitation de ta coop',
    sousTitre: 'COOP-AGRI Lagunes cherche du maïs blanc',
    temps: 'il y a 1h',
    unread: true,
  ),
  _MockNotif(
    emoji: '💰',
    kind: _NotifKind.primary,
    titre: 'Paiement reçu',
    sousTitre: '+95 000 F crédités · Vente Manioc',
    temps: 'il y a 3h',
    unread: true,
  ),
  _MockNotif(
    emoji: '📅',
    kind: _NotifKind.warn,
    titre: 'Prévision dans 5 jours',
    sousTitre: 'Récolte Maïs blanc prévue 20 mai · prépare ton stock',
    temps: 'il y a 4h',
    unread: true,
  ),
  _MockNotif(
    emoji: '⭐',
    kind: _NotifKind.primary,
    titre: 'Nouvel avis · 5★ de Marie Yao',
    sousTitre: '« Excellente qualité et ponctualité »',
    temps: 'il y a 6h',
    unread: true,
  ),
  _MockNotif(
    emoji: '💸',
    kind: _NotifKind.primary,
    titre: 'Acompte reçu',
    sousTitre: '+7 000 F de la prévision Yao K.',
    temps: 'hier · 18:42',
    unread: false,
  ),
  _MockNotif(
    emoji: '💬',
    kind: _NotifKind.info,
    titre: 'Message de ta coopérative',
    sousTitre: '« Réunion mensuelle vendredi à 16h »',
    temps: 'hier · 15:10',
    unread: false,
  ),
  _MockNotif(
    emoji: '🚚',
    kind: _NotifKind.primary,
    titre: 'Transporteur arrivé sur place',
    sousTitre: 'Camion Vert prêt à charger ton lot Manioc',
    temps: 'hier · 09:12',
    unread: false,
  ),
  _MockNotif(
    emoji: '🔄',
    kind: _NotifKind.info,
    titre: 'Mise à jour disponible',
    sousTitre: 'FarmCash v2.4 — nouvelles fonctions prévision',
    temps: 'il y a 2j',
    unread: false,
  ),
  _MockNotif(
    emoji: '📈',
    kind: _NotifKind.primary,
    titre: 'Prix du Maïs en hausse',
    sousTitre: '+8% cette semaine sur la zone Lagunes',
    temps: 'il y a 3j',
    unread: false,
  ),
];

const List<_MockNotif> _kMockNotifsAcheteur = [
  _MockNotif(
    emoji: '🛒',
    kind: _NotifKind.primary,
    titre: 'Proposition reçue · Yao K.',
    sousTitre: '100 kg Maïs à 820 F/kg pour ta demande',
    temps: 'il y a 5 min',
    unread: true,
  ),
  _MockNotif(
    emoji: '📦',
    kind: _NotifKind.primary,
    titre: 'Commande #C-0089 en route',
    sousTitre: 'Camion Vert · ETA 14h28',
    temps: 'il y a 1h',
    unread: true,
  ),
  _MockNotif(
    emoji: '💰',
    kind: _NotifKind.primary,
    titre: 'Prévision réservée convertie',
    sousTitre: 'Ton Maïs Yao K. est dispo · Paye le solde 63 000 F',
    temps: 'il y a 2h',
    unread: true,
  ),
  _MockNotif(
    emoji: '⭐',
    kind: _NotifKind.primary,
    titre: 'Demande de validation',
    sousTitre: 'Note la commande de Aya N.',
    temps: 'il y a 6h',
    unread: true,
  ),
  _MockNotif(
    emoji: '⚠️',
    kind: _NotifKind.warn,
    titre: 'Acompte expire J-1',
    sousTitre: 'Confirme ta réservation Tomate avant demain',
    temps: 'il y a 8h',
    unread: true,
  ),
  _MockNotif(
    emoji: '💵',
    kind: _NotifKind.primary,
    titre: 'Paiement reçu',
    sousTitre: 'Aya N. a reçu ton paiement de 19 000 F',
    temps: 'hier',
    unread: false,
  ),
  _MockNotif(
    emoji: '💬',
    kind: _NotifKind.primary,
    titre: 'Nouveau message · COOP-AGRI',
    sousTitre: 'Bonjour Marie, votre commande agrégée…',
    temps: 'hier',
    unread: false,
  ),
  _MockNotif(
    emoji: '✅',
    kind: _NotifKind.primary,
    titre: 'Livraison confirmée',
    sousTitre: 'Commande #C-0078 livrée à 16h45',
    temps: '2 jours',
    unread: false,
  ),
  _MockNotif(
    emoji: '📊',
    kind: _NotifKind.primary,
    titre: 'Prix du Manioc en baisse',
    sousTitre: '−12 % cette semaine · bon moment pour acheter',
    temps: '3 jours',
    unread: false,
  ),
  _MockNotif(
    emoji: '🎉',
    kind: _NotifKind.primary,
    titre: 'Bienvenue sur FarmCash',
    sousTitre: 'Découvre les producteurs près de chez toi',
    temps: '5 jours',
    unread: false,
  ),
];

const List<_MockNotif> _kMockNotifsCooperative = [
  _MockNotif(
    emoji: '🌾',
    kind: _NotifKind.primary,
    titre: 'Nouvelle livraison de Yao K.',
    sousTitre: 'Maïs blanc 250 kg en route',
    temps: 'il y a 12 min',
    unread: true,
  ),
  _MockNotif(
    emoji: '💰',
    kind: _NotifKind.primary,
    titre: 'Vente clôturée',
    sousTitre: 'Publication Manioc · 350 000 F crédités',
    temps: 'il y a 1h',
    unread: true,
  ),
  _MockNotif(
    emoji: '👤',
    kind: _NotifKind.primary,
    titre: "2 demandes d'adhésion",
    sousTitre: 'Aya et Konan veulent rejoindre',
    temps: 'il y a 3h',
    unread: true,
  ),
  _MockNotif(
    emoji: '📦',
    kind: _NotifKind.primary,
    titre: 'Lot validé',
    sousTitre: 'Igname 500 kg accepté par Industries Agricoles',
    temps: 'il y a 5h',
    unread: true,
  ),
  _MockNotif(
    emoji: '⚠️',
    kind: _NotifKind.warn,
    titre: 'Stock entrepôt Bouaké à 90%',
    sousTitre: 'Capacité bientôt atteinte',
    temps: 'il y a 6h',
    unread: true,
  ),
  _MockNotif(
    emoji: '💸',
    kind: _NotifKind.primary,
    titre: 'Avance versée',
    sousTitre: '15 000 F envoyés à Fatou Bakayoko',
    temps: 'hier · 18:42',
    unread: false,
  ),
  _MockNotif(
    emoji: '💬',
    kind: _NotifKind.info,
    titre: 'Message de Kouassi Bamba',
    sousTitre: '« Je passerai déposer le cacao demain matin »',
    temps: 'hier · 15:10',
    unread: false,
  ),
  _MockNotif(
    emoji: '🔄',
    kind: _NotifKind.info,
    titre: 'Mise à jour disponible',
    sousTitre: 'FarmCash v2.4 — nouvelles fonctions logistique',
    temps: 'hier · 10:00',
    unread: false,
  ),
  _MockNotif(
    emoji: '📈',
    kind: _NotifKind.primary,
    titre: 'Prévision validée',
    sousTitre: 'Récolte maïs estimée à 3.2 t pour ce mois',
    temps: 'il y a 2j',
    unread: false,
  ),
  _MockNotif(
    emoji: '🤝',
    kind: _NotifKind.primary,
    titre: 'Nouvelle offre acheteur',
    sousTitre: 'Restaurant Le Baoulé propose 220 F/kg',
    temps: 'il y a 2j',
    unread: false,
  ),
  _MockNotif(
    emoji: '🚚',
    kind: _NotifKind.primary,
    titre: 'Transport terminé',
    sousTitre: 'Lot LOT-2026-0138 livré à Bouaké',
    temps: 'il y a 3j',
    unread: false,
  ),
  _MockNotif(
    emoji: '⭐',
    kind: _NotifKind.primary,
    titre: 'Nouvelle évaluation',
    sousTitre: 'Industries Agricoles vous a noté 5/5',
    temps: 'il y a 4j',
    unread: false,
  ),
];

const List<_MockNotif> _kMockNotifsTransporteur = [
  _MockNotif(
    emoji: '🚛',
    kind: _NotifKind.primary,
    titre: 'Nouvelle mission disponible',
    sousTitre: '500 kg Maïs · Yopougon → Cocody · +18 500 F',
    temps: 'il y a 5 min',
    unread: true,
  ),
  _MockNotif(
    emoji: '💰',
    kind: _NotifKind.primary,
    titre: 'Paiement reçu',
    sousTitre: '+18 500 F crédités · Mission #M-0088',
    temps: 'il y a 1h',
    unread: true,
  ),
  _MockNotif(
    emoji: '📦',
    kind: _NotifKind.primary,
    titre: 'Producteur prêt',
    sousTitre: 'Yao Konan dit que le colis est prêt à enlever',
    temps: 'il y a 2h',
    unread: true,
  ),
  _MockNotif(
    emoji: '⭐',
    kind: _NotifKind.primary,
    titre: 'Nouvelle note 5★',
    sousTitre: 'Excellent service, ponctuel et soigné — Marie Yao',
    temps: 'il y a 4h',
    unread: true,
  ),
  _MockNotif(
    emoji: '📍',
    kind: _NotifKind.warn,
    titre: "Changement d'adresse",
    sousTitre: 'Mission #M-0086 : nouvelle adresse à Treichville',
    temps: 'hier · 17:22',
    unread: false,
  ),
  _MockNotif(
    emoji: '💬',
    kind: _NotifKind.info,
    titre: 'Message de ta coopérative',
    sousTitre: 'COOP-AGRI Lagunes : « Réunion logistique vendredi »',
    temps: 'hier · 14:08',
    unread: false,
  ),
  _MockNotif(
    emoji: '✖',
    kind: _NotifKind.warn,
    titre: 'Mission rejetée',
    sousTitre: "L'acheteur a annulé la mission #M-0083",
    temps: 'hier · 09:30',
    unread: false,
  ),
  _MockNotif(
    emoji: '💸',
    kind: _NotifKind.primary,
    titre: 'Commission versée',
    sousTitre: '+12 800 F crédités · Mission #M-0087',
    temps: '14 mai · 18:10',
    unread: false,
  ),
  _MockNotif(
    emoji: '🔄',
    kind: _NotifKind.info,
    titre: 'Mise à jour disponible',
    sousTitre: 'FarmCash v2.4 — meilleur suivi GPS',
    temps: '12 mai',
    unread: false,
  ),
  _MockNotif(
    emoji: '📈',
    kind: _NotifKind.primary,
    titre: 'Tarifs en hausse cette semaine',
    sousTitre: '+10% sur l\'axe Abidjan ↔ Bouaké',
    temps: '10 mai',
    unread: false,
  ),
];

List<_MockNotif> _mocksForRole(UserRole? role) {
  switch (role) {
    case UserRole.farmer:
      return _kMockNotifsProducteur;
    case UserRole.buyer:
      return _kMockNotifsAcheteur;
    case UserRole.cooperative:
      return _kMockNotifsCooperative;
    case UserRole.transporter:
      return _kMockNotifsTransporteur;
    default:
      return const [];
  }
}

/// Page Notifications partagée pour les 4 rôles.
///
/// Détecte le rôle via [currentUserProvider] et adapte :
/// - le rendu des tuiles (highlight unread varie selon le rôle),
/// - la navigation back (top-level vs in-stack),
/// - le bottom-nav décoratif quand pertinent,
/// - la liste de mocks fallback.
///
/// Mock-first : aucun endpoint réel branché. Quand
/// `notificationsService.list(...)` sera prêt côté backend, on remplacera
/// [_mocksForRole] par un FutureProvider.
class NotificationsPage extends ConsumerStatefulWidget {
  const NotificationsPage({super.key});

  @override
  ConsumerState<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends ConsumerState<NotificationsPage> {
  List<_MockNotif>? _notifs;
  UserRole? _roleSnapshot;

  void _initIfNeeded(UserRole? role) {
    if (_notifs == null || role != _roleSnapshot) {
      _roleSnapshot = role;
      _notifs = List<_MockNotif>.from(_mocksForRole(role));
    }
  }

  void _toutMarquerLu() {
    setState(() {
      _notifs = (_notifs ?? const [])
          .map((n) => _MockNotif(
                emoji: n.emoji,
                kind: n.kind,
                titre: n.titre,
                sousTitre: n.sousTitre,
                temps: n.temps,
                unread: false,
              ))
          .toList();
    });
    Snackbars.showInfo(
      context,
      'Toutes les notifications ont été marquées comme lues',
    );
  }

  void _ouvrirNotif(int index) {
    setState(() {
      final list = _notifs!;
      final n = list[index];
      list[index] = _MockNotif(
        emoji: n.emoji,
        kind: n.kind,
        titre: n.titre,
        sousTitre: n.sousTitre,
        temps: n.temps,
        unread: false,
      );
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Notification ouverte'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final role = ref.watch(currentUserProvider)?.role;
    _initIfNeeded(role);
    final notifs = _notifs ?? const <_MockNotif>[];
    final highlightFullBg = _highlightFullBg(role);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _Header(
              role: role,
              onToutMarquerLu: _toutMarquerLu,
            ),
            Expanded(
              child: ListView.builder(
                padding: _listPadding(role),
                itemCount: notifs.length,
                itemBuilder: (_, i) => _NotifTile(
                  notif: notifs[i],
                  isLast: i == notifs.length - 1,
                  onTap: () => _ouvrirNotif(i),
                  highlightFullBg: highlightFullBg,
                  layoutForAcheteur: role == UserRole.buyer,
                ),
              ),
            ),
            _BottomNavForRole(role: role),
          ],
        ),
      ),
    );
  }

  EdgeInsets _listPadding(UserRole? role) {
    if (role == UserRole.buyer) return EdgeInsets.zero;
    return const EdgeInsets.fromLTRB(
      AppDimens.pagePaddingH,
      0,
      AppDimens.pagePaddingH,
      AppDimens.space16,
    );
  }

  /// Acheteur / coop / transp. : fond primary-soft pour toute la tuile non-lue.
  /// Producteur : seulement la pastille + bulle (pas de fond plein).
  bool _highlightFullBg(UserRole? role) {
    return role == UserRole.buyer ||
        role == UserRole.cooperative ||
        role == UserRole.transporter;
  }
}

// ─── Header ─────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({required this.role, required this.onToutMarquerLu});

  final UserRole? role;
  final VoidCallback onToutMarquerLu;

  @override
  Widget build(BuildContext context) {
    final isAcheteur = role == UserRole.buyer;
    final isCoop = role == UserRole.cooperative;
    return Container(
      decoration: isAcheteur
          ? const BoxDecoration(
              color: AppColors.background,
              border: Border(
                bottom: BorderSide(
                  color: AppColors.border,
                  width: AppDimens.borderThin,
                ),
              ),
            )
          : null,
      padding: isAcheteur
          ? const EdgeInsets.fromLTRB(8, 8, 16, 12)
          : const EdgeInsets.fromLTRB(
              AppDimens.pagePaddingH,
              AppDimens.space8,
              AppDimens.pagePaddingH,
              AppDimens.space12,
            ),
      child: Row(
        children: [
          InkWell(
            onTap: () {
              if (isCoop) {
                context.canPop()
                    ? context.pop()
                    : context.go(RouteNames.accueilCooperativePath);
              } else if (role == UserRole.transporter) {
                context.canPop()
                    ? context.pop()
                    : context.go(RouteNames.accueilTransporteurPath);
              } else if (isAcheteur) {
                Navigator.of(context).maybePop();
              } else {
                Navigator.of(context).pop();
              }
            },
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
              'Notifications',
              style: AppTextStyles.titleSmall.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          InkWell(
            onTap: onToutMarquerLu,
            borderRadius: BorderRadius.circular(6),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 6,
                vertical: 4,
              ),
              child: Text(
                'Tout lire',
                style: AppTextStyles.link.copyWith(
                  fontSize: isAcheteur ? 12 : 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Notif tile ─────────────────────────────────────────────────────────

class _NotifTile extends StatelessWidget {
  const _NotifTile({
    required this.notif,
    required this.isLast,
    required this.onTap,
    required this.highlightFullBg,
    required this.layoutForAcheteur,
  });

  final _MockNotif notif;
  final bool isLast;
  final VoidCallback onTap;
  final bool highlightFullBg;
  final bool layoutForAcheteur;

  Color get _bubbleBg {
    switch (notif.kind) {
      case _NotifKind.primary:
        return _kPrimarySoft;
      case _NotifKind.warn:
        return _kWarnSoft;
      case _NotifKind.info:
        return _kInfoSoft;
    }
  }

  Color get _bubbleFg {
    switch (notif.kind) {
      case _NotifKind.primary:
        return AppColors.primary;
      case _NotifKind.warn:
        return _kWarn;
      case _NotifKind.info:
        return _kInfo;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Bulle blanche pour notifs primary unread sur fond plein (lisibilité).
    final bubbleBg = highlightFullBg &&
            notif.unread &&
            notif.kind == _NotifKind.primary
        ? AppColors.background
        : _bubbleBg;

    final usePadHorizontal = layoutForAcheteur ? 20.0 : 6.0;

    return InkWell(
      onTap: onTap,
      child: Container(
        color: highlightFullBg && notif.unread
            ? _kPrimarySoft
            : AppColors.background,
        padding: EdgeInsets.symmetric(
          vertical: 14,
          horizontal: highlightFullBg ? usePadHorizontal : 0,
        ),
        foregroundDecoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isLast ? Colors.transparent : AppColors.border,
              width: AppDimens.borderThin,
            ),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 10,
              child: notif.unread
                  ? Container(
                      margin: EdgeInsets.only(
                        top: layoutForAcheteur ? 8 : 10,
                      ),
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary,
                      ),
                    )
                  : null,
            ),
            SizedBox(width: layoutForAcheteur ? 4 : 2),
            // Acheteur a une bulle carrée bordée ; les autres ronde colorée.
            if (layoutForAcheteur)
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.border,
                    width: AppDimens.borderThin,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  notif.emoji,
                  style: const TextStyle(fontSize: 16),
                ),
              )
            else
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: bubbleBg,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  notif.emoji,
                  style: TextStyle(fontSize: 18, color: _bubbleFg),
                ),
              ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    notif.titre,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: layoutForAcheteur ? 13 : 14,
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    notif.sousTitre,
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      height: layoutForAcheteur ? 1.4 : 1.35,
                    ),
                  ),
                  SizedBox(height: layoutForAcheteur ? 5 : 4),
                  Text(
                    notif.temps,
                    style: AppTextStyles.labelSmall.copyWith(
                      fontSize: 11,
                      color: AppColors.textSubtle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Bottom-nav par rôle ────────────────────────────────────────────────

class _BottomNavForRole extends StatelessWidget {
  const _BottomNavForRole({required this.role});

  final UserRole? role;

  @override
  Widget build(BuildContext context) {
    switch (role) {
      case UserRole.farmer:
        return const _BottomNavStaticProducteur();
      case UserRole.buyer:
        return const _BottomNavDimmedAcheteur();
      case UserRole.cooperative:
        return const _BottomNavDimmedCooperative();
      case UserRole.transporter:
        return const _BottomNavDimmedTransporteur();
      default:
        return const SizedBox.shrink();
    }
  }
}

class _BottomNavStaticProducteur extends StatelessWidget {
  const _BottomNavStaticProducteur();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppDimens.bottomNavHeight,
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(
          top: BorderSide(
            color: AppColors.border,
            width: AppDimens.borderThin,
          ),
        ),
      ),
      child: Row(
        children: const [
          _NavItem(icon: Icons.home_outlined, label: 'Accueil'),
          _NavItem(icon: Icons.chat_bubble_outline, label: 'Messages'),
          SizedBox(width: 56 + 8),
          _NavItem(icon: Icons.receipt_long_outlined, label: 'Commandes'),
          _NavItem(icon: Icons.person_outline, label: 'Profil'),
        ],
      ),
    );
  }
}

class _BottomNavDimmedAcheteur extends StatelessWidget {
  const _BottomNavDimmedAcheteur();

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.45,
      child: Container(
        height: AppDimens.bottomNavHeight,
        decoration: const BoxDecoration(
          color: AppColors.background,
          border: Border(
            top: BorderSide(
              color: AppColors.border,
              width: AppDimens.borderThin,
            ),
          ),
        ),
        child: Row(
          children: const [
            _NavItem(icon: Icons.home_outlined, label: 'Accueil'),
            _NavItem(icon: Icons.storefront_outlined, label: 'Marché'),
            _NavItem(icon: Icons.chat_bubble_outline, label: 'Messages'),
            _NavItem(icon: Icons.receipt_long_outlined, label: 'Commandes'),
            _NavItem(icon: Icons.person_outline, label: 'Profil'),
          ],
        ),
      ),
    );
  }
}

class _BottomNavDimmedCooperative extends StatelessWidget {
  const _BottomNavDimmedCooperative();

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.45,
      child: Container(
        height: AppDimens.bottomNavHeight,
        decoration: const BoxDecoration(
          color: AppColors.background,
          border: Border(
            top: BorderSide(
              color: AppColors.border,
              width: AppDimens.borderThin,
            ),
          ),
        ),
        child: Row(
          children: const [
            _NavItem(icon: Icons.home_outlined, label: 'Accueil'),
            _NavItem(icon: Icons.groups_outlined, label: 'Membres'),
            SizedBox(width: 56 + 8),
            _NavItem(icon: Icons.inventory_2_outlined, label: 'Stock'),
            _NavItem(icon: Icons.storefront_outlined, label: 'Marché'),
          ],
        ),
      ),
    );
  }
}

class _BottomNavDimmedTransporteur extends StatelessWidget {
  const _BottomNavDimmedTransporteur();

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.45,
      child: Container(
        height: AppDimens.bottomNavHeight,
        decoration: const BoxDecoration(
          color: AppColors.background,
          border: Border(
            top: BorderSide(
              color: AppColors.border,
              width: AppDimens.borderThin,
            ),
          ),
        ),
        child: Row(
          children: const [
            _NavItem(icon: Icons.home_outlined, label: 'Accueil'),
            _NavItem(icon: Icons.local_shipping_outlined, label: 'Missions'),
            _NavItem(icon: Icons.chat_bubble_outline, label: 'Messages'),
            _NavItem(icon: Icons.person_outline, label: 'Profil'),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 22, color: AppColors.textSecondary),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
