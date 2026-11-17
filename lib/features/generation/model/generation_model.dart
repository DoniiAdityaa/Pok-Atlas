import 'dart:ui';

class GenerationStarter {
  final int id;
  final String name;
  final String type;

  const GenerationStarter({
    required this.id,
    required this.name,
    required this.type,
  });

  String get imageUrl =>
      'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png';
}

class GenerationModel {
  final int id;
  final String romanNumeral;
  final String regionName;
  final String year;
  final String games;
  final String idRange;
  final int startId;
  final int endId;
  final int totalPokemon;
  final String tagline;
  final String realWorldInspiration;
  final List<int> legendaryIds;
  final List<Color> gradientColors; // Soft pastel candy gradient
  final Color accentColor; // Vibrant signature candy accent
  final String groupArtworkAsset; // Ilustrasi lucu trio starter Pokémon
  final String mapAsset; // Peta resmi region (assets/images/maps/)
  final List<GenerationStarter> starters;

  const GenerationModel({
    required this.id,
    required this.romanNumeral,
    required this.regionName,
    required this.year,
    required this.games,
    required this.idRange,
    required this.startId,
    required this.endId,
    required this.totalPokemon,
    required this.tagline,
    required this.realWorldInspiration,
    required this.legendaryIds,
    required this.gradientColors,
    required this.accentColor,
    required this.groupArtworkAsset,
    required this.mapAsset,
    required this.starters,
  });
}

