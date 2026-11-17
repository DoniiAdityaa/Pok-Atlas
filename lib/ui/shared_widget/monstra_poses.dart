import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../color.dart';
import '../typography.dart';
import 'monstra_mascot.dart';

/// Kumpulan pose maskot Monstra yang bergerak sendiri.
///
/// | Widget              | Dipakai di                                   |
/// |---------------------|----------------------------------------------|
/// | [MonstraHug]        | Tab Favorit masih kosong                     |
/// | [MonstraLove]       | Toast "Disimpan ke Favorit" ([MonstraToast]) |
/// | [MonstraDizzy]      | Error / gagal memuat / offline               |
/// | [MonstraSleepy]     | Mode malam (dipakai [MonstraHeaderLogo])     |
/// | [MonstraCheer]      | Pemenang di Compare                          |
/// | [MonstraWave]       | Sapaan (Settings / About / onboarding)       |
/// | [MonstraHeaderLogo] | Logo header Home: ketuk = kaget + tips       |
///
/// Semua pose otomatis diam kalau user mematikan animasi di HP
/// (`MediaQuery.disableAnimations`).

// ─────────────────────────── Helper loop ───────────────────────────

/// Menjalankan [builder] dengan nilai t 0..1 yang berulang.
class _Loop extends StatefulWidget {
  const _Loop({required this.duration, required this.builder});

  final Duration duration;
  final Widget Function(BuildContext context, double t) builder;

  @override
  State<_Loop> createState() => _LoopState();
}

class _LoopState extends State<_Loop> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: widget.duration);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.of(context).disableAnimations) {
      _c.stop();
    } else if (!_c.isAnimating) {
      _c.repeat();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) => widget.builder(context, _c.value),
    );
  }
}

double _wave(double t, [double cycles = 1]) => math.sin(t * 2 * math.pi * cycles);

// ─────────────────────────── Pose: Hug ───────────────────────────

/// Memeluk hati yang berdetak. Untuk tab Favorit yang masih kosong.
class MonstraHug extends StatelessWidget {
  const MonstraHug({super.key, this.size = 76});

  final double size;

