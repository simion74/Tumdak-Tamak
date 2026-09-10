import 'package:audioplayers/audioplayers.dart';
import 'local_store.dart';

/// Central place to play instrument sounds with the lowest latency
/// audioplayers can give us. Every pad/touch-area in the app should call
/// [SoundService.instance.play] instead of creating its own AudioPlayer.
///
/// Also owns the per-sound EQ (Volume / Tone / Echo / Hall-Reverb) used by
/// the EQ popup on Tumdak & Tamak. Real multi-band DSP isn't available
/// through `audioplayers`, so EQ is approximated with techniques that are
/// genuinely audible on a phone speaker:
///  - Volume: straight gain.
///  - Tone (thick/thin): played back at a different rate.
///    Slower rate = lower pitch = thicker/heavier sound. Faster = thinner.
///  - Echo: a second, quieter copy of the same hit is fired a short moment
///    later, like a slap-back echo.
///  - Hall/Reverb: two or three even-quieter, more-spaced-out repeats,
///    approximating the "big room" tail a real hall reverb gives you.
///
/// IMPORTANT for later, when real Madal/Tumdak/Tamak recordings are ready:
/// just replace the .wav files inside assets/sounds/ with the real
/// recordings using the SAME file names listed in [_assetFor]. No code
/// changes will be needed.
class SoundService {
  SoundService._();
  static final SoundService instance = SoundService._();

  final Map<String, AudioPlayer> _players = {};
  // Extra "tail" players used only to fire echo/reverb repeats so they never
  // cut off or fight with the main hit player.
  final List<AudioPlayer> _tailPlayers = [];
  int _tailCursor = 0;
  bool _ready = false;

  // soundId -> {volume, rate, echo, reverb}
  final Map<String, Map<String, double>> _eq = {};

  // Separate player for the "MUSIC" feature (a background track the user
  // picks from their device and plays/pauses while drumming along), kept
  // apart from the pad players above so playing/pausing music never touches
  // pad playback and vice-versa.
  final AudioPlayer _musicPlayer = AudioPlayer(playerId: 'background_music');
  bool _musicLoaded = false;
  bool get isMusicPlaying => _musicLoaded && _musicPlaying;
  bool _musicPlaying = false;

  /// Maps a logical sound id to its asset path.
  static const Map<String, String> _assetFor = {
    'tumdak_left': 'sounds/tumdak_left.wav',
    'tumdak_right': 'sounds/tumdak_right.wav',
    'tamak': 'sounds/tamak.wav',
    // Octapad sound packages ("patches"). Add more patches by adding more
    // entries here (with matching wav files in assets/sounds/) and then
    // registering them in lib/models/octapad_patch.dart.
    'octapad_santali_kick': 'sounds/santali_kick.wav',
    'octapad_santali_snare': 'sounds/santali_snare.wav',
    'octapad_santali_chat': 'sounds/santali_chat.wav',
    'octapad_santali_ohat': 'sounds/santali_ohat.wav',
    'octapad_santali_tom': 'sounds/santali_tom.wav',
    'octapad_santali_crash': 'sounds/santali_crash.wav',
    'octapad_santali_clap': 'sounds/santali_clap.wav',
    'octapad_santali_rim': 'sounds/santali_rim.wav',

    'octapad_sohorai_kick': 'sounds/sohorai_kick.wav',
    'octapad_sohorai_snare': 'sounds/sohorai_snare.wav',
    'octapad_sohorai_chat': 'sounds/sohorai_chat.wav',
    'octapad_sohorai_ohat': 'sounds/sohorai_ohat.wav',
    'octapad_sohorai_tom': 'sounds/sohorai_tom.wav',
    'octapad_sohorai_crash': 'sounds/sohorai_crash.wav',
    'octapad_sohorai_clap': 'sounds/sohorai_clap.wav',
    'octapad_sohorai_rim': 'sounds/sohorai_rim.wav',

    'octapad_dong_kick': 'sounds/dong_kick.wav',
    'octapad_dong_snare': 'sounds/dong_snare.wav',
    'octapad_dong_chat': 'sounds/dong_chat.wav',
    'octapad_dong_ohat': 'sounds/dong_ohat.wav',
    'octapad_dong_tom': 'sounds/dong_tom.wav',
    'octapad_dong_crash': 'sounds/dong_crash.wav',
    'octapad_dong_clap': 'sounds/dong_clap.wav',
    'octapad_dong_rim': 'sounds/dong_rim.wav',

    // Below: 3 extra electronic kits, all CC0 (public-domain-equivalent,
    // free for commercial use, no attribution required) — see
    // lib/models/octapad_patch.dart for the source/license note.
    'octapad_trap_kick': 'sounds/trap_kick.wav',
    'octapad_trap_snare': 'sounds/trap_snare.wav',
    'octapad_trap_chat': 'sounds/trap_chat.wav',
    'octapad_trap_ohat': 'sounds/trap_ohat.wav',
    'octapad_trap_tom': 'sounds/trap_tom.wav',
    'octapad_trap_crash': 'sounds/trap_crash.wav',
    'octapad_trap_clap': 'sounds/trap_clap.wav',
    'octapad_trap_rim': 'sounds/trap_rim.wav',

    'octapad_bounce_kick': 'sounds/bounce_kick.wav',
    'octapad_bounce_snare': 'sounds/bounce_snare.wav',
    'octapad_bounce_chat': 'sounds/bounce_chat.wav',
    'octapad_bounce_ohat': 'sounds/bounce_ohat.wav',
    'octapad_bounce_tom': 'sounds/bounce_tom.wav',
    'octapad_bounce_crash': 'sounds/bounce_crash.wav',
    'octapad_bounce_clap': 'sounds/bounce_clap.wav',
    'octapad_bounce_rim': 'sounds/bounce_rim.wav',

    'octapad_vintage_kick': 'sounds/vintage_kick.wav',
    'octapad_vintage_snare': 'sounds/vintage_snare.wav',
    'octapad_vintage_chat': 'sounds/vintage_chat.wav',
    'octapad_vintage_ohat': 'sounds/vintage_ohat.wav',
    'octapad_vintage_tom': 'sounds/vintage_tom.wav',
    'octapad_vintage_crash': 'sounds/vintage_crash.wav',
    'octapad_vintage_clap': 'sounds/vintage_clap.wav',
    'octapad_vintage_rim': 'sounds/vintage_rim.wav',
  };

