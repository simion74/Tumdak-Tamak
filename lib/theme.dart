import 'package:flutter/material.dart';

/// Central place for the app's colors, gradients and text styles so every
/// page looks consistent. Tweak these values to gradually refine the look
/// without touching page code.
class AppColors {
  static const Color maroonDeep = Color(0xFF3A0508);
  static const Color maroon = Color(0xFF5C0B10);
  static const Color maroonLight = Color(0xFF7A1219);
  static const Color maroonBar = Color(0xFF4A0A0F);

  static const Color gold = Color(0xFFE9C46A);
  static const Color goldBright = Color(0xFFFFE9A8);
  static const Color goldDeep = Color(0xFFB8862E);

  static const List<Color> goldGradient = [goldBright, gold, goldDeep];

  static const Color panelDark = Color(0xFF23070A);
}

class AppGradients {
  static const BoxDecoration maroonBackground = BoxDecoration(
    gradient: RadialGradient(
      center: Alignment(0, -0.3),
      radius: 1.4,
      colors: [AppColors.maroonLight, AppColors.maroon, AppColors.maroonDeep],
      stops: [0.0, 0.55, 1.0],
    ),
  );

  static const LinearGradient topBar = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [AppColors.maroonLight, AppColors.maroonBar],
  );
}

/// A reusable gold "engraved" text style used for titles across the app.
/// Uses Playfair Display Black; if that font somehow fails to load, Flutter
/// falls back to the next entry in fontFamilyFallback (Times New Roman).
class GoldText extends StatelessWidget {
  final String text;
  final double fontSize;
  final double letterSpacing;
  final FontWeight fontWeight;

  const GoldText(
    this.text, {
    super.key,
    this.fontSize = 26,
    this.letterSpacing = 1.2,
    this.fontWeight = FontWeight.w800,
  });

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: AppColors.goldGradient,
      ).createShader(bounds),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'PlayfairDisplayBlack',
          fontFamilyFallback: const ['Times New Roman', 'serif'],
          fontSize: fontSize,
          fontWeight: fontWeight,
          letterSpacing: letterSpacing,
          color: Colors.white,
          shadows: const [
            Shadow(color: Colors.black87, offset: Offset(0, 2), blurRadius: 3),
          ],
        ),
      ),
    );
  }
}

/// The full ornamental title block used across the top bar: left flourish +
/// gold title + right flourish.
///
/// NOTE: this used to also draw a thin gold underline image below the title.
/// That underline was removed on purpose — it added extra vertical space to
/// every top bar, which is exactly what we're trying to shrink. The
/// `showUnderline` parameter is kept (defaulting to false / ignored) only so
/// any old call sites that still pass it don't break the build.
class OrnateTitle extends StatelessWidget {
  final String text;
  final double fontSize;
  final double flourishHeight;
  final bool showUnderline;

  const OrnateTitle(
    this.text, {
    super.key,
    this.fontSize = 30,
    this.flourishHeight = 26,
    this.showUnderline = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          'assets/images/decor/left_flourish.webp',
          height: flourishHeight,
        ),
        const SizedBox(width: 10),
        GoldText(text, fontSize: fontSize),
        const SizedBox(width: 10),
        Image.asset(
          'assets/images/decor/right_flourish.webp',
          height: flourishHeight,
        ),
      ],
    );
  }
}
