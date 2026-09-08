import 'package:flutter/material.dart';
import '../services/sound_service.dart';

/// A tappable drum-head image. Uses [onTapDown] (not onTap) so the sound
/// fires the instant a finger touches the screen — no waiting for a
/// release/tap-up — which is what keeps hand-drum apps feeling responsive.
class TouchPad extends StatefulWidget {
  final String imageAsset;
  final String soundId;
  final double size;

  const TouchPad({
    super.key,
    required this.imageAsset,
    required this.soundId,
    this.size = 260,
  });

  @override
  State<TouchPad> createState() => _TouchPadState();
}

class _TouchPadState extends State<TouchPad> {
  bool _pressed = false;

  void _hit() {
    setState(() => _pressed = true);
    SoundService.instance.play(widget.soundId);
    Future.delayed(const Duration(milliseconds: 90), () {
      if (mounted) setState(() => _pressed = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _hit(),
      child: AnimatedScale(
        scale: _pressed ? 0.94 : 1.0,
        duration: const Duration(milliseconds: 70),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 90),
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(_pressed ? 0.2 : 0.55),
                blurRadius: _pressed ? 8 : 22,
                spreadRadius: _pressed ? 0 : 2,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Image.asset(widget.imageAsset, fit: BoxFit.contain),
        ),
      ),
    );
  }
}
