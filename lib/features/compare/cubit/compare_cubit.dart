import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../models/pokemon_detail_model.dart';
import '../../../models/pokemon_list_model.dart';
import '../../../repository/pokemon_detail/pokemon_detail_repository.dart';
import '../../../repository/pokemon_list/pokemon_list_repository.dart';
import '../../../ui/color.dart';
import '../../../utility/resource/data_state.dart';

part 'compare_state.dart';

class CompareCubit extends Cubit<CompareState> {
  final PokemonListRepository listRepository;
  final PokemonDetailRepository detailRepository;

  CompareCubit({
    required this.listRepository,
    required this.detailRepository,
  }) : super(const CompareState());

  /// Inisialisasi awal: Muat direktori Pokémon dan set Pokémon awal jika ada
  Future<void> init({
    PokemonDetailModel? initialA,
    PokemonDetailModel? initialB,
  }) async {
    ComparePokemonItem? itemA;
    ComparePokemonItem? itemB;

    if (initialA != null) {
      itemA = ComparePokemonItem.fromDetail(initialA);
    }
    if (initialB != null) {
      itemB = ComparePokemonItem.fromDetail(initialB);
    }

    emit(state.copyWith(
      pokemonA: () => itemA,
      pokemonB: () => itemB,
    ));

    await loadDirectory();
  }

  /// Memuat direktori seluruh 1025 Pokémon untuk modal pencarian & filter
  Future<List<PokemonListItemModel>> loadDirectory() async {
    if (state.directory.isNotEmpty) return state.directory;
    emit(state.copyWith(isLoadingDirectory: true));

    try {
      final list = await listRepository.getAllPokemonDirectory();
      emit(state.copyWith(
        directory: list,
        isLoadingDirectory: false,
      ));
      return list;
    } catch (e) {
      emit(state.copyWith(
        isLoadingDirectory: false,
        errorMessage: () => 'Failed to load Pokémon directory: $e',
      ));
      return [];
    }
  }

  /// Memilih Pokémon untuk slot tertentu ('A' atau 'B') dari API
  Future<void> selectPokemon(String slot, dynamic idOrName) async {
    final cleanQuery = idOrName.toString().trim().toLowerCase();
    final isSlotA = slot.toUpperCase() == 'A';

    emit(state.copyWith(
      isLoadingA: isSlotA ? true : null,
      isLoadingB: !isSlotA ? true : null,
      errorMessage: () => null,
    ));

    final result = await detailRepository.getPokemonDetail(cleanQuery);

    if (result is DataStateSuccess && result.data != null) {
      final item = ComparePokemonItem.fromDetail(result.data!);
      emit(state.copyWith(
        pokemonA: isSlotA ? () => item : null,
        pokemonB: !isSlotA ? () => item : null,
        isLoadingA: isSlotA ? false : null,
        isLoadingB: !isSlotA ? false : null,
      ));
    } else {
      emit(state.copyWith(
        isLoadingA: isSlotA ? false : null,
        isLoadingB: !isSlotA ? false : null,
        errorMessage: () => result.message ?? 'Failed to load Pokémon details',
      ));
    }
  }

  /// Menukar posisi Slot A dan Slot B
  void swapSlots() {
    emit(state.copyWith(
      pokemonA: () => state.pokemonB,
      pokemonB: () => state.pokemonA,
    ));
  }

  /// Mengosongkan salah satu slot ('A' atau 'B')
  void clearSlot(String slot) {
    final isSlotA = slot.toUpperCase() == 'A';
    emit(state.copyWith(
      pokemonA: isSlotA ? () => null : null,
      pokemonB: !isSlotA ? () => null : null,
    ));
  }
}
