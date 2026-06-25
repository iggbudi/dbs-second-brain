# Analisis Codebase LK UKMs

> **Tanggal analisis:** 15 Juni 2026
> **URL:** https://lk.pjdigital.top
> **Organisasi:** Universitas Stikubank (UNISBANK) Semarang

---

## 1. Ringkasan Proyek

LK UKMs adalah aplikasi web PHP native untuk manajemen dokumen organisasi kemahasiswaan. Sistem ini mengelola siklus hidup proposal, LPJ (Laporan Pertanggungjawaban), surat masuk/keluar, disposisi, pengumuman, dan arsip — lengkap dengan alur persetujuan multi-tahap, notifikasi WhatsApp & email, serta analisis dokumen berbasis AI. Modul KIPK dikelola di project terpisah.

| Aspek | Detail |
|-------|--------|
| **Bahasa** | PHP 8+ (backend), Vanilla JavaScript (frontend) |
| **Framework** | Tidak ada — PHP native murni |
| **Database** | MySQL / MariaDB (`lkukm_db`, charset `utf8mb4`) |
| **Web Server** | Apache dengan `.htaccess` rewrite |
| **CSS** | Tailwind CSS (CDN), tema maroon `#8B1538` |
| **Ikon** | Font Awesome 6.4.0 |
| **Chart** | Chart.js (CDN) |
| **PDF** | TCPDF (Composer) |
| **Email** | PHPMailer via Gmail SMTP |
| **QR Code** | endroid/qr-code v6.0 |
| **AI** | OpenCode Zen / SumoPod MiniMax-M2.7-highspeed |

---

## 2. Struktur Direktori

```
/var/www/lk.pjdigital.top/
├── index.php                   # Entry point & router utama
├── .htaccess                   # Apache rewrite rules
├── composer.json               # Dependencies PHP
├── .env                        # Konfigurasi API key (AI, WhatsApp)
│
├── api/                        # Endpoint API (9 file)
│   ├── auth.php                # Login, logout, session, CSRF
│   ├── users.php               # CRUD user, statistik dashboard, pengaturan sistem
│   ├── surat.php               # Surat masuk, keluar, disposisi (~2364 baris)
│   ├── proposal.php            # Proposal, LPJ, revisi, analisis AI (~2504 baris)
│   ├── penggunaan_ruangan.php  # Penjadwalan ruangan
│   ├── alur.php                # Manajemen alur persetujuan (Super Admin)
│   ├── laporan.php             # Export laporan Excel
│   ├── pengumuman.php          # Pengumuman
│   ├── arsip.php               # Arsip + analisis AI dokumen
│   └── wa_send.php             # Kirim pesan WhatsApp
│
├── config/
│   ├── database.php            # Koneksi DB, session, timezone
│   └── schema.sql              # Skema database lengkap (11 tabel)
│
├── includes/
│   ├── env.php                 # Loader file .env
│   ├── functions.php           # Helper function inti (700+ baris)
│   ├── security.php            # CSRF, hashing, rate limiting, RBAC
│   └── email.php               # Kirim email via PHPMailer
│
├── templates/
│   ├── header.php              # HTML head, CDN, security headers
│   ├── sidebar.php             # Navigasi berbasis role
│   └── footer.php              # Toast, loading overlay, JS utilities
│
├── pages/                      # 16 halaman
│   ├── login.php               # Halaman login
│   ├── dashboard.php           # Dashboard dengan statistik live
│   ├── surat_masuk.php         # Manajemen surat masuk & keluar
│   ├── disposisi.php           # Manajemen disposisi
│   ├── proposal.php            # Manajemen proposal & LPJ (~2515 baris)
│   ├── penggunaan_ruangan.php  # Penjadwalan ruangan
│   ├── monitoring.php          # Monitoring admin
│   ├── pengumuman.php          # Halaman pengumuman
│   ├── arsip.php               # Manajemen arsip
│   ├── arsip_proposal.php      # Arsip proposal (Super Admin)
│   ├── alur.php                # Manajemen alur persetujuan
│   ├── users.php               # Manajemen user
│   ├── profil.php              # Profil user
│   ├── activity_logs.php       # Log aktivitas
│   └── system_settings.php     # Pengaturan sistem
│
├── modals/
│   └── surat.php               # Template modal untuk form surat
│
├── public/
│   ├── css/styles.css          # CSS kustom (sidebar, badge, scrollbar)
│   └── js/                     # (kosong)
│
├── autopost/                   # Modul auto-posting media sosial (terpisah)
│   ├── config.php              # Konfigurasi API Repliz
│   ├── index.php               # Endpoint POST
│   ├── ReplizClient.php        # Client API Repliz
│   └── ...
│
├── scripts/                    # Script utilitas & migrasi
│   ├── check_alur.php
│   ├── check_detail.php
│   ├── check_proposal.php
│   ├── import_google_csv.php
│   └── ...
│
├── uploads/                    # File upload (per-user)
│   ├── proposal_ukm_*/         # File proposal per UKM
│   ├── suratmasuk_*/           # Surat masuk per UKM
│   ├── suratkeluar_*/          # Surat keluar per UKM
│   ├── pengesahan_surat/       # PDF pengesahan yang di-generate
│   └── ...
│
├── vendor/                     # Composer dependencies
│   ├── phpmailer/
│   ├── tecnickcom/tcpdf/
│   └── endroid/qr-code/
│
└── docs/                       # Dokumentasi pengembangan
```

