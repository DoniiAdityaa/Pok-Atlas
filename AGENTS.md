# AGENTS.md — Instructions for AI Agents

Flutter PokéAtlas — Pokémon Encyclopedia app.
Architecture: **Layered Clean Architecture** + **BLoC/Cubit** + **get_it** + **Retrofit/Dio**.

Parallel instruction files (`CLAUDE.md`, `.cursorrules`) have similar content — if conventions change, update all of them to avoid drift.

---

## Skills — Read Before Working on a Task

Technical guides live in `.agents/skills/{folder}/SKILL.md`. Mapping for common tasks:

| Task | Skill |
|---|---|
| New feature (end-to-end flow) | `feature-flow` + `clean-architecture` |
| Cubit / State creation | `cubit-pattern` |
| Repository / caching / DataState | `repository-pattern` |
| New endpoint / Retrofit / Dio | `networking` |
| Error handling / Crashlytics / AppMessenger | `error-handling` |
| Heavy JSON parsing (isolate) | `json-parser` |
| Responsive layout | `responsive` |
| Logging | `logger` |
| Unit testing | `testing` |

---

## Commands

```bash
# Setup
flutter pub get
dart run build_runner build --delete-conflicting-outputs

# Verify before commit
dart format .
flutter analyze
flutter test

# Single test
flutter test test/cubit/home/home_cubit_test.dart

# Build runner watch (during development)
dart run build_runner watch --delete-conflicting-outputs
```

---

## Architecture & Dependency Rules (MUST NOT BE VIOLATED)

```
UI (features/)
  ↓ calls
Cubit (features/*/cubit/)
  ↓ calls
Repository (repository/*/)   ← extends BaseRepository
  ↓ calls
ApiService (data/api/)        ← Retrofit @RestApi
  ↓ calls
Dio (HTTP Client)
```

- **Domain / Cubit** must NOT import UI widgets
- **Repository** must NOT import BLoC / Cubit or widgets
- **UI** must NOT call Repository or ApiService directly — always go through Cubit
- All async network calls in repository must be wrapped via `getStateOf()` from `BaseRepository`
- Result is always `DataState<T>` (`DataStateSuccess` / `DataStateError`)

---

## Naming Convention

| Type | File Format | Class Format |
|---|---|---|
| Model | `{feature}_model.dart` | `{Feature}Model` |
| Repository | `{feature}_repository.dart` | `{Feature}Repository` |
| Cubit | `{feature}_cubit.dart` | `{Feature}Cubit` |
| State | `{feature}_state.dart` | `{Feature}State` |
| Screen | `{feature}_screen.dart` | `{Feature}Screen` |
| Shared Widget | `{name}.dart` | `{Name}` |

---

## Code Rules

### State Management
- Use **Cubit**, not full BLoC (unless complex event debouncing/transform is required)
- States must use `sealed class` + `Equatable`
- Standard states: `XInitial`, `XLoading`, `XLoaded`, `XError`
- Multi-field state: use `copyWith` with `Function()?` wrapper for nullable fields

### UI
- Rebuild widget: `BlocBuilder<XCubit, XState>` with exhaustive `switch (state)`
- Side effects (toast, navigate): `BlocListener` or `BlocConsumer`
- Snackbars / toasts: use `AppMessenger.show()` — never raw `ScaffoldMessenger.of(context).showSnackBar()`
- Colors: use constants from `lib/ui/color.dart` (e.g. `PokemonTypeColors.getColor(type)`)
- Typography: use styles from `lib/ui/typography.dart` (`smMedium`, `mdBold`, dll)

### Networking
- Public endpoints defined in `lib/config/constant.dart` (`ApiEndpoints.xxx`)
- Endpoints declared in `ApiService` with `@GET`, `@POST`, `@Path`, `@Query`
- Base URL read from `.env` via `Env.baseUrl` (Envied)

### Logging
- **NEVER** use `print()` or `debugPrint()` — fails `avoid_print` lint
- Use `LoggerHelper.d()`, `LoggerHelper.i()`, `LoggerHelper.w()`, `LoggerHelper.e()` from `lib/utility/logger.dart`

### Heavy JSON
- Lists with $\ge 50$ items: use `JsonParser.parseList()` from `lib/utility/json_parser.dart` (runs in Isolate)

### Error Handling
- Base error handling is centralized in `BaseRepository.mapDioExceptionToMessage()`
- Uncaught errors are caught by `GlobalErrorHandler` in `lib/config/global_error_handler.dart`
