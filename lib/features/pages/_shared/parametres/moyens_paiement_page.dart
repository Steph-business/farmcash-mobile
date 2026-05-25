import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../widgets/communs/parametres/carte_moyen_paiement.dart';
import '../../../widgets/communs/profil_settings/entete_profil_settings.dart';
import '../../../widgets/communs/snackbars.dart';

/// Modèle d'un moyen de paiement (mock V1 — pas encore persisté backend).
class _MoyenPaiement {
  _MoyenPaiement({
    required this.id,
    required this.icone,
    required this.nom,
    required this.sousLigne,
    required this.parDefaut,
  });

  final String id;
  final IconData icone;
  final String nom;
  final String sousLigne;
  bool parDefaut;
}

/// État mock local pour V1. À remplacer par un service backend dédié dès
/// qu'il sera disponible (`GET /payment-methods`, `POST`, `DELETE`).
final _moyensPaiementProvider =
    StateProvider<List<_MoyenPaiement>>((ref) => [
          _MoyenPaiement(
            id: 'om-1',
            icone: Icons.phone_android,
            nom: 'Orange Money',
            sousLigne: '07 ** ** ** 12 · ajouté le 14 mars 2026',
            parDefaut: true,
          ),
          _MoyenPaiement(
            id: 'mtn-1',
            icone: Icons.phone_android,
            nom: 'MTN Money',
            sousLigne: '05 ** ** ** 89 · ajouté le 02 avril 2026',
            parDefaut: false,
          ),
        ]);

/// Page Moyens de paiement partagée (acheteur, producteur, transporteur).
///
/// Permet d'ajouter, supprimer et définir un moyen de paiement par défaut.
/// V1 : mock local + snackbars de feedback. Le bouton "Ajouter" ouvre un
/// bottom sheet de choix de type.
class MoyensPaiementPage extends ConsumerWidget {
  /// Construit la page.
  const MoyensPaiementPage({super.key, required this.fallbackPath});

  /// Chemin de repli si la pile de navigation est vide (deep link).
  final String fallbackPath;