---

## 3. Arsitektur Routing

### Entry Point: `index.php`

Routing menggunakan pendekatan dual:

1. **Pretty URL** — `.htaccess` me-rewrite URL bersih (contoh: `/api/auth` → `api/auth.php`, `/dashboard` → `pages/dashboard.php`)
2. **Query parameter fallback** — `?page=dashboard` jika pretty URL gagal

### Route API (9 endpoint)

| URL | File | Method |
|-----|------|--------|
| `/api/auth` | `api/auth.php` | POST |
| `/api/users` | `api/users.php` | GET/POST |
| `/api/surat` | `api/surat.php` | GET/POST |
| `/api/proposal` | `api/proposal.php` | GET/POST |
| `/api/penggunaan_ruangan` | `api/penggunaan_ruangan.php` | GET/POST |
| `/api/alur` | `api/alur.php` | GET/POST |
| `/api/laporan` | `api/laporan.php` | GET/POST |
| `/api/pengumuman` | `api/pengumuman.php` | GET/POST |
| `/api/arsip` | `api/arsip.php` | GET/POST |
| `/api/wa_send` | `api/wa_send.php` | POST |

### Route Halaman (16 halaman)

`dashboard`, `surat_masuk`, `surat_keluar` (redirect ke surat_masuk), `disposisi`, `proposal`, `arsip`, `arsip_proposal`, `users`, `profil`, `monitoring`, `alur`, `system_settings`, `pengumuman`, `activity_logs`, `penggunaan_ruangan`, `login`

### Guard Halaman

- Semua halaman memerlukan login kecuali `login`
- Role **Disposisi** dibatasi: dashboard, surat_masuk, disposisi, profil, login
- Role **Read Only** dibatasi: dashboard, surat_masuk, disposisi, proposal, profil, login

---

## 4. Struktur Database

**12 tabel** di database `lkukm_db`:

