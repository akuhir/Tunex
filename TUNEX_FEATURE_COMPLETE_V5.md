# Tunex v5 feature completion

Built on the stable MediaStore/date-added v4 base.

Implemented:
- Persistent Favorites remain fully wired to the library and song actions.
- Persistent Playlists: create, rename, delete, add songs, remove songs, and play.
- Dedicated Lyrics route for the current track, using local matching `.lrc` files.
- Search artist results now open the real artist route.
- Search album results now open the real album route.
- Queue now supports removing entries.
- Now Playing overflow menu has working Queue and Lyrics actions.
- Song Share action now opens the Android share sheet with the actual local audio file.
- Now Playing Share action is also functional.
- MediaStore/date-added sorting from v4 is retained.
- The previous on_audio_query AlbumQuery crash path remains removed.

Notes:
- Lyrics remain offline/local: Tunex looks for a `.lrc` file beside the audio file. No network lyrics provider was added.
- Artist artwork may still use generated/placeholder artwork because MediaStore does not provide a reliable per-artist image on all Android devices.
