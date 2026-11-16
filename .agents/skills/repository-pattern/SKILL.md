---
name: Repository Pattern
description: Membuat dan menggunakan Repository di PokéAtlas
---
# Repository Pattern — PokéAtlas

## BaseRepository

Semua repository extends `BaseRepository` di `lib/repository/base/base_repository.dart`.

Method utama: `getStateOf<T>()` — wrap request Retrofit ke `DataState<T>`.

```dart
abstract class BaseRepository {
  Future<DataState<T>> getStateOf<T>({
    required Future<HttpResponse<T>> Function() request,
  }) async { ... }
}
```

## Membuat Repository Baru

```dart
// lib/repository/{feature}/{feature}_repository.dart
import 'package:pokeatlas/data/api/api_service.dart';
import 'package:pokeatlas/models/{feature}_model.dart';
import 'package:pokeatlas/utility/resource/data_state.dart';
import '../base/base_repository.dart';

class FeatureRepository extends BaseRepository {
  final ApiService _apiService;

  FeatureRepository(this._apiService);

  Future<DataState<FeatureModel>> getFeature(int id) {
    return getStateOf(request: () => _apiService.getFeature(id));
  }

  // Multiple calls → gabungkan manual
  Future<DataState<CombinedModel>> getFeatureWithDetail(int id) async {
    final result = await getStateOf(request: () => _apiService.getFeature(id));
    if (result is DataStateError) return result;

    final detail = await getStateOf(
      request: () => _apiService.getFeatureDetail(id),
    );
    if (detail is DataStateError) return detail;

    return DataStateSuccess(
      CombinedModel(
        feature: result.data!,
        detail: detail.data!,
      ),
    );
  }
}
```

## DataState

```dart
// lib/utility/resource/data_state.dart
sealed class DataState<T> {
  final T? data;
  final String? error;
  final int? statusCode;
  ...
}
class DataStateSuccess<T> extends DataState<T> { ... }
class DataStateError<T> extends DataState<T> { ... }
```

## In-Memory Cache (pattern yang sudah ada)

Untuk data yang jarang berubah (pokemon detail):

```dart
class PokemonDetailRepository extends BaseRepository {
  final ApiService _apiService;
  final Map<int, PokemonDetailModel> _cache = {};

  PokemonDetailRepository(this._apiService);

  Future<DataState<PokemonDetailModel>> getPokemonDetail(int id) async {
    if (_cache.containsKey(id)) {
      return DataStateSuccess(_cache[id]!);
    }
    final result = await getStateOf(
      request: () => _apiService.getPokemonDetail(id),
    );
    if (result is DataStateSuccess && result.data != null) {
      _cache[id] = result.data!;
    }
    return result;
  }
}
```

## Rules

- Repository tidak boleh emit state atau import BLoC
- Repository tidak boleh import widget
- Error handling sudah diurus `getStateOf` — tidak perlu try/catch manual
- Kalau butuh transformasi data kompleks, lakukan di repository bukan di Cubit
