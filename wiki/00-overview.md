# Wiki Layer LK UKMs - Overview

Terakhir diperbarui: 2026-06-09

## Tujuan Wiki Layer

Wiki Layer adalah ringkasan terstruktur agar agent membaca konteks LK UKMs dari Markdown yang sudah dirapikan terlebih dahulu, bukan membuka source mentah berulang-ulang.

Aturan kerja:
1. Baca file wiki yang relevan lebih dulu.
2. Buka source mentah hanya untuk verifikasi detail, implementasi, atau edit.
3. Jika pola project berubah permanen, update wiki terkait.

## Project

**LK UKMs** adalah aplikasi PHP native tanpa framework untuk manajemen:

- Proposal dan LPJ UKM
- Approval proposal/LPJ berbasis alur dinamis
- Surat masuk/keluar dan disposisi
- Arsip surat/dokumen
- Arsip proposal
- Penggunaan ruangan
- KIPK
- Pengumuman
- User, role, activity logs
- PDF pengesahan
- Notifikasi email/WhatsApp
- Analisis AI untuk arsip/proposal

`autopost/` adalah tool standalone dan tidak termasuk aplikasi utama LK UKMs.

## Stack

- Backend: PHP native
- DB: MySQL/MariaDB via mysqli
- Frontend: Tailwind CSS CDN + Font Awesome
- PDF: TCPDF
- Email: PHPMailer
- QR: endroid/qr-code

## Struktur Penting

```text
index.php                  Entry point dan router
config/database.php        DB/session/timezone/getDBConnection()
config/schema.sql          Referensi schema
includes/functions.php     Helper umum, upload, log, approval, config, WA
includes/security.php      CSRF, password, role guard, upload validation
includes/email.php         PHPMailer SMTP
api/*.php                  Endpoint AJAX/API
pages/*.php                Halaman render server-side
templates/header.php       Header, Tailwind config, csrf token
templates/sidebar.php      Sidebar/menu
templates/footer.php       Toast helper dan common JS
modals/surat.php           Modal surat
uploads/                   File upload
.ai-team/wiki/             Knowledge base agent
.ai-team/rules/            Aturan workflow/agent
```

## File Wiki

- `01-architecture.md` — arsitektur, routing, layout.
- `02-routing.md` — page routes dan API routes.
- `03-security.md` — keamanan, auth, CSRF, upload, escaping.
- `04-database-schema.md` — ringkasan tabel.
- `05-api-map.md` — peta endpoint/action.
- `06-page-map.md` — peta halaman dan API yang dipakai.
- `07-proposal-lpj-workflow.md` — proposal, LPJ, approval, PDF.
- `08-surat-workflow.md` — surat masuk/keluar, disposisi, PDF.
- `09-upload-pdf-notification-ai.md` — upload, PDF, notifikasi, AI analysis.
- `10-frontend-patterns.md` — Tailwind, JS, CSRF, toast.
- `99-known-issues.md` — catatan risiko/known issues.
