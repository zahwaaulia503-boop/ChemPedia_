# 🧪 ChemPedia - Ensiklopedia & Media Pembelajaran Kimia SMA

Aplikasi Android ensiklopedia dan media pembelajaran kimia SMA interaktif berbasis **Kurikulum Merdeka (Fase E & Fase F: Kelas X, XI, dan XII)** yang dikembangkan menggunakan **Flutter**, database cloud **Supabase**, dan otomatisasi build APK via **GitHub Actions**.

Dibuat untuk memenuhi tugas mata kuliah **Produksi dan Pengembangan Media Pembelajaran Kimia**.

---

## 📱 Fitur Utama ChemPedia

1. **Layar Pembuka & Profil Siswa (Zero-Friction):**
   * Masuk langsung tanpa registrasi email/password yang rumit.
   * Siswa dapat memasukkan nama panggilan, memilih jenjang kelas (X, XI, atau XII), dan memilih avatar karakter kartun kimia lucu (*Dr. Erlenmeyer, Atom Ceria, Prof. Kimia, Beaker Imut, dll.*).
2. **Beranda & Fakta Kimia Harian (Tahukah Kamu?):**
   * Sapaan hangat dan personal untuk siswa.
   * Fakta ilmiah interaktif berganti setiap hari yang dapat diperluas (*expandable*).
   * Fitur klaim bonus harian **ChemCoins**.
   * Menu jalan pintas ke Glosarium, Favorit, dan Misteri Kimia.
3. **Ensiklopedia Materi Kimia SMA (Kurikulum Merdeka):**
   * Dikelompokkan rapi per tab: **Kelas X (Fase E)**, **Kelas XI (Fase F)**, dan **Kelas XII (Fase F)**.
   * Setiap bab memuat uraian konsep ringkas, blok rumus ilmiah presisi, contoh penerapan nyata (*Real-world application*), tombol penanda favorit (*bookmark*), dan tombol langsung menuju kuis latihan bab tersebut.
4. **Formula & Rumus Kimia Presisi:**
   * Ditampilkan dengan dukungan subskrip ($\text{H}_2\text{SO}_4$, $\text{H}_2\text{O}$), superskrip muatan ion ($\text{Ca}^{2+}$, $\text{SO}_4^{2-}$), dan panah reaksi ($\rightarrow$, $\rightleftharpoons$).
5. **Ensiklopedia Unsur Kimia (Tabel Periodik Mode Ganda):**
   * **Mode 1 (Daftar Kartu):** Grid kartu interaktif dengan filter cepat kategori (*Logam Alkali, Halogen, Gas Mulia, dll.*) serta pencarian instan nama/lambang unsur.
   * **Mode 2 (Tabel Periodik Penuh 18 Golongan):** Tampilan tabel periodik utuh yang dapat digeser secara horizontal.
   * **Detail Unsur:** Menampilkan nomor atom, lambang, nama Indonesia & Latin, massa atom relatif ($A_r$), golongan, periode, blok orbital ($s, p, d, f$), wujud zat, konfigurasi elektron, dan kegunaan nyata di kehidupan.
6. **Pencarian Universal (*Universal Search*):**
   * Kolom pencarian terpadu yang menampilkan hasil sekaligus dari 3 kategori: **Materi**, **Unsur Kimia**, dan **Istilah Glosarium**.
7. **Kamus Glosarium Kimia A–Z:**
   * Kamus istilah kimia lengkap dengan indeks abjad A sampai Z untuk pencarian definisi cepat.
8. **Kuis Interaktif, Gamifikasi & Misteri Kimia Dunia:**
   * Kuis pilihan ganda interaktif per bab materi.
   * Layar evaluasi skor dilengkapi **refleksi edukatif personal** dan ulasan pembahasan kunci jawaban ilmiah di setiap butir soal.
   * Siswa mendapatkan reward koin harian (**ChemCoins**) dari pengerjaan kuis.
   * **Misteri Kimia Dunia:** Artikel ilmiah misteri sains bumi (seperti *Api Biru Kawah Ijen* dan *Kaca Gurun Pasir Kuno*) yang dapat dibuka (*unlock*) menggunakan ChemCoins.
9. **Ketahanan Akses Offline (*Local Cache*):**
   * Aplikasi menyimpan cadangan data secara lokal sehingga materi yang pernah dimuat tetap dapat dibaca dengan lancar saat siswa tidak memiliki kuota internet atau sinyal sekolah lemah.

---

## 🗄️ Langkah 1: Setup Database Supabase

ChemPedia menggunakan database cloud Supabase untuk menyimpan seluruh konten master secara terpusat:

