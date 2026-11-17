import 'package:flutter/material.dart';

import '../../ui/color.dart';
import '../../ui/motion/motion.dart';
import '../../ui/shared_widget/app_header.dart';
import '../../ui/shared_widget/generation_card.dart';
import '../../ui/shared_widget/pokemon_empty_state.dart';
import '../../ui/shared_widget/pokemon_search_bar.dart';
import 'model/generation_model.dart';
import 'region_detail_screen.dart';

/// Generation Atlas — header, search, dan daftar kartu 9 era Pokémon
/// (data dummy lokal dari [GenerationData]).
class GenerationScreen extends StatefulWidget {
  const GenerationScreen({super.key});

  @override
  State<GenerationScreen> createState() => _GenerationScreenState();
}

class _GenerationScreenState extends State<GenerationScreen> {
  static const double _cardHeight = 198;
  static const double _cardGap = 16;
  static const double _itemExtent = _cardHeight + _cardGap;

  final List<GenerationModel> _allGenerations = GenerationData.allGenerations;
  late List<GenerationModel> _generations = _allGenerations;

  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  /// Kartu (by generation id) yang sudah pernah dianimasikan masuk.
  final Set<int> _revealedCards = {};

  /// Region yang sedang terlihat — ditampilkan sebagai subtitle header.
  int _activeIndex = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients || _generations.isEmpty) return;
    final position = _scrollController.position;
    final active = position.pixels >= position.maxScrollExtent - 4
        ? _generations.length - 1
        : ((position.pixels + _itemExtent * 0.4) / _itemExtent)
            .floor()
            .clamp(0, _generations.length - 1);

    if (active != _activeIndex) setState(() => _activeIndex = active);
  }

  /// Cocokkan query ke nama region, nomor gen (angka/romawi), tahun,
  /// judul game, dan nama starter. Contoh: "kanto", "gen 3", "iv",
  /// "2013", "sword", "pikachu".
  bool _matches(GenerationModel gen, String q) {
    final normalized = q.replaceAll(RegExp(r'^(gen|generation)\s*'), '');
    if (normalized.isEmpty) return true;

    if (gen.id.toString() == normalized ||
        gen.romanNumeral.toLowerCase() == normalized) {
      return true;
    }

    final haystack = [
      gen.regionName,
      gen.year,
      gen.games,
      gen.tagline,
      ...gen.starters.map((s) => s.name),
    ].join(' ').toLowerCase();

    return haystack.contains(q);
  }

  void _onSearchChanged(String value) {
    final q = value.trim().toLowerCase();
    if (q == _query) return;

    setState(() {
      _query = q;
      _generations = q.isEmpty
          ? _allGenerations
          : _allGenerations.where((g) => _matches(g, q)).toList();
      _activeIndex = 0;
    });

    if (_scrollController.hasClients) _scrollController.jumpTo(0);
  }

  void _resetSearch() {
    _searchController.clear();
    _onSearchChanged('');
    FocusScope.of(context).unfocus();
  }

  void _openRegion(GenerationModel gen) {
    FocusScope.of(context).unfocus();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => RegionDetailScreen(generation: gen)),
    );
  }

  String get _subtitle {
    if (_query.isEmpty) return 'All Generation';
    final count = _generations.length;
    return count == 0 ? 'No region found' : '$count region found';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.translucent,
      child: Scaffold(
        backgroundColor: bg,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              FadeSlideIn(
                offset: const Offset(0, -8),
                child: AppPageHeader(
                  title: 'Generation Atlas',
                  subtitle: _subtitle,
                ),
              ),
              FadeSlideIn(
                delay: AppMotion.staggerAt(1),
                offset: const Offset(0, 12),
                child: PokemonSearchBar(
                  controller: _searchController,
                  hintText: 'Search region, gen, game, or starter...',
                  margin: const EdgeInsets.fromLTRB(20, 4, 20, 4),
                  onChanged: _onSearchChanged,
                ),
              ),
              Expanded(
                child: AnimatedSwitcher(
                  duration: AppMotion.medium,
                  switchInCurve: AppMotion.enter,
                  child: _generations.isEmpty
                      ? _buildEmptyState()
                      : _buildList(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildList(BuildContext context) {
    return ListView.builder(
      key: const ValueKey('generation-list'),
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        MediaQuery.paddingOf(context).bottom + 32,
      ),
      itemExtent: _itemExtent,
      itemCount: _generations.length,
      itemBuilder: (context, index) => _buildCardItem(index),
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      key: const ValueKey('generation-empty'),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      child: PokemonEmptyState(
        title: 'No Region Found',
        subtitle: 'Try "Kanto", "Gen 4", "Sword", or a starter like "Piplup".',
        resetLabel: 'Clear search',
        onReset: _resetSearch,
      ),
    );
  }

  Widget _buildCardItem(int index) {
    final gen = _generations[index];
    final isFirstReveal = _revealedCards.add(gen.id);

    return Padding(
      padding: const EdgeInsets.only(bottom: _cardGap),
      child: FadeSlideIn(
        key: ValueKey(gen.id),
        animate: isFirstReveal,
        // Kartu yang terlihat di awal masuk berurutan; sisanya muncul saat di-scroll.
        delay: index < 4 ? AppMotion.staggerAt(index + 2) : Duration.zero,
        offset: const Offset(0, 28),
        scaleFrom: 0.96,
        child: GenerationCard(
          generation: gen,
          height: _cardHeight,
          onTap: () => _openRegion(gen),
        ),
      ),
    );
  }
}
