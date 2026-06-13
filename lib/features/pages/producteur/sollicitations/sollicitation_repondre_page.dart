import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../api_client/api_exception.dart';
import '../../../../services/providers.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../widgets/communs/entete_page_standard.dart';
import '../../../widgets/communs/snackbars.dart';
import '../../../widgets/producteur/sollicitations/sollicitation_date_field.dart';
import '../../../widgets/producteur/sollicitations/sollicitation_detail.dart';
import '../../../widgets/producteur/sollicitations/sollicitation_field_label.dart';
import '../../../widgets/producteur/sollicitations/sollicitation_input_unit.dart';
import '../../../widgets/producteur/sollicitations/sollicitation_note_field.dart';
import '../../../widgets/producteur/sollicitations/sollicitation_quand.dart';
import '../../../widgets/producteur/sollicitations/sollicitation_recap_card.dart';
import '../../../widgets/producteur/sollicitations/sollicitation_recap_card_error.dart';
import '../../../widgets/producteur/sollicitations/sollicitation_recap_card_loading.dart';
import '../../../widgets/producteur/sollicitations/sollicitation_section_title.dart';
import '../../../widgets/producteur/sollicitations/sollicitation_sticky_actions.dart';
import '../../../widgets/producteur/sollicitations/sollicitation_when_row.dart';

/// Charge le détail enrichi de la sollicitation depuis le backend.
final _solDetailProvider = FutureProvider.autoDispose
    .family<SollicitationDetail, String>((ref, id) async {
      final raw = await ref
          .read(cooperativesServiceProvider)
          .getSollicitation(id);

      final coop = raw['cooperative'] as Map<String, dynamic>?;
      final annonce = raw['annonce'] as Map<String, dynamic>?;
      final produit =
          (annonce?['produits_agricoles'] as Map<String, dynamic>?) ??
          (annonce?['produit'] as Map<String, dynamic>?);
      final medias = annonce?['medias'] as List<dynamic>?;
      final firstPhoto = medias
          ?.whereType<Map>()
          .map((m) => (m['url'] ?? m['thumbnail_url'])?.toString())
          .firstWhere((u) => u != null && u.isNotEmpty, orElse: () => null);

      double? toDouble(dynamic v) {
        if (v is num) return v.toDouble();
        if (v is String) return double.tryParse(v);
        return null;
      }

      DateTime? toDate(dynamic v) {
        if (v is String) return DateTime.tryParse(v);
        return null;
      }

      return SollicitationDetail(
        coopNom: (coop?['nom'] as String?)?.trim().isNotEmpty == true
            ? coop!['nom'] as String
            : 'Ma coopérative',
        coopLogoUrl: coop?['logo_url'] as String?,
        produitNom: (produit?['nom'] as String?) ?? 'Produit',
        produitThumb: firstPhoto,
        quantiteKg:
            toDouble(raw['quantite_cible_kg']) ??
            toDouble(annonce?['quantite_kg']),
        prixMinKg:
            toDouble(annonce?['prix_max_kg']) ??
            toDouble(annonce?['prix_par_kg']),
        expiresAt: toDate(raw['expires_at']),
        message: raw['message'] as String?,
      );
    });

/// Page de réponse à une sollicitation reçue de la coopérative.
class SollicitationRepondrePage extends ConsumerStatefulWidget {
  const SollicitationRepondrePage({required this.sollicitationId, super.key});

  final String sollicitationId;

  @override
  ConsumerState<SollicitationRepondrePage> createState() =>
      _SollicitationRepondrePageState();
}

