/// Editable "About" info for Tunex.
///
/// Everything the About screen shows that isn't derived from app
/// config lives here — a single file to edit instead of hunting
/// through the About screen's widget tree. Leave any field as an
/// empty string to hide the row/card it feeds in the UI.
///
/// Note on the "hidden" contact fields (email, WhatsApp number, socials):
/// these are kept out of the visible UI — only tap targets are shown,
/// never the raw string — but this is not real security. A compiled
/// Flutter app's string constants are straightforward to recover by
/// decompiling the APK, so treat this as "not casually visible on
/// screen," not as anything a determined person couldn't find.
class DeveloperInfo {
  DeveloperInfo._();

  // --- Developer identity ---
  static const String developerName = "Abubakar Muh'd Nurudeen";
  static const String developerAlias = 'Solograph';
  static const String developerRoleTagline =
      'History Student • Aspiring Developer • AI Enthusiast';

  /// Path to the profile photo asset. Drop a photo at this exact path
  /// (create the file `assets/images/profile.jpg`) and it will appear
  /// automatically — no code changes needed. Until that file exists,
  /// the avatar shows a graceful placeholder icon instead.
  static const String profileImageAsset = 'assets/images/profile.jpg';

  // --- About Tunex bio copy ---
  static const String aboutTunexBody =
      'Tunex is a modern offline music player designed for people who '
      'simply love music. It automatically discovers audio files stored '
      'on your device, allowing you to play, organize, and enjoy your '
      'favorite songs through a clean, fast, and immersive experience.\n\n'
      'As a History student with a passion for technology, I created '
      'Tunex to challenge myself, explore mobile app development, '
      'artificial intelligence, and user experience design while '
      'building software that people genuinely enjoy using.\n\n'
      'Every feature represents another step in my journey as a '
      "developer.\n\nTunex isn't just another music player. It's a "
      'personal project built with curiosity, creativity, and '
      'continuous learning.';

  // --- Contact (not shown as visible text anywhere in the UI) ---
  static const String contactEmail = 'nurudeensolograph@gmail.com';
  static const String whatsappUrl = 'https://wa.me/2349017769742';
  static const String xUrl = 'https://x.com/ANurudeen94258';
  static const String telegramUrl = 'https://t.me/Cryptovibes01';

  // --- Footer ---
  static const String copyrightLine = '© 2026 Tunex. All rights reserved.';
  static const String madeWithLine = 'Made with ❤️ from Nigeria 🇳🇬';
}
