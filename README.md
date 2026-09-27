# 🐾 PokéAtlas

> **Explore. Discover. Know Them All.**

PokéAtlas adalah aplikasi **Pokémon Encyclopedia & Explorer** berbasis Flutter yang memungkinkan pengguna menjelajahi, mencari, mempelajari, dan membandingkan berbagai informasi Pokémon dalam satu aplikasi.

Aplikasi ini menggunakan **PokéAPI** sebagai sumber data utama untuk mengambil informasi Pokémon secara dinamis, termasuk nama, tipe, statistik, abilities, moves, species, evolution chain, dan berbagai artwork/sprite Pokémon.

PokéAtlas dibuat sebagai **project portfolio sekaligus project pembelajaran Flutter**, dengan fokus pada implementasi aplikasi yang terstruktur, penggunaan REST API, state management, data modeling, caching, local storage, dan pengembangan aplikasi mobile yang scalable.

---

## 📱 Apa Itu PokéAtlas?

PokéAtlas dapat dibayangkan sebagai sebuah **Pokédex modern**.

Jika Pokédex tradisional hanya memberikan informasi dasar mengenai Pokémon, PokéAtlas mencoba menghadirkan pengalaman eksplorasi yang lebih lengkap dan modern.

Pengguna dapat:

* 🔎 Mencari Pokémon
* 📖 Melihat daftar Pokémon
* 🧩 Memfilter Pokémon berdasarkan Type
* 📊 Melihat statistik Pokémon
* ⚡ Melihat Ability
* 🥊 Melihat Move
* 🧬 Melihat Evolution Chain
* 🧪 Melihat informasi Species
* ✨ Melihat artwork dan sprite
* ❤️ Menyimpan Pokémon sebagai Favorite
* ⚖️ Membandingkan beberapa Pokémon
* 🕘 Melihat Pokémon yang baru saja dibuka
* 📚 Mengeksplorasi Pokémon berdasarkan Generation

Tujuan utamanya bukan sekadar menampilkan data API, tetapi mengubah data tersebut menjadi **pengalaman aplikasi mobile yang nyaman untuk eksplorasi**.

---

# 🎯 Project Goals

PokéAtlas memiliki dua tujuan utama.

### 1. User Experience

Membuat aplikasi Pokémon encyclopedia yang:

* sederhana digunakan
* cepat
* modern
* informatif
* mudah melakukan pencarian
* mudah menemukan Pokémon berdasarkan kategori
* memiliki tampilan visual yang menarik

### 2. Developer Learning

Project ini juga digunakan untuk memperdalam:

* Flutter
* Dart
* REST API
* HTTP request
* Dio
* JSON parsing
* Data modeling
* Repository Pattern
* Cubit / BLoC
* Dependency Injection
* Routing
* Local Storage
* Caching
* Error handling
* Pagination
* Unit testing
* Widget testing
* Integration testing
* Firebase
* Clean Architecture
* Git & GitHub

---

# 🌐 Data Source

PokéAtlas menggunakan **PokéAPI** sebagai sumber data utama.

PokéAPI merupakan RESTful API publik yang menyediakan data dari franchise Pokémon, termasuk Pokémon, moves, abilities, types, species, evolution chains, dan berbagai resource lainnya. API v2 dapat digunakan tanpa authentication dan menggunakan HTTP GET untuk mengambil resource.

### Base URL

```text
https://pokeapi.co/api/v2/
```

### Contoh

```text
GET /pokemon/pikachu
```

atau:

```text
GET /pokemon/25
```

---

# 🧩 Informasi yang Digunakan

PokéAtlas tidak hanya mengambil nama Pokémon.

Data yang digunakan dapat mencakup:

```text
Pokémon
├── ID
├── Name
├── Height
├── Weight
├── Base Experience
├── Types
├── Abilities
├── Stats
├── Moves
├── Species
├── Sprites
└── Official Artwork
```

PokéAPI juga menyediakan relasi ke resource lain melalui URL, misalnya Pokémon → Species → Evolution Chain.

---

# 🖼️ Pokémon Images

