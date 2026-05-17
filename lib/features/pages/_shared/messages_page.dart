import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../models/enums.dart';
import '../../../routing/route_names.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_dimens.dart';
import '../../../theme/app_text_styles.dart';
import '../../state/auth_state.dart';
import '../../widgets/communs/header_utilisateur.dart';

// ─── Couleurs locales (alignées sur les maquettes) ──────────────────────

const Color _kPrimarySoft = Color(0xFFE8F5E9);
// Producteur
const Color _kChipAcheteurBg = Color(0xFFFFF8E1);
const Color _kChipAcheteurFg = Color(0xFFB26A00);
const Color _kChipTransportBg = Color(0xFFDBEAFE);
const Color _kChipTransportFg = Color(0xFF1D4ED8);
// Acheteur
const Color _kChipCoopBgAcheteur = Color(0xFFEFF6FF);
const Color _kChipCoopFgAcheteur = Color(0xFF1E40AF);
const Color _kChipTransBgAcheteur = Color(0xFFFEF3C7);
const Color _kChipTransFgAcheteur = Color(0xFFB45309);
// Transporteur
const Color _kChipCoopBgTransp = Color(0xFFE0E7FF);
const Color _kChipCoopFgTransp = Color(0xFF3730A3);
const Color _kChipAcheteurBgTransp = Color(0xFFFFF8E1);
const Color _kChipAcheteurFgTransp = Color(0xFFB26A00);

/// Filtres possibles pour la liste — superset des 4 rôles, chaque rôle ne
/// montre qu'un sous-ensemble.
enum _Filter {
  tous,
  acheteurs,
  cooperatives,
  transporteurs,
  producteurs,
  farmers, // alias coop pour producteurs
}

/// Rôle de l'interlocuteur — pilote la couleur du chip.
enum _InterlocuteurRole { farmer, acheteur, coop, transport }

/// Modèle local pour une conversation mock.
class _MockConv {
  final String avatarUrl;
  final String name;
  final _InterlocuteurRole role;
  final String time;
  final String lastMsg;
  final int unread;

  const _MockConv({
    required this.avatarUrl,
    required this.name,
    required this.role,
    required this.time,
    required this.lastMsg,
    required this.unread,
  });
}

// ─── Mocks par rôle (1:1 avec les anciennes pages spécifiques) ──────────

const List<_MockConv> _kMockConvsProducteur = [
  _MockConv(
    avatarUrl:
        'https://images.unsplash.com/photo-1625246333195-78d9c38ad449'
        '?w=200&h=200&fit=crop&auto=format',
    name: 'COOP-AGRI Lagunes',
    role: _InterlocuteurRole.coop,
    time: '10:15',
    lastMsg: 'Sollicitation envoyée : 500 kg de maïs',
    unread: 1,
  ),
  _MockConv(
    avatarUrl:
        'https://images.unsplash.com/photo-1438761681033-6461ffad8d80'
        '?w=200&h=200&fit=crop&auto=format',
    name: 'Restaurant Le Baoulé',
    role: _InterlocuteurRole.acheteur,
    time: '09:32',
    lastMsg: 'Quand est-ce que je peux passer ?',
    unread: 1,
  ),
  _MockConv(
    avatarUrl:
        'https://images.unsplash.com/photo-1500648767791-00dcc994a43e'
        '?w=200&h=200&fit=crop&auto=format',
    name: 'Marie Yao',
    role: _InterlocuteurRole.acheteur,
    time: 'hier',
    lastMsg: 'Merci, livraison reçue 🙏',
    unread: 0,
  ),
  _MockConv(
    avatarUrl:
        'https://images.unsplash.com/photo-1493612276216-ee3925520721'
        '?w=200&h=200&fit=crop&auto=format',
    name: 'Transporteur Camion Vert',
    role: _InterlocuteurRole.transport,
    time: 'hier',
    lastMsg: 'Mission acceptée, départ 14h',
    unread: 0,
  ),
  _MockConv(
    avatarUrl:
        'https://images.unsplash.com/photo-1531123897727-8f129e1688ce'
        '?w=200&h=200&fit=crop&auto=format',
    name: 'Industries Agricoles SA',
    role: _InterlocuteurRole.acheteur,
    time: 'lun.',
    lastMsg: 'Contrat signé, bonne continuation',
    unread: 0,
  ),
  _MockConv(
    avatarUrl:
        'https://images.unsplash.com/photo-1599566150163-29194dcaad36'
        '?w=200&h=200&fit=crop&auto=format',
    name: 'Hôtel Beau Rivage',
    role: _InterlocuteurRole.acheteur,
    time: 'dim.',
    lastMsg: 'Bonjour, vous avez encore des bananes ?',
    unread: 0,
  ),
  _MockConv(
    avatarUrl:
        'https://images.unsplash.com/photo-1566576721346-d4a3b4eaeb55'
        '?w=200&h=200&fit=crop&auto=format',
    name: 'Transport Express CI',
    role: _InterlocuteurRole.transport,
    time: '11 mai',
    lastMsg: 'Livraison confirmée à Bouaké',
    unread: 0,
  ),
];

