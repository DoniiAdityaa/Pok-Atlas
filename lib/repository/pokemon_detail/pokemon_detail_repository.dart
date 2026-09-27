import 'package:dio/dio.dart';
import 'package:pokeatlas/data/api/api_service.dart';
import 'package:pokeatlas/features/detail/pokemon_detail_ui_model.dart';
import 'package:pokeatlas/models/pokemon_detail_model.dart';
import 'package:pokeatlas/repository/base/base_repository.dart';
import 'package:pokeatlas/utility/resource/data_state.dart';

class PokemonDetailRepository extends BaseRepository {
  final ApiService api;
  final Dio dio;

  // In-memory cache agar perpindahan antar Pokémon & tahap evolusi instan tanpa re-render
  final Map<String, PokemonDetailModel> _detailCache = {};
  final Map<int, List<EvolutionUIModel>> _evolutionCache = {};
  final Map<String, PokemonSpeciesData> _speciesCache = {};

  PokemonDetailRepository({
    required this.api,
    required this.dio,
  });

  /// Cek apakah data detail Pokémon sudah ada dalam cache memory
  bool isDetailCached(String idOrName) {
    final clean = idOrName.toLowerCase().trim();
    return _detailCache.containsKey(clean);
  }

  /// Mengambil detail lengkap Pokémon berdasarkan ID atau nama (contoh: "25" atau "pikachu")
  Future<DataState<PokemonDetailModel>> getPokemonDetail(
    String idOrName,
  ) async {
    final clean = idOrName.toLowerCase().trim();
    if (_detailCache.containsKey(clean)) {
      return DataStateSuccess(_detailCache[clean]!);
    }

    final result = await getStateOf<PokemonDetailModel>(
      request: () => api.getPokemonDetail(clean),
    );

    if (result is DataStateSuccess && result.data != null) {
      _detailCache[clean] = result.data!;
      if (result.data!.id != null) {
        _detailCache[result.data!.id.toString()] = result.data!;
      }
      if (result.data!.name != null) {
        _detailCache[result.data!.name!.toLowerCase()] = result.data!;
      }
    }

    return result;
  }

  /// Mengambil data spesies dan hierarki rantai evolusi lengkap dari PokéAPI
  Future<PokemonSpeciesData?> getPokemonSpeciesData(String idOrName) async {
    try {
      final cleanIdOrName = idOrName.toLowerCase().trim();
      if (_speciesCache.containsKey(cleanIdOrName)) {
        return _speciesCache[cleanIdOrName];
      }

      final response = await dio.get('/pokemon-species/$cleanIdOrName');
      if (response.statusCode != 200 || response.data == null) {
        return null;
      }

      final data = response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : <String, dynamic>{};

      final speciesId = data['id'] as int?;

      // 1. Pokédex English Description (Flavor Text)
      String? description;
      final flavorEntries = data['flavor_text_entries'] as List<dynamic>?;
      if (flavorEntries != null) {
        for (final entry in flavorEntries) {
          if (entry['language']?['name'] == 'en') {
            description = (entry['flavor_text'] as String?)
                ?.replaceAll('\n', ' ')
                .replaceAll('\f', ' ')
                .replaceAll(RegExp(r'\s+'), ' ')
                .trim();
            break;
          }
        }
      }

      // 2. Genera (Species Category Title, e.g. "Hypnosis Pokémon")
      String? genera;
      final generaList = data['genera'] as List<dynamic>?;
      if (generaList != null) {
        for (final g in generaList) {
          if (g['language']?['name'] == 'en') {
            genera = g['genus'] as String?;
            break;
          }
        }
      }

      // 3. Gender Rate (in eighths, -1 is genderless)
      final genderRate = data['gender_rate'] as int? ?? 1;
      double maleRate = 50.0;
      double femaleRate = 50.0;
      if (genderRate == -1) {
        maleRate = 0.0;
        femaleRate = 0.0;
      } else {
        femaleRate = (genderRate / 8.0) * 100.0;
        maleRate = 100.0 - femaleRate;
      }

      // 4. Egg Groups
      List<String>? eggGroups;
      final eggList = data['egg_groups'] as List<dynamic>?;
      if (eggList != null) {
        eggGroups = eggList
            .map((e) => (e['name'] as String? ?? ''))
            .where((name) => name.isNotEmpty)
            .map((name) => name[0].toUpperCase() + name.substring(1))
            .toList();
      }

      // 5. Complete Evolution Chain Tree
      List<EvolutionUIModel> evolutions = [];
      if (speciesId != null && _evolutionCache.containsKey(speciesId)) {
        evolutions = _evolutionCache[speciesId]!;
      } else {
        final evoChainUrl = data['evolution_chain']?['url'] as String?;
        if (evoChainUrl != null && evoChainUrl.isNotEmpty) {
          final evoResponse = await dio.get(evoChainUrl);
          if (evoResponse.statusCode == 200 && evoResponse.data != null) {
            final evoData = evoResponse.data as Map<String, dynamic>;
            final chainNode = evoData['chain'] as Map<String, dynamic>?;
            if (chainNode != null) {
              _parseEvolutionChainNode(chainNode, 'Base Form', evolutions);
            }
          }
        }
      }

      final speciesData = PokemonSpeciesData(
        evolutions: evolutions,
        description: description,
        genera: genera,
        maleRate: maleRate,
        femaleRate: femaleRate,
        eggGroups: eggGroups,
      );

      // Cache evolusi untuk semua Pokémon dalam rantai evolusi ini
      for (final evo in evolutions) {
        _evolutionCache[evo.id] = evolutions;
      }
      _speciesCache[cleanIdOrName] = speciesData;
      if (speciesId != null) {
        _speciesCache[speciesId.toString()] = speciesData;
      }

      return speciesData;
    } catch (_) {
      return null;
    }
  }

