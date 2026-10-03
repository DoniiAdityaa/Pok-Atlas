import 'dart:ui';
import 'package:flutter/material.dart';
import '../../features/home/home_screen.dart';
import '../color.dart';
import '../typography.dart';

enum MainTab {
  home,
  explore,
  favorites,
  settings,
}

class _NavItemData {
  final MainTab tab;
  final String label;
  final IconData activeIcon;
  final IconData inactiveIcon;
  final Color activeColor;

  const _NavItemData({
    required this.tab,
    required this.label,
    required this.activeIcon,
    required this.inactiveIcon,
    required this.activeColor,
  });
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  MainTab _currentTab = MainTab.home;
  final _pageController = PageController();
  final GlobalKey<HomeScreenState> _homeKey = GlobalKey<HomeScreenState>();

  static const List<_NavItemData> _navItems = [
    _NavItemData(
      tab: MainTab.home,
      label: 'PokéDex',
      activeIcon: Icons.catching_pokemon,
      inactiveIcon: Icons.catching_pokemon_outlined,
      activeColor: primaryColor,
    ),
    _NavItemData(
      tab: MainTab.explore,
      label: 'Radar',
      activeIcon: Icons.explore_rounded,
      inactiveIcon: Icons.explore_outlined,
      activeColor: PokemonTypeColors.grass,
    ),
    _NavItemData(
      tab: MainTab.favorites,
      label: 'Vault',
      activeIcon: Icons.favorite_rounded,
      inactiveIcon: Icons.favorite_outline_rounded,
      activeColor: errorColor,
    ),
    _NavItemData(
      tab: MainTab.settings,
      label: 'Bag',
      activeIcon: Icons.backpack_rounded,
      inactiveIcon: Icons.backpack_outlined,
      activeColor: PokemonTypeColors.dragon,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabSelected(MainTab tab) {
    if (_currentTab == tab) {
      // Re-tap pada tab aktif: scroll kembali ke puncak halaman secara halus
      if (tab == MainTab.home) {
        _homeKey.currentState?.scrollToTop();
      }
      return;
    }
    setState(() => _currentTab = tab);
    _pageController.jumpToPage(tab.index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          HomeScreen(key: _homeKey),
          _buildExplorePlaceholder(),
          _buildFavoritesPlaceholder(),
          _buildSettingsPlaceholder(),
        ],
      ),
      bottomNavigationBar: _buildPlayfulFloatingDock(),
    );
  }

