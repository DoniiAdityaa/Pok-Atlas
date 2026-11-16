import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shimmer/shimmer.dart';
import '../../config/service_locator.dart';
import '../../models/pokemon_list_model.dart';
import '../../repository/pokemon_list/pokemon_list_repository.dart';
import '../../ui/color.dart';
import '../../ui/shared_widget/app_messenger.dart';
import '../../ui/shared_widget/pokemon_empty_state.dart';
import '../../ui/shared_widget/pokemon_search_bar.dart';
import '../../ui/shared_widget/pokemon_type_filter_bar.dart';
import '../../ui/typography.dart';
import '../detail/detail_screen.dart';
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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) {
        return Container(
          height: MediaQuery.of(modalContext).size.height * 0.75,
          decoration: const BoxDecoration(
            color: bgLight,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              _buildModalHandle(),
              _buildModalHeader(
                title: '${widget.generation.regionName} Cartography',
                subtitle: 'Official Geographic Atlas of the Region',
                onClose: () => Navigator.pop(modalContext),
              ),
              const Divider(height: 1, color: borderNeutral),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Map Banner
                      Container(
                        height: 220,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          gradient: LinearGradient(
                            colors: widget.generation.gradientColors,
                          ),
                          border: Border.all(
                            color: widget.generation.accentColor
                                .withValues(alpha: 0.25),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: widget.generation.accentColor
                                  .withValues(alpha: 0.10),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Pokéball watermark
                            Positioned(
                              right: -20,
                              bottom: -20,
                              child: Opacity(
                                opacity: 0.08,
                                child: Container(
                                  width: 130,
                                  height: 130,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: bgLight,
                                  ),
                                ),
                              ),
                            ),
                            Image.asset(
                              widget.generation.groupArtworkAsset,
                              width: 160,
                              fit: BoxFit.contain,
                            ),
                            Positioned(
                              bottom: 12,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 5),
                                decoration: BoxDecoration(
                                  color:
                                      Colors.white.withValues(alpha: 0.92),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          Colors.black.withValues(alpha: 0.08),
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                                child: Text(
                                  '🗺️  ${widget.generation.regionName} Territory Map',
                                  style: xxsBold.copyWith(
                                    color: widget.generation.accentColor,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      Text(
                        'Regional Geography & Lore',
                        style: smBold.copyWith(color: textNeutralPrimary),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'The ${widget.generation.regionName} region is renowned for its diverse natural habitats ranging from coastal towns to rugged mountain ranges. Inspired by real-world ${widget.generation.realWorldInspiration}, trainers embark across famous routes and gym cities.',
                        style: smRegular.copyWith(
                          color: black600,
                          height: 1.55,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Real-world highlight badge
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: widget.generation.accentColor
                              .withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: widget.generation.accentColor
                                .withValues(alpha: 0.20),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: widget.generation.accentColor
                                    .withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  '📍',
                                  style: const TextStyle(fontSize: 18),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Real-World Inspiration',
                                    style: xxsBold.copyWith(
                                      color: widget.generation.accentColor,
                                      letterSpacing: 0.4,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    widget.generation.realWorldInspiration,
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
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ============================================================
  // MODAL: Legendaries
  // ============================================================
  void _showLegendariesModal() {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) {
        return Container(
          height: MediaQuery.of(modalContext).size.height * 0.70,
          decoration: const BoxDecoration(
            color: bgLight,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              _buildModalHandle(),
              _buildModalHeader(
                title: '${widget.generation.regionName} Legendary Pokémon',
                subtitle:
                    '${widget.generation.legendaryIds.length} Mythical & Legendary Species',
                onClose: () => Navigator.pop(modalContext),
              ),
              const Divider(height: 1, color: borderNeutral),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(20),
                  physics: const BouncingScrollPhysics(),
                  itemCount: widget.generation.legendaryIds.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final id = widget.generation.legendaryIds[index];
                    final types = PokemonTypeColors.getTypesById(id);
                    final accentColor = types.isNotEmpty
                        ? PokemonTypeColors.getColor(types.first)
                        : widget.generation.accentColor;

                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          Navigator.pop(modalContext);
                          _navigateToPokemonDetail(
                            PokemonListItemModel(
                              name: 'pokemon',
                              url: 'https://pokeapi.co/api/v2/pokemon/$id/',
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(18),
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
                                        final tc =
                                            PokemonTypeColors.getColor(t);
                                        final assetPath =
                                            'assets/images/element/${t.toLowerCase()}.svg';
                                        return Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 7, vertical: 2.5),
                                          decoration: BoxDecoration(
                                            color: tc.withValues(alpha: 0.14),
                                            borderRadius:
                                                BorderRadius.circular(8),
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
              ),
            ],
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

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: CustomScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          slivers: [
            // 1. Hero Header
            SliverToBoxAdapter(child: _buildRegionHeroHeader(gen)),

            // 2. Quick Action Buttons (Map & Legendaries)
            SliverToBoxAdapter(child: _buildQuickActions(gen)),

            // 3. Search Bar
            SliverToBoxAdapter(child: _buildSearch(gen)),

            // 4. Type Filter Bar (shared component)
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

  /// Reusable modal drag handle
  Widget _buildModalHandle() {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(top: 12, bottom: 8),
        width: 40,
        height: 4.5,
        decoration: BoxDecoration(
          color: black300,
          borderRadius: BorderRadius.circular(3),
        ),
      ),
    );
  }

  /// Reusable modal header row
  Widget _buildModalHeader({
    required String title,
    required String subtitle,
    required VoidCallback onClose,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: mdBold.copyWith(
                    color: textNeutralPrimary,
                    fontSize: 18,
                  ),
                ),
                Text(
                  subtitle,
                  style: xxsRegular.copyWith(color: black500),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onClose,
            icon: const Icon(Icons.close_rounded, color: black500),
          ),
        ],
      ),
    );
  }

  /// 1. Hero Header dengan gradient pastel, ilustrasi starter, dan watermark
  Widget _buildRegionHeroHeader(GenerationModel gen) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gen.gradientColors,
        ),
        border: Border.all(
          color: gen.accentColor.withValues(alpha: 0.22),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: gen.accentColor.withValues(alpha: 0.14),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Decorative circle watermark (kanan bawah)
          Positioned(
            right: -28,
            bottom: -28,
            child: Opacity(
              opacity: 0.12,
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
          Positioned(
            right: 10,
            bottom: 10,
            child: Opacity(
              opacity: 0.06,
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: gen.accentColor,
                ),
              ),
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 14, 14, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Bar: Back | Gen Badge | Favorite
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Tombol Back
                    Material(
                      color: Colors.white,
                      shape: const CircleBorder(),
                      elevation: 0,
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () => Navigator.pop(context),
                        child: const SizedBox(
                          width: 38,
                          height: 38,
                          child: Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 16,
                            color: textNeutralPrimary,
                          ),
                        ),
                      ),
                    ),

                    // Badge Gen
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: gen.accentColor.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: gen.accentColor.withValues(alpha: 0.32),
                        ),
                      ),
                      child: Text(
                        'GEN ${gen.romanNumeral} • ${gen.year}',
                        style: xxsBold.copyWith(
                          color: gen.accentColor,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),

                    // Tombol Favorite
                    Material(
                      color: Colors.white,
                      shape: const CircleBorder(),
                      elevation: 0,
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() => _isFavorite = !_isFavorite);
                          AppMessenger.show(
                            context,
                            message: _isFavorite
                                ? '❤️  Added ${gen.regionName} to Favorites!'
                                : 'Removed ${gen.regionName} from Favorites',
                          );
                        },
                        child: SizedBox(
                          width: 38,
                          height: 38,
                          child: Icon(
                            _isFavorite
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            size: 18,
                            color: _isFavorite ? errorColor : black500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Kiri: Teks | Kanan: Ilustrasi Trio
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Teks info region
                    Expanded(
                      flex: 11,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            gen.regionName.toUpperCase(),
                            style: lBold.copyWith(
                              color: textNeutralPrimary,
                              fontSize: 30,
                              letterSpacing: 0.5,
                              height: 1.0,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            gen.games,
                            style: xxsMedium.copyWith(
                              color: black600,
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            gen.tagline,
                            style: xxsRegular.copyWith(
                              color: black500,
                              fontSize: 10,
                              fontStyle: FontStyle.italic,
                              height: 1.4,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 12),
                          // Real-world location chip
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.88),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: gen.accentColor.withValues(alpha: 0.22),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '📍',
                                  style: const TextStyle(fontSize: 10),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  gen.realWorldInspiration,
                                  style: xxsSemiBold.copyWith(
                                    color: gen.accentColor,
                                    fontSize: 9.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 6),

                    // Ilustrasi Trio Starter
                    SizedBox(
                      width: 128,
                      height: 116,
                      child: Image.asset(
                        gen.groupArtworkAsset,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.catching_pokemon,
                          size: 48,
                          color: black400,
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
    );
  }

  /// 2. Quick Actions — Explore Map & Legendaries (lebih berkarakter)
  Widget _buildQuickActions(GenerationModel gen) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Row(
        children: [
          _buildActionButton(
            emoji: '🗺️',
            label: 'Explore Map',
            accentColor: gen.accentColor,
            onTap: _showMapModal,
          ),
          const SizedBox(width: 10),
          _buildActionButton(
            emoji: '👑',
            label: '${gen.legendaryIds.length} Legendaries',
            accentColor: gen.accentColor,
            onTap: _showLegendariesModal,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String emoji,
    required String label,
    required Color accentColor,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            onTap();
          },
          borderRadius: BorderRadius.circular(18),
          child: Container(
            padding:
                const EdgeInsets.symmetric(vertical: 11, horizontal: 12),
            decoration: BoxDecoration(
              color: bgLight,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: accentColor.withValues(alpha: 0.20),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: accentColor.withValues(alpha: 0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(emoji, style: const TextStyle(fontSize: 15)),
                const SizedBox(width: 7),
                Flexible(
                  child: Text(
                    label,
                    style: xsBold.copyWith(
                      color: textNeutralPrimary,
                      fontSize: 12,
                    ),
                    overflow: TextOverflow.ellipsis,
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