PokéAtlas **tidak perlu menyimpan ribuan gambar Pokémon di dalam project Flutter**.

PokéAPI menyediakan URL sprite dan artwork pada data Pokémon.

Contohnya terdapat:

```text
sprites
├── front_default
├── front_shiny
├── back_default
├── back_shiny
└── other
    ├── dream_world
    ├── home
    ├── official-artwork
    └── showdown
```

PokéAPI juga memiliki repository khusus untuk sprite Pokémon, termasuk official artwork.

Untuk PokéAtlas, artwork utama akan menggunakan:

```text
official-artwork
```

Sedangkan sprite lainnya dapat digunakan untuk fitur tambahan seperti Shiny atau detail tertentu.

---

# 🔌 API Endpoints

Endpoint utama yang akan digunakan:

## 1. Pokémon List

```http
GET /pokemon
```

Digunakan untuk:

* Home
* Explore
* Pagination
* Infinite scroll

PokéAPI menggunakan pagination pada resource list dan menyediakan `limit`, `offset`, `next`, dan `previous`.

Contoh:

```http
GET /pokemon?limit=20&offset=0
```

---

## 2. Pokémon Detail

```http
GET /pokemon/{id}
```

Contoh:

```http
GET /pokemon/25
```

atau:

```http
GET /pokemon/pikachu
```

Digunakan untuk:

* Detail Pokémon
* Type
* Stats
* Abilities
* Moves
* Sprite
* Species reference

---

## 3. Type

```http
GET /type
```

Digunakan untuk mengambil daftar Pokémon Type.

Contoh:

```text
Fire
Water
Grass
Electric
Psychic
Ice
Dragon
Dark
Fairy
...
```

---

## 4. Pokémon berdasarkan Type

```http
GET /type/{id}
```

Contoh:

```http
GET /type/10
```

Digunakan untuk fitur:

```text
Filter Pokémon
```

---

## 5. Pokémon Species

```http
GET /pokemon-species/{id}
```

Digunakan untuk mendapatkan informasi species dan relasi seperti:

* Generation
* Evolution Chain
* Species information

---

## 6. Evolution Chain

```http
GET /evolution-chain/{id}
```

Digunakan untuk menampilkan:

```text
Bulbasaur
   ↓
Ivysaur
   ↓
Venusaur
```

---

## 7. Ability

```http
GET /ability/{id}
```

Digunakan untuk menampilkan informasi Ability secara lebih detail.

---

## 8. Move

```http
GET /move/{id}
```

Digunakan jika halaman detail membutuhkan informasi Move yang lebih lengkap.

---

## 9. Generation

```http
GET /generation/{id}
```

Digunakan untuk fitur eksplorasi berdasarkan Generation.

---

# 🗺️ Application Structure

PokéAtlas akan memiliki beberapa bagian utama.

```text
PokéAtlas
│
├── 🏠 Home
│
├── 🔎 Explore
│
├── ❤️ Favorites
│
├── ⚙️ Settings
│
└── 📖 Pokémon Detail
```

---

# 🏠 Home

Home merupakan halaman utama aplikasi.

Isi utama:

* Greeting / header
* Search Pokémon
* Featured Pokémon
* Quick Type Filter
* Recently Viewed
* Popular / Recommended Pokémon
* Shortcut menuju Explore

Contoh struktur:

```text
┌─────────────────────────┐
│ PokéAtlas               │
│ Explore Pokémon         │
│                         │
│ 🔍 Search Pokémon...    │
│                         │
│ Types                   │
│ 🔥  💧  🌿  ⚡  🧠      │
│                         │
│ Featured Pokémon        │
│ ┌─────────────────────┐ │
│ │      Pikachu        │ │
│ │       image         │ │
│ └─────────────────────┘ │
│                         │
│ Recently Viewed         │
│ ...                     │
└─────────────────────────┘
```

---

# 🔎 Explore

Explore merupakan halaman untuk menjelajahi seluruh Pokémon.

Fitur:

* Pokémon list
* Search
* Pagination
* Infinite scrolling
* Type filter
* Generation filter
* Sorting

Contoh:

