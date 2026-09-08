import 'package:flutter/material.dart';
import '../theme.dart';

/// A square block with a raised, 3D "embossed" look — used for the four
/// home-page instrument blocks and for each Octapad pad.
///
/// [imageAsset] is drawn instead of a flat fill color, per the reference
/// design (each block shows its own icon image).
class EmbossSquare extends StatefulWidget {
  final String imageAsset;
  final String? label;
  final VoidCallback? onTap;
  final double borderRadius;
  final Color rimColor;

  const EmbossSquare({
    super.key,
    required this.imageAsset,
    this.label,
    this.onTap,
    this.borderRadius = 18,
    this.rimColor = AppColors.gold,
  });

  @override
  State<EmbossSquare> createState() => _EmbossSquareState();
}

class _EmbossSquareState extends State<EmbossSquare> {
  bool _pressed = false;

  void _setPressed(bool v) => setState(() => _pressed = v);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _setPressed(true),
      onTapCancel: () => _setPressed(false),
      onTapUp: (_) => _setPressed(false),
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 90),
        curve: Curves.easeOut,
        transform: Matrix4.identity()..scale(_pressed ? 0.95 : 1.0),
        transformAlignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 120,
              height: 120,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: _pressed
                      ? [const Color(0xFF1C1C1C), const Color(0xFF0A0A0A)]
                      : [const Color(0xFF2C2C2C), const Color(0xFF141414)],
                ),
                border: Border.all(color: widget.rimColor.withOpacity(0.8), width: 1.6),
                boxShadow: _pressed
                    ? [const BoxShadow(color: Colors.black87, blurRadius: 2, offset: Offset(0, 1))]
                    : [
                        const BoxShadow(color: Colors.black87, blurRadius: 10, offset: Offset(0, 6)),
                        BoxShadow(color: widget.rimColor.withOpacity(0.15), blurRadius: 12, spreadRadius: 1),
                      ],
              ),
              child: Image.asset(widget.imageAsset, fit: BoxFit.contain),
            ),
            if (widget.label != null) ...[
              const SizedBox(height: 8),
              GoldText(widget.label!, fontSize: 16, letterSpacing: 0.6),
            ],
          ],
        ),
      ),
    );
  }
}
