import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../routing/route_names.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_dimens.dart';
import '../../../theme/app_text_styles.dart';

/// Page Itinéraires du transporteur — placeholder hors shell.
///
/// L'onglet « Itinéraires » a été retiré du bottom-nav transporteur.
/// La route est conservée pour compatibilité (deeplinks anciens, etc.).
/// V1 : message simple + lien vers la page Missions.
class ItinerairesTransporteurPage extends ConsumerWidget {
  const ItinerairesTransporteurPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _Header(
              onBack: () => context.canPop()
                  ? context.pop()
                  : context.go(RouteNames.transporteurMissionsPath),
            ),
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppDimens.space24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.alt_route_outlined,
                        size: 40,
                        color: AppColors.textSubtle.withValues(alpha: 0.9),
                      ),
                      AppDimens.vGap12,
                      Text(
                        'Mes itinéraires',
                        style: AppTextStyles.titleMedium,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Cette page sera enrichie prochainement.',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      AppDimens.vGap16,
                      TextButton(
                        onPressed: () => context.go(
                          RouteNames.transporteurMissionsPath,
                        ),
                        child: Text(
                          'Voir mes missions actives',
                          style: AppTextStyles.link.copyWith(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimens.pagePaddingH,
        AppDimens.space8,
        AppDimens.pagePaddingH,
        AppDimens.space12,
      ),
      child: Row(
        children: [
          InkWell(
            onTap: onBack,
            borderRadius: BorderRadius.circular(20),
            child: const SizedBox(
              width: 40,
              height: 40,
              child: Icon(
                Icons.arrow_back_ios_new,
                size: 20,
                color: AppColors.text,
              ),
            ),
          ),
          Expanded(
            child: Text(
              'Mes itinéraires',
              style: AppTextStyles.titleSmall.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
