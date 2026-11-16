import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:photo_view/photo_view.dart';
import 'package:shimmer/shimmer.dart';
import '../../config/service_locator.dart';
import '../../models/pokemon_list_model.dart';
import '../../repository/pokemon_list/pokemon_list_repository.dart';
import '../../ui/color.dart';
import '../../ui/shared_widget/app_bottom_sheet.dart';
import '../../ui/shared_widget/app_messenger.dart';
import '../../ui/shared_widget/pokemon_search_bar.dart';
import '../../ui/shared_widget/pokemon_type_filter_bar.dart';
import '../../ui/typography.dart';
import '../detail/detail_screen.dart';
import 'model/generation_model.dart';
import 'widgets/generation_card.dart';

/// Halaman Detail Region / Generasi (PokéAtlas Region Hub)
/// Menampilkan info wilayah, quick actions (Map & Legendaries),
/// filter tipe & pencarian, serta grid lengkap seluruh Pokémon generasi tersebut.
class RegionDetailScreen extends StatefulWidget {
  final GenerationModel generation;

  const RegionDetailScreen({
    super.key,
    required this.generation,
  });

  @override
  State<RegionDetailScreen> createState() => _RegionDetailScreenState();
}

class _RegionDetailScreenState extends State<RegionDetailScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<PokemonListItemModel> _allRegionalPokemon = [];
  List<PokemonListItemModel> _filteredPokemon = [];

  bool _isLoading = true;
  bool _isFavorite = false;
  bool _isLegendaryOnly = false;
  String _selectedType = 'All';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadRegionalData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Memuat daftar Pokémon khusus rentang ID region ini
  Future<void> _loadRegionalData() async {
    setState(() => _isLoading = true);

    try {
      final repository = serviceLocator<PokemonListRepository>();
      final fullDirectory = await repository.getAllPokemonDirectory();

      if (fullDirectory.isNotEmpty) {
        final regional = fullDirectory.where((p) {
          final id = p.id;
          return id != null &&
              id >= widget.generation.startId &&
              id <= widget.generation.endId;
        }).toList();

        if (mounted) {
          setState(() {
            _allRegionalPokemon = regional;
            _applyFilters();
            _isLoading = false;
          });
          return;
        }
      }
    } catch (_) {
      // Abaikan error dan gunakan fallback generator
    }

    // Fallback otomatis jika koneksi lambat atau belum ter-cache
    if (mounted) {
      final fallbackList = List.generate(
        widget.generation.totalPokemon,
        (index) {
          final id = widget.generation.startId + index;
          return PokemonListItemModel(
            name: 'pokemon',
            url: 'https://pokeapi.co/api/v2/pokemon/$id/',
          );
        },
      );

      setState(() {
        _allRegionalPokemon = fallbackList;
        _applyFilters();
        _isLoading = false;
      });
    }
  }

  /// Memfilter Pokémon berdasarkan Search Query dan Type
  void _applyFilters() {
    List<PokemonListItemModel> results = List.from(_allRegionalPokemon);

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      results = results.where((p) {
        final name = (p.name ?? '').toLowerCase();
        final idStr = p.id?.toString() ?? '';
        return name.contains(q) || idStr.contains(q);
      }).toList();
    }

    if (_selectedType != 'All') {
      results = results.where((p) {
        final types = PokemonTypeColors.getTypesById(p.id);
        return types.any((t) => t.toLowerCase() == _selectedType.toLowerCase());
      }).toList();
    }

    if (_isLegendaryOnly) {
      final legIds = widget.generation.legendaryIds;
      results = results.where((p) => legIds.contains(p.id)).toList();
    }

    setState(() {
      _filteredPokemon = results;
    });
  }

  /// Navigasi langsung ke DetailScreen Pokémon yang diklik
  void _navigateToPokemonDetail(PokemonListItemModel pokemon) {
    final pokemonId = pokemon.id ?? widget.generation.startId;
    final types = PokemonTypeColors.getTypesById(pokemonId);
    final accentColor = types.isNotEmpty
        ? PokemonTypeColors.getColor(types.first)
        : widget.generation.accentColor;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailScreen(
          pokemonIdOrName: pokemonId.toString(),
          initialPokemonId: pokemonId,
          initialName: pokemon.capitalizedName.isNotEmpty
              ? pokemon.capitalizedName
              : 'Pokémon #$pokemonId',
          initialImageUrl: pokemon.imageUrl,
          initialColor: accentColor,
          initialTypes: types,
        ),
      ),
    );
  }

  // ============================================================
  // MODAL: Explore Map
  // ============================================================
  void _showMapModal() {
    HapticFeedback.lightImpact();
    final gen = widget.generation;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) {
        return Container(
          height: MediaQuery.of(modalContext).size.height * 0.85,
          decoration: const BoxDecoration(
            color: bgLight,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              const AppSheetHandle(),
              AppSheetHeader(
                title: '${gen.regionName} Cartography',
                subtitle: 'Official Geographic Map • Pinch to zoom',
                accentColor: gen.accentColor,
                leadingIcon: SvgPicture.asset(
                  'assets/images/icons/map.svg',
                  width: 18,
                  height: 18,
                  colorFilter: ColorFilter.mode(
                    gen.accentColor,
                    BlendMode.srcIn,
                  ),
                ),
                onClose: () => Navigator.pop(modalContext),
              ),
              const Divider(height: 1, color: borderNeutral),

              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                  physics: const BouncingScrollPhysics(),
                  children: [
                    // 1. Peta Zoomable (PhotoView)
                    Container(
                      height: 280,
                      decoration: BoxDecoration(
                        color: gen.gradientColors.first,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: gen.accentColor.withValues(alpha: 0.22),
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: gen.accentColor.withValues(alpha: 0.08),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Stack(
                        children: [
                          PhotoView(
                            imageProvider: AssetImage(gen.mapAsset),
                            minScale: PhotoViewComputedScale.contained * 0.9,
                            maxScale: PhotoViewComputedScale.covered * 3.0,
                            initialScale: PhotoViewComputedScale.contained,
                            backgroundDecoration: const BoxDecoration(
                              color: Colors.transparent,
                            ),
                            errorBuilder: (_, __, ___) => Center(
                              child: Text(
                                'Peta belum tersedia',
                                style: smMedium.copyWith(color: black400),
                              ),
                            ),
                          ),
                          Positioned(
                            right: 10,
                            bottom: 10,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.55),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.pinch_outlined,
                                    size: 11,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Pinch / Drag to explore',
                                    style: xxsMedium.copyWith(
                                      color: Colors.white,
                                      fontSize: 9.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // 2. Real-World Inspiration Card
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: bg,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: borderNeutral, width: 1.1),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: gen.accentColor.withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Icon(
                                Icons.place_outlined,
                                size: 18,
                                color: gen.accentColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'REAL-WORLD INSPIRATION',
                                  style: xxsBold.copyWith(
                                    color: black500,
                                    letterSpacing: 0.6,
                                    fontSize: 9.5,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  gen.realWorldInspiration,
                                  style: smSemiBold.copyWith(
                                    color: textNeutralPrimary,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // 3. Stats 3 Kolom (Spesies / Legendary / Rentang ID)
                    Row(
                      children: [
                        _buildMapStatBox(
                          label: 'TOTAL SPECIES',
                          value: '${gen.totalPokemon}',
                          accentColor: gen.accentColor,
                        ),
                        const SizedBox(width: 10),
                        _buildMapStatBox(
                          label: 'LEGENDARIES',
                          value: '${gen.legendaryIds.length}',
                          accentColor: const Color(0xFFD4A017),
                        ),
                        const SizedBox(width: 10),
                        _buildMapStatBox(
                          label: 'DEX RANGE',
                          value: gen.idRange,
                          accentColor: primaryColor,
                          isSmallValue: true,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMapStatBox({
    required String label,
    required String value,
    required Color accentColor,
    bool isSmallValue = false,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderNeutral, width: 1.1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: xxsBold.copyWith(
                color: black500,
                fontSize: 8.5,
                letterSpacing: 0.5,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: (isSmallValue ? smBold : mBold).copyWith(
                color: accentColor,
                fontSize: isSmallValue ? 12 : 16,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
  // ============================================================
  // BUILD
  // ============================================================
  @override
  Widget build(BuildContext context) {
    final gen = widget.generation;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: CustomScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          slivers: [
            // 1. App Bar minimalis (konsisten dengan GenerationScreen)
            SliverToBoxAdapter(child: _buildRegionHeroHeader(gen)),

            // 1b. Banner Region
            SliverToBoxAdapter(child: _buildRegionBanner(gen)),

            // 2. Quick Action Buttons (Map & Legendaries)
            SliverToBoxAdapter(child: _buildQuickActions(gen)),

            // 3. Search Bar
            SliverToBoxAdapter(child: _buildSearch(gen)),

            // 4. Legendary Filter Chip
            SliverToBoxAdapter(child: _buildLegendaryFilter(gen)),

            // 5. Type Filter Bar (shared component)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 4),
                child: PokemonTypeFilterBar(
                  selectedType: _selectedType,
                  onSelected: (type) {
                    setState(() => _selectedType = type);
                    _applyFilters();
                  },
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                ),
              ),
            ),

            // 6. Pokédex Section Header
            SliverToBoxAdapter(child: _buildPokedexSectionHeader(gen)),

            // 7. Grid Content
            if (_isLoading)
              _buildShimmerGrid()
            else if (_filteredPokemon.isEmpty)
              SliverToBoxAdapter(child: _buildEmptyState())
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
                sliver: SliverGrid(
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 0.78,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return _buildPokemonCard(
                          _filteredPokemon[index], gen);
                    },
                    childCount: _filteredPokemon.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // WIDGETS
  // ============================================================

  /// 1. Hero Header dengan gaya minimalis (konsisten dengan GenerationScreen)
  Widget _buildRegionHeroHeader(GenerationModel gen) {
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
          Expanded(
            child: Column(
              children: [
                Text(
                  '${gen.regionName} Atlas',
                  style: mBold.copyWith(
                    color: textNeutralPrimary,
                    fontSize: 18,
                    letterSpacing: -0.3,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  'GEN ${gen.romanNumeral} • ${gen.year}',
                  style: xxsRegular.copyWith(color: black500, fontSize: 11),
                ),
              ],
            ),
          ),

          // Tombol Favorite Lingkaran
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _isFavorite = !_isFavorite);
                AppMessenger.show(
                  context,
                  message: _isFavorite
                      ? 'Added ${gen.regionName} to Favorites!'
                      : 'Removed ${gen.regionName} from Favorites',
                );
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
                child: Icon(
                  _isFavorite
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  size: 18,
                  color: _isFavorite ? errorColor : bgDark,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 1b. Banner Region — pakai shared GenerationCard tanpa tombol Explore
  Widget _buildRegionBanner(GenerationModel gen) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 14),
      child: GenerationCard(
        generation: gen,
        showExploreButton: false,
        height: 168,
      ),
    );
  }

  /// 2. Explore Map — kartu hero lebar dengan preview peta region
  Widget _buildQuickActions(GenerationModel gen) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            _showMapModal();
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            height: 132,
            decoration: BoxDecoration(
              color: bgLight,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: gen.accentColor.withValues(alpha: 0.22),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: gen.accentColor.withValues(alpha: 0.08),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Preview peta region sebagai background
                Image.asset(
                  gen.mapAsset,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: gen.gradientColors,
                      ),
                    ),
                  ),
                ),

                // Gradient overlay agar teks terbaca
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.05),
                        Colors.black.withValues(alpha: 0.62),
                      ],
                    ),
                  ),
                ),

                // Konten teks
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Icon map (SVG) dalam lingkaran kaca
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.20),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.35),
                            width: 1.2,
                          ),
                        ),
                        child: Center(
                          child: SvgPicture.asset(
                            'assets/images/icons/map.svg',
                            width: 17,
                            height: 17,
                            colorFilter: const ColorFilter.mode(
                              Colors.white,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ),

                      // Teks
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${gen.regionName} Cartography',
                                  style: smBold.copyWith(
                                    color: Colors.white,
                                    fontSize: 15,
                                    letterSpacing: -0.2,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Official geographic atlas of the region',
                                  style: xxsRegular.copyWith(
                                    color: Colors.white.withValues(alpha: 0.78),
                                    fontSize: 10.5,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.20),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.35),
                                width: 1.2,
                              ),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.arrow_forward_rounded,
                                size: 15,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 3. Search Bar — pakai shared PokemonSearchBar
  Widget _buildSearch(GenerationModel gen) {
    return PokemonSearchBar(
      controller: _searchController,
      hintText: 'Search ${gen.regionName} Pokémon (e.g. Pikachu)...',
      margin: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      onChanged: (val) {
        _searchQuery = val;
        _applyFilters();
      },
      onClear: () {
        _searchQuery = '';
        _applyFilters();
      },
    );
  }

  /// 4. Legendary Filter Chip
  Widget _buildLegendaryFilter(GenerationModel gen) {
    const legendaryGold = Color(0xFFD4A017);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() => _isLegendaryOnly = !_isLegendaryOnly);
            _applyFilters();
          },
          borderRadius: BorderRadius.circular(14),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: _isLegendaryOnly
                  ? legendaryGold.withValues(alpha: 0.14)
                  : bgLight,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: _isLegendaryOnly
                    ? legendaryGold.withValues(alpha: 0.55)
                    : borderNeutral,
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: _isLegendaryOnly
                      ? legendaryGold.withValues(alpha: 0.12)
                      : Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset(
                  'assets/images/icons/crown.svg',
                  width: 14,
                  height: 14,
                  colorFilter: ColorFilter.mode(
                    _isLegendaryOnly ? legendaryGold : black500,
                    BlendMode.srcIn,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'Legendary Only',
                  style: xsBold.copyWith(
                    color: _isLegendaryOnly
                        ? legendaryGold
                        : textNeutralPrimary,
                    fontSize: 11.5,
                  ),
                ),
                const SizedBox(width: 5),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6, vertical: 1.5),
                  decoration: BoxDecoration(
                    color: (_isLegendaryOnly ? legendaryGold : black400)
                        .withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${gen.legendaryIds.length}',
                    style: xxsBold.copyWith(
                      color:
                          _isLegendaryOnly ? legendaryGold : black500,
                      fontSize: 9.5,
                    ),
                  ),
                ),
                if (_isLegendaryOnly) ...[
                  const SizedBox(width: 6),
                  Icon(
                    Icons.close_rounded,
                    size: 12,
                    color: legendaryGold.withValues(alpha: 0.85),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 6. Pokédex Section Header
  Widget _buildPokedexSectionHeader(GenerationModel gen) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                '${gen.regionName.toUpperCase()} POKÉDEX',
                style: smBold.copyWith(
                  color: textNeutralPrimary,
                  fontSize: 13,
                  letterSpacing: 0.6,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '(${gen.idRange})',
                style: xxsRegular.copyWith(color: black500, fontSize: 11),
              ),
            ],
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
            decoration: BoxDecoration(
              color: gen.accentColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: gen.accentColor.withValues(alpha: 0.20),
              ),
            ),
            child: Text(
              '${_filteredPokemon.length} Species',
              style: xxsBold.copyWith(
                color: gen.accentColor,
                fontSize: 10.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 6. Pokemon Grid Card — 1:1 konsisten dengan HomeScreen
  Widget _buildPokemonCard(PokemonListItemModel item, GenerationModel gen) {
    final id = item.id ?? gen.startId;
    final types = PokemonTypeColors.getTypesById(id);
    final typeColor = types.isNotEmpty
        ? PokemonTypeColors.getColor(types.first)
        : gen.accentColor;

    return InkWell(
      onTap: () => _navigateToPokemonDetail(item),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: bgLight,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: typeColor.withValues(alpha: 0.22),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: typeColor.withValues(alpha: 0.08),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // Soft tinted background (top section) — sama persis Home
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 110,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      typeColor.withValues(alpha: 0.18),
                      typeColor.withValues(alpha: 0.03),
                    ],
                  ),
                ),
              ),
            ),

            // Card Content
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ID & Type dot
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item.formattedId,
                        style: xxsBold.copyWith(
                          fontSize: 11,
                          color: black500,
                        ),
                      ),
                      if (types.isNotEmpty)
                        Container(
                          width: 9,
                          height: 9,
                          decoration: BoxDecoration(
                            color: typeColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),

                  // Sprite
                  Expanded(
                    child: Center(
                      child: Hero(
                        tag: 'region_pokemon_$id',
                        child: CachedNetworkImage(
                          imageUrl: item.imageUrl ?? '',
                          fit: BoxFit.contain,
                          placeholder: (_, __) => Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: typeColor,
                              ),
                            ),
                          ),
                          errorWidget: (_, __, ___) => const Icon(
                            Icons.catching_pokemon,
                            color: black300,
                            size: 34,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Nama Pokémon
                  Text(
                    item.capitalizedName.isNotEmpty
                        ? item.capitalizedName
                        : 'Pokémon #$id',
                    style: smBold.copyWith(
                      fontSize: 15,
                      color: bgDark,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 6),

                  // Type badges — pakai SVG icon sama seperti Home
                  if (types.isNotEmpty)
                    Wrap(
                      spacing: 4,
                      children: types.take(2).map((t) {
                        final tc = PokemonTypeColors.getColor(t);
                        final assetPath =
                            'assets/images/element/${t.toLowerCase()}.svg';
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2.5),
                          decoration: BoxDecoration(
                            color: tc.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SvgPicture.asset(
                                assetPath,
                                width: 10,
                                height: 10,
                                colorFilter: ColorFilter.mode(
                                  tc,
                                  BlendMode.srcIn,
                                ),
                              ),
                              const SizedBox(width: 3),
                              Text(
                                t,
                                style: xxsBold.copyWith(
                                  color: tc,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Shimmer skeleton grid — 1:1 sama seperti HomeScreen
  Widget _buildShimmerGrid() {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          childAspectRatio: 0.78,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            return Shimmer.fromColors(
              baseColor: black100,
              highlightColor: bgLight,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: borderNeutral),
                ),
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: 44,
                          height: 12,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        Container(
                          width: 9,
                          height: 9,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Center(
                      child: Container(
                        width: 76,
                        height: 76,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      width: 90,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 55,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
          childCount: 6,
        ),
      ),
    );
  }

  /// Empty state
  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 60),
      child: Center(
        child: Column(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: black100,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.search_off_rounded,
                size: 34,
                color: black400,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'No Pokémon Found',
              style: smBold.copyWith(color: textNeutralPrimary),
            ),
            const SizedBox(height: 4),
            Text(
              'Try adjusting your search or type filter.',
              textAlign: TextAlign.center,
              style: xxsRegular.copyWith(
                color: black500,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 18),
            OutlinedButton.icon(
              onPressed: () {
                _searchController.clear();
                _searchQuery = '';
                setState(() => _selectedType = 'All');
                _applyFilters();
              },
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Reset Filter'),
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