```text
Explore Pokémon

🔍 Search...

[All] [Fire] [Water] [Grass]

┌──────────┐ ┌──────────┐
│ Pikachu  │ │ Bulbasaur│
│   image  │ │   image  │
│ #0025     │ │ #0001    │
└──────────┘ └──────────┘
```

---

# 📖 Pokémon Detail

Halaman detail merupakan halaman utama untuk melihat informasi lengkap Pokémon.

Informasi:

### Basic Information

* Name
* Pokédex Number
* Artwork
* Type
* Height
* Weight

### Base Stats

```text
HP
Attack
Defense
Sp. Attack
Sp. Defense
Speed
```

### Abilities

Menampilkan Ability yang dimiliki Pokémon.

### Moves

Menampilkan daftar Move yang dapat dipelajari Pokémon.

### Evolution

Menampilkan Evolution Chain.

### Species

Menampilkan informasi species dan generation.

---

# ❤️ Favorites

Pengguna dapat menyimpan Pokémon favorit.

Favorite disimpan secara lokal sehingga Pokémon yang sudah disimpan dapat diakses tanpa harus terus mengambil daftar dari API.

Contoh:

```text
Favorites

❤️ Pikachu
❤️ Charizard
❤️ Lucario
❤️ Gengar
```

Teknologi yang dapat digunakan:

```text
Local Storage
```

Pilihan implementasi:

* Hive
* SQLite

---

# ⚖️ Compare Pokémon

Fitur Compare memungkinkan pengguna membandingkan Pokémon.

Contoh:

```text
           Pikachu      Raichu

HP             35          60
Attack         55          90
Defense        40          55
Sp.Attack      50          90
Sp.Defense     50          80
Speed          90         110
```

Fitur ini akan menggunakan data statistik dari endpoint Pokémon.

---

# 🕘 Recently Viewed

PokéAtlas dapat menyimpan Pokémon yang terakhir dibuka.

Contoh:

```text
Recently Viewed

Pikachu
Charizard
Gengar
Eevee
```

Data ini dapat disimpan secara lokal.

---

# 🎨 Design System

PokéAtlas menggunakan desain modern, clean, dan friendly.

### Design Direction

```text
Modern
Clean
Minimal
Friendly
Rounded
Card-based
Data-driven
Mobile-first
```

---

# 🎨 Color Palette

### Primary

```text
Blue
#2563EB
```

### Background

```text
#F8FAFC
```

### Card

```text
#FFFFFF
```

### Primary Text

```text
#0F172A
```

### Secondary Text

```text
#64748B
```

### Border

```text
#E2E8F0
```

---

# 🧩 Pokémon Type Colors

| Type     | Color     |
| -------- | --------- |
| Fire     | `#F97316` |
| Water    | `#3B82F6` |
| Grass    | `#22C55E` |
| Electric | `#EAB308` |
| Psychic  | `#EC4899` |
| Ice      | `#06B6D4` |
| Dark     | `#475569` |
| Dragon   | `#6366F1` |
| Poison   | `#A855F7` |
| Ground   | `#A16207` |
| Rock     | `#78716C` |
| Bug      | `#84CC16` |
| Flying   | `#818CF8` |
| Fighting | `#DC2626` |
| Ghost    | `#7C3AED` |
| Steel    | `#64748B` |
| Normal   | `#A8A29E` |
| Fairy    | `#F472B6` |

---

# 🔤 Typography

### Heading

**Poppins**

Digunakan untuk:

* Heading
* Pokémon Name
* Section title
* Important information

### Body

**Inter**

Digunakan untuk:

* Description
* Metadata
* Labels
* Supporting information

---

# 📐 UI Rules

### Border Radius

```text
Small     8px
Medium   12px
Card     16px
Large    20px
```

### Screen Padding

```text
20px
```

### Component Style

Menggunakan:

* Rounded cards
* Soft borders
* Clear hierarchy
* Consistent spacing
* Minimal shadows

---

# 🏗️ Technical Architecture

PokéAtlas menggunakan pendekatan **feature-based architecture** dengan pemisahan antara presentation, data, dan business logic.

Arsitektur sederhananya:

