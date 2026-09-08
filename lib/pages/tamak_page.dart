import 'package:flutter/material.dart';
import '../widgets/app_top_bar.dart';
import '../widgets/touch_pad.dart';
import '../widgets/eq_side_panel.dart';
import '../widgets/record_sheet.dart';
import '../widgets/music_sheet.dart';
import '../pages/settings_page.dart';

class TamakPage extends StatefulWidget {
  const TamakPage({super.key});

  @override
  State<TamakPage> createState() => _TamakPageState();
}

class _TamakPageState extends State<TamakPage> {
  bool _eqOpen = false;

  // EQ opens as a slim side panel (not a blocking bottom sheet), so the pad
  // stays tappable while dragging a fader — see eq_side_panel.dart.
  void _toggleEq() => setState(() => _eqOpen = !_eqOpen);

  void _openSettings() {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SettingsPage()));
  }

  void _openRecord() {
    showRecordSheet(context, instrumentName: 'Tamak');
  }

  void _openMusic() {
    showMusicSheet(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Builder(
        builder: (context) => Container(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0, -0.1),
              radius: 1.2,
              colors: [Color(0xFF4A0A10), Color(0xFF230508)],
            ),
          ),
          child: Column(
            children: [
              AppTopBar(
                title: 'Tamak',
                onLeadingTap: () => Navigator.of(context).popUntil((r) => r.isFirst),
                actions: [
                  TopBarAction(
                    iconAsset: 'assets/images/icon/tune_icon.png',
                    label: 'EQ',
                    onTap: _toggleEq,
                    highlighted: _eqOpen,
                  ),
                  TopBarAction(
                    iconAsset: 'assets/images/icon/music_icon.png',
                    label: 'Music',
                    onTap: _openMusic,
                  ),
                  TopBarAction(
                    iconAsset: 'assets/images/icon/setting_icon.png',
                    label: 'Settings',
                    onTap: _openSettings,
                  ),
                  TopBarAction(
                    iconAsset: 'assets/images/icon/record_icon.png',
                    label: 'Record',
                    onTap: _openRecord,
                  ),
                ],
              ),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: Center(
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            // Fit the single big pad to whichever dimension is
                            // tighter, so it never overflows/scrolls on small
                            // screens, but also never looks absurdly small on a
                            // tall phone with lots of spare height. When the EQ
                            // panel is open, this Expanded's width shrinks
                            // automatically, so the pad simply gets smaller and
                            // sits further left — no extra logic needed here.
                            final size = constraints.maxWidth < constraints.maxHeight
                                ? constraints.maxWidth * 0.82
                                : constraints.maxHeight * 0.9;
                            final padSize = size.clamp(90.0, 320.0);
                            return TouchPad(
                              imageAsset: 'assets/images/tamak_touchpad.webp',
                              soundId: 'tamak',
                              size: padSize,
                            );
                          },
                        ),
                      ),
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeInOut,
                      width: _eqOpen ? kEqPanelWidth : 0,
                      child: ClipRect(
                        child: OverflowBox(
                          alignment: Alignment.centerRight,
                          minWidth: kEqPanelWidth,
                          maxWidth: kEqPanelWidth,
                          child: EqSidePanel(
                            title: 'Tamak — EQ',
                            channels: const [
                              EqChannel(soundId: 'tamak', title: 'Tamak Pad'),
                            ],
                            onClose: () => setState(() => _eqOpen = false),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
