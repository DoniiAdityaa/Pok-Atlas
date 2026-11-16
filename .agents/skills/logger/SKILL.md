---
name: Logger
description: Logging terpusat dengan LoggerHelper
---
# Logger — PokéAtlas

`lib/utility/logger.dart`

Logger terpusat berbasis package `logger`. Output hanya muncul di **debug mode** (DevelopmentFilter).
Gunakan ini sebagai ganti `print()` di mana pun — `print()` lolos ke release build dan melanggar lint.

## Methods

```dart
LoggerHelper.d('Debug info');              // 🐛 Debug
LoggerHelper.i('Pokemon list loaded');     // ℹ️ Info
LoggerHelper.w('Cache miss for id=$id');  // ⚠️ Warning
LoggerHelper.e('Fetch failed', error, stackTrace);  // 🚨 Error + stack
LoggerHelper.t('Trace detail');           // 📝 Trace
LoggerHelper.f('Fatal condition');        // 🤷 Fatal
```

## Contoh Penggunaan

```dart
import 'package:pokeatlas/utility/logger.dart';

class PokemonDetailRepository extends BaseRepository {
  Future<DataState<PokemonDetailModel>> getPokemonDetail(int id) async {
    LoggerHelper.d('Fetching detail for id=$id');
    final result = await getStateOf(...);
    if (result is DataStateError) {
      LoggerHelper.w('Detail fetch failed: ${result.error}');
    }
    return result;
  }
}
```

## Rules

- **JANGAN** pakai `print()` — trigger lint `avoid_print` dan lolos ke production
- **JANGAN** pakai `debugPrint()` — masih bisa lolos ke release
- Semua logging lewat `LoggerHelper`
- Level error wajib sertakan `error` dan `stackTrace` untuk Crashlytics compatibility
