import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../theme.dart';
import '../services/sound_service.dart';
import '../services/local_store.dart';
import '../models/octapad_patch.dart';
import '../widgets/record_sheet.dart';

class OctapadPage extends StatefulWidget {
  const OctapadPage({super.key});

  @override
  State<OctapadPage> createState() => _OctapadPageState();
}

class _OctapadPageState extends State<OctapadPage> {
  // Patches you can pick from the TUNE list. Starts with the built-in ones;
  // packages loaded via the ADD SOUND button are appended here at runtime.
  final List<OctapadPatch> _patches = List.of(kOctapadPatches);
  int _customPatchCount = 0;

  int _activePatchIndex = 0;
  late List<PadSound> _pads = List.of(_patches[_activePatchIndex].pads);

  bool _editMode = false;
  bool _musicLoaded = false;
  bool _musicPlaying = false;

  // Bumped every time a pad is hit; used as a TweenAnimationBuilder key so
  // the "light" flash restarts cleanly on every tap, even rapid ones.
  final List<int> _hitTick = List.filled(8, 0);

  @override
  void initState() {
    super.initState();
    _restoreSavedLayouts();
  }

  /// Any pad rearranging or per-pad sound swapping the user did in Edit
  /// mode gets saved (see [_setEditMode]) — this loads those back in on
  /// startup, so a built-in patch's factory KICK/SNARE/HAT-C/HAT-O/TOM/
  /// CRASH/CLAP/RIM layout is only the *default*, not something that resets
  /// every time you reopen the app.
  Future<void> _restoreSavedLayouts() async {
    for (var i = 0; i < _patches.length; i++) {
      final saved = await LocalStore.instance.getPatchLayout(_patches[i].id);
      if (saved == null || saved.length != 8) continue;
      final pads = saved.map((e) => PadSound(e['label']!, e['soundId']!)).toList();
      _patches[i] = OctapadPatch(id: _patches[i].id, name: _patches[i].name, pads: pads);
    }
    if (!mounted) return;
    setState(() => _pads = List.of(_patches[_activePatchIndex].pads));
  }

  void _hit(int index) {
    setState(() => _hitTick[index]++);
    SoundService.instance.play(_pads[index].soundId);
  }

  void _swap(int a, int b) {
    setState(() {
      final tmp = _pads[a];
      _pads[a] = _pads[b];
      _pads[b] = tmp;
    });
  }

  void _selectPatch(int index) {
    setState(() {
      _activePatchIndex = index;
      _pads = List.of(_patches[index].pads);
    });
  }

  void _cyclePatch(int direction) {
    final next = (_activePatchIndex + direction) % _patches.length;
    _selectPatch(next < 0 ? next + _patches.length : next);
  }

  /// Turning Edit mode OFF (DONE) is the save point: whatever the pads look
  /// like right now — reordered, and/or with individual sounds swapped via
  /// the per-pad picker — becomes this patch's layout from now on, both in
  /// this session and (via LocalStore) after an app restart.
  void _setEditMode(bool value) {
    setState(() => _editMode = value);
    if (!value) {
      final current = _patches[_activePatchIndex];
      _patches[_activePatchIndex] = OctapadPatch(id: current.id, name: current.name, pads: List.of(_pads));
      LocalStore.instance.savePatchLayout(
        current.id,
        _pads.map((p) => {'label': p.label, 'soundId': p.soundId}).toList(),
      );
    }
  }

