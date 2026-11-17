import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../color.dart';
import 'app_motion.dart';

/// Tombol favorit dengan efek "pop" saat diaktifkan.
/// Area sentuh minimal 40x40 walau ikonnya kecil.
class HeartToggle extends StatefulWidget {
  const HeartToggle({
    super.key,
    required this.isActive,
    required this.onChanged,
    this.size = 19,
    this.inactiveColor = black400,
    this.activeColor = errorColor,
    this.background,
  });

  final bool isActive;
  final VoidCallback onChanged;
  final double size;
  final Color inactiveColor;
  final Color activeColor;
  final Color? background;

  @override
  State<HeartToggle> createState() => _HeartToggleState();
}

class _HeartToggleState extends State<HeartToggle>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 420),
  );

  late final Animation<double> _scale = TweenSequence<double>([
    TweenSequenceItem(
      tween:
          Tween(begin: 1.0, end: 1.35).chain(CurveTween(curve: Curves.easeOut)),
      weight: 35,
    ),
    TweenSequenceItem(
      tween: Tween(begin: 1.35, end: 0.92)
          .chain(CurveTween(curve: Curves.easeInOut)),
      weight: 30,
    ),
    TweenSequenceItem(
      tween:
          Tween(begin: 0.92, end: 1.0).chain(CurveTween(curve: Curves.easeOut)),
      weight: 35,
    ),
  ]).animate(_controller);

  @override
  void didUpdateWidget(covariant HeartToggle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.isActive && widget.isActive && !AppMotion.reduced(context)) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final icon = AnimatedSwitcher(
      duration: AppMotion.fast,
      transitionBuilder: (child, animation) =>
          FadeTransition(opacity: animation, child: child),
      child: Icon(
        widget.isActive
            ? Icons.favorite_rounded
            : Icons.favorite_border_rounded,
        key: ValueKey<bool>(widget.isActive),
        size: widget.size,
        color: widget.isActive ? widget.activeColor : widget.inactiveColor,
      ),
    );

    return Semantics(
      button: true,
      toggled: widget.isActive,
      label: widget.isActive ? 'Remove from favorites' : 'Add to favorites',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          HapticFeedback.lightImpact();
          widget.onChanged();
        },
        child: SizedBox(
          width: 40,
          height: 40,
          child: Center(
            child: ScaleTransition(
              scale: _scale,
              child: widget.background == null
                  ? icon
                  : Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: widget.background,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: icon,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