  /// Call once at app start (see main.dart) so the very first tap has no
  /// extra loading delay.
  ///
  /// IMPORTANT: players are intentionally NOT put into PlayerMode.lowLatency.
  /// On Android, combining lowLatency with ReleaseMode.stop is a confirmed
  /// audioplayers bug (github.com/bluefireteam/audioplayers/issues/1489):
  /// low-latency mode disables the stream-completion signal the player
  /// needs to reset itself, so a pad plays once and then never again. The
  /// default (mediaPlayer) mode doesn't have this problem and still keeps
  /// ReleaseMode.stop so repeated resume() calls stay fast.
  Future<void> preload() async {
    if (_ready) return;
    // Load every sound concurrently instead of one at a time — with ~50
    // sounds, awaiting each sequentially could take many seconds and would
    // also matter less; loading them all in parallel is both faster overall
    // and finishes evenly instead of some sounds becoming usable long
    // before others.
    final loaded = await Future.wait(_assetFor.entries.map((entry) async {
      final player = AudioPlayer(playerId: entry.key);
      await player.setSourceAsset(entry.value);
      await player.setReleaseMode(ReleaseMode.stop);
      return MapEntry(entry.key, player);
    }));
    _players.addEntries(loaded);

    // A small pool of extra players reused round-robin for echo/reverb
    // repeats, so a fast run of hits never runs out.
    final tails = await Future.wait(List.generate(4, (i) async {
      final p = AudioPlayer(playerId: 'tail_$i');
      await p.setReleaseMode(ReleaseMode.stop);
      return p;
    }));
    _tailPlayers.addAll(tails);

    // Restore any EQ the user saved last time for the built-in drum sounds.
    for (final id in ['tumdak_left', 'tumdak_right', 'tamak']) {
      _eq[id] = await LocalStore.instance.getEq(id);
    }
    _ready = true;
  }

  Map<String, double> eqFor(String soundId) =>
      _eq[soundId] ?? const {'volume': 1.0, 'rate': 1.0, 'echo': 0.0, 'reverb': 0.0};

  /// Updates and persists the EQ for [soundId]. Any value left null keeps
  /// its current setting.
  Future<void> setEq(
    String soundId, {
    double? volume,
    double? rate,
    double? echo,
    double? reverb,
  }) async {
    final current = Map<String, double>.from(eqFor(soundId));
    if (volume != null) current['volume'] = volume;
    if (rate != null) current['rate'] = rate;
    if (echo != null) current['echo'] = echo;
    if (reverb != null) current['reverb'] = reverb;
    _eq[soundId] = current;
    await LocalStore.instance.saveEq(soundId, current);
  }

