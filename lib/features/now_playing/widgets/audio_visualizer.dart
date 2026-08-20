import 'dart:math';
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// A lightweight animated bar visualizer for the Now Playing screen.
///
/// Honest scope note: `just_audio` doesn't expose raw PCM/frequency
/// data on Android without a custom native pipeline, so this isn't a
/// real spectrum analyzer reacting to actual audio frequencies —  it's
/// a pseudo-random animated bar pattern that plays while [isPlaying]
/// is true and freezes when paused, giving the "alive" visual energy
/// the brief calls for without overstating what it's measuring.
class AudioVisualizer extends StatefulWidget {
  final bool isPlaying;
  final int barCount;
  final double height;

  const AudioVisualizer({
    super.key,
    required this.isPlaying,
    this.barCount = 24,
    this.height = 40,
  });

  @override
  State<AudioVisualizer> createState() => _AudioVisualizerState();
}

class _AudioVisualizerState extends State<AudioVisualizer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final _random = Random();
  late List<double> _targets;

  @override
  void initState() {
    super.initState();
    _targets = List.generate(widget.barCount, (_) => _random.nextDouble());

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    )..addListener(() {
        if (_controller.isCompleted) {
          setState(() {
            _targets = List.generate(widget.barCount, (_) => _random.nextDouble());
          });
          _controller.forward(from: 0);
        }
      });

    if (widget.isPlaying) _controller.forward();
  }

  @override
  void didUpdateWidget(covariant AudioVisualizer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying && !oldWidget.isPlaying) {
      _controller.forward();
    } else if (!widget.isPlaying && oldWidget.isPlaying) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(widget.barCount, (i) {
              final progress = widget.isPlaying ? _controller.value : 0.0;
              final heightFraction = widget.isPlaying
                  ? 0.15 + (_targets[i] * 0.85 * _easeInOut(progress))
                  : 0.12;
              return Container(
                width: 3,
                height: widget.height * heightFraction.clamp(0.1, 1.0),
                decoration: BoxDecoration(
                  color: i % 2 == 0 ? AppColors.primary : AppColors.accent,
                  borderRadius: BorderRadius.circular(2),
                ),
              );
            }),
          );
        },
      ),
    );
  }

  double _easeInOut(double t) => (sin((t - 0.5) * pi) + 1) / 2;
}
