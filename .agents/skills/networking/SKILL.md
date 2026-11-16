---
name: Networking
description: Dio, Retrofit ApiService, dan menambah endpoint baru
---
# Networking — PokéAtlas

## Stack

- **Dio** — HTTP client
- **Retrofit** — type-safe API service (code generation)
- **AwesomeDioInterceptor** — logging di debug mode
- **Envied** — load base URL dari `.env`

## Konfigurasi Dio

`lib/config/service_locator.dart`

```dart
serviceLocator.registerLazySingleton<Dio>(() => Dio(
  BaseOptions(
    baseUrl: Env.baseUrl,
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
    headers: {'Content-Type': 'application/json'},
  ),
)..interceptors.addAll([
  if (kDebugMode) AwesomeDioInterceptor(),
]));
```

## ApiService (Retrofit)

`lib/data/api/api_service.dart`

```dart
@RestApi()
abstract class ApiService {
  factory ApiService(Dio dio, {String? baseUrl}) = _ApiService;

  @GET(ApiEndpoints.pokemonList)
  Future<HttpResponse<PokemonListModel>> getPokemonList(
    @Query('limit') int limit,
    @Query('offset') int offset,
  );

  @GET(ApiEndpoints.pokemonDetail)
  Future<HttpResponse<PokemonDetailModel>> getPokemonDetail(
    @Path('name') String name,
  );
}
```

## Menambah Endpoint Baru

**Step 1** — Tambah constant di `lib/config/constant.dart`:
```dart
class ApiEndpoints {
  static const String pokemonList   = '/pokemon';
  static const String pokemonDetail = '/pokemon/{name}';
  static const String pokemonXyz    = '/xyz/{id}';  // ← tambah
}
```

**Step 2** — Tambah method di `ApiService`:
```dart
@GET(ApiEndpoints.pokemonXyz)
Future<HttpResponse<XyzModel>> getXyz(@Path('id') int id);
```

**Step 3** — Generate ulang:
```bash
dart run build_runner build --delete-conflicting-outputs
```

## Base URL

Dari `.env`:
```
BASE_URL=https://pokeapi.co/api/v2
```

Dibaca via `lib/config/env/env.dart` (Envied).

## Rules

- Tidak boleh hardcode URL — selalu pakai `ApiEndpoints.xxx`
- Tidak boleh call `dio.get()` langsung di repository kecuali ada alasan kuat (seperti endpoint non-standard evolution chain)
- Response type harus `HttpResponse<T>` agar BaseRepository bisa baca status code
