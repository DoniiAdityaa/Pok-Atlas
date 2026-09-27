part of 'detail_cubit.dart';

sealed class DetailState extends Equatable {
  const DetailState();

  @override
  List<Object?> get props => [];
}

/// Keadaan awal sebelum memanggil detail
final class DetailInitial extends DetailState {}

/// Keadaan saat memuat data detail
final class DetailLoading extends DetailState {}

/// Keadaan saat data detail Pokémon berhasil didapat
final class DetailLoaded extends DetailState {
  final PokemonDetailModel pokemon;
  final List<EvolutionUIModel>? evolutions;
  final String? speciesDescription;
  final String? speciesGenera;
  final double? maleRate;
  final double? femaleRate;
  final List<String>? eggGroups;

  const DetailLoaded({
    required this.pokemon,
    this.evolutions,
    this.speciesDescription,
    this.speciesGenera,
    this.maleRate,
    this.femaleRate,
    this.eggGroups,
  });

  @override
  List<Object?> get props => [
        pokemon,
        evolutions,
        speciesDescription,
        speciesGenera,
        maleRate,
        femaleRate,
        eggGroups,
      ];
}

/// Keadaan saat terjadi error saat mengambil data
final class DetailError extends DetailState {
  final String message;

  const DetailError(this.message);

  @override
  List<Object?> get props => [message];
}