```text
UI
 ↓
Cubit
 ↓
Repository
 ↓
Remote Data Source
 ↓
Dio
 ↓
PokéAPI
```

Response:

```text
PokéAPI
 ↓
JSON
 ↓
Model
 ↓
Repository
 ↓
Cubit
 ↓
UI
```

---

# 📁 Project Structure

Struktur yang direncanakan:

```text
lib/
│
├── app/
│   ├── router/
│   ├── theme/
│   └── app.dart
│
├── core/
│   ├── constants/
│   ├── error/
│   ├── network/
│   ├── storage/
│   └── utils/
│
└── features/
    │
    ├── home/
    │   ├── presentation/
    │   └── ...
    │
    ├── pokemon/
    │   │
    │   ├── data/
    │   │   ├── datasources/
    │   │   ├── models/
    │   │   └── repositories/
    │   │
    │   ├── domain/
    │   │   └── repositories/
    │   │
    │   └── presentation/
    │       ├── cubit/
    │       ├── pages/
    │       └── widgets/
    │
    ├── favorites/
    │
    └── compare/
```

---

# 🧰 Technology Stack

## Frontend

```text
Flutter
Dart
```

## Networking

```text
Dio
```

## API

```text
PokéAPI
```

## State Management

```text
flutter_bloc
Cubit
```

## JSON

```text
json_serializable
json_annotation
build_runner
```

## Dependency Injection

```text
GetIt
```

## Routing

```text
GoRouter
```

## Local Storage

Planned:

```text
Hive
```

atau:

```text
SQLite
```

## Backend / Cloud Features

Planned:

```text
Firebase Authentication
Cloud Firestore
```

---

# 🔄 Data Flow

Contoh ketika pengguna membuka Pikachu:

```text
User
 │
 │ tap Pikachu
 ▼
Pokémon Detail Page
 │
 ▼
PokemonDetailCubit
 │
 ▼
PokemonRepository
 │
 ▼
PokemonRemoteDataSource
 │
 ▼
Dio
 │
 ▼
PokéAPI
 │
 │ GET /pokemon/pikachu
 ▼
JSON Response
 │
 ▼
PokemonModel
 │
 ▼
Repository
 │
 ▼
Cubit
 │
 ▼
UI
```

Dengan pola ini, UI tidak langsung berkomunikasi dengan API.

---

# 🧪 API Testing

Sebelum implementasi Flutter, endpoint PokéAPI akan dieksplorasi terlebih dahulu.

Testing akan mencakup:

```text
/pokemon
/pokemon/{id}
/type
/type/{id}
/pokemon-species/{id}
/evolution-chain/{id}
/ability/{id}
/move/{id}
/generation/{id}
```

Testing bertujuan mengetahui:

* HTTP status
* Struktur JSON
* Field yang tersedia
* Relasi antar resource
* URL gambar
* Pagination
* Data yang diperlukan aplikasi
* Data yang tidak diperlukan

Untuk eksplorasi awal, project menyediakan:

```text
testing_api/
└── pokeapi_comprehensive_test.py
```

File Python tersebut **bukan bagian dari aplikasi Flutter**. File tersebut hanya digunakan sebagai alat eksplorasi API sebelum data tersebut diimplementasikan ke Dart.

---

# 📊 API vs Application Data

Tidak semua data harus selalu berasal langsung dari API.

### Data dari PokéAPI

```text
Pokémon
Types
Stats
Abilities
Moves
Species
Evolution
Artwork
Generation
```

### Data milik aplikasi

```text
Favorite
Recently Viewed
Compare List
User Settings
Theme Preference
User Account
```

Jadi:

```text
PokéAPI
    ↓
Official Pokémon information
```

sedangkan:

```text
Local Storage / Firebase
    ↓
User-specific application data
```

---

# 🚀 Development Roadmap

## Phase 1 — Project Setup

* [ ] Create Flutter project
* [ ] Configure theme
* [ ] Configure folder structure
* [ ] Configure dependencies
* [ ] Configure Git

---

## Phase 2 — API Exploration

