# Known Issues / Risk Notes - LK UKMs

## Production Hardening

Production error display sudah dikontrol oleh `APP_ENV`/`APP_DEBUG` di `index.php` dan `config/database.php`: default production mematikan `display_errors`/`display_startup_errors` dan mengaktifkan `log_errors`. Pastikan server production tidak mengaktifkan `APP_DEBUG`.

## Direct API File vs Router

Sebagian frontend memakai variasi URL:

```text
api/proposal.php
/api/proposal.php
/api/proposal
```

Router mendukung `/api/proposal`, tetapi file langsung juga sering dipakai. Saat mengubah routing, pastikan kompatibilitas tetap aman.

## `api/wa_send.php`

File ada tetapi tidak terdaftar di `index.php`. Perlakukan sebagai endpoint direct/legacy sampai diverifikasi.

## `surat_keluar`

Route page `surat_keluar` diarahkan ke `surat_masuk`, karena satu halaman gabungan.

## API Response Shape

Sebagian endpoint lama mungkin memakai key khusus seperti `proposals`, `users`, `alur`, `announcements`, bukan selalu nested `data`. Saat refactor, jaga kompatibilitas frontend existing.

## P1-2 JSON Error Handler Rollout

JSON-safe error handler saat ini terdokumentasi untuk API proposal JSON actions. Rollout ke API lain sengaja deferred/bertahap karena sebagian endpoint dapat mengirim PDF/binary atau response non-JSON; pemasangan handler secara broad berisiko merusak stream/download bila output sudah mulai terkirim. Saat menambahkan handler ke API lain, audit dulu semua action binary/PDF dan pastikan success binary tidak memakai `jsonResponse()`.


## P2 Minimal Observability Schema Deferred

P2 observability tidak menjalankan migrasi schema fisik untuk `activity_logs`. Field terstruktur di API/UI (`event`, `request_id`, `category`, `level`, `detail`/`context`, `is_structured`) diparse dari JSON legacy di kolom `aktivitas` dan tetap menjaga kompatibilitas log lama. Kolom/index khusus `level`, `category`, `request_id`, dan `context_json` masih deferred; query/filter jangan mengasumsikan kolom tersebut ada sampai migrasi resmi dilakukan.

## Large Files

File besar dan kompleks:

```text
api/proposal.php
api/surat.php
pages/proposal.php
pages/surat_masuk.php
```

Untuk perubahan di area ini:
- Baca wiki workflow dulu.
- Buka source mentah hanya bagian relevan.
- Hindari broad refactor.
- Jalankan syntax check.
- Lakukan regression checklist.

## Approval Chain

Risiko bug tinggi bila membandingkan approver dengan lowercase biasa. Selalu gunakan `normalizeApprover()`.

## PDF Endpoint

PDF endpoint harus melakukan access control sebelum streaming. Jika output sudah dikirim, tidak bisa lagi return JSON error secara aman.

## Auto-Renew SSL

SSL `lk.pjdigital.top` pernah expired dan sudah diperbarui. Auto-renew cron ditambahkan:

```text
/etc/cron.d/certbot-renew
```

Jadwal:

```text
17 3,15 * * * root /usr/bin/certbot renew --quiet --deploy-hook "systemctl reload nginx"
```
