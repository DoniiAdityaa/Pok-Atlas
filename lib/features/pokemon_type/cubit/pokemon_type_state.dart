part of 'pokemon_type_cubit.dart';

sealed class PokemonTypeState extends Equatable {
  const PokemonTypeState();

  @override
  List<Object?> get props => [];
}

final class PokemonTypeInitial extends PokemonTypeState {
  const PokemonTypeInitial();
}

final class PokemonTypeLoading extends PokemonTypeState {
  const PokemonTypeLoading();
}

final class PokemonTypeLoaded extends PokemonTypeState {
  const PokemonTypeLoaded(this.index);

  /// `id → ['Grass', 'Poison']`
  final Map<int, List<String>> index;

  @override
  List<Object?> get props => [index.length];
}

final class PokemonTypeError extends PokemonTypeState {
  const PokemonTypeError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
