# Panduan Agen - Knowledge Base Project LK UKMs

Terakhir disusun: 2026-05-31.  
Sumber utama: `CLAUDE.md`, `AGENTS.md`, pemeriksaan struktur file project terkini.

## Ringkasan Project

Project ini adalah **LK UKMs - Sistem Proposal & LPJ LK UKMs**, aplikasi **PHP native tanpa framework** untuk manajemen:

- Proposal dan LPJ UKM
- Surat masuk/keluar dan disposisi
- Arsip surat/dokumen
- Arsip proposal
- Penggunaan ruangan
- Pengumuman
- User, role, activity logs
- Alur approval dinamis
- PDF pengesahan
- Notifikasi email/WhatsApp
- Analisis AI untuk arsip/proposal

Direktori `autopost/` adalah tool standalone dan harus diperlakukan terpisah dari aplikasi utama.

## Aturan Kerja untuk Agen

- Ikuti pola PHP native yang sudah ada; jangan memperkenalkan framework/runtime baru.
- Shell command harus diawali `rtk` sesuai instruksi project.
- Sebelum mengubah kode, pahami konteks dari file ini, `CLAUDE.md`, dan `AGENTS.md`.
- Hindari refactor besar kecuali memang diminta atau wajib untuk perubahan.
- Gunakan prepared statement untuk semua query SQL.
- Gunakan `getDBConnection()` dari `config/database.php` untuk akses database.
- Jangan percaya role/nilai permission dari client; gunakan session dan helper security.
- POST API wajib validasi CSRF.
- Response API JSON mengikuti pola `jsonResponse(['success' => ..., 'message' => ..., 'data' => ...])`, kecuali endpoint stream PDF/binary.
- Untuk output HTML dari data user, gunakan `sanitize()` atau escaping yang setara.
- Untuk upload, prioritaskan `uploadFileSecure()` dengan aturan MIME, extension, dan ukuran eksplisit.
- Gunakan `recordLog()` atau `recordLogSystem()` untuk aksi penting.
- Untuk approval chain, gunakan `normalizeApprover()` saat membandingkan approver/current_approver/username.

## Struktur Utama Project Terkini

```text
index.php                  Entry point dan router utama
config/database.php        DB config, session config, timezone, getDBConnection()
config/schema.sql          Referensi schema database
includes/functions.php     Helper umum, JSON response, upload, log, approval, config, WA
includes/security.php      CSRF, password, role guard, upload validation
includes/email.php         Email SMTP/PHPMailer
includes/env.php           Loader .env sederhana untuk integrasi AI
api/*.php                  Endpoint AJAX/API
pages/*.php                Halaman render server-side
modals/surat.php           Modal surat
public/css/styles.css      CSS tambahan
uploads/                   Penyimpanan file upload
templates/header.php       Header, Tailwind config, csrf token, wrapper layout
templates/sidebar.php      Sidebar/menu
templates/footer.php       Footer, toast helper, common JS
autopost/                  Tool posting konten terpisah dari aplikasi utama
```

## Routing Terkini (`index.php`)

Routing menerima pretty URL dan query fallback.

- Pretty URL halaman: `/dashboard`, `/proposal`, dst.
- API: `/api/auth`, `/api/proposal`, dst.
- Jika belum login dan bukan halaman `login`, diarahkan ke `/login`.
- Page tidak valid diarahkan ke `dashboard`.
- `surat_keluar` diarahkan ke `surat_masuk` karena satu halaman gabungan.

### API Routes Terdaftar

```text
api/auth
api/users
api/surat
api/proposal
api/penggunaan_ruangan
api/alur
api/pengumuman
api/laporan
api/arsip
```

Catatan: `api/wa_send.php` ada, tetapi tidak terdaftar di router utama; kemungkinan dipanggil langsung jika dipakai.

### Halaman Valid Terkini

```text
dashboard
surat_masuk
surat_keluar -> redirect ke surat_masuk
disposisi
proposal
arsip
arsip_proposal
users
profil
monitoring
alur
system_settings
pengumuman
activity_logs
penggunaan_ruangan
login
```

## Role dan Guard Halaman

Role umum yang dikenal dari dokumentasi/kode:

- `Super Admin`
- `Admin`
- `User`
- `Approver`
- `Disposisi`
- `Read Only`

Guard halaman di `index.php`:

- `Disposisi` hanya boleh: `dashboard`, `surat_masuk`, `disposisi`, `profil`, `login`; selain itu diarahkan ke `surat_masuk`.
- `Read Only` hanya boleh: `dashboard`, `surat_masuk`, `disposisi`, `proposal`, `profil`, `login`; selain itu diarahkan ke `dashboard`.
- `Approver` memakai menu ringkas: `dashboard`, `proposal`, `disposisi`, `profil`; tidak boleh mengakses `penggunaan_ruangan`.

Guard API harus tetap dilakukan di masing-masing endpoint memakai `requireRole()` / helper security, bukan hanya mengandalkan UI.

## Database

