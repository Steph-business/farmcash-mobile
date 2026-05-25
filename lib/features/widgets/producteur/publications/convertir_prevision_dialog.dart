import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../models/enums.dart';
import '../../../../models/prevision.dart';

/// Résultat retourné par `showConvertirPrevisionDialog`. Le backend exige
/// titre, prix, qualité, quantité min, région+ville et coordonnées GPS.
class ConvertirPrevisionParams {
  const ConvertirPrevisionParams({
    required this.titre,
    required this.prix,
    required this.quantiteMinKg,
    required this.qualite,
    required this.regionId,
    required this.villeId,
  });

  final String titre;
  final double prix;
  final double quantiteMinKg;
  final ProductQuality qualite;
  final String regionId;
  final String villeId;
}

/// Ouvre le dialog de conversion d'une prévision en annonce. Retourne les
/// paramètres saisis (titre, prix, qualité, ville…) ou `null` si annulé.
Future<ConvertirPrevisionParams?> showConvertirPrevisionDialog(
  BuildContext context, {
  required Prevision prevision,
  required List<dynamic> villes,
}) {
  return showDialog<ConvertirPrevisionParams>(
    context: context,
    builder: (ctx) => _ConvertirPrevisionDialog(
      prevision: prevision,
      villes: villes,
    ),
  );
}

/// Dialogue interne de conversion d'une prévision en annonce. Capture les
/// champs requis par `ConvertPrevisionDto` côté backend.
class _ConvertirPrevisionDialog extends StatefulWidget {
  const _ConvertirPrevisionDialog({
    required this.prevision,
    required this.villes,
  });

  final Prevision prevision;
  final List<dynamic> villes;

  @override
  State<_ConvertirPrevisionDialog> createState() =>
      _ConvertirPrevisionDialogState();
}

class _ConvertirPrevisionDialogState
    extends State<_ConvertirPrevisionDialog> {
  late final TextEditingController _titreCtrl;
  late final TextEditingController _prixCtrl;
  late final TextEditingController _qteMinCtrl;
  ProductQuality _qualite = ProductQuality.premium;
  dynamic _ville;

  @override
  void initState() {
    super.initState();
    _titreCtrl = TextEditingController(
      text: 'Récolte ${widget.prevision.id.substring(0, 6)}',
    );
    _prixCtrl = TextEditingController(
      text: widget.prevision.prixCibleKg != null
          ? widget.prevision.prixCibleKg!.toStringAsFixed(0)
          : '',
    );
    _qteMinCtrl = TextEditingController(text: '50');
    _ville = widget.villes.first;
  }

  @override
  void dispose() {
    _titreCtrl.dispose();
    _prixCtrl.dispose();
    _qteMinCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final titre = _titreCtrl.text.trim();
    final prix = double.tryParse(_prixCtrl.text.trim());
    final qteMin = double.tryParse(_qteMinCtrl.text.trim());
    if (titre.length < 3 ||
        prix == null ||
        prix <= 0 ||
        qteMin == null ||
        qteMin < 1 ||
        _ville == null) {
      return;
    }
    Navigator.of(context).pop(
      ConvertirPrevisionParams(
        titre: titre,
        prix: prix,
        quantiteMinKg: qteMin,
        qualite: _qualite,
        regionId: _ville.regionId as String,
        villeId: _ville.id as String,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Convertir en annonce'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _titreCtrl,
              decoration: const InputDecoration(
                labelText: 'Titre de l\'annonce',
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _prixCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: false),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
              ],
              decoration: const InputDecoration(
                labelText: 'Prix de vente',
                suffixText: 'F/kg',
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _qteMinCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: false),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
              ],
              decoration: const InputDecoration(
                labelText: 'Quantité min. par commande',
                suffixText: 'kg',
              ),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<ProductQuality>(
              initialValue: _qualite,
              decoration: const InputDecoration(labelText: 'Qualité'),
              items: ProductQuality.values
                  .where((q) => q != ProductQuality.unknown)
                  .map((q) => DropdownMenuItem(
                        value: q,
                        child: Text(q.apiValue),
                      ))
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => _qualite = v);
              },
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<dynamic>(
              initialValue: _ville,
              decoration: const InputDecoration(labelText: 'Ville'),
              items: widget.villes
                  .map((v) => DropdownMenuItem(
                        value: v,
                        child: Text(v.displayWithRegion as String),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => _ville = v),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
        TextButton(
          onPressed: _submit,
          child: const Text('Convertir'),
        ),
      ],
    );
  }
}
