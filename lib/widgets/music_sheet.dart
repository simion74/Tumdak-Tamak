import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../theme.dart';
import '../services/sound_service.dart';

/// The "MUSIC" popup: pick a song from the device and play/pause/stop it
/// underneath the drumming, with its own volume slider.
Future<void> showMusicSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    backgroundColor: AppColors.panelDark,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => const _MusicSheetBody(),
  );
}

class _MusicSheetBody extends StatefulWidget {
  const _MusicSheetBody();

  @override
  State<_MusicSheetBody> createState() => _MusicSheetBodyState();
}

class _MusicSheetBodyState extends State<_MusicSheetBody> {
  bool _loaded = false;
  bool _playing = false;
  double _volume = 1.0;
  String? _fileName;

  @override
  void initState() {
    super.initState();
    _playing = SoundService.instance.isMusicPlaying;
    _loaded = _playing;
  }

  Future<void> _pick() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.audio);
    final file = result?.files.single;
    if (file?.path == null) return;
    await SoundService.instance.playMusic(file!.path!);
    setState(() {
      _loaded = true;
      _playing = true;
      _fileName = file.name;
    });
  }

  Future<void> _togglePlayPause() async {
    if (!_loaded) {
      await _pick();
      return;
    }
    await SoundService.instance.toggleMusicPlayPause();
    setState(() => _playing = !_playing);
  }

  Future<void> _stop() async {
    await SoundService.instance.stopMusic();
    setState(() {
      _loaded = false;
      _playing = false;
      _fileName = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.music_note_rounded, color: AppColors.gold),
                const SizedBox(width: 8),
                const GoldText('Music', fontSize: 18),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _fileName ?? 'No track selected',
              style: const TextStyle(color: Colors.white70, fontSize: 13),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _pick,
                    icon: const Icon(Icons.folder_open_rounded, color: Colors.black),
                    label: const Text('Choose a Track', style: TextStyle(color: Colors.black)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.gold,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton.filled(
                  onPressed: _loaded ? _togglePlayPause : null,
                  icon: Icon(_playing ? Icons.pause_rounded : Icons.play_arrow_rounded),
                  style: IconButton.styleFrom(backgroundColor: AppColors.goldDeep, foregroundColor: Colors.black),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: _loaded ? _stop : null,
                  icon: const Icon(Icons.stop_rounded),
                  style: IconButton.styleFrom(backgroundColor: Colors.black26, foregroundColor: Colors.white70),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                const Icon(Icons.volume_up_rounded, color: Colors.white54, size: 18),
                Expanded(
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: AppColors.gold,
                      inactiveTrackColor: Colors.white24,
                      thumbColor: AppColors.goldBright,
                    ),
                    child: Slider(
                      value: _volume,
                      onChanged: (v) {
                        setState(() => _volume = v);
                        SoundService.instance.setMusicVolume(v);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
