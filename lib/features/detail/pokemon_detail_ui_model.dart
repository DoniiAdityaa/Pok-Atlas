import 'package:flutter/material.dart';
import '../../models/pokemon_detail_model.dart';
import '../../ui/color.dart';

// ============================================================================
// ENUM MODE TAMPILAN POKÉMON (ARTWORK 3D VS SHOWDOWN GIF)
// ============================================================================
enum PokemonDisplayMode {
  artwork, // 3D Official Artwork Ultra HD
  battleGif, // Live Battle Animated GIF
}

// ============================================================================
// EVOLUTION UI MODEL
// ============================================================================
class EvolutionUIModel {
  final int id;
  final String name;
  final String trigger;
  final String artworkUrl;
  final String gifUrl;

  const EvolutionUIModel({
    required this.id,
    required this.name,
    required this.trigger,
    required this.artworkUrl,
    required this.gifUrl,
  });

  String get formattedId => '#${id.toString().padLeft(4, '0')}';
}

typedef EvolutionDummy = EvolutionUIModel;

// ============================================================================
// MOVE UI MODEL
// ============================================================================
class MoveUIModel {
  final String name;
  final String type;
  final int power;
  final int accuracy;
  final int pp;
  final String description;

  const MoveUIModel({
    required this.name,
    required this.type,
    required this.power,
    required this.accuracy,
    required this.pp,
    this.description = 'A powerful signature move with high impact.',
  });
}

typedef MoveDummy = MoveUIModel;

// ============================================================================
// POKÉMON DETAIL UI PRESENTATION MODEL
// ============================================================================
class PokemonDetailUIModel {
  final int id;
  final String name;
  final String species;
  final List<String> types;
  final double height; // meters
  final double weight; // kg
  final int baseExp;
  final Map<String, String> versionDescriptions;
  final List<String> abilities;
  final String hiddenAbility;
  final double maleRate; // percentage
  final double femaleRate; // percentage
  final List<String> eggGroups;
  final Map<String, int> stats;
  final List<String> weaknesses;
  final List<String> resistances;
  final List<EvolutionUIModel> evolutions;
  final List<MoveUIModel> moves;
  final Color? customColor;

  const PokemonDetailUIModel({
    required this.id,
    required this.name,
    required this.species,
    required this.types,
    required this.height,
    required this.weight,
    required this.baseExp,
    required this.versionDescriptions,
    required this.abilities,
    required this.hiddenAbility,
    required this.maleRate,
    required this.femaleRate,
    required this.eggGroups,
    required this.stats,
    required this.weaknesses,
    required this.resistances,
    required this.evolutions,
    required this.moves,
    this.customColor,
  });

  String get formattedId => '#${id.toString().padLeft(4, '0')}';

  Color get primaryColor {
    if (customColor != null) return customColor!;
    if (types.isNotEmpty && types.first != 'Normal') {
      return PokemonTypeColors.getColor(types.first);
    }
    return PokemonTypeColors.getColorById(id);
  }

  int get totalStats => stats.values.fold(0, (sum, val) => sum + val);

  String get description => versionDescriptions.values.isNotEmpty
      ? versionDescriptions.values.first
      : '';

  // URL 3D Official Artwork
  String get artworkUrl =>
      'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png';

  String get shinyArtworkUrl =>
      'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/shiny/$id.png';

  // URL Live Animated Battle GIF (Showdown)
  String get battleGifUrl =>
      'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/showdown/$id.gif';

  String get shinyBattleGifUrl =>
      'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/showdown/shiny/$id.gif';

  // URL Suara Auman Resmi Pokémon (.mp3 didukung native oleh iOS AVPlayer & Android MediaPlayer)
  String get cryMp3Url {
    final clean = name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
    return 'https://play.pokemonshowdown.com/audio/cries/$clean.mp3';
  }

  // URL Suara Auman PokéAPI (format .ogg)
  String get cryOggUrl =>
      'https://raw.githubusercontent.com/PokeAPI/cries/main/cries/pokemon/latest/$id.ogg';

  String get cryUrl => cryMp3Url;

