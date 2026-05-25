import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../widgets/communs/snackbars.dart';
import '../../../widgets/communs/wallet/wallet_widgets.dart';

const _kQuickAmounts = [10000, 50000, 100000];

/// Page Retirer Wallet acheteur — montant à retirer, destinataire (OM
/// 07 11 22 33 44), code PIN MoMo (visuel), CTA sticky « Confirmer le
/// retrait ».
///
/// Note service : pas d'endpoint « withdraw » exposé ; à la confirmation on
/// affiche un snackbar puis on pop.
class WalletRetirerAcheteurPage extends ConsumerStatefulWidget {
  const WalletRetirerAcheteurPage({super.key});

  @override
  ConsumerState<WalletRetirerAcheteurPage> createState() =>
      _WalletRetirerAcheteurPageState();
}

class _WalletRetirerAcheteurPageState
    extends ConsumerState<WalletRetirerAcheteurPage> {
  late final TextEditingController _amountCtrl;
  int _selectedChip = 50000;
  bool _toutChipActive = false;
  static const double _kBalance = 245800;

  @override
  void initState() {
    super.initState();
    _amountCtrl = TextEditingController(
      text: NumberFormat('#,##0', 'fr_FR').format(50000),
    );
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  void _pickChip(int amount) {
    setState(() {
      _selectedChip = amount;
      _toutChipActive = false;
      _amountCtrl.text = NumberFormat('#,##0', 'fr_FR').format(amount);
    });
  }

  void _pickAll() {
    setState(() {
      _toutChipActive = true;
      _selectedChip = -1;
      _amountCtrl.text =
          NumberFormat('#,##0', 'fr_FR').format(_kBalance.toInt());
    });
  }

  void _onConfirmer() {
    Snackbars.showInfo(context, 'Demande de retrait envoyée');
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const EnteteWallet(
              titre: 'Retirer mon argent',
              bordureBas: true,
              tailleTitre: 15,
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => FocusScope.of(context).unfocus(),
                child: ListView(
                  padding:
                      const EdgeInsets.fromLTRB(20, AppDimens.space16, 20, 120),
                  children: [
                    const BandeauSoldeCompact(
                      balance: _kBalance,
                      label: 'Solde disponible',
                    ),
                    AppDimens.vGap16,
                    SaisieMontant(controller: _amountCtrl),
                    AppDimens.vGap8,
                    ChipsMontantsRapides(
                      montants: _kQuickAmounts,
                      selectionne: _selectedChip,
                      onChoisir: _pickChip,
                      afficherTout: true,
                      toutActif: _toutChipActive,
                      onChoisirTout: _pickAll,
                    ),
                    AppDimens.vGap24,
                    const TitreSectionWallet('Destinataire'),
                    AppDimens.vGap8,
                    const SelecteurDestinataire(
                      codeLogo: 'OM',
                      couleurLogo: Color(0xFFFF6B00),
                      titre: 'Mon numéro MoMo',
                      sousTitre: '07 11 22 33 44 · Orange Money',
                    ),
                    AppDimens.vGap16,
                    const TitreSectionWallet('Code PIN MoMo'),
                    AppDimens.vGap8,
                    const SaisiePin(),
                    AppDimens.vGap8,
                    const LigneInfoWallet(
                      message:
                          'Le retrait sera disponible dans ~5 minutes. '
                          'Frais MoMo : 0 F (offert par FarmCash).',
                    ),
                  ],
                ),
              ),
            ),
            BoutonStickyAction(
              label: 'Confirmer le retrait',
              onTap: _onConfirmer,
            ),
          ],
        ),
      ),
    );
  }
}
