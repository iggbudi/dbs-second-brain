# Progres PWA LK UKMs

## Konteks

- Aplikasi LK UKMs adalah native PHP + Tailwind CDN, bukan SPA.
- Fokus pekerjaan saat ini adalah refactor PWA/mobile untuk role `User`, setelah role `Approver` lebih dulu direfactor.
- Root project: `/var/www/lk.pjdigital.top`.
- File penting yang sering tersentuh:
  - `pages/dashboard.php`
  - `pages/proposal.php`
  - `pages/surat_masuk.php`
  - `pages/profil.php`
  - `pages/penggunaan_ruangan.php`
  - `public/js/proposal-page.js`
  - `api/proposal.php`
  - `api/users.php`
  - `templates/footer.php`
  - `public/css/styles.css`
  - `sw.js`
  - `docs/menu-role-matrix.md`

## Progres Role User

### Sprint U1 - Bottom Navigation User

Status: selesai.

Hasil:
- Bottom nav mobile khusus role `User`.
- Item bottom nav: `Beranda`, `Proposal`, `Surat`, `Ruangan`.
- Sidebar drawer dan hamburger mobile disembunyikan untuk role `User`.
- Desktop/tablet besar tetap memakai sidebar existing.

File terkait:
- `templates/mobile_user_nav.php`
- `templates/footer.php`
- `public/css/styles.css`

### Sprint U2 - Dashboard Mobile User

Status: selesai.

Hasil:
- Dashboard mobile User punya first screen app-like.
- Section utama: `Dokumen Saya` / `Pantau Pengajuan`.
- Kartu utama:
  - `Menunggu Persetujuan`
  - `Perlu Revisi`
- Kartu kecil:
  - `Surat Saya`
  - `Baru Disubmit`
- Shortcut:
  - `Ajukan Proposal`
  - `Ajukan LPJ`
  - `Buat Surat`
  - `Ajukan Ruangan`
- Section dashboard lama disembunyikan pada mobile User, tapi tetap tersedia di desktop.

File utama:
- `pages/dashboard.php`

Validasi yang sudah dijalankan:
- `rtk php -l pages/dashboard.php`
- `rtk php -l templates/mobile_user_nav.php`
- `rtk php -l templates/footer.php`

### Sprint U3 - Proposal/LPJ Mobile User

Status: selesai, termasuk fix counter segmented.

Hasil:
- Mobile User `/proposal` punya toolbar `Dokumen Saya` / `Proposal & LPJ`.
- Segmented control:
  - `Semua`
  - `Menunggu`
  - `Revisi`
  - `LPJ`
- Quick action:
  - `Proposal`
  - `LPJ`
  - `Wajib LPJ`
- List mobile User dirender sebagai card ringkas, bukan tabel.
- Card tidak menampilkan anggaran/durasi di list awal.
- Informasi lengkap tetap tersedia lewat tombol detail.
- CTA card kontekstual:
  - `Upload Revisi`
  - `Unggah LPJ`
  - `Pengesahan`
  - `Detail`
- Modal tambah proposal/LPJ dibuat seperti bottom sheet mobile.

Fix penting:
- Counter segmented sempat tampil nol semua.
- Perbaikan:
  - `api/proposal.php` menambahkan `meta.user_segment_counts`.
  - `public/js/proposal-page.js` membaca `user_segment_counts`.
  - `pages/proposal.php` bump script ke `/public/js/proposal-page.js?v=10`.
  - `sw.js` bump cache ke `lkukms-pwa-v10`.

File utama:
- `pages/proposal.php`
- `public/js/proposal-page.js`
- `api/proposal.php`
- `sw.js`

Validasi yang sudah dijalankan:
- `rtk php -l api/proposal.php`
- `rtk php -l pages/proposal.php`
- `node --check public/js/proposal-page.js`
- `node --check sw.js`

Catatan PWA:
- Jika counter proposal masih terlihat lama di HP/PWA, refresh lalu tutup-buka app agar service worker v10 aktif dan cache lama dibuang.

### Sprint U4 - Surat Mobile User

Status: selesai.

Scope:
- Role `User` pada menu `Surat`.
- Halaman yang dipakai adalah `/surat_masuk`, tetapi untuk User menampilkan `Surat Keluar`.

Hasil:
- Mobile User `/surat_masuk` punya toolbar `Surat Saya` / `Surat Keluar`.
- Segmented control:
  - `Semua`
  - `Menunggu`
  - `Revisi`
  - `Selesai`
- Quick action:
  - `Kirim Surat`
  - `Cari`