const List<_MockConv> _kMockConvsAcheteur = [
  _MockConv(
    avatarUrl:
        'https://images.unsplash.com/photo-1531123897727-8f129e1688ce'
        '?w=200&h=200&fit=crop&auto=format',
    name: 'Yao K.',
    role: _InterlocuteurRole.farmer,
    time: '11:24',
    lastMsg: 'Le maïs sera prêt vendredi',
    unread: 1,
  ),
  _MockConv(
    avatarUrl:
        'https://images.unsplash.com/photo-1625246333195-78d9c38ad449'
        '?w=200&h=200&fit=crop&auto=format',
    name: 'COOP-AGRI Lagunes',
    role: _InterlocuteurRole.coop,
    time: '10:08',
    lastMsg: 'Confirmation commande agrégée Manioc',
    unread: 2,
  ),
  _MockConv(
    avatarUrl:
        'https://images.unsplash.com/photo-1438761681033-6461ffad8d80'
        '?w=200&h=200&fit=crop&auto=format',
    name: 'Aya N.',
    role: _InterlocuteurRole.farmer,
    time: 'hier',
    lastMsg: 'Merci pour ton paiement 🙏',
    unread: 0,
  ),
  _MockConv(
    avatarUrl:
        'https://images.unsplash.com/photo-1493612276216-ee3925520721'
        '?w=200&h=200&fit=crop&auto=format',
    name: 'Transporteur Camion Vert',
    role: _InterlocuteurRole.transport,
    time: 'hier',
    lastMsg: "Livraison aujourd'hui 14h",
    unread: 0,
  ),
  _MockConv(
    avatarUrl:
        'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2'
        '?w=200&h=200&fit=crop&auto=format',
    name: 'Marie Y.',
    role: _InterlocuteurRole.farmer,
    time: '2j',
    lastMsg: "D'accord pour 60 kg de tomate",
    unread: 0,
  ),
  _MockConv(
    avatarUrl:
        'https://images.unsplash.com/photo-1500648767791-00dcc994a43e'
        '?w=200&h=200&fit=crop&auto=format',
    name: 'Kouamé B.',
    role: _InterlocuteurRole.farmer,
    time: '3j',
    lastMsg: 'Photo des ignames envoyée',
    unread: 0,
  ),
  _MockConv(
    avatarUrl:
        'https://images.unsplash.com/photo-1560250097-0b93528c311a'
        '?w=200&h=200&fit=crop&auto=format',
    name: 'COOP Saveurs Bouaké',
    role: _InterlocuteurRole.coop,
    time: '5j',
    lastMsg: 'Bonjour, on a 500 kg pour vous',
    unread: 0,
  ),
];

