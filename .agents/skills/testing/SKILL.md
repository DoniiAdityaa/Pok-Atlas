---
name: Testing
description: Unit testing Cubit dan Repository dengan Mockito
---
# Testing — PokéAtlas

## Setup (sudah ada di pubspec.yaml)

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  build_runner: ^2.x.x
  # Tambahkan kalau belum ada:
  # mockito: ^5.x.x
```

## Struktur Test

```
test/
├── repository/
│   └── pokemon_detail/
│       └── pokemon_detail_repository_test.dart
├── cubit/
│   └── home/
│       └── home_cubit_test.dart
└── utility/
    └── json_parser_test.dart
```

## Contoh — Test Cubit

```dart
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:pokeatlas/features/home/cubit/home_cubit.dart';
import 'package:pokeatlas/repository/pokemon_list/pokemon_list_repository.dart';
import 'package:pokeatlas/utility/resource/data_state.dart';
import 'home_cubit_test.mocks.dart';

@GenerateMocks([PokemonListRepository])
void main() {
  late MockPokemonListRepository mockRepo;
  late HomeCubit cubit;

  setUp(() {
    mockRepo = MockPokemonListRepository();
    cubit = HomeCubit(mockRepo);
  });

  tearDown(() => cubit.close());

  blocTest<HomeCubit, HomeState>(
    'emits [HomeLoading, HomeLoaded] when fetch succeeds',
    build: () {
      when(mockRepo.getPokemonList(any, any)).thenAnswer(
        (_) async => DataStateSuccess(fakeModel),
      );
      return cubit;
    },
    act: (c) => c.getPokemonList(),
    expect: () => [isA<HomeLoading>(), isA<HomeLoaded>()],
  );

  blocTest<HomeCubit, HomeState>(
    'emits [HomeLoading, HomeError] when fetch fails',
    build: () {
      when(mockRepo.getPokemonList(any, any)).thenAnswer(
        (_) async => DataStateError('Network error'),
      );
      return cubit;
    },
    act: (c) => c.getPokemonList(),
    expect: () => [isA<HomeLoading>(), isA<HomeError>()],
  );
}
```

## Generate Mocks

```bash
dart run build_runner build --delete-conflicting-outputs
```

## Contoh — Test Repository

```dart
@GenerateMocks([ApiService])
void main() {
  late MockApiService mockApi;
  late PokemonListRepository repo;

  setUp(() {
    mockApi = MockApiService();
    repo = PokemonListRepository(mockApi);
  });

  test('returns DataStateSuccess when API call succeeds', () async {
    when(mockApi.getPokemonList(any, any)).thenAnswer(
      (_) async => HttpResponse(fakeModel, fakeResponse),
    );
    final result = await repo.getPokemonList(20, 0);
    expect(result, isA<DataStateSuccess>());
  });
}
```

## Tips

- Tambahkan `bloc_test: ^9.x.x` di dev_dependencies untuk `blocTest()`
- Jalankan `flutter test` untuk semua test
- Jalankan `flutter test test/cubit/home/` untuk satu folder
