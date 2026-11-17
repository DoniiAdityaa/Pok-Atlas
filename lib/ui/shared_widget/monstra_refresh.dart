import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../color.dart';
import 'monstra_badge_loader.dart';

/// Pull-to-refresh khas Monstra (pengganti [RefreshIndicator]).
///
/// - Saat ditarik: badge maskot turun dan membesar mengikuti tarikan (diam).
/// - Saat memuat: maskot melompat + cincin oranye berputar.
///
/// Bungkus scroll view vertikal apa pun. Supaya tetap bisa ditarik walau
/// kontennya pendek, pakai `AlwaysScrollableScrollPhysics`.
class MonstraRefresh extends StatelessWidget {
  const MonstraRefresh({
    super.key,
    required this.onRefresh,
    required this.child,
  });

  final Future<void> Function() onRefresh;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CustomMaterialIndicator(
      onRefresh: () async {
        HapticFeedback.lightImpact();
        await onRefresh();
      },
      backgroundColor: bgLight,
      indicatorBuilder: (context, controller) {
        final isLoading = controller.state.isLoading;
        final pull = controller.value.clamp(0.0, 1.0).toDouble();
        return Padding(
          padding: const EdgeInsets.all(2),
          child: Transform.scale(
            scale: isLoading ? 1.0 : 0.5 + (0.5 * pull),
            child: MonstraBadgeLoader(size: 36, animate: isLoading),
          ),
        );
      },
      child: child,
    );
  }
}
