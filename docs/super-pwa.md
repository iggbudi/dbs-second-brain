# Refactor Mobile PWA — Role Super Admin

Setelah refactor mobile berhasil untuk role **User** (Sprint U1–U6) dan **Approver**, sekarang giliran **Super Admin** mendapat pengalaman mobile yang setara.

## Kondisi Saat Ini

Super Admin di mobile (≤1023px) **tidak punya optimasi mobile sama sekali**:
- ❌ Tidak ada bottom navigation — masih pakai sidebar + hamburger
- ❌ Tidak ada tombol logout mobile
- ❌ Tidak ada padding-bottom untuk bottom nav
- ❌ Halaman-halaman utama masih render tabel desktop dengan horizontal scroll
- ❌ Tombol aksi di beberapa halaman pakai `opacity-0 group-hover:opacity-100` — **tidak bisa diakses di layar sentuh**

### Tantangan Utama vs User/Approver

| Aspek | User | Approver | Super Admin |
|-------|------|----------|-------------|
| Total menu | 4 | 4 | **14** |
| Halaman eksklusif | 0 | 0 | **4** (Users, Alur, Arsip, Settings) |
| Halaman berat tabel | 2 | 2 | **7+** |
| Bottom nav items | 4 | 4 | **5** (termasuk "Lainnya") |

> Super Admin punya **14 menu item** — terlalu banyak untuk bottom nav biasa.
> Rencana ini menggunakan pola **4 item utama + tombol "Lainnya"** yang membuka menu grid (bottom sheet), mirip pola app banking/super-app.

## Open Questions

> **Q1: Apakah semua 14 halaman perlu dioptimasi mobile, atau ada yang bisa ditandai "desktop-only"?**
> Halaman seperti Kelola Alur, Pengaturan Sistem, dan Arsip Proposal jarang diakses. Bisa saja menampilkan pesan "Buka di desktop untuk pengalaman terbaik" alih-alih full refactor. Rencana ini tetap mengoptimasi semuanya di Sprint SA7, tapi bisa di-skip jika tidak prioritas.

> **Q2: Urutan item bottom nav Super Admin.**
> Rencana saat ini: `Beranda` · `Proposal` · `Surat` · `Monitor` · `Lainnya`. Apakah ada preferensi lain? Misalnya mengganti `Monitor` dengan `Disposisi`?

---

## Sprint SA1 — Bottom Navigation & Shell Dasar

Status: belum mulai.

Tujuan: Membuat infrastruktur navigasi mobile Super Admin: bottom nav 5 item + menu "Lainnya" sebagai bottom sheet grid.

### File baru

- `templates/mobile_superadmin_nav.php`

Bottom navigation bar untuk Super Admin dengan 5 item:

| # | Label | Route | Icon |
|---|-------|-------|------|
| 1 | Beranda | `/dashboard` | `fa-home` |
| 2 | Proposal | `/proposal` | `fa-file-alt` |
| 3 | Surat | `/surat_masuk` | `fa-envelope` |
| 4 | Monitor | `/monitoring` | `fa-chart-line` |
| 5 | Lainnya | (buka sheet) | `fa-grip` |

- Item "Lainnya" membuka **bottom sheet grid menu** berisi sisa 10 item (Disposisi, Laporan, Pengumuman, Activity Logs, Audit Login, Arsip Proposal, Kelola Users, Kelola Alur, Ruangan, Pengaturan Sistem, Profil).
- Menggunakan class CSS `mobile-bottom-nav superadmin-bottom-nav`.
- Bottom sheet grid: 3 kolom ikon + label, scroll jika perlu, backdrop overlay.

### File diubah

- `templates/footer.php`
  - Tambah conditional include `mobile_superadmin_nav.php` untuk role `Super Admin`.
  - Tambah tombol logout mobile (`mobile-logout-btn`) untuk role `Super Admin`.
  - JS handler untuk toggle bottom sheet "Lainnya".

- `public/css/styles.css`
  - Tambah `.role-super-admin` rules di `@media (max-width: 1023px)`:
    - Sembunyikan sidebar, overlay, dan toggle button (seperti User/Approver).
    - Tampilkan `.superadmin-bottom-nav` dan `.mobile-logout-btn`.
    - Tambah `padding-bottom` pada `.app-main` dan `main` untuk bottom nav.
    - Reposisi toast container dan PWA install prompt di atas bottom nav.
  - Style bottom sheet grid menu "Lainnya": backdrop, slide-up animation, grid 3 kolom.

