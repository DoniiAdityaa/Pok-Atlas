import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../models/pokemon_list_model.dart';
import '../../../repository/pokemon_list/pokemon_list_repository.dart';
import '../../../utility/resource/data_state.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final PokemonListRepository repository;

  HomeCubit({required this.repository}) : super(HomeInitial());

  int _offset = 0;
  static const int _limit = 20;

  // Cache untuk list 'All' agar saat kembali ke tab 'All' tidak perlu fetch ulang
  List<PokemonListItemModel> _allPokemonList = [];
  List<PokemonListItemModel> _allDirectory = [];
  bool _allHasReachedMax = false;
  String _currentType = 'All';

  List<PokemonListItemModel> get allDirectory => _allDirectory;

  /// Memanggil batch pertama Pokémon (20 data pertama)
  Future<void> getPokemonList() async {
    emit(HomeLoading());
    _offset = 0;
    _currentType = 'All';

    final result = await repository.getPokemonList(
      limit: _limit,
      offset: _offset,
    );

    if (result is DataStateSuccess && result.data != null) {
      final list = result.data!.results ?? [];
      final hasReachedMax = result.data!.next == null || list.isEmpty;
      _offset += list.length;
      _allPokemonList = list;
      _allHasReachedMax = hasReachedMax;

      emit(HomeLoaded(
        pokemonList: list,
        allDirectory: _allDirectory,
        hasReachedMax: hasReachedMax,
        selectedType: 'All',
      ));
    } else {
      emit(HomeError(result.message ?? 'Failed to load Pokémon data'));
    }
  }

  bool _isLoadingDirectory = false;

  /// Memuat direktori seluruh 1025 Pokémon secara malas (Lazy Loading On-Demand).
  /// Hanya dipanggil saat user menyentuh kolom pencarian atau menekan tombol dadu acak.
  Future<List<PokemonListItemModel>> ensureDirectoryLoaded() async {
    if (_allDirectory.isNotEmpty) return _allDirectory;
    if (_isLoadingDirectory) return _allDirectory;

    _isLoadingDirectory = true;
    try {
      final dir = await repository.getAllPokemonDirectory();
      if (dir.isNotEmpty) {
        _allDirectory = dir;
        final currentState = state;
        if (currentState is HomeLoaded) {
          emit(currentState.copyWith(allDirectory: dir));
        }
      }
    } finally {
      _isLoadingDirectory = false;
    }
    return _allDirectory;
  }

  /// Memuat Pokémon berikutnya saat di-scroll ke bawah (Infinite Scroll)
  Future<void> loadMorePokemon() async {
    // Jika sedang dalam filter tipe tertentu selain 'All', jangan fetch
    if (_currentType.toLowerCase() != 'all') return;

    final currentState = state;
    if (currentState is! HomeLoaded) return;
    if (currentState.hasReachedMax || currentState.isLoadingMore) return;

    emit(currentState.copyWith(isLoadingMore: true));

    final result = await repository.getPokemonList(
      limit: _limit,
      offset: _offset,
    );

    if (result is DataStateSuccess && result.data != null) {
      final newList = result.data!.results ?? [];
      final hasReachedMax = result.data!.next == null || newList.isEmpty;
      _offset += newList.length;
      _allPokemonList = [..._allPokemonList, ...newList];
      _allHasReachedMax = hasReachedMax;

      emit(currentState.copyWith(
        pokemonList: _allPokemonList,
        allDirectory: _allDirectory,
        hasReachedMax: hasReachedMax,
        isLoadingMore: false,
      ));
    } else {
      emit(currentState.copyWith(isLoadingMore: false));
    }
  }

  /// Memfilter Pokémon berdasarkan tipe elemen
  Future<void> filterByType(String type) async {
    _currentType = type;

    // Jika pilih 'All', langsung restore dari cache list All jika ada
    if (type.toLowerCase() == 'all') {
      _currentType = 'All';
      if (_allPokemonList.isNotEmpty) {
        emit(HomeLoaded(
          pokemonList: _allPokemonList,
          allDirectory: _allDirectory,
          hasReachedMax: _allHasReachedMax,
          selectedType: 'All',
        ));
        return;
      } else {
        return getPokemonList();
      }
    }

    emit(HomeLoading());

    final result = await repository.getPokemonByType(type);

    if (result is DataStateSuccess && result.data != null) {
      final typeSlots = result.data!.pokemon ?? [];
      // Ekstrak PokemonListItemModel dari tiap slot
      final list = typeSlots
          .map((slotItem) => slotItem.pokemon)
          .whereType<PokemonListItemModel>()
          .toList();

      emit(HomeLoaded(
        pokemonList: list,
        allDirectory: _allDirectory,
        hasReachedMax: true,
        selectedType: type,
      ));
    } else {
      emit(HomeError(result.message ?? 'Failed to load $type type Pokémon'));
    }
  }
}
