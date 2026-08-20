import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/constants/app_constants.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'data/services/hive_service.dart';
import 'data/services/tunex_audio_handler.dart';
import 'providers/playback_provider.dart';
import 'providers/settings_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await HiveService.init();
  } catch (e) {
    debugPrint('[Tunex] HiveService.init() failed: $e');
  }

  late final TunexAudioHandler audioHandler;
  try {
    audioHandler = await AudioService.init(
      builder: () => TunexAudioHandler(),
      config: const AudioServiceConfig(
        androidNotificationChannelId: 'com.tunex.app.audio',
        androidNotificationChannelName: 'Tunex playback',
        androidNotificationOngoing: true,
      ),
    );
  } catch (e) {
    debugPrint('[Tunex] AudioService.init() failed: $e');
    audioHandler = TunexAudioHandler();
  }

  runApp(
    ProviderScope(
      overrides: [
        audioHandlerProvider.overrideWithValue(audioHandler),
      ],
      child: const TunexApp(),
    ),
  );
}

class TunexApp extends ConsumerWidget {
  const TunexApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    ref.watch(accentProvider);

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.dark,
      routerConfig: router,
    );
  }
}