| Tabel | Fungsi | Kolom Kunci |
|-------|--------|-------------|
| `users` | Akun pengguna | id, username, password, name, role, jabatan, sebutan, phone, email, nim, unit, force_change |
| `activity_logs` | Audit trail | id, waktu, username, nama_lengkap, role, aktivitas |
| `surat_masuk` | Surat masuk | id, nomor_surat, tanggal_terima, pengirim, no_hp, perkara, kategori, status, url_dokumen, owner |
| `surat_keluar` | Surat keluar | id, nomor_surat, tanggal_kirim, tujuan, perkara, kategori, status, history (JSON), url_dokumen, created_by |
| `surat_disposisi` | Disposisi surat | id, surat_masuk_id, dari_username, kepada_username, isi_disposisi, prioritas, tenggat, status |
| `proposal` | Proposal & LPJ | id, nama_kegiatan, jenis (Proposal/LPJ), pengaju, status, status_keuangan, url_file, ai_analysis, current_approver, parent_proposal_id, history (JSON) |
| `proposal_revision_history` | Riwayat revisi | id, proposal_id, revision_cycle, version_no, event_type, approver_username |
| `alur` | Alur persetujuan | id, pengaju, acc1–acc6 |
| `arsip` | Arsip dokumen | id, tanggal, nama_surat, perkara, url_file, uploaded_by, content_text, ai_analysis |
| `penggunaan_ruangan` | Jadwal ruangan | id, tanggal, jam_mulai, jam_selesai, ruangan, pengguna_ruangan |
| `pengumuman` | Pengumuman | id, tanggal, isi, created_by |
| `proposal_reminder_log` | Log reminder proposal | id, proposal_id, milestone, recipient_type |
| `system_config` | Konfigurasi sistem | id, config_key, config_value |

### Konfigurasi Default
- `OPEN_SURAT`: ON
- `SYSTEM_NAME`: "LK UKMs"
- `SYSTEM_DESC`: "Sistem Proposal & LPJ"
- Admin default: `superadmin` / `admin123` (plaintext di schema, auto-upgrade ke bcrypt saat login pertama)

---

## 5. Sistem Autentikasi & Otorisasi

### Alur Login

1. User mengirim username + password via POST ke `/api/auth` (action: `login`)
2. Token CSRF divalidasi
3. Rate limiting dicek (5 percobaan / 15 menit per IP+username, disimpan di file temp)
4. Password diverifikasi (mendukung plaintext legacy & bcrypt)
5. Jika plaintext terdeteksi, otomatis upgrade ke bcrypt
6. Session di-regenerate (`session_regenerate_id(true)`)
7. Token CSRF di-rotate
8. Data user disimpan di `$_SESSION['user']`

### Konfigurasi Session

- Lifetime: 8 jam (`session.gc_maxlifetime` = 28800)
- Cookie: httponly=true, SameSite=Lax, secure flag sesuai HTTPS
- Custom save path: `/var/lib/php/lk_pjdigital_sessions`

### Sistem Password

| Fungsi | Fungsi |
|--------|--------|
| `isLegacyPassword()` | Deteksi plaintext (< 60 char atau tanpa prefix `$2y$`) |
| `verifyPassword()` | Verifikasi plaintext atau `password_verify()` |
| `hashPassword()` | Hash bcrypt via `password_hash()` |
| `upgradePasswordHash()` | Migrasi otomatis plaintext → bcrypt |
| `force_change` flag | Paksa ganti password saat login pertama |

### Role-Based Access Control (RBAC)

| Role | Kemampuan |
|------|-----------|
| **Super Admin** | Akses penuh: user management, pengaturan sistem, alur persetujuan, semua data |
| **Admin** | User management (terbatas), monitoring, pengumuman, log aktivitas |
| **User** | Submit proposal/LPJ, kelola surat masuk sendiri, lihat data sendiri |
| **Approver** | Review/approve proposal yang ditugaskan, lihat jadwal ruangan |
| **Disposisi** | Lihat surat masuk, kelola disposisi saja |
| **Read Only** | Akses baca-saja: dashboard, surat, disposisi, proposal |

### Pola Penegakan Role

- Server-side `requireRole()` memeriksa `$_SESSION['user']['role']`
- Role diambil dari database saat login, tidak pernah dari client
- `requireLogin()` memeriksa keberadaan session
- Pengecekan tambahan per-fungsi (misal: approver hanya bisa bertindak saat gilirannya)

---

## 6. Modul Utama

### 6.1 Proposal & LPJ

**Alur siklus hidup:**
```
Draft → Disubmit → Dalam Review (per approver) → Disetujui / Ditolak / Revisi
  → Proses Keuangan → Dicairkan → LPJ Wajib → LPJ Disubmit → LPJ Disetujui
```

