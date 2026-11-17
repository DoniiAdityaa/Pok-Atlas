import 'dart:async';
import 'dart:ui' show lerpDouble;

import 'package:flutter/widgets.dart';

import 'app_motion.dart';

/// Entrance satu kali: fade + geser halus (+ opsional sedikit scale).
///
/// Dipakai untuk section di Home dan kartu Pokémon saat pertama kali muncul.
/// Set [animate] ke `false` untuk langsung tampil (mis. item yang sudah pernah
/// ditampilkan lalu di-recycle oleh SliverGrid).
class FadeSlideIn extends StatefulWidget {
  const FadeSlideIn({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = AppMotion.slow,
    this.offset = const Offset(0, 18),
    this.scaleFrom = 1.0,
    this.animate = true,
  });

  final Widget child;
  final Duration delay;
  final Duration duration;

  /// Posisi awal relatif (pixel) sebelum bergerak ke posisi akhir.
  final Offset offset;
  final double scaleFrom;
  final bool animate;

  @override
  State<FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<FadeSlideIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: widget.duration);
  late final Animation<double> _progress =
      CurvedAnimation(parent: _controller, curve: AppMotion.enter);
  late final Animation<double> _opacity = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
  );

  Timer? _delayTimer;
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;

    if (!widget.animate || AppMotion.reduced(context)) {
      _controller.value = 1.0;
    } else if (widget.delay == Duration.zero) {
      _controller.forward();
    } else {
      _delayTimer = Timer(widget.delay, () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _delayTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: AnimatedBuilder(
        animation: _progress,
        child: widget.child,
        builder: (context, child) {
          final t = _progress.value;
          Widget result = Transform.translate(
            offset: widget.offset * (1 - t),
            child: child,
          );
          if (widget.scaleFrom != 1.0) {
            result = Transform.scale(
              scale: lerpDouble(widget.scaleFrom, 1.0, t)!,
              child: result,
            );
          }
          return result;
        },
      ),
    );
  }
}
