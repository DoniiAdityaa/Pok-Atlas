import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../ui/color.dart';
import '../../ui/typography.dart';
import 'cubit/detail_cubit.dart';
import 'pokemon_detail_ui_model.dart';

class DetailScreen extends StatefulWidget {
  final String pokemonIdOrName;
  final int initialPokemonId;
  final String? initialName;
  final List<String>? initialTypes;
  final String? initialImageUrl;
  final Color? initialColor;

  const DetailScreen({
    super.key,
    this.pokemonIdOrName = '6',
    this.initialPokemonId = 6, // Default Charizard
    this.initialName,
    this.initialTypes,
    this.initialImageUrl,
    this.initialColor,
  });

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen>
    with TickerProviderStateMixin {
  late final TabController _tabController;
  late final AnimationController _floatingController;
  late final Animation<double> _floatingAnimation;
  late final Animation<double> _pulseAnimation;
  late final AudioPlayer _audioPlayer;

  late PokemonDetailUIModel _currentPokemon;
  PokemonDisplayMode _displayMode = PokemonDisplayMode.artwork;
  bool _isShiny = false;
  bool _isFavorite = true;
  bool _isPlayingAudio = false;
  String _selectedVersion = 'Version 1';

  final List<String> _tabs = ['About', 'Base Stats', 'Evolution', 'Moves'];

  @override
  void initState() {
    super.initState();
    final parsedId =
        int.tryParse(widget.pokemonIdOrName) ?? widget.initialPokemonId;
    _currentPokemon = PokemonDetailUIModel.placeholder(
      id: parsedId > 0 ? parsedId : widget.initialPokemonId,
      name: widget.initialName,
      types: widget.initialTypes,
      customColor: widget.initialColor,
    );

    _tabController = TabController(length: _tabs.length, vsync: this);

    // 🪶 Floating & Breathing Animation
    _floatingController = AnimationController(
      duration: const Duration(milliseconds: 2400),
      vsync: this,
    )..repeat(reverse: true);

    _floatingAnimation = Tween<double>(begin: -7.0, end: 7.0).animate(
      CurvedAnimation(
        parent: _floatingController,
        curve: Curves.easeInOutSine,
      ),
    );

    _pulseAnimation = Tween<double>(begin: 0.94, end: 1.06).animate(
      CurvedAnimation(
        parent: _floatingController,
        curve: Curves.easeInOutSine,
      ),
    );

    // 🔊 Audio player untuk auman suara Pokémon (PokéAPI Cry)
    _audioPlayer = AudioPlayer();
    _audioPlayer.onPlayerComplete.listen((_) {
      if (mounted) {
        setState(() => _isPlayingAudio = false);
      }
    });

    // 🚀 Ambil data live dari PokéAPI via DetailCubit
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DetailCubit>().getPokemonDetail(widget.pokemonIdOrName);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _floatingController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  /// Memutar suara auman resmi Pokémon
  Future<void> _playPokemonCry() async {
    try {
      setState(() => _isPlayingAudio = true);
      await _audioPlayer.stop();
      await _audioPlayer.play(UrlSource(_currentPokemon.cryUrl));
    } catch (e) {
      try {
        await _audioPlayer.play(UrlSource(_currentPokemon.cryOggUrl));
      } catch (fallbackError) {
        if (mounted) {
          setState(() => _isPlayingAudio = false);
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Could not play cry sound: $fallbackError'),
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  /// URL Gambar sesuai pilihan Artwork / Battle GIF dan Normal / Shiny
  String _getActiveImageUrl() {
    if (_displayMode == PokemonDisplayMode.artwork) {
      return _isShiny
          ? _currentPokemon.shinyArtworkUrl
          : _currentPokemon.artworkUrl;
    } else {
      return _isShiny
          ? _currentPokemon.shinyBattleGifUrl
          : _currentPokemon.battleGifUrl;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DetailCubit, DetailState>(
      listener: (context, state) {
        if (state is DetailLoaded) {
          setState(() {
            _currentPokemon = PokemonDetailUIModel.fromApiModel(
              state.pokemon,
              evolutions: (state.evolutions != null && state.evolutions!.isNotEmpty)
                  ? state.evolutions
                  : _currentPokemon.evolutions,
              speciesDescription: state.speciesDescription,
              speciesGenera: state.speciesGenera,
              maleRate: state.maleRate,
              femaleRate: state.femaleRate,
              eggGroups: state.eggGroups,
            );
          });
        } else if (state is DetailError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is DetailLoading;
        final primaryColor = _currentPokemon.primaryColor;

        return Scaffold(
          backgroundColor: primaryColor,
          body: Stack(
            children: [
              // 1. Dynamic Ambient Gradient
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 400,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        primaryColor,
                        primaryColor.withValues(alpha: 0.85),
                      ],
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Pulsing Glow Aura behind Pokémon
                      Positioned(
                        top: 100,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: AnimatedBuilder(
                            animation: _pulseAnimation,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: _pulseAnimation.value,
                                child: Container(
                                  width: 210,
                                  height: 210,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white.withValues(alpha: 0.16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.white
                                            .withValues(alpha: 0.22),
                                        blurRadius: 40,
                                        spreadRadius: 8,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),

                      // Ambient Faded Pokéball Motif
                      Positioned(
                        right: -30,
                        top: 30,
                        child: Opacity(
                          opacity: 0.12,
                          child: Container(
                            width: 260,
                            height: 260,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 2. Main Content Layout
              SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    // Top Custom App Bar
                    _buildTopAppBar(),

                    if (isLoading)
                      const SizedBox(
                        height: 2.5,
                        child: LinearProgressIndicator(
                          backgroundColor: Colors.transparent,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white70),
                        ),
                      ),

                    // Header Identity (Name, ID, Species, Type Badges)
                    _buildHeaderIdentity(),

                    const SizedBox(height: 8),

                    // Sliding Sheet Container with Tabs & Floating Pokémon
                    Expanded(
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          // White Rounded Sheet
                          Container(
                            margin: const EdgeInsets.only(top: 140),
                            width: double.infinity,
                            decoration: const BoxDecoration(
                              color: bgLight,
                              borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(32)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 20,
                                  offset: Offset(0, -6),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                const SizedBox(height: 52),

                                // Segmented Tab Bar
                                _buildCustomTabBar(primaryColor),

                                const SizedBox(height: 12),

                                // Tab Views Content
                                Expanded(
                                  child: TabBarView(
                                    controller: _tabController,
                                    physics: const BouncingScrollPhysics(),
                                    children: [
                                      _buildAboutTab(),
                                      _buildBaseStatsTab(),
                                      _buildEvolutionTab(),
                                      _buildMovesTab(),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // 🪶 Floating & Breathing Pokémon Showcase
                          Positioned(
                            top: -30,
                            left: 0,
                            right: 0,
                            child: Center(
                              child: AnimatedBuilder(
                                animation: _floatingAnimation,
                                builder: (context, child) {
                                  return Transform.translate(
                                    offset: Offset(0, _floatingAnimation.value),
                                    child: child,
                                  );
                                },
                                child: Hero(
                                  tag: 'pokemon_${widget.initialPokemonId}',
                                  child: AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 300),
                                    transitionBuilder: (child, animation) =>
                                        ScaleTransition(
                                      scale: animation,
                                      child: child,
                                    ),
                                    child: CachedNetworkImage(
                                      key: ValueKey<String>(
                                          '${_currentPokemon.id}_${_displayMode}_$_isShiny'),
                                      imageUrl: _getActiveImageUrl(),
                                      height: 215,
                                      width: 215,
                                      fit: BoxFit.contain,
                                      placeholder: (context, url) => Center(
                                        child: CircularProgressIndicator(
                                          color: primaryColor,
                                          strokeWidth: 2,
                                        ),
                                      ),
                                      errorWidget: (context, url, error) =>
                                          const Icon(Icons.broken_image_rounded,
                                              size: 80, color: Colors.white70),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // 🎛️ Mode Switcher (3D Artwork vs Battle GIF + Shiny Toggle)
                          Positioned(
                            top: 150,
                            left: 20,
                            right: 20,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Switcher: 3D Artwork vs Battle Live GIF
                                Container(
                                  padding: const EdgeInsets.all(3),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: borderNeutral),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black
                                            .withValues(alpha: 0.04),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      _buildModeButton(
                                        icon: Icons.image_outlined,
                                        isSelected: _displayMode ==
                                            PokemonDisplayMode.artwork,
                                        primaryColor: primaryColor,
                                        tooltip: '3D Artwork',
                                        onTap: () {
                                          setState(() => _displayMode =
                                              PokemonDisplayMode.artwork);
                                        },
                                      ),
                                      _buildModeButton(
                                        icon: Icons.play_circle_filled_rounded,
                                        isSelected: _displayMode ==
                                            PokemonDisplayMode.battleGif,
                                        primaryColor: primaryColor,
                                        tooltip: 'Battle GIF (Gerak)',
                                        onTap: () {
                                          setState(() => _displayMode =
                                              PokemonDisplayMode.battleGif);
                                        },
                                      ),
                                    ],
                                  ),
                                ),

                                // Shiny Form Toggle Button
                                InkWell(
                                  onTap: () =>
                                      setState(() => _isShiny = !_isShiny),
                                  borderRadius: BorderRadius.circular(20),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 250),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: _isShiny
                                          ? orange700.withValues(alpha: 0.15)
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: _isShiny
                                            ? orange700
                                            : borderNeutral,
                                        width: 1.2,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black
                                              .withValues(alpha: 0.04),
                                          blurRadius: 6,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.auto_awesome,
                                          size: 14,
                                          color:
                                              _isShiny ? orange700 : black500,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          _isShiny ? 'Shiny Form' : 'Normal',
                                          style: xxsBold.copyWith(
                                            color:
                                                _isShiny ? orange700 : black600,
                                          ),
                                        ),
                                      ],
                                    ),
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
            ],
          ),
        );
      },
    );
  }

  // ==========================================================================
  // MODE BUTTON HELPER
  // ==========================================================================
  Widget _buildModeButton({
    required IconData icon,
    required bool isSelected,
    required Color primaryColor,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? primaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            icon,
            size: 18,
            color: isSelected ? Colors.white : black500,
          ),
        ),
      ),
    );
  }

  // ==========================================================================
  // TOP APP BAR
  // ==========================================================================
  Widget _buildTopAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildFrostedButton(
            icon: Icons.arrow_back_ios_new_rounded,
            onTap: () => Navigator.pop(context),
          ),
          InkWell(
            onTap: _playPokemonCry,
            borderRadius: BorderRadius.circular(20),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: _isPlayingAudio
                    ? Colors.white.withValues(alpha: 0.38)
                    : Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
                border: _isPlayingAudio
                    ? Border.all(color: Colors.white, width: 1.2)
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _isPlayingAudio
                        ? Icons.graphic_eq_rounded
                        : Icons.volume_up_rounded,
                    size: 16,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _isPlayingAudio ? 'Playing Cry...' : 'Pokédex Entry',
                    style: xsBold.copyWith(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
          _buildFrostedButton(
            icon: _isFavorite
                ? Icons.favorite_rounded
                : Icons.favorite_border_rounded,
            iconColor: _isFavorite ? const Color(0xFFFF4757) : Colors.white,
            onTap: () {
              setState(() => _isFavorite = !_isFavorite);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    _isFavorite
                        ? '${_currentPokemon.name} added to Favorites!'
                        : '${_currentPokemon.name} removed from Favorites!',
                  ),
                  duration: const Duration(seconds: 1),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFrostedButton({
    required IconData icon,
    required VoidCallback onTap,
    Color iconColor = Colors.white,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.22),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.35),
            width: 1.2,
          ),
        ),
        child: Icon(icon, size: 19, color: iconColor),
      ),
    );
  }

  // ==========================================================================
  // HEADER IDENTITY
  // ==========================================================================
  Widget _buildHeaderIdentity() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _currentPokemon.name,
                    style: xxlBold.copyWith(
                      fontSize: 32,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Text(
                    _currentPokemon.species,
                    style: smMedium.copyWith(
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _currentPokemon.formattedId,
                  style: lBold.copyWith(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Barisan Tipe di Header (Menampilkan SEMUA tipe, contoh Fire & Flying)
          Row(
            children: _currentPokemon.types.map((type) {
              return _buildHeaderTypeChip(type);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderTypeChip(String type) {
    final assetPath = 'assets/images/element/${type.toLowerCase()}.svg';

    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.35),
          width: 1.0,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            assetPath,
            width: 14,
            height: 14,
            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
          ),
          const SizedBox(width: 5),
          Text(
            type,
            style: xsBold.copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // CUSTOM TAB BAR
  // ==========================================================================
  Widget _buildCustomTabBar(Color primaryColor) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: borderNeutral.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(24),
      ),
      child: TabBar(
        controller: _tabController,
        dividerColor: Colors.transparent,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        labelColor: primaryColor,
        unselectedLabelColor: black500,
        labelStyle: xsBold.copyWith(fontSize: 12.5),
        unselectedLabelStyle: xsMedium.copyWith(fontSize: 12.5),
        tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
      ),
    );
  }

  // ==========================================================================
  // TAB 1: ABOUT (SESUAI GAMBAR 1 & 2 DARI USER: TIPE, KELEMAHAN, VERSI)
  // ==========================================================================
  Widget _buildAboutTab() {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(22, 10, 22, 30),
      children: [
        // 1. SECTION TIPE & KELEMAHAN (PERSIS GAMBAR 1)
        _buildTypeAndWeaknessSection(),

        const SizedBox(height: 22),

        // 2. SECTION VERSI POKÉDEX ENTRY (PERSIS GAMBAR 2)
        _buildVersionDescriptionSection(),

        const SizedBox(height: 22),

        // 3. PHYSICAL METRICS (TINGGI & BERAT DENGAN VISUAL GAUGE)
        _buildPhysicalMetricsSection(),

        const SizedBox(height: 22),

        // 4. KEMAMPUAN (ABILITIES) & BREEDING
        _buildAbilitiesAndBreedingSection(),
      ],
    );
  }

  /// Section Tipe & Kelemahan persis gambar 1 dari user
  Widget _buildTypeAndWeaknessSection() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderNeutral),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Tipe

          // Header: Kelemahan
          Text(
            'Weaknesses',
            style: lBold.copyWith(
              color: const Color(0xFF6B5B6D),
              fontSize: 22,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 12),

          // Row of Weaknesses Badges (e.g. Water, Electric, Rock)
          Wrap(
            spacing: 12,
            runSpacing: 10,
            children: _currentPokemon.weaknesses.map((type) {
              return _buildSquareElementBadge(
                type: type,
                size: 44,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  /// Badge Kotak Elemen dengan sudut melengkung + ikon SVG putih (Persis Gambar 1)
  Widget _buildSquareElementBadge({
    required String type,
    String? label,
    double size = 44,
  }) {
    final color = PokemonTypeColors.getColor(type);
    final assetPath = 'assets/images/element/${type.toLowerCase()}.svg';

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.35),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          padding: EdgeInsets.all(size * 0.22),
          child: SvgPicture.asset(
            assetPath,
            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
          ),
        ),
        if (label != null) ...[
          const SizedBox(width: 10),
          Text(
            label,
            style: mdBold.copyWith(
              color: const Color(0xFF2D2A2E),
              fontSize: 18,
            ),
          ),
        ],
      ],
    );
  }

  /// Section "Version" Pokédex Entry (Image 2 style)
  Widget _buildVersionDescriptionSection() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderNeutral),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.catching_pokemon,
                      size: 20, color: Color(0xFF9E9E9E)),
                  const SizedBox(width: 8),
                  Text(
                    'Version',
                    style: mdBold.copyWith(
                      color: const Color(0xFF333333),
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              // Pill Switcher Version 1 vs Version 2
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: borderNeutral.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children:
                      _currentPokemon.versionDescriptions.keys.map((version) {
                    final isSelected = _selectedVersion == version;
                    return InkWell(
                      onTap: () => setState(() => _selectedVersion = version),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.06),
                                    blurRadius: 4,
                                  ),
                                ]
                              : null,
                        ),
                        child: Text(
                          version,
                          style: (isSelected ? xxsBold : xxsMedium).copyWith(
                            color: isSelected ? bgDark : black500,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: Text(
              key: ValueKey<String>(_selectedVersion),
              _currentPokemon.versionDescriptions[_selectedVersion] ??
                  _currentPokemon.description,
              style: smRegular.copyWith(
                color: const Color(0xFF424242),
                height: 1.5,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Section Physical Metrics
  Widget _buildPhysicalMetricsSection() {
    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            icon: Icons.straighten_rounded,
            title: '${_currentPokemon.height} m',
            subtitle: 'Height',
            color: PokemonTypeColors.grass,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMetricCard(
            icon: Icons.scale_rounded,
            title: '${_currentPokemon.weight} kg',
            subtitle: 'Weight',
            color: PokemonTypeColors.fire,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMetricCard(
            icon: Icons.bolt_rounded,
            title: '${_currentPokemon.baseExp} XP',
            subtitle: 'Base EXP',
            color: PokemonTypeColors.electric,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderNeutral),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(title, style: smBold.copyWith(color: bgDark)),
          const SizedBox(height: 2),
          Text(subtitle, style: xxsMedium.copyWith(color: black500)),
        ],
      ),
    );
  }

  /// Section Abilities & Traits
  Widget _buildAbilitiesAndBreedingSection() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderNeutral),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Abilities', style: mdBold.copyWith(color: bgDark)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ..._currentPokemon.abilities.map(
                (ability) => _buildAbilityBadge(ability, isHidden: false),
              ),
              _buildAbilityBadge(_currentPokemon.hiddenAbility, isHidden: true),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: borderNeutral, height: 1),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Gender Ratio', style: xsMedium.copyWith(color: black500)),
              Row(
                children: [
                  Text('♂ ${_currentPokemon.maleRate}%',
                      style: xsBold.copyWith(color: Colors.blue)),
                  const SizedBox(width: 8),
                  Text('♀ ${_currentPokemon.femaleRate}%',
                      style: xsBold.copyWith(color: Colors.pinkAccent)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Row(
              children: [
                Expanded(
                  flex: _currentPokemon.maleRate.toInt(),
                  child: Container(height: 7, color: Colors.blue),
                ),
                Expanded(
                  flex: _currentPokemon.femaleRate.toInt(),
                  child: Container(height: 7, color: Colors.pinkAccent),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAbilityBadge(String name, {required bool isHidden}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isHidden ? borderNeutral.withValues(alpha: 0.4) : bgLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isHidden ? black300 : borderNeutral,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            name,
            style: xsBold.copyWith(color: bgDark),
          ),
          if (isHidden) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: black300,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'Hidden',
                style: xxsBold.copyWith(color: black700),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ==========================================================================
  // TAB 2: BASE STATS (STATISTIK BALOK BERSEGMEN 15 BLOK PERSIS GAMBAR 2)
  // ==========================================================================
  Widget _buildBaseStatsTab() {
    final activeColor = _currentPokemon.primaryColor;

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
      children: [
        // Header Card Statistik (Persis Gambar 2)
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: borderNeutral),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Pokéball icon + Statistik Title + Total
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.catching_pokemon,
                          size: 22, color: Color(0xFF9E9E9E)),
                      const SizedBox(width: 8),
                      Text(
                        'Statistik',
                        style: lBold.copyWith(
                          color: const Color(0xFF333333),
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: activeColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Total: ${_currentPokemon.totalStats}',
                      style: xsBold.copyWith(color: activeColor),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // 📊 TWO-COLUMN SEGMENTED STAT BARS (PLAYFUL RETRO STYLE)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left Column: HP, Attack, Defense
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSegmentedStatBar(
                          label: 'HP',
                          value: _currentPokemon.stats['HP'] ?? 0,
                          activeColor: activeColor,
                        ),
                        const SizedBox(height: 16),
                        _buildSegmentedStatBar(
                          label: 'Attack',
                          value: _currentPokemon.stats['Attack'] ??
                              _currentPokemon.stats['Serangan'] ??
                              0,
                          activeColor: activeColor,
                        ),
                        const SizedBox(height: 16),
                        _buildSegmentedStatBar(
                          label: 'Defense',
                          value: _currentPokemon.stats['Defense'] ??
                              _currentPokemon.stats['Pertahanan'] ??
                              0,
                          activeColor: activeColor,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Right Column: Sp. Atk, Sp. Def, Speed
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSegmentedStatBar(
                          label: 'Sp. Atk',
                          value: _currentPokemon.stats['Sp. Atk'] ??
                              _currentPokemon.stats['Serangan Khusus'] ??
                              0,
                          activeColor: activeColor,
                        ),
                        const SizedBox(height: 16),
                        _buildSegmentedStatBar(
                          label: 'Sp. Def',
                          value: _currentPokemon.stats['Sp. Def'] ??
                              _currentPokemon.stats['Pertahanan Khusus'] ??
                              0,
                          activeColor: activeColor,
                        ),
                        const SizedBox(height: 16),
                        _buildSegmentedStatBar(
                          label: 'Speed',
                          value: _currentPokemon.stats['Speed'] ??
                              _currentPokemon.stats['Kecepatan'] ??
                              0,
                          activeColor: activeColor,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Game Hint Note
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: activeColor.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: activeColor.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline_rounded, size: 18, color: activeColor),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Each block segment represents Pokémon stat units (max. 15 blocks).',
                  style: xxsRegular.copyWith(color: black700),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Komponen Bar Balok Bersegmen (15 Kotak Balok) Persis Gambar 2
  Widget _buildSegmentedStatBar({
    required String label,
    required int value,
    int maxSegments = 15,
    int maxValue = 150,
    required Color activeColor,
  }) {
    final filledSegments = value <= 0
        ? 0
        : ((value / maxValue) * maxSegments).clamp(1, maxSegments).round();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Nama Stat dengan Garis Bawah Oranye Memanjang (Persis Gambar 2)
        SizedBox(
          width: 58,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: xxsBold.copyWith(
                  color: const Color(0xFF2B2B2B),
                  fontSize: 10.5,
                  height: 1.15,
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 2),
              Container(
                height: 1.5,
                width: double.infinity,
                color: activeColor.withValues(alpha: 0.75),
              ),
            ],
          ),
        ),
        const SizedBox(width: 4),

        // Barisan 15 Kotak Balok Vertikal (Filled vs Unfilled)
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(maxSegments, (index) {
              final isFilled = index < filledSegments;

              return Expanded(
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 250 + (index * 25)),
                  height: 17,
                  margin: const EdgeInsets.symmetric(horizontal: 0.8),
                  decoration: BoxDecoration(
                    color: isFilled
                        ? activeColor
                        : const Color(
                            0xFFE8ECEF), // Abu-abu muda untuk blok kosong
                    borderRadius: BorderRadius.circular(1.5),
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  // ==========================================================================
  // TAB 3: EVOLUTION CHAIN (INTERAKTIF & PLAYFUL)
  // ==========================================================================
  Widget _buildEvolutionTab() {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(22, 14, 22, 30),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Evolution Chain',
                style: lBold.copyWith(color: bgDark),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: borderNeutral.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.touch_app_rounded,
                      size: 12, color: black600),
                  const SizedBox(width: 4),
                  Text(
                    'Tap to switch',
                    style: xxsBold.copyWith(color: black600),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Vertical Evolution Timeline
        for (int i = 0; i < _currentPokemon.evolutions.length; i++) ...[
          _buildEvolutionCard(
            _currentPokemon.evolutions[i],
            isCurrent: _currentPokemon.evolutions[i].id == _currentPokemon.id,
            accentColor: _currentPokemon.primaryColor,
          ),
          if (i < _currentPokemon.evolutions.length - 1)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                children: [
                  Container(
                    width: 2,
                    height: 16,
                    color: borderNeutral,
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color:
                          _currentPokemon.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      _currentPokemon.evolutions[i + 1].trigger,
                      style:
                          xxsBold.copyWith(color: _currentPokemon.primaryColor),
                    ),
                  ),
                  Container(
                    width: 2,
                    height: 16,
                    color: borderNeutral,
                  ),
                ],
              ),
            ),
        ],
      ],
    );
  }

  Widget _buildEvolutionCard(
    EvolutionDummy evolution, {
    required bool isCurrent,
    required Color accentColor,
  }) {
    return InkWell(
      onTap: () {
        if (evolution.id == _currentPokemon.id) return;
        setState(() {
          _currentPokemon = _currentPokemon.copyWithEvolutionTarget(
            id: evolution.id,
            name: evolution.name,
            accentColor: PokemonTypeColors.getColorById(evolution.id),
          );
        });
        context.read<DetailCubit>().getPokemonDetail(
              evolution.id.toString(),
              isSwitchingEvolution: true,
            );
      },
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isCurrent ? accentColor.withValues(alpha: 0.08) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isCurrent ? accentColor : borderNeutral,
            width: isCurrent ? 2.0 : 1.0,
          ),
          boxShadow: isCurrent
              ? [
                  BoxShadow(
                    color: accentColor.withValues(alpha: 0.22),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            // Mini Preview (Battle GIF or Artwork)
            Container(
              width: 70,
              height: 70,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: isCurrent
                    ? accentColor.withValues(alpha: 0.15)
                    : borderNeutral.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(16),
              ),
              child: CachedNetworkImage(
                imageUrl: _displayMode == PokemonDisplayMode.battleGif
                    ? evolution.gifUrl
                    : evolution.artworkUrl,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  evolution.formattedId,
                  style: xxsBold.copyWith(color: black500),
                ),
                Text(
                  evolution.name,
                  style: mdBold.copyWith(color: bgDark),
                ),
                const SizedBox(height: 2),
                Text(
                  evolution.trigger,
                  style: xsRegular.copyWith(color: black600),
                ),
              ],
            ),
            const Spacer(),
            if (isCurrent)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Active',
                  style: xxsBold.copyWith(color: Colors.white),
                ),
              )
            else
              const Icon(Icons.touch_app_rounded, size: 20, color: black400),
          ],
        ),
      ),
    );
  }

  // ==========================================================================
  // TAB 4: MOVES (PLAYFUL POKÉMON TCG / GAME BATTLE STYLE)
  // ==========================================================================
  Widget _buildMovesTab() {
    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(22, 14, 22, 30),
      itemCount: _currentPokemon.moves.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final move = _currentPokemon.moves[index];
        final typeColor = PokemonTypeColors.getColor(move.type);

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: borderNeutral),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Type Badge Kotak + Move Name
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: typeColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          move.type,
                          style: xxsBold.copyWith(color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        move.name,
                        style: smBold.copyWith(color: bgDark, fontSize: 16),
                      ),
                    ],
                  ),
                  // Power Number Badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: typeColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'PWR ${move.power}',
                      style: xsBold.copyWith(color: typeColor),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                move.description,
                style: xxsRegular.copyWith(color: black600, height: 1.4),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: borderNeutral.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Accuracy: ${move.accuracy}%',
                      style: xxsMedium.copyWith(color: black700),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: borderNeutral.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'PP: ${move.pp}',
                      style: xxsMedium.copyWith(color: black700),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
