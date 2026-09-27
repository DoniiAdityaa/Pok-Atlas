# 🧭 PokéAtlas — Design System & Project Blueprint

> **"Explore. Discover. Know Them All."**  
> Aplikasi mobile Flutter modern untuk eksplorasi dan ensiklopedia Pokémon berbasis PokéAPI dengan antarmuka yang bersih, intuitif, dan *mobile-first*.

---

## 1. 📌 Identitas Proyek (Brand Identity)

| Properti | Detail | Keterangan |
| :--- | :--- | :--- |
| **Nama Aplikasi** | **PokéAtlas** | Menggabungkan *Poké* (dunia Pokémon) dan *Atlas* (peta/katalog eksplorasi komprehensif). |
| **Tagline** | *Explore. Discover. Know Them All.* | Merefleksikan misi eksplorasi dari generasi 1 hingga generasi terbaru. |
| **Gaya Desain** | Modern, Clean, Card-based, Soft Rounded | Menghindari kesan *fan-made cartoonish*, fokus pada pengalaman layaknya aplikasi resmi kelas atas (AAA mobile app). |
| **Target Platform** | iOS & Android (Flutter) | Responsif, performa tinggi, animasi mulus 60 FPS. |

---

## 2. 🎨 Palet Warna (Color Palette)

Aplikasi **PokéAtlas** tidak menggunakan warna merah Pokéball di seluruh halaman agar mata pengguna tidak cepat lelah. UI utama menggunakan palet **Royal Blue & Slate Clean**, sementara warna tipe Pokémon difungsikan sebagai **warna aksen dinamis**.

### 2.1 Warna Utama (Brand Colors)

