import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

/// يجمّع رموز نظام التصميم في [ThemeData] واحدة.
///
/// كل شاشة — حتى التي لم تُعَد كتابتها بعد — ترث من هنا الخلفية القماشية،
/// الخطوط العربية، أنصاف الأقطار، وألوان الأزرار والحقول والحوارات.
class AppTheme {
  const AppTheme._();

  static const ColorScheme _colorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.primary,
    onPrimary: AppColors.onPrimary,
    primaryContainer: AppColors.primarySoft,
    onPrimaryContainer: AppColors.primaryDark,
    secondary: AppColors.gold,
    onSecondary: AppColors.onPrimary,
    secondaryContainer: AppColors.goldSoft,
    onSecondaryContainer: AppColors.goldDark,
    tertiary: AppColors.goldDark,
    onTertiary: AppColors.onPrimary,
    tertiaryContainer: AppColors.goldSoft,
    onTertiaryContainer: AppColors.goldDark,
    error: AppColors.danger,
    onError: AppColors.onPrimary,
    errorContainer: AppColors.dangerSoft,
    onErrorContainer: AppColors.danger,
    surface: AppColors.bgElev,
    onSurface: AppColors.ink,
    surfaceContainerLowest: AppColors.bgElev,
    surfaceContainerLow: AppColors.bg,
    surfaceContainer: AppColors.bg,
    surfaceContainerHigh: AppColors.bgSunken,
    surfaceContainerHighest: AppColors.bgSunken,
    onSurfaceVariant: AppColors.inkMuted,
    outline: AppColors.line,
    outlineVariant: AppColors.line,
    shadow: AppColors.ink,
    scrim: AppColors.ink,
    inverseSurface: AppColors.primaryDark,
    onInverseSurface: AppColors.onPrimary,
    inversePrimary: AppColors.primarySoft,
  );

  static const TextTheme _textTheme = TextTheme(
    displayLarge: AppText.displayLarge,
    displayMedium: AppText.displayMedium,
    displaySmall: AppText.displaySmall,
    headlineLarge: AppText.displayMedium,
    headlineMedium: AppText.displaySmall,
    headlineSmall: AppText.displayXSmall,
    titleLarge: AppText.displaySmall,
    titleMedium: AppText.displayXSmall,
    titleSmall: AppText.bodyStrong,
    bodyLarge: AppText.bodyLarge,
    bodyMedium: AppText.bodyMedium,
    bodySmall: AppText.caption,
    labelLarge: AppText.button,
    labelMedium: AppText.captionStrong,
    labelSmall: AppText.overline,
  );

  /// لون شريط الحالة: أيقونات فاتحة فوق الشريط العلوي الأخضر.
  static const SystemUiOverlayStyle systemOverlay = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
    systemNavigationBarColor: AppColors.bg,
    systemNavigationBarIconBrightness: Brightness.dark,
  );

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      colorScheme: _colorScheme,
      textTheme: _textTheme,
      fontFamily: AppFonts.body,
      fontFamilyFallback: AppFonts.fallback,
      scaffoldBackgroundColor: AppColors.bg,
      canvasColor: AppColors.bg,
      dividerColor: AppColors.line,
      splashFactory: InkSparkle.splashFactory,
      visualDensity: VisualDensity.standard,
      iconTheme: const IconThemeData(color: AppColors.primary, size: 22),
      primaryIconTheme: const IconThemeData(color: AppColors.onPrimary),

      // ------------------------------------------------------ الشريط العلوي
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppText.appBarTitle,
        toolbarTextStyle: AppText.bodyMedium,
        iconTheme: IconThemeData(color: AppColors.onPrimary, size: 22),
        actionsIconTheme: IconThemeData(color: AppColors.onPrimary, size: 22),
        systemOverlayStyle: systemOverlay,
        // الخيط الذهبي الفاصل بين الشريط والمحتوى — توقيع الهوية، يصل كل
        // شريط علوي في التطبيق حتى الشاشات التي ما زالت تستعمل AppBar العادية.
        shape: Border(
          bottom: BorderSide(color: AppColors.gold, width: 2),
        ),
      ),

      // ------------------------------------------------------------ البطاقات
      cardTheme: const CardThemeData(
        color: AppColors.bgElev,
        surfaceTintColor: Colors.transparent,
        shadowColor: Color(0x141C2A24),
        elevation: 0,
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadii.xlAll,
          side: BorderSide(color: AppColors.line),
        ),
      ),

      // -------------------------------------------------------------- الحقول
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.bgElev,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm + 2,
        ),
        hintStyle: AppText.bodyMedium.copyWith(color: AppColors.inkFaint),
        labelStyle: AppText.bodyMedium.copyWith(color: AppColors.inkMuted),
        floatingLabelStyle: AppText.captionStrong.copyWith(
          color: AppColors.primary,
        ),
        helperStyle: AppText.caption,
        errorStyle: AppText.caption.copyWith(color: AppColors.danger),
        prefixIconColor: AppColors.inkMuted,
        suffixIconColor: AppColors.inkMuted,
        border: const OutlineInputBorder(
          borderRadius: AppRadii.mdAll,
          borderSide: BorderSide(color: AppColors.line),
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: AppRadii.mdAll,
          borderSide: BorderSide(color: AppColors.line),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: AppRadii.mdAll,
          borderSide: BorderSide(color: AppColors.primary, width: 1.6),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: AppRadii.mdAll,
          borderSide: BorderSide(color: AppColors.danger),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderRadius: AppRadii.mdAll,
          borderSide: BorderSide(color: AppColors.danger, width: 1.6),
        ),
        disabledBorder: const OutlineInputBorder(
          borderRadius: AppRadii.mdAll,
          borderSide: BorderSide(color: AppColors.line),
        ),
      ),

      // -------------------------------------------------------------- الأزرار
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          disabledBackgroundColor: AppColors.primarySoft,
          disabledForegroundColor: AppColors.inkFaint,
          elevation: 0,
          minimumSize: const Size(0, 52),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          textStyle: AppText.button,
          shape: const RoundedRectangleBorder(borderRadius: AppRadii.mdAll),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          disabledBackgroundColor: AppColors.primarySoft,
          disabledForegroundColor: AppColors.inkFaint,
          minimumSize: const Size(0, 52),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          textStyle: AppText.button,
          shape: const RoundedRectangleBorder(borderRadius: AppRadii.mdAll),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          backgroundColor: AppColors.bgElev,
          disabledForegroundColor: AppColors.inkFaint,
          minimumSize: const Size(0, 52),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          textStyle: AppText.button,
          side: const BorderSide(color: AppColors.line),
          shape: const RoundedRectangleBorder(borderRadius: AppRadii.mdAll),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          disabledForegroundColor: AppColors.inkFaint,
          minimumSize: const Size(0, 44),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          textStyle: AppText.button,
          shape: const RoundedRectangleBorder(borderRadius: AppRadii.smAll),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(foregroundColor: AppColors.primary),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: 0,
        focusElevation: 0,
        hoverElevation: 0,
        highlightElevation: 0,
        extendedTextStyle: AppText.button,
        extendedPadding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        shape: RoundedRectangleBorder(borderRadius: AppRadii.pillAll),
      ),

      // -------------------------------------------------------------- الشرائح
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.primaryTint,
        selectedColor: AppColors.primary,
        secondarySelectedColor: AppColors.primary,
        disabledColor: AppColors.bgSunken,
        checkmarkColor: AppColors.onPrimary,
        labelStyle: AppText.captionStrong.copyWith(color: AppColors.primaryDark),
        secondaryLabelStyle: AppText.captionStrong.copyWith(
          color: AppColors.onPrimary,
        ),
        side: const BorderSide(color: AppColors.line),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        shape: const RoundedRectangleBorder(borderRadius: AppRadii.pillAll),
        showCheckmark: false,
      ),

      // -------------------------------------------------------------- الحوارات
      dialogTheme: const DialogThemeData(
        backgroundColor: AppColors.bgElev,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: AppText.displaySmall,
        contentTextStyle: AppText.bodyMedium,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadii.xlAll,
          side: BorderSide(color: AppColors.line),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.bgElev,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        modalElevation: 0,
        showDragHandle: true,
        dragHandleColor: AppColors.line,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadii.xl),
          ),
        ),
      ),
      popupMenuTheme: const PopupMenuThemeData(
        color: AppColors.bgElev,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        textStyle: AppText.bodyMedium,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadii.mdAll,
          side: BorderSide(color: AppColors.line),
        ),
      ),
      drawerTheme: const DrawerThemeData(
        backgroundColor: AppColors.bg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.horizontal(
            left: Radius.circular(AppRadii.xl),
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.primaryDark,
        contentTextStyle: AppText.bodyMedium.copyWith(
          color: AppColors.onPrimary,
        ),
        actionTextColor: AppColors.goldSoft,
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        shape: const RoundedRectangleBorder(borderRadius: AppRadii.mdAll),
      ),

      // ------------------------------------------------------ عناصر متفرقة
      dividerTheme: const DividerThemeData(
        color: AppColors.line,
        thickness: 1,
        space: 1,
      ),
      listTileTheme: const ListTileThemeData(
        iconColor: AppColors.primary,
        textColor: AppColors.ink,
        titleTextStyle: AppText.bodyLarge,
        subtitleTextStyle: AppText.caption,
        contentPadding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        shape: RoundedRectangleBorder(borderRadius: AppRadii.mdAll),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: AppColors.bgSunken,
        circularTrackColor: Colors.transparent,
        linearMinHeight: 8,
      ),
      tabBarTheme: const TabBarThemeData(
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.inkMuted,
        labelStyle: AppText.bodyStrong,
        unselectedLabelStyle: AppText.bodyMedium,
        indicatorColor: AppColors.gold,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: AppColors.line,
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.primary;
          return AppColors.bgElev;
        }),
        checkColor: const WidgetStatePropertyAll(AppColors.onPrimary),
        side: const BorderSide(color: AppColors.line, width: 1.5),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(6)),
        ),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.primary;
          return AppColors.inkFaint;
        }),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.onPrimary;
          return AppColors.bgElev;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.primary;
          return AppColors.bgSunken;
        }),
        trackOutlineColor: const WidgetStatePropertyAll(AppColors.line),
      ),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: AppColors.primary,
        selectionColor: AppColors.primarySoft,
        selectionHandleColor: AppColors.primary,
      ),
      expansionTileTheme: const ExpansionTileThemeData(
        iconColor: AppColors.primary,
        collapsedIconColor: AppColors.inkMuted,
        textColor: AppColors.ink,
        collapsedTextColor: AppColors.ink,
        backgroundColor: AppColors.bgElev,
        collapsedBackgroundColor: AppColors.bgElev,
        shape: RoundedRectangleBorder(borderRadius: AppRadii.lgAll),
        collapsedShape: RoundedRectangleBorder(borderRadius: AppRadii.lgAll),
      ),
      bottomAppBarTheme: const BottomAppBarTheme(
        color: AppColors.bgElev,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        height: 72,
      ),
      datePickerTheme: const DatePickerThemeData(
        backgroundColor: AppColors.bgElev,
        surfaceTintColor: Colors.transparent,
        headerBackgroundColor: AppColors.primary,
        headerForegroundColor: AppColors.onPrimary,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: AppRadii.xlAll),
      ),
      timePickerTheme: const TimePickerThemeData(
        backgroundColor: AppColors.bgElev,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: AppRadii.xlAll),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: const BoxDecoration(
          color: AppColors.primaryDark,
          borderRadius: AppRadii.smAll,
        ),
        textStyle: AppText.caption.copyWith(color: AppColors.onPrimary),
      ),
    );
  }
}
