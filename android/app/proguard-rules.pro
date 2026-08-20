# audio_service uses reflection for its background media session —
# keep its classes intact under R8/ProGuard minification.
-keep class com.ryanheise.audioservice.** { *; }
-keep class com.ryanheise.just_audio.** { *; }

