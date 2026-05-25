import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../api_client/api_exception.dart';
import '../../../models/conversation.dart';
import '../../../models/enums.dart';
import '../../../routing/route_names.dart';
import '../../../services/providers.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_dimens.dart';
import '../../../theme/app_text_styles.dart';
import '../../state/auth_state.dart';
import '../../widgets/communs/header_utilisateur.dart';
import '../../widgets/messages/barre_recherche.dart';
import '../../widgets/messages/entete_messages.dart';
import '../../widgets/messages/etat_erreur_messages.dart';
import '../../widgets/messages/etat_vide_messages.dart';
import '../../widgets/messages/filtres_messages.dart';
import '../../widgets/messages/messages_helpers.dart';
import '../../widgets/messages/messages_types.dart';
import '../../widgets/messages/tuile_conversation.dart';

// ─── Provider liste conversations ───────────────────────────────────────

/// Source de vérité : `GET /messaging/conversations` paginé (50 dernières
/// suffisent pour le scroll). Pull-to-refresh invalide ce provider.
final _conversationsProvider =
    FutureProvider.autoDispose<List<Conversation>>((ref) async {
  final svc = ref.watch(messagingServiceProvider);
  final page = await svc.listConversations(limit: 50);
  return page.data;
});

// ─── Page partagée ──────────────────────────────────────────────────────

/// Page Messages partagée pour les 4 rôles (farmer / buyer / coop / transp.).
///
/// Détecte le rôle du user connecté via [currentUserProvider] et adapte :
/// - le header (variante par rôle ou top-level back pour la coop),
/// - les filtres chips (catégories d'interlocuteurs pertinentes),
/// - la liste des conversations (réelle via `messagingService.listConversations()`).
///
/// Tap sur une conv : route vers la page chat détail si dispo, sinon
/// snackbar. La création de page chat dédiée est tracée hors scope ici.
class MessagesPage extends ConsumerStatefulWidget {
  const MessagesPage({super.key});

  @override
  ConsumerState<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends ConsumerState<MessagesPage> {
  FiltreMessages _filter = FiltreMessages.tous;
  final TextEditingController _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  /// Filtrage côté client : on combine `_filter` (rôle interlocuteur)
  /// + recherche texte (nom ou dernier message). Le backend ne propose
  /// pas encore `?role=` ni `?q=` sur la liste — quand ça arrivera, on
  /// passera le filtre au provider plutôt que de filtrer ici.
  List<Conversation> _applyFilters(
    List<Conversation> all,
    String? currentUserId,
  ) {
    Iterable<Conversation> list = all;
    if (_filter != FiltreMessages.tous) {
      list = list.where((c) {
        final role = otherRole(c, currentUserId);
        return role != null && _matchFilter(role, _filter);
      });
    }
    final q = _query.trim().toLowerCase();
    if (q.isNotEmpty) {
      list = list.where((c) {
        final name = otherName(c, currentUserId).toLowerCase();
        final last = (c.lastMessage?.content ?? '').toLowerCase();
        return name.contains(q) || last.contains(q);
      });
    }
    return list.toList(growable: false);
  }

  bool _matchFilter(RoleInterlocuteur role, FiltreMessages filter) {
    switch (role) {
      case RoleInterlocuteur.farmer:
        return filter == FiltreMessages.producteurs ||
            filter == FiltreMessages.farmers;
      case RoleInterlocuteur.acheteur:
        return filter == FiltreMessages.acheteurs;
      case RoleInterlocuteur.coop:
        return filter == FiltreMessages.cooperatives;
      case RoleInterlocuteur.transport:
        return filter == FiltreMessages.transporteurs;
    }
  }

  void _ouvrirConv(Conversation conv, String? currentUserId) {
    // Push la page chat détail. Au retour, on invalide le provider liste
    // pour rafraîchir `unreadCount` (markConversationRead côté chat détail
    // a déjà appelé l'API mais le compteur côté liste serait dépassé sinon).
    context.push(RouteNames.chatDetailPathFor(conv.id)).then((_) {
      if (mounted) ref.invalidate(_conversationsProvider);
    });
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

  @override
  Widget build(BuildContext context) {
    final me = ref.watch(currentUserProvider);
    final role = me?.role;
    final myId = me?.id;
    final convsAsync = ref.watch(_conversationsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(role, convsAsync.valueOrNull),
            if (role != UserRole.cooperative) _buildPageTitle(role),
            BarreRechercheMessages(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _query = v),
              role: role,
            ),
            FiltresMessages(
              current: _filter,
              onSelect: (f) => setState(() => _filter = f),
              role: role,
            ),
            Expanded(
              child: convsAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                error: (err, _) => EtatErreurMessages(
                  message: err is ApiException
                      ? err.message
                      : 'Erreur de chargement',
                  onRetry: () => ref.invalidate(_conversationsProvider),
                ),
                data: (all) {
                  final convs = _applyFilters(all, myId);
                  if (convs.isEmpty) return const EtatVideMessages();
                  return RefreshIndicator(
                    onRefresh: () async {
                      ref.invalidate(_conversationsProvider);
                      await ref.read(_conversationsProvider.future);
                    },
                    child: ListView.builder(
                      padding: _listPadding(role),
                      itemCount: convs.length,
                      itemBuilder: (_, i) => TuileConversation(
                        conv: convs[i],
                        currentUserId: myId,
                        isLast: i == convs.length - 1,
                        onTap: () => _ouvrirConv(convs[i], myId),
                        role: role,
                      ),
                    ),
                  );
                },
              ),
            ),
            // TODO(refacto) : factoriser ce bottom-nav statique avec les
            // autres pages cooperative qui en ont besoin (hors scope ici).
            if (role == UserRole.cooperative) const _BottomNavStatic(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(UserRole? role, List<Conversation>? convs) {
    final unread =
        convs?.fold<int>(0, (acc, c) => acc + (c.unreadCount > 0 ? 1 : 0)) ?? 0;
    switch (role) {
      case UserRole.cooperative:
        // La coop pousse cette page top-level → header back compact
        return const EnteteMessagesTopLevel(title: 'Messages');
      case UserRole.transporter:
        // Transporteur : titre dans la page + cloche notif à droite
        return EnteteMessagesTransporteur(
          unreadNotifications: unread,
          onNotifications: _openNotifications,
        );
      case UserRole.farmer:
        return HeaderUtilisateur(
          variant: HeaderVariant.producteur,
          unreadNotifications: unread,
        );
      case UserRole.buyer:
        return const HeaderUtilisateur(
          variant: HeaderVariant.acheteur,
          cartCount: 3,
        );
      default:
        return HeaderUtilisateur(
          variant: _fallbackVariantForRole(role),
          unreadNotifications: unread,
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

// ─── Bottom-nav statique (coop) ─────────────────────────────────────────
// TODO(refacto) : extraire vers widgets/cooperative/barre_navigation_*.dart
// quand le pattern sera partagé avec d'autres pages coop.

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
