import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

/// Loader maskot Monstra versi badge: maskot melompat di lingkaran gelap
/// dengan cincin oranye berputar (Lottie `monstra_loader.json`).
///
/// Dipakai oleh [MonstraRefresh]; bisa juga dipakai sebagai loading biasa:
/// ```dart
/// const Center(child: MonstraBadgeLoader(size: 56))
/// ```
class MonstraBadgeLoader extends StatelessWidget {
  const MonstraBadgeLoader({
    super.key,
    this.size = 56,
    this.animate = true,
  });

  final double size;

  /// `false` = diam di frame pertama (dipakai saat layar sedang ditarik).
  final bool animate;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    return Semantics(
      label: 'Memuat',
      child: SizedBox.square(
        dimension: size,
        child: Lottie.asset(
          'assets/animation/monstra_loader.json',
          animate: animate && !reduceMotion,
          repeat: true,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
