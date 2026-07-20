# Tunex

**Feel Every Beat.**

Tunex is a premium, fully offline Android music player built with Flutter.
It scans the device for local audio files and organizes them into a fast,
beautifully animated library — no streaming, no accounts, no ads.

## Status: Phase 6 — Polish Pass (Complete)

All six phases are done. Tunex is now feature-complete against the
original brief: foundation, real device library, real audio playback,
library organization + persistence, working Settings, and this final
polish pass.

- Project architecture, theme system, animated splash screen
- Bottom navigation shell + persistent mini player with live progress bar
- Runtime audio permission handling, with dedicated "permission
  needed" / "permanently denied" UI
- Real device scanning via `on_audio_query` (MediaStore) — songs,
  albums, and artists read from the actual device library
- Real embedded album artwork, with a branded gradient fallback
- **Real audio playback** via `just_audio` + `audio_service`: lock
  screen controls, notification controls, headset button support,
  `audio_session` focus handling
- Full Now Playing screen: live seek bar, shuffle/repeat, skip
  next/previous, swipe-to-skip, real favorite toggle
- **Persisted Favorites** (Hive-backed) — the heart icon anywhere
  actually saves, with a dedicated Favorites page
- **Playlists** — create/rename/delete, add/remove songs from any
  song's three-dot menu, dedicated list + detail pages
- **Real listening history** (Hive-backed play counts + timestamps)
  driving genuine Most Played / Recently Played rails on Home, instead
  of the earlier shuffled placeholder
- **Search** — instant client-side search across songs, artists, and
  albums
- **Genres** and **Folders** pages, reading MediaStore genre tags and
  grouping by containing directory respectively
- **Album detail** and **Artist detail** pages (tap an album or artist
  to see its tracks / stats / play-all)
- The three-dot song menu is fully wired: Play Next, Add to Playlist,
  Favorite toggle, View Album, View Artist, Song Details
- **Accent Color picker** — 5 curated presets (Violet/Sunset/Emerald/
  Rose/Ocean), persisted and applied live across the whole app the
  instant you pick one, no restart needed
- **Sort Songs / Sort Albums** — persisted sort order (title, artist,
  album, duration, or track count depending on the list), changeable
  from Settings or the sort icon on each tab
- **Sleep Timer** — real countdown (15/30/45/60/90 min presets) that
  actually pauses playback when it reaches zero, with a live remaining
  -time display
- **Equalizer shortcut** — launches the device's system equalizer
  (most Android OEMs ship one) scoped to Tunex's audio session, with a
  friendly message if the device has none
- **Lyrics (LRC)** — looks for a `.lrc` file next to each song's audio
  file and displays it as plain text in an expandable panel on Now
  Playing. Shown as static text, not synced/highlighted line-by-line
  with playback, by design
- **Queue viewer** — see and jump to any song in the current playback
  queue from Now Playing
- **Audio visualizer** — an animated bar visualizer on Now Playing that
  reacts to play/pause state. Note: this is a stylistic animation, not
  a real-time frequency spectrum analyzer — `just_audio` doesn't expose
  raw PCM data on Android without a custom native audio pipeline, which
  is out of scope for an app whose core value is a great offline
  listening experience, not DSP

Tunex is now feature-complete against the original brief — see
**Roadmap** for the full phase history.

## Brand

| Token | Value |
|---|---|
| Primary | `#6C63FF` |
| Accent | `#00D4FF` |
| Background | `#0F172A` |
| Surface | `#161B2D` |
| Card | `#1B2236` |
| Success | `#34D399` |
| Danger | `#FF4D6D` |

Typeface: **Poppins** (via `google_fonts`).

## Architecture

