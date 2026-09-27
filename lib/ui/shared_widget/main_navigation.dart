import 'package:flutter/material.dart';

enum MainTab {
  home,
  explore,
  favorites,
  settings,
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  MainTab _currentTab = MainTab.home;
  final _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabSelected(MainTab tab) {
    if (_currentTab == tab) {
      // TODO: Scroll to top if needed
      return;
    }
    setState(() => _currentTab = tab);
    _pageController.jumpToPage(tab.index);
  }

  Widget _buildPlaceholder(String title) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.category, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.grey,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Coming soon...',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildHomePlaceholder() {
    return Scaffold(
      body: _buildPlaceholder('Home'),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.explore),
      ),
    );
  }

  Widget _buildExplorePlaceholder() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Explore Pokémon'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.filter_list),
          ),
        ],
      ),
      body: _buildPlaceholder('Explore'),
    );
  }

  Widget _buildFavoritesPlaceholder() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Favorites'),
      ),
      body: _buildPlaceholder('Favorites'),
    );
  }

  Widget _buildSettingsPlaceholder() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: _buildPlaceholder('Settings'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _buildHomePlaceholder(),
          _buildExplorePlaceholder(),
          _buildFavoritesPlaceholder(),
          _buildSettingsPlaceholder(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentTab.index,
        onTap: (index) => _onTabSelected(MainTab.values[index]),
        type: BottomNavigationBarType.fixed,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore_outlined),
            activeIcon: Icon(Icons.explore),
            label: 'Explore',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_outline),
            activeIcon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
