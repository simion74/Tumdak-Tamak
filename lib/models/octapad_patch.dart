/// A single pad's label + which sound it triggers.
class PadSound {
  final String label;
  final String soundId; // key understood by SoundService
  const PadSound(this.label, this.soundId);
}

/// A full 8-pad sound package ("patch") for the Octapad. Selecting a patch
/// from the Tune screen swaps all 8 pads to this package's sounds at once.
class OctapadPatch {
  final String id;
  final String name;
  final List<PadSound> pads; // exactly 8, in default (row-major) order
  const OctapadPatch({required this.id, required this.name, required this.pads});
}

/// Built-in patches shipped with the app.
///
/// NOTE on sourcing (please read before publishing the app):
/// - "santali" was built from the `santali.Patch.mcn` folder you provided —
///   no branding/attribution files were bundled with it.
/// - ⚠️ "sohorai" was built from the `dong sohorai.mcn` folder you
///   provided. That folder's own text notes identify it as a patch
///   originally published by a third party ("Octapad Master Sachin",
///   octapatch.in), not something recorded by you. Since you specifically
///   asked to avoid copyright problems: this one is NOT confirmed
///   copyright-free, and is kept in the app only for your own testing.
///   Before a public release you should either get written permission
///   from that creator, or replace these .wav files
///   (assets/sounds/sohorai_*.wav) with something you have the rights to
///   use (e.g. your own recordings, or one of the CC0 kits below). The
///   duplicate "DONG 73" folder was skipped: same patch but with
///   broken/empty hi-hat samples.
/// - "trap", "bounce" and "vintage" are 3 new electronic kits added from
///   github.com/Boochi44/free-drum-samples, released under **CC0 1.0**
///   (public-domain-equivalent) — free for commercial use, no attribution
///   required, confirmed copyright-free. Good filler patches while you
///   record your own Santali/Sohorai-style sounds for the rest.
/// - ⚠️ "dong" was built from the `DONG.mcn` folder you provided. Its own
///   bundled text notes (for the extra loops/tracks shipped alongside the
///   pad sounds) are also credited to "Octapad Master Sachin"
///   (octapatch.in) — the same third-party publisher as "sohorai". So
///   this one is ALSO not confirmed copyright-free; same caution applies
///   as for "sohorai" (get permission before public release, or replace
///   with your own recordings). You've since sent a re-fixed version with
///   all 8 pad sounds working correctly (the earlier upload had 2 broken
///   files) — that fixed set is what's bundled now.
const List<OctapadPatch> kOctapadPatches = [
  OctapadPatch(
    id: 'santali',
    name: 'Santali',
    pads: [
      PadSound('KICK', 'octapad_santali_kick'),
      PadSound('SNARE', 'octapad_santali_snare'),
      PadSound('HAT-C', 'octapad_santali_chat'),
      PadSound('HAT-O', 'octapad_santali_ohat'),
      PadSound('TOM', 'octapad_santali_tom'),
      PadSound('CRASH', 'octapad_santali_crash'),
      PadSound('CLAP', 'octapad_santali_clap'),
      PadSound('RIM', 'octapad_santali_rim'),
    ],
  ),
  OctapadPatch(
    id: 'sohorai',
    name: 'Dong Sohorai ⚠️',
    pads: [
      PadSound('KICK', 'octapad_sohorai_kick'),
      PadSound('SNARE', 'octapad_sohorai_snare'),
      PadSound('HAT-C', 'octapad_sohorai_chat'),
      PadSound('HAT-O', 'octapad_sohorai_ohat'),
      PadSound('TOM', 'octapad_sohorai_tom'),
      PadSound('CRASH', 'octapad_sohorai_crash'),
      PadSound('CLAP', 'octapad_sohorai_clap'),
      PadSound('RIM', 'octapad_sohorai_rim'),
    ],
  ),
  OctapadPatch(
    id: 'dong',
    name: 'Dong ⚠️',
    pads: [
      PadSound('KICK', 'octapad_dong_kick'),
      PadSound('SNARE', 'octapad_dong_snare'),
      PadSound('HAT-C', 'octapad_dong_chat'),
      PadSound('HAT-O', 'octapad_dong_ohat'),
      PadSound('TOM', 'octapad_dong_tom'),
      PadSound('CRASH', 'octapad_dong_crash'),
      PadSound('CLAP', 'octapad_dong_clap'),
      PadSound('RIM', 'octapad_dong_rim'),
    ],
  ),
  OctapadPatch(
    id: 'trap',
    name: 'Trap (CC0)',
    pads: [
      PadSound('KICK', 'octapad_trap_kick'),
      PadSound('SNARE', 'octapad_trap_snare'),
      PadSound('HAT-C', 'octapad_trap_chat'),
      PadSound('HAT-O', 'octapad_trap_ohat'),
      PadSound('TOM', 'octapad_trap_tom'),
      PadSound('CRASH', 'octapad_trap_crash'),
      PadSound('CLAP', 'octapad_trap_clap'),
      PadSound('RIM', 'octapad_trap_rim'),
    ],
  ),
  OctapadPatch(
    id: 'bounce',
    name: 'Bounce (CC0)',
    pads: [
      PadSound('KICK', 'octapad_bounce_kick'),
      PadSound('SNARE', 'octapad_bounce_snare'),
      PadSound('HAT-C', 'octapad_bounce_chat'),
      PadSound('HAT-O', 'octapad_bounce_ohat'),
      PadSound('TOM', 'octapad_bounce_tom'),
      PadSound('CRASH', 'octapad_bounce_crash'),
      PadSound('CLAP', 'octapad_bounce_clap'),
      PadSound('RIM', 'octapad_bounce_rim'),
    ],
  ),
  OctapadPatch(
    id: 'vintage',
    name: 'Soulful Vintage (CC0)',
    pads: [
      PadSound('KICK', 'octapad_vintage_kick'),
      PadSound('SNARE', 'octapad_vintage_snare'),
      PadSound('HAT-C', 'octapad_vintage_chat'),
      PadSound('HAT-O', 'octapad_vintage_ohat'),
      PadSound('TOM', 'octapad_vintage_tom'),
      PadSound('CRASH', 'octapad_vintage_crash'),
      PadSound('CLAP', 'octapad_vintage_clap'),
      PadSound('RIM', 'octapad_vintage_rim'),
    ],
  ),
];
