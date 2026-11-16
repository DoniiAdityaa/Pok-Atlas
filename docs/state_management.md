# State Management — PokéAtlas

PokéAtlas menggunakan **BLoC / Cubit** (`flutter_bloc: ^8.0.1`).

---

## 1. Kenapa Cubit?

- Lebih sederhana dari full BLoC (tidak perlu Event class terpisah)
- Langsung panggil method: `cubit.getPokemonList()`
- Emit state secara imperatif: `emit(HomeLoading())`
- Cukup powerful untuk kebutuhan PokéAtlas tanpa boilerplate berlebih

---

## 2. Standar Pembuatan State

Gunakan **sealed class** + **Equatable**:

```dart
part of 'example_cubit.dart';

sealed class ExampleState extends Equatable {
  const ExampleState();
  @override
  List<Object?> get props => [];
}

final class ExampleInitial extends ExampleState {
  const ExampleInitial();
}

final class ExampleLoading extends ExampleState {
  const ExampleLoading();
}

final class ExampleLoaded extends ExampleState {
  final List<PokemonListItemModel> pokemons;
  const ExampleLoaded(this.pokemons);

  @override
  List<Object?> get props => [pokemons];
}

final class ExampleError extends ExampleState {
  final String message;
  const ExampleError(this.message);

  @override
  List<Object?> get props => [message];
}
```

---

## 3. Standar Pembuatan Cubit

```dart
class ExampleCubit extends Cubit<ExampleState> {
  final PokemonListRepository _repository;

  ExampleCubit(this._repository) : super(const ExampleInitial());

  Future<void> fetchPokemons() async {
    emit(const ExampleLoading());
    final result = await _repository.getPokemonList(20, 0);

    if (result is DataStateSuccess<PokemonListModel>) {
      emit(ExampleLoaded(result.data?.results ?? []));
    } else if (result is DataStateError) {
      emit(ExampleError(result.error ?? 'Gagal memuat Pokémon'));
    }
  }
}
```

---

## 4. Standar Pemakaian di UI

### A. BlocBuilder — HANYA untuk rebuild UI

```dart
BlocBuilder<ExampleCubit, ExampleState>(
  builder: (context, state) {
    return switch (state) {
      ExampleInitial() => const SizedBox.shrink(),
      ExampleLoading() => const Center(child: CircularProgressIndicator()),
      ExampleLoaded(:final pokemons) => ListView.builder(...),
      ExampleError(:final message) => PokemonEmptyState(message: message),
    };
  },
)
```

### B. BlocListener — HANYA untuk side-effects (toast/navigasi)

```dart
BlocListener<ExampleCubit, ExampleState>(
  listener: (context, state) {
    if (state is ExampleError) {
      AppMessenger.show(context, message: state.message, icon: Icons.error);
    }
  },
  child: ...,
)
```

### C. BlocConsumer — Keduanya (rebuild + side-effect)

```dart
BlocConsumer<ExampleCubit, ExampleState>(
  listener: (context, state) {
    if (state is ExampleError) {
      AppMessenger.show(context, message: state.message);
    }
  },
  builder: (context, state) {
    // UI rebuild
  },
)
```

---

## 5. Do & Don't

- **DO** inject Cubit lewat `serviceLocator<XyzCubit>()`
- **DO** gunakan `const` untuk state tanpa payload (`const HomeLoading()`)
- **DO** override `props` di setiap subclass `Equatable`
- **DON'T** panggil `emit()` setelah Cubit ditutup (`isClosed` check kalau perlu)
- **DON'T** letakkan logic UI di dalam Cubit (contoh: format date/color calculation sebaiknya di UI/helper)
- **DON'T** emit state yang sama berturut-turut tanpa perubahan props (BLoC akan skip rebuild)