  @override
  Widget build(BuildContext context) {
    return _Loop(
      duration: const Duration(milliseconds: 1400),
      builder: (context, t) {
        // Detak ganda: dug-dug ... jeda.
        double beat = 0;
        if (t < 0.15) beat = math.sin(t / 0.15 * math.pi);
        if (t > 0.22 && t < 0.37) beat = math.sin((t - 0.22) / 0.15 * math.pi) * 0.7;
        return SizedBox(
          width: size,
          height: size,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Transform.scale(
                scale: 1 + beat * 0.025,
                child: MonstraMascot(
                  size: size,
                  leftEye: MonstraEye.happy,
                  rightEye: MonstraEye.happy,
                  earTilt: beat * 0.08,
                ),
              ),
              Positioned(
                bottom: size * 0.10,
                child: Transform.scale(
                  scale: 1 + beat * 0.18,
                  child: Icon(
                    Icons.favorite_rounded,
                    size: size * 0.36,
                    color: secondaryColor,
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

// ─────────────────────────── Pose: Love ───────────────────────────

/// Mata hati + hati kecil melayang. Dipakai di [MonstraToast].
class MonstraLove extends StatelessWidget {
  const MonstraLove({super.key, this.size = 44});

  final double size;

  @override
  Widget build(BuildContext context) {
    return _Loop(
      duration: const Duration(milliseconds: 1600),
      builder: (context, t) {
        final hop = math.max(0.0, _wave(t, 2));
        return SizedBox(
          width: size * 1.35,
          height: size * 1.25,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.bottomCenter,
            children: [
              Transform.translate(
                offset: Offset(0, -hop * size * 0.06),
                child: MonstraMascot(
                  size: size,
                  leftEye: MonstraEye.heart,
                  rightEye: MonstraEye.heart,
                  earTilt: hop * 0.15,
                ),
              ),
              for (var k = 0; k < 2; k++)
                Builder(builder: (context) {
                  final phase = (t + k * 0.5) % 1.0;
                  return Positioned(
                    top: size * 0.45 * (1 - phase),
                    left: k == 0 ? 0 : null,
                    right: k == 1 ? 0 : null,
                    child: Opacity(
                      opacity: (1 - phase).clamp(0.0, 1.0).toDouble(),
                      child: Icon(
                        Icons.favorite_rounded,
                        size: size * 0.24,
                        color: secondaryColor,
                      ),
                    ),
                  );
                }),
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────── Pose: Dizzy ───────────────────────────

/// Pusing: mata spiral berputar, badan goyang, keringat. Untuk error/offline.
class MonstraDizzy extends StatelessWidget {
  const MonstraDizzy({super.key, this.size = 76});

  final double size;

  @override
  Widget build(BuildContext context) {
    return _Loop(
      duration: const Duration(milliseconds: 1400),
      builder: (context, t) {
        final sway = _wave(t);
        return SizedBox(
          width: size * 1.25,
          height: size * 1.15,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.bottomCenter,
            children: [
              Transform.rotate(
                angle: sway * 0.09,
                alignment: Alignment.bottomCenter,
                child: MonstraMascot(
                  size: size,
                  leftEye: MonstraEye.spiral,
                  rightEye: MonstraEye.spiral,
                  spin: t * 2 * math.pi,
                  earTilt: -0.15 + sway * 0.05,
                ),
              ),
              Positioned(
                top: size * 0.02 + (sway.abs() * 3),
                right: 0,
                child: Icon(
                  Icons.water_drop_rounded,
                  size: size * 0.2,
                  color: const Color(0xFF9CC3FF),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────── Pose: Sleepy ───────────────────────────

/// Ngantuk: mata terpejam, napas pelan, huruf "z" melayang.
class MonstraSleepy extends StatelessWidget {
  const MonstraSleepy({super.key, this.size = 76, this.roundedTile = false});

  final double size;
  final bool roundedTile;

  @override
  Widget build(BuildContext context) {
    return _Loop(
      duration: const Duration(milliseconds: 2800),
      builder: (context, t) {
        final breathe = _wave(t);
        return SizedBox(
          width: size,
          height: size,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              MonstraMascot(
                size: size,
                roundedTile: roundedTile,
                leftEye: MonstraEye.closed,
                rightEye: MonstraEye.closed,
                earTilt: -0.1 + breathe * 0.04,
              ),
              for (var k = 0; k < 2; k++)
                Builder(builder: (context) {
                  final phase = (t + k * 0.5) % 1.0;
                  return Positioned(
                    right: -size * 0.12 - phase * size * 0.12,
                    top: -phase * size * 0.35,
                    child: Opacity(
                      opacity: math.sin(phase * math.pi),
                      child: Text(
                        'z',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w700,
                          fontSize: size * (0.22 + phase * 0.12),
                          height: 1,
                          color: primaryColor,
                        ),
                      ),
                    ),
                  );
                }),
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────── Pose: Cheer ───────────────────────────

/// Bersorak: lompat, mulut lebar, mahkota & kilau. Untuk pemenang Compare.
class MonstraCheer extends StatelessWidget {
  const MonstraCheer({super.key, this.size = 56});

  final double size;

  @override
  Widget build(BuildContext context) {
    return _Loop(
      duration: const Duration(milliseconds: 1100),
      builder: (context, t) {
        final hop = math.max(0.0, _wave(t));
        final sparkle = (math.sin(t * 2 * math.pi) + 1) / 2;
        return SizedBox(
          width: size * 1.5,
          height: size * 1.45,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.bottomCenter,
            children: [
              Transform.translate(
                offset: Offset(0, -hop * size * 0.14),
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.topCenter,
                  children: [
                    MonstraMascot(
                      size: size,
                      leftEye: MonstraEye.happy,
                      rightEye: MonstraEye.happy,
                      mouth: MonstraMouth.grin,
                      earTilt: hop * 0.2,
                    ),
                    Positioned(
                      top: -size * 0.24,
                      child: SvgPicture.asset(
                        'assets/images/icons/crown.svg',
                        width: size * 0.34,
                        colorFilter: const ColorFilter.mode(
                          sunglow400,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                left: 0,
                top: size * 0.25,
                child: Opacity(
                  opacity: sparkle,
                  child: Icon(Icons.auto_awesome_rounded,
                      size: size * 0.22, color: secondaryColor),
                ),
              ),
              Positioned(
                right: 0,
                top: size * 0.05,
                child: Opacity(
                  opacity: 1 - sparkle,
                  child: Icon(Icons.auto_awesome_rounded,
                      size: size * 0.18, color: sunglow400),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────── Pose: Wave ───────────────────────────

/// Menyapa: satu mata berkedip, tangan melambai. Untuk Settings/About/onboarding.
class MonstraWave extends StatelessWidget {
  const MonstraWave({super.key, this.size = 76});

  final double size;

  @override
  Widget build(BuildContext context) {
    return _Loop(
      duration: const Duration(milliseconds: 1600),
      builder: (context, t) {
        final rock = _wave(t);
        final waveHand = _wave(t, 2);
        return SizedBox(
          width: size * 1.3,
          height: size,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.centerLeft,
            children: [
              Transform.rotate(
                angle: rock * 0.05,
                alignment: Alignment.bottomCenter,
                child: MonstraMascot(
                  size: size,
                  rightEye: MonstraEye.happy,
                  earTilt: 0.05 + rock * 0.05,
                ),
              ),
              Positioned(
                right: 0,
                top: size * 0.08,
                child: Transform.rotate(
                  angle: waveHand * 0.35,
                  alignment: Alignment.bottomLeft,
                  child: Icon(
                    Icons.waving_hand_rounded,
                    size: size * 0.32,
                    color: sunglow400,
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

// ─────────────────────────── Header logo ───────────────────────────

/// Logo header Home yang interaktif.
///
/// - Diam: maskot sesekali berkedip.
/// - Diketuk: maskot kaget + melompat, lalu balon tips muncul di bawahnya.
/// - Jam 21.00–05.00: maskot ngantuk (mata terpejam + "z").
class MonstraHeaderLogo extends StatefulWidget {
  const MonstraHeaderLogo({
    super.key,
    this.height = 34,
    this.tips = defaultTips,
  });

  final double height;
  final List<String> tips;

  static const List<String> defaultTips = [
    'Ketuk ikon hati untuk menyimpan monster favoritmu.',
    'Tarik layar ke bawah untuk memuat ulang data.',
    'Coba Compare untuk adu stat dua monster.',
    'Malam hari aku ikut ngantuk, lho.',
  ];

  @override
  State<MonstraHeaderLogo> createState() => _MonstraHeaderLogoState();
}

class _MonstraHeaderLogoState extends State<MonstraHeaderLogo>
    with TickerProviderStateMixin {
  late final AnimationController _hop = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 600),
  );
  late final AnimationController _idle = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 4200),
  );

  bool _surprised = false;
  int _tipIndex = 0;
  OverlayEntry? _bubble;
  Timer? _timer;

  bool get _isNight {
    final hour = DateTime.now().hour;
    return hour >= 21 || hour < 5;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.of(context).disableAnimations) {
      _idle.stop();
    } else if (!_idle.isAnimating) {
      _idle.repeat();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _removeTip();
    _hop.dispose();
    _idle.dispose();
    super.dispose();
  }

  void _onTap() {
    HapticFeedback.lightImpact();
    setState(() => _surprised = true);
    _hop.forward(from: 0);
    _showTip();
    _timer?.cancel();
    _timer = Timer(const Duration(milliseconds: 2600), () {
      if (!mounted) return;
      setState(() => _surprised = false);
      _removeTip();
    });
  }

  void _showTip() {
    _removeTip();
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.attached || widget.tips.isEmpty) return;
    final origin = box.localToGlobal(Offset.zero);
    final text = widget.tips[_tipIndex % widget.tips.length];
    _tipIndex++;
    const bubbleWidth = 240.0;
    _bubble = OverlayEntry(
      builder: (_) => Positioned(
        top: origin.dy + box.size.height + 8,
        left: origin.dx + box.size.width / 2 - bubbleWidth / 2,
        width: bubbleWidth,
        child: IgnorePointer(child: _TipBubble(text: text)),
      ),
    );
    Overlay.of(context).insert(_bubble!);
  }

  void _removeTip() {
    _bubble?.remove();
    _bubble = null;
  }

  @override
  Widget build(BuildContext context) {
    final h = widget.height;
    return Semantics(
      button: true,
      label: 'Monstra. Ketuk untuk tips',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _onTap,
        child: AnimatedBuilder(
          animation: Listenable.merge([_hop, _idle]),
          builder: (context, _) {
            final hop = math.sin(_hop.value * math.pi);
            final t = _idle.value;
            final blink = t > 0.94 ? math.sin((t - 0.94) / 0.06 * math.pi) : 0.0;
            final sleepy = _isNight && !_surprised;

            final MonstraEye eye = _surprised
                ? MonstraEye.wide
                : (sleepy ? MonstraEye.closed : MonstraEye.open);

            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Transform.translate(
                  offset: Offset(0, -hop * h * 0.2),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      MonstraMascot(
                        size: h,
                        roundedTile: true,
                        leftEye: eye,
                        rightEye: eye,
                        mouth: _surprised ? MonstraMouth.o : MonstraMouth.none,
                        blink: blink,
                        earTilt: hop * 0.25,
                      ),
                      if (sleepy)
                        Positioned(
                          right: -h * 0.18,
                          top: -h * 0.22 - math.sin(t * 2 * math.pi) * 2,
                          child: Text(
                            'z',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w700,
                              fontSize: h * 0.36,
                              height: 1,
                              color: primaryColor,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                SizedBox(width: h * 0.24),
                SvgPicture.asset(
                  'assets/images/monstra_wordmark.svg',
                  height: h * 0.62,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _TipBubble extends StatelessWidget {
  const _TipBubble({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      builder: (context, v, child) => Opacity(
        opacity: v,
        child: Transform.translate(offset: Offset(0, (1 - v) * -6), child: child),
      ),
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          decoration: BoxDecoration(
            color: nightColor,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: nightColor.withValues(alpha: 0.25),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: xsMedium.copyWith(color: creamColor, height: 1.45),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────── Toast favorit ───────────────────────────

/// Pop-up kecil dari bawah dengan maskot bermata hati.
///
/// ```dart
/// MonstraToast.show(context, title: 'Disimpan ke Favorit!',
///     subtitle: '$name sekarang ada di Favorit');
/// ```
class MonstraToast {
  MonstraToast._();

  static OverlayEntry? _current;

  static void show(
    BuildContext context, {
    required String title,
    String? subtitle,
    Duration duration = const Duration(milliseconds: 1800),
  }) {
    HapticFeedback.lightImpact();
    _current?.remove();
    _current = null;

    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _MonstraToastView(
        title: title,
        subtitle: subtitle,
        duration: duration,
        onDone: () {
          if (_current == entry) {
            entry.remove();
            _current = null;
          }
        },
      ),
    );
    _current = entry;
    Overlay.of(context).insert(entry);
  }
}

class _MonstraToastView extends StatefulWidget {
  const _MonstraToastView({
    required this.title,
    required this.subtitle,
    required this.duration,
    required this.onDone,
  });

  final String title;
  final String? subtitle;
  final Duration duration;
  final VoidCallback onDone;

  @override
  State<_MonstraToastView> createState() => _MonstraToastViewState();
}

class _MonstraToastViewState extends State<_MonstraToastView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 380),
    reverseDuration: const Duration(milliseconds: 240),
  );
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _c.forward();
    _timer = Timer(widget.duration, () async {
      if (!mounted) return;
      await _c.reverse();
      widget.onDone();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final anim = CurvedAnimation(
      parent: _c,
      curve: Curves.easeOutBack,
      reverseCurve: Curves.easeInCubic,
    );
    return Positioned(
      left: 16,
      right: 16,
      bottom: bottomInset + 96,
      child: FadeTransition(
        opacity: _c,
        child: SlideTransition(
          position: Tween(begin: const Offset(0, 0.6), end: Offset.zero)
              .animate(anim),
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.fromLTRB(10, 8, 16, 8),
              decoration: BoxDecoration(
                color: nightColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: nightColor.withValues(alpha: 0.3),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const MonstraLove(size: 40),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: smMedium.copyWith(
                            color: creamColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (widget.subtitle != null)
                          Text(
                            widget.subtitle!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: xsRegular.copyWith(color: jacarta200),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
