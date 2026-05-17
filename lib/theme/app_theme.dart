// =====================================================================
//  AppTheme — ThemeData light/dark FarmCash (alignée DESIGN.md)
//  ---------------------------------------------------------------------
//  Principes appliqués :
//   • Material 3 mais sobre, sans surfaceTint coloré
//   • Aucune ombre prononcée (cards, boutons, dialogs) — bordure 1px
//   • Inputs : bordure 1px → bordure verte au focus (PAS de halo)
//   • Vert primaire utilisé uniquement pour : bouton primaire, lien,
//     bordure focus, indicateur de tab/loader
//   • Pas de surfaceContainer coloré (tout reste blanc / soft)
// =====================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_dimens.dart';
import 'app_text_styles.dart';

class AppTheme {
  AppTheme._();

  // ───────────────────────────────────────────────────────────────────
  //  LIGHT
  // ───────────────────────────────────────────────────────────────────
  static ThemeData get light {
    const scheme = ColorScheme.light(
      primary: AppColors.primary,
      onPrimary: AppColors.onPrimary,
      primaryContainer: AppColors.primary,
      onPrimaryContainer: AppColors.onPrimary,
      secondary: AppColors.primary,
      onSecondary: AppColors.onPrimary,
      error: AppColors.error,
      onError: AppColors.onError,
      surface: AppColors.surface,
      onSurface: AppColors.text,
      surfaceContainerHighest: AppColors.surfaceSoft,
      onSurfaceVariant: AppColors.textSecondary,
      outline: AppColors.borderStrong,
      outlineVariant: AppColors.border,
      shadow: Colors.black12,
      scrim: Colors.black54,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.background,
      canvasColor: AppColors.background,
      dividerColor: AppColors.border,
      splashFactory: InkRipple.splashFactory,

      textTheme: AppTextStyles.textTheme,
      primaryTextTheme: AppTextStyles.textTheme,

      // ── AppBar : plate, sans tint coloré ─────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.text,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        toolbarHeight: AppDimens.appBarHeight,
        titleTextStyle: AppTextStyles.titleLarge,
        iconTheme: const IconThemeData(
          color: AppColors.text,
          size: AppDimens.iconL,
        ),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
      ),

      // ── Boutons : plats, radius 10, sans ombre ───────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          disabledBackgroundColor: AppColors.borderStrong,
          disabledForegroundColor: AppColors.textSubtle,
          minimumSize: const Size.fromHeight(AppDimens.buttonHeight),
          padding: AppDimens.paddingButton,
          shape: const RoundedRectangleBorder(borderRadius: AppDimens.brButton),
          textStyle: AppTextStyles.button,
          elevation: 0,
          shadowColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
        ).copyWith(
          overlayColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.hovered) ||
                states.contains(WidgetState.pressed)) {
              return AppColors.primaryHover.withValues(alpha: 0.10);
            }
            return null;
          }),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          minimumSize: const Size.fromHeight(AppDimens.buttonHeight),
          padding: AppDimens.paddingButton,
          shape: const RoundedRectangleBorder(borderRadius: AppDimens.brButton),
          textStyle: AppTextStyles.button,
          elevation: 0,
        ),
      ),

      // Bouton secondaire = outlined gris neutre (PAS bordure verte)
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.text,
          side: const BorderSide(
            color: AppColors.borderStrong,
            width: AppDimens.borderThin,
          ),
          minimumSize: const Size.fromHeight(AppDimens.buttonHeight),
          padding: AppDimens.paddingButton,
          shape: const RoundedRectangleBorder(borderRadius: AppDimens.brButton),
          textStyle: AppTextStyles.button,
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.space12,
            vertical: AppDimens.space8,
          ),
          textStyle: AppTextStyles.button,
        ),
      ),

      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: AppColors.text,
          minimumSize: const Size(40, 40),
          shape: const RoundedRectangleBorder(borderRadius: AppDimens.brButton),
        ),
      ),

      // ── Cards : bordure 1px plutôt qu'ombre ──────────────────────
      cardTheme: CardThemeData(
        color: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: const RoundedRectangleBorder(
          borderRadius: AppDimens.brCard,
          side: BorderSide(
            color: AppColors.border,
            width: AppDimens.borderThin,
          ),
        ),
        clipBehavior: Clip.antiAlias,
      ),

      // ── Inputs : blanc, bordure 1px → vert au focus (sans halo) ──
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.background,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        constraints: const BoxConstraints(minHeight: AppDimens.inputHeight),
        hintStyle: AppTextStyles.hint,
        labelStyle: AppTextStyles.labelMedium,
        floatingLabelBehavior: FloatingLabelBehavior.never, // labels au-dessus
        errorStyle: AppTextStyles.errorText,
        border: const OutlineInputBorder(
          borderRadius: AppDimens.brInput,
          borderSide: BorderSide(
            color: AppColors.borderStrong,
            width: AppDimens.borderThin,
          ),
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: AppDimens.brInput,
          borderSide: BorderSide(
            color: AppColors.borderStrong,
            width: AppDimens.borderThin,
          ),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: AppDimens.brInput,
          borderSide: BorderSide(
            color: AppColors.primary,
            width: AppDimens.borderThin,
          ),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: AppDimens.brInput,
          borderSide: BorderSide(
            color: AppColors.error,
            width: AppDimens.borderThin,
          ),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderRadius: AppDimens.brInput,
          borderSide: BorderSide(
            color: AppColors.error,
            width: AppDimens.borderThin,
          ),
        ),
        disabledBorder: const OutlineInputBorder(
          borderRadius: AppDimens.brInput,
          borderSide: BorderSide(
            color: AppColors.border,
            width: AppDimens.borderThin,
          ),
        ),
      ),

      // ── Bottom Navigation : sobre ────────────────────────────────
      navigationBarTheme: NavigationBarThemeData(
        height: AppDimens.bottomNavHeight,
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        indicatorColor: Colors.transparent, // pas de pastille colorée
        elevation: 0,
        labelTextStyle: WidgetStatePropertyAll(AppTextStyles.labelSmall),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(
              color: AppColors.primary,
              size: AppDimens.iconL,
            );
          }
          return const IconThemeData(
            color: AppColors.textSecondary,
            size: AppDimens.iconL,
          );
        }),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.background,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        selectedLabelStyle: AppTextStyles.labelSmall,
        unselectedLabelStyle: AppTextStyles.labelSmall,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        showSelectedLabels: true,
        showUnselectedLabels: true,
      ),

      // ── FAB : plat, sans tint ────────────────────────────────────
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: 0,
        focusElevation: 0,
        hoverElevation: 0,
        highlightElevation: 0,
        shape: RoundedRectangleBorder(borderRadius: AppDimens.brButton),
      ),

      // ── Chip : neutre, devient vert quand sélectionné ────────────
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.background,
        selectedColor: AppColors.primary,
        labelStyle: AppTextStyles.labelMedium,
        secondaryLabelStyle:
            AppTextStyles.labelMedium.copyWith(color: AppColors.onPrimary),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppDimens.radiusPill)),
          side: BorderSide(color: AppColors.borderStrong, width: 1),
        ),
        side: const BorderSide(color: AppColors.borderStrong, width: 1),
      ),

      // ── Dialog : sobre, bordure légère ───────────────────────────
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: AppDimens.brCard,
          side: BorderSide(color: AppColors.border, width: 1),
        ),
        titleTextStyle: AppTextStyles.titleLarge,
        contentTextStyle: AppTextStyles.bodyMedium,
      ),

      // ── Bottom Sheet : drag handle visible, sans tint ────────────
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: AppDimens.brBottomSheet),
        showDragHandle: true,
        dragHandleColor: AppColors.borderStrong,
      ),

      // ── SnackBar : flottant, sobre ───────────────────────────────
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.text,
        contentTextStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.onPrimary,
        ),
        actionTextColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(borderRadius: AppDimens.brButton),
        elevation: 0,
      ),

      // ── Divider : fil très fin ───────────────────────────────────
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: AppDimens.borderThin,
        space: AppDimens.space16,
      ),

      // ── TabBar : indicateur vert, sans fond coloré ───────────────
      tabBarTheme: TabBarThemeData(
        labelColor: AppColors.text,
        unselectedLabelColor: AppColors.textSecondary,
        labelStyle: AppTextStyles.titleSmall,
        unselectedLabelStyle: AppTextStyles.titleSmall,
        indicator: const UnderlineTabIndicator(
          borderSide: BorderSide(
            color: AppColors.primary,
            width: AppDimens.borderMedium,
          ),
        ),
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: AppColors.border,
      ),

      // ── ProgressIndicator : vert ────────────────────────────────
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
        circularTrackColor: AppColors.border,
        linearTrackColor: AppColors.border,
      ),

      // ── Switch / Checkbox / Radio ────────────────────────────────
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.onPrimary;
          return AppColors.surface;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.primary;
          return AppColors.borderStrong;
        }),
        trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.primary;
          return Colors.transparent;
        }),
        checkColor: const WidgetStatePropertyAll(AppColors.onPrimary),
        side: const BorderSide(
          color: AppColors.borderStrong,
          width: AppDimens.borderThin,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.primary;
          return AppColors.borderStrong;
        }),
      ),

      // ── ListTile ─────────────────────────────────────────────────
      listTileTheme: const ListTileThemeData(
        iconColor: AppColors.textSecondary,
        textColor: AppColors.text,
        tileColor: Colors.transparent,
        contentPadding:
            EdgeInsets.symmetric(horizontal: AppDimens.pagePaddingH),
        minVerticalPadding: AppDimens.space12,
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────
  //  DARK
  // ───────────────────────────────────────────────────────────────────
  static ThemeData get dark {
    const scheme = ColorScheme.dark(
      primary: AppColors.primaryDark,
      onPrimary: AppColors.backgroundDark,
      secondary: AppColors.primaryDark,
      onSecondary: AppColors.backgroundDark,
      error: Color(0xFFEF9A9A),
      onError: Color(0xFF400D0D),
      surface: AppColors.surfaceDark,
      onSurface: AppColors.textDark,
      surfaceContainerHighest: AppColors.surfaceSoftDark,
      onSurfaceVariant: AppColors.textSecondaryDark,
      outline: AppColors.borderStrongDark,
      outlineVariant: AppColors.borderDark,
      shadow: Colors.black,
      scrim: Colors.black87,
    );

    return light.copyWith(
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.backgroundDark,
      canvasColor: AppColors.backgroundDark,
      dividerColor: AppColors.borderDark,
      textTheme: AppTextStyles.textThemeDark,
      primaryTextTheme: AppTextStyles.textThemeDark,
      appBarTheme: light.appBarTheme.copyWith(
        backgroundColor: AppColors.backgroundDark,
        foregroundColor: AppColors.textDark,
        titleTextStyle: AppTextStyles.titleLarge.copyWith(
          color: AppColors.textDark,
        ),
        iconTheme: const IconThemeData(
          color: AppColors.textDark,
          size: AppDimens.iconL,
        ),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
      ),
      cardTheme: light.cardTheme.copyWith(
        color: AppColors.surfaceDark,
        shape: const RoundedRectangleBorder(
          borderRadius: AppDimens.brCard,
          side: BorderSide(color: AppColors.borderDark, width: 1),
        ),
      ),
      inputDecorationTheme: light.inputDecorationTheme.copyWith(
        fillColor: AppColors.surfaceDark,
        hintStyle: AppTextStyles.hint.copyWith(color: AppColors.textSubtleDark),
        labelStyle:
            AppTextStyles.labelMedium.copyWith(color: AppColors.textSecondaryDark),
        enabledBorder: const OutlineInputBorder(
          borderRadius: AppDimens.brInput,
          borderSide: BorderSide(color: AppColors.borderStrongDark, width: 1),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: AppDimens.brInput,
          borderSide: BorderSide(color: AppColors.primaryDark, width: 1),
        ),
        disabledBorder: const OutlineInputBorder(
          borderRadius: AppDimens.brInput,
          borderSide: BorderSide(color: AppColors.borderDark, width: 1),
        ),
      ),
      navigationBarTheme: light.navigationBarTheme.copyWith(
        backgroundColor: AppColors.backgroundDark,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(
              color: AppColors.primaryDark,
              size: AppDimens.iconL,
            );
          }
          return const IconThemeData(
            color: AppColors.textSecondaryDark,
            size: AppDimens.iconL,
          );
        }),
      ),
      bottomNavigationBarTheme: light.bottomNavigationBarTheme.copyWith(
        backgroundColor: AppColors.backgroundDark,
        selectedItemColor: AppColors.primaryDark,
        unselectedItemColor: AppColors.textSecondaryDark,
      ),
      dialogTheme: light.dialogTheme.copyWith(
        backgroundColor: AppColors.surfaceDark,
        titleTextStyle:
            AppTextStyles.titleLarge.copyWith(color: AppColors.textDark),
        contentTextStyle:
            AppTextStyles.bodyMedium.copyWith(color: AppColors.textDark),
        shape: const RoundedRectangleBorder(
          borderRadius: AppDimens.brCard,
          side: BorderSide(color: AppColors.borderDark, width: 1),
        ),
      ),
      bottomSheetTheme: light.bottomSheetTheme.copyWith(
        backgroundColor: AppColors.surfaceDark,
      ),
      snackBarTheme: light.snackBarTheme.copyWith(
        backgroundColor: AppColors.surfaceSoftDark,
        contentTextStyle:
            AppTextStyles.bodyMedium.copyWith(color: AppColors.textDark),
      ),
      dividerTheme: light.dividerTheme.copyWith(color: AppColors.borderDark),
      chipTheme: light.chipTheme.copyWith(
        backgroundColor: AppColors.surfaceDark,
        labelStyle:
            AppTextStyles.labelMedium.copyWith(color: AppColors.textDark),
        side: const BorderSide(color: AppColors.borderStrongDark, width: 1),
      ),
    );
  }
}