  /// Menyalin data saat berpindah antar tahap evolusi dengan mempertahankan seluruh daftar evolusi
  /// sehingga UI evolution chain tidak berkedip, tidak kolaps, dan tidak perlu re-render ulang
  PokemonDetailUIModel copyWithEvolutionTarget({
    required int id,
    required String name,
    Color? accentColor,
  }) {
    final effectiveTypes = PokemonTypeColors.getTypesById(id);
    return PokemonDetailUIModel(
      id: id,
      name: name,
      species: '$name Pokémon',
      types: effectiveTypes,
      height: height,
      weight: weight,
      baseExp: baseExp,
      versionDescriptions: versionDescriptions,
      abilities: abilities,
      hiddenAbility: hiddenAbility,
      maleRate: maleRate,
      femaleRate: femaleRate,
      eggGroups: eggGroups,
      stats: stats,
      weaknesses: calculateWeaknesses(effectiveTypes),
      resistances: resistances,
      evolutions: evolutions, // Mempertahankan seluruh pohon evolusi tanpa reset!
      moves: moves,
      customColor: accentColor ?? PokemonTypeColors.getColorById(id),
    );
  }

  /// Factory untuk membuat data placeholder instan yang sesuai dengan Pokémon yang dipilih
  /// sehingga tidak muncul karakter dummy (Charizard) saat transisi awal membuka halaman
  factory PokemonDetailUIModel.placeholder({
    required int id,
    String? name,
    List<String>? types,
    Color? customColor,
  }) {
    final effectiveName =
        (name != null && name.isNotEmpty) ? name : 'Pokémon';
    final effectiveTypes = (types != null && types.isNotEmpty)
        ? types
        : PokemonTypeColors.getTypesById(id);

    return PokemonDetailUIModel(
      id: id,
      name: effectiveName,
      species: '$effectiveName Pokémon',
      types: effectiveTypes,
      height: 1.0,
      weight: 20.0,
      baseExp: 100,
      versionDescriptions: {
        'Version 1':
            'Fetching Pokédex data for $effectiveName from PokéAPI database...',
        'Version 2':
            'Analyzing elemental stats, evolution line, and battle techniques...',
      },
      abilities: const ['Synchronizing...'],
      hiddenAbility: 'Synchronizing...',
      maleRate: 50.0,
      femaleRate: 50.0,
      eggGroups: const ['Field'],
      stats: const {
        'HP': 0,
        'Attack': 0,
        'Defense': 0,
        'Sp. Atk': 0,
        'Sp. Def': 0,
        'Speed': 0,
      },
      weaknesses: calculateWeaknesses(effectiveTypes),
      resistances: const [],
      evolutions: [
        EvolutionUIModel(
          id: id,
          name: effectiveName,
          trigger: 'Base Form',
          artworkUrl:
              'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png',
          gifUrl:
              'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/showdown/$id.gif',
        ),
      ],
      moves: const [
        MoveUIModel(
          name: 'Synchronizing Moves...',
          type: 'Normal',
          power: 0,
          accuracy: 100,
          pp: 10,
          description:
              'Synchronizing available move sets from the PokéAPI database...',
        ),
      ],
      customColor: customColor,
    );
  }

