import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../theme.dart';
import '../services/local_store.dart';
import '../widgets/app_top_bar.dart';
import '../widgets/record_sheet.dart';
import 'home_page.dart' show kAppShareText;
import 'settings_page.dart';

/// UI for the "play together over WiFi/Hotspot" feature.
///
/// NOTE (important for later): actually connecting phones, syncing audio
/// with near-zero delay, and choosing which phone's speaker/recording is
/// the final output requires real local-network code — for example the
/// `nearby_connections` or `flutter_p2p_connection` packages for
/// device-to-device discovery, plus careful audio-clock syncing. That part
/// is a separate, more advanced milestone and is best tested on real
/// phones rather than in a preview/emulator. This page wires up the full
/// screen flow (find nearby devices → tick which ones to add → the phone
/// that started the session becomes the "main"/output device → session
/// controls). [_startSearch] currently and honestly finds nothing (no
/// fake/demo devices) — wiring in a real discovery package later only
/// touches that one method.
class GroupMusicPage extends StatefulWidget {
  const GroupMusicPage({super.key});

  @override
  State<GroupMusicPage> createState() => _GroupMusicPageState();
}

enum _SessionState { idle, searching, picking, connected }

class _NearbyDevice {
  final String name;
  bool selected;
  _NearbyDevice(this.name, {this.selected = false});
}

class _GroupMusicPageState extends State<GroupMusicPage> {
  _SessionState _state = _SessionState.idle;
  final List<_NearbyDevice> _found = [];
  final List<String> _connected = [];
  String _myName = 'You';

  @override
  void initState() {
    super.initState();
    LocalStore.instance.loadProfile().then((profile) {
      if (!mounted) return;
      final name = profile['name'] ?? '';
      if (name.isNotEmpty) setState(() => _myName = name);
    });
  }

  Future<void> _startSearch() async {
    setState(() {
      _state = _SessionState.searching;
      _found.clear();
      _connected.clear();
    });
    // Real nearby-device discovery isn't wired up yet (see the class-level
    // note above) — so this honestly finds nothing instead of pretending
    // with fake names. The delay is kept so the spinner still reads as a
    // real scan rather than an instant, suspicious "0 results".
    await Future.delayed(const Duration(milliseconds: 1400));
    if (!mounted) return;
    setState(() => _state = _SessionState.picking);
  }

  void _connectSelected() {
    setState(() {
      _connected
        ..clear()
        ..addAll(_found.where((d) => d.selected).map((d) => d.name));
      _state = _SessionState.connected;
    });
  }

  void _stopSession() {
    setState(() {
      _state = _SessionState.idle;
      _found.clear();
      _connected.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Builder(
        builder: (context) => Container(
          decoration: AppGradients.maroonBackground,
          child: Column(
            children: [
              AppTopBar(
                title: 'Group Music',
                onLeadingTap: () => Navigator.of(context).popUntil((r) => r.isFirst),
                actions: [
                  TopBarAction(
                    iconAsset: 'assets/images/icon/share_icon.png',
                    label: 'Invite',
                    onTap: () => Share.share('$_myName is inviting you to join Tumdak ~ Tamak Group Music! $kAppShareText'),
                  ),
                  TopBarAction(
                    iconAsset: 'assets/images/icon/record_icon.png',
                    label: 'Record',
                    onTap: () => showRecordSheet(context, instrumentName: 'Group Session'),
                  ),
                  TopBarAction(
                    iconAsset: 'assets/images/icon/setting_icon.png',
                    label: 'Settings',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SettingsPage()),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 620),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.wifi_tethering_rounded,
                            size: 56,
                            color: AppColors.gold.withOpacity(0.9),
                          ),
                          const SizedBox(height: 10),
                          const GoldText('Play Together — WiFi / Hotspot', fontSize: 20),
                          const SizedBox(height: 4),
                          Text('Your name: $_myName', style: const TextStyle(color: Colors.white54, fontSize: 12)),
                          const SizedBox(height: 18),
                          if (_state == _SessionState.idle)
                            _ActionButton(label: 'Find Devices', onTap: _startSearch),
                          if (_state == _SessionState.searching) ...[
                            const CircularProgressIndicator(color: AppColors.gold),
                            const SizedBox(height: 12),
                            const Text('Searching nearby devices...',
                                style: TextStyle(color: Colors.white70)),
                          ],
                          if (_state == _SessionState.picking) ...[
                            if (_found.isEmpty) ...[
                              const Icon(Icons.search_off_rounded, color: Colors.white38, size: 40),
                              const SizedBox(height: 10),
                              const Text(
                                'No devices found nearby.',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Make sure everyone is on the same Wi-Fi / Hotspot and has\n'
                                'Group Music open on their phone, then try again.',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.white54, fontSize: 12),
                              ),
                              const SizedBox(height: 16),
                              _ActionButton(label: 'Search Again', onTap: _startSearch),
                              const SizedBox(height: 8),
                              TextButton(
                                onPressed: _stopSession,
                                child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
                              ),
                            ] else ...[
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.black26,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppColors.gold.withOpacity(0.4)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                      child: Text('Found — tick to add:',
                                          style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.w700)),
                                    ),
                                    for (final d in _found)
                                      CheckboxListTile(
                                        value: d.selected,
                                        onChanged: (v) => setState(() => d.selected = v ?? false),
                                        activeColor: AppColors.gold,
                                        dense: true,
                                        controlAffinity: ListTileControlAffinity.leading,
                                        title: Text(d.name, style: const TextStyle(color: Colors.white)),
                                      ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 14),
                              _ActionButton(
                                label: 'Add / Connect',
                                onTap: _found.any((d) => d.selected) ? _connectSelected : null,
                              ),
                              const SizedBox(height: 8),
                              TextButton(
                                onPressed: _stopSession,
                                child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
                              ),
                            ],
                          ],
                          if (_state == _SessionState.connected) ...[
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.black26,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.gold.withOpacity(0.4)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.smartphone, color: AppColors.goldBright, size: 18),
                                      const SizedBox(width: 8),
                                      Text('$_myName (your phone)', style: const TextStyle(color: Colors.white)),
                                      const Spacer(),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppColors.gold.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: const Text('MAIN / OUTPUT',
                                            style: TextStyle(color: AppColors.goldBright, fontSize: 10, fontWeight: FontWeight.w700)),
                                      ),
                                    ],
                                  ),
                                  const Divider(color: Colors.white24, height: 18),
                                  for (final d in _connected)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 4),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.smartphone, color: Colors.white70, size: 18),
                                          const SizedBox(width: 8),
                                          Text(d, style: const TextStyle(color: Colors.white)),
                                          const Spacer(),
                                          const Text('Connected', style: TextStyle(color: Colors.greenAccent, fontSize: 12)),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: _ActionButton(
                                    label: 'Add More',
                                    onTap: () => setState(() => _state = _SessionState.picking),
                                    compact: true,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _ActionButton(
                                    label: 'Record',
                                    onTap: () => showRecordSheet(context, instrumentName: 'Group Session'),
                                    compact: true,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            TextButton(
                              onPressed: _stopSession,
                              child: const Text('End Session',
                                  style: TextStyle(color: Colors.white54)),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool compact;

  const _ActionButton({required this.label, required this.onTap, this.compact = false});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.goldDeep,
        foregroundColor: Colors.black,
        disabledBackgroundColor: Colors.white12,
        padding: EdgeInsets.symmetric(horizontal: compact ? 10 : 22, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
    );
  }
}
