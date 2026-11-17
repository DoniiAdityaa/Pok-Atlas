import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../color.dart';

/// Gaya mata maskot untuk berbagai pose.
enum MonstraEye { open, happy, closed, heart, spiral, wide }

/// Gaya mulut maskot. [none] = hanya taring.
enum MonstraMouth { none, grin, o }

/// Maskot Monstra yang digambar ulang dengan [CustomPainter] supaya
/// bagian-bagiannya bisa dianimasikan (mata melirik, kedip, telinga goyang).
///
/// Bentuknya mengikuti `assets/images/monstra_mark.svg` (viewBox 200×200).
class MonstraMascot extends StatelessWidget {
  final double size;

  /// Arah lirikan pupil, -1..1 di tiap sumbu. (0, -1) = lihat ke atas.
  final Offset look;

  /// 0 = mata terbuka, 1 = terpejam.
  final double blink;

  /// Sudut goyang telinga dalam radian (positif = telinga mekar keluar).
  final double earTilt;

  /// Tampilkan latar lingkaran gelap seperti logo.
  final bool showBackground;

  /// Latar kotak membulat (seperti ikon app) alih-alih lingkaran.
  final bool roundedTile;

  /// Gaya mata kiri & kanan (default: terbuka biasa).
  final MonstraEye leftEye;
  final MonstraEye rightEye;

  /// Gaya mulut.
  final MonstraMouth mouth;

  /// Putaran mata spiral (radian), dipakai pose pusing.
  final double spin;

  const MonstraMascot({
    super.key,
    this.size = 40,
    this.look = Offset.zero,
    this.blink = 0,
    this.earTilt = 0,
    this.showBackground = true,
    this.roundedTile = false,
    this.leftEye = MonstraEye.open,
    this.rightEye = MonstraEye.open,
    this.mouth = MonstraMouth.none,
    this.spin = 0,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        size: Size.square(size),
        painter: _MonstraPainter(
          look: look,
          blink: blink.clamp(0.0, 1.0),
          earTilt: earTilt,
          showBackground: showBackground,
          roundedTile: roundedTile,
          leftEye: leftEye,
          rightEye: rightEye,
          mouth: mouth,
          spin: spin,
        ),
      ),
    );
  }
}

class _MonstraPainter extends CustomPainter {
  final Offset look;
  final double blink;
  final double earTilt;
  final bool showBackground;
  final bool roundedTile;
  final MonstraEye leftEye;
  final MonstraEye rightEye;
  final MonstraMouth mouth;
  final double spin;

  _MonstraPainter({
    required this.look,
    required this.blink,
    required this.earTilt,
    required this.showBackground,
    required this.roundedTile,
    required this.leftEye,
    required this.rightEye,
    required this.mouth,
    required this.spin,
  });

  static final Path _body = Path()
    ..moveTo(40, 160)
    ..lineTo(40, 72)
    ..quadraticBezierTo(40, 46, 64, 46)
    ..quadraticBezierTo(82, 46, 90, 66)
    ..lineTo(100, 90)
    ..lineTo(110, 66)
    ..quadraticBezierTo(118, 46, 136, 46)
    ..quadraticBezierTo(160, 46, 160, 72)
    ..lineTo(160, 160)
    ..quadraticBezierTo(160, 168, 152, 168)
    ..lineTo(126, 168)
    ..quadraticBezierTo(118, 168, 118, 160)
    ..lineTo(118, 128)
    ..quadraticBezierTo(100, 142, 82, 128)
    ..lineTo(82, 160)
    ..quadraticBezierTo(82, 168, 74, 168)
    ..lineTo(48, 168)
    ..quadraticBezierTo(40, 168, 40, 160)
    ..close();

  static final Path _leftEar = Path()
    ..moveTo(54, 58)
    ..lineTo(46, 28)
    ..lineTo(72, 46)
    ..close();

  static final Path _rightEar = Path()
    ..moveTo(146, 58)
    ..lineTo(154, 28)
    ..lineTo(128, 46)
    ..close();

  static final Path _teeth = Path()
    ..moveTo(88, 132)
    ..lineTo(93, 147)
    ..lineTo(98, 135)
    ..close()
    ..moveTo(102, 135)
    ..lineTo(107, 147)
    ..lineTo(112, 132)
    ..close();

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 200;
    canvas.save();
    canvas.scale(scale);

