import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';

/// Loader sobre, centré, sans message.
class Chargement extends StatelessWidget {
  const Chargement({this.size = 24, super.key});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: const CircularProgressIndicator(
          strokeWidth: 2.4,
          color: AppColors.primary,
        ),
      ),
    );
  }
}