  /// Parsing rekursif untuk traversal rantai evolusi (Base -> Stage 1 -> Stage 2)
  void _parseEvolutionChainNode(
    Map<String, dynamic> node,
    String trigger,
    List<EvolutionUIModel> result,
  ) {
    final species = node['species'] as Map<String, dynamic>?;
    final name = (species?['name'] as String?) ?? '';
    final url = (species?['url'] as String?) ?? '';
    final cleanUrl = url.endsWith('/') ? url.substring(0, url.length - 1) : url;
    final id = int.tryParse(cleanUrl.split('/').last) ?? 0;
    final capitalized = name.isNotEmpty
        ? name[0].toUpperCase() + name.substring(1)
        : 'Unknown';

    result.add(EvolutionUIModel(
      id: id,
      name: capitalized,
      trigger: trigger,
      artworkUrl:
          'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png',
      gifUrl:
          'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/showdown/$id.gif',
    ));

    final evolvesTo = (node['evolves_to'] as List<dynamic>?) ?? [];
    for (final next in evolvesTo) {
      if (next is! Map<String, dynamic>) continue;
      String nextTrigger = 'Evolution';
      final detailsList = next['evolution_details'] as List<dynamic>?;
      final details = detailsList?.firstOrNull as Map<String, dynamic>?;
      if (details != null) {
        if (details['min_level'] != null) {
          nextTrigger = 'Level ${details['min_level']}';
        } else if (details['item'] != null) {
          final itemName = ((details['item']['name'] as String?) ?? 'item')
              .split('-')
              .map((w) => w.isNotEmpty ? w[0].toUpperCase() + w.substring(1) : '')
              .join(' ');
          nextTrigger = 'Use $itemName';
        } else if (details['trigger']?['name'] == 'trade') {
          nextTrigger = 'Trade';
        } else if (details['min_happiness'] != null) {
          nextTrigger = 'High Friendship';
        } else if (details['known_move'] != null) {
          final moveName = ((details['known_move']['name'] as String?) ?? '')
              .split('-')
              .map((w) => w.isNotEmpty ? w[0].toUpperCase() + w.substring(1) : '')
              .join(' ');
          nextTrigger = 'Learn $moveName';
        } else if (details['location'] != null) {
          nextTrigger = 'Special Area';
        }
      }
      _parseEvolutionChainNode(next, nextTrigger, result);
    }
  }
}

