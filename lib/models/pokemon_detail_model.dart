import 'package:json_annotation/json_annotation.dart';

part 'pokemon_detail_model.g.dart';

@JsonSerializable()
class PokemonDetailModel {
  @JsonKey(name: 'id')
  final int? id;

  @JsonKey(name: 'name')
  final String? name;

  @JsonKey(name: 'height')
  final int? height;

  @JsonKey(name: 'weight')
  final int? weight;

  @JsonKey(name: 'types')
  final List<PokemonTypeSlot>? types;

  @JsonKey(name: 'stats')
  final List<PokemonStatSlot>? stats;

  @JsonKey(name: 'sprites')
  final PokemonSprites? sprites;

  const PokemonDetailModel({
    this.id,
    this.name,
    this.height,
    this.weight,
    this.types,
    this.stats,
    this.sprites,
  });

  factory PokemonDetailModel.fromJson(Map<String, dynamic> json) =>
      _$PokemonDetailModelFromJson(json);

  Map<String, dynamic> toJson() => _$PokemonDetailModelToJson(this);

  /// Helper untuk format id Pokédex: "#0001"
  String get formattedId {
    if (id == null) return '#0000';
    return '#${id.toString().padLeft(4, '0')}';
  }

  /// Helper untuk nama Pokémon berhuruf kapital (contoh: "bulbasaur" -> "Bulbasaur")
  String get capitalizedName {
    if (name == null || name!.isEmpty) return '';
    return name![0].toUpperCase() + name!.substring(1);
  }

  /// Helper untuk mendapatkan URL gambar resmi (official artwork)
  String get officialImageUrl {
    return sprites?.other?.officialArtwork?.frontDefault ??
        sprites?.frontDefault ??
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png';
  }

  /// Helper untuk mendapatkan URL gambar resmi versi Shiny
  String get shinyOfficialImageUrl {
    return sprites?.other?.officialArtwork?.frontShiny ??
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/shiny/$id.png';
  }

  /// Helper untuk URL animasi GIF pertempuran (Showdown)
  String get battleGifUrl =>
      'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/showdown/$id.gif';

  /// Helper untuk URL animasi GIF pertempuran versi Shiny
  String get shinyBattleGifUrl =>
      'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/showdown/shiny/$id.gif';

  /// Helper tinggi dalam meter (PokéAPI menyimpan dalam desimeter, e.g. 7 = 0.7 m)
  double get heightInMeters => (height ?? 0) / 10.0;

  /// Helper berat dalam kg (PokéAPI menyimpan dalam hektogram, e.g. 69 = 6.9 kg)
  double get weightInKg => (weight ?? 0) / 10.0;

  /// Helper daftar nama tipe (contoh: ["Grass", "Poison"])
  List<String> get typeNames {
    if (types == null) return [];
    return types!
        .where((t) => t.type?.name != null)
        .map((t) =>
            t.type!.name![0].toUpperCase() + t.type!.name!.substring(1))
        .toList();
  }

  /// Helper stat shortcut (HP, Attack, Defense, Special Attack, Special Defense, Speed)
  int get hp => _getStatValue('hp');
  int get attack => _getStatValue('attack');
  int get defense => _getStatValue('defense');
  int get specialAttack => _getStatValue('special-attack');
  int get specialDefense => _getStatValue('special-defense');
  int get speed => _getStatValue('speed');

  int _getStatValue(String statName) {
    if (stats == null) return 0;
    try {
      final statSlot = stats!.firstWhere(
        (s) => s.stat?.name?.toLowerCase() == statName.toLowerCase(),
      );
      return statSlot.baseStat ?? 0;
    } catch (_) {
      return 0;
    }
  }
}

@JsonSerializable()
class PokemonTypeSlot {
  @JsonKey(name: 'slot')
  final int? slot;

  @JsonKey(name: 'type')
  final NamedApiResource? type;

  const PokemonTypeSlot({this.slot, this.type});

  factory PokemonTypeSlot.fromJson(Map<String, dynamic> json) =>
      _$PokemonTypeSlotFromJson(json);

  Map<String, dynamic> toJson() => _$PokemonTypeSlotToJson(this);
}

@JsonSerializable()
class PokemonStatSlot {
  @JsonKey(name: 'base_stat')
  final int? baseStat;

  @JsonKey(name: 'effort')
  final int? effort;

  @JsonKey(name: 'stat')
  final NamedApiResource? stat;

  const PokemonStatSlot({this.baseStat, this.effort, this.stat});

  factory PokemonStatSlot.fromJson(Map<String, dynamic> json) =>
      _$PokemonStatSlotFromJson(json);

  Map<String, dynamic> toJson() => _$PokemonStatSlotToJson(this);
}

@JsonSerializable()
class NamedApiResource {
  @JsonKey(name: 'name')
  final String? name;

  @JsonKey(name: 'url')
  final String? url;

  const NamedApiResource({this.name, this.url});

  factory NamedApiResource.fromJson(Map<String, dynamic> json) =>
      _$NamedApiResourceFromJson(json);

  Map<String, dynamic> toJson() => _$NamedApiResourceToJson(this);
}

@JsonSerializable()
class PokemonSprites {
  @JsonKey(name: 'front_default')
  final String? frontDefault;

  @JsonKey(name: 'other')
  final PokemonOtherSprites? other;

  const PokemonSprites({this.frontDefault, this.other});

  factory PokemonSprites.fromJson(Map<String, dynamic> json) =>
      _$PokemonSpritesFromJson(json);

  Map<String, dynamic> toJson() => _$PokemonSpritesToJson(this);
}

@JsonSerializable()
class PokemonOtherSprites {
  @JsonKey(name: 'official-artwork')
  final OfficialArtwork? officialArtwork;

  const PokemonOtherSprites({this.officialArtwork});

  factory PokemonOtherSprites.fromJson(Map<String, dynamic> json) =>
      _$PokemonOtherSpritesFromJson(json);

  Map<String, dynamic> toJson() => _$PokemonOtherSpritesToJson(this);
}

@JsonSerializable()
class OfficialArtwork {
  @JsonKey(name: 'front_default')
  final String? frontDefault;

  @JsonKey(name: 'front_shiny')
  final String? frontShiny;

  const OfficialArtwork({this.frontDefault, this.frontShiny});

  factory OfficialArtwork.fromJson(Map<String, dynamic> json) =>
      _$OfficialArtworkFromJson(json);

  Map<String, dynamic> toJson() => _$OfficialArtworkToJson(this);
}