const List<_MockConv> _kMockConvsCooperative = [
  _MockConv(
    avatarUrl:
        'https://images.unsplash.com/photo-1531123897727-8f129e1688ce'
        '?w=200&h=200&fit=crop&auto=format',
    name: 'Yao Konan',
    role: _InterlocuteurRole.farmer,
    time: '10:24',
    lastMsg: 'OK je passe demain matin pour la livraison',
    unread: 2,
  ),
  _MockConv(
    avatarUrl:
        'https://images.unsplash.com/photo-1559339352-11d035aa65de'
        '?w=200&h=200&fit=crop&auto=format',
    name: 'Restaurant Le Baoulé',
    role: _InterlocuteurRole.acheteur,
    time: '09:15',
    lastMsg: 'Vous avez encore du maïs blanc ?',
    unread: 1,
  ),
  _MockConv(
    avatarUrl:
        'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d'
        '?w=200&h=200&fit=crop&auto=format',
    name: 'Aya Diallo',
    role: _InterlocuteurRole.farmer,
    time: 'hier',
    lastMsg: "Merci pour l'avance",
    unread: 0,
  ),
  _MockConv(
    avatarUrl:
        'https://images.unsplash.com/photo-1566576721346-d4a3b4eaeb55'
        '?w=200&h=200&fit=crop&auto=format',
    name: 'Transporteur Camion Vert',
    role: _InterlocuteurRole.transport,
    time: 'hier',
    lastMsg: 'Mission acceptée, départ 14h',
    unread: 5,
  ),
  _MockConv(
    avatarUrl:
        'https://images.unsplash.com/photo-1500648767791-00dcc994a43e'
        '?w=200&h=200&fit=crop&auto=format',
    name: 'Kouassi Bamba',
    role: _InterlocuteurRole.farmer,
    time: 'lun.',
    lastMsg: 'Bonne récolte cette semaine, merci',
    unread: 0,
  ),
  _MockConv(
    avatarUrl:
        'https://images.unsplash.com/photo-1542385151-efd9000785a0'
        '?w=200&h=200&fit=crop&auto=format',
    name: 'Industries Agricoles SA',
    role: _InterlocuteurRole.acheteur,
    time: 'lun.',
    lastMsg: 'Contrat signé, bonne continuation',
    unread: 0,
  ),
  _MockConv(
    avatarUrl:
        'https://images.unsplash.com/photo-1599566150163-29194dcaad36'
        '?w=200&h=200&fit=crop&auto=format',
    name: 'Moussa Diabaté',
    role: _InterlocuteurRole.farmer,
    time: 'dim.',
    lastMsg: 'Je viens de peser, total 540 kg',
    unread: 0,
  ),
  _MockConv(
    avatarUrl:
        'https://images.unsplash.com/photo-1493612276216-ee3925520721'
        '?w=200&h=200&fit=crop&auto=format',
    name: 'Transport Express CI',
    role: _InterlocuteurRole.transport,
    time: '11 mai',
    lastMsg: 'Livraison confirmée à Bouaké',
    unread: 0,
  ),
];

const List<_MockConv> _kMockConvsTransporteur = [
  _MockConv(
    avatarUrl:
        'https://images.unsplash.com/photo-1531123897727-8f129e1688ce'
        '?w=200&h=200&fit=crop&auto=format',
    name: 'Yao Konan',
    role: _InterlocuteurRole.farmer,
    time: '12:08',
    lastMsg: 'Le colis est prêt, viens à 14h',
    unread: 1,
  ),
  _MockConv(
    avatarUrl:
        'https://images.unsplash.com/photo-1438761681033-6461ffad8d80'
        '?w=200&h=200&fit=crop&auto=format',
    name: 'Restaurant Le Baoulé',
    role: _InterlocuteurRole.acheteur,
    time: '11:34',
    lastMsg: "On t'attend au plus tard à 16h",
    unread: 2,
  ),
  _MockConv(
    avatarUrl:
        'https://images.unsplash.com/photo-1625246333195-78d9c38ad449'
        '?w=200&h=200&fit=crop&auto=format',
    name: 'COOP-AGRI Lagunes',
    role: _InterlocuteurRole.coop,
    time: 'hier',
    lastMsg: 'Nouvelle mission disponible pour toi',
    unread: 0,
  ),
  _MockConv(
    avatarUrl:
        'https://images.unsplash.com/photo-1500648767791-00dcc994a43e'
        '?w=200&h=200&fit=crop&auto=format',
    name: "Aya N'Guessan",
    role: _InterlocuteurRole.farmer,
    time: 'hier',
    lastMsg: 'Merci pour la livraison ⭐',
    unread: 0,
  ),
  _MockConv(
    avatarUrl:
        'https://images.unsplash.com/photo-1488459716781-31db52582fe9'
        '?w=200&h=200&fit=crop&auto=format',
    name: 'Marché Adjamé · Mme Touré',
    role: _InterlocuteurRole.acheteur,
    time: 'mar.',
    lastMsg: 'Livraison reçue, merci beaucoup',
    unread: 0,
  ),
  _MockConv(
    avatarUrl:
        'https://images.unsplash.com/photo-1599566150163-29194dcaad36'
        '?w=200&h=200&fit=crop&auto=format',
    name: 'Brou Kouadio',
    role: _InterlocuteurRole.farmer,
    time: 'lun.',
    lastMsg: 'Je serai au champ à partir de 7h',
    unread: 0,
  ),
  _MockConv(
    avatarUrl:
        'https://images.unsplash.com/photo-1493612276216-ee3925520721'
        '?w=200&h=200&fit=crop&auto=format',
    name: 'COOP Manioc Sud',
    role: _InterlocuteurRole.coop,
    time: '11 mai',
    lastMsg: 'Bonjour, paiement effectué',
    unread: 0,
  ),
];

