// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pokemon_type_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PokemonTypeResponseModel _$PokemonTypeResponseModelFromJson(
        Map<String, dynamic> json) =>
    PokemonTypeResponseModel(
      name: json['name'] as String?,
      pokemon: (json['pokemon'] as List<dynamic>?)
          ?.map((e) => PokemonTypeSlotItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$PokemonTypeResponseModelToJson(
        PokemonTypeResponseModel instance) =>
    <String, dynamic>{
      'name': instance.name,
      'pokemon': instance.pokemon,
    };

PokemonTypeSlotItem _$PokemonTypeSlotItemFromJson(Map<String, dynamic> json) =>
    PokemonTypeSlotItem(
      pokemon: json['pokemon'] == null
          ? null
          : PokemonListItemModel.fromJson(
              json['pokemon'] as Map<String, dynamic>),
      slot: (json['slot'] as num?)?.toInt(),
    );

Map<String, dynamic> _$PokemonTypeSlotItemToJson(
        PokemonTypeSlotItem instance) =>
    <String, dynamic>{
      'pokemon': instance.pokemon,
      'slot': instance.slot,
    };
