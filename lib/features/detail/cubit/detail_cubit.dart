import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../models/pokemon_detail_model.dart';
import '../../../repository/pokemon_detail/pokemon_detail_repository.dart';
import '../../../utility/resource/data_state.dart';
import '../pokemon_detail_ui_model.dart';

part 'detail_state.dart';

class DetailCubit extends Cubit<DetailState> {
  final PokemonDetailRepository repository;

  DetailCubit({required this.repository}) : super(DetailInitial());

  /// Mengambil detail Pokémon berdasarkan ID atau nama (contoh: "25" atau "pikachu")
  Future<void> getPokemonDetail(
    String idOrName, {
    bool isSwitchingEvolution = false,
  }) async {
    final isCached = repository.isDetailCached(idOrName);

    // Jangan tampilkan LinearProgressIndicator jika data sudah di-cache atau sedang beralih evolusi
    if (!isCached && !isSwitchingEvolution) {
      emit(DetailLoading());
    }

    final result = await repository.getPokemonDetail(idOrName);

    if (result is DataStateSuccess && result.data != null) {
      final speciesData = await repository.getPokemonSpeciesData(idOrName);

      emit(DetailLoaded(
        pokemon: result.data!,
        evolutions: speciesData?.evolutions,
        speciesDescription: speciesData?.description,
        speciesGenera: speciesData?.genera,
        maleRate: speciesData?.maleRate,
        femaleRate: speciesData?.femaleRate,
        eggGroups: speciesData?.eggGroups,
      ));
    } else {
      if (!isSwitchingEvolution) {
        emit(DetailError(result.message ?? 'Failed to load Pokémon details'));
      }
    }
  }
}