  /// Edit-mode tap-on-a-pad (not drag): opens a picker of every sound from
  /// every built-in kit, so a pad can be assigned any sound at all — not
  /// just the 8 that came with the currently-selected patch. This is how
  /// you build your own custom arrangement for new music, professional
  /// style, instead of only being able to reorder the existing 8.
  Future<void> _openSoundPicker(int padIndex) async {
    final chosen = await showModalBottomSheet<LibrarySound>(
      context: context,
      backgroundColor: AppColors.panelDark,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) {
        return SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.75),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GoldText('Choose a Sound — Pad ${padIndex + 1}', fontSize: 18),
                  const SizedBox(height: 4),
                  const Text(
                    'Pick any sound from any kit, or load your own file',
                    style: TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                  const SizedBox(height: 10),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.upload_file_rounded, color: AppColors.goldBright),
                    title: const Text('Upload a sound from this device', style: TextStyle(color: AppColors.goldBright, fontWeight: FontWeight.w700)),
                    onTap: () => Navigator.of(context).pop(),
                    trailing: const Icon(Icons.chevron_right_rounded, color: Colors.white38),
                  ),
                  const Divider(color: Colors.white24, height: 18),
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: kAllLibrarySounds.length,
                      itemBuilder: (context, i) {
                        final s = kAllLibrarySounds[i];
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                          title: Text(s.displayName, style: const TextStyle(color: Colors.white)),
                          trailing: IconButton(
                            icon: const Icon(Icons.play_circle_fill_rounded, color: AppColors.goldBright),
                            tooltip: 'Preview',
                            onPressed: () => SoundService.instance.play(s.soundId),
                          ),
                          onTap: () => Navigator.of(context).pop(s),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    if (chosen != null) {
      setState(() => _pads[padIndex] = PadSound(chosen.label, chosen.soundId));
      return;
    }

    // User tapped "Upload a sound from this device" (popped with null via
    // that ListTile) — fall through to the file picker for this one pad.
    await _uploadSoundForPad(padIndex);
  }

  Future<void> _uploadSoundForPad(int padIndex) async {
    final result = await FilePicker.platform.pickFiles(type: FileType.audio);
    final file = result?.files.single;
    final path = file?.path;
    if (path == null) return;
    final soundId = '${_patches[_activePatchIndex].id}_custom_pad${padIndex}_${DateTime.now().millisecondsSinceEpoch}';
    await SoundService.instance.registerDeviceSound(soundId, path);
    final rawName = file!.name.split('.').first.toUpperCase();
    final label = rawName.length > 6 ? rawName.substring(0, 6) : rawName;
    if (!mounted) return;
    setState(() => _pads[padIndex] = PadSound(label.isEmpty ? 'PAD ${padIndex + 1}' : label, soundId));
  }

