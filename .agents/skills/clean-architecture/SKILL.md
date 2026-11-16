---
name: Clean Architecture (Pokeatlas)
description: Layer diagram, dependency rule, dan alur data di project ini
---
# Clean Architecture — PokéAtlas

## Layer Diagram

```
┌─────────────────────────────────────────────────────┐
│  PRESENTATION (UI)                                  │
│  Screen → BlocBuilder/BlocConsumer → Cubit          │
├─────────────────────────────────────────────────────┤
│  DOMAIN (Business Logic)                            │
│  Cubit → Repository (abstract) → DataState<T>       │
├─────────────────────────────────────────────────────┤
│  DATA (Infrastructure)                              │
│  RepositoryImpl → ApiService (Retrofit) → Dio       │
└─────────────────────────────────────────────────────┘
```

## Dependency Rule

- **Domain** tidak boleh import Flutter, Dio, Retrofit, atau package eksternal apapun
- **Data layer** mengimplementasikan domain (Repository → RepositoryImpl)
- **Presentation** hanya berinteraksi dengan Cubit; tidak langsung ke Repository

## Alur Data

```
UI action
  → Cubit.method()
    → Repository.fetchX()
      → BaseRepository.getStateOf()
        → ApiService.endpoint()         ← Retrofit + Dio
      ← DataStateSuccess<T> / DataStateError
    ← emit(XLoaded(data)) / emit(XError(msg))
  ← BlocBuilder rebuild widget
```

## Folder Structure

```
lib/
├── config/            # DI (GetIt), env, constants, error handler
├── data/
│   └── api/           # ApiService (Retrofit abstract + generated)
├── features/
│   └── {feature}/
│       ├── {feature}_screen.dart
│       └── cubit/
│           ├── {feature}_cubit.dart
│           └── {feature}_state.dart
├── models/            # JSON models (@JsonSerializable)
├── repository/
│   ├── base/          # BaseRepository.getStateOf<T>()
│   ├── pokemon_list/
│   └── pokemon_detail/
├── ui/                # theme, colors, typography, shared_widget/
└── utility/           # logger, json_parser, responsive, resource/
```
