import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeProvider() {
    _loadTheme();
  }

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  void toggleTheme(bool isOn) {
    _themeMode = isOn ? ThemeMode.dark : ThemeMode.light;
    _saveTheme(isOn);
    notifyListeners();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('isDarkMode') ?? false;
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  Future<void> _saveTheme(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDark);
  }

  // ── Brand colors ────────────────────────────────────────────
  static const Color _primary = Color(0xFFFF6A00);
  static const Color _primaryDark = Color(0xFF9C3701);

  // ╔══════════════════════════════════════════════════════════╗
  // ║                   LIGHT THEME                           ║
  // ╚══════════════════════════════════════════════════════════╝
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: _primary,

      // Color scheme
      colorScheme: ColorScheme.fromSeed(
        seedColor: _primary,
        brightness: Brightness.light,
        primary: _primary,
        onPrimary: Colors.white,
        secondary: const Color(0xFF6B7280),
        onSecondary: Colors.white,
        surface: Colors.white,
        onSurface: const Color(0xFF111827),
        surfaceContainerHighest: const Color(0xFFF3F4F6),
        outline: const Color(0xFFE5E7EB),
        error: const Color(0xFFDC2626),
      ),

      // Scaffold
      scaffoldBackgroundColor: const Color(0xFFF3F4F6),

      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF111827),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFF111827)),
        titleTextStyle: GoogleFonts.hanuman(
          textStyle: const TextStyle(
            color: Color(0xFF111827),
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarBrightness: Brightness.light,
          statusBarIconBrightness: Brightness.dark,
        ),
      ),

      // Card
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shadowColor: Colors.black12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
      ),

      // Input decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        labelStyle: GoogleFonts.hanuman(textStyle: const TextStyle(color: Color(0xFF6B7280))),
        hintStyle: GoogleFonts.hanuman(textStyle: const TextStyle(color: Color(0xFF9CA3AF))),
        prefixIconColor: _primary,
        suffixIconColor: const Color(0xFF9CA3AF),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFDC2626)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFDC2626), width: 1.5),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
      ),

      // Text
      textTheme: GoogleFonts.hanumanTextTheme().copyWith(
        displayLarge: const TextStyle(color: Color(0xFF111827), fontWeight: FontWeight.bold),
        displayMedium: const TextStyle(color: Color(0xFF111827), fontWeight: FontWeight.bold),
        displaySmall: const TextStyle(color: Color(0xFF111827), fontWeight: FontWeight.w700),
        headlineLarge: const TextStyle(color: Color(0xFF111827), fontWeight: FontWeight.w700),
        headlineMedium: const TextStyle(color: Color(0xFF1F2937), fontWeight: FontWeight.w600),
        headlineSmall: const TextStyle(color: Color(0xFF1F2937), fontWeight: FontWeight.w600),
        titleLarge: const TextStyle(color: Color(0xFF111827), fontWeight: FontWeight.w700),
        titleMedium: const TextStyle(color: Color(0xFF1F2937), fontWeight: FontWeight.w600),
        titleSmall: const TextStyle(color: Color(0xFF374151), fontWeight: FontWeight.w500),
        bodyLarge: const TextStyle(color: Color(0xFF1F2937)),
        bodyMedium: const TextStyle(color: Color(0xFF4B5563)),
        bodySmall: const TextStyle(color: Color(0xFF6B7280)),
        labelLarge: const TextStyle(color: Color(0xFF374151), fontWeight: FontWeight.w600),
        labelMedium: const TextStyle(color: Color(0xFF6B7280)),
        labelSmall: const TextStyle(color: Color(0xFF9CA3AF)),
      ),

      // Icons
      iconTheme: const IconThemeData(color: Color(0xFF6B7280)),
      primaryIconTheme: const IconThemeData(color: _primary),

      // Divider
      dividerTheme: const DividerThemeData(
        color: Color(0xFFE5E7EB),
        thickness: 1,
        space: 1,
      ),

      // ListTile
      listTileTheme: ListTileThemeData(
        iconColor: const Color(0xFF6B7280),
        textColor: const Color(0xFF1F2937),
        subtitleTextStyle: GoogleFonts.hanuman(
          textStyle: const TextStyle(color: Color(0xFF6B7280), fontSize: 13),
        ),
      ),

      // Elevated button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          textStyle: GoogleFonts.hanuman(
            textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          ),
        ),
      ),

      // Outlined button
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _primary,
          side: const BorderSide(color: _primary),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        ),
      ),

      // Switch
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected) ? _primary : const Color(0xFFD1D5DB)),
        trackColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected) ? _primary.withOpacity(0.4) : const Color(0xFFE5E7EB)),
      ),

      // Bottom sheet
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),

      // Dialog
      dialogTheme: DialogThemeData(
        backgroundColor: Colors.white,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titleTextStyle: GoogleFonts.hanuman(
          textStyle: const TextStyle(
            color: Color(0xFF111827),
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        contentTextStyle: GoogleFonts.hanuman(
          textStyle: const TextStyle(color: Color(0xFF4B5563), fontSize: 15),
        ),
      ),

      // Snackbar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: const Color(0xFF1F2937),
        contentTextStyle: GoogleFonts.hanuman(textStyle: const TextStyle(color: Colors.white)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),

      // Chip
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFFF3F4F6),
        labelStyle: GoogleFonts.hanuman(
          textStyle: const TextStyle(color: Color(0xFF374151), fontWeight: FontWeight.w500),
        ),
        side: const BorderSide(color: Color(0xFFE5E7EB)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),
    );
  }

  // ╔══════════════════════════════════════════════════════════╗
  // ║                   DARK THEME                            ║
  // ╚══════════════════════════════════════════════════════════╝
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: _primary,

      // Color scheme
      colorScheme: ColorScheme.fromSeed(
        seedColor: _primary,
        brightness: Brightness.dark,
        primary: _primary,
        onPrimary: Colors.white,
        secondary: const Color(0xFF94A3B8),
        onSecondary: Colors.white,
        surface: const Color(0xFF0F172A),        // Slate 900
        onSurface: const Color(0xFFF1F5F9),      // Slate 100
        surfaceContainerHighest: const Color(0xFF1E293B), // Slate 800
        outline: const Color(0xFF334155),        // Slate 700
        error: const Color(0xFFF87171),
      ),

      // Scaffold
      scaffoldBackgroundColor: const Color(0xFF020617), // Slate 950

      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: GoogleFonts.hanuman(
          textStyle: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarBrightness: Brightness.dark,
          statusBarIconBrightness: Brightness.light,
        ),
      ),

      // Card
      cardTheme: CardThemeData(
        color: const Color(0xFF1E293B), // Slate 800
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF334155)),
        ),
      ),

      // Input
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1E293B),
        labelStyle: GoogleFonts.hanuman(textStyle: const TextStyle(color: Color(0xFF94A3B8))),
        hintStyle: GoogleFonts.hanuman(textStyle: const TextStyle(color: Color(0xFF64748B))),
        prefixIconColor: _primary,
        suffixIconColor: const Color(0xFF64748B),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF334155)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF334155)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFF87171)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFF87171), width: 1.5),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF1E293B)),
        ),
      ),

      // Text
      textTheme: GoogleFonts.hanumanTextTheme().copyWith(
        displayLarge: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        displayMedium: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        displaySmall: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        headlineLarge: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        headlineMedium: const TextStyle(color: Color(0xFFF1F5F9), fontWeight: FontWeight.w600),
        headlineSmall: const TextStyle(color: Color(0xFFF1F5F9), fontWeight: FontWeight.w600),
        titleLarge: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        titleMedium: const TextStyle(color: Color(0xFFF1F5F9), fontWeight: FontWeight.w600),
        titleSmall: const TextStyle(color: Color(0xFFCBD5E1), fontWeight: FontWeight.w500),
        bodyLarge: const TextStyle(color: Color(0xFFE2E8F0)),
        bodyMedium: const TextStyle(color: Color(0xFFCBD5E1)),
        bodySmall: const TextStyle(color: Color(0xFF94A3B8)),
        labelLarge: const TextStyle(color: Color(0xFFCBD5E1), fontWeight: FontWeight.w600),
        labelMedium: const TextStyle(color: Color(0xFF94A3B8)),
        labelSmall: const TextStyle(color: Color(0xFF64748B)),
      ),

      // Icons
      iconTheme: const IconThemeData(color: Color(0xFF94A3B8)),
      primaryIconTheme: const IconThemeData(color: _primary),

      // Divider
      dividerTheme: DividerThemeData(
        color: Colors.white.withOpacity(0.08),
        thickness: 1,
        space: 1,
      ),

      // ListTile
      listTileTheme: ListTileThemeData(
        iconColor: const Color(0xFF94A3B8),
        textColor: const Color(0xFFE2E8F0),
        subtitleTextStyle: GoogleFonts.hanuman(
          textStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
        ),
      ),

      // Elevated button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          textStyle: GoogleFonts.hanuman(
            textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          ),
        ),
      ),

      // Outlined button
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _primary,
          side: const BorderSide(color: _primary),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        ),
      ),

      // Switch
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected) ? _primary : const Color(0xFF475569)),
        trackColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected) ? _primary.withOpacity(0.4) : const Color(0xFF334155)),
      ),

      // Bottom sheet
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Color(0xFF0D1117),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),

      // Dialog
      dialogTheme: DialogThemeData(
        backgroundColor: const Color(0xFF1E293B),
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titleTextStyle: GoogleFonts.hanuman(
          textStyle: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        contentTextStyle: GoogleFonts.hanuman(
          textStyle: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 15),
        ),
      ),

      // Snackbar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: const Color(0xFF1E293B),
        contentTextStyle: GoogleFonts.hanuman(textStyle: const TextStyle(color: Colors.white)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),

      // Chip
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFF1E293B),
        labelStyle: GoogleFonts.hanuman(
          textStyle: const TextStyle(color: Color(0xFFCBD5E1), fontWeight: FontWeight.w500),
        ),
        side: const BorderSide(color: Color(0xFF334155)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),
    );
  }
}