// ─── Page partagée ──────────────────────────────────────────────────────

/// Page Messages partagée pour les 4 rôles (farmer / buyer / coop / transp.).
///
/// Détecte le rôle du user connecté via [currentUserProvider] et adapte :
/// - le header (variante par rôle ou top-level back pour la coop),
/// - les filtres chips (catégories d'interlocuteurs pertinentes),
/// - la liste des conversations (mocks fallback par rôle).
///
/// Mock-first : aucun endpoint réel branché. Quand `messagingService
/// .listConversations()` sera prêt côté backend (filtre déjà par user_id),
/// on remplacera [_mocksForRole] par un FutureProvider.
class MessagesPage extends ConsumerStatefulWidget {
  const MessagesPage({super.key});

  @override
  ConsumerState<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends ConsumerState<MessagesPage> {
  _Filter _filter = _Filter.tous;
  final TextEditingController _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<_MockConv> get _convs {
    final role = ref.read(currentUserProvider)?.role;
    return _mocksForRole(role);
  }

  List<_MockConv> get _filtered {
    Iterable<_MockConv> list = _convs;
    if (_filter != _Filter.tous) {
      list = list.where((c) => _matchFilter(c.role, _filter));
    }
    final q = _query.trim().toLowerCase();
    if (q.isNotEmpty) {
      list = list.where((c) =>
          c.name.toLowerCase().contains(q) ||
          c.lastMsg.toLowerCase().contains(q));
    }
    return list.toList(growable: false);
  }

  bool _matchFilter(_InterlocuteurRole role, _Filter filter) {
    switch (role) {
      case _InterlocuteurRole.farmer:
        return filter == _Filter.producteurs || filter == _Filter.farmers;
      case _InterlocuteurRole.acheteur:
        return filter == _Filter.acheteurs;
      case _InterlocuteurRole.coop:
        return filter == _Filter.cooperatives;
      case _InterlocuteurRole.transport:
        return filter == _Filter.transporteurs;
    }
  }

  void _ouvrirConv(_MockConv c) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('Conversation avec ${c.name} — à venir'),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  void _openNotifications() {
    final role = ref.read(currentUserProvider)?.role;
    switch (role) {
      case UserRole.transporter:
        context.push(RouteNames.transporteurNotificationsPath);
        break;
      case UserRole.farmer:
        context.push(RouteNames.producteurNotificationsPath);
        break;
      case UserRole.buyer:
        context.push(RouteNames.acheteurNotificationsPath);
        break;
      case UserRole.cooperative:
        context.push(RouteNames.cooperativeNotificationsPath);
        break;
      default:
        break;
    }
  }

  int get _unreadCount =>
      _convs.fold<int>(0, (acc, c) => acc + (c.unread > 0 ? 1 : 0));

  @override
  Widget build(BuildContext context) {
    final role = ref.watch(currentUserProvider)?.role;
    final convs = _filtered;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(role),
            if (role != UserRole.cooperative) _buildPageTitle(role),
            _SearchBar(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _query = v),
              role: role,
            ),
            _FiltersRow(
              current: _filter,
              onSelect: (f) => setState(() => _filter = f),
              role: role,
            ),
            Expanded(
              child: convs.isEmpty
                  ? const _EmptyState()
                  : ListView.builder(
                      padding: _listPadding(role),
                      itemCount: convs.length,
                      itemBuilder: (_, i) => _ConvTile(
                        conv: convs[i],
                        isLast: i == convs.length - 1,
                        onTap: () => _ouvrirConv(convs[i]),
                        role: role,
                      ),
                    ),
            ),
            if (role == UserRole.cooperative) const _BottomNavStatic(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(UserRole? role) {
    switch (role) {
      case UserRole.cooperative:
        // La coop pousse cette page top-level → header back compact
        return const _HeaderTopLevel(title: 'Messages');
      case UserRole.transporter:
        // Transporteur : titre dans la page + cloche notif à droite
        return _HeaderTransporteur(
          unreadNotifications: _unreadCount,
          onNotifications: _openNotifications,
        );
      case UserRole.farmer:
        return HeaderUtilisateur(
          variant: HeaderVariant.producteur,
          unreadNotifications: _unreadCount,
        );
      case UserRole.buyer:
        return const HeaderUtilisateur(
          variant: HeaderVariant.acheteur,
          cartCount: 3,
        );
      default:
        return HeaderUtilisateur(
          variant: _fallbackVariantForRole(role),
          unreadNotifications: _unreadCount,
        );
    }
  }

  Widget _buildPageTitle(UserRole? role) {
    final isAcheteur = role == UserRole.buyer;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        isAcheteur ? 20 : AppDimens.pagePaddingH,
        AppDimens.space8,
        isAcheteur ? 20 : AppDimens.pagePaddingH,
        isAcheteur ? AppDimens.space8 : AppDimens.space12,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Messages',
              style: isAcheteur
                  ? AppTextStyles.headlineSmall.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    )
                  : AppTextStyles.displayLarge.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                      letterSpacing: -0.3,
                    ),
            ),
          ),
        ],
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
}

