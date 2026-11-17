import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_motion.dart';

/// Pengganti InkWell untuk kartu & tombol: mengecil sedikit saat ditekan lalu
/// memantul halus saat dilepas. Memberi rasa "fisik" tanpa ripple yang ramai.
class Pressable extends StatefulWidget {
  const Pressable({
    super.key,
    required this.child,
    this.onTap,
    this.pressedScale = 0.96,
    this.haptic = true,
    this.semanticLabel,
  });

  final Widget child;
  final VoidCallback? onTap;
  final double pressedScale;
  final bool haptic;
  final String? semanticLabel;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable>
    with SingleTickerProviderStateMixin {
  // value 0 = normal, 1 = fully pressed
  late final AnimationController _controller = AnimationController(
    vsync: this,
    lowerBound: 0,
    upperBound: 1,
  );

  bool get _enabled => widget.onTap != null && !AppMotion.reduced(context);

  void _pressDown() {
    if (!_enabled) return;
    _controller.animateTo(
      1,
      duration: const Duration(milliseconds: 90),
      curve: Curves.easeOut,
    );
  }

  void _release() {
    if (!_enabled) return;
    // Pastikan efek "tekan" sempat terlihat walau tap sangat cepat.
    final remaining = 1 - _controller.value;
    final pressFuture = remaining > 0.01
        ? _controller.animateTo(
            1,
            duration: Duration(milliseconds: (70 * remaining).round() + 1),
          )
        : Future<void>.value();
    pressFuture.whenComplete(() {
      if (!mounted) return;
      _controller.animateTo(
        0,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutBack,
      );
    });
  }

  void _cancel() {
    if (!_enabled) return;
    _controller.animateTo(
      0,
      duration: AppMotion.fast,
      curve: AppMotion.standard,
    );
  }

  void _handleTap() {
    if (widget.haptic) HapticFeedback.selectionClick();
    widget.onTap?.call();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: widget.onTap != null,
      label: widget.semanticLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => _pressDown(),
        onTapUp: (_) => _release(),
        onTapCancel: _cancel,
        onTap: widget.onTap == null ? null : _handleTap,
        child: AnimatedBuilder(
          animation: _controller,
          child: widget.child,
          builder: (context, child) {
            final scale = 1 - (1 - widget.pressedScale) * _controller.value;
            return Transform.scale(scale: scale, child: child);
          },
        ),
      ),
    );
  }
}
