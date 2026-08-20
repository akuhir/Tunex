# Tunex crash fix

The Logcat crash was `IllegalStateException: Reply already submitted` from the `on_audio_query` native `AlbumQuery` implementation.

This version removes `on_audio_query_forked` from the application and replaces its library scanning path with a small native Android MediaStore bridge. Tunex no longer calls `queryAlbums()`, `querySongs()`, `queryGenres()`, `queryAudiosFrom()`, or the plugin artwork channel.

The bridge reads audio tracks directly from `MediaStore.Audio.Media`, groups albums in Dart-visible results, and loads album artwork through MediaStore. Android media permissions remain declared for API 33+ and older devices.

This removes the native `AlbumQuery.kt:58` code path that was killing the process.