- `sw.js`
  - Bump `CACHE_VERSION` ke `lkukms-pwa-v13`.

### Validasi

- `rtk php -l templates/mobile_superadmin_nav.php`
- `rtk php -l templates/footer.php`
- Login sebagai Super Admin, viewport 375px. Bottom nav visible, sidebar hidden, tombol logout visible, menu "Lainnya" bisa dibuka.

---

## Sprint SA2 — Dashboard Mobile Super Admin

Status: belum mulai.

Tujuan: Dashboard Super Admin yang compact dan app-like di mobile, tanpa mengubah tampilan desktop.

### File diubah

- `pages/dashboard.php`

Tambah section `superadmin-home-shell` (analog `user-home-shell`) khusus mobile:

Struktur mobile dashboard SA:

1. **Focus Card "Antrian Super Admin"** — 4 kartu utama dalam grid 2×2:
   - Keuangan Menunggu (gradient maroon)
   - Proses Keuangan (gradient blue, tampilkan Rp)
   - Wajib LPJ (gradient amber)
   - Overdue (gradient red)

2. **Health Card "Kesehatan Sistem"** — 2 kartu kecil:
   - UKM Tanpa Alur
   - Approver Tidak Resolve

3. **Quick Actions Grid** — grid 4 kolom shortcut:
   - Monitoring, Proposal, Surat, Disposisi (baris 1)
   - Users, Alur, Pengaturan, Laporan (baris 2)

4. **Section tersembunyi di mobile**: Hero panel lama, Ringkasan/Stats (collapse), Pengumuman + Aktivitas Terkini → tetap tampil di desktop.

CSS mobile rules:
```css
@media (max-width: 767px) {
    .role-super-admin .sa-hero-panel { display: none; }
    .role-super-admin .sa-secondary-section { display: none; }
}
```

### Validasi

- `rtk php -l pages/dashboard.php`
- Login SA, viewport 375px. Antrian + Health + Quick Actions tampil kompak.

---

## Sprint SA3 — Proposal & LPJ Mobile Super Admin

Status: belum mulai.

Tujuan: Optimasi tampilan proposal untuk SA di mobile — preset filters, card view, dan modal bottom sheet.

### File diubah

- `pages/proposal.php`
  - Tambah toolbar mobile SA `.proposal-sa-toolbar` (analog `.proposal-user-toolbar`):
    - Judul "Kelola Proposal"
    - Segmented control: `Semua` · `Menunggu` · `Disetujui` · `Keuangan` · `LPJ`
  - Preset filter row (Antrian Keuangan, Wajib LPJ, Overdue, Menunggu ACC) → render sebagai **horizontal scroll chips** di mobile, bukan grid.
  - SA card mobile: tampilkan info lebih lengkap dari User card:
    - Pengaju, Kegiatan, Status, Anggaran (compact), Status Keuangan badge
    - CTA kontekstual: Detail, Edit Anggaran, Edit Keuangan, Undo
  - Modal-modal SA (Edit Anggaran, Edit Status Keuangan, Edit Tanggal, Undo Approval, Mark LPJ Selesai) → bottom sheet di mobile.
  - Stats section collapse/hide di mobile.

- `public/js/proposal-page.js`
  - Render SA mobile cards dengan info keuangan.
  - Counter segmented SA dari data yang sudah ada.
  - Bottom sheet handler untuk modal SA.

### Validasi

- `rtk php -l pages/proposal.php`
- `node --check public/js/proposal-page.js`
- Login SA, viewport 375px. Card list SA tampil, preset filter chips scrollable, modal bottom sheet.

---

## Sprint SA4 — Surat Masuk Mobile Super Admin

Status: belum mulai.

Tujuan: Surat Masuk SA yang saat ini tabel desktop → card view di mobile.

### File diubah

- `pages/surat_masuk.php`
  - Tambah toolbar mobile SA `.surat-sa-toolbar`:
    - Judul "Kelola Surat"
    - Segmented control: `Masuk` · `Keluar` · `Semua`
    - Quick action: `Tambah Surat` · `Cari`
  - Tambah card list container `#suratSaCardList` untuk mobile SA:
    - Surat Masuk card: Nomor surat, Pengirim, Perihal, Status, Tanggal
    - CTA: Detail, Edit Status, Buat Disposisi, Hapus
  - Kategori summary cards: responsive grid sudah ada (`grid-cols-2 sm:grid-cols-3`), cukup fine-tune padding.
  - Filter bar: stack vertikal di mobile, input full-width.
  - Modal SA (Update Status, Disposisi, CRUD Surat) → bottom sheet di mobile.
  - Sembunyikan tabel desktop di mobile SA.