  void _ouvrirAjout(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => _BottomSheetAjouter(
        onChoix: (label) {
          Navigator.of(context).pop();
          Snackbars.showInfo(context, 'Ajout de "$label" — à venir');
        },
      ),
    );
  }

  Future<void> _confirmerSuppression(
    BuildContext context,
    WidgetRef ref,
    _MoyenPaiement m,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Supprimer ${m.nom} ?'),
        content: const Text(
          'Tu pourras le rajouter plus tard. Tes paiements en cours ne '
          'seront pas affectés.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    if (ok != true) return;

    final liste = [...ref.read(_moyensPaiementProvider)];
    liste.removeWhere((x) => x.id == m.id);
    // Si on supprime le défaut, promouvoir le premier restant.
    if (m.parDefaut && liste.isNotEmpty && !liste.any((x) => x.parDefaut)) {
      liste.first.parDefaut = true;
    }
    ref.read(_moyensPaiementProvider.notifier).state = liste;
    if (!context.mounted) return;
    Snackbars.showInfo(context, '${m.nom} supprimé');
  }

  void _definirParDefaut(WidgetRef ref, String id) {
    final liste = [...ref.read(_moyensPaiementProvider)];
    for (final m in liste) {
      m.parDefaut = (m.id == id);
    }
    ref.read(_moyensPaiementProvider.notifier).state = liste;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final moyens = ref.watch(_moyensPaiementProvider);

    return Scaffold(
      backgroundColor: AppColors.surfaceSoft,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            EnteteProfilSettings(
              fallbackPath: fallbackPath,
              titre: 'Moyens de paiement',
            ),
            Expanded(
              child: moyens.isEmpty
                  ? _EmptyState(onAjouter: () => _ouvrirAjout(context, ref))
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(
                        AppDimens.pagePaddingH,
                        AppDimens.space8,
                        AppDimens.pagePaddingH,
                        AppDimens.space24,
                      ),
                      children: [
                        Text(
                          'Ajoute ou gère les moyens utilisés pour tes '
                          'recharges, achats et retraits.',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                            height: 1.5,
                          ),
                        ),
                        AppDimens.vGap16,
                        for (final m in moyens)
                          CarteMoyenPaiement(
                            icone: m.icone,
                            nom: m.nom,
                            sousLigne: m.sousLigne,
                            parDefaut: m.parDefaut,
                            onDefinirParDefaut: () =>
                                _definirParDefaut(ref, m.id),
                            onSupprimer: () =>
                                _confirmerSuppression(context, ref, m),
                          ),
                        AppDimens.vGap8,
                        OutlinedButton.icon(
                          onPressed: () => _ouvrirAjout(context, ref),
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('Ajouter un moyen de paiement'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: BorderSide(
                              color:
                                  AppColors.primary.withValues(alpha: 0.4),
                            ),
                            minimumSize:
                                const Size.fromHeight(AppDimens.buttonHeight),
                            shape: RoundedRectangleBorder(
                              borderRadius: AppDimens.brButton,
                            ),
                            textStyle: AppTextStyles.button.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
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

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAjouter});

  final VoidCallback onAjouter;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppDimens.space24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.credit_card_off_outlined,
            size: 48,
            color: AppColors.textSubtle,
          ),
          AppDimens.vGap16,
          Text(
            'Aucun moyen de paiement',
            style: AppTextStyles.titleMedium.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          AppDimens.vGap8,
          Text(
            'Ajoute un moyen pour effectuer tes paiements et tes retraits.',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          AppDimens.vGap24,
          FilledButton.icon(
            onPressed: onAjouter,
            icon: const Icon(Icons.add),
            label: const Text('Ajouter un moyen'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.onPrimary,
              minimumSize: const Size(220, AppDimens.buttonHeight),
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomSheetAjouter extends StatelessWidget {
  const _BottomSheetAjouter({required this.onChoix});

  final ValueChanged<String> onChoix;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppDimens.pagePaddingH,
          AppDimens.space16,
          AppDimens.pagePaddingH,
          AppDimens.space24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            AppDimens.vGap16,
            Text(
              'Choisir un type',
              style: AppTextStyles.titleMedium.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            AppDimens.vGap16,
            _OptionAjout(
              icone: Icons.phone_android,
              label: 'Orange Money',
              sousTitre: 'Wallet mobile Orange',
              onTap: () => onChoix('Orange Money'),
            ),
            _OptionAjout(
              icone: Icons.phone_android,
              label: 'MTN Money',
              sousTitre: 'Wallet mobile MTN',
              onTap: () => onChoix('MTN Money'),
            ),
            _OptionAjout(
              icone: Icons.phone_android,
              label: 'Moov Money',
              sousTitre: 'Wallet mobile Moov',
              onTap: () => onChoix('Moov Money'),
            ),
            _OptionAjout(
              icone: Icons.credit_card,
              label: 'Carte bancaire',
              sousTitre: 'Visa, Mastercard',
              onTap: () => onChoix('Carte bancaire'),
            ),
            _OptionAjout(
              icone: Icons.account_balance,
              label: 'Virement bancaire',
              sousTitre: 'IBAN ou compte local',
              onTap: () => onChoix('Virement bancaire'),
            ),
          ],
        ),
      ),
    );
  }
}

class _OptionAjout extends StatelessWidget {
  const _OptionAjout({
    required this.icone,
    required this.label,
    required this.sousTitre,
    required this.onTap,
  });

  final IconData icone;
  final String label;
  final String sousTitre;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppDimens.brCard,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.surfaceSoft,
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Icon(icone, size: 18, color: AppColors.text),
            ),
            AppDimens.hGap12,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    sousTitre,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              size: 18,
              color: AppColors.textSubtle,
            ),
          ],
        ),
      ),
    );
  }
}
