# Routing Map - LK UKMs

Sumber utama: `index.php`.

## API Routes Terdaftar

```text
/api/auth                 → api/auth.php
/api/users                → api/users.php
/api/surat                → api/surat.php
/api/proposal             → api/proposal.php
/api/penggunaan_ruangan   → api/penggunaan_ruangan.php
/api/alur                 → api/alur.php
/api/kipk                 → api/kipk.php
/api/pengumuman           → api/pengumuman.php
/api/arsip                → api/arsip.php
```

Catatan: `api/wa_send.php` ada tetapi tidak terdaftar di router utama; kemungkinan dipanggil langsung bila digunakan.

## Page Routes Valid

```text
/dashboard
/surat_masuk
/surat_keluar       → redirect internal ke surat_masuk
/disposisi
/proposal
/arsip
/arsip_proposal
/users
/profil
/monitoring
/alur
/system_settings
/pengumuman
/activity_logs
/penggunaan_ruangan
/login
```

Jika page tidak valid, diarahkan ke `dashboard`.

## Login Guard

Jika belum login dan page bukan `login`:

```text
redirect /login
```

## Role Guard di Router

### Role `Disposisi`

Hanya boleh:

```text
dashboard, surat_masuk, disposisi, profil, login
```

Jika akses page lain → diarahkan ke `surat_masuk`.

### Role `Read Only`

Hanya boleh:

```text
dashboard, surat_masuk, disposisi, proposal, profil, login
```

Jika akses page lain → diarahkan ke `dashboard`.

## Catatan Penting

Guard di `index.php` hanya page-level. API tetap wajib melakukan authorization sendiri dengan `requireRole()` atau helper existing.

Jangan mengandalkan hiding tombol/menu di frontend sebagai kontrol akses.
