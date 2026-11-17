import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'app_motion.dart';

/// Gerakan "bernapas" naik-turun yang sangat pelan untuk artwork Pokémon.
class Floating extends StatefulWidget {
  const Floating({
    super.key,
    required this.child,
    this.amplitude = 5,
    this.period = const Duration(milliseconds: 3400),
  });

  final Widget child;
  final double amplitude;
  final Duration period;

  @override
  State<Floating> createState() => _FloatingState();
}

class _FloatingState extends State<Floating>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: widget.period);
  late final Animation<double> _curve =
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (AppMotion.reduced(context)) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _curve,
      child: widget.child,
      builder: (context, child) => Transform.translate(
        offset: Offset(0, widget.amplitude * (1 - 2 * _curve.value)),
        child: child,
      ),
    );
  }
}

/// Goyangan ala Pokéball yang sedang menangkap Pokémon:
/// sekali goyang singkat, lalu diam lama. Tidak mengganggu, tapi "hidup".
class Wobble extends StatefulWidget {
  const Wobble({
    super.key,
    required this.child,
    this.interval = const Duration(seconds: 7),
    this.initialDelay = const Duration(milliseconds: 1400),
    this.maxAngle = 0.22,
  });

  final Widget child;
  final Duration interval;
  final Duration initialDelay;
  final double maxAngle;

  @override
  State<Wobble> createState() => _WobbleState();
}

class _WobbleState extends State<Wobble> with SingleTickerProviderStateMixin {
  // Porsi siklus yang dipakai untuk goyang; sisanya diam.
  static const double _activePortion = 0.13;

  late final AnimationController _controller =
      AnimationController(vsync: this, duration: widget.interval);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (AppMotion.reduced(context)) {
      _controller.stop();
      return;
    }
    if (_controller.isAnimating) return;
    // Mulai dari titik siklus sehingga goyangan pertama terjadi setelah initialDelay.
    final startOffset = 1 -
        (widget.initialDelay.inMilliseconds / widget.interval.inMilliseconds)
            .clamp(0.0, 1.0);
    _controller.value = startOffset;
    _controller.forward().whenComplete(() {
      if (mounted) _controller.repeat();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) {
        final t = _controller.value;
        if (t > _activePortion) return child!;
        final p = t / _activePortion; // 0..1
        final angle = math.sin(p * math.pi * 4) * widget.maxAngle * (1 - p);
        return Transform.rotate(
          angle: angle,
          alignment: Alignment.bottomCenter,
          child: child,
        );
      },
    );
  }
}

/// Kilau diagonal ala kartu holo yang lewat sesekali di atas kartu featured.
/// Diletakkan di dalam Stack (Positioned.fill) dan tidak menerima sentuhan.
class HoloSweep extends StatefulWidget {
  const HoloSweep({
    super.key,
    this.interval = const Duration(milliseconds: 5200),
    this.intensity = 0.22,
  });

  final Duration interval;
  final double intensity;

  @override
  State<HoloSweep> createState() => _HoloSweepState();
}

class _HoloSweepState extends State<HoloSweep>
    with SingleTickerProviderStateMixin {
  static const double _activePortion = 0.24;

  late final AnimationController _controller =
      AnimationController(vsync: this, duration: widget.interval);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (AppMotion.reduced(context)) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final bandWidth = width * 0.45;
          return AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              final t = _controller.value;
              if (t > _activePortion) return const SizedBox.shrink();
              final p = Curves.easeInOutCubic.transform(t / _activePortion);
              final dx = -bandWidth * 1.6 + (width + bandWidth * 2.2) * p;
              return Stack(
                clipBehavior: Clip.hardEdge,
                children: [
                  Positioned(
                    left: dx,
                    top: -60,
                    bottom: -60,
                    width: bandWidth,
                    child: Transform.rotate(
                      angle: 0.35,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withValues(alpha: 0),
                              Colors.white.withValues(alpha: widget.intensity),
                              Colors.white.withValues(alpha: 0),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
