import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../color.dart';
import '../motion/motion.dart';
import '../typography.dart';

/// Tombol bulat 44x44 standar PokéAtlas (putih, border tipis, bayangan halus).
///
/// Dipakai untuk tombol back, aksi di header (Pokéball surprise, dll).
/// Isi dengan [icon], [imageAsset], atau [child] (mis. animasi Lottie).
class AppCircleButton extends StatelessWidget {
  const AppCircleButton({
    super.key,
    required this.onTap,
    this.icon,
    this.imageAsset,
    this.child,
    this.tooltip,
    this.size = 44,
    this.iconSize = 18,
    this.iconColor = bgDark,
    this.backgroundColor = bgLight,
  }) : assert(icon != null || imageAsset != null || child != null);

  final VoidCallback onTap;
  final IconData? icon;
  final String? imageAsset;

  /// Isi kustom, menggantikan [icon]/[imageAsset].
  final Widget? child;
  final String? tooltip;
  final double size;
  final double iconSize;
  final Color iconColor;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    final button = Pressable(
      haptic: false,
      pressedScale: 0.88,
      semanticLabel: tooltip,
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
          border: Border.all(
            color: borderNeutral.withValues(alpha: 0.8),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: child ??
            (imageAsset != null
            ? Image.asset(
                imageAsset!,
                width: iconSize + 4,
                height: iconSize + 4,
                fit: BoxFit.contain,
              )
            : Icon(icon, size: iconSize, color: iconColor)),
      ),
    );

    if (tooltip == null) return button;
    return Tooltip(message: tooltip!, child: button);
  }
}

/// Tombol kapsul kecil berisi ikon maskot Monstra (putih, border tipis).
///
/// Satu gaya untuk aksi "Surprise / acak" — dipakai di header Home dan
/// sheet pilih Pokémon di Compare. Statis, tanpa animasi berulang.
class AppPillButton extends StatelessWidget {
  const AppPillButton({
    super.key,
    required this.onTap,
    this.imageAsset = 'assets/images/icons/monstra_mark.png',
    this.iconSize = 16,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    this.tooltip,
  });

  final VoidCallback onTap;
  final String imageAsset;
  final double iconSize;
  final EdgeInsetsGeometry padding;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final button = Pressable(
      haptic: false,
      pressedScale: 0.9,
      semanticLabel: tooltip,
      onTap: () {
        HapticFeedback.mediumImpact();
        onTap();
      },
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: bgLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderNeutral, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Image.asset(
          imageAsset,
          width: iconSize,
          height: iconSize,
          fit: BoxFit.contain,
        ),
      ),
    );

    if (tooltip == null) return button;
    return Tooltip(message: tooltip!, child: button);
  }
}

/// Tombol kembali bulat — satu gaya untuk semua layar.
///
/// Default-nya memanggil `Navigator.maybePop`, override lewat [onTap].
class AppBackButton extends StatelessWidget {
  const AppBackButton({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return AppCircleButton(
      icon: Icons.arrow_back_ios_new_rounded,
      tooltip: 'Back',
      onTap: onTap ?? () => Navigator.maybePop(context),
    );
  }
}

/// Header halaman standar: [AppBackButton] — judul di tengah — aksi kanan.
///
/// Kalau [trailing] kosong, sisi kanan diisi spacer 44px supaya judul tetap
/// presisi di tengah. Set [titleVisible] ke `false` untuk menyembunyikan judul
/// dengan animasi (mis. saat judul besar masih terlihat di konten).
class AppPageHeader extends StatelessWidget {
  const AppPageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onBack,
    this.titleVisible = true,
    this.padding = const EdgeInsets.fromLTRB(20, 12, 20, 8),
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onBack;
  final bool titleVisible;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        children: [
          AppBackButton(onTap: onBack),
          const SizedBox(width: 12),
          Expanded(
            child: AnimatedSlide(
              offset: titleVisible ? Offset.zero : const Offset(0, 0.25),
              duration: AppMotion.medium,
              curve: AppMotion.standard,
              child: AnimatedOpacity(
                opacity: titleVisible ? 1 : 0,
                duration: AppMotion.medium,
                curve: AppMotion.standard,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: mBold.copyWith(
                        color: textNeutralPrimary,
                        fontSize: 18,
                        letterSpacing: -0.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      // Subtitle berganti dengan fade + geser halus
                      AnimatedSwitcher(
                        duration: AppMotion.medium,
                        switchInCurve: AppMotion.enter,
                        transitionBuilder: (child, animation) => FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, 0.5),
                              end: Offset.zero,
                            ).animate(animation),
                            child: child,
                          ),
                        ),
                        child: Text(
                          subtitle!,
                          key: ValueKey<String>(subtitle!),
                          style: xxsRegular.copyWith(
                            color: black500,
                            fontSize: 11,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          trailing ?? const SizedBox(width: 44, height: 44),
        ],
      ),
    );
  }
}