- Tabel desktop disembunyikan pada mobile User.
- Data surat keluar yang sama dirender sebagai card di `#suratKeluarCardList`.
- Card menampilkan:
  - nomor surat
  - status
  - perihal
  - tanggal kirim
  - tujuan
  - ringkasan kategori
- Jika status `Revisi`, CTA utama menjadi `Upload Revisi`.
- Selain status `Revisi`, CTA utama adalah `Detail`.
- Modal `suratKeluarModal`, `revisiSuratModal`, dan `detailSuratModal` dibuat seperti bottom sheet pada mobile.
- Counter segmented surat mengambil total via request `getSuratKeluar` dengan filter status.

File utama:
- `pages/surat_masuk.php`

Validasi yang sudah dijalankan:
- `rtk php -l pages/surat_masuk.php`

### Sprint U5 - Profil Mobile User

Status: selesai.

Hasil:
- Mobile User `/profil` punya hero card mirip Approver.
- Hero section: avatar, nama, badge role + username.
- Summary cards 3 kolom: Email, No. HP, NIM.
- Tab switcher: `Kontak` / `Password`.
- Panel switching: info card hidden di mobile, hanya panel aktif yang tampil.
- Bottom padding mengakomodasi bottom nav.
- Desktop tidak berubah (grid 2 kolom).

File utama:
- `pages/profil.php`

Validasi yang sudah dijalankan:
- `rtk php -l pages/profil.php`

### Sprint U6 - Ruangan Mobile User

Status: selesai.

Hasil:
- Mobile User `/penggunaan_ruangan` punya toolbar ringkas "Jadwal Ruangan".
- Hero lama hidden di mobile User, diganti toolbar khusus.
- Navigasi bulan compact: tombol prev/next + ikon kalender, touch target 44px.
- Filter row: select full-width, label hidden di mobile.
- Legend compact: dot kecil + label pendek.
- Kalender lebih ringkas: cell height 3.5rem (dari 5rem), badge lebih kecil.
- Detail card dengan ikon untuk ruangan/pengguna/input.
- Empty state: ikon + pesan centered.
- Bottom padding mengakomodasi bottom nav.
- Desktop/Admin tidak berubah.

File utama:
- `pages/penggunaan_ruangan.php`

Validasi yang sudah dijalankan:
- `rtk php -l pages/penggunaan_ruangan.php`

## Fix & Fitur Tambahan

### Fix: Dashboard Proposal Counts User Selalu Nol

Status: selesai.

Root cause: `api/users.php` - fungsi `calculateProposalQuickAccessCounts()` query User hanya select `status, tanggal_upload` tanpa `pengaju`. Variabel `$isMine` selalu `false`, counter `menungguReview`, `perluRevisi`, `baruDisubmit` tidak pernah bertambah.

Fix: Hapus pengecekan `$isMine` untuk role User, karena query sudah filter `WHERE pengaju = ?`.

File utama:
- `api/users.php`

### Fitur: Tombol Logout Mobile Header

Status: selesai (perlu verifikasi manual).

Hasil:
- Tombol logout fixed di pojok kanan atas untuk mobile User/Approver.
- Ikon `fa-sign-out-alt`, 40x40px, backdrop blur.
- Desktop: hidden (sidebar sudah ada logout).
- Mobile (< 1024px): visible, `position: fixed`.
- Menggunakan `handleLogout()` yang sudah ada di `footer.php`.

File utama:
- `templates/footer.php`
- `public/css/styles.css`

## Status Cache PWA

- Service worker saat ini:
  - `CACHE_VERSION = 'lkukms-pwa-v12'`
- File:
  - `sw.js`

## Status Git Yang Perlu Diingat

File yang disentuh di fase terakhir:
- `pages/profil.php`
- `pages/penggunaan_ruangan.php`
- `api/users.php`
- `templates/footer.php`
- `public/css/styles.css`
- `sw.js`

## Checklist Manual Berikutnya

1. Login sebagai `User`, viewport 375px-428px.
2. Buka `/dashboard`, pastikan counter proposal tidak nol jika data ada.
3. Buka `/profil`, pastikan hero card, summary, tab switcher tampil.
4. Buka `/penggunaan_ruangan`, pastikan toolbar, kalender compact, detail card tampil.
5. Pastikan tombol logout visible di pojok kanan atas.
6. Tap tombol logout, pastikan konfirmasi muncul dan redirect ke login.
7. Login sebagai `Approver`, pastikan tombol logout juga visible.
8. Pastikan desktop semua role tidak rusak.
