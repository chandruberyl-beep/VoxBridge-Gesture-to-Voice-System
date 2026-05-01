import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ── Core Palette ────────────────────────────────────────────────────────────
  static const Color bg = Color(0xFFEDF4F0);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surface2 = Color(0xFFF4F9F6);
  static const Color surface3 = Color(0xFFEAF5EF);
  static const Color border = Color(0xFFDDEDE5);
  static const Color border2 = Color(0xFFCCE2D8);
  static const Color primary = Color(0xFF2D6A4F);
  static const Color primaryLight = Color(0xFF52B788);
  static const Color primaryDark = Color(0xFF1B4332);
  static const Color success = Color(0xFF40C97A);
  static const Color error = Color(0xFFD94F4F);
  static const Color errorLight = Color(0xFFFFE8E8);
  static const Color warning = Color(0xFFF4A261);
  static const Color textDark = Color(0xFF1A2E25);
  static const Color textMid = Color(0xFF4A6B5A);
  static const Color textLight = Color(0xFF8BA899);
  static const Color textFaint = Color(0xFFB8D0C6);

  // ── Pastel Accents ──────────────────────────────────────────────────────────
  static const Color accentPink = Color(0xFFF7CEDE);
  static const Color accentPurple = Color(0xFFD9CEFF);
  static const Color accentMint = Color(0xFFBFEDD8);
  static const Color accentPeach = Color(0xFFFFDDC9);
  static const Color accentBlue = Color(0xFFC6E0FF);
  static const Color accentYellow = Color(0xFFFFF0C2);
  static const Color accentRose = Color(0xFFFFD6E0);
  static const Color accentSage = Color(0xFFD4EAD0);

  static const List<Color> gestureAccents = [
    accentPink,
    accentPurple,
    accentMint,
    accentPeach,
    accentBlue,
    accentYellow,
    accentPink,
    accentPurple,
  ];

  static const List<Color> quoteAccents = [
    accentPink,
    accentPurple,
    accentPeach,
    accentBlue,
    accentMint,
    accentYellow,
    accentRose,
    accentSage,
  ];

  static const List<Color> chipAccents = [
    accentMint,
    accentBlue,
    accentPurple,
    accentPink,
    accentPeach,
    accentYellow,
  ];

  // ── Typography ──────────────────────────────────────────────────────────────
  static TextStyle heading({
    double size = 22,
    FontWeight weight = FontWeight.w700,
    double spacing = -0.3,
    Color color = textDark,
    double height = 1.2,
  }) {
    return GoogleFonts.plusJakartaSans(
      fontSize: size,
      fontWeight: weight,
      letterSpacing: spacing,
      color: color,
      height: height,
    );
  }

  static TextStyle display({
    double size = 32,
    FontWeight weight = FontWeight.w800,
    double spacing = -0.8,
    Color color = textDark,
    double height = 1.1,
  }) {
    return GoogleFonts.plusJakartaSans(
      fontSize: size,
      fontWeight: weight,
      letterSpacing: spacing,
      color: color,
      height: height,
    );
  }

  static TextStyle body({
    double size = 14,
    FontWeight weight = FontWeight.w400,
    double spacing = 0.1,
    Color color = textMid,
    double height = 1.5,
  }) {
    return GoogleFonts.dmSans(
      fontSize: size,
      fontWeight: weight,
      letterSpacing: spacing,
      color: color,
      height: height,
    );
  }

  static TextStyle label({
    double size = 10,
    Color? color,
    FontWeight weight = FontWeight.w600,
    double spacing = 1.4,
  }) {
    return GoogleFonts.dmSans(
      fontSize: size,
      fontWeight: weight,
      letterSpacing: spacing,
      color: color ?? textLight,
    );
  }

  static TextStyle caption({
    double size = 11,
    Color? color,
    FontWeight weight = FontWeight.w400,
  }) {
    return GoogleFonts.dmSans(
      fontSize: size,
      fontWeight: weight,
      letterSpacing: 0.2,
      color: color ?? textLight,
      height: 1.4,
    );
  }

  static TextStyle buttonText({
    double size = 15,
    Color color = Colors.white,
  }) {
    return GoogleFonts.plusJakartaSans(
      fontSize: size,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.1,
      color: color,
    );
  }

  static TextStyle quoteText({
    double size = 16,
    Color color = textDark,
  }) {
    return GoogleFonts.plusJakartaSans(
      fontSize: size,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.2,
      color: color,
      height: 1.6,
      fontStyle: FontStyle.italic,
    );
  }

  // ── Card Decorations ─────────────────────────────────────────────────────────
  static BoxDecoration card({
    Color? color,
    double radius = 20,
    bool shadow = true,
    bool border = true,
  }) {
    return BoxDecoration(
      color: color ?? surface,
      borderRadius: BorderRadius.circular(radius),
      border: border ? Border.all(color: AppTheme.border, width: 1) : null,
      boxShadow: shadow
          ? [
              BoxShadow(
                color: const Color(0xFF2D6A4F).withOpacity(0.07),
                blurRadius: 24,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: const Color(0xFF2D6A4F).withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 1),
              ),
            ]
          : null,
    );
  }

  static BoxDecoration elevatedCard({Color? color, double radius = 24}) {
    return BoxDecoration(
      color: color ?? surface,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: border, width: 1),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF2D6A4F).withOpacity(0.12),
          blurRadius: 40,
          offset: const Offset(0, 12),
        ),
        BoxShadow(
          color: const Color(0xFF2D6A4F).withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  static BoxDecoration primaryCard({double radius = 22}) {
    return BoxDecoration(
      color: primary,
      borderRadius: BorderRadius.circular(radius),
      boxShadow: [
        BoxShadow(
          color: primary.withOpacity(0.35),
          blurRadius: 28,
          offset: const Offset(0, 10),
        ),
        BoxShadow(
          color: primary.withOpacity(0.15),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  static BoxDecoration accentCard({
    required Color color,
    double radius = 20,
  }) {
    return BoxDecoration(
      color: color.withOpacity(0.28),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: color, width: 1.2),
      boxShadow: [
        BoxShadow(
          color: color.withOpacity(0.2),
          blurRadius: 20,
          offset: const Offset(0, 6),
        ),
      ],
    );
  }

  static BoxDecoration pill({Color? color}) {
    return BoxDecoration(
      color: color ?? accentMint,
      borderRadius: BorderRadius.circular(100),
    );
  }

  static BoxDecoration pillBordered({Color? color, Color? borderColor}) {
    return BoxDecoration(
      color: color ?? accentMint,
      borderRadius: BorderRadius.circular(100),
      border: Border.all(
        color: borderColor ?? (color ?? accentMint).withOpacity(0.4),
        width: 1,
      ),
    );
  }

  static BoxDecoration iconContainer({
    required Color color,
    double radius = 14,
  }) {
    return BoxDecoration(
      color: color.withOpacity(0.5),
      borderRadius: BorderRadius.circular(radius),
    );
  }

  static BoxDecoration circle({required Color color}) {
    return BoxDecoration(color: color, shape: BoxShape.circle);
  }

  // ── Button Styles ────────────────────────────────────────────────────────────
  static ButtonStyle primaryButton({double radius = 16}) {
    return ElevatedButton.styleFrom(
      backgroundColor: primary,
      foregroundColor: Colors.white,
      elevation: 0,
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
      ),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
    );
  }

  static ButtonStyle secondaryButton({double radius = 16}) {
    return ElevatedButton.styleFrom(
      backgroundColor: surface2,
      foregroundColor: textMid,
      elevation: 0,
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
        side: const BorderSide(color: border, width: 1),
      ),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
    );
  }

  // ── Gradients ────────────────────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF52B788), Color(0xFF2D6A4F)],
  );

  static const LinearGradient bgGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFF0F7F3), Color(0xFFEDF4F0)],
  );

  // ── Spacing ──────────────────────────────────────────────────────────────────
  static const double spacingXS = 4;
  static const double spacingSM = 8;
  static const double spacingMD = 16;
  static const double spacingLG = 24;
  static const double spacingXL = 32;
  static const double spacingXXL = 48;

  // ── Radius ───────────────────────────────────────────────────────────────────
  static const double radiusSM = 10;
  static const double radiusMD = 16;
  static const double radiusLG = 20;
  static const double radiusXL = 28;
  static const double radiusXXL = 36;

  // ── Shadows ──────────────────────────────────────────────────────────────────
  static List<BoxShadow> get softShadow => [
        BoxShadow(
          color: const Color(0xFF2D6A4F).withOpacity(0.07),
          blurRadius: 24,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get strongShadow => [
        BoxShadow(
          color: const Color(0xFF2D6A4F).withOpacity(0.15),
          blurRadius: 40,
          offset: const Offset(0, 12),
        ),
        BoxShadow(
          color: const Color(0xFF2D6A4F).withOpacity(0.06),
          blurRadius: 10,
          offset: const Offset(0, 3),
        ),
      ];

  static List<BoxShadow> primaryShadow({double opacity = 0.35}) => [
        BoxShadow(
          color: primary.withOpacity(opacity),
          blurRadius: 28,
          offset: const Offset(0, 10),
        ),
        BoxShadow(
          color: primary.withOpacity(opacity * 0.4),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];
}
