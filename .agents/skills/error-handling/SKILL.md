---
name: Error Handling
description: Global error handler, DataState error, dan AppMessenger
---
# Error Handling — PokéAtlas

## Layer 1 — GlobalErrorHandler (uncaught)

`lib/config/global_error_handler.dart`

Menangkap semua error yang tidak ditangani: Flutter errors, platform errors, Zone errors.
Sudah terintegrasi dengan Firebase Crashlytics di release mode.

```dart
// main.dart — wrap seluruh app
void main() {
  GlobalErrorHandler.init(() async {
    await setUpLocator();
    runApp(const MyApp());
  });
}
```

## Layer 2 — DataState (domain / repository)

`lib/utility/resource/data_state.dart`

```dart
// Repository selalu return DataState<T>
final result = await _repository.getData();

if (result is DataStateSuccess<MyModel>) {
  // pakai result.data
} else if (result is DataStateError) {
  // pakai result.error (String pesan)
  // result.statusCode (int? HTTP status)
}
```

## Layer 3 — Cubit (presentation)

```dart
// Di cubit: emit state yang bawa pesan error
if (result is DataStateError) {
  emit(XError(result.error ?? 'Terjadi kesalahan'));
}
```

## Layer 4 — UI (AppMessenger)

`lib/ui/shared_widget/app_messenger.dart`

```dart
// Di listener BlocConsumer
BlocConsumer<XCubit, XState>(
  listener: (context, state) {
    if (state is XError) {
      AppMessenger.show(
        context,
        message: state.message,
        icon: Icons.error_rounded,
      );
    }
  },
  ...
)

// Atau shortcut
AppMessenger.showSuccess(context, message: 'Pokemon berhasil dimuat!');
```

## Layer 5 — Manual report ke Crashlytics

```dart
try {
  // operasi berisiko di luar alur normal
} catch (e, stack) {
  GlobalErrorHandler.reportError(e, stack, reason: 'Pokemon evolution parsing');
}
```

## Pesan error di BaseRepository

Error messages sudah di-map di `mapDioExceptionToMessage()`:
- Timeout → pesan jaringan timeout
- 404 → Data tidak ditemukan
- 401 → Sesi tidak valid
- dst.

Jangan duplikat logic ini di Repository child atau Cubit.
