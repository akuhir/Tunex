# Tunex permission fix v3

The library permission banner persisted because the repository was importing a second permission service that always used `Permission.audio`. The Android 11 device running Tunex needs `Permission.storage` / `READ_EXTERNAL_STORAGE` instead.

The repository now uses the platform-aware service:
- Android 13+ (API 33+): `Permission.audio` / READ_MEDIA_AUDIO
- Android 12 and below: `Permission.storage` / READ_EXTERNAL_STORAGE

After the permission dialog, Tunex re-checks the OS permission before calling MediaStore.
The MediaStore scanner remains in place and the old `on_audio_query` crash path is not restored.
