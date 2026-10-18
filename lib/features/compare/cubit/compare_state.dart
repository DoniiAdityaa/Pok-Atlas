part of 'compare_cubit.dart';

/// UI Model untuk data perbandingan Pokémon di Arena Compare
class ComparePokemonItem {
  final int id;
  final String name;
  final List<String> types;
  final String imageUrl;
  final int hp;
  final int attack;
  final int defense;
  final int specialAttack;
  final int specialDefense;
  final int speed;
  final double height; // meter
  final double weight; // kg
  final List<String> abilities;

  const ComparePokemonItem({
    required this.id,
    required this.name,
    required this.types,
    required this.imageUrl,
    required this.hp,
    required this.attack,
    required this.defense,
    required this.specialAttack,
    required this.specialDefense,
    required this.speed,
    required this.height,
    required this.weight,
    required this.abilities,
  });

  /// Base Stat Total (BST)
  int get totalBst =>
      hp + attack + defense + specialAttack + specialDefense + speed;

  /// Format Pokédex ID: "#0025"
  String get formattedId => '#${id.toString().padLeft(4, '0')}';

  /// Konversi dari [PokemonDetailModel] (data live PokéAPI) ke [ComparePokemonItem]
  factory ComparePokemonItem.fromDetail(PokemonDetailModel detail) {
    final effectiveTypes = detail.typeNames.isNotEmpty
        ? detail.typeNames
        : PokemonTypeColors.getTypesById(detail.id);

    return ComparePokemonItem(
      id: detail.id ?? 0,
      name: detail.capitalizedName.isNotEmpty
          ? detail.capitalizedName
          : (detail.name ?? 'Unknown'),
      types: effectiveTypes,
      imageUrl: detail.officialImageUrl,
      hp: detail.hp,
      attack: detail.attack,
      defense: detail.defense,
      specialAttack: detail.specialAttack,
      specialDefense: detail.specialDefense,
      speed: detail.speed,
      height: detail.heightInMeters,
      weight: detail.weightInKg,
      abilities: effectiveTypes,
    );
  }
}

class CompareState extends Equatable {
  final ComparePokemonItem? pokemonA;
  final ComparePokemonItem? pokemonB;
  final bool isLoadingA;
  final bool isLoadingB;
  final List<PokemonListItemModel> directory;
  final bool isLoadingDirectory;
  final String? errorMessage;

  const CompareState({
    this.pokemonA,
    this.pokemonB,
    this.isLoadingA = false,
    this.isLoadingB = false,
    this.directory = const [],
    this.isLoadingDirectory = false,
    this.errorMessage,
  });

  bool get hasBoth => pokemonA != null && pokemonB != null;
  bool get hasEither => pokemonA != null || pokemonB != null;

  CompareState copyWith({
    ComparePokemonItem? Function()? pokemonA,
    ComparePokemonItem? Function()? pokemonB,
    bool? isLoadingA,
    bool? isLoadingB,
    List<PokemonListItemModel>? directory,
    bool? isLoadingDirectory,
    String? Function()? errorMessage,
  }) {
    return CompareState(
      pokemonA: pokemonA != null ? pokemonA() : this.pokemonA,
      pokemonB: pokemonB != null ? pokemonB() : this.pokemonB,
      isLoadingA: isLoadingA ?? this.isLoadingA,
      isLoadingB: isLoadingB ?? this.isLoadingB,
      directory: directory ?? this.directory,
      isLoadingDirectory: isLoadingDirectory ?? this.isLoadingDirectory,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        pokemonA,
        pokemonB,
        isLoadingA,
        isLoadingB,
        directory,
        isLoadingDirectory,
        errorMessage,
      ];
}
