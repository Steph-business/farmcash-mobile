import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';

const BorderRadius _kBrInput = BorderRadius.all(Radius.circular(10));

/// Bottom sheet de promotion d'un farmer géré en farmer autonome.
///
/// La coop saisit le téléphone du membre (préfixe +225 figé) et envoie ;
/// le backend déclenche alors un OTP de vérification côté farmer et
/// bascule `managed_by_coop_id` → `null`.
///
/// Renvoie le téléphone E.164 normalisé via `Navigator.pop(phone)` quand
/// l'utilisateur valide, ou `null` s'il annule.
class FeuillePromouvoirMembre extends StatefulWidget {
  const FeuillePromouvoirMembre({super.key, this.nomMembre});

  /// Nom du membre à promouvoir (affiché dans l'entête de la feuille).
  final String? nomMembre;

  @override
  State<FeuillePromouvoirMembre> createState() =>
      _FeuillePromouvoirMembreState();
}

class _FeuillePromouvoirMembreState extends State<FeuillePromouvoirMembre> {
  final _telCtrl = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _telCtrl.dispose();
    super.dispose();
  }

  /// Normalise vers E.164 : "07 12 34 56 78" → "+22507123456 78"
  /// (mêmes règles que `inviter_farmer_page.dart`).
  String _normalize(String raw) {
    var phone = raw.replaceAll(RegExp(r'\s+'), '');
    if (!phone.startsWith('+')) {
      phone = phone.startsWith('00')
          ? '+${phone.substring(2)}'
          : (phone.startsWith('225') ? '+$phone' : '+225$phone');
    }
    return phone;
  }

  void _valider() {
    final raw = _telCtrl.text.trim();
    if (raw.isEmpty) return;
    setState(() => _busy = true);
    Navigator.of(context).pop(_normalize(raw));
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: viewInsets),
      child: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(
            AppDimens.pagePaddingH,
            AppDimens.space12,
            AppDimens.pagePaddingH,
            AppDimens.space16,
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
                widget.nomMembre == null
                    ? 'Promouvoir le membre'
                    : 'Promouvoir ${widget.nomMembre}',
                style: AppTextStyles.titleSmall.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              AppDimens.vGap8,
              Text(
                "Saisis le téléphone du membre. Un OTP lui sera envoyé "
                "pour activer son compte.",
                style: AppTextStyles.bodySmall.copyWith(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  height: 1.35,
                ),
              ),
              AppDimens.vGap16,
              Container(
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: _kBrInput,
                  border: Border.all(
                    color: AppColors.borderStrong,
                    width: AppDimens.borderThin,
                  ),
                ),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 12),
                      child: Text(
                        '+225',
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.text,
                        ),
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 28,
                      color: AppColors.border,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _telCtrl,
                        enabled: !_busy,
                        autofocus: true,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9 ]')),
                        ],
                        style: AppTextStyles.bodyMedium.copyWith(fontSize: 14),
                        decoration: InputDecoration(
                          hintText: '07 12 34 56 78',
                          hintStyle: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSubtle,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 0),
                        ),
                        onSubmitted: (_) => _valider(),
                      ),
                    ),
                  ],
                ),
              ),
              AppDimens.vGap16,
              SizedBox(
                width: double.infinity,
                height: AppDimens.buttonHeight,
                child: Material(
                  color: AppColors.primary,
                  borderRadius: AppDimens.brButton,
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: _busy ? null : _valider,
                    child: Center(
                      child: _busy
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              'Promouvoir',
                              style: AppTextStyles.button.copyWith(
                                color: AppColors.onPrimary,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
