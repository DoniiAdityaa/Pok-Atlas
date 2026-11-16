import 'package:flutter/foundation.dart';

/// Parse JSON berat menggunakan Dart Isolate (`compute()`).
///
/// Mencegah jank di UI thread saat parsing list Pokemon besar.
///
/// ```dart
/// // Parse list (otomatis pakai isolate kalau >= 50 item)
/// final list = await JsonParser.parseList(
///   jsonList: response.data['results'],
///   fromJson: PokemonListItemModel.fromJson,
/// );
///
/// // Parse single object
/// final detail = JsonParser.parseObject(
///   json: response.data,
///   fromJson: PokemonDetailModel.fromJson,
/// );
/// ```
class JsonParser {
  JsonParser._();

  /// Minimum item sebelum pakai Isolate.
  /// List < threshold → parse di Main Thread (lebih cepat untuk data kecil).
  static const int minItemsForIsolate = 50;

  /// Parse JSON List ke `List<T>`.
  /// Otomatis pakai Isolate kalau [jsonList] >= [minItemsForIsolate] item.
  static Future<List<T>> parseList<T>({
    required List<dynamic> jsonList,
    required T Function(Map<String, dynamic> json) fromJson,
  }) async {
    if (jsonList.length < minItemsForIsolate) {
      return jsonList.map((e) => fromJson(e as Map<String, dynamic>)).toList();
    }

    return compute(
      _parseListInIsolate<T>,
      _ParseListPayload<T>(jsonList: jsonList, fromJson: fromJson),
    );
  }

  static List<T> _parseListInIsolate<T>(_ParseListPayload<T> payload) {
    return payload.jsonList
        .map((e) => payload.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Parse single JSON Map ke object `T`. Selalu di Main Thread.
  static T parseObject<T>({
    required Map<String, dynamic> json,
    required T Function(Map<String, dynamic> json) fromJson,
  }) {
    return fromJson(json);
  }

  /// Synchronous version — selalu di Main Thread.
  /// Gunakan kalau yakin data kecil atau sudah berada di dalam Isolate lain.
  static List<T> parseListSync<T>({
    required List<dynamic> jsonList,
    required T Function(Map<String, dynamic> json) fromJson,
  }) {
    return jsonList.map((e) => fromJson(e as Map<String, dynamic>)).toList();
  }
}

class _ParseListPayload<T> {
  final List<dynamic> jsonList;
  final T Function(Map<String, dynamic> json) fromJson;

  _ParseListPayload({required this.jsonList, required this.fromJson});
}