Database MySQL/MariaDB via mysqli. Charset `utf8mb4`. Timezone `Asia/Jakarta`.

`config/database.php` saat diperiksa:

- Host: `localhost`
- DB: `lkukm_db`
- User: `lkukm_user`
- Session lifetime: 8 jam
- Session cookie: `httponly`, `samesite=Lax`, secure mengikuti HTTPS
- `display_errors = 1` masih aktif untuk development; matikan untuk produksi.

### Tabel di `config/schema.sql` Terkini

```text
users
activity_logs
surat_masuk
surat_keluar
surat_disposisi
arsip
penggunaan_ruangan
pengumuman
proposal
proposal_revision_history
alur
system_config
```

## Helper Penting

Di `includes/functions.php`:

- `jsonResponse($data, $statusCode = 200)`
- `sanitize()`
- `recordLog($user, $activity)`
- `recordLogSystem($activity)`
- `uploadFileSmart()`
- `uploadFileSecure()`
- `sendWhatsAppNotification()`
- `getApprovalChain($pengaju)`
- `findApproverUsers($approver)`
- `normalizeApprover(string $s)`
- `getSystemConfig()`
- `saveSystemConfig()`
- `getSystemName()`
- `getSystemDescription()`

Di `includes/security.php`:

- `csrfGenerateToken()`
- `csrfValidateToken()`
- `requireCsrfToken()`
- `requireRole($allowedRoles)`
- `verifyPassword()` mendukung bcrypt dan legacy plaintext
- `upgradePasswordHash()` sekaligus set `force_change = 1`
- `hashPassword()`
- `validateFileUpload()`

## API Endpoint Terkini

### `api/auth.php`

POST actions:

- `login`
- `logout`
- `checkSession`
- `getCsrfToken`

### `api/users.php`

GET actions:

- `getUsers`
- `getUser`
- `getActivityLogs`
- `getDashboardStats`
- `getSystemSettings`

POST actions:

- `addUser`
- `updateUserProfile`
- `changeOwnPassword`
- `deleteUser`
- `resetUserPassword`
- `updateUserByAdmin`
- `saveSystemSettings`
- `sendLoginInfoWA`

### `api/surat.php`

GET actions:

- `getSuratMasuk`
- `getSuratKeluar`
- `getDisposisiBySurat`
- `getDisposisiList`
- `getMonitoringSurat`
- `generatePengesahanSurat` menghasilkan PDF langsung

POST actions:

- `addSuratMasuk`
- `addSuratKeluar`
- `addDisposisiSurat`
- `updateDisposisiStatus`
- `reviseSuratKeluar`
- `updateStatusSurat`
- `deleteSuratMasuk`
- `deleteSuratKeluar`

### `api/proposal.php`

GET actions:

- `getProposals`
- `getArchivePengaju`
- `getArchiveByPengaju`
- `getApprovalChain`
- `generateLembarPengesahan` menghasilkan PDF langsung
- `generateLembarPengesahanLPJ` menghasilkan PDF langsung

POST actions:

- `addProposal`
- `updateStatusProposal`
- `reviseProposal`
- `sendReminder`
- `editProposalByAdmin`
- `updateProposalFinancialStatus`
- `deleteProposal`
- `analyzeProposal`
- `extractTextProposal`
- `continueAnalysisProposal`

### `api/alur.php`

GET actions:

- `getAlur`
- `getApproverUsers`
- `getUKMUsers`

POST actions:

- `addAlur`
- `updateAlur`
- `deleteAlur`

### `api/pengumuman.php`

GET actions:

- `getAnnouncements`

POST actions:

- `addAnnouncement`
- `deleteAnnouncement`

### `api/arsip.php`

GET actions:

- `getArsipData`
- `getAnnouncements`

POST actions:

- `addArsipData`
- `deleteArsip`
- `addAnnouncement`
- `deleteAnnouncement`
- `analyzeArsip`
- `extractTextArsip`
- `continueAnalysisArsip`

### `api/penggunaan_ruangan.php`

GET actions:

- `getPenggunaanRuangan`

POST actions:

- `addPenggunaanRuangan`
- `updatePenggunaanRuangan`

## Proposal dan LPJ

- Proposal dan LPJ memakai tabel yang sama: `proposal`.
- Pembeda utama adalah field `jenis` (`Proposal` atau `LPJ`).
- LPJ dapat mengacu ke proposal asal via `parent_proposal_id`.
- Approval chain disimpan di tabel `alur` dengan kolom `acc1` sampai `acc6`.
- `current_approver` menunjukkan approver aktif.
- `history` proposal disimpan sebagai JSON.
- Gunakan `normalizeApprover()` saat mencocokkan nama/username approver.

### PDF Proposal/LPJ

