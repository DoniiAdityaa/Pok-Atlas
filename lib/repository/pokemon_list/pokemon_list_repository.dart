import 'package:pokeatlas/data/api/api_service.dart';
import 'package:pokeatlas/models/pokemon_list_model.dart';
import 'package:pokeatlas/models/pokemon_type_response_model.dart';
import 'package:pokeatlas/repository/base/base_repository.dart';
import 'package:pokeatlas/utility/resource/data_state.dart';

class PokemonListRepository extends BaseRepository {
  final ApiService api;

  PokemonListRepository({required this.api});

  List<PokemonListItemModel> _allPokemonDirectory = [];

  Future<DataState<PokemonListModel>> getPokemonList({
    int limit = 20,
    int offset = 0,
  }) async {
    return getStateOf<PokemonListModel>(
        request: () => api.getPokemonList(limit: limit, offset: offset));
  }

  /// Mengambil direktori lengkap seluruh 1025 Pokémon untuk pencarian global instan
  Future<List<PokemonListItemModel>> getAllPokemonDirectory() async {
    if (_allPokemonDirectory.isNotEmpty) {
      return _allPokemonDirectory;
    }

    final result = await getStateOf<PokemonListModel>(
      request: () => api.getPokemonList(limit: 1025, offset: 0),
    );

    if (result is DataStateSuccess && result.data?.results != null) {
      _allPokemonDirectory = result.data!.results!;
    }

    return _allPokemonDirectory;
  }

  Future<DataState<PokemonTypeResponseModel>> getPokemonByType(
    String type,
  ) async {
    return getStateOf<PokemonTypeResponseModel>(
      request: () => api.getPokemonByType(type.toLowerCase()),
    );
  }
}
