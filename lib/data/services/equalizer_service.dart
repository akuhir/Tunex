import 'package:android_intent_plus/android_intent.dart';
import 'package:flutter/services.dart';

/// Launches the device's built-in system equalizer, scoped to Tunex's
/// audio session via the standard Android
/// `ACTION_DISPLAY_AUDIO_EFFECT_CONTROL_PANEL` intent.
///
/// This is the "Equalizer Shortcut" from the brief, not a custom-built
/// EQ UI — most Android OEMs (Samsung, and many others) ship their own
/// system equalizer with presets and a graphic EQ, and launching it
/// via intent is the standard, well-supported way for a media app to
/// offer EQ access without shipping and maintaining real-time DSP
/// itself. Not every device has one installed (stock AOSP emulators
/// commonly don't), so [launch] reports whether it succeeded so the
/// UI can show a friendly explanation instead of silently doing
/// nothing.
class EqualizerService {
  EqualizerService._();

  static const _action = 'android.media.action.DISPLAY_AUDIO_EFFECT_CONTROL_PANEL';
  static const _sessionExtra = 'android.media.extra.AUDIO_SESSION';
  static const _packageExtra = 'android.media.extra.PACKAGE_NAME';

  /// Returns true if a system equalizer activity was found and
  /// launched, false if no such activity exists on this device (the
  /// intent has no matching receiver).
  static Future<bool> launch({required int audioSessionId}) async {
    try {
      final intent = AndroidIntent(
        action: _action,
        arguments: <String, dynamic>{
          _sessionExtra: audioSessionId,
          _packageExtra: 'com.tunex.app',
        },
      );
      await intent.launch();
      return true;
    } on PlatformException {
      // Thrown when no activity resolves the intent — i.e. this
      // device/ROM doesn't ship a system equalizer.
      return false;
    }
  }
}
