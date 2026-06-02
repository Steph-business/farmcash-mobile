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

/// Mode du scanner : enlèvement chez le producteur ou livraison chez
/// l'acheteur. Le mode contrôle quel endpoint est appelé après le scan
/// et où l'utilisateur est redirigé en cas de succès.
enum ScannerMode {
  /// QR du producteur — déclenche `scan-pickup` + libère escrow PRODUCT.
  pickup,

  /// QR de l'acheteur — déclenche `scan-delivery` + libère escrow
  /// TRANSPORT et passe la commande en COMPLETED.
  delivery,
}

/// Scanner QR (placeholder caméra : V1 utilise la saisie manuelle).
///
/// La route porte le `missionId` cible et un `mode` (pickup ou delivery).
/// Le scan déclenche soit `scan-pickup` soit `scan-delivery` avec la
/// position GPS (anti-fraude, < 500 m du point attendu).
class ScannerPage extends ConsumerStatefulWidget {
  const ScannerPage({
    this.missionId,
    this.mode = ScannerMode.pickup,
    super.key,
  });

  final String? missionId;

  /// Mode de scan — détermine l'endpoint appelé et le wording.
  final ScannerMode mode;

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
                  widget.mode == ScannerMode.delivery
                      ? 'Pointe la caméra vers le QR de l\'acheteur'
                      : 'Pointe la caméra vers le QR du producteur',
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
    final estDelivery = widget.mode == ScannerMode.delivery;
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          estDelivery ? 'Scan livraison' : 'Saisie manuelle',
        ),
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
              decoration: InputDecoration(
                labelText: estDelivery
                    ? 'Token QR acheteur'
                    : 'Token QR producteur',
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
            'Position GPS requise pour valider le scan.',
          );
        }
        return;
      }
      final svc = ref.read(logisticsServiceProvider);
      if (widget.mode == ScannerMode.delivery) {
        // Photo de preuve : placeholder côté V1 — l'upload réel viendra
        // dans une PR dédiée. Le backend exige une URL HTTP/HTTPS valide.
        await svc.scanDelivery(
          shipmentId: shipmentId,
          token: token,
          lat: position.latitude,
          lng: position.longitude,
          photoPreuveUrl:
              'https://placeholder.farmcash.app/delivery-proof.jpg',
        );
        if (!mounted) return;
        Snackbars.showSucces(
          context,
          'Livraison confirmée · transporteur payé',
        );
        context.go(
          RouteNames.transporteurLivraisonConfirmePathFor(shipmentId),
        );
      } else {
        await svc.scanPickup(
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
      }
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
