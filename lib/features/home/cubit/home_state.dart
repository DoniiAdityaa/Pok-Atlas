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
  final List<PokemonListItemModel> allDirectory;
  final bool hasReachedMax;
  final bool isLoadingMore;
  final String selectedType;

  const HomeLoaded({
    required this.pokemonList,
    this.allDirectory = const [],
    this.hasReachedMax = false,
    this.isLoadingMore = false,
    this.selectedType = 'All',
  });

  HomeLoaded copyWith({
    List<PokemonListItemModel>? pokemonList,
    List<PokemonListItemModel>? allDirectory,
    bool? hasReachedMax,
    bool? isLoadingMore,
    String? selectedType,
  }) {
    return HomeLoaded(
      pokemonList: pokemonList ?? this.pokemonList,
      allDirectory: allDirectory ?? this.allDirectory,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      selectedType: selectedType ?? this.selectedType,
    );
  }

  @override
  List<Object?> get props =>
      [pokemonList, allDirectory, hasReachedMax, isLoadingMore, selectedType];
}

/// Keadaan saat terjadi error saat mengambil data
final class HomeError extends HomeState {
  final String message;

  const HomeError(this.message);

  @override
  List<Object?> get props => [message];
}
