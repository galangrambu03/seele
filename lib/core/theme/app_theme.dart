import 'package:material_ui/material_ui.dart';
import '../color/color.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColor.background,

      colorScheme: const ColorScheme.dark(
        primary: AppColor.lime,
        secondary: AppColor.cyan,
        tertiary: AppColor.lavender,
        surface: AppColor.surface,
        error: AppColor.error,
      ),

      fontFamily: 'PlusJakartaSans',

      appBarTheme: const AppBarTheme(
        backgroundColor: AppColor.background,
        foregroundColor: AppColor.textPrimary,
        elevation: 0,
      ),

      dividerColor: Colors.white12,
    );
  }
}