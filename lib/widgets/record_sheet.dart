import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import '../theme.dart';

/// The "RECORD" popup: record the instrument through the mic, preview the
/// take, then save it to the user's chosen storage location.
Future<void> showRecordSheet(BuildContext context, {required String instrumentName}) {
  return showModalBottomSheet(
    context: context,
    backgroundColor: AppColors.panelDark,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => _RecordSheetBody(instrumentName: instrumentName),
  );
}

enum _RecState { idle, recording, recorded }

class _RecordSheetBody extends StatefulWidget {
  final String instrumentName;
  const _RecordSheetBody({required this.instrumentName});

  @override
  State<_RecordSheetBody> createState() => _RecordSheetBodyState();
}

class _RecordSheetBodyState extends State<_RecordSheetBody> {
  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _preview = AudioPlayer(playerId: 'record_preview');

  _RecState _state = _RecState.idle;
  String? _filePath;
  bool _previewPlaying = false;
  Duration _elapsed = Duration.zero;
  DateTime? _startedAt;

  @override
  void dispose() {
    _recorder.dispose();
    _preview.dispose();
    super.dispose();
  }

  Future<void> _start() async {
    final hasPermission = await _recorder.hasPermission();
    if (!hasPermission) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Microphone permission required')),
      );
      return;
    }
    final dir = await getTemporaryDirectory();
    final path = '${dir.path}/tt_record_${DateTime.now().millisecondsSinceEpoch}.m4a';
    await _recorder.start(const RecordConfig(), path: path);
    setState(() {
      _state = _RecState.recording;
      _filePath = path;
      _startedAt = DateTime.now();
      _elapsed = Duration.zero;
    });
    _tick();
  }

  void _tick() {
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted || _state != _RecState.recording || _startedAt == null) return;
      setState(() => _elapsed = DateTime.now().difference(_startedAt!));
      _tick();
    });
  }

  Future<void> _stop() async {
    final path = await _recorder.stop();
    setState(() {
      _state = _RecState.recorded;
      _filePath = path ?? _filePath;
    });
  }

  Future<void> _togglePreview() async {
    if (_filePath == null) return;
    if (_previewPlaying) {
      await _preview.pause();
      setState(() => _previewPlaying = false);
    } else {
      await _preview.setSourceDeviceFile(_filePath!);
      await _preview.resume();
      setState(() => _previewPlaying = true);
      _preview.onPlayerComplete.first.then((_) {
        if (mounted) setState(() => _previewPlaying = false);
      });
    }
  }

  Future<void> _save() async {
    if (_filePath == null) return;
    final suggestedName =
        '${widget.instrumentName.toLowerCase()}_${DateTime.now().millisecondsSinceEpoch}.m4a';
    try {
      // file_picker's saveFile() behaves differently per platform, and we
      // need to handle both correctly:
      //  - Android: bytes is REQUIRED. Without it, saveFile() crashes or
      //    returns null on several Android versions (this is a known
      //    file_picker limitation, not a bug in this app).
      //  - iOS: bytes has NO effect — saveFile() only returns a path, and
      //    the app itself must write the bytes to that path.
      //  - Desktop (Windows/macOS/Linux): bytes is used directly and the
      //    file is written for us.
      // Reading the bytes once and handling both cases below (pass bytes
      // to satisfy Android + desktop, then manually write if iOS left the
      // file unwritten) covers every platform with one code path.
      final bytes = await File(_filePath!).readAsBytes();
      final savePath = await FilePicker.platform.saveFile(
        dialogTitle: 'Save Recording',
        fileName: suggestedName,
        type: FileType.custom,
        allowedExtensions: const ['m4a'],
        bytes: bytes,
      );
      if (savePath == null) return; // user cancelled
      // iOS (and, per file_picker's issue tracker, occasionally other
      // platform/version combos) returns a path without actually writing
      // the file — write it ourselves if that happened.
      final target = File(savePath);
      if (!await target.exists()) {
        await target.writeAsBytes(bytes);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Saved: $savePath')),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save: $e')),
      );
    }
  }

  void _discard() {
    setState(() {
      _state = _RecState.idle;
      _filePath = null;
      _elapsed = Duration.zero;
    });
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
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
                const Icon(Icons.fiber_manual_record_rounded, color: Colors.redAccent),
                const SizedBox(width: 8),
                GoldText('Record ${widget.instrumentName}', fontSize: 18),
              ],
            ),
            const SizedBox(height: 18),
            Center(
              child: Text(
                _fmt(_elapsed),
                style: const TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(height: 18),
            if (_state == _RecState.idle)
              _BigButton(
                icon: Icons.fiber_manual_record_rounded,
                label: 'Start Recording',
                color: Colors.redAccent,
                onTap: _start,
              ),
            if (_state == _RecState.recording)
              _BigButton(
                icon: Icons.stop_rounded,
                label: 'Stop',
                color: AppColors.gold,
                onTap: _stop,
              ),
            if (_state == _RecState.recorded) ...[
              Row(
                children: [
                  Expanded(
                    child: _BigButton(
                      icon: _previewPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                      label: _previewPlaying ? 'Pause' : 'Listen',
                      color: AppColors.gold,
                      onTap: _togglePreview,
                      compact: true,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _BigButton(
                      icon: Icons.save_alt_rounded,
                      label: 'Save',
                      color: Colors.greenAccent.shade400,
                      onTap: _save,
                      compact: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              TextButton.icon(
                onPressed: _discard,
                icon: const Icon(Icons.delete_outline, color: Colors.white54),
                label: const Text('Discard & Record Again', style: TextStyle(color: Colors.white54)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _BigButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool compact;

  const _BigButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, color: Colors.black),
      label: Text(label, style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.black)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: EdgeInsets.symmetric(vertical: 14, horizontal: compact ? 10 : 22),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        minimumSize: compact ? null : const Size.fromHeight(48),
      ),
    );
  }
}
