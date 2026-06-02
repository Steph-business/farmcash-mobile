import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../api_client/api_exception.dart';
import '../../../../models/annonce_vente.dart';
import '../../../../services/providers.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';
import '../../communs/snackbars.dart';

/// Bottom sheet de saisie d'une candidature de négociation sur une
/// annonce de vente (acheteur → producteur).
///
/// L'acheteur propose un prix et une quantité différents de l'annonce
/// publique → ça crée une `candidatures_vente` côté backend. Le
/// producteur peut accepter, refuser ou contre-proposer. L'annonce
/// publique GARDE son prix initial — la négociation est privée
/// (visible uniquement par les 2 parties).
class SheetNegocierAnnonce extends ConsumerStatefulWidget {
  const SheetNegocierAnnonce({super.key, required this.annonce});

  final AnnonceVente annonce;

  @override
  ConsumerState<SheetNegocierAnnonce> createState() =>
      _SheetNegocierAnnonceState();
}

class _SheetNegocierAnnonceState
    extends ConsumerState<SheetNegocierAnnonce> {
  final _prixCtrl = TextEditingController();
  final _qteCtrl = TextEditingController();
  final _messageCtrl = TextEditingController();
  final _nf = NumberFormat('#,##0', 'fr_FR');
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    // Pré-remplit avec le prix et la quantité de l'annonce —
    // l'utilisateur ajuste ensuite à sa convenance.
    _prixCtrl.text = widget.annonce.prixParKg.round().toString();
    _qteCtrl.text = widget.annonce.quantiteKg.round().toString();
  }

  @override
  void dispose() {
    _prixCtrl.dispose();
    _qteCtrl.dispose();
    _messageCtrl.dispose();
    super.dispose();
  }

  Future<void> _envoyer() async {
    if (_sending) return;
    final prix = double.tryParse(_prixCtrl.text.trim());
    final qte = double.tryParse(_qteCtrl.text.trim());
    if (prix == null || prix <= 0) {
      Snackbars.showErreur(context, 'Saisis un prix valide.');
      return;
    }
    if (qte == null || qte <= 0) {
      Snackbars.showErreur(context, 'Saisis une quantité valide.');
      return;
    }
    if (qte > widget.annonce.quantiteKg) {
      Snackbars.showErreur(
        context,
        'Quantité demandée > stock dispo (${_nf.format(widget.annonce.quantiteKg.round())} kg).',
      );
      return;
    }
    setState(() => _sending = true);
    try {
      await ref.read(negotiationServiceProvider).createCandidature(
            annonceId: widget.annonce.id,
            quantiteKg: qte,
            prixProposeKg: prix,
            message: _messageCtrl.text.trim().isEmpty
                ? null
                : _messageCtrl.text.trim(),
          );
      if (!mounted) return;
      Navigator.of(context).pop();
      Snackbars.showSucces(
        context,
        'Offre envoyée au vendeur — tu seras notifié dès qu\'il répond.',
      );
    } on ApiException catch (e) {
      if (mounted) Snackbars.showErreur(context, e.message);
    } catch (e) {
      if (mounted) Snackbars.showErreur(context, 'Erreur : $e');
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final montant = (double.tryParse(_qteCtrl.text.trim()) ?? 0) *
        (double.tryParse(_prixCtrl.text.trim()) ?? 0);

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Drag handle visuel
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                'Négocier avec le vendeur',
                textAlign: TextAlign.center,
                style: AppTextStyles.titleSmall.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Prix affiché : ${_nf.format(widget.annonce.prixParKg.round())} F/kg · '
                'Stock : ${_nf.format(widget.annonce.quantiteKg.round())} kg',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySmall.copyWith(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              _ChampLabel(label: 'Ton prix proposé (F/kg)'),
              const SizedBox(height: 4),
              TextField(
                controller: _prixCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (_) => setState(() {}),
                decoration: _inputDeco('Ex: 650'),
              ),
              const SizedBox(height: 12),
              _ChampLabel(label: 'Quantité voulue (kg)'),
              const SizedBox(height: 4),
              TextField(
                controller: _qteCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (_) => setState(() {}),
                decoration: _inputDeco('Ex: 200'),
              ),
              const SizedBox(height: 12),
              _ChampLabel(label: 'Message au vendeur (optionnel)'),
              const SizedBox(height: 4),
              TextField(
                controller: _messageCtrl,
                maxLines: 3,
                minLines: 2,
                decoration: _inputDeco(
                  'Ex: Bonjour, je peux prendre tout votre stock à ce prix…',
                ),
              ),
              const SizedBox(height: 16),
              // Aperçu du montant total à ce prix négocié.
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Montant total si accepté',
                        style: AppTextStyles.bodySmall.copyWith(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.text,
                        ),
                      ),
                    ),
                    Text(
                      '${_nf.format(montant.round())} F',
                      style: AppTextStyles.titleSmall.copyWith(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _sending ? null : _envoyer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  textStyle: AppTextStyles.button.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                child: _sending
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Envoyer mon offre'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDeco(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: false,
      fillColor: Colors.transparent,
      isDense: true,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
          color: AppColors.primary,
          width: 1.5,
        ),
      ),
      hintStyle: AppTextStyles.hint.copyWith(
        fontSize: 13,
        color: AppColors.textSubtle,
      ),
    );
  }
}

class _ChampLabel extends StatelessWidget {
  const _ChampLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: AppTextStyles.labelMedium.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: AppColors.text,
      ),
    );
  }
}
