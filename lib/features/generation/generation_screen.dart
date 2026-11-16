import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../ui/color.dart';
import '../../ui/typography.dart';
import 'model/generation_model.dart';
import 'region_detail_screen.dart';

class GenerationScreen extends StatefulWidget {
  const GenerationScreen({super.key});

  @override
  State<GenerationScreen> createState() => _GenerationScreenState();
}

class _GenerationScreenState extends State<GenerationScreen> {
  final List<GenerationModel> _generations = GenerationData.allGenerations;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // 1. App Bar Header
            SliverToBoxAdapter(child: _buildHeader(context)),

            // 2. Summary Badge Bar
            SliverToBoxAdapter(child: _buildSummaryBar()),

            // 3. List Kartu 9 Generasi Pokémon
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 32),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final gen = _generations[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 18),
                      child: _buildGenerationCard(context, gen),
                    );
                  },
                  childCount: _generations.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 1. Header dengan tombol kembali & Pokéball icon
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Tombol Kembali Lingkaran
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                HapticFeedback.lightImpact();
                Navigator.pop(context);
              },
              borderRadius: BorderRadius.circular(22),
              splashColor: primaryColor50,
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: bgLight,
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
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 18,
                  color: bgDark,
                ),
              ),
            ),
          ),

          // Judul Tengah
          Column(
            children: [
              Text(
                'Generation Atlas',
                style: mBold.copyWith(
                  color: textNeutralPrimary,
                  fontSize: 18,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '9 Eras of the Pokémon World',
                style: xxsRegular.copyWith(color: black500, fontSize: 11),
              ),
            ],
          ),

          // Sisi Kanan: Spacer penyeimbang (44px) agar judul tetap presisi di tengah
          const SizedBox(width: 44, height: 44),
        ],
      ),
    );
  }

  /// 2. Bar info ringkas total region & total spesies (Responsive & bebas overflow)
  Widget _buildSummaryBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: bgLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderNeutral, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🗺️', style: TextStyle(fontSize: 13)),
                const SizedBox(width: 6),
                Text(
                  '9 Regions',
                  style: xsBold.copyWith(color: textNeutralPrimary),
                ),
                const SizedBox(width: 4),
                Text(
                  '(1996–Present)',
                  style: xxsRegular.copyWith(color: black500, fontSize: 10),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '1,025 Species',
                style: xxsBold.copyWith(
                  color: primaryColor,
                  fontSize: 10.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 3. Kartu Hero Generasi Pokémon
  Widget _buildGenerationCard(BuildContext context, GenerationModel gen) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RegionDetailScreen(generation: gen),
            ),
          );
        },
        borderRadius: BorderRadius.circular(24),
        child: Container(
          height: 198,
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
                    fontFamily: 'poppins',
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

              // C. Konten Kartu: Kiri (Info & Metadata) & Kanan (Artwork 3 Starter Pokémon)
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

                    // Kolom Kanan: Artwork Trio Starter Pokémon & Tombol Explore
                    SizedBox(
                      width: 135,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          // Artwork Trio Starter Lucu (Grup Ilustrasi)
                          Expanded(
                            child: Container(
                              alignment: Alignment.centerRight,
                              child: Image.asset(
                                gen.groupArtworkAsset,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  // Fallback otomatis jika file asset belum dimasukkan user
                                  return _buildFallbackStarterStack(gen);
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),

                          // Tombol Explore Pill Candy
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
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Fallback tumpukan avatar 3 starter jika gambar grup belum diunduh
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

  /// Avatar lingkaran starter Pokémon dengan glossy white pedestal & candy glow
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
          // Artwork Pokémon
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

          // Indikator Titik Elemen Kecil (Grass/Fire/Water) di pojok bawah
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
