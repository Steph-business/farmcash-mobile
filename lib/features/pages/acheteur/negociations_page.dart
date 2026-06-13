import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../theme/app_colors.dart';
import '../../state/badges_state.dart';
import '../../storage/prefs_storage.dart';
import '../../widgets/acheteur/commandes/onglet_negociations.dart';
import '../../widgets/communs/entete_page_standard.dart';

/// Page « Négociations » côté acheteur — autonome, accessible via la
/// tuile dédiée sur l'accueil (`/acheteur/negociations`).
///
/// Au montage :
///   1. On stocke le timestamp courant dans `prefs.negociationsLastSeen`
///      → toutes les propositions actuelles deviennent « vues ».
///   2. On invalide `propositionsRecuesNonTraiteesCountProvider` →
///      le badge sur la tuile accueil retombe à 0 immédiatement.
///   3. Les futures propositions reçues après ce moment seront comptées
///      comme nouvelles tant que l'utilisateur ne revient pas ici.
///
/// Cette logique « last_seen » est gérée côté mobile uniquement (pas
/// d'endpoint backend dédié). Suffisant pour la V1 : pas de sync entre
/// devices mais c'est le pattern Gmail / WhatsApp et l'attente UX
/// est claire (« je rentre → je vois tout → c'est vu »).
class NegociationsAcheteurPage extends ConsumerStatefulWidget {
  const NegociationsAcheteurPage({super.key});

  @override
  ConsumerState<NegociationsAcheteurPage> createState() =>
      _NegociationsAcheteurPageState();
}

class _NegociationsAcheteurPageState
    extends ConsumerState<NegociationsAcheteurPage> {
  @override
  void initState() {
    super.initState();
    // Marque la visite après le 1er frame (sinon on touche aux providers
    // depuis initState ce qui est interdit) + invalide le badge pour
    // qu'il redescende à 0 immédiatement côté UI.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref
          .read(prefsStorageProvider)
          .setNegociationsLastSeen(DateTime.now());
      ref.invalidate(propositionsRecuesNonTraiteesCountProvider);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const EntetePageStandard(titre: 'Négociations'),
            const Expanded(child: OngletNegociations()),
          ],
        ),
      ),
    );
  }
}