// ─── Mocks fallback par rôle ────────────────────────────────────────────

List<_MockConv> _mocksForRole(UserRole? role) {
  switch (role) {
    case UserRole.farmer:
      return _kMockConvsProducteur;
    case UserRole.buyer:
      return _kMockConvsAcheteur;
    case UserRole.cooperative:
      return _kMockConvsCooperative;
    case UserRole.transporter:
      return _kMockConvsTransporteur;
    default:
      return const [];
  }
}

HeaderVariant _fallbackVariantForRole(UserRole? role) {
  switch (role) {
    case UserRole.farmer:
      return HeaderVariant.producteur;
    case UserRole.buyer:
      return HeaderVariant.acheteur;
    case UserRole.cooperative:
      return HeaderVariant.cooperative;
    case UserRole.transporter:
      return HeaderVariant.transporteur;
    default:
      return HeaderVariant.producteur;
  }
}

// ─── Header top-level (coop) ────────────────────────────────────────────

class _HeaderTopLevel extends StatelessWidget {
  const _HeaderTopLevel({required this.title});

  final String title;

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
              title,
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

// ─── Header transporteur (titre + cloche) ───────────────────────────────

class _HeaderTransporteur extends StatelessWidget {
  const _HeaderTransporteur({
    required this.unreadNotifications,
    required this.onNotifications,
  });

  final int unreadNotifications;
  final VoidCallback onNotifications;

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
          Expanded(
            child: Text(
              'Messages',
              style: AppTextStyles.displayLarge.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                height: 1.2,
                letterSpacing: -0.3,
              ),
            ),
          ),
          InkWell(
            onTap: onNotifications,
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                const SizedBox(
                  width: 40,
                  height: 40,
                  child: Icon(
                    Icons.notifications_none,
                    size: 22,
                    color: AppColors.text,
                  ),
                ),
                if (unreadNotifications > 0)
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      constraints: const BoxConstraints(minWidth: 16),
                      height: 16,
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
                        '$unreadNotifications',
                        style: AppTextStyles.labelSmall.copyWith(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppColors.onPrimary,
                          height: 1,
                        ),
                      ),
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

// ─── Barre de recherche ─────────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  const _SearchBar({
    required this.controller,
    required this.onChanged,
    required this.role,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final UserRole? role;

