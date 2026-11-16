---
name: Feature Flow (E2E)
description: Langkah-langkah lengkap membuat feature baru dari nol di PokéAtlas
---
# Feature Flow — Step by Step

Urutan wajib saat membuat feature baru. Jangan loncat langkah.

## Urutan Implementasi

```
Step 1: Model          lib/models/{feature}_model.dart  (@JsonSerializable)
Step 2: ApiService     lib/data/api/api_service.dart    (tambah @GET/@POST endpoint)
Step 3: Repository     lib/repository/{feature}/{feature}_repository.dart
Step 4: Cubit State    lib/features/{feature}/cubit/{feature}_state.dart
Step 5: Cubit          lib/features/{feature}/cubit/{feature}_cubit.dart
Step 6: Screen         lib/features/{feature}/{feature}_screen.dart
Step 7: Register DI    lib/config/service_locator.dart
Step 8: Register BLoC  lib/main.dart → MultiBlocProvider
```

## Step 1 — Model

```dart
// lib/models/pokemon_xyz_model.dart
import 'package:json_annotation/json_annotation.dart';
part 'pokemon_xyz_model.g.dart';

@JsonSerializable()
class PokemonXyzModel {
  @JsonKey(name: 'field_name')
  final String fieldName;

  const PokemonXyzModel({required this.fieldName});

  factory PokemonXyzModel.fromJson(Map<String, dynamic> json) =>
      _$PokemonXyzModelFromJson(json);

  Map<String, dynamic> toJson() => _$PokemonXyzModelToJson(this);
}
```

Setelah buat model, run:
```bash
dart run build_runner build --delete-conflicting-outputs
```

## Step 2 — ApiService Endpoint

```dart
// lib/data/api/api_service.dart
@GET(ApiEndpoints.pokemonXyz)
Future<HttpResponse<PokemonXyzModel>> getPokemonXyz(
  @Path('id') int id,
);
```

Tambah constant di `lib/config/constant.dart`:
```dart
static const String pokemonXyz = '/xyz/{id}';
```

## Step 3 — Repository

```dart
// lib/repository/pokemon_xyz/pokemon_xyz_repository.dart
import 'package:pokeatlas/data/api/api_service.dart';
import 'package:pokeatlas/models/pokemon_xyz_model.dart';
import 'package:pokeatlas/utility/resource/data_state.dart';
import '../base/base_repository.dart';

class PokemonXyzRepository extends BaseRepository {
  final ApiService _apiService;

  PokemonXyzRepository(this._apiService);

  Future<DataState<PokemonXyzModel>> getXyz(int id) {
    return getStateOf(request: () => _apiService.getPokemonXyz(id));
  }
}
```

## Step 4 — Cubit State

```dart
// lib/features/xyz/cubit/xyz_state.dart
part of 'xyz_cubit.dart';

sealed class XyzState extends Equatable {
  const XyzState();
  @override
  List<Object?> get props => [];
}

final class XyzInitial extends XyzState {
  const XyzInitial();
}

final class XyzLoading extends XyzState {
  const XyzLoading();
}

final class XyzLoaded extends XyzState {
  final PokemonXyzModel data;
  const XyzLoaded(this.data);
  @override
  List<Object?> get props => [data];
}

final class XyzError extends XyzState {
  final String message;
  const XyzError(this.message);
  @override
  List<Object?> get props => [message];
}
```

## Step 5 — Cubit

```dart
// lib/features/xyz/cubit/xyz_cubit.dart
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:pokeatlas/models/pokemon_xyz_model.dart';
import 'package:pokeatlas/repository/pokemon_xyz/pokemon_xyz_repository.dart';
import 'package:pokeatlas/utility/resource/data_state.dart';
part 'xyz_state.dart';

class XyzCubit extends Cubit<XyzState> {
  final PokemonXyzRepository _repository;

  XyzCubit(this._repository) : super(const XyzInitial());

  Future<void> fetchXyz(int id) async {
    emit(const XyzLoading());
    final result = await _repository.getXyz(id);
    if (result is DataStateSuccess<PokemonXyzModel>) {
      emit(XyzLoaded(result.data!));
    } else if (result is DataStateError) {
      emit(XyzError(result.error ?? 'Terjadi kesalahan'));
    }
  }
}
```

## Step 6 — Screen

```dart
// lib/features/xyz/xyz_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'cubit/xyz_cubit.dart';

class XyzScreen extends StatelessWidget {
  const XyzScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<XyzCubit, XyzState>(
        builder: (context, state) {
          return switch (state) {
            XyzInitial() => const SizedBox.shrink(),
            XyzLoading() => const Center(child: CircularProgressIndicator()),
            XyzLoaded(:final data) => Text(data.fieldName),
            XyzError(:final message) => Center(child: Text(message)),
          };
        },
      ),
    );
  }
}
```

## Step 7 — Register DI

```dart
// lib/config/service_locator.dart
serviceLocator.registerLazySingleton<PokemonXyzRepository>(
  () => PokemonXyzRepository(serviceLocator()),
);
serviceLocator.registerFactory<XyzCubit>(
  () => XyzCubit(serviceLocator()),
);
```

## Step 8 — Register BLoC di main.dart

```dart
BlocProvider(
  create: (_) => serviceLocator<XyzCubit>(),
),
```
