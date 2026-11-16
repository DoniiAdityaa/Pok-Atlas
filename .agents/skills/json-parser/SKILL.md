---
name: JsonParser
description: Parse JSON besar di Isolate agar UI tidak jank
---
# JsonParser — PokéAtlas

`lib/utility/json_parser.dart`

Parse JSON list besar menggunakan Dart Isolate (`compute()`) agar tidak memblokir UI thread.

## Kapan Pakai

| Ukuran data | Gunakan |
|---|---|
| < 50 item | `parseListSync()` atau `parseList()` (otomatis pakai main thread) |
| >= 50 item | `parseList()` — otomatis pakai Isolate |
| Single object | `parseObject()` |
| Sudah dalam Isolate lain | `parseListSync()` |

## Contoh

```dart
import 'package:pokeatlas/utility/json_parser.dart';

// Parse list pokemon (otomatis isolate kalau >= 50)
final pokemons = await JsonParser.parseList(
  jsonList: response['results'] as List,
  fromJson: PokemonListItemModel.fromJson,
);

// Parse single object
final detail = JsonParser.parseObject(
  json: response as Map<String, dynamic>,
  fromJson: PokemonDetailModel.fromJson,
);

// Sync (kalau yakin data kecil)
final types = JsonParser.parseListSync(
  jsonList: data['types'] as List,
  fromJson: PokemonTypeSlotItem.fromJson,
);
```

## Threshold

```dart
static const int minItemsForIsolate = 50;
```

Ubah nilai ini kalau perlu tuning performa.