* [ ] Test `/pokemon`
* [ ] Test `/pokemon/{id}`
* [ ] Test `/type`
* [ ] Test `/type/{id}`
* [ ] Test `/pokemon-species`
* [ ] Test `/evolution-chain`
* [ ] Test `/ability`
* [ ] Test `/move`
* [ ] Test `/generation`

---

## Phase 3 — Data Modeling

Create models for:

```text
Pokemon
PokemonType
PokemonStat
PokemonAbility
PokemonMove
PokemonSpecies
EvolutionChain
Sprites
```

---

## Phase 4 — Networking

Implement:

```text
Dio
Remote Data Source
Repository
Error Handling
Pagination
```

---

## Phase 5 — Home

Implement:

* [ ] Search
* [ ] Featured Pokémon
* [ ] Type shortcuts
* [ ] Recently viewed

---

## Phase 6 — Explore

Implement:

* [ ] Pokémon list
* [ ] Pagination
* [ ] Search
* [ ] Type filter
* [ ] Generation filter

---

## Phase 7 — Detail

Implement:

* [ ] Artwork
* [ ] Basic information
* [ ] Types
* [ ] Stats
* [ ] Abilities
* [ ] Moves
* [ ] Species
* [ ] Evolution chain

---

## Phase 8 — Local Features

Implement:

* [ ] Favorites
* [ ] Recently viewed
* [ ] Compare
* [ ] Local caching

---

## Phase 9 — Firebase

Future features:

* [ ] Firebase Authentication
* [ ] Cloud favorites
* [ ] User profile
* [ ] Firestore synchronization

---

## Phase 10 — Quality

* [ ] Unit testing
* [ ] Repository testing
* [ ] Cubit testing
* [ ] Widget testing
* [ ] Integration testing
* [ ] Error handling
* [ ] Loading state
* [ ] Empty state
* [ ] Offline handling

---

# 🛡️ Error & Loading States

Aplikasi tidak boleh hanya memiliki kondisi:

```text
Success
```

Tetapi juga:

```text
Loading
Success
Empty
Error
Offline
```

Contoh:

```text
Loading
   ↓
API Request
   ↓
 ┌───────────────┐
 │               │
Success        Error
 │               │
 ▼               ▼
Show Data      Show Error
```

---

# 💾 Caching

PokéAPI sendiri menganjurkan developer untuk melakukan caching resource yang sudah diminta untuk mengurangi beban request.

Karena itu PokéAtlas nantinya dapat menerapkan:

```text
API
 ↓
Cache
 ↓
Flutter
```

Tujuannya:

* Mengurangi request berulang
* Mempercepat loading
* Membantu penggunaan offline
* Mengurangi ketergantungan terhadap network

---

# 🧪 Testing Strategy

Testing akan dibagi menjadi beberapa level.

### API Testing

Memastikan endpoint memberikan response yang sesuai.

### Unit Testing

Testing:

```text
Models
Repositories
Cubits
Utilities
```

### Widget Testing

Testing:

```text
PokemonCard
SearchField
TypeBadge
StatBar
```

### Integration Testing

Testing flow:

```text
Open App
 ↓
Search Pokémon
 ↓
Open Detail
 ↓
Add Favorite
 ↓
Open Favorites
```

---

# 🎨 Branding

## App Name

**PokéAtlas**

## Tagline

> **Explore. Discover. Know Them All.**

## Meaning

**Poké** berasal dari Pokémon.

**Atlas** menggambarkan sebuah kumpulan informasi atau peta eksplorasi.

Jadi PokéAtlas dapat diposisikan sebagai:

> **Sebuah atlas digital untuk menjelajahi dunia Pokémon.**

Nama ini cocok dengan konsep aplikasi karena pengguna tidak hanya melihat satu Pokémon, tetapi dapat menjelajahi berbagai Pokémon, type, generation, evolution, ability, dan informasi lainnya.

---

# 🧭 Core Concept

PokéAtlas memiliki konsep:

```text
DISCOVER
   ↓
EXPLORE
   ↓
LEARN
   ↓
COMPARE
   ↓
COLLECT
```

