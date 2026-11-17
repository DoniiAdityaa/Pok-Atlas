import 'dart:convert';

import 'package:pokeatlas/data/api/api_service.dart';
import 'package:pokeatlas/models/pokemon_type_response_model.dart';
import 'package:pokeatlas/repository/base/base_repository.dart';
import 'package:pokeatlas/utility/logger.dart';
import 'package:pokeatlas/utility/resource/data_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Indeks tipe asli tiap Pokémon: `id → ['Grass', 'Poison']` (urut sesuai slot).
///
/// Dibangun dari 18 endpoint `GET /type/{name}` (endpoint list tidak memuat
/// tipe). Hasilnya di-cache di memori + SharedPreferences sehingga hanya
/// di-fetch sekali seumur instalasi.
class PokemonTypeRepository extends BaseRepository {
  PokemonTypeRepository({required this.api, required this.prefs});

  final ApiService api;
  final SharedPreferences prefs;

  static const String _cacheKey = 'pokemon_type_index_v1';
  static const int _maxNationalDexId = 1025;

  static const List<String> allTypes = [
    'normal', 'fire', 'water', 'grass', 'electric', 'ice', //
    'fighting', 'poison', 'ground', 'flying', 'psychic', 'bug',
    'rock', 'ghost', 'dragon', 'dark', 'steel', 'fairy',
  ];

  Map<int, List<String>>? _memoryCache;

  Future<DataState<Map<int, List<String>>>> getTypeIndex({
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh) {
      final cached = _memoryCache ?? _readDiskCache();
      if (cached != null && cached.isNotEmpty) {
        _memoryCache = cached;
        return DataStateSuccess(cached);
      }
    }

    // Fetch 18 tipe secara paralel
    final results = await Future.wait(
      allTypes.map(
        (type) => getStateOf<PokemonTypeResponseModel>(
          request: () => api.getPokemonByType(type),
        ),
      ),
    );

    final firstError = results.whereType<DataStateError>().firstOrNull;
    if (firstError != null) {
      return DataStateError(firstError.message);
    }

    // id → (slot → type)
    final slots = <int, Map<int, String>>{};
    for (var i = 0; i < results.length; i++) {
      final typeName = _capitalize(allTypes[i]);
      for (final entry in results[i].data?.pokemon ?? const []) {
        final id = entry.pokemon?.id;
        if (id == null || id > _maxNationalDexId) continue; // skip form khusus
        slots.putIfAbsent(id, () => {})[entry.slot ?? 1] = typeName;
      }
    }

    final index = {
      for (final e in slots.entries)
        e.key: (e.value.keys.toList()..sort()).map((s) => e.value[s]!).toList(),
    };

    _memoryCache = index;
    await _writeDiskCache(index);
    return DataStateSuccess(index);
  }

  Map<int, List<String>>? _readDiskCache() {
    final raw = prefs.getString(_cacheKey);
    if (raw == null) return null;
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return decoded.map(
        (key, value) => MapEntry(
          int.parse(key),
          (value as List).cast<String>(),
        ),
      );
    } catch (error, stackTrace) {
      LoggerHelper.e('Failed to read type index cache', error, stackTrace);
      return null;
    }
  }

  Future<void> _writeDiskCache(Map<int, List<String>> index) async {
    try {
      await prefs.setString(
        _cacheKey,
        jsonEncode(index.map((k, v) => MapEntry(k.toString(), v))),
      );
    } catch (error, stackTrace) {
      LoggerHelper.e('Failed to write type index cache', error, stackTrace);
    }
  }

  static String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}