  /// Playful floating dock navigation with bouncy expanding pills & frosted glass
  Widget _buildPlayfulFloatingDock() {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(36),
            boxShadow: [
              // Deep ambient elevation
              BoxShadow(
                color: primaryColor.withValues(alpha: 0.10),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
              // Crisp key light
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(36),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.88),
                  borderRadius: BorderRadius.circular(36),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.8),
                    width: 1.2,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: _navItems.map((item) {
                    final isSelected = _currentTab == item.tab;
                    return _buildNavItem(item, isSelected);
                  }).toList(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Individual animated tab item that expands smoothly when active
  Widget _buildNavItem(_NavItemData item, bool isSelected) {
    return InkWell(
      onTap: () => _onTabSelected(item.tab),
      borderRadius: BorderRadius.circular(24),
      splashColor: item.activeColor.withValues(alpha: 0.15),
      highlightColor: item.activeColor.withValues(alpha: 0.08),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 16 : 14,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? item.activeColor.withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Bouncy animated icon on selection
            TweenAnimationBuilder<double>(
              key: ValueKey('${item.tab}_$isSelected'),
              tween: Tween(begin: isSelected ? 0.75 : 1.0, end: 1.0),
              duration: const Duration(milliseconds: 320),
              curve: Curves.elasticOut,
              builder: (context, scale, child) {
                return Transform.scale(
                  scale: scale,
                  child: Icon(
                    isSelected ? item.activeIcon : item.inactiveIcon,
                    color: isSelected ? item.activeColor : black400,
                    size: 22,
                  ),
                );
              },
            ),

            // Animated expanding label
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 240),
              firstCurve: Curves.easeOut,
              secondCurve: Curves.easeIn,
              crossFadeState: isSelected
                  ? CrossFadeState.showFirst
                  : CrossFadeState.showSecond,
              firstChild: Padding(
                padding: const EdgeInsets.only(left: 6.0),
                child: Text(
                  item.label,
                  style: xsBold.copyWith(
                    color: item.activeColor,
                    fontSize: 12,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
              secondChild: const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  /// Playful Explore Placeholder (Wild Area Radar)
  Widget _buildExplorePlaceholder() {
    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Tag
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: PokemonTypeColors.grass.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '🌿 WILD AREA RADAR',
                  style: xxsBold.copyWith(
                    color: PokemonTypeColors.grass,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Explore Pokémon',
                style: xxlBold.copyWith(
                  fontSize: 28,
                  color: bgDark,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Discover species across all generations and regions.',
                style: smRegular.copyWith(
                  color: textNeutralSecondary,
                ),
              ),

              const Spacer(),

              // Playful Hero Card
              Center(
                child: Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: borderNeutral),
                    boxShadow: [
                      BoxShadow(
                        color: PokemonTypeColors.grass.withValues(alpha: 0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 76,
                        height: 76,
                        decoration: BoxDecoration(
                          color:
                              PokemonTypeColors.grass.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.explore_rounded,
                            size: 40,
                            color: PokemonTypeColors.grass,
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'Generations & Biomes',
                        style: mdBold.copyWith(color: bgDark),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Filter Kanto to Paldea, sort by base stats, and discover legendary Pokémon roaming in the wild.',
                        style: smRegular.copyWith(
                          fontSize: 13,
                          color: textNeutralSecondary,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 18),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: black100,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          '🚀 Coming Next in Step 2',
                          style: xsSemiBold.copyWith(
                            color: black600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }

  /// Playful Favorites Placeholder (Trainer Vault)
  Widget _buildFavoritesPlaceholder() {
    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Tag
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: errorColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '❤️ TRAINER VAULT',
                  style: xxsBold.copyWith(
                    color: errorColor,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Favorite Team',
                style: xxlBold.copyWith(
                  fontSize: 28,
                  color: bgDark,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Your handpicked Pokémon companions.',
                style: smRegular.copyWith(
                  color: textNeutralSecondary,
                ),
              ),

              const Spacer(),

              // Playful Hero Card
              Center(
                child: Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: borderNeutral),
                    boxShadow: [
                      BoxShadow(
                        color: errorColor.withValues(alpha: 0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 76,
                        height: 76,
                        decoration: BoxDecoration(
                          color: errorColor.withValues(alpha: 0.10),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.favorite_rounded,
                            size: 38,
                            color: errorColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'Build Your Dream Team',
                        style: mdBold.copyWith(color: bgDark),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tap the ❤️ heart button on any Pokémon card on the Home screen to save them here for quick team battles.',
                        style: smRegular.copyWith(
                          fontSize: 13,
                          color: textNeutralSecondary,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),

              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }

  /// Playful Settings Placeholder (Trainer Bag)
  Widget _buildSettingsPlaceholder() {
    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Tag
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: PokemonTypeColors.dragon.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '🎒 TRAINER BAG',
                  style: xxsBold.copyWith(
                    color: PokemonTypeColors.dragon,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Trainer & Settings',
                style: xxlBold.copyWith(
                  fontSize: 28,
                  color: bgDark,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'App preferences, audio settings, and Pokédex info.',
                style: smRegular.copyWith(
                  color: textNeutralSecondary,
                ),
              ),

              const Spacer(),

              // Playful Hero Card
              Center(
                child: Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: borderNeutral),
                    boxShadow: [
                      BoxShadow(
                        color: PokemonTypeColors.dragon.withValues(alpha: 0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 76,
                        height: 76,
                        decoration: BoxDecoration(
                          color:
                              PokemonTypeColors.dragon.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.backpack_rounded,
                            size: 38,
                            color: PokemonTypeColors.dragon,
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'Trainer Kit & Options',
                        style: mdBold.copyWith(color: bgDark),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Manage Pokémon cry audio, cache settings, and app themes here.',
                        style: smRegular.copyWith(
                          fontSize: 13,
                          color: textNeutralSecondary,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),

              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }
}
