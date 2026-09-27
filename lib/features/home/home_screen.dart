import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shimmer/shimmer.dart';
import '../../models/pokemon_list_model.dart';
import '../../ui/color.dart';
import '../../ui/pokemon_type_data.dart';
import '../../ui/typography.dart';
import '../detail/detail_screen.dart';
import 'cubit/home_cubit.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  String _selectedType = 'All';
  String _searchQuery = '';
  bool _isGridMode = true; // true: 2-kolom grid, false: 1-kolom list horizontal
  final Set<int> _favoriteIds = {
    25,
    6
  }; // Pikachu & Charizard favorited by default
  final TextEditingController _searchController = TextEditingController();
  late final ScrollController _scrollController;

  Color _getPokemonAccentColor(int id) => PokemonTypeColors.getColorById(id);

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.hasClients &&
        _scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 250) {
      context.read<HomeCubit>().loadMorePokemon();
    }
  }

  void _toggleFavorite(int id) {
    setState(() {
      if (_favoriteIds.contains(id)) {
        _favoriteIds.remove(id);
      } else {
        _favoriteIds.add(id);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // Filtered Pokémon list for PokéAPI Real Data
  List<PokemonListItemModel> _filterPokemonList(
      List<PokemonListItemModel> list) {
    return list.where((pokemon) {
      final query = _searchQuery.toLowerCase().trim();
      if (query.isEmpty) return true;
      final nameMatch = pokemon.name?.toLowerCase().contains(query) ?? false;
      final idMatch = pokemon.formattedId.contains(query) ||
          (pokemon.id?.toString().contains(query) ?? false);
      return nameMatch || idMatch;
    }).toList();
  }

  // Surprise random Pokémon picker dari PokéAPI
  void _pickRandomPokemon() {
    final state = context.read<HomeCubit>().state;
    if (state is HomeLoaded && state.pokemonList.isNotEmpty) {
      final random = Random();
      final randomPokemon =
          state.pokemonList[random.nextInt(state.pokemonList.length)];
      _showPokemonItemQuickDetails(randomPokemon);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Memuat data Pokémon dari PokéAPI...'),
          duration: Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: RefreshIndicator(
          color: primaryColor,
          backgroundColor: bgLight,
          onRefresh: () => context.read<HomeCubit>().getPokemonList(),
          child: CustomScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              // 1. Explorer Header
              SliverToBoxAdapter(
                child: _buildHeader(),
              ),
              // 3. Featured Hero Card
              SliverToBoxAdapter(
                child: _buildFeaturedCard(),
              ),
              // 4. Blok (Evolution & Compare)
              SliverToBoxAdapter(
                child: _buildPokeTools(),
              ),

              // 4. Element Type Filter Bar
              SliverToBoxAdapter(
                child: _buildTypeFilterBar(),
              ),

              SliverToBoxAdapter(
                child: _buildSearchBar(),
              ),

              // 5. Section Title: Pokémon List (Synced with Cubit State)
              BlocBuilder<HomeCubit, HomeState>(
                builder: (context, state) {
                  int count = 0;
                  if (state is HomeLoaded) {
                    count = _filterPokemonList(state.pokemonList).length;
                  }
                  return SliverToBoxAdapter(
                    child: _buildSectionTitle(
                      title: _selectedType == 'All'
                          ? 'Explore Pokémon'
                          : '$_selectedType Pokémon',
                      count: count,
                    ),
                  );
                },
              ),

              // 6. 2-Column Pokémon Cards Grid / Shimmer / Error
              BlocBuilder<HomeCubit, HomeState>(
                builder: (context, state) {
                  if (state is HomeLoading) {
                    return _buildShimmerGrid();
                  } else if (state is HomeError) {
                    return _buildErrorState(state.message);
                  } else if (state is HomeLoaded) {
                    final filtered = _filterPokemonList(state.pokemonList);
                    return _buildPokemonGrid(
                      pokemons: filtered,
                      isLoadingMore: state.isLoadingMore,
                    );
                  }
                  return const SliverToBoxAdapter(child: SizedBox.shrink());
                },
              ),

              // Bottom Spacing for Floating Navigation Bar
              const SliverToBoxAdapter(
                child: SizedBox(height: 100),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================================
  // MODULAR PRIVATE WIDGET BUILDERS (Sesuai Konvensi Rapi)
  // ==========================================================================

  /// Header sambutan dengan info trainer dan tombol acak
  /// Header modern & playful (Left Action - Center Title - Right Action)
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 1. Sisi Kiri: Spacer penyeimbang (44px) agar judul PokéAtlas tetap presisi di tengah
          const SizedBox(width: 44, height: 44),

          // 2. Tengah: Judul PokéAtlas Playful
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Poké',
                      style: lBold.copyWith(
                        fontSize: 22,
                        letterSpacing: -0.5,
                        color: bgDark,
                      ),
                    ),
                    TextSpan(
                      text: 'Atlas',
                      style: lBold.copyWith(
                        fontSize: 22,
                        letterSpacing: -0.5,
                        color: primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // 3. Ikon Kanan: Surprise Pokémon Encounter (Dadu Acak)
          _buildHeaderCircleButton(
            icon: Icons.casino_outlined,
            tooltip: 'Surprise Pokémon!',
            hasBadgeDot: true, // Dot merah aksen Pokémon liar
            onTap: _pickRandomPokemon,
          ),
        ],
      ),
    );
  }

  /// Helper tombol lingkaran empuk di Header
  Widget _buildHeaderCircleButton({
    required IconData icon,
    required VoidCallback onTap,
    String? tooltip,
    bool hasBadgeDot = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
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
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(
                icon,
                size: 20,
                color: bgDark,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Search Bar interaktif dengan clear action
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: bgLight,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: borderNeutral),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (value) => setState(() => _searchQuery = value),
          decoration: InputDecoration(
            hintText: 'Search Pokémon',
            hintStyle: smRegular.copyWith(
              fontSize: 13.5,
              color: black400,
            ),
            prefixIcon: const Icon(Icons.search, color: black500, size: 22),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, size: 18, color: black400),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                  )
                : const Icon(Icons.tune_rounded, color: black400, size: 20),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          ),
        ),
      ),
    );
  }

  /// Banner Hero Pokémon of the Day (Charizard)
  Widget _buildFeaturedCard() {
    const featured = PokemonListItemModel(
      name: 'charizard',
      url: 'https://pokeapi.co/api/v2/pokemon/6/',
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: InkWell(
        onTap: () => _showPokemonItemQuickDetails(featured),
        borderRadius: BorderRadius.circular(24),
        child: Container(
          height: 180,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                PokemonTypeColors.fire,
                orange700,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: PokemonTypeColors.fire.withValues(alpha: 0.35),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              // Background Pokéball Watermark Motif
              Positioned(
                right: -30,
                bottom: -35,
                child: Opacity(
                  opacity: 0.15,
                  child: Container(
                    width: 220,
                    height: 220,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: bgLight,
                    ),
                  ),
                ),
              ),

              // Content Info (Left Side)
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Badge: Featured of the day
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: bgLight.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('🔥', style: xsRegular),
                          const SizedBox(width: 4),
                          Text(
                            'FEATURED TODAY',
                            style: xxsBold.copyWith(
                              color: black00,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Pokémon Name & ID
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          featured.formattedId,
                          style: xsSemiBold.copyWith(
                            color: black00.withValues(alpha: 0.8),
                          ),
                        ),
                        Text(
                          featured.capitalizedName,
                          style: lBold.copyWith(
                            fontSize: 24,
                            color: black00,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),

                    // Type Chips
                    Row(
                      children: const ['Fire', 'Flying'].map((type) {
                        return _buildTypeBadge(
                          type,
                          isLightBackground: false,
                          iconSize: 13,
                          fontSize: 11,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 3.5),
                          margin: const EdgeInsets.only(right: 6),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),

              // Pokémon Artwork popping out (Right Side)
              Positioned(
                right: 10,
                bottom: -5,
                top: 10,
                child: CachedNetworkImage(
                  imageUrl: featured.imageUrl ?? '',
                  width: 170,
                  fit: BoxFit.contain,
                  placeholder: (context, url) => const Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: bgLight,
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) =>
                      const Icon(Icons.broken_image, color: Colors.white70),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // kotak kembar (Twin bento tiles) Evolution Tree & Compare Arena
  // Poké Tools: Row(Evolution, Compare) + Banner Horizontal(Generation Explorer)
  Widget _buildPokeTools() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
          child: Text(
            'Poké Tools',
            style: mdBold.copyWith(color: bgDark),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            children: [
              // 1. BARIS ATAS: Row(Evolution, Compare)
              Row(
                children: [
                  Expanded(
                    child: _buildToolTwinCard(
                      title: 'Evolution',
                      subtitle: 'Branches & Forms',
                      badgeText: 'DNA TREE',
                      badgeIcon: Icons.alt_route_rounded,
                      gradientColors: const [
                        PokemonTypeColors.grass,
                        PokemonTypeColors.ice,
                      ],
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '🧬 Evolution Explorer coming soon!',
                              style: xsMedium.copyWith(color: black00),
                            ),
                            duration: const Duration(seconds: 1),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildToolTwinCard(
                      title: 'Compare',
                      subtitle: 'Stat Matchup',
                      badgeText: 'VS ARENA',
                      badgeIcon: Icons.bolt_rounded,
                      gradientColors: const [
                        PokemonTypeColors.dragon,
                        PokemonTypeColors.fighting,
                      ],
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '⚔️ Compare Pokémon coming soon!',
                              style: xsMedium.copyWith(color: black00),
                            ),
                            duration: const Duration(seconds: 1),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // 2.Kotak Horizontal Lebar Generation & Region Atlas
              _buildGenerationHorizontalBanner(),
            ],
          ),
        ),
      ],
    );
  }

  /// Kartu kembar di baris atas (Evolution & Compare)
  Widget _buildToolTwinCard({
    required String title,
    required String subtitle,
    required String badgeText,
    required IconData badgeIcon,
    required List<Color> gradientColors,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          height: 114,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: gradientColors,
            ),
            boxShadow: [
              BoxShadow(
                color: gradientColors.first.withValues(alpha: 0.28),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              // Pokéball watermark di kanan bawah
              Positioned(
                right: -15,
                bottom: -15,
                child: Opacity(
                  opacity: 0.14,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: bgLight,
                    ),
                  ),
                ),
              ),

              // Ikon besar transparan melayang di kanan
              Positioned(
                right: 6,
                bottom: 8,
                child: Icon(
                  badgeIcon,
                  size: 44,
                  color: bgLight.withValues(alpha: 0.22),
                ),
              ),

              // Konten Teks & Badge
              Padding(
                padding: const EdgeInsets.all(13.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Badge Chip
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7.5,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: bgLight.withValues(alpha: 0.22),
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(badgeIcon, size: 10.5, color: black00),
                          const SizedBox(width: 3.5),
                          Text(
                            badgeText,
                            style: xxsBold.copyWith(
                              fontSize: 9,
                              color: black00,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Title & Subtitle
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: smBold.copyWith(
                            fontSize: 15,
                            color: black00,
                          ),
                        ),
                        const SizedBox(height: 1.5),
                        Text(
                          subtitle,
                          style: xxsRegular.copyWith(
                            fontSize: 10,
                            color: black00.withValues(alpha: 0.85),
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
    );
  }

  /// Banner horizontal lebar untuk Generation & Regions Atlas di baris bawah
  Widget _buildGenerationHorizontalBanner() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '🌍 Generation & Region Atlas coming soon!',
                style: xsMedium.copyWith(color: black00),
              ),
              duration: const Duration(seconds: 1),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          height: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                PokemonTypeColors.water,
                PokemonTypeColors.dragon,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: PokemonTypeColors.water.withValues(alpha: 0.30),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              // Pokéball watermark kanan
              Positioned(
                right: -20,
                bottom: -28,
                child: Opacity(
                  opacity: 0.12,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: bgLight,
                    ),
                  ),
                ),
              ),

              // Ikon Globe transparan besar di kanan
              Positioned(
                right: 0,
                bottom: -10,
                top: 20,
                child: Icon(
                  Icons.public_rounded,
                  size: 72,
                  color: bgLight.withValues(alpha: 0.16),
                ),
              ),

              // Konten Banner
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 12.0),
                child: Row(
                  children: [
                    // Kolom Kiri: Badge & Nama Fitur
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Badge Chip
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: bgLight.withValues(alpha: 0.22),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.public_rounded,
                                    size: 10.5, color: black00),
                                const SizedBox(width: 4),
                                Text(
                                  'REGION ATLAS',
                                  style: xxsBold.copyWith(
                                    fontSize: 9,
                                    color: black00,
                                    letterSpacing: 0.6,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Judul & Keterangan Region
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Generation Explorer',
                                style: smBold.copyWith(
                                  fontSize: 15.5,
                                  color: black00,
                                  letterSpacing: -0.2,
                                ),
                              ),
                              Text(
                                'Kanto to Paldea • 9 Generations',
                                style: xxsRegular.copyWith(
                                  fontSize: 10.5,
                                  color: black00.withValues(alpha: 0.85),
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
            ],
          ),
        ),
      ),
    );
  }

  /// Baris filter elemen tipe (Fire, Water, Grass, dll.)
  Widget _buildTypeFilterBar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Text(
            'Filter by Element',
            style: mdBold.copyWith(color: bgDark),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 42,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: pokemonTypeList.length,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final typeItem = pokemonTypeList[index];
              final isSelected = _selectedType == typeItem.name;

              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      if (_selectedType == typeItem.name) return;
                      setState(() => _selectedType = typeItem.name);
                      context.read<HomeCubit>().filterByType(typeItem.name);
                      if (_scrollController.hasClients) {
                        _scrollController.animateTo(
                          0,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOut,
                        );
                      }
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: isSelected ? typeItem.color : bgLight,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? typeItem.color : borderNeutral,
                          width: 1.2,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: typeItem.color.withValues(alpha: 0.35),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ]
                            : null,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (typeItem.iconAsset != null)
                            SvgPicture.asset(
                              typeItem.iconAsset!,
                              width: 14,
                              height: 14,
                              colorFilter: ColorFilter.mode(
                                isSelected ? black00 : typeItem.color,
                                BlendMode.srcIn,
                              ),
                            )
                          else
                            Icon(
                              typeItem.fallbackIcon ?? Icons.catching_pokemon,
                              size: 14,
                              color: isSelected ? black00 : typeItem.color,
                            ),
                          const SizedBox(width: 6),
                          Text(
                            typeItem.name,
                            style: (isSelected ? xsBold : xsMedium).copyWith(
                              fontSize: 12.5,
                              color: isSelected ? black00 : black700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  /// Judul section daftar kartu dengan badge jumlah hasil & switcher View Mode (2-Kolom Grid / 1-Kolom List)
  Widget _buildSectionTitle({required String title, required int count}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Sisi Kiri: Judul & Badge Jumlah Pokémon
          Row(
            children: [
              Text(
                title,
                style: lgBold.copyWith(color: bgDark),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: black100,
                  borderRadius: BorderRadius.circular(10),
                ),
                // child: Text(
                //   '$count',
                //   style: xsSemiBold.copyWith(
                //     fontSize: 11.5,
                //     color: black500,
                //   ),
                // ),
              ),
            ],
          ),

          // Sisi Kanan: Mini Pill View Switcher (Grid 2 Kolom vs List 1 Kolom)
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: black100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: borderNeutral.withValues(alpha: 0.6),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildViewToggleItem(
                  icon: Icons.grid_view_rounded,
                  tooltip: '2-Column Grid',
                  isSelected: _isGridMode,
                  onTap: () {
                    if (!_isGridMode) setState(() => _isGridMode = true);
                  },
                ),
                const SizedBox(width: 2),
                _buildViewToggleItem(
                  icon: Icons.view_agenda_rounded,
                  tooltip: '1-Column Detailed List',
                  isSelected: !_isGridMode,
                  onTap: () {
                    if (_isGridMode) setState(() => _isGridMode = false);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Tombol icon di dalam mini pill switcher view mode
  Widget _buildViewToggleItem({
    required IconData icon,
    required String tooltip,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(9),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? bgLight : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Icon(
          icon,
          size: 16,
          color: isSelected ? primaryColor : black400,
        ),
      ),
    );
  }

  /// Shimmer loading skeleton saat pertama kali memuat Pokémon dari PokéAPI
  Widget _buildShimmerGrid() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
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
                          width: 20,
                          height: 20,
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

  /// State error jika gagal koneksi ke PokéAPI dengan tombol retry
  Widget _buildErrorState(String message) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: errorColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.cloud_off_rounded,
                color: errorColor,
                size: 32,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Gagal Memuat Pokémon',
              style: mdBold.copyWith(color: bgDark),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: smRegular.copyWith(color: black500, fontSize: 13),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                if (_selectedType == 'All') {
                  context.read<HomeCubit>().getPokemonList();
                } else {
                  context.read<HomeCubit>().filterByType(_selectedType);
                }
              },
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Grid 2 kolom atau List 1 kolom kartu Pokémon dari PokéAPI
  Widget _buildPokemonGrid({
    required List<PokemonListItemModel> pokemons,
    required bool isLoadingMore,
  }) {
    if (pokemons.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40.0),
          child: Column(
            children: [
              const Text('🔍', style: xxlRegular),
              const SizedBox(height: 12),
              Text(
                'No Pokémon found',
                style: mdSemiBold.copyWith(color: bgDark),
              ),
              const SizedBox(height: 6),
              Text(
                'Try searching with a different name or ID.',
                style: smRegular.copyWith(
                  fontSize: 13,
                  color: black500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SliverMainAxisGroup(
      slivers: [
        if (_isGridMode)
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 0.78,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final pokemon = pokemons[index];
                  return _buildPokemonCard(pokemon);
                },
                childCount: pokemons.length,
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList.separated(
              itemCount: pokemons.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final pokemon = pokemons[index];
                return _buildPokemonListCard(pokemon);
              },
            ),
          ),
        if (isLoadingMore)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 24.0),
              child: Center(
                child: SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: primaryColor,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  /// Kartu 1 kolom (Horizontal Banner) dengan artwork besar di kanan
  Widget _buildPokemonListCard(PokemonListItemModel pokemon) {
    final typeColor = _getPokemonAccentColor(pokemon.id ?? 1);
    final isFav = _favoriteIds.contains(pokemon.id ?? 0);

    return InkWell(
      onTap: () => _showPokemonItemQuickDetails(pokemon),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 118,
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
            // Soft gradient accent from left to right
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      typeColor.withValues(alpha: 0.12),
                      typeColor.withValues(alpha: 0.02),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // Subtle Pokéball watermark motif behind sprite
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
                    color: typeColor,
                  ),
                ),
              ),
            ),

            // Content Layout
            Row(
              children: [
                // Info sisi kiri (ID, Nama, National Dex tag)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              pokemon.formattedId,
                              style: xxsBold.copyWith(
                                fontSize: 11,
                                color: black500,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: typeColor.withValues(alpha: 0.14),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'National Dex',
                                style: xxsSemiBold.copyWith(
                                  fontSize: 9.5,
                                  color: typeColor,
                                ),
                              ),
                            ),
                          ],
                        ),

                        // Nama Pokémon
                        Text(
                          pokemon.capitalizedName,
                          style: mdBold.copyWith(
                            color: bgDark,
                            fontSize: 17,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),

                        Row(
                          children: [
                            Icon(Icons.catching_pokemon,
                                size: 13, color: typeColor),
                            const SizedBox(width: 4),
                            Text(
                              'Tap to inspect entry',
                              style: xxsRegular.copyWith(color: black500),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Artwork & Favorite Button di sisi kanan
                SizedBox(
                  width: 115,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Sprite Resmi PokéAPI
                      Positioned(
                        right: 8,
                        bottom: 4,
                        top: 4,
                        child: Hero(
                          tag: 'pokemon_${pokemon.id}',
                          child: CachedNetworkImage(
                            imageUrl: pokemon.imageUrl ?? '',
                            width: 100,
                            height: 100,
                            fit: BoxFit.contain,
                            placeholder: (context, url) => const Center(
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: primaryColor,
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => const Icon(
                              Icons.catching_pokemon,
                              size: 40,
                              color: black400,
                            ),
                          ),
                        ),
                      ),

                      // Floating Favorite Heart Button
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              if (pokemon.id != null) {
                                _toggleFavorite(pokemon.id!);
                              }
                            },
                            borderRadius: BorderRadius.circular(14),
                            child: Container(
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: bgLight.withValues(alpha: 0.85),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                              child: Icon(
                                isFav ? Icons.favorite : Icons.favorite_border,
                                size: 16,
                                color: isFav ? errorColor : black400,
                              ),
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
    );
  }

  /// Kartu satuan Pokémon dengan palet warna dinamis sesuai tipe
  Widget _buildPokemonCard(PokemonListItemModel pokemon) {
    final typeColor = _getPokemonAccentColor(pokemon.id ?? 1);
    final isFav = _favoriteIds.contains(pokemon.id ?? 0);

    return InkWell(
      onTap: () => _showPokemonItemQuickDetails(pokemon),
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
            // Soft colored background tint for top section
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
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Row: Number ID & Favorite Toggle
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        pokemon.formattedId,
                        style: xxsBold.copyWith(
                          fontSize: 11,
                          color: black500,
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          if (pokemon.id != null) {
                            _toggleFavorite(pokemon.id!);
                          }
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: Icon(
                            isFav ? Icons.favorite : Icons.favorite_border,
                            size: 19,
                            color: isFav ? errorColor : black400,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Image Container
                  Expanded(
                    child: Center(
                      child: Hero(
                        tag: 'pokemon_${pokemon.id}',
                        child: CachedNetworkImage(
                          imageUrl: pokemon.imageUrl ?? '',
                          fit: BoxFit.contain,
                          placeholder: (context, url) => Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: typeColor,
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => const Icon(
                            Icons.catching_pokemon,
                            size: 36,
                            color: black400,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Pokémon Name
                  Text(
                    pokemon.capitalizedName,
                    style: smBold.copyWith(
                      fontSize: 15,
                      color: bgDark,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 6),

                  // Pokédex Entry Tag
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 2.5,
                    ),
                    decoration: BoxDecoration(
                      color: typeColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.catching_pokemon,
                          size: 11,
                          color: typeColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'GEN I',
                          style: xxsBold.copyWith(
                            color: typeColor,
                            fontSize: 10,
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
    );
  }

  /// Modal Bottom Sheet Detail Singkat untuk Pokémon dari API
  void _showPokemonItemQuickDetails(PokemonListItemModel pokemon) {
    final typeColor = _getPokemonAccentColor(pokemon.id ?? 1);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final modalFav = _favoriteIds.contains(pokemon.id ?? 0);
            return Container(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
              decoration: const BoxDecoration(
                color: bgLight,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: black300,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            pokemon.formattedId,
                            style: xsBold.copyWith(
                              fontSize: 13,
                              color: black500,
                            ),
                          ),
                          Text(
                            pokemon.capitalizedName,
                            style: lBold.copyWith(
                              fontSize: 26,
                              color: bgDark,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: () {
                          if (pokemon.id != null) {
                            _toggleFavorite(pokemon.id!);
                            setModalState(() {});
                          }
                        },
                        icon: Icon(
                          modalFav ? Icons.favorite : Icons.favorite_border,
                          color: modalFav ? errorColor : black400,
                          size: 26,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 180,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: typeColor.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: CachedNetworkImage(
                        imageUrl: pokemon.imageUrl ?? '',
                        height: 160,
                        fit: BoxFit.contain,
                        placeholder: (context, url) => Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: typeColor,
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => const Icon(
                          Icons.catching_pokemon,
                          size: 48,
                          color: black400,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Entry resmi Pokémon dari PokéAPI database. Tap detail untuk mengecek base stats, abilities, move pool, dan evolusi.',
                    style: smRegular.copyWith(
                      fontSize: 13,
                      color: black600,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailScreen(
                              pokemonIdOrName: pokemon.id?.toString() ?? pokemon.name ?? '6',
                              initialPokemonId: pokemon.id ?? 6,
                              initialName: pokemon.capitalizedName,
                              initialImageUrl: pokemon.imageUrl,
                              initialColor: typeColor,
                              initialTypes: PokemonTypeColors.getTypesById(pokemon.id),
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: typeColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        'Lihat Detail Lengkap',
                        style: smBold.copyWith(
                          color: Colors.white,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  /// Badge elemen Pokémon dengan ikon SVG resmi dari assets/images/element/
  Widget _buildTypeBadge(
    String type, {
    bool isLightBackground = true,
    double iconSize = 11,
    double fontSize = 10,
    EdgeInsetsGeometry padding =
        const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
    EdgeInsetsGeometry margin = EdgeInsets.zero,
  }) {
    final color = PokemonTypeColors.getColor(type);
    final assetPath = 'assets/images/element/${type.toLowerCase()}.svg';

    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: isLightBackground
            ? color.withValues(alpha: 0.14)
            : bgLight.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            assetPath,
            width: iconSize,
            height: iconSize,
            colorFilter: ColorFilter.mode(
              isLightBackground ? color : black00,
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            type,
            style: xxsBold.copyWith(
              color: isLightBackground ? color : black00,
              fontSize: fontSize,
            ),
          ),
        ],
      ),
    );
  }
}
