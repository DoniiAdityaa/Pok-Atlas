import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../color.dart';
import '../typography.dart';

/// Layar sukses ala "Account synced": lingkaran centang yang membesar
/// + confetti meledak dari tengah.
///
/// Pakai:
/// ```dart
/// MonstraSuccess.show(
///   context,
///   title: 'Tim tersimpan!',
///   message: 'Tim kamu sudah masuk ke daftar.',
/// );
/// ```
class MonstraSuccess extends StatefulWidget {
  const MonstraSuccess({
    super.key,
    required this.title,
    required this.message,
    this.icon,
  });

  final String title;
  final String message;

  /// Ganti lingkaran centang dengan widget lain, misalnya maskot pose "cheer".
  final Widget? icon;

  static Future<void> show(
    BuildContext context, {
    required String title,
    required String message,
    Widget? icon,
  }) {
    return Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.white,
        transitionDuration: const Duration(milliseconds: 250),
        pageBuilder: (_, __, ___) =>
            MonstraSuccess(title: title, message: message, icon: icon),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
    );
  }

  @override
  State<MonstraSuccess> createState() => _MonstraSuccessState();
}

class _MonstraSuccessState extends State<MonstraSuccess>
    with SingleTickerProviderStateMixin {
  late final ConfettiController _confetti =
      ConfettiController(duration: const Duration(milliseconds: 600));

  // 0.0 → 1.0 dalam 900 ms: lingkaran pop, centang tergambar, teks muncul.
  late final AnimationController _anim = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  late final Animation<double> _circle = CurvedAnimation(
    parent: _anim,
    curve: const Interval(0.0, 0.45, curve: Curves.elasticOut),
  );
  late final Animation<double> _check = CurvedAnimation(
    parent: _anim,
    curve: const Interval(0.35, 0.7, curve: Curves.easeOut),
  );
  late final Animation<double> _text = CurvedAnimation(
    parent: _anim,
    curve: const Interval(0.55, 1.0, curve: Curves.easeOut),
  );

  @override
  void initState() {
    super.initState();
    _anim.forward();
    // Confetti meledak tepat saat lingkaran "pop".
    Future.delayed(const Duration(milliseconds: 180), () {
      if (!mounted) return;
      _confetti.play();
      HapticFeedback.mediumImpact();
    });
    // Tutup otomatis setelah 2,2 detik.
    Future.delayed(const Duration(milliseconds: 2200), () {
      if (mounted) Navigator.of(context).maybePop();
    });
  }

  @override
  void dispose() {
    _confetti.dispose();
    _anim.dispose();
    super.dispose();
  }

  /// Bentuk confetti: pil kecil membulat seperti di contoh.
  Path _pill(Size size) {
    return Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(0, 0, 6, 16),
          const Radius.circular(3),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgLight,
      body: GestureDetector(
        onTap: () => Navigator.of(context).maybePop(),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ScaleTransition(
                    scale: _circle,
                    child: widget.icon ??
                        Container(
                          width: 112,
                          height: 112,
                          decoration: const BoxDecoration(
                            color: primaryColor,
                            shape: BoxShape.circle,
                          ),
                          child: AnimatedBuilder(
                            animation: _check,
                            builder: (_, __) => CustomPaint(
                              painter: _CheckPainter(progress: _check.value),
                            ),
                          ),
                        ),
                  ),
                  const SizedBox(height: 28),
                  FadeTransition(
                    opacity: _text,
                    child: SlideTransition(
                      position: Tween(
                        begin: const Offset(0, 0.3),
                        end: Offset.zero,
                      ).animate(_text),
                      child: Column(
                        children: [
                          Text(
                            widget.title,
                            style: lBold.copyWith(color: textNeutralPrimary),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 40),
                            child: Text(
                              widget.message,
                              style:
                                  smRegular.copyWith(color: textNeutralSecondary),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Confetti di atas semuanya, meledak dari tengah.
            ConfettiWidget(
              confettiController: _confetti,
              blastDirectionality: BlastDirectionality.explosive,
              numberOfParticles: 40,
              emissionFrequency: 0.05,
              maxBlastForce: 28,
              minBlastForce: 10,
              gravity: 0.25,
              shouldLoop: false,
              createParticlePath: _pill,
              colors: const [
                primaryColor, // indigo
                secondaryColor, // oranye
                sunglow400, // kuning
                Color(0xFF7FF0C3), // mint
                Color(0xFFB79CFF), // ungu muda
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Menggambar centang putih yang "tertulis" dari kiri ke kanan.
class _CheckPainter extends CustomPainter {
  _CheckPainter({required this.progress});
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final path = Path()
      ..moveTo(w * 0.30, w * 0.52)
      ..lineTo(w * 0.44, w * 0.66)
      ..lineTo(w * 0.72, w * 0.38);
    final metric = path.computeMetrics().first;
    final partial = metric.extractPath(0, metric.length * min(progress, 1.0));
    canvas.drawPath(
      partial,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.08
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(_CheckPainter old) => old.progress != progress;
}