**Fitur utama:**
- Alur persetujuan multi-tahap (maks. 6 approver) terkonfigurasi per pengaju via tabel `alur`
- LPJ terkait ke proposal induk via `parent_proposal_id`
- LPJ hanya bisa dibuat jika `status_keuangan = 'Dicairkan'`
- Pelacakan revisi dengan penomoran siklus/versi
- Pelacakan status keuangan: Menunggu → Proses Keuangan → Dicairkan
- Generate PDF pengesahan (Lembar Pengesahan) via TCPDF
- Analisis dokumen berbasis AI (ekstraksi teks PDF → analisis MiniMax)
- Kunci idempotensi untuk mencegah duplikasi
- Notifikasi WhatsApp & email ke approver dan pengaju

### 6.2 Surat (Manajemen Surat)

**Surat Masuk:**
- CRUD lengkap dengan upload file (PDF/DOCX)
- Kategori: Undangan, Permohonan, Laporan, Pemberitahuan, Peminjaman Ruangan, Lainnya
- Status tracking: Menunggu, Diproses, Selesai, Ditolak

**Surat Keluar:**
- Nomor surat otomatis
- Riwayat status dalam format JSON
- Revisi surat keluar
- Generate PDF pengesahan surat

**Disposisi:**
- Teruskan surat ke user lain dengan prioritas & tenggat
- View Kotak Masuk / Terkirim
- Prioritas: Rendah, Sedang, Tinggi
- Status: Terkirim, Dibaca, Diproses, Selesai
- Filter, search, pagination, sorting

### 6.3 Penjadwalan Ruangan

- Booking berbasis kalender
- Filter bulan & ruangan
- Validasi waktu (jam_selesai > jam_mulai)
- Super Admin bisa create/edit, semua user bisa lihat

### 6.4 Arsip Dokumen

- Arsipkan dokumen dengan upload file
- Integrasi analisis AI
- Ekstraksi teks PDF + caching di kolom `content_text`
- Cache analisis AI via `ai_prompt_hash` (hindari panggilan API berulang)

### 6.5 Analisis Dokumen AI

- Menggunakan API OpenCode Zen / SumoPod MiniMax-M2.7-highspeed
- Menghasilkan analisis terstruktur: Ringkasan, Kategori, Prioritas, Insight
- Mendukung kelanjutan jika output terpotong
- Caching dengan hash MD5 prompt
- Pelacakan penggunaan di kolom `ai_usage` (JSON)
- Berlaku untuk proposal dan dokumen arsip

### 6.6 Dashboard

- Statistik & kartu aksi berbasis role
- Perhitungan tren (perbandingan 30 hari vs 60 hari)
- Auto-refresh setiap 60 detik (visibility-aware)
- Chart tren user aktif (range 7/14/30 hari)
- Ringkasan keuangan untuk role Admin
- Tampilan pengumuman

### 6.7 Manajemen User

- CRUD user (Super Admin)
- Reset password dengan generate random
- Email selamat datang dengan template HTML branded
- Kirim info login via WhatsApp
- Force password change pada login pertama

### 6.8 Pengaturan Sistem

- Konfigurasi nama & deskripsi sistem
- Toggle fitur surat (`OPEN_SURAT`)
- Konfigurasi AI terpusat

### 6.9 Log Aktivitas

- Setiap aksi dicatat dengan timestamp, user, role, aktivitas
- Logging event terstruktur dengan payload JSON
- Request ID untuk korelasi
- Redaksi data sensitif (password, token, data base64)
- Derivasi kategori/level untuk UI

### 6.10 Pengumuman

- CRUD pengumuman (Admin/Super Admin buat, Super Admin hapus)
- Ditampilkan di dashboard

---

## 7. Integrasi Eksternal

### 7.1 WhatsApp (via wa.dwibudi.my.id)

| Aspek | Detail |
|-------|--------|
| **Endpoint** | `https://wa.dwibudi.my.id/instances/{id}/messages` |
| **Instance ID** | `2e47ed5a-c719-4916-80e9-5e778e18e581` |
| **Library** | cURL (timeout 10 detik, SSL verify disabled) |
| **Penggunaan** | Notifikasi proposal, disposisi, info login |
| **Normalisasi** | Nomor 0xxx → 62xxx |