  /// ADD SOUND: lets the user pick up to 8 of their own sound files from the
  /// device and turns them into a brand-new patch, added to the TUNE list.
  Future<void> _addSoundPackage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
      allowMultiple: true,
    );
    if (result == null || result.files.isEmpty) return;

    final files = result.files.take(8).toList();
    _customPatchCount++;
    final patchId = 'custom_$_customPatchCount';
    final pads = <PadSound>[];
    for (var i = 0; i < files.length; i++) {
      final file = files[i];
      final path = file.path;
      if (path == null) continue;
      final soundId = '${patchId}_pad$i';
      await SoundService.instance.registerDeviceSound(soundId, path);
      final rawName = file.name.split('.').first.toUpperCase();
      final label = rawName.length > 6 ? rawName.substring(0, 6) : rawName;
      pads.add(PadSound(label.isEmpty ? 'PAD ${i + 1}' : label, soundId));
    }
    // Pad out to 8 slots by repeating the last uploaded sound, so the grid
    // always has something to trigger even if fewer than 8 files were picked.
    while (pads.isNotEmpty && pads.length < 8) {
      pads.add(pads[pads.length % pads.length]);
    }
    if (pads.isEmpty) return;

    if (!mounted) return;
    setState(() {
      _patches.add(OctapadPatch(id: patchId, name: 'My Package $_customPatchCount', pads: pads));
      _selectPatch(_patches.length - 1);
    });
  }

  /// MUSIC: lets the user pick a song from the device to play underneath
  /// their drumming. Playback itself is controlled by the PLAY/PAUSE button.
  Future<void> _pickMusic() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.audio);
    final path = result?.files.single.path;
    if (path == null) return;
    await SoundService.instance.playMusic(path);
    if (!mounted) return;
    setState(() {
      _musicLoaded = true;
      _musicPlaying = true;
    });
  }

  Future<void> _toggleMusicPlayPause() async {
    if (!_musicLoaded) {
      // No track picked yet — MUSIC button doubles as "pick a track" first.
      await _pickMusic();
      return;
    }
    await SoundService.instance.toggleMusicPlayPause();
    setState(() => _musicPlaying = !_musicPlaying);
  }

  void _openTuneSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.panelDark,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.35,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return SafeArea(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
                children: [
                  const GoldText('Choose Sound Package', fontSize: 18),
                  const SizedBox(height: 4),
                  Text(
                    '${_patches.length} packages available — tap a name to select it, '
                    'tap the \u25B6 button beside it to preview first',
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                  const SizedBox(height: 10),
                  for (int i = 0; i < _patches.length; i++)
                    _PatchRow(
                      name: _patches[i].name,
                      selected: i == _activePatchIndex,
                      onSelect: () {
                        _selectPatch(i);
                        Navigator.of(context).pop();
                      },
                      onPreview: () {
                        SoundService.instance.play(_patches[i].pads.first.soundId);
                      },
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: AppGradients.maroonBackground,
        child: SafeArea(
          child: Column(
            children: [
              _Toolbar(
                patchName: _patches[_activePatchIndex].name,
                editMode: _editMode,
                musicLoaded: _musicLoaded,
                musicPlaying: _musicPlaying,
                onHome: () => Navigator.of(context).popUntil((r) => r.isFirst),
                onPrevPatch: () => _cyclePatch(-1),
                onNextPatch: () => _cyclePatch(1),
                onPatchTap: _openTuneSheet,
                onTune: _openTuneSheet,
                onEditToggle: () => _setEditMode(!_editMode),
                onMusic: _pickMusic,
                onUpload: _addSoundPackage,
                onRecord: () => showRecordSheet(context, instrumentName: 'Octapad'),
                onPlayPause: _toggleMusicPlayPause,
              ),
              if (_editMode)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    'Press & hold, then drag pads to rearrange, then tap DONE',
                    style: TextStyle(
                      color: AppColors.gold.withOpacity(0.85),
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      // 8 pads laid out as 4 columns x 2 rows. Instead of a
                      // fixed childAspectRatio (which made pads too tall to
                      // fit both rows on shorter screens, forcing a scroll),
                      // work out the aspect ratio from the actual space we
                      // have so both rows always fit on one screen — pads
                      // just get shorter on smaller screens instead.
                      const crossAxisCount = 4;
                      const rows = 2;
                      const spacing = 8.0;
                      final cellWidth =
                          (constraints.maxWidth - spacing * (crossAxisCount - 1)) / crossAxisCount;
                      final cellHeight = (constraints.maxHeight - spacing * (rows - 1)) / rows;
                      final aspectRatio = cellWidth / cellHeight;
                      return GridView.builder(
                        itemCount: 8,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          mainAxisSpacing: spacing,
                          crossAxisSpacing: spacing,
                          childAspectRatio: aspectRatio,
                        ),
                        itemBuilder: (context, index) => _buildPad(index),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPad(int index) {
    final pad = _pads[index];
    final content = _PadFace(label: pad.label, editMode: _editMode, hitTick: _hitTick[index]);

    if (!_editMode) {
      return GestureDetector(
        onTapDown: (_) => _hit(index),
        child: content,
      );
    }

    // Edit mode: quick tap opens the sound-picker for this pad; press-and-
    // hold then drag onto another pad swaps their positions instead. A
    // plain GestureDetector(onTap) layered outside the long-press
    // recognizer works fine here — Flutter's gesture arena resolves a
    // released-before-the-long-press-threshold touch as a tap, so the two
    // never fight over the same touch.
    return GestureDetector(
      onTap: () => _openSoundPicker(index),
      child: DragTarget<int>(
        onWillAccept: (data) => data != null && data != index,
        onAccept: (data) => _swap(data, index),
        builder: (context, candidateData, rejectedData) {
          final isTargetHover = candidateData.isNotEmpty;
          return LongPressDraggable<int>(
            data: index,
            feedback: Material(
              color: Colors.transparent,
              child: SizedBox(width: 90, height: 90, child: content),
            ),
            childWhenDragging: Opacity(opacity: 0.3, child: content),
            child: AnimatedScale(
              scale: isTargetHover ? 1.06 : 1.0,
              duration: const Duration(milliseconds: 120),
              child: content,
            ),
          );
        },
      ),
    );
  }
}

/// Slim, professional-drum-machine-style control strip: small square
/// outlined buttons across two thin rows (there are simply too many of them
/// now — Home/prev/next/Tune on top, Edit/Music/Upload/Record/Play on the
/// bottom) instead of one big decorative title bar.
class _Toolbar extends StatelessWidget {
  final String patchName;
  final bool editMode;
  final bool musicLoaded;
  final bool musicPlaying;
  final VoidCallback onHome;
  final VoidCallback onPrevPatch;
  final VoidCallback onNextPatch;
  final VoidCallback onPatchTap;
  final VoidCallback onTune;
  final VoidCallback onEditToggle;
  final VoidCallback onMusic;
  final VoidCallback onUpload;
  final VoidCallback onRecord;
  final VoidCallback onPlayPause;

  const _Toolbar({
    required this.patchName,
    required this.editMode,
    required this.musicLoaded,
    required this.musicPlaying,
    required this.onHome,
    required this.onPrevPatch,
    required this.onNextPatch,
    required this.onPatchTap,
    required this.onTune,
    required this.onEditToggle,
    required this.onMusic,
    required this.onUpload,
    required this.onRecord,
    required this.onPlayPause,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.18),
        border: Border(
          bottom: BorderSide(color: AppColors.gold.withOpacity(0.25), width: 1),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Row 1: navigation + patch readout + tune list.
          Row(
            children: [
              _StripButton.icon(
                iconAsset: 'assets/images/icon/home_icon.png',
                tooltip: 'Home',
                onTap: onHome,
              ),
              const SizedBox(width: 6),
              _StripButton.icon(
                fallbackIcon: Icons.chevron_left_rounded,
                tooltip: 'Previous',
                onTap: onPrevPatch,
              ),
              const SizedBox(width: 5),
              Expanded(
                child: _KitReadout(label: patchName.toUpperCase(), onTap: onPatchTap),
              ),
              const SizedBox(width: 5),
              _StripButton.icon(
                fallbackIcon: Icons.chevron_right_rounded,
                tooltip: 'Next',
                onTap: onNextPatch,
              ),
              const SizedBox(width: 6),
              _StripButton.icon(
                iconAsset: 'assets/images/icon/tune_icon.png',
                tooltip: 'Tune',
                onTap: onTune,
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Row 2: action buttons. Thin, evenly-spaced squares since there
          // are five of them now.
          Row(
            children: [
              Expanded(
                child: _StripButton.icon(
                  iconAsset: editMode ? 'assets/images/icon/choice_icon.png' : 'assets/images/icon/edit_icon.png',
                  tooltip: editMode ? 'Done' : 'Edit',
                  label: editMode ? 'DONE' : 'EDIT',
                  onTap: onEditToggle,
                  highlighted: editMode,
                  fill: true,
                ),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: _StripButton.icon(
                  iconAsset: 'assets/images/icon/music_icon.png',
                  tooltip: 'Music',
                  label: 'MUSIC',
                  onTap: onMusic,
                  fill: true,
                ),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: _StripButton.icon(
                  iconAsset: 'assets/images/icon/upload_icon.png',
                  tooltip: 'Add a sound package',
                  label: 'ADD SOUND',
                  onTap: onUpload,
                  fill: true,
                ),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: _StripButton.icon(
                  iconAsset: 'assets/images/icon/record_icon.png',
                  tooltip: 'Record',
                  label: 'REC',
                  onTap: onRecord,
                  iconColor: Colors.redAccent.shade200,
                  fill: true,
                ),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: _StripButton.icon(
                  iconAsset: musicPlaying ? 'assets/images/icon/puse_icon.png' : 'assets/images/icon/play_icon.png',
                  tooltip: musicPlaying ? 'Pause' : 'Play',
                  label: musicPlaying ? 'PAUSE' : 'PLAY',
                  onTap: onPlayPause,
                  highlighted: musicLoaded && musicPlaying,
                  fill: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// One row inside the "Choose Sound Package" sheet: tap the name to select
/// that patch (closes the sheet), tap the play icon to just preview one of
/// its sounds without selecting it — so you can quickly audition every
/// package before deciding.
class _PatchRow extends StatelessWidget {
  final String name;
  final bool selected;
  final VoidCallback onSelect;
  final VoidCallback onPreview;

  const _PatchRow({
    required this.name,
    required this.selected,
    required this.onSelect,
    required this.onPreview,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onSelect,
        child: Container(
          margin: const EdgeInsets.only(bottom: 4),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: selected ? AppColors.gold.withOpacity(0.12) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(
                selected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
                color: selected ? AppColors.gold : Colors.white38,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  name,
                  style: TextStyle(
                    color: selected ? AppColors.goldBright : Colors.white,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
              IconButton(
                onPressed: onPreview,
                tooltip: 'Preview',
                icon: const Icon(Icons.play_circle_fill_rounded, color: AppColors.goldBright, size: 24),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _KitReadout extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _KitReadout({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 30,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFF2A0709),
          borderRadius: BorderRadius.circular(7),
          border: Border.all(color: AppColors.gold.withOpacity(0.7), width: 1.1),
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppColors.gold,
            fontWeight: FontWeight.w700,
            fontSize: 12,
            letterSpacing: 1.0,
          ),
        ),
      ),
    );
  }
}

/// Thin square (or thin square-with-tiny-label) control-strip button.
/// Deliberately compact — [iconAsset]-only for the top navigation row
/// (30x30), or icon + a tiny caption underneath via [fill]/[label] for the
/// bottom action row. Uses your real icon artwork (not generic Material
/// icons) so every button matches the rest of the app's branding; a
/// built-in [fallbackIcon] is only used for the two chevron arrows, since
/// there's no custom prev/next asset in your icon pack.
class _StripButton extends StatelessWidget {
  final String? iconAsset;
  final IconData? fallbackIcon;
  final String? label;
  final String? tooltip;
  final VoidCallback onTap;
  final bool highlighted;
  final bool fill;
  final Color? iconColor;

  const _StripButton.icon({
    this.iconAsset,
    this.fallbackIcon,
    required this.onTap,
    this.label,
    this.tooltip,
    this.highlighted = false,
    this.fill = false,
    this.iconColor,
  }) : assert(iconAsset != null || fallbackIcon != null);

  @override
  Widget build(BuildContext context) {
    final iconSize = label == null ? 18.0 : 15.0;
    final Widget iconWidget = iconAsset != null
        ? Image.asset(
            iconAsset!,
            width: iconSize,
            height: iconSize,
            color: iconColor ?? (highlighted ? AppColors.goldBright : null),
            colorBlendMode: (iconColor != null || highlighted) ? BlendMode.srcATop : null,
          )
        : Icon(fallbackIcon, color: iconColor ?? AppColors.gold, size: iconSize);

    final button = InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(7),
      child: Container(
        height: 30,
        width: fill ? null : 30,
        padding: fill ? const EdgeInsets.symmetric(horizontal: 2) : null,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: highlighted ? AppColors.gold.withOpacity(0.22) : const Color(0xFF2A0709),
          borderRadius: BorderRadius.circular(7),
          border: Border.all(
            color: highlighted ? AppColors.goldBright : AppColors.gold.withOpacity(0.7),
            width: 1.1,
          ),
        ),
        child: label == null
            ? iconWidget
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  iconWidget,
                  const SizedBox(height: 1),
                  Text(
                    label!,
                    style: TextStyle(
                      color: highlighted ? AppColors.goldBright : AppColors.gold,
                      fontWeight: FontWeight.w700,
                      fontSize: 8,
                      letterSpacing: 0.4,
                    ),
                  ),
                ],
              ),
      ),
    );
    return tooltip == null ? button : Tooltip(message: tooltip!, child: button);
  }
}

/// The visual pad itself: gradient block + label + a brief "light" flash
/// overlay that fires every time [hitTick] changes.
class _PadFace extends StatelessWidget {
  final String label;
  final bool editMode;
  final int hitTick;

  const _PadFace({required this.label, required this.editMode, required this.hitTick});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF8E141A), Color(0xFF4A0A0F)],
            ),
            border: Border.all(
              color: editMode ? AppColors.goldBright : AppColors.gold.withOpacity(0.85),
              width: editMode ? 2.0 : 1.3,
            ),
            boxShadow: const [
              BoxShadow(color: Colors.black87, blurRadius: 6, offset: Offset(0, 4)),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.gold,
              fontWeight: FontWeight.w700,
              fontSize: 15,
              letterSpacing: 1.0,
            ),
          ),
        ),
        if (editMode)
          const Positioned(
            top: 6,
            right: 8,
            child: Icon(Icons.drag_indicator, color: Colors.white54, size: 16),
          ),
        Positioned.fill(
          child: IgnorePointer(
            child: TweenAnimationBuilder<double>(
              key: ValueKey(hitTick),
              tween: Tween(begin: hitTick == 0 ? 0.0 : 1.0, end: 0.0),
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOut,
              builder: (context, value, _) {
                return Opacity(
                  opacity: value,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: RadialGradient(
                        colors: [
                          AppColors.goldBright.withOpacity(0.85),
                          AppColors.gold.withOpacity(0.0),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
