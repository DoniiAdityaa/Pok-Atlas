import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pokeatlas/repository/pokemon_type/pokemon_type_repository.dart';
import 'package:pokeatlas/utility/resource/data_state.dart';

part 'pokemon_type_state.dart';

/// Cubit app-level yang menyediakan tipe asli setiap Pokémon.
///
/// Disediakan di root (`main.dart`) agar Home, Region Detail, Compare, dll.
/// bisa memakai warna & badge tipe yang benar.
class PokemonTypeCubit extends Cubit<PokemonTypeState> {
  PokemonTypeCubit({required this.repository})
      : super(const PokemonTypeInitial());

  final PokemonTypeRepository repository;

  Future<void> loadTypeIndex({bool forceRefresh = false}) async {
    if (state is PokemonTypeLoading) return;
    emit(const PokemonTypeLoading());

    final result = await repository.getTypeIndex(forceRefresh: forceRefresh);
    switch (result) {
      case DataStateSuccess(:final data):
        emit(PokemonTypeLoaded(data));
      case DataStateError(:final message):
        emit(PokemonTypeError(message));
    }
  }

  /// Tipe Pokémon berdasarkan ID, atau `null` jika belum tersedia.
  List<String>? typesOf(int? id) {
    final current = state;
    if (id == null || current is! PokemonTypeLoaded) return null;
    return current.index[id];
  }
}