CSS tambahan:
```css
@media (max-width: 767px) {
    .role-super-admin .surat-desktop-table { display: none; }
    .role-super-admin #suratSaCardList { display: block; }
}
```

### Validasi

- `rtk php -l pages/surat_masuk.php`
- Login SA, viewport 375px. Card list surat tampil, filter stack, modal bottom sheet.

---

## Sprint SA5 — Kelola Users Mobile

Status: belum mulai.

Tujuan: Halaman users (SA-only) yang saat ini 100% desktop → mobile-friendly.

### File diubah

- `pages/users.php`
  - **Fix kritis**: Ganti `opacity-0 group-hover:opacity-100` pada tombol aksi → selalu visible di mobile (touch devices tidak punya hover).
  - Stats cards: sudah `grid-cols-1 md:grid-cols-3` → OK.
  - Tabel users → card list di mobile:
    - Card: Avatar, Nama, Username, Role badge, Status badge
    - Aksi: Edit, Reset Password, WA, Delete → icon row always visible
  - Role filter buttons: horizontal scroll chips.
  - Trend chart: full-width di mobile.
  - Modal form (add/edit user): bottom sheet, input full-width, `min-height: 48px`.
  - Touch targets: semua tombol/link `min-height: 48px; min-width: 48px`.

### Validasi

- `rtk php -l pages/users.php`
- Login SA, viewport 375px. Card list users tampil, tombol aksi visible tanpa hover, modal bottom sheet.

---

## Sprint SA6 — Disposisi Mobile Super Admin

Status: belum mulai.

Tujuan: Disposisi SA mendapat perlakuan card mobile seperti Approver, tapi dengan aksi SA tambahan.

### File diubah

- `pages/disposisi.php`
  - Disposisi sudah punya `.disposisi-mobile-card` dan `@media (max-width: 767px)` → extend untuk SA:
    - Tambah toolbar SA `.disposisi-sa-toolbar` dengan segmented control: `Masuk` · `Proses` · `Selesai` · `Semua`
    - SA card: tampilkan info tambahan (pengirim asal, tujuan disposisi)
    - SA actions: Forward, Update Status, Delete → touch-friendly
  - Tabel desktop hidden di mobile SA.
  - Hero/header compact di mobile.

### Validasi

- `rtk php -l pages/disposisi.php`
- Login SA, viewport 375px.

---

## Sprint SA7 — Halaman Admin-Only (Batch)

Status: belum mulai.

Tujuan: Optimasi mobile untuk halaman-halaman yang hanya diakses admin/SA. Karena frekuensi akses lebih rendah, optimasi lebih ringan (responsive layout, touch targets, scroll chips) daripada full card-swap.

### File diubah

- `pages/monitoring.php` — 304 baris
  - Stats cards: sudah `grid-cols-1 md:grid-cols-3` → OK.
  - Chart area: full-width di mobile, grid stack 1 kolom.
  - Filter bar: stack vertikal, input full-width.
  - Touch targets: tombol refresh `min-height: 48px`.

- `pages/laporan.php` — 288 baris
  - Filter grid: sudah `grid-cols-1 md:grid-cols-2 xl:grid-cols-5` → OK di mobile.
  - Tabel laporan: wrap dalam card view di mobile, atau minimal `text-xs` dengan sticky first column.
  - Download button: full-width di mobile.
  - Summary cards: responsive grid.

- `pages/activity_logs.php` — 274 baris
  - Filter grid: `grid-cols-1 md:grid-cols-12` → 1 kolom OK di mobile.
  - Log tabel → timeline/card view di mobile (sudah ada avatar+badge rendering di JS).
  - Touch targets filter buttons.

- `pages/login_audit.php` — 39 baris (kecil)
  - Tabel 8 kolom → card view di mobile:
    - Card: Waktu, Username, Status badge, IP
    - Detail expand: User-Agent, Session, Alasan

- `pages/arsip_proposal.php` — 700 baris
  - Grid 2 kolom `xl:grid-cols-[22rem_1fr]` → stack 1 kolom di mobile.
  - Tabel arsip → card view di mobile.
  - Filter sidebar: collapse/accordion di mobile.
  - Stats cards: sudah `grid-cols-1 md:grid-cols-4` → OK.