class GenerationData {
  static const List<GenerationModel> allGenerations = [
    // 1. Kanto (Soft Blush Candy & Warm Coral)
    GenerationModel(
      id: 1,
      romanNumeral: 'I',
      regionName: 'Kanto',
      year: '1996',
      games: 'Red, Blue & Yellow',
      idRange: '#0001 - #0151',
      startId: 1,
      endId: 151,
      totalPokemon: 151,
      tagline: 'The timeless classic era where every Pokémon journey began.',
      realWorldInspiration: 'Kantō Region, Japan',
      legendaryIds: [144, 145, 146, 150, 151],
      gradientColors: [
        Color(0xFFFFF0F0), // Soft Strawberry Sorbet
        Color(0xFFFFDEDE), // Delicate Blush Peach
      ],
      accentColor: Color(0xFFFF4B5C), // Warm Coral Red
      groupArtworkAsset: 'assets/images/generations/gen1.png',
      mapAsset: 'assets/images/maps/kanto.png',
      starters: [
        GenerationStarter(id: 1, name: 'Bulbasaur', type: 'Grass'),
        GenerationStarter(id: 4, name: 'Charmander', type: 'Fire'),
        GenerationStarter(id: 7, name: 'Squirtle', type: 'Water'),
      ],
    ),

    // 2. Johto (Honey Butter Cream & Warm Amber)
    GenerationModel(
      id: 2,
      romanNumeral: 'II',
      regionName: 'Johto',
      year: '1999',
      games: 'Gold, Silver & Crystal',
      idRange: '#0152 - #0251',
      startId: 152,
      endId: 251,
      totalPokemon: 100,
      tagline: 'Ancient legends, sacred towers, and roaming mythical beasts.',
      realWorldInspiration: 'Kansai Region, Japan',
      legendaryIds: [243, 244, 245, 249, 250, 251],
      gradientColors: [
        Color(0xFFFFFBEB), // Honey Cream
        Color(0xFFFEF3C7), // Golden Vanilla
      ],
      accentColor: Color(0xFFD97706), // Warm Honey Amber
      groupArtworkAsset: 'assets/images/generations/gen2.png',
      mapAsset: 'assets/images/maps/johto.png',
      starters: [
        GenerationStarter(id: 152, name: 'Chikorita', type: 'Grass'),
        GenerationStarter(id: 155, name: 'Cyndaquil', type: 'Fire'),
        GenerationStarter(id: 158, name: 'Totodile', type: 'Water'),
      ],
    ),

    // 3. Hoenn (Tropical Mint Gelato & Vivid Emerald)
    GenerationModel(
      id: 3,
      romanNumeral: 'III',
      regionName: 'Hoenn',
      year: '2002',
      games: 'Ruby, Sapphire & Emerald',
      idRange: '#0252 - #0386',
      startId: 252,
      endId: 386,
      totalPokemon: 135,
      tagline: 'A tropical wonderland forged by primal land, sea, and sky.',
      realWorldInspiration: 'Kyushu Island, Japan',
      legendaryIds: [377, 378, 379, 380, 381, 382, 383, 384, 385, 386],
      gradientColors: [
        Color(0xFFECFDF5), // Soft Mint
        Color(0xFFD1FAE5), // Fresh Seafoam
      ],
      accentColor: Color(0xFF059669), // Vivid Emerald Green
      groupArtworkAsset: 'assets/images/generations/gen3.png',
      mapAsset: 'assets/images/maps/hoenn.png',
      starters: [
        GenerationStarter(id: 252, name: 'Treecko', type: 'Grass'),
        GenerationStarter(id: 255, name: 'Torchic', type: 'Fire'),
        GenerationStarter(id: 258, name: 'Mudkip', type: 'Water'),
      ],
    ),

    // 4. Sinnoh (Cosmic Periwinkle Mist & Indigo)
    GenerationModel(
      id: 4,
      romanNumeral: 'IV',
      regionName: 'Sinnoh',
      year: '2006',
      games: 'Diamond, Pearl & Platinum',
      idRange: '#0387 - #0493',
      startId: 387,
      endId: 493,
      totalPokemon: 107,
      tagline: 'A mystical snowy land rooted in the creation of space & time.',
      realWorldInspiration: 'Hokkaido, Japan',
      legendaryIds: [
        480,
        481,
        482,
        483,
        484,
        485,
        486,
        487,
        488,
        491,
        492,
        493
      ],
      gradientColors: [
        Color(0xFFEEF2FF), // Periwinkle Mist
        Color(0xFFE0E7FF), // Soft Iris Tint
      ],
      accentColor: Color(0xFF4F46E5), // Cosmic Indigo
      groupArtworkAsset: 'assets/images/generations/gen4.png',
      mapAsset: 'assets/images/maps/sinnoh.png',
      starters: [
        GenerationStarter(id: 387, name: 'Turtwig', type: 'Grass'),
        GenerationStarter(id: 390, name: 'Chimchar', type: 'Fire'),
        GenerationStarter(id: 393, name: 'Piplup', type: 'Water'),
      ],
    ),

    // 5. Unova (Modern Slate Pearl & Cool Steel)
    GenerationModel(
      id: 5,
      romanNumeral: 'V',
      regionName: 'Unova',
      year: '2010',
      games: 'Black & White',
      idRange: '#0494 - #0649',
      startId: 494,
      endId: 649,
      totalPokemon: 156,
      tagline: 'A bustling metropolis shaped by opposing ideals and truth.',
      realWorldInspiration: 'New York City, USA',
      legendaryIds: [
        494,
        638,
        639,
        640,
        641,
        642,
        643,
        644,
        645,
        646,
        647,
        648,
        649
      ],
      gradientColors: [
        Color(0xFFF1F5F9), // Crisp Pearl Slate
        Color(0xFFE2E8F0), // Cool Steel Mist
      ],
      accentColor: Color(0xFF475569), // Modern Slate
      groupArtworkAsset: 'assets/images/generations/gen5.png',
      mapAsset: 'assets/images/maps/unova.png',
      starters: [
        GenerationStarter(id: 494, name: 'Snivy', type: 'Grass'),
        GenerationStarter(id: 497, name: 'Tepig', type: 'Fire'),
        GenerationStarter(id: 501, name: 'Oshawott', type: 'Water'),
      ],
    ),

    // 6. Kalos (Azure Macaron & Royal Blue)
    GenerationModel(
      id: 6,
      romanNumeral: 'VI',
      regionName: 'Kalos',
      year: '2013',
      games: 'X & Y',
      idRange: '#0650 - #0721',
      startId: 650,
      endId: 721,
      totalPokemon: 72,
      tagline: 'The star-shaped land of beauty, romance, and Mega Evolution.',
      realWorldInspiration: 'Metropolitan France',
      legendaryIds: [716, 717, 718, 719, 720, 721],
      gradientColors: [
        Color(0xFFEFF6FF), // Baby Azure
        Color(0xFFDBEAFE), // Sky Tint
      ],
      accentColor: Color(0xFF2563EB), // French Royal Blue
      groupArtworkAsset: 'assets/images/generations/gen6.png',
      mapAsset: 'assets/images/maps/kalos.png',
      starters: [
        GenerationStarter(id: 650, name: 'Chespin', type: 'Grass'),
        GenerationStarter(id: 653, name: 'Fennekin', type: 'Fire'),
        GenerationStarter(id: 656, name: 'Froakie', type: 'Water'),
      ],
    ),

    // 7. Alola (Tropical Mango & Solar Tangerine)
    GenerationModel(
      id: 7,
      romanNumeral: 'VII',
      regionName: 'Alola',
      year: '2016',
      games: 'Sun & Moon',
      idRange: '#0722 - #0809',
      startId: 722,
      endId: 809,
      totalPokemon: 88,
      tagline: 'A tropical archipelago celebrated for island trials & Z-Moves.',
      realWorldInspiration: 'Hawaiian Archipelago, USA',
      legendaryIds: [
        785,
        786,
        787,
        788,
        789,
        790,
        791,
        792,
        800,
        801,
        802,
        807
      ],
      gradientColors: [
        Color(0xFFFFF7ED), // Warm Peach Gelato
        Color(0xFFFFEDD5), // Tropical Mango Cream
      ],
      accentColor: Color(0xFFEA580C), // Solar Tangerine
      groupArtworkAsset: 'assets/images/generations/gen7.png',
      mapAsset: 'assets/images/maps/alola.png',
      starters: [
        GenerationStarter(id: 722, name: 'Rowlet', type: 'Grass'),
        GenerationStarter(id: 725, name: 'Litten', type: 'Fire'),
        GenerationStarter(id: 728, name: 'Popplio', type: 'Water'),
      ],
    ),

    // 8. Galar (Ocean Aqua Splash & Cyan)
    GenerationModel(
      id: 8,
      romanNumeral: 'VIII',
      regionName: 'Galar',
      year: '2019',
      games: 'Sword & Shield',
      idRange: '#0810 - #0905',
      startId: 810,
      endId: 905,
      totalPokemon: 96,
      tagline: 'Vast wild areas and colossal Dynamax stadium league battles.',
      realWorldInspiration: 'Great Britain, UK',
      legendaryIds: [888, 889, 890, 891, 892, 894, 895, 896, 897, 898],
      gradientColors: [
        Color(0xFFECFEFF), // Soft Ice Aqua
        Color(0xFFCFFAFE), // Oceanic Cyan Tint
      ],
      accentColor: Color(0xFF0284C7), // Deep Aqua
      groupArtworkAsset: 'assets/images/generations/gen8.png',
      mapAsset:
          'assets/images/maps/hoenn.png', // Galar belum tersedia, fallback Hoenn
      starters: [
        GenerationStarter(id: 810, name: 'Grookey', type: 'Grass'),
        GenerationStarter(id: 813, name: 'Scorbunny', type: 'Fire'),
        GenerationStarter(id: 816, name: 'Sobble', type: 'Water'),
      ],
    ),

    // 9. Paldea (Berry Violet Sorbet & Magenta)
    GenerationModel(
      id: 9,
      romanNumeral: 'IX',
      regionName: 'Paldea',
      year: '2022',
      games: 'Scarlet & Violet',
      idRange: '#0906 - #1025',
      startId: 906,
      endId: 1025,
      totalPokemon: 120,
      tagline:
          'An open world realm illuminated by the sparkling Terastal phenomenon.',
      realWorldInspiration: 'Iberian Peninsula (Spain & Portugal)',
      legendaryIds: [
        1001,
        1002,
        1003,
        1004,
        1007,
        1008,
        1014,
        1015,
        1016,
        1017,
        1024,
        1025
      ],
      gradientColors: [
        Color(0xFFFDF4FF), // Berry Frost
        Color(0xFFFAE8FF), // Violet Petal
      ],
      accentColor: Color(0xFFC026D3), // Terastal Berry Magenta
      groupArtworkAsset: 'assets/images/generations/gen9.png',
      mapAsset: 'assets/images/maps/paldea.png',
      starters: [
        GenerationStarter(id: 906, name: 'Sprigatito', type: 'Grass'),
        GenerationStarter(id: 909, name: 'Fuecoco', type: 'Fire'),
        GenerationStarter(id: 912, name: 'Quaxly', type: 'Water'),
      ],
    ),
  ];
}
