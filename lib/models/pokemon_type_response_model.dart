import 'package:json_annotation/json_annotation.dart';
import 'pokemon_list_model.dart';

part 'pokemon_type_response_model.g.dart';

@JsonSerializable()
class PokemonTypeResponseModel {
  @JsonKey(name: 'name')
  final String? name;

  @JsonKey(name: 'pokemon')
  final List<PokemonTypeSlotItem>? pokemon;

  const PokemonTypeResponseModel({
    this.name,
    this.pokemon,
  });

  factory PokemonTypeResponseModel.fromJson(Map<String, dynamic> json) =>
      _$PokemonTypeResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$PokemonTypeResponseModelToJson(this);
}

@JsonSerializable()
class PokemonTypeSlotItem {
  @JsonKey(name: 'pokemon')
  final PokemonListItemModel? pokemon;

  @JsonKey(name: 'slot')
  final int? slot;

  const PokemonTypeSlotItem({
    this.pokemon,
    this.slot,
  });

  factory PokemonTypeSlotItem.fromJson(Map<String, dynamic> json) =>
      _$PokemonTypeSlotItemFromJson(json);

  Map<String, dynamic> toJson() => _$PokemonTypeSlotItemToJson(this);
}