  @override
  Widget build(BuildContext context) {
    final isAcheteur = role == UserRole.buyer;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        isAcheteur ? 20 : AppDimens.pagePaddingH,
        0,
        isAcheteur ? 20 : AppDimens.pagePaddingH,
        AppDimens.space12,
      ),
      child: Container(
        height: isAcheteur ? 42 : null,
        decoration: BoxDecoration(
          color: AppColors.surfaceSoft,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isAcheteur ? AppColors.borderStrong : AppColors.border,
            width: AppDimens.borderThin,
          ),
        ),
        padding: EdgeInsets.symmetric(horizontal: isAcheteur ? 14 : 12),
        child: Row(
          children: [
            Icon(
              Icons.search,
              size: isAcheteur ? 18 : 16,
              color: isAcheteur ? AppColors.textSubtle : AppColors.textSecondary,
            ),
            SizedBox(width: isAcheteur ? 10 : 8),
            Expanded(
              child: TextField(
                controller: controller,
                onChanged: onChanged,
                style: AppTextStyles.bodySmall.copyWith(
                  fontSize: 13,
                  color: AppColors.text,
                ),
                decoration: InputDecoration(
                  isCollapsed: true,
                  contentPadding: EdgeInsets.symmetric(
                    vertical: isAcheteur ? 12 : 10,
                  ),
                  border: InputBorder.none,
                  hintText: isAcheteur
                      ? 'Rechercher une conversation…'
                      : 'Rechercher une conversation',
                  hintStyle: AppTextStyles.hint.copyWith(
                    fontSize: 13,
                    color: AppColors.textSubtle,
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

// ─── Filtres ────────────────────────────────────────────────────────────

class _FiltersRow extends StatelessWidget {
  const _FiltersRow({
    required this.current,
    required this.onSelect,
    required this.role,
  });

  final _Filter current;
  final ValueChanged<_Filter> onSelect;
  final UserRole? role;

  List<(_Filter, String)> get _items {
    switch (role) {
      case UserRole.farmer:
        return const [
          (_Filter.tous, 'Tous'),
          (_Filter.acheteurs, 'Acheteurs'),
          (_Filter.cooperatives, 'Coopératives'),
          (_Filter.transporteurs, 'Transporteurs'),
        ];
      case UserRole.buyer:
        return const [
          (_Filter.tous, 'Tous'),
          (_Filter.producteurs, 'Producteurs'),
          (_Filter.cooperatives, 'Coopératives'),
          (_Filter.transporteurs, 'Transporteurs'),
        ];
      case UserRole.cooperative:
        return const [
          (_Filter.tous, 'Tous'),
          (_Filter.farmers, 'Farmers'),
          (_Filter.acheteurs, 'Acheteurs'),
          (_Filter.transporteurs, 'Transporteurs'),
        ];
      case UserRole.transporter:
        return const [
          (_Filter.tous, 'Tous'),
          (_Filter.producteurs, 'Producteurs'),
          (_Filter.acheteurs, 'Acheteurs'),
          (_Filter.cooperatives, 'Coopératives'),
        ];
      default:
        return const [(_Filter.tous, 'Tous')];
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAcheteur = role == UserRole.buyer;
    final items = _items;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        isAcheteur ? 20 : AppDimens.pagePaddingH,
        0,
        isAcheteur ? 20 : AppDimens.pagePaddingH,
        AppDimens.space12,
      ),
      child: SizedBox(
        height: isAcheteur ? 30 : 28,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: items.length,
          separatorBuilder: (_, _) => const SizedBox(width: 8),
          itemBuilder: (_, i) {
            final (value, label) = items[i];
            final active = value == current;
            return InkWell(
              onTap: () => onSelect(value),
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: isAcheteur ? 7 : 6,
                ),
                decoration: BoxDecoration(
                  color: active ? AppColors.primary : AppColors.background,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: active ? AppColors.primary : AppColors.border,
                    width: AppDimens.borderThin,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  label,
                  style: AppTextStyles.labelSmall.copyWith(
                    fontSize: isAcheteur ? 11 : 12,
                    fontWeight: FontWeight.w600,
                    color: active
                        ? AppColors.onPrimary
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ─── Conv tile (rendu différent selon rôle) ─────────────────────────────

class _ConvTile extends StatelessWidget {
  const _ConvTile({
    required this.conv,
    required this.isLast,
    required this.onTap,
    required this.role,
  });

  final _MockConv conv;
  final bool isLast;
  final VoidCallback onTap;
  final UserRole? role;

  @override
  Widget build(BuildContext context) {
    switch (role) {
      case UserRole.buyer:
        return _ConvTileAcheteur(conv: conv, isLast: isLast, onTap: onTap);
      case UserRole.cooperative:
        return _ConvTileCooperative(
          conv: conv,
          isLast: isLast,
          onTap: onTap,
        );
      case UserRole.transporter:
        return _ConvTileWithAvatarChip(
          conv: conv,
          isLast: isLast,
          onTap: onTap,
          chipBuilder: _ChipRoleTransporteur.new,
        );
      case UserRole.farmer:
      default:
        return _ConvTileWithAvatarChip(
          conv: conv,
          isLast: isLast,
          onTap: onTap,
          chipBuilder: _ChipRoleProducteur.new,
        );
    }
  }
}

/// Tile producteur/transporteur (chip rôle BAS-DROITE de l'avatar).
class _ConvTileWithAvatarChip extends StatelessWidget {
  const _ConvTileWithAvatarChip({
    required this.conv,
    required this.isLast,
    required this.onTap,
    required this.chipBuilder,
  });

  final _MockConv conv;
  final bool isLast;
  final VoidCallback onTap;
  final Widget Function({Key? key, required _InterlocuteurRole role})
      chipBuilder;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isLast ? Colors.transparent : AppColors.border,
              width: AppDimens.borderThin,
            ),
          ),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 48,
              height: 48,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  _Avatar(conv: conv),
                  Positioned(
                    right: -4,
                    bottom: -4,
                    child: chipBuilder(role: conv.role),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ConvBody(conv: conv),
            ),
          ],
        ),
      ),
    );
  }
}

/// Tile coop (avatar sans chip, badge à droite de la dernière ligne).
class _ConvTileCooperative extends StatelessWidget {
  const _ConvTileCooperative({
    required this.conv,
    required this.isLast,
    required this.onTap,
  });

  final _MockConv conv;
  final bool isLast;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isLast ? Colors.transparent : AppColors.border,
              width: AppDimens.borderThin,
            ),
          ),
        ),
        child: Row(
          children: [
            _Avatar(conv: conv),
            const SizedBox(width: 12),
            Expanded(
              child: _ConvBody(conv: conv),
            ),
          ],
        ),
      ),
    );
  }
}

