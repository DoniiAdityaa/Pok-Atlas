// To parse this JSON data, do
//
//     final levelModel = levelModelFromJson(jsonString);

import 'package:json_annotation/json_annotation.dart';

part 'level_model.g.dart';

@JsonSerializable()
class LevelModel {
  @JsonKey(name: "id")
  String? id;
  @JsonKey(name: "nama")
  String? nama;
  @JsonKey(name: "created_by")
  String? createdBy;
  @JsonKey(name: "created_at")
  DateTime? createdAt;
  @JsonKey(name: "updated_at")
  DateTime? updatedAt;

  LevelModel({
    this.id,
    this.nama,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
  });

  factory LevelModel.fromJson(Map<String, dynamic> json) => _$LevelModelFromJson(json);

  Map<String, dynamic> toJson() => _$LevelModelToJson(this);
}