- `pages/alur.php` — 937 baris
  - Tabel alur → card view di mobile:
    - Card: Nama pengaju, 6 slot approver (compact list)
    - Aksi: Edit, Hapus
  - Modal form (6 approver select): scroll inside bottom sheet, select full-width.
  - Tab/view switcher (jika ada): horizontal scroll.

- `pages/system_settings.php` — 236 baris
  - Form settings: input full-width, `min-height: 48px`.
  - Grup settings: stack vertikal.
  - Save button: full-width/sticky di mobile.

### Validasi batch

```bash
rtk php -l pages/monitoring.php
rtk php -l pages/laporan.php
rtk php -l pages/activity_logs.php
rtk php -l pages/login_audit.php
rtk php -l pages/arsip_proposal.php
rtk php -l pages/alur.php
rtk php -l pages/system_settings.php
```

---

## Sprint SA8 — Profil & Ruangan Mobile Super Admin

Status: belum mulai.

Tujuan: Halaman profil dan ruangan SA mendapat perlakuan mobile yang sama polished-nya dengan User/Approver.

### File diubah

- `pages/profil.php`
  - SA saat ini masuk ke branch `else` (grid 2 kolom, semua panel visible).
  - Tambah SA mobile treatment:
    - Hero card: avatar, nama, badge role + username (seperti User/Approver).
    - Summary cards 3 kolom: Email, No. HP, NIM.
    - Tab switcher: `Kontak` / `Password`.
    - Panel switching: hanya panel aktif tampil di mobile.

- `pages/penggunaan_ruangan.php`
  - SA punya form input panel yang User tidak punya → optimasi:
    - Form input: stack vertikal di mobile, input full-width, `min-height: 48px`.
    - Form terpisah dari kalender (tab atau accordion).
    - Kalender compact: cell height 3.5rem (adopsi dari User mobile).
    - Detail card: adopsi `.room-user-detail-card` styling.
    - Edit button: touch-friendly.

### Validasi

- `rtk php -l pages/profil.php`
- `rtk php -l pages/penggunaan_ruangan.php`

---

## Verification Plan

### Automated Tests

```bash
# Syntax check semua file PHP yang dimodifikasi
rtk php -l templates/mobile_superadmin_nav.php
rtk php -l templates/footer.php
rtk php -l pages/dashboard.php
rtk php -l pages/proposal.php
rtk php -l pages/surat_masuk.php
rtk php -l pages/users.php
rtk php -l pages/disposisi.php
rtk php -l pages/monitoring.php
rtk php -l pages/laporan.php
rtk php -l pages/activity_logs.php
rtk php -l pages/login_audit.php
rtk php -l pages/arsip_proposal.php
rtk php -l pages/alur.php
rtk php -l pages/system_settings.php
rtk php -l pages/profil.php
rtk php -l pages/penggunaan_ruangan.php

# JS check
node --check public/js/proposal-page.js
node --check sw.js
```

### Manual Verification

1. Login sebagai `Super Admin`, viewport 375px–428px (iPhone SE / iPhone 14).
2. Bottom nav 5 item visible, sidebar hidden, logout button visible.
3. Tap "Lainnya" → bottom sheet grid muncul dengan 10+ menu item.
4. Setiap halaman: card view tampil (bukan tabel horizontal scroll).
5. Semua tombol aksi bisa di-tap (tidak butuh hover).
6. Modal/form tampil sebagai bottom sheet.
7. Logout berfungsi.
8. Login sebagai `Admin`, pastikan tidak terpengaruh (Admin masih pakai sidebar di mobile).
9. Login sebagai `User` dan `Approver`, pastikan bottom nav mereka tidak berubah.
10. Desktop (≥1024px) semua role: tidak ada perubahan visual.

### Urutan Eksekusi

SA1 harus selesai duluan (infrastruktur nav). Setelah itu SA2–SA4 bisa paralel. SA5–SA8 setelah pola card & bottom sheet sudah established.

```
SA1 (Bottom Nav & Shell)
 ├── SA2 (Dashboard)
 ├── SA3 (Proposal)
 └── SA4 (Surat)
      ├── SA5 (Users)
      ├── SA6 (Disposisi)
      ├── SA7 (Admin Pages Batch)
      └── SA8 (Profil & Ruangan)
```