1. Buka [https://supabase.com](https://supabase.com) dan buat akun gratis.
2. Buat proyek baru (*New Project*), beri nama misalnya **chempedia-db**.
3. Di menu sebelah kiri, buka menu **SQL Editor**.
4. Salin seluruh isi file **`supabase/database_schema.sql`** yang ada di proyek ini, tempelkan ke SQL Editor Supabase, lalu tekan tombol **Run**.
5. Database Anda sekarang sudah terisi tabel `materials`, `elements`, `glossary`, `quizzes`, `quiz_questions`, `daily_facts`, dan `weekly_mysteries` lengkap dengan data awal kimia yang autentik!
6. Buka menu **Project Settings** $\rightarrow$ **API**, lalu catat:
   * **Project URL**
   * **Project API Keys (anon / public)**

---

## 🚀 Langkah 2: Build APK Otomatis via GitHub Actions

Anda tidak perlu menginstal Flutter SDK yang berat di komputer lokal. GitHub Actions akan mengompilasi kode program menjadi file `.apk` secara otomatis di cloud!

### A. Unggah Proyek ke Repositori GitHub
1. Buat repositori baru di akun [GitHub](https://github.com) Anda (misalnya diberi nama `chempedia-android`).
2. Unggah seluruh folder proyek ini ke repositori tersebut:
   * Jika menggunakan **GitHub Desktop**: Pilih *Add Existing Repository*, arahkan ke folder ini, lalu klik *Publish repository*.
   * Atau jika menggunakan **Git CLI** (di terminal):
     ```bash
     git init
     git add .
     git commit -m "Initial commit ChemPedia App"
     git branch -M main
     git remote add origin https://github.com/USERNAME_ANDA/chempedia-android.git
     git push -u origin main
     ```

### B. Konfigurasi Kredensial Rahasia (GitHub Secrets)
1. Buka repositori Anda di GitHub.
2. Klik tab **Settings** $\rightarrow$ **Secrets and variables** $\rightarrow$ **Actions**.
3. Klik tombol **New repository secret**, tambahkan 2 rahasia:
   * Name: `SUPABASE_URL` | Secret: *(Isi dengan Project URL Supabase Anda)*
   * Name: `SUPABASE_ANON_KEY` | Secret: *(Isi dengan Anon Public Key Supabase Anda)*

### C. Unduh File APK Hasil Build
1. Setiap kali Anda melakukan push atau klik tombol **Run workflow** di tab **Actions** di GitHub, alur kerja `.github/workflows/build_apk.yml` akan berjalan otomatis.
2. Tunggu proses build selesai (sekitar 3–5 menit hingga muncul centang hijau ✅).
3. Klik hasil build tersebut, scroll ke bagian bawah ke bagian **Artifacts**.
4. Klik **`ChemPedia-Release-APK`** untuk mengunduh file biner **`app-release.apk`**.

---

## 📲 Langkah 3: Memasang APK di Ponsel Android

1. Kirim file `app-release.apk` yang telah diunduh ke ponsel Android Anda (bisa melalui WhatsApp, Telegram, Google Drive, atau kabel data).
2. Di HP Android, buka file `app-release.apk`.
3. Jika muncul peringatan keamanan *"Instal aplikasi dari sumber tidak dikenal"*, pilih **Izinkan** (*Allow from this source*).
4. Selesai! Aplikasi ChemPedia siap digunakan untuk presentasi dan pengujian media pembelajaran.

---

## 📂 Struktur Folder Proyek

```text
chempedia/
├── .github/workflows/build_apk.yml   # Skrip CI/CD GitHub Actions APK
├── android/                          # Konfigurasi native Android & Gradle
├── assets/                           # Ikon & data
├── lib/
│   ├── core/
│   │   ├── constants/                # Palet warna pastel tematik & Supabase config
│   │   ├── theme/                    # Material 3 Theme modern
│   │   ├── utils/                    # FormulaParser (subskrip H2O, reaksi kimia)
│   │   └── widgets/                  # ChemistryBackground, CartoonAvatar, CoinBadge
│   ├── data/
│   │   ├── models/                   # Material, Element, Quiz, Glossary models
│   │   ├── repositories/             # AppRepository (Supabase + Offline Cache)
│   │   └── services/                 # LocalStorageService & SupabaseService
│   ├── modules/
│   │   ├── favorites/                # Halaman Materi Favorit Saya
│   │   ├── glossary/                 # Kamus Istilah Kimia A-Z
│   │   ├── home/                     # Beranda & Fakta Kimia Harian
│   │   ├── materials/                # Ensiklopedia Materi (Kelas X, XI, XII)
│   │   ├── mystery/                  # Misteri Kimia Dunia Terkunci Koin
│   │   ├── navigation/               # Bilah Navigasi 4-Tab Bawah
│   │   ├── onboarding/               # Setup Profil & Pilihan Karakter Kartun
│   │   ├── periodic_table/           # Tabel Periodik Mode Ganda & Detail Unsur
│   │   ├── quiz/                     # Kuis Gamifikasi, Skor, & Refleksi
│   │   └── search/                   # Pencarian Universal Terpadu
│   └── main.dart                     # Entry point aplikasi Flutter
├── supabase/
│   └── database_schema.sql           # Skrip SQL tabel, RLS, & seed data Kurikulum Merdeka
└── pubspec.yaml                      # Konfigurasi dependensi Flutter
```