    if (showBackground) {
      final bgPaint = Paint()..color = nightColor;
      if (roundedTile) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            const Rect.fromLTWH(0, 0, 200, 200),
            const Radius.circular(50),
          ),
          bgPaint,
        );
      } else {
        canvas.drawCircle(const Offset(100, 100), 100, bgPaint);
      }
    }

    // Grup maskot: translate(20 24) scale(0.8), sama seperti SVG.
    canvas.translate(20, 24);
    canvas.scale(0.8);

    final cream = Paint()
      ..color = creamColor
      ..isAntiAlias = true;
    final night = Paint()..color = nightColor;
    final pupil = Paint()..color = secondaryColor;

    // Telinga berputar di pangkalnya.
    _drawRotated(canvas, _leftEar, const Offset(60, 50), -earTilt, cream);
    _drawRotated(canvas, _rightEar, const Offset(140, 50), earTilt, cream);

    canvas.drawPath(_body, cream);
    canvas.drawPath(_teeth, cream);

    // Mata: kedip = oval memipih secara vertikal.
    final eyeScaleY = 1 - blink * 0.88;
    final lookPx = Offset(
      look.dx.clamp(-1.0, 1.0) * 5,
      look.dy.clamp(-1.0, 1.0) * 5,
    );
    final line = Paint()
      ..color = nightColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final eyes = [
      (center: const Offset(68, 92), pupilBase: const Offset(4, 3), style: leftEye),
      (center: const Offset(132, 92), pupilBase: const Offset(-4, 3), style: rightEye),
    ];
    for (final eye in eyes) {
      final c = eye.center;
      switch (eye.style) {
        case MonstraEye.open:
          canvas.drawOval(
            Rect.fromCenter(center: c, width: 30, height: 30 * eyeScaleY),
            night,
          );
          if (blink < 0.6) {
            canvas.drawOval(
              Rect.fromCenter(
                center: c + eye.pupilBase + lookPx,
                width: 14,
                height: 14 * eyeScaleY,
              ),
              pupil,
            );
          }
        case MonstraEye.happy:
          canvas.drawPath(
            Path()
              ..moveTo(c.dx - 12, c.dy + 5)
              ..quadraticBezierTo(c.dx, c.dy - 11, c.dx + 12, c.dy + 5),
            line,
          );
        case MonstraEye.closed:
          canvas.drawPath(
            Path()
              ..moveTo(c.dx - 12, c.dy - 2)
              ..quadraticBezierTo(c.dx, c.dy + 8, c.dx + 12, c.dy - 2),
            line,
          );
        case MonstraEye.heart:
          canvas.drawCircle(c, 15, night);
          canvas.drawPath(_heart(c + const Offset(0, 1), 8.5), pupil);
        case MonstraEye.spiral:
          canvas.drawPath(
            _spiral(c, spin),
            Paint()
              ..color = nightColor
              ..style = PaintingStyle.stroke
              ..strokeWidth = 3.5
              ..strokeCap = StrokeCap.round,
          );
        case MonstraEye.wide:
          canvas.drawCircle(c, 18, night);
          canvas.drawCircle(c + lookPx * 0.6, 5, pupil);
      }
    }

    // Mulut.
    switch (mouth) {
      case MonstraMouth.none:
        break;
      case MonstraMouth.grin:
        canvas.drawPath(
          Path()
            ..moveTo(86, 106)
            ..quadraticBezierTo(100, 128, 114, 106)
            ..close(),
          night,
        );
      case MonstraMouth.o:
        canvas.drawOval(
          Rect.fromCenter(center: const Offset(100, 114), width: 14, height: 18),
          night,
        );
    }

    canvas.restore();
  }

  static Path _heart(Offset c, double s) {
    return Path()
      ..moveTo(c.dx, c.dy + s * 0.9)
      ..cubicTo(c.dx - s * 1.7, c.dy - s * 0.2, c.dx - s * 0.9, c.dy - s * 1.4,
          c.dx, c.dy - s * 0.45)
      ..cubicTo(c.dx + s * 0.9, c.dy - s * 1.4, c.dx + s * 1.7, c.dy - s * 0.2,
          c.dx, c.dy + s * 0.9)
      ..close();
  }

  static Path _spiral(Offset c, double spin) {
    final path = Path();
    const steps = 40;
    for (var i = 0; i <= steps; i++) {
      final t = i / steps;
      final a = spin + t * 2.5 * 2 * math.pi;
      final r = 2 + t * 11;
      final p = c + Offset(math.cos(a) * r, math.sin(a) * r);
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    return path;
  }

  void _drawRotated(
    Canvas canvas,
    Path path,
    Offset pivot,
    double angle,
    Paint paint,
  ) {
    if (angle == 0) {
      canvas.drawPath(path, paint);
      return;
    }
    canvas.save();
    canvas.translate(pivot.dx, pivot.dy);
    canvas.rotate(angle);
    canvas.translate(-pivot.dx, -pivot.dy);
    canvas.drawPath(path, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_MonstraPainter old) =>
      old.look != look ||
      old.blink != blink ||
      old.earTilt != earTilt ||
      old.showBackground != showBackground ||
      old.roundedTile != roundedTile ||
      old.leftEye != leftEye ||
      old.rightEye != rightEye ||
      old.mouth != mouth ||
      old.spin != spin;
}

/// Monstra yang "hidup" sendiri: melompat kecil, kedip, telinga goyang.
/// Dipakai saat refresh berlangsung, dan bisa dipakai sebagai loader umum.
class MonstraLoader extends StatefulWidget {
  final double size;
  final bool showBackground;

  const MonstraLoader({super.key, this.size = 40, this.showBackground = true});

  @override
  State<MonstraLoader> createState() => _MonstraLoaderState();
}

class _MonstraLoaderState extends State<MonstraLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.of(context).disableAnimations) {
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
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value;
        // Dua lompatan per siklus, dengan squash saat mendarat.
        final hopPhase = (t * 2) % 1;
        final hop = math.sin(hopPhase * math.pi);
        final squash = hopPhase < 0.12 || hopPhase > 0.88 ? 0.06 : 0.0;
        // Kedip singkat di akhir siklus.
        final blink =
            t > 0.86 && t < 0.96 ? math.sin((t - 0.86) / 0.1 * math.pi) : 0.0;
        // Mata melirik kiri-kanan pelan.
        final look = Offset(math.sin(t * 2 * math.pi) * 0.8, -0.3);

