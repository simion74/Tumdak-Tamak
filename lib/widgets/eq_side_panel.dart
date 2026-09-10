import 'package:flutter/material.dart';
import '../theme.dart';
import '../services/sound_service.dart';

/// One channel (e.g. "Left Pad / Thick" or "Right Pad / Thin") shown inside
/// the EQ side panel, tied to a single [soundId] in [SoundService].
class EqChannel {
  final String soundId;
  final String title;
  const EqChannel({required this.soundId, required this.title});
}

/// Fixed width of the panel when open. Kept in one place so pages can size
/// their [AnimatedContainer] wrapper identically.
const double kEqPanelWidth = 196.0;

/// A slim, always-embedded (never modal) EQ control strip meant to sit on
/// the right edge of Tumdak/Tamak, with the touchpad(s) shrinking to make
/// room on the left. Because it's not a bottom sheet, nothing blocks touch
/// events on the pad — the user can drag a fader with one hand and tap the
/// pad with the other (or the same hand, alternating) to hear the change
/// live, exactly like riding a fader on a real mixer while the drummer
/// keeps playing.
class EqSidePanel extends StatefulWidget {
  final String title;
  final List<EqChannel> channels;
  final VoidCallback onClose;

  const EqSidePanel({
    super.key,
    required this.title,
    required this.channels,
    required this.onClose,
  });

  @override
  State<EqSidePanel> createState() => _EqSidePanelState();
}

class _EqSidePanelState extends State<EqSidePanel> {
  int _activeChannel = 0;
  late Map<String, Map<String, double>> _eqBySound;

  @override
  void initState() {
    super.initState();
    _eqBySound = {
      for (final ch in widget.channels) ch.soundId: Map.of(SoundService.instance.eqFor(ch.soundId)),
    };
  }

