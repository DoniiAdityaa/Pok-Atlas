import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../ui/color.dart';
import '../../../ui/typography.dart';
import '../model/generation_model.dart';

/// Shared Widget untuk Kartu Generasi Pokémon.
///
/// Digunakan di:
/// 1. [GenerationScreen] — mode list dengan tombol Explore & tap navigation
/// 2. [RegionDetailScreen] — mode hero banner tanpa tombol Explore
class GenerationCard extends StatelessWidget {
  final GenerationModel generation;
  final VoidCallback? onTap;
  final bool showExploreButton;
  final double? height;
  final EdgeInsetsGeometry margin;

  const GenerationCard({
    super.key,
    required this.generation,
    this.onTap,
    this.showExploreButton = true,
    this.height = 198,
    this.margin = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    final gen = generation;

    final cardContent = Container(
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gen.gradientColors,
        ),
        border: Border.all(
          color: gen.accentColor.withValues(alpha: 0.24),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: gen.accentColor.withValues(alpha: 0.12),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: -2,
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // A. Watermark Angka Romawi Raksasa di Background Kanan
          Positioned(
            right: -8,
            bottom: -28,
            child: Text(
              gen.romanNumeral,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 160,
                fontWeight: FontWeight.w900,
                color: gen.accentColor.withValues(alpha: 0.08),
                letterSpacing: -6,
              ),
            ),
          ),

          // B. Watermark Lingkaran Pokéball Translucent
          Positioned(
            right: 90,
            bottom: -40,
            child: Opacity(
              opacity: 0.06,
              child: Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: gen.accentColor,
                ),
              ),
            ),
          ),

          // C. Konten Kartu: Kiri (Info) & Kanan (Artwork 3 Starter Pokémon)
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 16, 16),
            child: Row(
              children: [
                // Kolom Kiri: Informasi Generasi
                Expanded(
                  flex: 11,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Header: Badge Generasi + Tahun Rilis
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: gen.accentColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: gen.accentColor.withValues(alpha: 0.28),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              'GEN ${gen.romanNumeral}',
                              style: xxsBold.copyWith(
                                color: gen.accentColor,
                                fontSize: 9.5,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              gen.year,
                              style: xxsSemiBold.copyWith(
                                color: black500,
                                fontSize: 11,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),

                      // Nama Region
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            gen.regionName.toUpperCase(),
                            style: lBold.copyWith(
                              color: textNeutralPrimary,
                              fontSize: 25,
                              letterSpacing: 0.5,
                              height: 1.1,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            gen.games,
                            style: xxsMedium.copyWith(
                              color: black600,
                              fontSize: 10.5,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),

                      // Tagline Singkat
                      Text(
                        gen.tagline,
                        style: xxsRegular.copyWith(
                          color: black500,
                          fontSize: 9.5,
                          fontStyle: FontStyle.italic,
                          height: 1.25,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      // Footer Chips: Rentang Pokédex & Jumlah Spesies
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 2.5),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.90),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: gen.accentColor.withValues(alpha: 0.20),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              gen.idRange,
                              style: xxsBold.copyWith(
                                color: gen.accentColor,
                                fontSize: 9.5,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 2.5),
                            decoration: BoxDecoration(
                              color: gen.accentColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: gen.accentColor.withValues(alpha: 0.25),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              '${gen.totalPokemon} Species',
                              style: xxsBold.copyWith(
                                color: gen.accentColor,
                                fontSize: 9.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // Kolom Kanan: Artwork Trio Starter Pokémon
                SizedBox(
                  width: 135,
                  child: Column(
                    mainAxisAlignment: showExploreButton
                        ? MainAxisAlignment.spaceBetween
                        : MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Artwork Trio Starter
                      Expanded(
                        child: Container(
                          alignment: Alignment.centerRight,
                          child: Image.asset(
                            gen.groupArtworkAsset,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildFallbackStarterStack(gen);
                            },
                          ),
                        ),
                      ),

                      // Tombol Explore Pill Candy (opsional)
                      if (showExploreButton) ...[
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 5.5),
                          decoration: BoxDecoration(
                            color: gen.accentColor,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: gen.accentColor.withValues(alpha: 0.30),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Explore',
                                style: xxsBold.copyWith(
                                  color: Colors.white,
                                  fontSize: 10,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.arrow_forward_rounded,
                                size: 11,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            onTap!();
          },
          borderRadius: BorderRadius.circular(24),
          child: cardContent,
        ),
      );
    }

    return cardContent;
  }

  Widget _buildFallbackStarterStack(GenerationModel gen) {
    return SizedBox(
      height: 120,
      width: 120,
      child: Stack(
        alignment: Alignment.centerRight,
        children: [
          Positioned(
            top: 0,
            right: 48,
            child: _buildStarterAvatar(
              gen.starters[0],
              size: 54,
              accentColor: gen.accentColor,
              colorDot: const Color(0xFF10B981),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 32,
            child: _buildStarterAvatar(
              gen.starters[1],
              size: 60,
              accentColor: gen.accentColor,
              colorDot: const Color(0xFFEF4444),
            ),
          ),
          Positioned(
            top: 14,
            right: 0,
            child: _buildStarterAvatar(
              gen.starters[2],
              size: 64,
              accentColor: gen.accentColor,
              colorDot: const Color(0xFF3B82F6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStarterAvatar(
    GenerationStarter starter, {
    required double size,
    required Color accentColor,
    required Color colorDot,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: Border.all(
          color: Colors.white,
          width: 2.0,
        ),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.20),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          CachedNetworkImage(
            imageUrl: starter.imageUrl,
            width: size * 0.85,
            height: size * 0.85,
            fit: BoxFit.contain,
            placeholder: (_, __) => Center(
              child: SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(
                  strokeWidth: 1.5,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
            ),
            errorWidget: (_, __, ___) => const Icon(
              Icons.catching_pokemon,
              color: Colors.white70,
              size: 20,
            ),
          ),
          Positioned(
            bottom: 2,
            right: 2,
            child: Container(
              width: 9,
              height: 9,
              decoration: BoxDecoration(
                color: colorDot,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