        return Transform.translate(
          offset: Offset(0, -hop * widget.size * 0.12),
          child: Transform.scale(
            scaleX: 1 + squash,
            scaleY: 1 - squash,
            alignment: Alignment.bottomCenter,
            child: MonstraMascot(
              size: widget.size,
              look: look,
              blink: blink,
              earTilt: hop * 0.18,
              showBackground: widget.showBackground,
            ),
          ),
        );
      },
    );
  }
}

/// Monstra yang bingung: celingukan kiri-kanan, kepala miring, telinga
/// turun, dan tanda "?" mengambang. Dipakai di empty state / no result.
class MonstraConfused extends StatefulWidget {
  final double size;

  const MonstraConfused({super.key, this.size = 72});

  @override
  State<MonstraConfused> createState() => _MonstraConfusedState();
}

class _MonstraConfusedState extends State<MonstraConfused>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3200),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.of(context).disableAnimations) {
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

  /// Lirikan: tahan di kiri → pindah → tahan di kanan → balik tengah.
  double _lookX(double t) {
    double ease(double x) => Curves.easeInOutCubic.transform(x.clamp(0, 1));
    if (t < 0.10) return -ease(t / 0.10);
    if (t < 0.38) return -1;
    if (t < 0.50) return -1 + 2 * ease((t - 0.38) / 0.12);
    if (t < 0.78) return 1;
    if (t < 0.90) return 1 - ease((t - 0.78) / 0.12);
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.size;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value;
        final lookX = _lookX(t);
        // Kedip dua kali cepat saat kembali ke tengah.
        final blink = t > 0.92
            ? math.sin(((t - 0.92) / 0.08) * 2 * math.pi).abs()
            : 0.0;
        final bob = math.sin(t * 4 * math.pi);

        return SizedBox(
          width: size * 1.35,
          height: size * 1.25,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.bottomCenter,
            children: [
              // Bayangan lantai.
              Positioned(
                bottom: 0,
                child: Container(
                  width: size * (0.62 + bob * 0.02),
                  height: size * 0.08,
                  decoration: BoxDecoration(
                    color: nightColor.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(size),
                  ),
                ),
              ),
              Positioned(
                bottom: size * 0.05,
                child: Transform.rotate(
                  angle: lookX * 0.10,
                  alignment: Alignment.bottomCenter,
                  child: MonstraMascot(
                    size: size,
                    look: Offset(lookX, 0.2),
                    blink: blink,
                    // Telinga sedikit layu (miring ke dalam).
                    earTilt: -0.12 + bob * 0.03,
                  ),
                ),
              ),
              // Tanda tanya mengambang di atas kepala.
              Positioned(
                top: bob * 3,
                right: lookX > 0 ? null : 0,
                left: lookX > 0 ? 0 : null,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Text(
                    '?',
                    key: ValueKey(lookX > 0),
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w800,
                      fontSize: size * 0.34,
                      height: 1,
                      color: secondaryColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
