# Sound Credits & Licenses

This file documents where every built-in Octapad sound package ("patch")
came from, so you always know what you can safely publish. Keep this file
updated whenever sounds are added or replaced.

## Santali
Source: `santali.Patch.mcn` (provided by you). No third-party branding or
license file was bundled with it. Treat as your own content.

## Dong Sohorai ⚠️ NOT CONFIRMED COPYRIGHT-FREE
Source: `dong sohorai.mcn` (provided by you). That folder's own notes
identify it as a patch originally published by a third party
("Octapad Master Sachin", octapatch.in) — not something recorded by you.

**Before publishing the app publicly**, do one of:
- Get written permission from the original creator to include it, or
- Replace `assets/sounds/sohorai_*.wav` with your own recordings or one
  of the CC0 kits below.

Until then, keep this patch for internal testing only.

## Dong ⚠️ NOT CONFIRMED COPYRIGHT-FREE
Source: `DONG.mcn` (provided by you). The extra loop/track files bundled in
that same folder (e.g. `Best Dhol patch Opms.txt`,
`Jharkhandi Nagpuri Oreginal patch Opms.txt`) are credited to a third
party: **"Octapad Master Sachin" (octapatch.in)** — the same publisher
as the "Dong Sohorai" patch. The core 8 pad sounds don't have their own
separate credit file, but given they shipped in the same folder as that
publisher's other content, treat them the same way:

**Before publishing the app publicly**, do one of:
- Get written permission from the original creator to include it, or
- Replace `assets/sounds/dong_*.wav` with your own recordings or one of
  the CC0 kits below.

Update: you re-sent a fixed set (`DONG_fixed_8sounds.zip`) where all 8
pads are real, distinct, valid audio — that's what's bundled now. The
earlier version had `chat.wav`/`ohat.wav` as 0-byte/corrupted files,
which is why only some pads worked before.

Until then, keep this patch for internal testing only.

## Trap / Bounce / Vintage — ✅ CC0 (safe for commercial use)
Source: https://github.com/Boochi44/free-drum-samples
License: **CC0 1.0 Universal** (public-domain-equivalent).
- Free to use, modify, and redistribute — including commercially.
- No attribution required (the repo's own README confirms this).
- The repo itself notes some one-shots were derived from the TR-808
  sample set by Edward Loveall (`tidalcycles/sounds-tr808-fischer`),
  also CC0. If you'd like to credit that chain anyway (optional, not
  required), the suggested line is:
  > "Some samples derived from the TR-808 recordings by Edward Loveall (CC0)."

Files copied in (see `lib/services/sound_service.dart` for the exact
asset paths):
- `trap_kick.wav`, `trap_snare.wav`, `trap_chat.wav`, `trap_ohat.wav`,
  `trap_tom.wav`, `trap_crash.wav`, `trap_clap.wav`, `trap_rim.wav`
- `bounce_kick.wav`, `bounce_snare.wav`, `bounce_chat.wav`,
  `bounce_ohat.wav`, `bounce_tom.wav`, `bounce_crash.wav`,
  `bounce_clap.wav`, `bounce_rim.wav`
- `vintage_kick.wav`, `vintage_snare.wav`, `vintage_chat.wav`,
  `vintage_ohat.wav`, `vintage_tom.wav`, `vintage_crash.wav`,
  `vintage_clap.wav`, `vintage_rim.wav`

(Note: the Bounce and Vintage kits don't ship a dedicated rimshot sample,
so their RIM pad reuses the Trap kit's `perc-rimshot.wav` — same CC0
license, so this is fine.)

## Recommended next step for Santali / Sohorai-style sounds
For the most authentic Santal-instrument feel (madal/tumdak/nagara-style
hits for future patches), the safest and best-sounding option is to
record real players yourself — the app's built-in **Record** feature
(mic → preview → save) is made for exactly this. Free stock packs online
are almost all Western electronic/hip-hop kits, so they won't match the
traditional sound the way your own recordings will.
