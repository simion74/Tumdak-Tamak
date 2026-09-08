import 'dart:ui';
import 'package:flutter/material.dart';
import '../services/local_store.dart';
import '../widgets/app_top_bar.dart';
import '../widgets/touch_pad.dart';
import '../widgets/eq_side_panel.dart';
import '../widgets/record_sheet.dart';
import '../widgets/music_sheet.dart';
import '../widgets/pad_edit_sheet.dart';
import '../pages/settings_page.dart';

class TumdakPage extends StatefulWidget {
  const TumdakPage({super.key});

  @override
  State<TumdakPage> createState() => _TumdakPageState();
}

class _TumdakPageState extends State<TumdakPage> {
  bool _swapped = false;
  bool _eqOpen = false;

  @override
  void initState() {
    super.initState();
    LocalStore.instance.getTumdakSwapped().then((value) {
      if (mounted) setState(() => _swapped = value);
    });
  }

  Future<void> _openEdit() async {
    final result = await showPadEditSheet(context, currentlySwapped: _swapped);
    if (result == null) return;
    setState(() => _swapped = result);
    await LocalStore.instance.setTumdakSwapped(result);
  }

  // EQ now opens as a slim side panel (not a blocking bottom sheet), so the
  // pads stay tappable while dragging a fader — see eq_side_panel.dart.
  void _toggleEq() => setState(() => _eqOpen = !_eqOpen);

  void _openSettings() {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SettingsPage()));
  }

  void _openRecord() {
    showRecordSheet(context, instrumentName: 'Tumdak');
  }

  void _openMusic() {
    showMusicSheet(context);
  }

  @override
  Widget build(BuildContext context) {
    final leftAsset = _swapped ? 'assets/images/tumdak_touchpad_2.webp' : 'assets/images/tumdak_touchpad_1.webp';
    final rightAsset = _swapped ? 'assets/images/tumdak_touchpad_1.webp' : 'assets/images/tumdak_touchpad_2.webp';
    final leftSound = _swapped ? 'tumdak_right' : 'tumdak_left';
    final rightSound = _swapped ? 'tumdak_left' : 'tumdak_right';

    return Scaffold(
      body: Builder(
        builder: (context) => Stack(
          fit: StackFit.expand,
          children: [
            // blurred background
            Image.asset('assets/images/tumdak_bg.webp', fit: BoxFit.cover),
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
              child: Container(color: Colors.black.withOpacity(0.35)),
            ),
            Column(
              children: [
                AppTopBar(
                  title: 'Tumdak',
                  onLeadingTap: () => Navigator.of(context).popUntil((r) => r.isFirst),
                  actions: [
                    TopBarAction(
                      iconAsset: 'assets/images/icon/edit_icon.png',
                      label: 'Edit',
                      onTap: _openEdit,
                    ),
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
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            // Two pads side by side must fit on ANY screen with no
                            // scrolling — small phones especially. Size each pad
                            // off whichever is tighter, the available width split
                            // in two, or the available height, then clamp so it
                            // never looks too tiny or comically huge on tablets.
                            // When the EQ panel is open, this Expanded's width
                            // shrinks automatically, so the pads simply get
                            // smaller and sit further left — no extra logic
                            // needed here.
                            const spacing = 16.0;
                            const sidePadding = 24.0;
                            final maxByWidth = (constraints.maxWidth - spacing - sidePadding * 2) / 2;
                            final maxByHeight = constraints.maxHeight - 16;
                            final size = maxByWidth < maxByHeight ? maxByWidth : maxByHeight;
                            final padSize = size.clamp(80.0, 260.0);
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                TouchPad(
                                  key: ValueKey('left_$leftSound'),
                                  imageAsset: leftAsset,
                                  soundId: leftSound,
                                  size: padSize,
                                ),
                                TouchPad(
                                  key: ValueKey('right_$rightSound'),
                                  imageAsset: rightAsset,
                                  soundId: rightSound,
                                  size: padSize,
                                ),
                              ],
                            );
                          },
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
                              title: 'Tumdak — EQ',
                              channels: [
                                EqChannel(soundId: leftSound, title: 'বাম প্যাড'),
                                EqChannel(soundId: rightSound, title: 'ডান প্যাড'),
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
          ],
        ),
      ),
    );
  }
}
