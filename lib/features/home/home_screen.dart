import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shimmer/shimmer.dart';
import '../../config/service_locator.dart';
import '../../data/api/api_service.dart';
import '../../models/pokemon_detail_model.dart';
import '../../models/pokemon_list_model.dart';
import '../../ui/shared_widget/monstra_mascot.dart';
import '../../ui/shared_widget/monstra_poses.dart';
import '../../ui/color.dart';
import '../../ui/motion/motion.dart';
import '../../ui/shared_widget/app_header.dart';
import '../../ui/shared_widget/app_messenger.dart';
import '../../ui/shared_widget/pokemon_card.dart';
import '../../ui/shared_widget/monstra_refresh.dart';
import '../../ui/shared_widget/pokemon_empty_state.dart';
import '../../ui/shared_widget/pokemon_search_bar.dart';
import '../../ui/shared_widget/pokemon_type_filter_bar.dart';
import '../../ui/typography.dart';
import '../compare/compare_screen.dart';
import '../detail/detail_screen.dart';
import '../generation/generation_screen.dart';
import '../pokemon_type/cubit/pokemon_type_cubit.dart';
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
  final FocusNode _searchFocusNode = FocusNode();
  late final ScrollController _scrollController;

  /// ID kartu yang sudah pernah dianimasikan masuk. Kartu yang di-recycle oleh
  /// SliverGrid saat scroll balik tidak dianimasikan ulang (biar tidak norak).
  final Set<int> _revealedIds = {};

  // Random featured Pokémon state — fetched live from API
  PokemonDetailModel? _featuredPokemon;
  bool _featuredLoading = true;

  Color _getPokemonAccentColor(int id) => PokemonTypeColors.getColorById(id);

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
    _searchFocusNode.addListener(() {
      setState(() {});
      if (_searchFocusNode.hasFocus) {
        context.read<HomeCubit>().ensureDirectoryLoaded();
      }
    });
    _fetchRandomFeatured();
  }

  /// Fetch a random Pokémon from PokeAPI (ID 1–1010) for the daily featured banner.
  /// Uses the date as a seed so the Pokémon stays the same all day and only changes tomorrow.
  Future<void> _fetchRandomFeatured() async {
    final now = DateTime.now();
    final daySeed = now.year * 10000 + now.month * 100 + now.day;
    final randomId = Random(daySeed).nextInt(1010) + 1;
    try {
      final response = await serviceLocator
          .get<ApiService>()
          .getPokemonDetail(randomId.toString());
      if (mounted) {
        setState(() {
          _featuredPokemon = response.data;
          _featuredLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _featuredLoading = false);
    }
  }

  void _onScroll() {
    if (_scrollController.hasClients &&
        _scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 450) {
      context.read<HomeCubit>().loadMorePokemon();
    }
  }

  void _toggleFavorite(int id) {
    final adding = !_favoriteIds.contains(id);
    setState(() {
      if (adding) {
        _favoriteIds.add(id);
      } else {
        _favoriteIds.remove(id);
      }
    });
    if (adding) {
      MonstraToast.show(
        context,
        title: 'Disimpan ke Favorit!',
        subtitle: 'Cek koleksimu di tab Favorit',
      );
    }
  }

  /// Animasi scroll kembali ke puncak halaman secara halus saat tab PokéDex ditekan ulang
  void scrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  // Filtered Pokémon list for PokéAPI Real Data (Global 1025 directory search on All filter)
  List<PokemonListItemModel> _filterPokemonList(
    List<PokemonListItemModel> list, {
    List<PokemonListItemModel>? allDirectory,
  }) {
    final query = _searchQuery.toLowerCase().trim();
    if (query.isEmpty) return list;

    // Jika filter All dan direktori lengkap tersedia, cari di seluruh 1025 Pokémon!
    final source = (_selectedType == 'All' &&
            allDirectory != null &&
            allDirectory.isNotEmpty)
        ? allDirectory
        : list;

    final filtered = source.where((pokemon) {
      final nameMatch = pokemon.name?.toLowerCase().contains(query) ?? false;
      final idMatch = pokemon.formattedId.contains(query) ||
          (pokemon.id?.toString().contains(query) ?? false);
      return nameMatch || idMatch;
    }).toList();

    return filtered.length > 60 ? filtered.sublist(0, 60) : filtered;
  }

  /// Label generasi (GEN I – IX) — logika ada di shared [PokemonCard].
  String _getGenerationTag(int? id) => PokemonCard.generationTagFor(id);

  // Surprise random Pokémon picker dari PokéAPI (Buka BottomSheet dengan Shimmer & Live Fetch)
  void _pickRandomPokemon() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) => _SurprisePokemonBottomSheet(
        cubit: context.read<HomeCubit>(),
        getAccentColor: _getPokemonAccentColor,
        getGenerationTag: _getGenerationTag,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: MonstraRefresh(
          onRefresh: () => context.read<HomeCubit>().getPokemonList(),
          child: NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification scrollInfo) {
              if (scrollInfo.metrics.pixels >=
                  scrollInfo.metrics.maxScrollExtent - 450) {
                context.read<HomeCubit>().loadMorePokemon();
              }
              return false;
            },
            child: CustomScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              slivers: [
                // 1. Explorer Header
                SliverToBoxAdapter(
                  child: FadeSlideIn(
                    offset: const Offset(0, -10),
                    child: _buildHeader(),
                  ),
                ),
                // 3. Featured Hero Card
                SliverToBoxAdapter(
                  child: FadeSlideIn(
                    delay: AppMotion.staggerAt(1),
                    offset: const Offset(0, 24),
                    scaleFrom: 0.97,
                    child: _buildFeaturedCard(),
                  ),
                ),
                // 4. Blok (Evolution & Compare)
                SliverToBoxAdapter(
                  child: _buildPokeTools(),
                ),

                // 4. Element Type Filter Bar
                SliverToBoxAdapter(
                  child: FadeSlideIn(
                    delay: AppMotion.staggerAt(5),
                    child: _buildTypeFilterBar(),
                  ),
                ),

                SliverToBoxAdapter(
                  child: FadeSlideIn(
                    delay: AppMotion.staggerAt(6),
                    child: _buildSearchBar(),
                  ),
                ),

                // 5. Section Title: Pokémon List (Synced with Cubit State)
                BlocBuilder<HomeCubit, HomeState>(
                  builder: (context, state) {
                    int count = 0;
                    if (state is HomeLoaded) {
                      count = _filterPokemonList(
                        state.pokemonList,
                        allDirectory: state.allDirectory,
                      ).length;
                    }
                    return SliverToBoxAdapter(
                      child: _buildSectionTitle(
                        title: _selectedType == 'All'
                            ? ''
                            : '$_selectedType Pokémon',
                        count: count,
                      ),
                    );
                  },
                ),

                // 6. 2-Column Pokémon Cards Grid / Shimmer / Error
                BlocBuilder<HomeCubit, HomeState>(
                  builder: (context, state) {
                    // Rebuild kartu saat tipe asli selesai dimuat
                    context.watch<PokemonTypeCubit>();
                    if (state is HomeLoading) {
                      return _buildShimmerGrid();
                    } else if (state is HomeError) {
                      return _buildErrorState(state.message);
                    } else if (state is HomeLoaded) {
                      final filtered = _filterPokemonList(
                        state.pokemonList,
                        allDirectory: state.allDirectory,
                      );
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
          // 1. Sisi Kiri: Spacer penyeimbang (44px) agar judul Monstra tetap presisi di tengah
          const SizedBox(width: 44, height: 44),

          // 2. Tengah: Logo Monstra interaktif (ketuk = kaget + tips,
          //    malam hari = ngantuk)
          const MonstraHeaderLogo(height: 34),

          // 3. Ikon Kanan: Surprise (Pokémon acak) — kapsul statis,
          //    sama dengan tombol acak di sheet Compare.
          SizedBox(
            width: 44,
            child: Center(
              child: AppPillButton(
                tooltip: 'Surprise Pokémon!',
                iconSize: 18,
                padding:
                    const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
                onTap: _pickRandomPokemon,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Search Bar interaktif dengan reusable PokemonSearchBar
  Widget _buildSearchBar() {
    return PokemonSearchBar(
      controller: _searchController,
      focusNode: _searchFocusNode,
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      onChanged: (value) {
        setState(() => _searchQuery = value);
        if (value.isNotEmpty) {
          context.read<HomeCubit>().ensureDirectoryLoaded();
        }
      },
      onClear: () {
        setState(() => _searchQuery = '');
      },
    );
  }

  /// Banner Pokémon of the Session — random, fetched live from API
  /// Transisi halus antara shimmer → kartu, dan kartu ↔ tersembunyi saat search aktif.
  Widget _buildFeaturedCard() {
    return AnimatedSize(
      duration: AppMotion.medium,
      curve: AppMotion.standard,
      alignment: Alignment.topCenter,
      child: AnimatedSwitcher(
        duration: AppMotion.medium,
        switchInCurve: AppMotion.enter,
        switchOutCurve: Curves.easeIn,
        transitionBuilder: (child, animation) => FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.97, end: 1).animate(animation),
            child: child,
          ),
        ),
        layoutBuilder: (current, previous) => Stack(
          alignment: Alignment.topCenter,
          children: [...previous, if (current != null) current],
        ),
        child: _buildFeaturedContent(),
      ),
    );
  }

  Widget _buildFeaturedContent() {
    if (_searchController.text.trim().isNotEmpty) {
      return const SizedBox.shrink(key: ValueKey('featured_hidden'));
    }

    // Loading shimmer state
    if (_featuredLoading) {
      return Padding(
        key: const ValueKey('featured_loading'),
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
            height: 190,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(28),
            ),
          ),
        ),
      );
    }

    // No data / error state — silently hide
    if (_featuredPokemon == null) {
      return const SizedBox.shrink(key: ValueKey('featured_empty'));
    }

    final pokemon = _featuredPokemon!;
    final types = pokemon.typeNames;
    final primaryType = types.isNotEmpty ? types.first : 'Normal';
    final secondaryType = types.length > 1 ? types[1] : primaryType;
    final primaryColor = PokemonTypeColors.getColor(primaryType);
    final secondaryColor = PokemonTypeColors.getColor(secondaryType);
    final imageUrl = pokemon.officialImageUrl;

    return Padding(
      key: ValueKey('featured_${pokemon.id}'),
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Pressable(
        onTap: () => _navigateToDetail(pokemon.toListItem),
        pressedScale: 0.975,
        semanticLabel: 'Featured Pokémon ${pokemon.capitalizedName}',
        child: Container(
          height: 190,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            // Indigo brand gradient, warna tipe hanya sebagai tint di sudut
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                jacarta700,
                nightColor,
                Color.alphaBlend(
                  secondaryColor.withValues(alpha: 0.35),
                  nightColor,
                ),
              ],
              stops: const [0.0, 0.6, 1.0],
            ),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withValues(alpha: 0.38),
                blurRadius: 24,
                offset: const Offset(0, 10),
                spreadRadius: -2,
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              // 1. Siluet maskot Monstra transparan — pojok kanan bawah
              Positioned(
                right: -36,
                bottom: -52,
                child: Opacity(
                  opacity: 0.12,
                  child: Transform.rotate(
                    angle: -0.12,
                    child: const MonstraMascot(
                      size: 230,
                      showBackground: false,
                    ),
                  ),
                ),
              ),

              // 3. Soft radial spotlight
              Positioned(
                left: -30,
                top: -10,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.white.withValues(alpha: 0.12),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              // 4. Content — Left Column
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 8, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Type label pill badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.22),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'FEATURED POKÉMON',
                        style: xxsBold.copyWith(
                          color: Colors.white.withValues(alpha: 0.95),
                          letterSpacing: 1.2,
                          fontSize: 9,
                        ),
                      ),
                    ),

                    // Pokédex ID + Name
                    FadeSlideIn(
                      delay: AppMotion.staggerAt(2),
                      offset: const Offset(-14, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            pokemon.formattedId,
                            style: xxsBold.copyWith(
                              color: Colors.white.withValues(alpha: 0.70),
                              letterSpacing: 1.5,
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(height: 1),
                          Text(
                            pokemon.capitalizedName,
                            style: lBold.copyWith(
                              fontSize: 28,
                              color: Colors.white,
                              letterSpacing: -0.8,
                              height: 1.05,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Real type chips from API
                    Row(
                      children: types.asMap().entries.map((entry) {
                        final type = entry.value;
                        return FadeSlideIn(
                          delay: AppMotion.staggerAt(3 + entry.key),
                          offset: const Offset(0, 8),
                          child: _buildTypeBadge(
                            type,
                            isLightBackground: false,
                            iconSize: 12,
                            fontSize: 11,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 3.5,
                            ),
                            margin: const EdgeInsets.only(right: 6),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),

              // 5. Official artwork — masuk dari kanan lalu melayang pelan
              Positioned(
                right: 0,
                bottom: -8,
                top: 4,
                child: FadeSlideIn(
                  delay: AppMotion.staggerAt(2),
                  duration: const Duration(milliseconds: 720),
                  offset: const Offset(36, 6),
                  scaleFrom: 0.88,
                  child: Floating(
                    child: CachedNetworkImage(
                      imageUrl: imageUrl,
                      width: 178,
                      fit: BoxFit.contain,
                      placeholder: (context, url) =>
                          const Center(child: MonstraLoader(size: 44)),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.broken_image, color: Colors.white54),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Poké Tools: Row(Evolution, Compare) + Banner Horizontal(Generation Explorer)
  Widget _buildPokeTools() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FadeSlideIn(
          delay: AppMotion.staggerAt(2),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
            child: Text(
              'Poké Tools',
              style: mdBold.copyWith(color: bgDark),
            ),
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
                    child: FadeSlideIn(
                      delay: AppMotion.staggerAt(3),
                      offset: const Offset(-16, 12),
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
                          AppMessenger.showComingSoon(
                            context,
                            featureName: 'Evolution Explorer',
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FadeSlideIn(
                      delay: AppMotion.staggerAt(3),
                      offset: const Offset(16, 12),
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
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CompareScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // 2.Kotak Horizontal Lebar Generation & Region Atlas
              FadeSlideIn(
                delay: AppMotion.staggerAt(4),
                child: _buildGenerationHorizontalBanner(),
              ),
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
    return Pressable(
      onTap: onTap,
      semanticLabel: '$title — $subtitle',
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
    );
  }

  /// Banner horizontal lebar untuk Generation & Regions Atlas di baris bawah
  Widget _buildGenerationHorizontalBanner() {
    return Pressable(
      pressedScale: 0.975,
      semanticLabel: 'Generation Explorer',
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const GenerationScreen(),
          ),
        );
      },
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
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
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
    );
  }

  /// Baris filter elemen tipe (Fire, Water, Grass, dll.)
  Widget _buildTypeFilterBar() {
    return PokemonTypeFilterBar(
      selectedType: _selectedType,
      showTitle: true,
      title: 'Filter by Element',
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemSpacing: 8,
      animateIn: true,
      onSelected: (typeName) {
        if (_selectedType == typeName) return;
        setState(() {
          _selectedType = typeName;
          _revealedIds.clear(); // hasil filter baru masuk dengan stagger lagi
        });
        context.read<HomeCubit>().filterByType(typeName);
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      },
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
              AnimatedSwitcher(
                duration: AppMotion.medium,
                switchInCurve: AppMotion.enter,
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.4),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                ),
                child: Text(
                  title,
                  key: ValueKey<String>(title),
                  style: lgBold.copyWith(color: bgDark),
                ),
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

          // Sisi Kanan: toggle Grid / List (shared)
          PokemonViewToggle(
            isGrid: _isGridMode,
            onChanged: (grid) => _setViewMode(grid: grid),
          ),
        ],
      ),
    );
  }

  void _setViewMode({required bool grid}) {
    if (_isGridMode == grid) return;
    setState(() {
      _isGridMode = grid;
      _revealedIds.clear(); // layout baru → kartu masuk ulang dengan stagger
    });
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
      child: FadeSlideIn(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
          child: Column(
            children: [
              // Maskot pusing: gagal memuat / offline
              const MonstraDizzy(size: 76),
              const SizedBox(height: 14),
              Text(
                'Failed to Load Pokémon',
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
      ),
    );
  }

  /// Membungkus kartu dengan entrance stagger — hanya saat pertama kali tampil.
  Widget _revealCard({
    required PokemonListItemModel pokemon,
    required int index,
    required Widget child,
  }) {
    final id = pokemon.id ?? -index - 1;
    final isFirstReveal = _revealedIds.add(id);
    return FadeSlideIn(
      key: ValueKey('reveal_${_isGridMode}_$id'),
      animate: isFirstReveal,
      // Batch awal di-stagger berurutan; item hasil infinite-scroll cukup
      // di-stagger per kolom agar terasa responsif.
      delay: index < 8
          ? AppMotion.staggerAt(index)
          : AppMotion.stagger * (index % (_isGridMode ? 2 : 1)),
      offset: Offset(0, _isGridMode ? 28 : 20),
      scaleFrom: _isGridMode ? 0.94 : 0.98,
      child: child,
    );
  }

  /// Grid 2 kolom atau List 1 kolom kartu Pokémon dari PokéAPI
  Widget _buildPokemonGrid({
    required List<PokemonListItemModel> pokemons,
    required bool isLoadingMore,
  }) {
    if (pokemons.isEmpty) {
      return SliverToBoxAdapter(
        child: FadeSlideIn(
          scaleFrom: 0.96,
          child: PokemonEmptyState(
            title: 'No Pokémon Found',
            subtitle: 'Try searching with a different name or ID.',
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 40),
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
                childAspectRatio: 0.74,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final pokemon = pokemons[index];
                  return _revealCard(
                    pokemon: pokemon,
                    index: index,
                    child: _buildPokemonCard(pokemon),
                  );
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
                return _revealCard(
                  pokemon: pokemon,
                  index: index,
                  child: _buildPokemonListCard(pokemon),
                );
              },
            ),
          ),
        if (isLoadingMore)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const MonstraLoader(size: 28),
                    const SizedBox(width: 12),
                    Text(
                      'Catching more Pokémon...',
                      style: smMedium.copyWith(
                        color: black500,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  /// Kartu 1 kolom (panjang) — shared [PokemonCard]
  Widget _buildPokemonListCard(PokemonListItemModel pokemon) =>
      _buildSharedCard(pokemon, PokemonCardStyle.list);

  /// Kartu grid (kotak) — shared [PokemonCard]
  Widget _buildPokemonCard(PokemonListItemModel pokemon) =>
      _buildSharedCard(pokemon, PokemonCardStyle.grid);

  Widget _buildSharedCard(
      PokemonListItemModel pokemon, PokemonCardStyle style) {
    return PokemonCard(
      pokemon: pokemon,
      style: style,
      isFavorite: _favoriteIds.contains(pokemon.id ?? 0),
      onFavoriteToggle:
          pokemon.id == null ? null : () => _toggleFavorite(pokemon.id!),
      onTap: () => _navigateToDetail(pokemon),
    );
  }

  /// Navigasi langsung ke DetailScreen saat kartu Pokémon diklik
  void _navigateToDetail(PokemonListItemModel pokemon) {
    final typeColor = _getPokemonAccentColor(pokemon.id ?? 1);
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

/// ============================================================================
/// SURPRISE POKÉMON BOTTOM SHEET (Dadu Acak dengan Shimmer Skeleton & Live Fetch)
/// ============================================================================
class _SurprisePokemonBottomSheet extends StatefulWidget {
  final HomeCubit cubit;
  final Color Function(int) getAccentColor;
  final String Function(int?) getGenerationTag;

  const _SurprisePokemonBottomSheet({
    required this.cubit,
    required this.getAccentColor,
    required this.getGenerationTag,
  });

  @override
  State<_SurprisePokemonBottomSheet> createState() =>
      _SurprisePokemonBottomSheetState();
}

class _SurprisePokemonBottomSheetState
    extends State<_SurprisePokemonBottomSheet> {
  bool _isLoading = true;
  PokemonListItemModel? _pokemon;

  @override
  void initState() {
    super.initState();
    _fetchSurprisePokemon();
  }

  Future<void> _fetchSurprisePokemon() async {
    setState(() => _isLoading = true);

    // Ambil direktori 1025 jika belum di-cache ke RAM (Lazy load on-demand)
    var dir = widget.cubit.allDirectory;
    if (dir.isEmpty) {
      dir = await widget.cubit.ensureDirectoryLoaded();
    }

    if (!mounted) return;

    final pool = dir.isNotEmpty
        ? dir
        : (widget.cubit.state is HomeLoaded
            ? (widget.cubit.state as HomeLoaded).pokemonList
            : <PokemonListItemModel>[]);

    if (pool.isNotEmpty) {
      final random = Random();
      final picked = pool[random.nextInt(pool.length)];

      // 1. Download & cache gambar ke memori SEBELUM mematikan Shimmer!
      if (picked.imageUrl != null && picked.imageUrl!.isNotEmpty) {
        try {
          await precacheImage(
            CachedNetworkImageProvider(picked.imageUrl!),
            context,
          );
        } catch (_) {
          // Fallback aman jika koneksi bermasalah
        }
      }

      // 2. Beri jeda minimum agar efek shimmer terasa smooth & memuaskan
      await Future.delayed(const Duration(milliseconds: 300));

      // 3. Matikan Shimmer HANYA saat data teks & gambar sudah 100% siap!
      if (mounted) {
        setState(() {
          _pokemon = picked;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: bgLight,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
      child: AnimatedSize(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top Handle Bar
            Center(
              child: Container(
                width: 44,
                height: 4.5,
                decoration: BoxDecoration(
                  color: black300,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 18),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              switchInCurve: Curves.easeOutBack,
              switchOutCurve: Curves.easeIn,
              child: _isLoading
                  ? _buildLoadingState(context)
                  : (_pokemon != null
                      ? _buildRevealedState(context, _pokemon!)
                      : const SizedBox.shrink()),
            ),
          ],
        ),
      ),
    );
  }

  /// Tampilan Shimmer Skeleton Loading di dalam BottomSheet (1-to-1 dengan kartu Pokémon)
  Widget _buildLoadingState(BuildContext context) {
    return Shimmer.fromColors(
      key: const ValueKey('loading_skeleton_state'),
      baseColor: black100,
      highlightColor: bgLight,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Placeholder ID & Gen Tag + Close Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 15,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 52,
                        height: 16,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 150,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ],
              ),
              Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Placeholder Pokémon Image Container
          Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
            ),
          ),
          const SizedBox(height: 16),

          // Placeholder Description text (2 baris)
          Center(
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  width: 240,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),

          // Placeholder Action Buttons Row
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 3,
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Tampilan Hasil Pokémon setelah Shimmer Loading selesai
  Widget _buildRevealedState(
      BuildContext context, PokemonListItemModel pokemon) {
    final typeColor = widget.getAccentColor(pokemon.id ?? 1);

    return Column(
      key: ValueKey('revealed_${pokemon.id}'),
      mainAxisSize: MainAxisSize.min,
      children: [
        // Top Header (Tanpa Icon Love, hanya Close Button)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      pokemon.formattedId,
                      style: xsBold.copyWith(
                        fontSize: 13,
                        color: black500,
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
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
              icon: const Icon(Icons.close_rounded, size: 22, color: black400),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Pokémon Image Box
        Container(
          height: 180,
          width: double.infinity,
          decoration: BoxDecoration(
            color: typeColor.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Center(
            child: CachedNetworkImage(
              imageUrl: pokemon.imageUrl ?? '',
              height: 160,
              fit: BoxFit.contain,
              placeholder: (context, url) =>
                  const Center(child: MonstraLoader(size: 52)),
              errorWidget: (context, url, error) => const Icon(
                Icons.catching_pokemon,
                size: 52,
                color: black400,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Official Pokémon entry from PokéAPI database. Tap view details to inspect base stats, abilities, move pool, and evolution.',
          style: smRegular.copyWith(
            fontSize: 13,
            color: black600,
            height: 1.4,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 22),

        // Action Buttons Row: [ 🎲 Roll Again ] + [ View Full Details ]
        Row(
          children: [
            Expanded(
              flex: 2,
              child: SizedBox(
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: _fetchSurprisePokemon,
                  icon: const Icon(Icons.casino_outlined, size: 18),
                  label: const Text('Roll Again'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: bgDark,
                    side: const BorderSide(color: borderNeutral, width: 1.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 3,
              child: SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailScreen(
                          pokemonIdOrName:
                              pokemon.id?.toString() ?? pokemon.name ?? '6',
                          initialPokemonId: pokemon.id ?? 6,
                          initialName: pokemon.capitalizedName,
                          initialImageUrl: pokemon.imageUrl,
                          initialColor: typeColor,
                          initialTypes:
                              PokemonTypeColors.getTypesById(pokemon.id),
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
                    'View Full Details',
                    style: smBold.copyWith(color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
