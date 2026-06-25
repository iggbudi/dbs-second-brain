# Development Rules - LK UKMs Wiki Layer

## Wiki-First Rule

Sebelum membaca source mentah, baca wiki yang relevan:

- Overview/architecture: `.ai-team/wiki/00-overview.md`, `01-architecture.md`
- Routing: `02-routing.md`
- Security: `03-security.md`
- DB: `04-database-schema.md`
- API: `05-api-map.md`
- Page: `06-page-map.md`
- Proposal/LPJ: `07-proposal-lpj-workflow.md`
- Surat: `08-surat-workflow.md`
- Upload/PDF/AI: `09-upload-pdf-notification-ai.md`
- Frontend: `10-frontend-patterns.md`

Buka source mentah hanya untuk:
- Verifikasi detail yang belum ada di wiki.
- Mengubah kode.
- Debug bug spesifik.
- Menjalankan QA terhadap file berubah.

## Implementation Rules

- Native PHP only, no new framework/runtime.
- DB via `getDBConnection()`.
- SQL prepared statements.
- POST API requires CSRF.
- Permission server-side.
- API JSON shape standard unless binary/PDF stream.
- Output escaped.
- Upload secure.
- Approval compare via `normalizeApprover()`.
- Frontend uses Tailwind maroon and `showToast()`.

## Wiki Maintenance

Jika menemukan fakta penting yang belum ada atau berubah, update file wiki terkait dalam commit/perubahan yang sama.