  /// Factory untuk mengonversi data live API [PokemonDetailModel] ke model tampilan detail
  factory PokemonDetailUIModel.fromApiModel(
    PokemonDetailModel model, {
    List<EvolutionUIModel>? evolutions,
    String? speciesDescription,
    String? speciesGenera,
    double? maleRate,
    double? femaleRate,
    List<String>? eggGroups,
  }) {
    final pokeId = model.id ?? 1;
    final pokeName =
        model.capitalizedName.isNotEmpty ? model.capitalizedName : 'Pokémon';
    final pokeTypes = model.typeNames.isNotEmpty ? model.typeNames : ['Normal'];
    final computedWeaknesses = calculateWeaknesses(pokeTypes);

    final effectiveEvolutions = (evolutions != null && evolutions.isNotEmpty)
        ? evolutions
        : [
            EvolutionUIModel(
              id: pokeId,
              name: pokeName,
              trigger: 'Base Form',
              artworkUrl: model.officialImageUrl,
              gifUrl:
                  'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/showdown/$pokeId.gif',
            ),
          ];

    return PokemonDetailUIModel(
      id: pokeId,
      name: pokeName,
      species: speciesGenera ?? '$pokeName Pokémon',
      types: pokeTypes,
      height: model.heightInMeters > 0 ? model.heightInMeters : 1.0,
      weight: model.weightInKg > 0 ? model.weightInKg : 20.0,
      baseExp: ((model.hp +
              model.attack +
              model.defense +
              model.specialAttack +
              model.specialDefense +
              model.speed) ~/
          2.5),
      versionDescriptions: {
        'Version 1': speciesDescription ??
            'A spirited $pokeName observed in natural habitats, possessing unique elemental abilities.',
        'Version 2':
            'Travels widely across various regions, adapting swiftly and demonstrating formidable power in battle.',
      },
      abilities: const ['Pressure', 'Inner Focus'],
      hiddenAbility: 'Super Luck',
      maleRate: maleRate ?? 50.0,
      femaleRate: femaleRate ?? 50.0,
      eggGroups: eggGroups ?? const ['Field', 'Monster'],
      stats: {
        'HP': model.hp,
        'Attack': model.attack,
        'Defense': model.defense,
        'Sp. Atk': model.specialAttack,
        'Sp. Def': model.specialDefense,
        'Speed': model.speed,
      },
      weaknesses: computedWeaknesses,
      resistances: const ['Normal'],
      evolutions: effectiveEvolutions,
      moves: [
        const MoveUIModel(
          name: 'Quick Attack',
          type: 'Normal',
          power: 40,
          accuracy: 100,
          pp: 30,
          description: 'An almost invisibly fast attack that strikes first.',
        ),
        MoveUIModel(
          name: '${pokeTypes.first} Strike',
          type: pokeTypes.first,
          power: 85,
          accuracy: 95,
          pp: 15,
          description:
              'A powerful elemental blast charged with inner stamina.',
        ),
      ],
    );
  }

  /// Menghitung kelemahan Pokémon secara otomatis berdasarkan tipenya
  static List<String> calculateWeaknesses(List<String> types) {
    const Map<String, List<String>> typeWeaknessMap = {
      'Fire': ['Water', 'Ground', 'Rock'],
      'Water': ['Electric', 'Grass'],
      'Grass': ['Fire', 'Ice', 'Poison', 'Flying', 'Bug'],
      'Electric': ['Ground'],
      'Psychic': ['Bug', 'Ghost', 'Dark'],
      'Ice': ['Fire', 'Fighting', 'Rock', 'Steel'],
      'Dragon': ['Ice', 'Dragon', 'Fairy'],
      'Normal': ['Fighting'],
      'Ghost': ['Ghost', 'Dark'],
      'Poison': ['Ground', 'Psychic'],
      'Fighting': ['Flying', 'Psychic', 'Fairy'],
      'Rock': ['Water', 'Grass', 'Fighting', 'Ground', 'Steel'],
      'Ground': ['Water', 'Grass', 'Ice'],
      'Flying': ['Electric', 'Ice', 'Rock'],
      'Bug': ['Fire', 'Flying', 'Rock'],
      'Steel': ['Fire', 'Fighting', 'Ground'],
      'Dark': ['Fighting', 'Bug', 'Fairy'],
      'Fairy': ['Poison', 'Steel'],
    };

    final Set<String> weaknesses = {};
    for (final t in types) {
      if (typeWeaknessMap.containsKey(t)) {
        weaknesses.addAll(typeWeaknessMap[t]!);
      }
    }
    return weaknesses.isEmpty ? ['Water', 'Rock'] : weaknesses.take(4).toList();
  }
}

typedef PokemonDetailDummy = PokemonDetailUIModel;

// ============================================================================
// POKÉMON SPECIES & EVOLUTION CHAIN DATA
// ============================================================================
class PokemonSpeciesData {
  final List<EvolutionUIModel> evolutions;
  final String? description;
  final String? genera;
  final double? maleRate;
  final double? femaleRate;
  final List<String>? eggGroups;

  const PokemonSpeciesData({
    required this.evolutions,
    this.description,
    this.genera,
    this.maleRate,
    this.femaleRate,
    this.eggGroups,
  });
}
