import 'package:pokeatlas/data/api/api_service.dart';
import 'package:pokeatlas/models/pokemon_list_model.dart';
import 'package:pokeatlas/repository/base/base_repository.dart';
import 'package:pokeatlas/utility/resource/data_state.dart';

class PokemonListRepository extends BaseRepository {
  final ApiService api;

  PokemonListRepository({required this.api});

  Future<DataState<PokemonListModel>> getPokemonList({
    int limit = 20,
    int offset = 0,
  }) async {
    return getStateOf<PokemonListModel>(
        request: () => api.getPokemonList(limit: limit, offset: offset));
  }
}