| Token | Hex Code | Visual Sample | Penggunaan |
| :--- | :--- | :--- | :--- |
| **Primary** | `#2563EB` | ![#2563EB](https://via.placeholder.com/15/2563EB/000000?text=+) Royal Blue | Warna primer brand, tombol utama, tab aktif, link, progress bar. |
| **Primary Dark** | `#1D4ED8` | ![#1D4ED8](https://via.placeholder.com/15/1D4ED8/000000?text=+) Blue 700 | State pressed/hover tombol, badge border. |
| **Primary Tint** | `#EFF6FF` | ![#EFF6FF](https://via.placeholder.com/15/EFF6FF/000000?text=+) Blue 50 | Background badge, highlight container, subtle aura splash. |
| **Background** | `#F8FAFC` | ![#F8FAFC](https://via.placeholder.com/15/F8FAFC/000000?text=+) Slate 50 | Warna latar belakang seluruh layar aplikasi. |
| **Surface / Card** | `#FFFFFF` | ![#FFFFFF](https://via.placeholder.com/15/FFFFFF/000000?text=+) Pure White | Warna kartu Pokémon, bottom sheet, modal dialog. |
| **Text Primary** | `#0F172A` | ![#0F172A](https://via.placeholder.com/15/0F172A/000000?text=+) Slate 900 | Judul utama, nama Pokémon, angka stats penting. |
| **Text Secondary** | `#64748B` | ![#64748B](https://via.placeholder.com/15/64748B/000000?text=+) Slate 500 | Tagline, subtitle, label deskripsi, teks placeholder. |
| **Border / Divider** | `#E2E8F0` | ![#E2E8F0](https://via.placeholder.com/15/E2E8F0/000000?text=+) Slate 200 | Garis pemisah, outline kartu, form input border. |

---

### 2.2 Warna Tipe Pokémon (Type Accent Colors)

Setiap Pokémon memiliki satu atau dua elemen tipe. Warna ini digunakan pada **badge tipe**, **latar kartu Pokémon**, dan **diagram stats**:

| Tipe | Hex Code | Warna | Penggunaan |
| :--- | :--- | :--- | :--- |
| **Fire** | `#EF4444` | Red / Orange | Charmander, Cyndaquil, dll. |
| **Water** | `#3B82F6` | Sky Blue | Squirtle, Totodile, dll. |
| **Grass** | `#10B981` | Emerald Green | Bulbasaur, Chikorita, dll. |
| **Electric** | `#F59E0B` | Amber / Yellow | Pikachu, Zapdos, dll. |
| **Psychic** | `#EC4899` | Pink | Mewtwo, Alakazam, dll. |
| **Ice** | `#06B6D4` | Cyan / Ice Blue | Articuno, Lapras, dll. |
| **Dragon** | `#6366F1` | Indigo / Violet | Dragonite, Garchomp, dll. |
| **Dark** | `#334155` | Slate / Dark Navy | Umbreon, Darkrai, dll. |
| **Fairy** | `#F472B6` | Rose Pink | Clefairy, Sylveon, dll. |
| **Ghost** | `#7C3AED` | Deep Purple | Gengar, Mimikyu, dll. |
| **Poison** | `#A855F7` | Purple | Ekans, Koffing, dll. |
| **Bug** | `#84CC16` | Lime Green | Butterfree, Scyther, dll. |
| **Fighting** | `#DC2626` | Deep Red | Machamp, Lucario, dll. |
| **Ground** | `#D97706` | Ochre Brown | Diglett, Groudon, dll. |
| **Rock** | `#78716C` | Warm Stone | Geodude, Onix, dll. |
| **Steel** | `#64748B` | Metallic Gray | Steelix, Metagross, dll. |
| **Flying** | `#818CF8` | Lavender Blue | Pidgeot, Rayquaza, dll. |
| **Normal** | `#94A3B8` | Neutral Slate | Eevee, Snorlax, dll. |

---

## 3. ✍️ Panduan Tipografi (Typography)

Sistem tipografi PokéAtlas menggabungkan dua font modern:

* **Headings:** `Poppins` (Bold / SemiBold) — Memberikan karakter yang modern, kokoh, dan bersahabat.
* **Body / Isi:** `Inter` (Regular / Medium) — Keterbacaan tinggi (*high legibility*) untuk data angka, spesifikasi, dan deskripsi.

```text
Contoh Hirarki Tipografi:
├── PokéAtlas                  → Poppins Bold (32pt - 36pt)
├── Explore Pokémon            → Poppins SemiBold (20pt - 24pt)
├── Pikachu                    → Poppins SemiBold (18pt)
├── Base Stats                 → Poppins Medium (16pt)
├── Electric                   → Inter Medium (12pt)
└── Search your Pokémon...     → Inter Regular (14pt)
```

---

## 4. 🖼️ Strategi Aset: API vs Buatan Sendiri

Penting untuk membedakan mana aset yang didapat langsung dari jaringan vs aset yang kita rancang sendiri:

### 🟢 Disediakan oleh PokéAPI (Tidak Perlu Disimpan di Lokal):
* **Data Pokémon:** ID, Nama, Bobot (Weight), Tinggi (Height), Base Stats (HP, Attack, Defense, dll.).
* **Gambar / Sprite:** URL `official-artwork` berkualitas tinggi:
  * Artwork Utama: `sprites.other['official-artwork'].front_default`
  * Variasi Shiny: `sprites.other['official-artwork'].front_shiny`
* **Relasi Data:** Tipe elemen, abilities, daftar moves, evolusi, varian species.

### 🎨 Dibuat Sendiri (Custom UI & Assets):
* **Logo PokéAtlas & App Icon:** Identitas grafis sendiri (motif kompas + bola eksplorasi).
* **Splash Screen:** Desain pembuka aplikasi dengan Lottie animation dan branding.
* **UI Components:** Kartu Pokémon, Stat bar chart, Navigasi Tab, Filter Chips, Modal Bottom Sheet.
* **Empty / Error States:** Ilustrasi ramah saat data tidak ditemukan atau saat koneksi internet terputus.

---

## 5. 🌐 Arsitektur Data & API PokéAtlas

### 5.1 Alur Data (Data Flow Architecture)
```text
PokéAPI REST (https://pokeapi.co/api/v2)
  │
  ▼
Dio HTTP Client (BaseOptions: baseUrl, timeouts, headers)
  │
  ▼
Retrofit ApiService (Type-safe endpoints interface)
  │
  ▼
BaseRepository (Error mapping, status handling, returns DataState<T>)
  │
  ▼
Cubit State Management (UI logic, emits Loading, Success, Error)
  │
  ▼
Flutter UI Screen / Shared Widget
```

### 5.2 6 Endpoint Prioritas Utama (MVP):
1. **`GET /pokemon?offset=0&limit=20`** $\rightarrow$ List Pokémon dengan pagination tak terbatas (*infinite scroll*).
2. **`GET /pokemon/{id or name}`** $\rightarrow$ Detail lengkap satu Pokémon (sprite artwork, tipe, stats, ability, moves).
3. **`GET /type`** $\rightarrow$ Mengambil seluruh 18 tipe elemen untuk filter chips.
4. **`GET /type/{id or name}`** $\rightarrow$ Mengambil daftar Pokémon berdasarkan tipe tertentu.
5. **`GET /pokemon-species/{id or name}`** $\rightarrow$ Deskripsi Pokedex (flavor text), habitat, generasi, dan URL evolution-chain.
6. **`GET /evolution-chain/{id}`** $\rightarrow$ Pohon evolusi Pokémon dari bentuk dasar hingga tingkat akhir.

---

## 6. 🗺️ Peta Fitur & Alur Pengguna (Feature Roadmap)

```text
[Splash Screen]
      │
      ▼
[Main Navigation]
      ├── 🏠 Home Tab
      │     ├── Search Pokémon Quick Bar
      │     ├── Featured Pokémon of the Day
      │     ├── Filter Elemen Chips (Fire, Water, Grass, dll.)
      │     └── Grid Kartu Pokémon (Pagination Infinite Scroll)
      │
      ├── 🔍 Explore Tab
      │     ├── Filter berdasarkan Generasi (Gen I - IX)
      │     └── Filter berdasarkan Tipe & Sorting (ID, Nama, Stat tertinggi)
      │
      ├── 💖 Favorites Tab
      │     └── Daftar Pokémon favorit tersimpan lokal (Offline Access)
      │
      └── ⚖️ Compare Tab
            └── Perbandingan Base Stats head-to-head 2 Pokémon
```

---

## 7. 📏 Aturan Desain Komponen (UI Component Rules)

1. **Border Radius:**
   * Kartu Pokémon: `16px` – `20px` (rounded lembut)
   * Tombol & Input Field: `12px` – `14px`
   * Pill Badges & Chips: `20px` (kapsul penuh)
2. **Elevasi & Shadow:**
   * Gunakan bayangan sangat halus: `BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 16, offset: Offset(0, 4))`
   * Hindari bayangan hitam tebal yang membuat desain terlihat berat.
3. **Card Presentation:**
   * Setiap kartu Pokémon diberi warna latar belakang lembut sesuai elemen tipe utamanya (dengan opacity 10% - 15%), sehingga visual terlihat hidup dan kaya warna.