  @override
  void didUpdateWidget(covariant EqSidePanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Channels can change (e.g. Tumdak's Left/Right swap via Edit) while the
    // panel stays open — keep our local snapshot in sync with reality.
    for (final ch in widget.channels) {
      _eqBySound.putIfAbsent(ch.soundId, () => Map.of(SoundService.instance.eqFor(ch.soundId)));
    }
  }

  void _update(String soundId, String key, double value) {
    setState(() => _eqBySound[soundId]![key] = value);
    SoundService.instance.setEq(
      soundId,
      volume: key == 'volume' ? value : null,
      rate: key == 'rate' ? value : null,
      echo: key == 'echo' ? value : null,
      reverb: key == 'reverb' ? value : null,
    );
  }

  void _reset(String soundId) {
    const defaults = {'volume': 1.0, 'rate': 1.0, 'echo': 0.0, 'reverb': 0.0};
    setState(() => _eqBySound[soundId] = Map.of(defaults));
    SoundService.instance.setEq(soundId, volume: 1.0, rate: 1.0, echo: 0.0, reverb: 0.0);
  }

  void _test(String soundId) => SoundService.instance.play(soundId);

  @override
  Widget build(BuildContext context) {
    final channel = widget.channels[_activeChannel.clamp(0, widget.channels.length - 1)];
    final eq = _eqBySound[channel.soundId] ?? const {'volume': 1.0, 'rate': 1.0, 'echo': 0.0, 'reverb': 0.0};

    return Container(
      width: kEqPanelWidth,
      decoration: BoxDecoration(
        color: AppColors.panelDark,
        border: Border(left: BorderSide(color: AppColors.gold.withOpacity(0.4), width: 1.2)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.45), blurRadius: 14, offset: const Offset(-3, 0))],
      ),
      child: SafeArea(
        left: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 4, 2),
              child: Row(
                children: [
                  const Icon(Icons.equalizer_rounded, color: AppColors.gold, size: 15),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      widget.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.w700, fontSize: 12),
                    ),
                  ),
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 26, minHeight: 26),
                    visualDensity: VisualDensity.compact,
                    onPressed: widget.onClose,
                    tooltip: 'Close',
                    icon: const Icon(Icons.close_rounded, color: Colors.white70, size: 18),
                  ),
                ],
              ),
            ),
            if (widget.channels.length > 1)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                child: Row(
                  children: [
                    for (var i = 0; i < widget.channels.length; i++)
                      Expanded(
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => setState(() => _activeChannel = i),
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            decoration: BoxDecoration(
                              color: i == _activeChannel ? AppColors.gold.withOpacity(0.25) : Colors.black26,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: i == _activeChannel ? AppColors.goldBright : AppColors.gold.withOpacity(0.3),
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              widget.channels[i].title,
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: i == _activeChannel ? AppColors.goldBright : Colors.white70,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            const SizedBox(height: 6),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 6),
              child: Text(
                'Tap the touchpad beside it to hear live',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white38, fontSize: 9.5),
              ),
            ),
            const SizedBox(height: 4),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: _VerticalFader(
                      label: 'Volume',
                      value: eq['volume']!,
                      min: 0.0,
                      max: 1.5,
                      topHint: '+',
                      bottomHint: '\u2212',
                      onChanged: (v) => _update(channel.soundId, 'volume', v),
                    ),
                  ),
                  Expanded(
                    child: _VerticalFader(
                      label: 'Tone',
                      value: eq['rate']!,
                      min: 0.7,
                      max: 1.3,
                      topHint: 'Thin',
                      bottomHint: 'Thick',
                      onChanged: (v) => _update(channel.soundId, 'rate', v),
                    ),
                  ),
                  Expanded(
                    child: _VerticalFader(
                      label: 'Echo',
                      value: eq['echo']!,
                      min: 0.0,
                      max: 1.0,
                      topHint: 'More',
                      bottomHint: 'Less',
                      onChanged: (v) => _update(channel.soundId, 'echo', v),
                    ),
                  ),
                  Expanded(
                    child: _VerticalFader(
                      label: 'Hall',
                      value: eq['reverb']!,
                      min: 0.0,
                      max: 1.0,
                      topHint: 'More',
                      bottomHint: 'Less',
                      onChanged: (v) => _update(channel.soundId, 'reverb', v),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 10),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _test(channel.soundId),
                      icon: const Icon(Icons.play_arrow_rounded, size: 16, color: AppColors.goldBright),
                      label: const Text('TEST', style: TextStyle(fontSize: 10.5)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.goldBright,
                        side: BorderSide(color: AppColors.gold.withOpacity(0.5)),
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  IconButton(
                    onPressed: () => _reset(channel.soundId),
                    icon: const Icon(Icons.restart_alt_rounded, color: Colors.white54, size: 18),
                    tooltip: 'Reset',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A mixer-style vertical fader: drag up to increase, down to decrease —
/// built by rotating a normal [Slider] 270° so its native left(min)/
/// right(max) gesture axis becomes bottom(min)/top(max).
class _VerticalFader extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final String topHint;
  final String bottomHint;
  final ValueChanged<double> onChanged;

  const _VerticalFader({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.topHint,
    required this.bottomHint,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        Text(topHint, style: const TextStyle(color: Colors.white38, fontSize: 8.5, fontWeight: FontWeight.w600)),
        Expanded(
          child: RotatedBox(
            quarterTurns: 3,
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: AppColors.gold,
                inactiveTrackColor: Colors.white24,
                thumbColor: AppColors.goldBright,
                overlayColor: AppColors.gold.withOpacity(0.2),
                trackHeight: 3,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6.5),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
              ),
              child: Slider(
                value: value.clamp(min, max),
                min: min,
                max: max,
                onChanged: onChanged,
              ),
            ),
          ),
        ),
        Text(bottomHint, style: const TextStyle(color: Colors.white38, fontSize: 8.5, fontWeight: FontWeight.w600)),
        const SizedBox(height: 3),
        Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Colors.white70, fontSize: 9.5, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}
