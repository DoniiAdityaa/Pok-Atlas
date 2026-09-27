// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pokemon_detail_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PokemonDetailModel _$PokemonDetailModelFromJson(Map<String, dynamic> json) =>
    PokemonDetailModel(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String?,
      height: (json['height'] as num?)?.toInt(),
      weight: (json['weight'] as num?)?.toInt(),
      types: (json['types'] as List<dynamic>?)
          ?.map((e) => PokemonTypeSlot.fromJson(e as Map<String, dynamic>))
          .toList(),
      stats: (json['stats'] as List<dynamic>?)
          ?.map((e) => PokemonStatSlot.fromJson(e as Map<String, dynamic>))
          .toList(),
      sprites: json['sprites'] == null
          ? null
          : PokemonSprites.fromJson(json['sprites'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$PokemonDetailModelToJson(PokemonDetailModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'height': instance.height,
      'weight': instance.weight,
      'types': instance.types,
      'stats': instance.stats,
      'sprites': instance.sprites,
    };

PokemonTypeSlot _$PokemonTypeSlotFromJson(Map<String, dynamic> json) =>
    PokemonTypeSlot(
      slot: (json['slot'] as num?)?.toInt(),
      type: json['type'] == null
          ? null
          : NamedApiResource.fromJson(json['type'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$PokemonTypeSlotToJson(PokemonTypeSlot instance) =>
    <String, dynamic>{
      'slot': instance.slot,
      'type': instance.type,
    };

PokemonStatSlot _$PokemonStatSlotFromJson(Map<String, dynamic> json) =>
    PokemonStatSlot(
      baseStat: (json['base_stat'] as num?)?.toInt(),
      effort: (json['effort'] as num?)?.toInt(),
      stat: json['stat'] == null
          ? null
          : NamedApiResource.fromJson(json['stat'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$PokemonStatSlotToJson(PokemonStatSlot instance) =>
    <String, dynamic>{
      'base_stat': instance.baseStat,
      'effort': instance.effort,
      'stat': instance.stat,
    };

NamedApiResource _$NamedApiResourceFromJson(Map<String, dynamic> json) =>
    NamedApiResource(
      name: json['name'] as String?,
      url: json['url'] as String?,
    );

Map<String, dynamic> _$NamedApiResourceToJson(NamedApiResource instance) =>
    <String, dynamic>{
      'name': instance.name,
      'url': instance.url,
    };

PokemonSprites _$PokemonSpritesFromJson(Map<String, dynamic> json) =>
    PokemonSprites(
      frontDefault: json['front_default'] as String?,
      other: json['other'] == null
          ? null
          : PokemonOtherSprites.fromJson(json['other'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$PokemonSpritesToJson(PokemonSprites instance) =>
    <String, dynamic>{
      'front_default': instance.frontDefault,
      'other': instance.other,
    };

PokemonOtherSprites _$PokemonOtherSpritesFromJson(Map<String, dynamic> json) =>
    PokemonOtherSprites(
      officialArtwork: json['official-artwork'] == null
          ? null
          : OfficialArtwork.fromJson(
              json['official-artwork'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$PokemonOtherSpritesToJson(
        PokemonOtherSprites instance) =>
    <String, dynamic>{
      'official-artwork': instance.officialArtwork,
    };

OfficialArtwork _$OfficialArtworkFromJson(Map<String, dynamic> json) =>
    OfficialArtwork(
      frontDefault: json['front_default'] as String?,
      frontShiny: json['front_shiny'] as String?,
    );

Map<String, dynamic> _$OfficialArtworkToJson(OfficialArtwork instance) =>
    <String, dynamic>{
      'front_default': instance.frontDefault,
      'front_shiny': instance.frontShiny,
    };
