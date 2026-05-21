import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';

import '../../../api_client/api_exception.dart';
import '../../../routing/route_names.dart';
import '../../../services/providers.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../widgets/communs/snackbars.dart';

const Color _kBg = Color(0xFF1A1A1A);

/// Scanner QR (placeholder caméra : V1 utilise la saisie manuelle).
///
/// La route porte le `missionId` cible — on accepte aussi un mode "demo"
/// où le shipmentId est saisi à la main. Le scan déclenche
/// `POST /logistics/shipments/:id/scan-pickup` avec la position GPS.
class ScannerPage extends ConsumerStatefulWidget {
  const ScannerPage({this.missionId, super.key});

  final String? missionId;

  @override
  ConsumerState<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends ConsumerState<ScannerPage> {
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: SafeArea(
        child: Stack(
          children: [
            // ─── Header : croix de fermeture ────────────────────────
            Positioned(
              top: 8,
              right: 8,
              child: InkWell(
                onTap: () => Navigator.of(context).pop(),
                borderRadius: BorderRadius.circular(20),
                child: const SizedBox(
                  width: 44,
                  height: 44,
                  child: Icon(Icons.close, color: Colors.white, size: 24),
                ),
              ),
            ),

            // ─── Cadre central ──────────────────────────────────────
            Center(
              child: SizedBox(
                width: 240,
                height: 240,
                child: Stack(
                  children: [
                    _Corner(top: 0, left: 0, top1: true, left1: true),
                    _Corner(top: 0, right: 0, top1: true, right1: true),
                    _Corner(bottom: 0, left: 0, bottom1: true, left1: true),
                    _Corner(bottom: 0, right: 0, bottom1: true, right1: true),
                    const Positioned(
                      left: 0,
                      right: 0,
                      top: 119,
                      child: SizedBox(
                        height: 2,
                        child: ColoredBox(color: AppColors.primary),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ─── Texte sous le cadre ────────────────────────────────
            Align(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.only(top: 320),
                child: Text(
                  'Pointe la caméra vers le QR du producteur',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            // ─── Lien saisie manuelle ───────────────────────────────
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 40),
                child: TextButton(
                  onPressed: _busy ? null : _ouvrirSaisieManuelle,
                  child: Text(
                    _busy
                        ? 'Validation en cours…'
                        : 'Saisir le code manuellement',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _ouvrirSaisieManuelle() async {
    final shipmentCtrl = TextEditingController(text: widget.missionId ?? '');
    final tokenCtrl = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Saisie manuelle'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: shipmentCtrl,
              decoration: const InputDecoration(
                labelText: 'ID mission',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: tokenCtrl,
              decoration: const InputDecoration(
                labelText: 'Token QR producteur',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Valider'),
          ),
        ],
      ),
    );
    if (result != true) return;
    if (!mounted) return;
    await _validerScan(
      shipmentId: shipmentCtrl.text.trim(),
      token: tokenCtrl.text.trim(),
    );
  }

  Future<void> _validerScan({
    required String shipmentId,
    required String token,
  }) async {
    if (shipmentId.isEmpty || token.isEmpty) {
      Snackbars.showErreur(context, 'Mission ID et token requis.');
      return;
    }
    setState(() => _busy = true);
    try {
      final position = await _getCurrentPosition();
      if (position == null) {
        if (mounted) {
          Snackbars.showErreur(
            context,
            'Position GPS requise pour valider l\'enlèvement.',
          );
        }
        return;
      }
      await ref.read(logisticsServiceProvider).scanPickup(
            shipmentId: shipmentId,
            token: token,
            lat: position.latitude,
            lng: position.longitude,
          );
      if (!mounted) return;
      Snackbars.showSucces(context, 'Enlèvement confirmé · escrow libéré');
      context.go(
        RouteNames.transporteurEnlevementConfirmePathFor(shipmentId),
      );
    } on ApiException catch (e) {
      if (mounted) Snackbars.showErreur(context, e.message);
    } catch (e) {
      if (mounted) Snackbars.showErreur(context, 'Erreur : $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<Position?> _getCurrentPosition() async {
    try {
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) return null;
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
    } catch (_) {
      return null;
    }
  }
}

// ─── Coin du cadre (L) ───────────────────────────────────────────────

class _Corner extends StatelessWidget {
  const _Corner({
    this.top,
    this.bottom,
    this.left,
    this.right,
    this.top1 = false,
    this.bottom1 = false,
    this.left1 = false,
    this.right1 = false,
  });

  final double? top;
  final double? bottom;
  final double? left;
  final double? right;
  final bool top1;
  final bool bottom1;
  final bool left1;
  final bool right1;

  @override
  Widget build(BuildContext context) {
    const side = BorderSide(color: AppColors.primary, width: 3);
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          border: Border(
            top: top1 ? side : BorderSide.none,
            bottom: bottom1 ? side : BorderSide.none,
            left: left1 ? side : BorderSide.none,
            right: right1 ? side : BorderSide.none,
          ),
        ),
      ),
    );
  }
}