/// Tile acheteur (chip rôle À CÔTÉ du nom, badge en colonne droite).
class _ConvTileAcheteur extends StatelessWidget {
  const _ConvTileAcheteur({
    required this.conv,
    required this.isLast,
    required this.onTap,
  });

  final _MockConv conv;
  final bool isLast;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isLast ? Colors.transparent : AppColors.border,
              width: AppDimens.borderThin,
            ),
          ),
        ),
        child: Row(
          children: [
            _Avatar(conv: conv),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          conv.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.text,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      _ChipRoleAcheteur(role: conv.role),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    conv.lastMsg,
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  conv.time,
                  style: AppTextStyles.labelSmall.copyWith(
                    fontSize: 11,
                    color: AppColors.textSubtle,
                  ),
                ),
                if (conv.unread > 0) ...[
                  const SizedBox(height: 5),
                  Container(
                    constraints: const BoxConstraints(minWidth: 18),
                    height: 18,
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(9),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${conv.unread}',
                      style: AppTextStyles.labelSmall.copyWith(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onPrimary,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Avatar + corps commun ──────────────────────────────────────────────

class _Avatar extends StatelessWidget {
  const _Avatar({required this.conv});

  final _MockConv conv;

  @override
  Widget build(BuildContext context) {
    return Container(
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
        imageUrl: conv.avatarUrl,
        fit: BoxFit.cover,
        placeholder: (_, _) => const ColoredBox(color: _kPrimarySoft),
        errorWidget: (_, _, _) => Center(
          child: Text(
            _initiales(conv.name),
            style: AppTextStyles.labelSmall.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ),
      ),
    );
  }
}

class _ConvBody extends StatelessWidget {
  const _ConvBody({required this.conv});

  final _MockConv conv;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                conv.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.text,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              conv.time,
              style: AppTextStyles.labelSmall.copyWith(
                fontSize: 11,
                color: AppColors.textSubtle,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Row(
          children: [
            Expanded(
              child: Text(
                conv.lastMsg,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodySmall.copyWith(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            if (conv.unread > 0) ...[
              const SizedBox(width: 8),
              Container(
                constraints: const BoxConstraints(minWidth: 20),
                height: 20,
                padding: const EdgeInsets.symmetric(horizontal: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Text(
                  '${conv.unread}',
                  style: AppTextStyles.labelSmall.copyWith(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onPrimary,
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

// ─── Chip rôle — variantes par rôle viewer ──────────────────────────────

/// Chip rôle du producteur (sous avatar).
class _ChipRoleProducteur extends StatelessWidget {
  const _ChipRoleProducteur({super.key, required this.role});

  final _InterlocuteurRole role;

  @override
  Widget build(BuildContext context) {
    final (label, bg, fg) = switch (role) {
      _InterlocuteurRole.coop => ('Coop', _kPrimarySoft, AppColors.primary),
      _InterlocuteurRole.acheteur =>
        ('Acheteur', _kChipAcheteurBg, _kChipAcheteurFg),
      _InterlocuteurRole.transport =>
        ('Transp.', _kChipTransportBg, _kChipTransportFg),
      _InterlocuteurRole.farmer =>
        ('Farmer', _kPrimarySoft, AppColors.primary),
    };
    return _ChipBadge(label: label, bg: bg, fg: fg);
  }
}

/// Chip rôle du transporteur (sous avatar).
class _ChipRoleTransporteur extends StatelessWidget {
  const _ChipRoleTransporteur({super.key, required this.role});

  final _InterlocuteurRole role;

  @override
  Widget build(BuildContext context) {
    final (label, bg, fg) = switch (role) {
      _InterlocuteurRole.farmer =>
        ('Farmer', _kPrimarySoft, AppColors.primary),
      _InterlocuteurRole.coop =>
        ('Coop', _kChipCoopBgTransp, _kChipCoopFgTransp),
      _InterlocuteurRole.acheteur =>
        ('Acheteur', _kChipAcheteurBgTransp, _kChipAcheteurFgTransp),
      _InterlocuteurRole.transport =>
        ('Transp.', _kChipTransportBg, _kChipTransportFg),
    };
    return _ChipBadge(label: label, bg: bg, fg: fg);
  }
}

class _ChipBadge extends StatelessWidget {
  const _ChipBadge({required this.label, required this.bg, required this.fg});

  final String label;
  final Color bg;
  final Color fg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.background, width: 1.5),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(
          fontSize: 9,
          fontWeight: FontWeight.w600,
          color: fg,
          height: 1,
        ),
      ),
    );
  }
}

/// Chip rôle acheteur (À CÔTÉ du nom, pas sous l'avatar).
class _ChipRoleAcheteur extends StatelessWidget {
  const _ChipRoleAcheteur({required this.role});

  final _InterlocuteurRole role;

  @override
  Widget build(BuildContext context) {
    final (label, bg, fg) = switch (role) {
      _InterlocuteurRole.farmer =>
        ('Farmer', _kPrimarySoft, AppColors.primary),
      _InterlocuteurRole.coop =>
        ('Coop', _kChipCoopBgAcheteur, _kChipCoopFgAcheteur),
      _InterlocuteurRole.transport =>
        ('Transport', _kChipTransBgAcheteur, _kChipTransFgAcheteur),
      _InterlocuteurRole.acheteur =>
        ('Acheteur', _kChipAcheteurBg, _kChipAcheteurFg),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(
          fontSize: 9,
          fontWeight: FontWeight.w600,
          color: fg,
          height: 1.2,
        ),
      ),
    );
  }
}

// ─── Bottom-nav statique (coop) ─────────────────────────────────────────

class _BottomNavStatic extends StatelessWidget {
  const _BottomNavStatic();

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
          _NavItem(icon: Icons.home, label: 'Accueil', active: true),
          _NavItem(
            icon: Icons.groups_outlined,
            label: 'Membres',
            active: false,
          ),
          SizedBox(width: 56 + 8),
          _NavItem(
            icon: Icons.inventory_2_outlined,
            label: 'Stock',
            active: false,
          ),
          _NavItem(
            icon: Icons.storefront_outlined,
            label: 'Marché',
            active: false,
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.active,
  });

  final IconData icon;
  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.primary : AppColors.textSecondary;
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 22, color: color),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              fontSize: 11,
              fontWeight: active ? FontWeight.w600 : FontWeight.w500,
              color: color,
            ),
          ),
        ],
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
              Icons.chat_bubble_outline,
              size: 40,
              color: AppColors.textSubtle.withValues(alpha: 0.9),
            ),
            const SizedBox(height: AppDimens.space12),
            Text(
              'Aucune conversation',
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