  /// Plays a sound instantly, applying that sound's saved EQ (volume, tone,
  /// echo, hall/reverb). Safe to call rapidly / repeatedly (retriggers from
  /// the start each time, like a real drum pad).
  Future<void> play(String soundId, {double volume = 1.0}) async {
    final player = _players[soundId];
    if (player == null) return;
    final eq = eqFor(soundId);
    final gain = (volume * (eq['volume'] ?? 1.0)).clamp(0.0, 1.5);
    final rate = (eq['rate'] ?? 1.0).clamp(0.5, 1.8);
    try {
      // setPlaybackRate/setVolume/seek are independent of each other, so run
      // them concurrently instead of awaiting one-by-one — this cuts the
      // number of sequential platform-channel round trips before the sound
      // actually starts, which is most of the tap-to-sound delay.
      await Future.wait([
        player.setPlaybackRate(rate),
        player.setVolume(gain),
        player.seek(Duration.zero),
      ]);
      await player.resume();
    } catch (_) {
      // Best-effort: a hiccup on this one retrigger should never leave the
      // pad permanently silent for later taps.
    }

    _fireEchoAndReverb(soundId, eq, gain, rate);
  }

  void _fireEchoAndReverb(String soundId, Map<String, double> eq, double gain, double rate) {
    final echo = eq['echo'] ?? 0.0;
    final reverb = eq['reverb'] ?? 0.0;
    if (echo <= 0.02 && reverb <= 0.02) return;
    final asset = _assetFor[soundId];
    if (asset == null) return;

    // Echo: one slap-back repeat, ~110ms later, quieter.
    if (echo > 0.02) {
      _scheduleTail(asset, delayMs: 110, volume: gain * echo * 0.65, rate: rate);
    }
    // Hall/reverb: several soft, spaced-out repeats trailing off, to
    // suggest a bigger room.
    if (reverb > 0.02) {
      final taps = 1 + (reverb * 3).round(); // 1..4 repeats
      for (var i = 1; i <= taps; i++) {
        _scheduleTail(
          asset,
          delayMs: 160 * i,
          volume: gain * reverb * (0.5 / i),
          rate: rate * 0.98,
        );
      }
    }
  }

  void _scheduleTail(String asset, {required int delayMs, required double volume, required double rate}) {
    Future.delayed(Duration(milliseconds: delayMs), () async {
      if (_tailPlayers.isEmpty) return;
      final p = _tailPlayers[_tailCursor % _tailPlayers.length];
      _tailCursor++;
      try {
        await p.setPlaybackRate(rate.clamp(0.5, 1.8));
        await p.setVolume(volume.clamp(0.0, 1.0));
        await p.setSourceAsset(asset);
        await p.resume();
      } catch (_) {
        // Best-effort only — a missed echo tap should never crash playback.
      }
    });
  }

  /// Loads a user-picked sound file from their device (e.g. from the
  /// "UPLOAD" button on the Octapad) and registers it under [soundId] so it
  /// can be triggered with [play] exactly like a built-in pad sound.
  Future<void> registerDeviceSound(String soundId, String filePath) async {
    final existing = _players[soundId];
    if (existing != null) {
      await existing.dispose();
    }
    final player = AudioPlayer(playerId: soundId);
    await player.setSourceDeviceFile(filePath);
    await player.setReleaseMode(ReleaseMode.stop);
    _players[soundId] = player;
  }

  /// Loads and starts looping a background music track picked from the
  /// device (the "MUSIC" button), so the user can play the drum pads along
  /// with a song.
  Future<void> playMusic(String filePath) async {
    await _musicPlayer.setReleaseMode(ReleaseMode.loop);
    await _musicPlayer.setSourceDeviceFile(filePath);
    await _musicPlayer.resume();
    _musicLoaded = true;
    _musicPlaying = true;
  }

  Future<void> toggleMusicPlayPause() async {
    if (!_musicLoaded) return;
    if (_musicPlaying) {
      await _musicPlayer.pause();
    } else {
      await _musicPlayer.resume();
    }
    _musicPlaying = !_musicPlaying;
  }

  Future<void> stopMusic() async {
    if (!_musicLoaded) return;
    await _musicPlayer.stop();
    _musicLoaded = false;
    _musicPlaying = false;
  }

  Future<void> setMusicVolume(double v) async {
    await _musicPlayer.setVolume(v.clamp(0.0, 1.0));
  }

  Future<void> dispose() async {
    for (final p in _players.values) {
      await p.dispose();
    }
    _players.clear();
    for (final p in _tailPlayers) {
      await p.dispose();
    }
    _tailPlayers.clear();
    await _musicPlayer.dispose();
    _ready = false;
  }
}
