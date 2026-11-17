import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pokeatlas/ui/shared_widget/generation_card.dart';
import 'package:shimmer/shimmer.dart';
import '../../config/service_locator.dart';
import '../../models/pokemon_list_model.dart';
import '../../repository/pokemon_list/pokemon_list_repository.dart';
import '../../ui/color.dart';
import '../../ui/shared_widget/app_header.dart';
import '../../ui/shared_widget/app_messenger.dart';
import '../../ui/shared_widget/app_sheet.dart';
import '../../ui/motion/motion.dart';
import '../../ui/shared_widget/pokemon_card.dart';
import '../../ui/shared_widget/pokemon_search_bar.dart';
import '../../ui/shared_widget/pokemon_type_filter_bar.dart';
import '../../ui/typography.dart';
import '../detail/detail_screen.dart';
import '../pokemon_type/cubit/pokemon_type_cubit.dart';
import '../../ui/shared_widget/monstra_refresh.dart';
import 'model/generation_model.dart';

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
  bool _isGridMode = true;
  final Set<int> _favoriteIds = {};

  /// Kartu yang sudah dianimasikan masuk — tidak diulang saat scroll balik.
  final Set<String> _revealedCards = {};
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
  Future<void> _loadRegionalData({bool showLoading = true}) async {
    if (showLoading) setState(() => _isLoading = true);

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
    final gen = widget.generation;
    showAppSheet(
      context: context,
      builder: (_) => AppSheet(
        overline: 'GEN ${gen.romanNumeral} • ${gen.year}',
        overlineColor: gen.accentColor,
        title: '${gen.regionName} Map',
        child: _RegionMapSheetContent(generation: gen),
      ),
    );
  }

  // ============================================================
  // MODAL: Legendaries
  // ============================================================
  void _showLegendariesModal() {
    final gen = widget.generation;
    showAppSheet(
      context: context,
      builder: (modalContext) {
        return AppSheet(
          overline: '${gen.legendaryIds.length} LEGENDARY & MYTHICAL',
          overlineColor: gen.accentColor,
          title: '${gen.regionName} Legends',
          child: ListView.separated(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            physics: const BouncingScrollPhysics(),
            itemCount: gen.legendaryIds.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final id = widget.generation.legendaryIds[index];
              final types = PokemonTypeColors.getTypesById(id);
              final accentColor = types.isNotEmpty
                  ? PokemonTypeColors.getColor(types.first)
                  : widget.generation.accentColor;

              return FadeSlideIn(
                delay: AppMotion.staggerAt(index + 1),
                offset: const Offset(0, 14),
                child: Pressable(
                  onTap: () {
                    Navigator.pop(modalContext);
                    _navigateToPokemonDetail(
                      PokemonListItemModel(
                        name: 'pokemon',
                        url: 'https://pokeapi.co/api/v2/pokemon/$id/',
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: bgLight,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: accentColor.withValues(alpha: 0.22),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: accentColor.withValues(alpha: 0.06),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Avatar with tinted background
                        Container(
                          width: 58,
                          height: 58,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                accentColor.withValues(alpha: 0.18),
                                accentColor.withValues(alpha: 0.06),
                              ],
                            ),
                            border: Border.all(
                              color: accentColor.withValues(alpha: 0.20),
                            ),
                          ),
                          child: CachedNetworkImage(
                            imageUrl:
                                'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png',
                            fit: BoxFit.contain,
                            placeholder: (_, __) => Center(
                              child: SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 1.5,
                                  color: accentColor,
                                ),
                              ),
                            ),
                            errorWidget: (_, __, ___) => Icon(
                              Icons.catching_pokemon_rounded,
                              color: accentColor.withValues(alpha: 0.5),
                              size: 26,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),

                        // Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '#${id.toString().padLeft(4, '0')}',
                                style: xxsBold.copyWith(
                                  color: accentColor,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Legendary #$id',
                                style: smBold.copyWith(
                                  color: textNeutralPrimary,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Wrap(
                                spacing: 4,
                                children: types.map((t) {
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
                                            fontSize: 9.5,
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

                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 13,
                          color: black400,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  // ============================================================
  // BUILD
  // ============================================================
  @override
  Widget build(BuildContext context) {
    final gen = widget.generation;
    // Rebuild kartu & filter saat tipe asli selesai dimuat
    context.watch<PokemonTypeCubit>();

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: MonstraRefresh(
          onRefresh: () => _loadRegionalData(showLoading: false),
          child: CustomScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              // 1. App Bar minimalis (konsisten dengan GenerationScreen)
              SliverToBoxAdapter(child: _buildRegionHeroHeader(gen)),

              // 1b. Banner Region
              SliverToBoxAdapter(child: _buildRegionBanner(gen)),

              // 2. Quick Action Buttons (Map & Legendaries)
              SliverToBoxAdapter(child: _buildQuickActions(gen)),

              // 3 + 4. Search & filter tipe — menempel di atas saat di-scroll
              SliverPersistentHeader(
                pinned: true,
                delegate: _PinnedBarDelegate(
                  extent: 122,
                  builder: (overlaps) => AnimatedContainer(
                    duration: AppMotion.fast,
                    decoration: BoxDecoration(
                      color: bg,
                      boxShadow: overlaps
                          ? [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.06),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : null,
                    ),
                    child: Column(
                      children: [
                        _buildSearch(gen),
                        const SizedBox(height: 10),
                        PokemonTypeFilterBar(
                          selectedType: _selectedType,
                          onSelected: (type) {
                            setState(() => _selectedType = type);
                            _applyFilters();
                          },
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // 5. Pokédex Section Header
              SliverToBoxAdapter(child: _buildPokedexSectionHeader(gen)),

              // 6. Grid Content
              if (_isLoading)
                _buildShimmerGrid()
              else if (_filteredPokemon.isEmpty)
                SliverToBoxAdapter(child: _buildEmptyState())
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
                  sliver: _isGridMode
                      ? SliverGrid(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 14,
                            mainAxisSpacing: 14,
                            childAspectRatio: 0.74,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (context, index) => _buildPokemonCard(
                                _filteredPokemon[index], index),
                            childCount: _filteredPokemon.length,
                          ),
                        )
                      : SliverList.separated(
                          itemCount: _filteredPokemon.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) =>
                              _buildPokemonCard(_filteredPokemon[index], index),
                        ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // WIDGETS
  // ============================================================

  /// 1. Header halaman — memakai shared [AppPageHeader] (konsisten di semua layar)
  Widget _buildRegionHeroHeader(GenerationModel gen) {
    return AppPageHeader(
      title: '${gen.regionName} Atlas',
      subtitle: 'GEN ${gen.romanNumeral} • ${gen.year}',
      trailing: AppCircleButton(
        icon: _isFavorite
            ? Icons.favorite_rounded
            : Icons.favorite_border_rounded,
        iconColor: _isFavorite ? errorColor : bgDark,
        tooltip: _isFavorite ? 'Remove from favorites' : 'Add to favorites',
        onTap: () {
          setState(() => _isFavorite = !_isFavorite);
          AppMessenger.show(
            context,
            message: _isFavorite
                ? 'Added ${gen.regionName} to Favorites!'
                : 'Removed ${gen.regionName} from Favorites',
          );
        },
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
        floatArtwork: true,
      ),
    );
  }

  /// 2. Quick Actions — kartu Peta (pakai peta asli) & Legends (wajah legendary)
  Widget _buildQuickActions(GenerationModel gen) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: FadeSlideIn(
              delay: AppMotion.staggerAt(2),
              offset: const Offset(-12, 10),
              child: Pressable(
                semanticLabel: 'Open ${gen.regionName} map',
                onTap: _showMapModal,
                child: _MapActionCard(generation: gen),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: FadeSlideIn(
              delay: AppMotion.staggerAt(3),
              offset: const Offset(12, 10),
              child: Pressable(
                semanticLabel: '${gen.legendaryIds.length} legendary Pokémon',
                onTap: _showLegendariesModal,
                child: _LegendsActionCard(generation: gen),
              ),
            ),
          ),
        ],
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

  /// 5. Pokédex Section Header
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
                '(${_filteredPokemon.length})',
                style: xxsRegular.copyWith(color: black500, fontSize: 11),
              ),
            ],
          ),
          PokemonViewToggle(
            isGrid: _isGridMode,
            activeColor: gen.accentColor,
            onChanged: (grid) => setState(() => _isGridMode = grid),
          ),
        ],
      ),
    );
  }

  /// 6. Kartu Pokémon — shared [PokemonCard] (sama dengan HomeScreen)
  Widget _buildPokemonCard(PokemonListItemModel item, int index) {
    final id = item.id;
    final revealKey = '${_isGridMode}_${id ?? index}';
    return FadeSlideIn(
      key: ValueKey('region_card_$revealKey'),
      animate: _revealedCards.add(revealKey),
      delay: index < 8 ? AppMotion.staggerAt(index) : Duration.zero,
      offset: const Offset(0, 20),
      scaleFrom: 0.96,
      child: PokemonCard(
        pokemon: item,
        style: _isGridMode ? PokemonCardStyle.grid : PokemonCardStyle.list,
        isFavorite: id != null && _favoriteIds.contains(id),
        onFavoriteToggle: id == null
            ? null
            : () => setState(() {
                  if (!_favoriteIds.remove(id)) _favoriteIds.add(id);
                }),
        onTap: () => _navigateToPokemonDetail(item),
      ),
    );
  }

  Widget _buildShimmerGrid() {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          childAspectRatio: 0.74,
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

/// Isi bottom sheet peta region: peta (bisa di-zoom) + 2 info singkat.
class _RegionMapSheetContent extends StatefulWidget {
  const _RegionMapSheetContent({required this.generation});

  final GenerationModel generation;

  @override
  State<_RegionMapSheetContent> createState() => _RegionMapSheetContentState();
}

class _RegionMapSheetContentState extends State<_RegionMapSheetContent> {
  final TransformationController _zoomController = TransformationController();
  bool _isZoomed = false;

  @override
  void initState() {
    super.initState();
    _zoomController.addListener(() {
      final zoomed = _zoomController.value.getMaxScaleOnAxis() > 1.01;
      if (zoomed != _isZoomed) setState(() => _isZoomed = zoomed);
    });
  }

  @override
  void dispose() {
    _zoomController.dispose();
    super.dispose();
  }

  void _resetZoom() {
    HapticFeedback.selectionClick();
    _zoomController.value = Matrix4.identity();
  }

  @override
  Widget build(BuildContext context) {
    final gen = widget.generation;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Peta region
          FadeSlideIn(
            offset: const Offset(0, 16),
            scaleFrom: 0.97,
            child: AspectRatio(
              aspectRatio: 4 / 3,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  gradient: LinearGradient(colors: gen.gradientColors),
                  border: Border.all(
                    color: gen.accentColor.withValues(alpha: 0.22),
                    width: 1.2,
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    InteractiveViewer(
                      transformationController: _zoomController,
                      minScale: 1,
                      maxScale: 4,
                      child: Image.asset(
                        gen.mapAsset,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _MapPlaceholder(
                          accentColor: gen.accentColor,
                        ),
                      ),
                    ),

                    // Petunjuk zoom / tombol reset
                    Positioned(
                      right: 10,
                      bottom: 10,
                      child: AnimatedSwitcher(
                        duration: AppMotion.medium,
                        child: _isZoomed
                            ? _MapPill(
                                key: const ValueKey('reset'),
                                icon: Icons.zoom_out_map_rounded,
                                label: 'Reset',
                                onTap: _resetZoom,
                              )
                            : const _MapPill(
                                key: ValueKey('hint'),
                                icon: Icons.pinch_rounded,
                                label: 'Pinch to zoom',
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 14),

          // 2. Info singkat
          FadeSlideIn(
            delay: AppMotion.staggerAt(2),
            offset: const Offset(0, 12),
            child: Row(
              children: [
                Expanded(
                  child: _MapInfoTile(
                    icon: Icons.place_rounded,
                    label: 'Inspired by',
                    value: gen.realWorldInspiration,
                    accentColor: gen.accentColor,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _MapInfoTile(
                    icon: Icons.catching_pokemon,
                    label: 'Pokédex',
                    value: gen.idRange,
                    accentColor: gen.accentColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MapPill extends StatelessWidget {
  const _MapPill({
    super.key,
    required this.icon,
    required this.label,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final pill = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: black600),
          const SizedBox(width: 5),
          Text(label, style: xxsBold.copyWith(color: black700, fontSize: 11)),
        ],
      ),
    );

    if (onTap == null) return IgnorePointer(child: pill);
    return Pressable(onTap: onTap, pressedScale: 0.92, child: pill);
  }
}

class _MapInfoTile extends StatelessWidget {
  const _MapInfoTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.accentColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderNeutral, width: 1.1),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 16, color: accentColor),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: xxsMedium.copyWith(color: black500, fontSize: 10.5),
                ),
                const SizedBox(height: 1),
                Text(
                  value,
                  style: xsBold.copyWith(
                    color: textNeutralPrimary,
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MapPlaceholder extends StatelessWidget {
  const _MapPlaceholder({required this.accentColor});

  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.map_outlined, size: 36, color: accentColor),
          const SizedBox(height: 8),
          Text(
            'Map coming soon',
            style: xsBold.copyWith(color: accentColor),
          ),
        ],
      ),
    );
  }
}

const double _actionCardHeight = 104;

/// Kartu aksi "Region Map": latar potongan peta asli + gradasi warna region.
class _MapActionCard extends StatelessWidget {
  const _MapActionCard({required this.generation});

  final GenerationModel generation;

  @override
  Widget build(BuildContext context) {
    final gen = generation;
    return Container(
      height: _actionCardHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: gen.accentColor,
        boxShadow: [
          BoxShadow(
            color: gen.accentColor.withValues(alpha: 0.28),
            blurRadius: 14,
            offset: const Offset(0, 6),
            spreadRadius: -2,
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Potongan peta (sedikit diperbesar & digeser ke kanan)
          Transform.scale(
            scale: 1.5,
            alignment: Alignment.centerRight,
            child: Image.asset(
              gen.mapAsset,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
          ),
          // Gradasi agar teks tetap terbaca
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  gen.accentColor.withValues(alpha: 0.95),
                  gen.accentColor.withValues(alpha: 0.55),
                  gen.accentColor.withValues(alpha: 0.05),
                ],
                stops: const [0.0, 0.55, 1.0],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: SvgPicture.asset(
                    'assets/images/icons/map_fold.svg',
                    width: 16,
                    height: 16,
                    colorFilter:
                        const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Region Map',
                      style: smBold.copyWith(
                        color: Colors.white,
                        fontSize: 14,
                        height: 1.2,
                      ),
                    ),
                    Text(
                      'Tap to explore',
                      style: xxsMedium.copyWith(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 10.5,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Kartu aksi "Legends": tumpukan wajah legendary + jumlahnya.
class _LegendsActionCard extends StatelessWidget {
  const _LegendsActionCard({required this.generation});

  final GenerationModel generation;

  static const double _avatar = 38;
  static const double _overlap = 12;

  @override
  Widget build(BuildContext context) {
    final gen = generation;
    final shown = gen.legendaryIds.take(3).toList();
    final extra = gen.legendaryIds.length - shown.length;
    final slots = shown.length + (extra > 0 ? 1 : 0);

    return Container(
      height: _actionCardHeight,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.alphaBlend(gen.accentColor.withValues(alpha: 0.10), bgLight),
            bgLight,
          ],
        ),
        border: Border.all(
          color: gen.accentColor.withValues(alpha: 0.22),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: gen.accentColor.withValues(alpha: 0.10),
            blurRadius: 14,
            offset: const Offset(0, 6),
            spreadRadius: -2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Wajah legendary bertumpuk
          SizedBox(
            height: _avatar,
            width: _avatar + (slots - 1) * (_avatar - _overlap),
            child: Stack(
              children: [
                for (var i = 0; i < slots; i++)
                  Positioned(
                    left: i * (_avatar - _overlap),
                    child: i < shown.length
                        ? _LegendAvatar(
                            id: shown[i],
                            accentColor: gen.accentColor,
                            size: _avatar,
                          )
                        : _ExtraAvatar(
                            count: extra,
                            accentColor: gen.accentColor,
                            size: _avatar,
                          ),
                  ),
              ],
            ),
          ),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Legends',
                      style: smBold.copyWith(
                        color: textNeutralPrimary,
                        fontSize: 14,
                        height: 1.2,
                      ),
                    ),
                    Text(
                      '${gen.legendaryIds.length} legendary & mythical',
                      style:
                          xxsMedium.copyWith(color: black500, fontSize: 10.5),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              SvgPicture.asset(
                'assets/images/icons/crown.svg',
                width: 18,
                height: 18,
                colorFilter: ColorFilter.mode(gen.accentColor, BlendMode.srcIn),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegendAvatar extends StatelessWidget {
  const _LegendAvatar({
    required this.id,
    required this.accentColor,
    required this.size,
  });

  final int id;
  final Color accentColor;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Color.alphaBlend(accentColor.withValues(alpha: 0.12), bgLight),
        border: Border.all(color: bgLight, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipOval(
        child: CachedNetworkImage(
          imageUrl:
              'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png',
          fit: BoxFit.contain,
          fadeInDuration: AppMotion.medium,
          errorWidget: (_, __, ___) => Icon(
            Icons.catching_pokemon,
            size: size * 0.5,
            color: accentColor,
          ),
        ),
      ),
    );
  }
}

class _ExtraAvatar extends StatelessWidget {
  const _ExtraAvatar({
    required this.count,
    required this.accentColor,
    required this.size,
  });

  final int count;
  final Color accentColor;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: accentColor,
        border: Border.all(color: bgLight, width: 2),
      ),
      alignment: Alignment.center,
      child: Text(
        '+$count',
        style: xxsBold.copyWith(color: Colors.white, fontSize: 11),
      ),
    );
  }
}

/// Header yang menempel (pinned) dengan tinggi tetap.
class _PinnedBarDelegate extends SliverPersistentHeaderDelegate {
  _PinnedBarDelegate({required this.extent, required this.builder});

  final double extent;
  final Widget Function(bool overlapsContent) builder;

  @override
  double get minExtent => extent;

  @override
  double get maxExtent => extent;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) =>
      SizedBox.expand(child: builder(overlapsContent || shrinkOffset > 0));

  @override
  bool shouldRebuild(covariant _PinnedBarDelegate oldDelegate) => true;
}
