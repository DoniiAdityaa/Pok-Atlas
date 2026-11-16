# Environment Setup — PokéAtlas

PokéAtlas menggunakan **Envied** untuk type-safe compile-time environment variables.

---

## 1. File `.env`

File `.env` berada di root project dan **tidak boleh dicommit ke git** (sudah masuk `.gitignore`).

Template `.env`:
```env
BASE_URL=https://pokeapi.co/api/v2
```

---

## 2. Cara Kerja

```
.env (file rahasia, gitignored)
  ↓ dibaca saat compile oleh envied_generator
lib/config/env/env.dart (@Envied)
  ↓ di-generate menjadi
lib/config/env/env.g.dart
  ↓ digunakan oleh
lib/config/service_locator.dart (Dio baseUrl)
```

---

## 3. Menambah Environment Variable Baru

**Step 1** — Tambah variable di `.env`:
```env
BASE_URL=https://pokeapi.co/api/v2
API_KEY=your_key_here
```

**Step 2** — Tambah field di `lib/config/env/env.dart`:
```dart
@Envied(path: '.env')
abstract class Env {
  @EnviedField(varName: 'BASE_URL')
  static const String baseUrl = _Env.baseUrl;

  @EnviedField(varName: 'API_KEY')
  static const String apiKey = _Env.apiKey;  // ← tambah
}
```

**Step 3** — Generate ulang:
```bash
dart run build_runner build --delete-conflicting-outputs
```

---

## 4. Commands

```bash
# Setup pertama kali setelah clone
cp .env.example .env
dart run build_runner build --delete-conflicting-outputs
```