```
lib/
  core/
    theme/          # colors, typography, spacing/radius, ThemeData
    router/         # go_router configuration (incl. stacked routes for
                     # Search/Favorites/Playlists/Genres/Folders/detail pages)
    constants/       # app-wide constants
    widgets/        # shared reusable widgets (glass panels, tiles, shell,
                     # permission/empty/error state views, song actions
                     # sheet, add-to-playlist sheet)
  data/
    models/         # Song, Album, Artist, Playlist
    repositories/    # MusicRepository (MediaStore scanning),
                     # FavoritesRepository, PlaylistsRepository,
                     # HistoryRepository, SettingsRepository (all
                     # Hive-backed), MockMusicData (fixtures only)
    services/       # PermissionService, TunexAudioHandler (audio_service),
                     # HiveService (local persistence init),
                     # EqualizerService, LyricsService
  features/
    splash/
    home/
    songs/
    albums/          # + album_detail_screen.dart
    artists/         # + artist_detail_screen.dart
    genres/
    folders/
    favorites/
    playlists/       # + playlist_detail_screen.dart
    now_playing/      # + widgets/queue_sheet.dart, audio_visualizer.dart
    search/
    settings/        # + widgets/accent_picker_sheet.dart,
                     #   sleep_timer_sheet.dart, sort_picker_sheet.dart
  providers/         # Riverpod state: playback, library, favorites,
                     # playlists, settings (accent/sort), sleep timer
  main.dart
```

Each `features/<name>` folder owns its screen(s) and any
feature-specific widgets under a `widgets/` subfolder — see
`features/home/widgets/` for the pattern.

State management: **Riverpod**. Navigation: **go_router**, with a
`ShellRoute` keeping bottom nav + mini player persistent across tabs,
and the full-screen Now Playing route stacked outside the shell.

## Permissions

Tunex requests:
- `READ_MEDIA_AUDIO` (Android 13+) / `READ_EXTERNAL_STORAGE` (older)
  to scan the device's audio library
- `FOREGROUND_SERVICE` + `FOREGROUND_SERVICE_MEDIA_PLAYBACK` +
  `POST_NOTIFICATIONS` for background playback controls (used once the
  audio engine phase lands)

All handled through `PermissionService` — if denied, Home/Songs/Albums/
Artists show a dedicated prompt instead of silently showing nothing.

## Getting started

```bash
flutter pub get
flutter run
```

Requires Flutter 3.3+ (Dart 3.3+), a physical Android device or
emulator with some audio files on it (an emulator with no music will
correctly show the "No music found" empty state). Android only for now.

## Roadmap

- [x] Phase 1 — Foundation, theme, splash, navigation, Home UI
- [x] Phase 2 — MediaStore scanning (`on_audio_query`), permissions, real library data
- [x] Phase 3 — Playback engine (`just_audio` + `audio_service`), real Now Playing controls
- [x] Phase 4 — Playlists, Favorites, Search, Genres, Folders
- [x] Phase 5 — Settings behavior (theme/accent, sort, sleep timer)
- [x] Phase 6 — Polish pass: equalizer shortcut, lyrics (LRC, non-synced), visualizer

## Known limitations

Being upfront about a few things that are intentionally scoped out or
simplified:

- **Equalizer** launches the OS system equalizer via intent rather
  than shipping a custom in-app EQ. Devices without one installed
  (common on stock AOSP emulators, rare on real hardware) show a
  friendly "not found" message instead of a broken screen.
- **Visualizer** is a stylistic animated bar display, not a real
  frequency-spectrum analyzer — Android's `just_audio` doesn't expose
  raw PCM/FFT data without a custom native audio pipeline.
- **Lyrics** display the full `.lrc` file contents as static text and
  are not synced/highlighted to the current playback position by
  design.
- **Queue editing** (reordering, removing individual songs mid-queue)
  isn't built — the Queue viewer supports jumping to any song, and
  "Play Next" starts that song immediately rather than inserting it at
  queue position 2.
- **Sharing** a local audio file is a visible-but-inert button — actual
  file sharing needs either a platform share-sheet plugin or a
  server-hosted link, both out of scope for an offline-only player.
- **Release builds sign with the debug keystore** (see
  `android/app/build.gradle`) so CI builds succeed out of the box —
  swap in a real signing config before any Play Store submission.

## CI

`.github/workflows/build_apk.yml` builds debug + release APKs on every
push to `main` and uploads them as GitHub Actions artifacts.

## License

MIT — see [LICENSE](LICENSE).
