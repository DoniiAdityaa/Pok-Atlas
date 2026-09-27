import 'package:json_annotation/json_annotation.dart';

part 'pokemon_list_model.g.dart';

@JsonSerializable()
class PokemonListModel {
  @JsonKey(name: 'count')
  final int? count;

  @JsonKey(name: 'next')
  final String? next;

  @JsonKey(name: 'previous')
  final String? previous;

  @JsonKey(name: 'results')
  final List<PokemonListItemModel>? results;

  const PokemonListModel({
    this.count,
    this.next,
    this.previous,
    this.results,
  });

  factory PokemonListModel.fromJson(Map<String, dynamic> json) =>
      _$PokemonListModelFromJson(json);

  Map<String, dynamic> toJson() => _$PokemonListModelToJson(this);
}

@JsonSerializable()
class PokemonListItemModel {
  @JsonKey(name: 'name')
  final String? name;

  @JsonKey(name: 'url')
  final String? url;

  const PokemonListItemModel({
    this.name,
    this.url,
  });

  factory PokemonListItemModel.fromJson(Map<String, dynamic> json) =>
      _$PokemonListItemModelFromJson(json);

  Map<String, dynamic> toJson() => _$PokemonListItemModelToJson(this);

  /// Helper untuk mengekstrak ID Pokémon dari URL (contoh: "https://pokeapi.co/api/v2/pokemon/25/" -> 25)
  int? get id {
    if (url == null) return null;
    final cleanUrl =
        url!.endsWith('/') ? url!.substring(0, url!.length - 1) : url!;
    final segments = cleanUrl.split('/');
    return int.tryParse(segments.last);
  }

  /// Helper untuk memformat ID jadi Pokédex format (contoh: "#0025")
  String get formattedId {
    final pokemonId = id;
    if (pokemonId == null) return '#0000';
    return '#${pokemonId.toString().padLeft(4, '0')}';
  }

  /// Helper untuk nama berhuruf kapital (contoh: "pikachu" -> "Pikachu")
  String get capitalizedName {
    if (name == null || name!.isEmpty) return '';
    return name![0].toUpperCase() + name!.substring(1);
  }

  /// Helper untuk mendapatkan URL gambar artwork resmi berkualitas tinggi dari PokéAPI
  String? get imageUrl {
    final pokemonId = id;
    if (pokemonId == null) return null;
    return 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$pokemonId.png';
  }
}
