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

  /// Memanggil batch pertama Pokémon (20 data pertama)
  Future<void> getPokemonList() async {
    emit(HomeLoading());
    _offset = 0;

    final result = await repository.getPokemonList(
      limit: _limit,
      offset: _offset,
    );

    if (result is DataStateSuccess && result.data != null) {
      final list = result.data!.results ?? [];
      final hasReachedMax = result.data!.next == null || list.isEmpty;
      _offset += list.length;

      emit(HomeLoaded(
        pokemonList: list,
        hasReachedMax: hasReachedMax,
      ));
    } else {
      emit(HomeError(result.message ?? 'Gagal memuat data Pokémon'));
    }
  }

  /// Memuat Pokémon berikutnya saat di-scroll ke bawah (Infinite Scroll)
  Future<void> loadMorePokemon() async {
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

      emit(currentState.copyWith(
        pokemonList: [...currentState.pokemonList, ...newList],
        hasReachedMax: hasReachedMax,
        isLoadingMore: false,
      ));
    } else {
      emit(currentState.copyWith(isLoadingMore: false));
    }
  }
}