### 7.2 Email (PHPMailer + Gmail SMTP)

| Aspek | Detail |
|-------|--------|
| **SMTP** | `smtp.gmail.com:587` dengan STARTTLS |
| **From** | `dbs@edu.unisbank.ac.id` |
| **Penggunaan** | Email selamat datang, notifikasi status proposal, notifikasi disposisi |
| **Template** | HTML email branded dengan tema maroon gradient |

### 7.3 Analisis AI (OpenCode Zen / SumoPod)

| Aspek | Detail |
|-------|--------|
| **Endpoint** | Konfigurabel via Dashboard (Super Admin → Pengaturan Sistem → Konfigurasi AI) |
| **Model** | Konfigurabel via Dashboard, default `MiniMax-M2.7-highspeed` |
| **API Key** | Konfigurabel via Dashboard, fallback ke `.env` |
| **Timeout** | 180 detik (via `.env` → `OPENCODE_ZEN_TIMEOUT`) |
| **Penggunaan** | Analisis proposal, analisis dokumen arsip |
| **Bahasa** | Prompt & output dalam Bahasa Indonesia |

**Urutan prioritas konfigurasi:** Database (`system_config`) → `.env` → hardcoded default.
Super Admin dapat mengubah Base URL, API Key, dan Model langsung dari halaman Pengaturan Sistem tanpa akses server.

### 7.4 PDF (TCPDF)

- Generate Lembar Pengesahan proposal & LPJ
- Generate pengesahan surat
- Konversi DOCX → PDF (ekstraksi teks, bukan formatting)
- Format A4, font Helvetica

### 7.5 Ekstraksi Teks PDF (pdftotext)

- Command-line tool `pdftotext`
- Ekstraksi teks dari PDF untuk analisis AI
- Teks disimpan di kolom `content_text` (maks. 50.000 karakter)
- Pada Analisis AI proposal/LPJ, kegagalan ekstraksi PDF bersifat non-blocking: sistem tetap menganalisis metadata dokumen dan menampilkan warning bahwa isi PDF belum dapat dibaca.
- Warning fallback dikirim melalui response `extractionWarning` dan ditampilkan di modal Analisis AI; pesan tidak memuat path server, stderr mentah, secret, atau isi konfigurasi.

### 7.6 QR Code (endroid/qr-code v6.0)

- Digunakan dalam PDF pengesahan

### 7.7 Auto-Posting Media Sosial (Repliz API)

- Modul terpisah di `/autopost/`
- Mendukung: Threads, Instagram, TikTok
- Akun: @marysauda (Threads/IG), @pamomong.tersembunyi (TikTok)

---

## 8. Frontend Stack

### CSS & Design

| Komponen | Sumber |
|----------|--------|
| Tailwind CSS | CDN (`cdn.tailwindcss.com`) |
| Font Awesome | CDN (v6.4.0) |
| Google Fonts | Inter (300–800) |
| Custom CSS | `/public/css/styles.css` |
| Warna utama | Maroon `#8B1538` → `#A0204D` → `#6B0F2A` |

### JavaScript

- **Vanilla JavaScript** — tanpa framework (tidak ada React, Vue, jQuery)
- **Chart.js** (CDN) untuk chart dashboard
- Fetch API untuk AJAX
- Semua JS inline di file halaman atau di `footer.php`
- Tidak ada build tools (tidak ada webpack, npm, Vite)

### Pola UI

- Layout berbasis card dengan rounded corners & shadow
- Sidebar responsif (collapsible desktop, slide-in mobile)
- Toast notification (success/error/info)
- Modal dialog (multiple per halaman)
- Badge status dengan warna semantik
- Filter chips & tab chips
- Loading overlay

---

## 9. Pola Keamanan

### 9.1 Proteksi CSRF

- Token di-generate per session dengan `random_bytes(32)`
- Token di-rotate setelah login (`csrfRotateToken()`)
- Validasi via `hash_equals()` (timing-safe)
- Wajib untuk semua POST request
- Dikirim via field `csrf_token` atau header `X-CSRF-Token`

