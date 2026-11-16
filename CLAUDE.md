# CLAUDE.md — Instructions for Claude

This project is **PokéAtlas**, a Flutter Pokémon Encyclopedia app.
Architecture: **Layered Clean Architecture** + **BLoC/Cubit** + **get_it** + **Retrofit/Dio**.

---

## REQUIRED: Read the Relevant Skill Before Working on a Task

Before writing code, read the corresponding skill file at `.agents/skills/{folder}/SKILL.md`:

| Task | Skill to Read |
|---|---|
| Creating a new feature end-to-end | `feature-flow/SKILL.md` + `clean-architecture/SKILL.md` |
| Creating / modifying Cubit or State | `cubit-pattern/SKILL.md` |
| Creating / modifying Repository | `repository-pattern/SKILL.md` |
| Adding an API endpoint | `networking/SKILL.md` |
| Error handling or reporting | `error-handling/SKILL.md` |
| Parsing large JSON responses | `json-parser/SKILL.md` |
| Responsive layout | `responsive/SKILL.md` |
| Logging | `logger/SKILL.md` |
| Unit testing | `testing/SKILL.md` |

---

## Core Rules

### Architecture
- **No GetX** — this project uses **BLoC/Cubit** (`flutter_bloc`) and **get_it**
- **UI → Cubit → Repository → ApiService → Dio**
- Do NOT import widgets into Cubit or Repository
- Do NOT call Repository from UI directly — always use Cubit
- Register new dependencies in `lib/config/service_locator.dart`:
  - Repositories: `registerLazySingleton`
  - Cubits: `registerFactory`

### State Management
- State classes must be `sealed class` extending `Equatable`
- Standard states: `Initial`, `Loading`, `Loaded`, `Error`
- UI consumes state via `BlocBuilder` with pattern matching:
  ```dart
  switch (state) {
    XInitial() => ...,
    XLoading() => ...,
    XLoaded(:final data) => ...,
    XError(:final message) => ...,
  }
  ```

### Code Style
- **NEVER** use `print()` or `debugPrint()` — use `LoggerHelper` from `lib/utility/logger.dart`
- Snackbars: use `AppMessenger.show()` from `lib/ui/shared_widget/app_messenger.dart`
- Colors: use `lib/ui/color.dart` and `PokemonTypeColors`
- Typography: use `lib/ui/typography.dart`
- Large lists ($\ge 50$ items): use `JsonParser.parseList()`

### Commands
```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter analyze
flutter test
```
