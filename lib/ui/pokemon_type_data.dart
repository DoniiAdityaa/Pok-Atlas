import 'package:flutter/material.dart';
import 'color.dart';

/// Representasi data elemen tipe Pokémon untuk filter dan UI badge
class PokemonTypeItem {
  final String name;
  final String? iconAsset;
  final IconData? fallbackIcon;
  final Color color;

  const PokemonTypeItem({
    required this.name,
    this.iconAsset,
    this.fallbackIcon,
    required this.color,
  });
}

/// 18 Master data elemen resmi Pokémon beserta ikon SVG dan warna aksennya
const List<PokemonTypeItem> pokemonTypeList = [
  PokemonTypeItem(
    name: 'All',
    fallbackIcon: Icons.catching_pokemon,
    color: primaryColor,
  ),
  PokemonTypeItem(
    name: 'Fire',
    iconAsset: 'assets/images/element/fire.svg',
    color: PokemonTypeColors.fire,
  ),
  PokemonTypeItem(
    name: 'Water',
    iconAsset: 'assets/images/element/water.svg',
    color: PokemonTypeColors.water,
  ),
  PokemonTypeItem(
    name: 'Grass',
    iconAsset: 'assets/images/element/grass.svg',
    color: PokemonTypeColors.grass,
  ),
  PokemonTypeItem(
    name: 'Electric',
    iconAsset: 'assets/images/element/electric.svg',
    color: PokemonTypeColors.electric,
  ),
  PokemonTypeItem(
    name: 'Ice',
    iconAsset: 'assets/images/element/ice.svg',
    color: PokemonTypeColors.ice,
  ),
  PokemonTypeItem(
    name: 'Fighting',
    iconAsset: 'assets/images/element/fighting.svg',
    color: PokemonTypeColors.fighting,
  ),
  PokemonTypeItem(
    name: 'Poison',
    iconAsset: 'assets/images/element/poison.svg',
    color: PokemonTypeColors.poison,
  ),
  PokemonTypeItem(
    name: 'Ground',
    iconAsset: 'assets/images/element/ground.svg',
    color: PokemonTypeColors.ground,
  ),
  PokemonTypeItem(
    name: 'Flying',
    iconAsset: 'assets/images/element/flying.svg',
    color: PokemonTypeColors.flying,
  ),
  PokemonTypeItem(
    name: 'Psychic',
    iconAsset: 'assets/images/element/psychic.svg',
    color: PokemonTypeColors.psychic,
  ),
  PokemonTypeItem(
    name: 'Bug',
    iconAsset: 'assets/images/element/bug.svg',
    color: PokemonTypeColors.bug,
  ),
  PokemonTypeItem(
    name: 'Rock',
    iconAsset: 'assets/images/element/rock.svg',
    color: PokemonTypeColors.rock,
  ),
  PokemonTypeItem(
    name: 'Ghost',
    iconAsset: 'assets/images/element/ghost.svg',
    color: PokemonTypeColors.ghost,
  ),
  PokemonTypeItem(
    name: 'Dragon',
    iconAsset: 'assets/images/element/dragon.svg',
    color: PokemonTypeColors.dragon,
  ),
  PokemonTypeItem(
    name: 'Steel',
    iconAsset: 'assets/images/element/steel.svg',
    color: PokemonTypeColors.steel,
  ),
  PokemonTypeItem(
    name: 'Fairy',
    iconAsset: 'assets/images/element/fairy.svg',
    color: PokemonTypeColors.fairy,
  ),
  PokemonTypeItem(
    name: 'Dark',
    iconAsset: 'assets/images/element/dark.svg',
    color: PokemonTypeColors.dark,
  ),
  PokemonTypeItem(
    name: 'Normal',
    iconAsset: 'assets/images/element/normal.svg',
    color: PokemonTypeColors.normal,
  ),
];