### 9.2 Sanitasi Input

- Fungsi `sanitize()`: `trim()` → `stripslashes()` → `htmlspecialchars(ENT_QUOTES, UTF-8)`
- Diterapkan ke semua input user sebelum diproses

### 9.3 Pencegahan SQL Injection

- **Semua query menggunakan prepared statements** (`mysqli` + `bind_param()`)
- Whitelist validasi untuk nama kolom dinamis (sort, table)
- Parameterized IN clause untuk batch query

### 9.4 Pencegahan XSS

- `htmlspecialchars()` untuk semua output PHP
- `textContent` lebih dipilih daripada `innerHTML` di JS
- Security headers: `X-Content-Type-Options: nosniff`, `X-Frame-Options: DENY`, `X-XSS-Protection: 1; mode=block`

### 9.5 Keamanan Upload

- Whitelist ekstensi (PDF untuk proposal/surat, lebih luas untuk umum)
- Validasi MIME type via `finfo_file()` (bukan hanya cek ekstensi)
- Limit ukuran file (10MB default, 5MB untuk gambar)
- Sanitasi nama file (regex hapus non-alphanumeric)
- Generate nama file unik dengan `uniqid()`
- Pipeline: sanitasi → whitelist → decode → size check → temp file → MIME verify → move

### 9.6 Keamanan Session

- `session_regenerate_id(true)` saat login & logout
- Lifetime 8 jam
- Cookie: httponly, SameSite=Lax, secure flag sesuai HTTPS

### 9.7 Rate Limiting

- Login: 5 percobaan / 15 menit per IP+username
- Disimpan di file temp (bukan database, untuk performa)
- Auto-cleanup setelah window expired

### 9.8 Keamanan Password

- Auto-upgrade plaintext → bcrypt saat login
- `password_needs_rehash()` untuk upgrade algoritma
- Flag `force_change` untuk password wajib ganti
- Password random 12 karakter untuk reset admin

### 9.9 Error Handling

- Production: `display_errors = 0`, `log_errors = 1`
- Structured error handler untuk API (exception, error, fatal)
- Request ID untuk korelasi error
- Redaksi data sensitif di log (password, token, payload base64)

### 9.10 CORS

- Whitelist origin (localhost, 127.0.0.1, host saat ini)
- Reflect origin jika dalam whitelist

### 9.11 Keamanan Konten

- `.htaccess` blokir akses ke file `.sql`, `.md`, `.json`
- `Options -Indexes` cegah directory listing
- Monitoring ukuran POST body

### 9.12 Sanitasi Error Message

- Error dari provider eksternal (AI) di-log ke server `error_log` dengan prefix kontekstual (`[AI Arsip]`, `[AI Proposal]`)
- Client menerima pesan generik berbahasa Indonesia, bukan error mentah dari provider
- Mencegah kebocoran detail jaringan internal, status API key, dan infrastruktur provider

---

## 10. Pola Kode & Konvensi

### Pola Umum

| Pola | Implementasi |
|------|-------------|
| **Singleton DB** | `getDBConnection()` di `config/database.php` — satu koneksi mysqli |
| **Response JSON** | `jsonResponse(['success' => ..., 'message' => ..., 'data' => ...])` |
| **Security check** | `requireLogin()` + `requireRole(['role1', 'role2'])` di awal setiap handler |
| **CSRF check** | `validateCsrfToken()` di awal setiap POST handler |
| **Logging** | `recordLog($aktivitas)` atau `recordLogSystem(...)` untuk aksi bermakna |
| **Upload** | `uploadFileSecure($file, 'proposal', ...)` dengan validasi ketat |
| **Sanitasi output** | `sanitize($value)` sebelum tampil di HTML |
| **Approver compare** | `normalizeApprover()` untuk perbandingan case/space-insensitive |

### Pola Database