- Proposal: `api/proposal.php?action=generateLembarPengesahan&id=...`
- LPJ: `api/proposal.php?action=generateLembarPengesahanLPJ&id=...`
- Output stream PDF langsung via TCPDF; jangan pakai `jsonResponse()` untuk sukses.
- Akses PDF approval sheet umumnya untuk `Super Admin`, username `ketua-dpm`, atau pemilik/pengaju dokumen.
- Proposal approval sheet butuh `jenis != LPJ` dan `status = Disetujui`.
- LPJ approval sheet butuh `jenis = LPJ` dan `status = Disetujui`.
- UI action visibility ada di `pages/proposal.php`, fungsi JS terkait seperti `canGenerateLembar()` dan `canGenerateLembarLPJ()`.

## Surat, Disposisi, dan Pengesahan

- Surat masuk dan surat keluar punya tabel berbeda (`surat_masuk`, `surat_keluar`) tetapi UI utama digabung di `pages/surat_masuk.php` dan API di `api/surat.php`.
- Disposisi memiliki halaman sendiri `pages/disposisi.php` dan tabel `surat_disposisi`.
- Pengesahan surat memakai `api/surat.php?action=generatePengesahanSurat` dan menghasilkan PDF langsung.

## Arsip dan AI

- Ada modul arsip di `pages/arsip.php` dan `api/arsip.php`.
- Ada arsip proposal di `pages/arsip_proposal.php` yang terkait endpoint proposal archive.
- `api/arsip.php` dan `api/proposal.php` memiliki fitur analisis AI.
- Konfigurasi AI memakai `.env` melalui `includes/env.php`.
- `.env.example` berisi:
  - `OPENCODE_ZEN_API_KEY`
  - `OPENCODE_ZEN_MODEL`
  - `OPENCODE_ZEN_ENDPOINT`
- Jangan commit/menampilkan isi `.env` yang berisi secret.

## Frontend dan Layout

- Halaman umumnya include `templates/header.php`, `templates/sidebar.php`, lalu `templates/footer.php`.
- `templates/header.php` juga memuat Tailwind CDN, Font Awesome, Chart.js, `public/css/styles.css`, dan set `window.csrfToken`.
- Tailwind theme utama maroon:
  - `primary`: `#8B1538`
  - `primary-dark`: `#6B0F2A`
  - `primary-light`: `#A0204D`
- Gunakan helper JS global `showToast(message, type)` dari `templates/footer.php` untuk feedback user.
- Semua POST fetch/form dari frontend harus menyertakan `csrf_token: window.csrfToken`.

Catatan kondisi terkini: `templates/header.php` sudah include `templates/sidebar.php` saat bukan login, tetapi banyak page juga masih include `templates/sidebar.php` secara eksplisit. Jangan mengubah pola layout ini tanpa mengecek dampak visual karena bisa menjadi legacy behavior project.

## Dependencies

Composer dependencies:

- `tecnickcom/tcpdf:^6.10` untuk PDF
- `endroid/qr-code:^6.0` untuk QR code
- `phpmailer/phpmailer:^6.9` untuk email SMTP

Gunakan:

```bash
rtk composer install
```

## Upload dan File

- Upload disimpan di `uploads/{category}_{username}/`.
- Nama file memakai prefix unik untuk menghindari overwrite.
- Untuk upload baru, gunakan `uploadFileSecure()` jika memungkinkan.
- Tetapkan MIME, extension, dan size limit eksplisit.

## Notifikasi

- Email menggunakan PHPMailer di `includes/email.php`.
- WhatsApp menggunakan `sendWhatsAppNotification()` di `includes/functions.php`.
- Ada file test `test_wa.php`.
- Untuk test lokal: `rtk php test_wa.php`.

## System Config

Konfigurasi sistem berada di tabel `system_config` dan helper `getSystemConfig()`/`saveSystemConfig()`.

Key yang disebut di dokumentasi/kode antara lain:

- `OPEN_SURAT`
- `SYSTEM_NAME`
- `SYSTEM_DESC`

## Local Checks yang Disarankan

- Cek syntax PHP file tertentu:

```bash
rtk php -l path/to/file.php
```

- Install dependency:

```bash
rtk composer install
```

- Utility scripts tersedia di `scripts/`:

```text
check_alur.php
check_detail.php
check_proposal.php
check_url.php
check_user.php
ensure_superadmin.php
import_google_csv.php
```

Contoh:

```bash
rtk php scripts/check_alur.php
rtk php scripts/check_detail.php
```

## Perbedaan Penting dari `CLAUDE.md` yang Perlu Diingat

Beberapa poin di `CLAUDE.md` tampak sudah tertinggal dari kondisi project terkini:

- `api/arsip` sekarang sudah terdaftar di router `index.php`.
- `api/penggunaan_ruangan` sekarang juga terdaftar.
- Halaman `arsip`, `arsip_proposal`, `disposisi`, dan `penggunaan_ruangan` sekarang valid di router.
- Schema sekarang mencakup `surat_disposisi`, `penggunaan_ruangan`, dan `proposal_revision_history`.
- Session lifetime di `config/database.php` sekarang diset 8 jam.

Jika ada konflik antara `CLAUDE.md` dan kondisi file terkini, prioritaskan kode terkini lalu update dokumentasi bila diperlukan.
