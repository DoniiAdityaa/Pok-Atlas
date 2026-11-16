# Arsitektur PokéAtlas

PokéAtlas menggunakan **Layered Architecture** terinspirasi dari Clean Architecture dengan **BLoC/Cubit** sebagai state management dan **get_it** sebagai Service Locator.

---

## 1. Layer Overview

```
lib/
├── config/              ← Service Locator, Environment, Constants, Error Handler
├── data/api/            ← Retrofit ApiService (HTTP client interface)
├── repository/          ← Data abstraction + caching + DataState wrapping
├── features/            ← Feature modules (UI + Cubit + State)
├── models/              ← JSON Serializable models
├── ui/                  ← Design system (Theme, Color, Typography, Shared Widgets)
└── utility/             ← Helpers (Logger, JsonParser, Responsive, Resource)
```

### Dependency Rules

- `features/` (UI) HANYA boleh panggil `Cubit`
- `Cubit` HANYA boleh panggil `Repository`
- `Repository` HANYA boleh panggil `ApiService` (Retrofit)
- `ApiService` panggil `Dio`
- Tidak ada direct call dari UI ke Repository atau ApiService

---

## 2. Alur Data Lengkap

```
User Action (Tap button / Pull to refresh)
  ↓
Cubit.someMethod()
  ↓ emit(XLoading())
Repository.getData()
  ↓
BaseRepository.getStateOf()
  ↓
ApiService.getEndpoint()        [Dio HTTP call]
  ↓ (200 OK)
DataStateSuccess(data)
  ↓
Cubit:
  if (result is DataStateSuccess) emit(XLoaded(result.data!))
  if (result is DataStateError)   emit(XError(result.error!))
  ↓
BlocBuilder rebuild UI:
  switch (state) {
    XLoading() => LoadingWidget(),
    XLoaded(:final data) => ContentWidget(data),
    XError(:final message) => ErrorWidget(message),
  }
```

---

## 3. Komponen Utama

### State Management (`flutter_bloc`)
- Pola: **Cubit** (bukan full Bloc event-driven)
- State: `sealed class` + `Equatable`
- Binding UI: `BlocBuilder` (rebuild) atau `BlocConsumer` (rebuild + side-effect)

### Service Locator (`get_it`)
- Setup di `lib/config/service_locator.dart`
- Singleton untuk `Dio`, `ApiService`, dan `Repositories`
- Factory untuk `Cubit` (instance baru setiap dipanggil)

### Networking (`dio` + `retrofit`)
- `ApiService` sebagai abstract class dengan decorator `@GET`, `@POST`, `@Path`, `@Query`
- Auto-generate via `build_runner`
- Base URL dari `.env` via `Envied`

### Error Handling
- Terpusat di `BaseRepository.getStateOf()`
- Mapping status HTTP ke pesan bahasa Indonesia
- Uncaught error ditangani `GlobalErrorHandler` (terintegrasi Crashlytics)

---

## 4. Design System (`lib/ui/`)

| File | Isi |
|---|---|
| `theme.dart` | `AppTheme.light` dan `AppTheme.dark` |
| `color.dart` | Palette warna PokéAtlas + `PokemonTypeColors` (18 type Pokémon) |
| `typography.dart` | Poppins scale (`xxs` sampai `xxxl` × `Regular`, `Medium`, `SemiBold`, `Bold`) |
| `style.dart` | Theme buttons, inputs, cards |
| `dimension.dart` | Radii dan spacings |
| `shared_widget/` | Komponen reusable (`AppMessenger`, `PokemonSearchBar`, `MainNavigation`, dll) |
