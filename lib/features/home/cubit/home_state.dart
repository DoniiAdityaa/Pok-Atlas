part of 'home_cubit.dart';

sealed class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

/// Keadaan awal sebelum memanggil data
final class HomeInitial extends HomeState {}

/// Keadaan saat memuat data pertama kali
final class HomeLoading extends HomeState {}

/// Keadaan saat data Pokémon berhasil didapat
final class HomeLoaded extends HomeState {
  final List<PokemonListItemModel> pokemonList;
  final bool hasReachedMax;
  final bool isLoadingMore;

  const HomeLoaded({
    required this.pokemonList,
    this.hasReachedMax = false,
    this.isLoadingMore = false,
  });

  HomeLoaded copyWith({
    List<PokemonListItemModel>? pokemonList,
    bool? hasReachedMax,
    bool? isLoadingMore,
  }) {
    return HomeLoaded(
      pokemonList: pokemonList ?? this.pokemonList,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object?> get props => [pokemonList, hasReachedMax, isLoadingMore];
}

/// Keadaan saat terjadi error saat mengambil data
final class HomeError extends HomeState {
  final String message;

  const HomeError(this.message);

  @override
  List<Object?> get props => [message];
}
