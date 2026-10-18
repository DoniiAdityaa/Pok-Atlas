import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import '../../models/pokemon_detail_model.dart';
import '../../models/pokemon_list_model.dart';
import '../../ui/color.dart';
import '../../ui/shared_widget/pokemon_search_bar.dart';
import '../../ui/shared_widget/pokemon_type_filter_bar.dart';
import '../../ui/typography.dart';
import '../detail/detail_screen.dart';
import 'cubit/compare_cubit.dart';

class CompareScreen extends StatefulWidget {
  final PokemonDetailModel? initialPokemonA;
  final PokemonDetailModel? initialPokemonB;

  const CompareScreen({
    super.key,
    this.initialPokemonA,
    this.initialPokemonB,
  });

  @override
  State<CompareScreen> createState() => _CompareScreenState();
}

class _CompareScreenState extends State<CompareScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CompareCubit>().init(
            initialA: widget.initialPokemonA,
            initialB: widget.initialPokemonB,
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CompareCubit, CompareState>(
      builder: (context, state) {
        final pokemonA = state.pokemonA;
        final pokemonB = state.pokemonB;
        final hasBoth = state.hasBoth;

        return Scaffold(
          backgroundColor: bg,
          body: SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // 1. App Bar Header
                SliverToBoxAdapter(child: _buildHeader(context, state)),

                // 2. Matchup Arena (Slot A vs Slot B)
                SliverToBoxAdapter(
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: _buildMatchupArena(state),
                  ),
                ),
                // 4. Content Area: Jika ada yang kosong, tampilkan panduan playful
                if (!hasBoth)
                  SliverToBoxAdapter(child: _buildEmptyStateGuide())
                else ...[
                  // 5. Base Stats Matchup Head-to-Head
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                      child: _buildBaseStatsSection(pokemonA!, pokemonB!),
                    ),
                  ),

                  // 6. Basic Information (Height, Weight, Abilities)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      child: _buildBasicInfoSection(pokemonA, pokemonB),
                    ),
                  ),

                  // 7. Action Button: Buka Detail Masing-Masing
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                      child: _buildBottomActionButtons(pokemonA, pokemonB),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  /// 1. Top Header App Bar
  Widget _buildHeader(BuildContext context, CompareState state) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Row(
        children: [
          // Tombol Kembali
          InkWell(
            onTap: () => Navigator.pop(context),
            borderRadius: BorderRadius.circular(14),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: bgLight,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: black200, width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 18,
                color: textNeutralPrimary,
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Judul Layar
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Compare Pokémon',
                  style:
                      mdBold.copyWith(color: textNeutralPrimary, height: 1.1),
                ),
                const SizedBox(height: 2),
                Text(
                  'VS Arena & Stat Matchup',
                  style: xsMedium.copyWith(color: black500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 2. Matchup Arena: Slot A + Center VS & Swap + Slot B
  Widget _buildMatchupArena(CompareState state) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgLight,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: black200, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Slot A (Kiri)
          Expanded(
            child: _buildPokemonSlot(
              slotLabel: 'Slot A',
              pokemon: state.pokemonA,
              isLoading: state.isLoadingA,
              onTap: () => _openPickerBottomSheet(isSlotA: true),
            ),
          ),

          // Center: All-in-One Battle Badge & Swap Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Tooltip(
              message: 'Tap to swap Pokémon',
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: (state.pokemonA != null || state.pokemonB != null)
                      ? _swapPokemon
                      : null,
                  borderRadius: BorderRadius.circular(24),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: bgLight,
                      border: Border.all(
                        color: black200,
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Teks VS Utama di tengah (Warna Gelap/Hitam)
                        Text(
                          'VS',
                          style: sBold.copyWith(
                            color: textNeutralPrimary,
                            letterSpacing: 1.0,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        // Ikon Swap mini di bagian bawah lingkaran
                        Positioned(
                          bottom: 4,
                          child: Icon(
                            Icons.swap_horiz_rounded,
                            size: 13,
                            color: (state.pokemonA != null ||
                                    state.pokemonB != null)
                                ? primaryColor
                                : black400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Slot B (Kanan)
          Expanded(
            child: _buildPokemonSlot(
              slotLabel: 'Slot B',
              pokemon: state.pokemonB,
              isLoading: state.isLoadingB,
              onTap: () => _openPickerBottomSheet(isSlotA: false),
            ),
          ),
        ],
      ),
    );
  }

  /// Desain Slot Kartu: Konsisten dengan kartu HomeScreen
  Widget _buildPokemonSlot({
    required String slotLabel,
    required ComparePokemonItem? pokemon,
    bool isLoading = false,
    required VoidCallback onTap,
  }) {
    // Loading State: Shimmer Skeleton berukuran 195px
    if (isLoading) {
      return Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Container(
          height: 195,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      );
    }

    // A. Kondisi KOSONG: Desain ramah dengan dashed border
    if (pokemon == null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          height: 195,
          decoration: BoxDecoration(
            color: black50,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: primaryColor.withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: primaryColor.withValues(alpha: 0.1),
                ),
                child: const Icon(
                  Icons.add_rounded,
                  color: primaryColor,
                  size: 26,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Select Pokémon',
                style: smBold.copyWith(color: textNeutralPrimary, fontSize: 13),
              ),
              const SizedBox(height: 5),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: black200.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  slotLabel,
                  style: xxsBold.copyWith(color: black600, fontSize: 9.5),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // B. Kondisi TERISI: Desain Konsisten 1:1 dengan HomeScreen (Gradient + Pokéball Watermark)
    final primaryType =
        pokemon.types.isNotEmpty ? pokemon.types.first : 'Normal';
    final secondaryType =
        pokemon.types.length > 1 ? pokemon.types[1] : primaryType;
    final primaryColorVal = PokemonTypeColors.getColor(primaryType);
    final secondaryColorVal = PokemonTypeColors.getColor(secondaryType);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 195,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              primaryColorVal.withValues(alpha: 0.95),
              Color.alphaBlend(
                secondaryColorVal.withValues(alpha: 0.75),
                primaryColorVal,
              ),
              secondaryColorVal,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: primaryColorVal.withValues(alpha: 0.35),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // Watermark Pokéball Translucent di background
            Positioned(
              right: -25,
              bottom: -25,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.15),
                    width: 12,
                  ),
                ),
                child: Center(
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.15),
                        width: 8,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Content Kartu
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // ID + Slot Badge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          slotLabel,
                          style: xxsBold.copyWith(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 8.5,
                          ),
                        ),
                      ),
                      Text(
                        pokemon.formattedId,
                        style: xxsBold.copyWith(
                          color: Colors.white.withValues(alpha: 0.75),
                          fontSize: 10,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),

                  // Artwork Resmi Pokémon (dengan transisi halus saat berganti)
                  SizedBox(
                    height: 82,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 350),
                      switchInCurve: Curves.easeOutBack,
                      switchOutCurve: Curves.easeIn,
                      transitionBuilder: (child, animation) {
                        return ScaleTransition(
                          scale: Tween<double>(begin: 0.75, end: 1.0)
                              .animate(animation),
                          child: FadeTransition(
                            opacity: animation,
                            child: child,
                          ),
                        );
                      },
                      child: KeyedSubtree(
                        key: ValueKey('${pokemon.id}_$slotLabel'),
                        child: CachedNetworkImage(
                          imageUrl: pokemon.imageUrl,
                          fit: BoxFit.contain,
                          placeholder: (context, url) => const Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white60,
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => const Icon(
                            Icons.broken_image,
                            color: Colors.white54,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Nama Pokémon
                  Text(
                    pokemon.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: smBold.copyWith(
                      color: Colors.white,
                      fontSize: 14.5,
                      letterSpacing: -0.3,
                    ),
                  ),

                  // Chips Tipe Pokémon
                  Wrap(
                    spacing: 4,
                    runSpacing: 2,
                    alignment: WrapAlignment.center,
                    children: pokemon.types.map((type) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          type,
                          style: xxsBold.copyWith(
                            color: Colors.white,
                            fontSize: 9,
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  // Hint kecil: "Ketuk untuk ganti"
                  Text(
                    'Tap to change ✎',
                    style: xxsMedium.copyWith(
                      color: Colors.white.withValues(alpha: 0.75),
                      fontSize: 8.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 4. Panduan Empty State jika slot belum lengkap
  Widget _buildEmptyStateGuide() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: bgLight,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: black200, width: 1),
        ),
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primaryColor.withValues(alpha: 0.1),
              ),
              child: const Icon(
                Icons.compare_arrows_rounded,
                color: primaryColor,
                size: 30,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Matchup Arena Ready',
              style: mBold.copyWith(color: textNeutralPrimary),
            ),
            const SizedBox(height: 6),
            Text(
              'Select 2 Pokémon in Slot A & Slot B above to view side-by-side base stats, body measurements, and special abilities.',
              textAlign: TextAlign.center,
              style: sRegular.copyWith(color: black500, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }

  /// 5. Base Stats Matchup Head-to-Head Section
  Widget _buildBaseStatsSection(ComparePokemonItem a, ComparePokemonItem b) {
    final colorA = PokemonTypeColors.getColor(a.types.first);
    final colorB = PokemonTypeColors.getColor(b.types.first);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bgLight,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: black200, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.bar_chart_rounded,
                    size: 18, color: primaryColor),
              ),
              const SizedBox(width: 10),
              Text(
                'Base Stats Comparison',
                style: sBold.copyWith(color: textNeutralPrimary),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // 6 Baris Stat Head-to-Head
          _buildStatRow(
              label: 'HP',
              valA: a.hp,
              valB: b.hp,
              colorA: colorA,
              colorB: colorB),
          const SizedBox(height: 12),
          _buildStatRow(
              label: 'Attack',
              valA: a.attack,
              valB: b.attack,
              colorA: colorA,
              colorB: colorB),
          const SizedBox(height: 12),
          _buildStatRow(
              label: 'Defense',
              valA: a.defense,
              valB: b.defense,
              colorA: colorA,
              colorB: colorB),
          const SizedBox(height: 12),
          _buildStatRow(
              label: 'Sp. Atk',
              valA: a.specialAttack,
              valB: b.specialAttack,
              colorA: colorA,
              colorB: colorB),
          const SizedBox(height: 12),
          _buildStatRow(
              label: 'Sp. Def',
              valA: a.specialDefense,
              valB: b.specialDefense,
              colorA: colorA,
              colorB: colorB),
          const SizedBox(height: 12),
          _buildStatRow(
              label: 'Speed',
              valA: a.speed,
              valB: b.speed,
              colorA: colorA,
              colorB: colorB),

          const SizedBox(height: 18),
          const Divider(height: 1, color: black200),
          const SizedBox(height: 16),

          // Total BST (Base Stat Total) Banner
          _buildTotalBstCard(a: a, b: b, colorA: colorA, colorB: colorB),
        ],
      ),
    );
  }

  /// Satu Baris Perbandingan Stat Head-to-Head
  Widget _buildStatRow({
    required String label,
    required int valA,
    required int valB,
    required Color colorA,
    required Color colorB,
  }) {
    const maxStat = 180.0; // Patokan maksimum stat untuk normalisasi bar
    final ratioA = (valA / maxStat).clamp(0.08, 1.0);
    final ratioB = (valB / maxStat).clamp(0.08, 1.0);

    final aWins = valA > valB;
    final bWins = valB > valA;

    return Column(
      children: [
        // Label Nama Stat & Angka di Atas Bar
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Angka Pokémon A
            Row(
              children: [
                if (aWins) const Text('🏆 ', style: TextStyle(fontSize: 10)),
                Text(
                  valA.toString(),
                  style: sBold.copyWith(
                    color: aWins ? colorA : black700,
                    fontWeight: aWins ? FontWeight.w800 : FontWeight.w600,
                  ),
                ),
              ],
            ),

            // Label Stat (Tengah)
            Text(
              label,
              style: xsBold.copyWith(color: black500, letterSpacing: 0.5),
            ),

            // Angka Pokémon B
            Row(
              children: [
                Text(
                  valB.toString(),
                  style: sBold.copyWith(
                    color: bWins ? colorB : black700,
                    fontWeight: bWins ? FontWeight.w800 : FontWeight.w600,
                  ),
                ),
                if (bWins) const Text(' 🏆', style: TextStyle(fontSize: 10)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 6),

        // Dua Bar Horizontal Saling Berhadapan (Kiri vs Kanan)
        Row(
          children: [
            // Bar Kiri (Pokémon A) — Tumbuh dari kanan ke kiri
            Expanded(
              child: Align(
                alignment: Alignment.centerRight,
                child: FractionallySizedBox(
                  widthFactor: ratioA,
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: aWins ? colorA : colorA.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),

            // Titik Pemisah di Tengah
            Container(
              width: 4,
              height: 4,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: black300,
              ),
            ),
            const SizedBox(width: 8),

            // Bar Kanan (Pokémon B) — Tumbuh dari kiri ke kanan
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: ratioB,
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: bWins ? colorB : colorB.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Total Base Stats (BST) Summary Banner
  Widget _buildTotalBstCard({
    required ComparePokemonItem a,
    required ComparePokemonItem b,
    required Color colorA,
    required Color colorB,
  }) {
    final diff = (a.totalBst - b.totalBst).abs();
    final aLead = a.totalBst > b.totalBst;
    final bLead = b.totalBst > a.totalBst;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: black50,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: black200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Total A
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${a.totalBst}',
                style: mBold.copyWith(
                  color: aLead ? colorA : textNeutralPrimary,
                  fontSize: 20,
                ),
              ),
              Text(
                'Total BST',
                style: xxsMedium.copyWith(color: black400),
              ),
            ],
          ),

          // Badge Advantage / Imbang
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: aLead
                  ? colorA.withValues(alpha: 0.12)
                  : (bLead ? colorB.withValues(alpha: 0.12) : black200),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              diff == 0 ? 'TIED STATS' : '${aLead ? a.name : b.name} +$diff',
              style: xxsBold.copyWith(
                color: aLead ? colorA : (bLead ? colorB : black600),
                letterSpacing: 0.5,
              ),
            ),
          ),

          // Total B
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${b.totalBst}',
                style: mBold.copyWith(
                  color: bLead ? colorB : textNeutralPrimary,
                  fontSize: 20,
                ),
              ),
              Text(
                'Total BST',
                style: xxsMedium.copyWith(color: black400),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 6. Basic Information Section (Height, Weight, Abilities)
  Widget _buildBasicInfoSection(ComparePokemonItem a, ComparePokemonItem b) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bgLight,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: black200, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.info_outline_rounded,
                    size: 18, color: primaryColor),
              ),
              const SizedBox(width: 10),
              Text(
                'Basic Information',
                style: sBold.copyWith(color: textNeutralPrimary),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Tinggi (Height)
          _buildInfoRow(
            title: 'Height',
            valA: '${a.height} m',
            valB: '${b.height} m',
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: black100),
          const SizedBox(height: 12),

          // Berat (Weight)
          _buildInfoRow(
            title: 'Weight',
            valA: '${a.weight} kg',
            valB: '${b.weight} kg',
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: black100),
          const SizedBox(height: 12),

          // Abilities
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Abilities A (Kiri)
              Expanded(
                child: Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: a.abilities.map((ability) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: black100,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        ability,
                        style: xxsBold.copyWith(color: textNeutralPrimary),
                      ),
                    );
                  }).toList(),
                ),
              ),

              // Label Tengah
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  'Abilities',
                  style: xsBold.copyWith(color: black500),
                ),
              ),

              // Abilities B (Kanan)
              Expanded(
                child: Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  alignment: WrapAlignment.end,
                  children: b.abilities.map((ability) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: black100,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        ability,
                        style: xxsBold.copyWith(color: textNeutralPrimary),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required String title,
    required String valA,
    required String valB,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            valA,
            style: smBold.copyWith(color: textNeutralPrimary),
          ),
        ),
        Text(
          title,
          style: xsBold.copyWith(color: black500),
        ),
        Expanded(
          child: Text(
            valB,
            textAlign: TextAlign.end,
            style: smBold.copyWith(color: textNeutralPrimary),
          ),
        ),
      ],
    );
  }

  /// 7. Bottom Action Buttons: Menuju Detail Screen
  Widget _buildBottomActionButtons(ComparePokemonItem a, ComparePokemonItem b) {
    final colorA = PokemonTypeColors.getColor(a.types.first);
    final colorB = PokemonTypeColors.getColor(b.types.first);

    return Row(
      children: [
        // Tombol View Pokémon A
        Expanded(
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailScreen(
                    pokemonIdOrName: a.id.toString(),
                    initialPokemonId: a.id,
                    initialName: a.name,
                    initialTypes: a.types,
                    initialImageUrl: a.imageUrl,
                    initialColor: colorA,
                  ),
                ),
              );
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: colorA.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: colorA.withValues(alpha: 0.4), width: 1.2),
              ),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.visibility_rounded, size: 16, color: colorA),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        'View ${a.name}',
                        overflow: TextOverflow.ellipsis,
                        style: xsBold.copyWith(color: colorA),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),

        // Tombol View Pokémon B
        Expanded(
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailScreen(
                    pokemonIdOrName: b.id.toString(),
                    initialPokemonId: b.id,
                    initialName: b.name,
                    initialTypes: b.types,
                    initialImageUrl: b.imageUrl,
                    initialColor: colorB,
                  ),
                ),
              );
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: colorB.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: colorB.withValues(alpha: 0.4), width: 1.2),
              ),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.visibility_rounded, size: 16, color: colorB),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        'View ${b.name}',
                        overflow: TextOverflow.ellipsis,
                        style: xsBold.copyWith(color: colorB),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Tukar Posisi Pokémon A dan B dengan animasi putar
  void _swapPokemon() {
    HapticFeedback.lightImpact();
    context.read<CompareCubit>().swapSlots();
  }

  /// Bottom Sheet untuk memilih Pokémon ke Slot
  void _openPickerBottomSheet({required bool isSlotA}) {
    final cubit = context.read<CompareCubit>();
    if (cubit.state.directory.isEmpty) {
      cubit.loadDirectory();
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        String query = '';
        String selectedType = 'All';

        return BlocBuilder<CompareCubit, CompareState>(
          bloc: cubit,
          builder: (context, state) {
            final directory = state.directory;
            final currentSlotId =
                isSlotA ? state.pokemonA?.id : state.pokemonB?.id;
            final otherSlotId =
                isSlotA ? state.pokemonB?.id : state.pokemonA?.id;

            return StatefulBuilder(
              builder: (context, setSheetState) {
                final filtered = directory.where((p) {
                  final name = p.name ?? '';
                  final idStr = p.id?.toString() ?? '';
                  final matchesQuery = query.isEmpty ||
                      name.toLowerCase().contains(query.toLowerCase()) ||
                      idStr.contains(query);
                  final types = PokemonTypeColors.getTypesById(p.id);
                  final matchesType = selectedType.toLowerCase() == 'all' ||
                      types.any(
                          (t) => t.toLowerCase() == selectedType.toLowerCase());
                  return matchesQuery && matchesType;
                }).toList()
                  ..sort((x, y) {
                    int score(PokemonListItemModel item) {
                      if (item.id == currentSlotId) return 0;
                      if (item.id == otherSlotId) return 1;
                      return 2;
                    }

                    final scoreX = score(x);
                    final scoreY = score(y);
                    if (scoreX != scoreY) {
                      return scoreX.compareTo(scoreY);
                    }
                    return (x.id ?? 0).compareTo(y.id ?? 0);
                  });

                return Container(
                  height: MediaQuery.of(context).size.height * 0.72,
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                  decoration: const BoxDecoration(
                    color: bgLight,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(28)),
                  ),
                  child: Column(
                    children: [
                      // Drag Handle
                      Container(
                        width: 38,
                        height: 4,
                        decoration: BoxDecoration(
                          color: black300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Header Sheet + Tombol Random / Surprise Me 🎲
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Select Pokémon for ${isSlotA ? "Slot A" : "Slot B"}',
                                style:
                                    sBold.copyWith(color: textNeutralPrimary),
                              ),
                              Text(
                                'Choose a Pokémon to enter the arena',
                                style: xxsRegular.copyWith(color: black500),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              // Tombol Random / Surprise Me 🎲
                              InkWell(
                                onTap: () {
                                  HapticFeedback.mediumImpact();
                                  final pool = directory;
                                  if (pool.isNotEmpty) {
                                    final randomItem =
                                        (List<PokemonListItemModel>.from(pool)
                                              ..shuffle())
                                            .first;
                                    Navigator.pop(sheetContext);
                                    cubit.selectPokemon(
                                        isSlotA ? 'A' : 'B', randomItem.id);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Row(
                                          children: [
                                            const Text('🎲 ',
                                                style: TextStyle(fontSize: 16)),
                                            Text(
                                              'Selected: ${randomItem.capitalizedName} for ${isSlotA ? "Slot A" : "Slot B"}!',
                                              style: smMedium.copyWith(
                                                  color: Colors.white),
                                            ),
                                          ],
                                        ),
                                        backgroundColor: bgDark,
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        duration:
                                            const Duration(milliseconds: 1600),
                                      ),
                                    );
                                  }
                                },
                                borderRadius: BorderRadius.circular(16),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: primaryColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color:
                                          primaryColor.withValues(alpha: 0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: const Text('🎲',
                                      style: TextStyle(fontSize: 12)),
                                ),
                              ),
                              const SizedBox(width: 4),
                              IconButton(
                                onPressed: () => Navigator.pop(sheetContext),
                                icon: const Icon(Icons.close_rounded,
                                    size: 20, color: black500),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 8,
                      ),

                      // Search Field (Shared PokemonSearchBar)
                      PokemonSearchBar(
                        hintText: 'Search name or Pokédex ID...',
                        onChanged: (val) {
                          setSheetState(() => query = val);
                        },
                        onClear: () {
                          setSheetState(() => query = '');
                        },
                      ),
                      const SizedBox(height: 10),

                      // Quick Filter Chips (Elemental Type)
                      PokemonTypeFilterBar(
                        selectedType: selectedType,
                        height: 36,
                        itemSpacing: 6,
                        padding: EdgeInsets.zero,
                        onSelected: (type) {
                          setSheetState(() {
                            selectedType = (selectedType.toLowerCase() ==
                                        type.toLowerCase() &&
                                    type != 'All')
                                ? 'All'
                                : type;
                          });
                        },
                      ),
                      const SizedBox(height: 12),

                      // List Pokémon atau Shimmer Loading atau Smart Empty State
                      Expanded(
                        child: state.isLoadingDirectory && directory.isEmpty
                            ? ListView.separated(
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: 6,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 12),
                                itemBuilder: (_, __) => Shimmer.fromColors(
                                  baseColor: Colors.grey.shade300,
                                  highlightColor: Colors.grey.shade100,
                                  child: Container(
                                    height: 118,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade300,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                ),
                              )
                            : filtered.isEmpty
                                ? Center(
                                    child: SingleChildScrollView(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 24, horizontal: 16),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Container(
                                              width: 64,
                                              height: 64,
                                              decoration: const BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: black100,
                                              ),
                                              child: const Icon(
                                                Icons.search_off_rounded,
                                                size: 32,
                                                color: black400,
                                              ),
                                            ),
                                            const SizedBox(height: 12),
                                            Text(
                                              'No Pokémon Found',
                                              style: smBold.copyWith(
                                                  color: textNeutralPrimary,
                                                  fontSize: 14),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              query.isNotEmpty &&
                                                      selectedType != 'All'
                                                  ? 'No "$selectedType" type Pokémon found\nmatching "$query"'
                                                  : 'Try checking your search keyword or change type filter',
                                              textAlign: TextAlign.center,
                                              style: xxsRegular.copyWith(
                                                  color: black500,
                                                  fontSize: 11),
                                            ),
                                            const SizedBox(height: 14),
                                            InkWell(
                                              onTap: () {
                                                HapticFeedback.lightImpact();
                                                setSheetState(() {
                                                  query = '';
                                                  selectedType = 'All';
                                                });
                                              },
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 14,
                                                        vertical: 7),
                                                decoration: BoxDecoration(
                                                  color: primaryColor
                                                      .withValues(alpha: 0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(16),
                                                  border: Border.all(
                                                    color: primaryColor
                                                        .withValues(alpha: 0.3),
                                                  ),
                                                ),
                                                child: Text(
                                                  'Reset Search & Filter',
                                                  style: xsBold.copyWith(
                                                      color: primaryColor,
                                                      fontSize: 11.5),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  )
                                : ListView.separated(
                                    physics: const BouncingScrollPhysics(),
                                    itemCount: filtered.length,
                                    separatorBuilder: (_, __) =>
                                        const SizedBox(height: 12),
                                    itemBuilder: (context, index) {
                                      final item = filtered[index];
                                      final itemTypes =
                                          PokemonTypeColors.getTypesById(
                                              item.id);
                                      final itemColor =
                                          PokemonTypeColors.getColor(
                                              itemTypes.first);

                                      // Status check: Konsisten untuk Slot A dan Slot B
                                      final bool isInSlotA =
                                          state.pokemonA?.id == item.id;
                                      final bool isInSlotB =
                                          state.pokemonB?.id == item.id;
                                      final bool isSelected =
                                          isInSlotA || isInSlotB;
                                      final Color slotColor = isInSlotA
                                          ? const Color(0xFF10B981)
                                          : primaryColor;

                                      return Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          onTap: () {
                                            HapticFeedback.selectionClick();
                                            Navigator.pop(sheetContext);
                                            cubit.selectPokemon(
                                                isSlotA ? 'A' : 'B', item.id);
                                          },
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          child: Container(
                                            height: 118,
                                            decoration: BoxDecoration(
                                              color: bgLight,
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              border: Border.all(
                                                color: isSelected
                                                    ? slotColor
                                                    : itemColor.withValues(
                                                        alpha: 0.22),
                                                width: isSelected ? 1.8 : 1.2,
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: itemColor.withValues(
                                                      alpha: 0.08),
                                                  blurRadius: 14,
                                                  offset: const Offset(0, 4),
                                                ),
                                              ],
                                            ),
                                            clipBehavior: Clip.antiAlias,
                                            child: Stack(
                                              children: [
                                                // 1. Soft tint gradient latar belakang (sama persis HomeScreen)
                                                Positioned.fill(
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      gradient: LinearGradient(
                                                        begin: Alignment
                                                            .centerLeft,
                                                        end: Alignment
                                                            .centerRight,
                                                        colors: [
                                                          itemColor.withValues(
                                                              alpha: 0.12),
                                                          itemColor.withValues(
                                                              alpha: 0.02),
                                                          Colors.transparent,
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),

                                                // 2. Pokéball watermark hemisphere di belakang artwork (sama persis HomeScreen)
                                                Positioned(
                                                  right: -15,
                                                  bottom: -15,
                                                  child: Opacity(
                                                    opacity: 0.10,
                                                    child: Container(
                                                      width: 130,
                                                      height: 130,
                                                      decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        color: itemColor,
                                                      ),
                                                    ),
                                                  ),
                                                ),

                                                // 3. Konten Kartu: Kiri (Info) & Kanan (Artwork)
                                                Row(
                                                  children: [
                                                    // Info sisi kiri
                                                    Expanded(
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .fromLTRB(
                                                                16, 14, 8, 14),
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            // Baris ID Pokédex + Badge Tipe Elemen
                                                            Row(
                                                              children: [
                                                                Text(
                                                                  item.formattedId,
                                                                  style: xxsBold
                                                                      .copyWith(
                                                                    fontSize:
                                                                        11,
                                                                    color:
                                                                        black500,
                                                                    letterSpacing:
                                                                        0.5,
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                    width: 8),
                                                                ...itemTypes
                                                                    .map(
                                                                        (type) {
                                                                  final tColor =
                                                                      PokemonTypeColors
                                                                          .getColor(
                                                                              type);
                                                                  return Container(
                                                                    margin: const EdgeInsets
                                                                        .only(
                                                                        right:
                                                                            4),
                                                                    padding:
                                                                        const EdgeInsets
                                                                            .symmetric(
                                                                      horizontal:
                                                                          7,
                                                                      vertical:
                                                                          2,
                                                                    ),
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      color: tColor.withValues(
                                                                          alpha:
                                                                              0.15),
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              6),
                                                                    ),
                                                                    child: Text(
                                                                      type,
                                                                      style: xxsSemiBold
                                                                          .copyWith(
                                                                        fontSize:
                                                                            9.5,
                                                                        color:
                                                                            tColor,
                                                                      ),
                                                                    ),
                                                                  );
                                                                }),
                                                              ],
                                                            ),

                                                            // Nama Pokémon
                                                            Text(
                                                              item.capitalizedName,
                                                              style: mdBold
                                                                  .copyWith(
                                                                color: bgDark,
                                                                fontSize: 17,
                                                              ),
                                                              maxLines: 1,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),

                                                            // Teks Panduan / Status Seleksi (Konsisten)
                                                            Row(
                                                              children: [
                                                                Icon(
                                                                  isSelected
                                                                      ? Icons
                                                                          .check_circle_rounded
                                                                      : Icons
                                                                          .catching_pokemon,
                                                                  size: 13,
                                                                  color: isSelected
                                                                      ? slotColor
                                                                      : itemColor,
                                                                ),
                                                                const SizedBox(
                                                                    width: 5),
                                                                Text(
                                                                  isInSlotA
                                                                      ? 'In Slot A'
                                                                      : (isInSlotB
                                                                          ? 'In Slot B'
                                                                          : 'Select for battle ⚔️'),
                                                                  style: xxsMedium
                                                                      .copyWith(
                                                                    color: isSelected
                                                                        ? slotColor
                                                                        : black500,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),

                                                    // Artwork Pokémon di Kanan (Sama persis HomeScreen)
                                                    SizedBox(
                                                      width: 115,
                                                      child: Stack(
                                                        alignment:
                                                            Alignment.center,
                                                        children: [
                                                          Positioned(
                                                            right: 8,
                                                            bottom: 4,
                                                            top: 4,
                                                            child:
                                                                CachedNetworkImage(
                                                              imageUrl:
                                                                  item.imageUrl ??
                                                                      '',
                                                              width: 100,
                                                              height: 100,
                                                              fit: BoxFit
                                                                  .contain,
                                                              placeholder: (context,
                                                                      url) =>
                                                                  const Center(
                                                                child: SizedBox(
                                                                  width: 20,
                                                                  height: 20,
                                                                  child:
                                                                      CircularProgressIndicator(
                                                                    strokeWidth:
                                                                        2,
                                                                    color:
                                                                        primaryColor,
                                                                  ),
                                                                ),
                                                              ),
                                                              errorWidget: (context,
                                                                      url,
                                                                      error) =>
                                                                  const Icon(
                                                                Icons
                                                                    .catching_pokemon,
                                                                size: 40,
                                                                color: black400,
                                                              ),
                                                            ),
                                                          ),

                                                          // Badge Status di Pojok Kanan Atas (Konsisten: Slot A & Slot B)
                                                          if (isSelected)
                                                            Positioned(
                                                              top: 8,
                                                              right: 8,
                                                              child: Container(
                                                                padding: const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        7,
                                                                    vertical:
                                                                        3),
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color:
                                                                      slotColor,
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              10),
                                                                  boxShadow: [
                                                                    BoxShadow(
                                                                      color: Colors
                                                                          .black
                                                                          .withValues(
                                                                              alpha: 0.12),
                                                                      blurRadius:
                                                                          4,
                                                                    ),
                                                                  ],
                                                                ),
                                                                child: Text(
                                                                  isInSlotA
                                                                      ? 'Slot A'
                                                                      : 'Slot B',
                                                                  style: xxsBold
                                                                      .copyWith(
                                                                    color: Colors
                                                                        .white,
                                                                    fontSize:
                                                                        9.5,
                                                                    letterSpacing:
                                                                        0.3,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