Pengguna pertama-tama menemukan Pokémon, kemudian mengeksplorasi informasinya, mempelajari statistik dan karakteristiknya, membandingkannya dengan Pokémon lain, dan akhirnya dapat menyimpannya sebagai favorite.

---

# 👤 Target Users

PokéAtlas ditujukan untuk:

* Pokémon fans
* Orang yang ingin mencari informasi Pokémon
* Pengguna yang ingin menjelajahi Pokémon berdasarkan Type
* Pengguna yang ingin melihat statistik
* Pengguna yang ingin melihat evolution chain
* Developer yang tertarik dengan project API-driven Flutter

---

# 💡 Why This Project?

PokéAtlas bukan hanya project untuk membuat aplikasi Pokémon.

Project ini dirancang untuk menjadi **end-to-end Flutter project**.

Developer akan belajar bagaimana sebuah aplikasi:

```text
External API
     ↓
Networking
     ↓
JSON
     ↓
Model
     ↓
Repository
     ↓
State Management
     ↓
UI
     ↓
Local Storage
     ↓
Cloud
     ↓
Testing
     ↓
Release
```

Dengan begitu project ini dapat menjadi portfolio yang menunjukkan kemampuan dalam membangun aplikasi Flutter yang menggunakan data eksternal dan memiliki architecture yang terstruktur.

---

# ⚠️ Disclaimer

PokéAtlas adalah project pembelajaran dan portfolio yang menggunakan PokéAPI sebagai sumber data.

PokéAPI menyatakan bahwa nama Pokémon dan karakter Pokémon merupakan trademark Nintendo.

Project ini tidak dimaksudkan untuk mengklaim kepemilikan atas Pokémon atau aset Pokémon.

Jika project akan dipublikasikan secara luas atau digunakan secara komersial, penggunaan nama, artwork, sprite, logo, dan aset terkait Pokémon perlu diperiksa kembali berdasarkan ketentuan dan hak yang berlaku.

---

# 📚 Learning Focus

Project ini secara khusus digunakan untuk mempelajari:

```text
Flutter
Dart
REST API
HTTP
Dio
JSON
Serialization
Repository Pattern
Cubit
BLoC
Dependency Injection
GoRouter
Local Storage
Caching
Firebase
Testing
Clean Architecture
Git
CI/CD
```

---

# 📌 Current Status

```text
Project: PokéAtlas
Status: 🟡 In Development

Current Focus:
API Exploration

Next:
Data Modeling
↓
Networking
↓
Repository
↓
Cubit
↓
UI
```

---

# 🗂️ Development Principle

Pengembangan PokéAtlas dilakukan secara bertahap.

Urutan utama:

```text
1. Understand the API
        ↓
2. Test the API
        ↓
3. Understand the JSON
        ↓
4. Create Models
        ↓
5. Create Data Source
        ↓
6. Create Repository
        ↓
7. Create Cubit
        ↓
8. Build UI
        ↓
9. Add Local Features
        ↓
10. Testing
        ↓
11. Release
```

**Jangan membuat UI berdasarkan tebakan struktur API.**

Data API dipahami terlebih dahulu, kemudian model dibuat berdasarkan response yang benar-benar diterima.

---

# 🌟 Future Ideas

Fitur yang dapat dikembangkan setelah MVP:

* Pokémon comparison
* Advanced filtering
* Shiny Pokémon
* Multiple forms
* Regional forms
* Generation explorer
* Move explorer
* Ability explorer
* Type effectiveness
* Recently viewed
* Offline mode
* Cloud favorites
* User account
* Dark mode
* Notifications
* Deep linking
* Analytics
* CI/CD
* Automated testing

---

# 📄 License

Project license dapat ditentukan kemudian sesuai kebutuhan portfolio dan distribusi aplikasi.

PokéAtlas menggunakan data dari:

**PokéAPI**

Official documentation:

[PokéAPI Documentation](https://pokeapi.co/docs/v2?utm_source=chatgpt.com)

---

## PokéAtlas

> **Explore. Discover. Know Them All.**

A modern Flutter Pokémon encyclopedia built to explore, learn, and discover the Pokémon world.
