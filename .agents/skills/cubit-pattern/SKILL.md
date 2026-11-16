---
name: Cubit Pattern
description: Cara membuat dan menggunakan Cubit + State di PokéAtlas
---
# Cubit Pattern — PokéAtlas

## State Pattern (sealed class)

Semua state pakai `sealed class` + `Equatable`. Ini memungkinkan exhaustive pattern matching di UI.

```dart
// {feature}_state.dart
part of '{feature}_cubit.dart';

sealed class XState extends Equatable {
  const XState();
  @override
  List<Object?> get props => [];
}

final class XInitial extends XState { const XInitial(); }
final class XLoading extends XState { const XLoading(); }

final class XLoaded extends XState {
  final SomeModel data;
  const XLoaded(this.data);
  @override
  List<Object?> get props => [data];
}

final class XError extends XState {
  final String message;
  const XError(this.message);
  @override
  List<Object?> get props => [message];
}
```

## Cubit

```dart
class XCubit extends Cubit<XState> {
  final XRepository _repository;

  XCubit(this._repository) : super(const XInitial());

  Future<void> fetchData() async {
    emit(const XLoading());
    final result = await _repository.getData();
    if (result is DataStateSuccess<SomeModel>) {
      emit(XLoaded(result.data!));
    } else if (result is DataStateError) {
      emit(XError(result.error ?? 'Terjadi kesalahan'));
    }
  }
}
```

## UI — BlocBuilder

```dart
BlocBuilder<XCubit, XState>(
  builder: (context, state) {
    return switch (state) {
      XInitial() => const SizedBox.shrink(),
      XLoading() => const Center(child: CircularProgressIndicator()),
      XLoaded(:final data) => MyWidget(data: data),
      XError(:final message) => ErrorWidget(message: message),
    };
  },
)
```

## UI — BlocConsumer (side effect + rebuild)

```dart
BlocConsumer<XCubit, XState>(
  listener: (context, state) {
    if (state is XError) {
      AppMessenger.show(context, message: state.message, icon: Icons.error);
    }
  },
  builder: (context, state) {
    // ... rebuild widget
  },
)
```

## State dengan mutable fields (pakai copyWith)

Untuk state yang perlu update partial (contoh: CompareState):

```dart
class XState extends Equatable {
  final String? fieldA;
  final int count;

  const XState({this.fieldA, required this.count});

  XState copyWith({
    String? Function()? fieldA,   // pakai Function() untuk null-able
    int? count,
  }) {
    return XState(
      fieldA: fieldA != null ? fieldA() : this.fieldA,
      count: count ?? this.count,
    );
  }

  @override
  List<Object?> get props => [fieldA, count];
}
```

## Rules

- Satu Cubit = satu fitur
- Cubit tidak boleh import UI / widget
- Cubit tidak boleh langsung call ApiService — selalu lewat Repository
- Gunakan `Equatable` di semua state agar BlocBuilder tidak rebuild berlebihan
- Inject dependency via constructor (get_it yang provide)