- Semua query menggunakan prepared statements
- Tabel `proposal` memiliki kolom `history` (JSON) untuk jejak status
- Tabel `surat_keluar` memiliki kolom `history` (JSON) untuk jejak status
- Dynamic table creation via `ensure*Table()` functions (migration-like tanpa sistem migrasi formal)
- Kolom `ai_analysis` dan `content_text` untuk caching hasil AI

### Pola Frontend

- Setiap halaman: include header → konten → include footer
- AJAX via `apiCall(action, data)` helper dari footer.php
- `showToast(message, type)` untuk feedback user
- Modal pattern: `<div id="modalXxx" class="hidden fixed inset-0 ...">`
- Status badge: `getStatusClass(status)` mengembalikan class Tailwind

---

## 11. Catatan Teknis Penting

1. **File terbesar:** `pages/proposal.php` (~2515 baris), `api/proposal.php` (~2504 baris), `api/surat.php` (~2364 baris) — mengandung HTML, PHP, dan JS inline dalam satu file.

2. **Tidak ada framework JS:** Seluruh frontend dibangun dengan vanilla JS dan inline `<script>`. Tidak ada component system, state management, atau virtual DOM.

3. **Tidak ada build tools:** Tidak ada webpack, Vite, npm. Semua asset dari CDN atau file statis.

4. **Dual login pattern:** Halaman login (`pages/login.php`) melakukan form POST server-side, sementara auth API (`api/auth.php`) menangani AJAX login. Keduanya menggunakan mekanisme keamanan yang sama.

5. **Konversi DOCX → PDF:** Sistem mengkonversi DOCX ke PDF dengan mengekstrak teks dari XML dan merendernya dengan TCPDF (konversi plain-text, tidak mempertahankan formatting).

6. **Normalisasi approver:** Identifier approver dinormalisasi (spasi diperlakukan sebagai underscore) sehingga "bem ftii" cocok dengan username "bem_ftii".

7. **Autopost module:** Modul posting media sosial terpisah di `/autopost/` — tidak terintegrasi dengan aplikasi utama.

8. **Environment-aware error handling:** Membaca `APP_ENV` dan `APP_DEBUG` untuk menentukan tampilkan atau sembunyikan error.

---

## 12. Statistik Codebase

| Komponen | Jumlah |
|----------|--------|
| File API | 10 file |
| File halaman | 16 file |
| File template | 3 file |
| File include | 4 file |
| Tabel database | 12 tabel |
| Role | 6 role |
| Composer dependencies | 3 (PHPMailer, TCPDF, QR Code) |

### Estimasi Ukuran (file utama)

| File | Estimasi Baris |
|------|---------------|
| `pages/proposal.php` | ~2515 |
| `api/proposal.php` | ~2504 |
| `api/surat.php` | ~2364 |
| `pages/surat_masuk.php` | ~1500+ |
| `includes/functions.php` | ~700+ |
| `includes/security.php` | ~400+ |
| `templates/sidebar.php` | ~300+ |
| `pages/dashboard.php` | ~400+ |

---

## 13. Kesimpulan

LK UKMs adalah aplikasi PHP native yang **solid dan berfitur lengkap** untuk mengelola dokumen organisasi kemahasiswaan. Kelebihan utamanya:

- ✅ Keamanan ketat (prepared statements, CSRF, rate limiting, RBAC, upload validation)
- ✅ Alur persetujuan multi-tahap yang fleksibel
- ✅ Integrasi notifikasi lengkap (WhatsApp + email)
- ✅ Analisis dokumen berbasis AI dengan caching
- ✅ Audit trail komprehensif
- ✅ Auto-upgrade password security (plaintext → bcrypt)

Area yang bisa ditingkatkan di masa depan:
- 📌 File-file besar (>2000 baris) bisa dipecah menjadi komponen lebih kecil
- 📌 Tidak ada automated testing (unit test, integration test)
- 📌 Tidak ada sistem migrasi database formal
- 📌 Frontend bisa mendapat manfaat dari framework JS untuk maintainability
- 📌 Beberapa credential hardcoded (SMTP password, WhatsApp instance ID) — idealnya dipindahkan ke `.env`