class _SollicitationRepondrePageState
    extends ConsumerState<SollicitationRepondrePage> {
  SollicitationQuand _quand = SollicitationQuand.maintenant;
  DateTime? _dateEstimee;

  final _qteCtrl = TextEditingController(text: '120');
  final _prixCtrl = TextEditingController(text: '800');
  final _noteCtrl = TextEditingController();

  bool _isSubmitting = false;

  @override
  void dispose() {
    _qteCtrl.dispose();
    _prixCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  double? get _qteKg {
    final raw = _qteCtrl.text.trim().replaceAll(',', '.');
    return double.tryParse(raw);
  }

  Future<void> _choisirDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateEstimee ?? now.add(const Duration(days: 7)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null && mounted) {
      setState(() => _dateEstimee = picked);
    }
  }

  Future<void> _envoyer({required bool accept}) async {
    if (_isSubmitting) return;
    if (accept) {
      final q = _qteKg;
      if (q == null || q <= 0) {
        Snackbars.showErreur(context, 'Indique une quantité valide.');
        return;
      }
    }
    setState(() => _isSubmitting = true);
    try {
      await ref
          .read(cooperativesServiceProvider)
          .respondSollicitation(
            id: widget.sollicitationId,
            accept: accept,
            quantiteKg: accept ? _qteKg : null,
          );
      if (!mounted) return;
      Snackbars.showSucces(
        context,
        accept ? 'Réponse envoyée à la coop.' : 'Sollicitation refusée.',
      );
      Navigator.of(context).pop(true);
    } on ApiException catch (e) {
      if (!mounted) return;
      Snackbars.showErreur(context, e.message);
    } catch (e) {
      if (!mounted) return;
      Snackbars.showErreurInattendue(context, e);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final detailAsync = ref.watch(_solDetailProvider(widget.sollicitationId));
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const EntetePageStandard(titre: 'Répondre à la sollicitation'),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                children: [
                  AppDimens.vGap8,
                  detailAsync.when(
                    loading: () => const SollicitationRecapCardLoading(),
                    error: (_, _) => const SollicitationRecapCardError(),
                    data: (d) => SollicitationRecapCard(detail: d),
                  ),
                  AppDimens.vGap24,
                  const SollicitationSectionTitle(
                    title: 'Quand peux-tu fournir ?',
                  ),
                  AppDimens.vGap12,
                  SollicitationWhenRow(
                    selected: _quand,
                    onChange: (q) {
                      setState(() {
                        _quand = q;
                        if (q == SollicitationQuand.maintenant) {
                          _dateEstimee = null;
                        }
                      });
                    },
                  ),
                  if (_quand == SollicitationQuand.plusTard) ...[
                    AppDimens.vGap16,
                    SollicitationDateField(
                      date: _dateEstimee,
                      onTap: _choisirDate,
                      enabled: !_isSubmitting,
                    ),
                  ],
                  AppDimens.vGap24,
                  const SollicitationSectionTitle(title: 'Ma contribution'),
                  AppDimens.vGap12,
                  const SollicitationFieldLabel(
                    label: 'Quantité que je peux fournir',
                  ),
                  AppDimens.vGap8,
                  SollicitationInputUnit(
                    controller: _qteCtrl,
                    unit: 'kg',
                    enabled: !_isSubmitting,
                    hint: '0',
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: false,
                    ),
                    formatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                    ],
                  ),
                  AppDimens.vGap16,
                  const SollicitationFieldLabel(label: 'Prix proposé'),
                  AppDimens.vGap8,
                  SollicitationInputUnit(
                    controller: _prixCtrl,
                    unit: 'F / kg',
                    enabled: !_isSubmitting,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: false,
                    ),
                    formatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                    ],
                  ),
                  AppDimens.vGap16,
                  const SollicitationFieldLabel(
                    label: 'Note pour la coop (optionnel)',
                  ),
                  AppDimens.vGap8,
                  SollicitationNoteField(
                    controller: _noteCtrl,
                    enabled: !_isSubmitting,
                  ),
                  AppDimens.vGap16,
                ],
              ),
            ),
            SollicitationStickyActions(
              isSubmitting: _isSubmitting,
              onRefuser: () => _envoyer(accept: false),
              onEnvoyer: () => _envoyer(accept: true),
            ),
          ],
        ),
      ),
    );
  }
}
