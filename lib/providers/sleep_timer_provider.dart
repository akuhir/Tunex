import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'playback_provider.dart';

/// State for the Settings > Sleep Timer feature: counts down from a
/// chosen duration and pauses playback when it hits zero. A plain
/// in-memory timer (not persisted) — a sleep timer that's still
/// running after the app was killed and relaunched wouldn't make
/// sense anyway.
class SleepTimerState {
  final Duration? remaining;
  final bool isActive;

  const SleepTimerState({this.remaining, this.isActive = false});
}

class SleepTimerNotifier extends StateNotifier<SleepTimerState> {
  final Ref _ref;
  Timer? _ticker;

  SleepTimerNotifier(this._ref) : super(const SleepTimerState());

  void start(Duration duration) {
    _ticker?.cancel();
    state = SleepTimerState(remaining: duration, isActive: true);

    _ticker = Timer.periodic(const Duration(seconds: 1), (timer) {
      final remaining = state.remaining;
      if (remaining == null || remaining.inSeconds <= 1) {
        _ref.read(playbackProvider.notifier).pause();
        cancel();
        return;
      }
      state = SleepTimerState(
        remaining: remaining - const Duration(seconds: 1),
        isActive: true,
      );
    });
  }

  /// Extends or shortens the timer without interrupting playback —
  /// used by "+5 min" style adjustments if added later; also handy for
  /// simply changing your mind about the duration mid-countdown.
  void adjust(Duration delta) {
    final remaining = state.remaining;
    if (remaining == null) return;
    final updated = remaining + delta;
    state = SleepTimerState(
      remaining: updated.isNegative ? Duration.zero : updated,
      isActive: true,
    );
  }

  void cancel() {
    _ticker?.cancel();
    _ticker = null;
    state = const SleepTimerState();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }
}

final sleepTimerProvider =
    StateNotifierProvider<SleepTimerNotifier, SleepTimerState>((ref) {
  return SleepTimerNotifier(ref);
});
