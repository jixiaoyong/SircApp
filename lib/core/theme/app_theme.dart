import 'package:material_ui/material_ui.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme => _theme(Brightness.light);
  static ThemeData get darkTheme => _theme(Brightness.dark);

  static ThemeData _theme(Brightness brightness) {
    final dark = brightness == Brightness.dark;
    final ink = Color(dark ? 0xFFF1F1F2 : 0xFF26282B);
    final muted = Color(dark ? 0xFFB2B4B8 : 0xFF66686C);
    final surface = Color(dark ? 0xFF222426 : 0xFFFFFFFF);
    final field = Color(dark ? 0xFF2D2F32 : 0xFFF2F2F2);
    final line = Color(dark ? 0xFF44474B : 0xFFDEDEDE);
    final focus = Color(dark ? 0xFF64B0FF : 0xFF0066D6);
    final scheme = ColorScheme.fromSeed(seedColor: ink, brightness: brightness)
        .copyWith(
          primary: dark ? const Color(0xFFE4E5E7) : ink,
          onPrimary: dark ? surface : Colors.white,
          secondary: focus,
          tertiary: Color(dark ? 0xFFA6C0DF : 0xFF526F91),
          surface: surface,
          surfaceContainerLowest: surface,
          surfaceContainerLow: field,
          surfaceContainer: field,
          surfaceContainerHigh: field,
          surfaceContainerHighest: field,
          onSurface: ink,
          onSurfaceVariant: muted,
          outline: Color(dark ? 0xFF85898F : 0xFF85888D),
          outlineVariant: line,
          error: Color(dark ? 0xFFFF747C : 0xFFCF242C),
          errorContainer: Color(dark ? 0xFF3D2629 : 0xFFFFF0F0),
        );
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
    );
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      brightness: brightness,
    );
    OutlineInputBorder inputBorder(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: color, width: width),
        );
    return base.copyWith(
      scaffoldBackgroundColor: Color(dark ? 0xFF171819 : 0xFFF7F7F7),
      dividerColor: line,
      textTheme: base.textTheme.apply(bodyColor: ink, displayColor: ink),
      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        foregroundColor: ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          color: ink,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: shape.copyWith(side: BorderSide(color: line)),
      ),
      dialogTheme: DialogThemeData(backgroundColor: surface, shape: shape),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: ink,
        unselectedItemColor: muted,
        elevation: 0,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        indicatorColor: field,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: shape,
          minimumSize: const Size(44, 48),
          disabledBackgroundColor: Color(dark ? 0xFF35383C : 0xFFE1E2E4),
          disabledForegroundColor: Color(dark ? 0xFFB2B4B8 : 0xFF626468),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: ink,
          shape: shape,
          side: BorderSide(color: scheme.outline),
          minimumSize: const Size(44, 44),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: ink,
          minimumSize: const Size(44, 44),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: field,
        contentPadding: const EdgeInsets.all(16),
        border: inputBorder(scheme.outline),
        enabledBorder: inputBorder(scheme.outline),
        focusedBorder: inputBorder(focus, 2),
        errorBorder: inputBorder(scheme.error),
        focusedErrorBorder: inputBorder(scheme.error, 2),
      ),
      listTileTheme: ListTileThemeData(textColor: ink, iconColor: muted),
    );
  }
}
