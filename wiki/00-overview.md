# DBS Second Brain - Project Inventory

Terakhir diperbarui: 2026-06-25

## Tujuan

Wiki ini adalah knowledge base terpusat untuk semua project DBS di berbagai server. Setiap Pi agent di server manapun bisa membaca knowledge ini untuk memahami konteks project.

---

## 📋 Daftar Project

### 1. LK UKMs (pjdigital.top)
> **Server**: pjdigital.top  
> **Status**: Active  
> **Wiki**: `01-architecture.md` hingga `99-known-issues.md`

Aplikasi PHP native untuk manajemen Proposal dan LPJ UKM, approval berbasis alur dinamis, surat masuk/keluar, disposisi, arsip, penggunaan ruangan, KIPK, pengumuman, user/role/activity logs, PDF pengesahan, notifikasi email/WhatsApp, dan analisis AI.

**Stack**: PHP native, MySQL/MariaDB, Tailwind CSS CDN, TCPDF, PHPMailer, QR Code

**Wiki Files**:
- `01-architecture.md` — arsitektur, routing, layout
- `02-routing.md` — page routes dan API routes
- `03-security.md` — keamanan, auth, CSRF, upload, escaping
- `04-database-schema.md` — ringkasan tabel
- `05-api-map.md` — peta endpoint/action
- `06-page-map.md` — peta halaman dan API
- `07-proposal-lpj-workflow.md` — proposal, LPJ, approval, PDF
- `08-surat-workflow.md` — surat masuk/keluar, disposisi, PDF
- `09-upload-pdf-notification-ai.md` — upload, PDF, notifikasi, AI analysis
- `10-frontend-patterns.md` — Tailwind, JS, CSRF, toast
- `99-known-issues.md` — catatan risiko/known issues

---

### 2. Sistem Disposisi Surat UNISBANK (aidis.my.id)
> **Server**: aidis.my.id  
> **Domain**: https://aidis.my.id  
> **Status**: Active Development  
> **Wiki**: `aidis-my-id-disposisi-surat.md`

Aplikasi web untuk manajemen disposisi surat masuk di Universitas Stikubank (UNISBANK). Sistem routing surat hierarkis dari Rektor hingga Kaprodi, dengan siklus review, usulan bottom-up, delegasi kewenangan, notifikasi, dan pelaporan.

**Stack**: PHP 8.2+ native, PostgreSQL 15+, HTML/CSS/JS vanilla, PHPUnit 10

**Key Features**:
- Registrasi surat masuk dengan nomor agenda otomatis
- Routing disposisi hierarkis (Rektor → Wakil Rektor → Dekan → Kaprodi)
- 11 roles dengan RBAC
- Siklus review dan instruksi lanjutan
- Delegasi kewenangan
- Usulan bottom-up dari admin fakultas
- Dashboard dan reporting real-time
- Notifikasi in-app, email, WhatsApp

**Architecture**: 3-layer (Controller → Service → Repository)

**Codebase**: 50 PHP files (src), 32 templates, 22 tests

**Wiki**: Lihat `aidis-my-id-disposisi-surat.md` untuk dokumentasi lengkap

---

## 🔧 Server Inventory

| Server | Domain | Total Projects | Main Stack |
|--------|--------|----------------|------------|
| Server A | pjdigital.top | 1+ (LK UKMs) | PHP + MySQL |
| Server B | aidis.my.id | 17 | PHP, Node.js, Laravel, PostgreSQL, MySQL, MongoDB |

### Server B (aidis.my.id) - 17 Projects
| # | Domain | Stack | Type |
|---|--------|-------|------|
| 1 | aidis.my.id | PHP + PostgreSQL | Disposisi Surat UNISBANK |
| 2 | al-barokah.my.id | PHP + DOMPDF | Masjid Landing Page |
| 3 | botjb.nanariset.my.id | Static | Placeholder |
| 4 | bot.shm.my.id | Node.js + Telegraf | Telegram Bot (SIMPEL-U) |
| 5 | brainboard.socai.my.id | Laravel | Web Application |
| 6 | cmaestro.my.id | Node.js + Pi SDK | AI Chatbot (Bengkel) |
| 7 | eduguide.socai.my.id | Next.js + Laravel | AI Academic Assistant |
| 8 | fetal.pjdigital.top | Unknown | Unknown |
| 9 | inv.nanariset.my.id | Node.js | Invoice System |
| 10 | kl.socai.my.id | PHP + MySQL | Kausar Leather |
| 11 | quizify.socai.my.id | Laravel | Quiz Application |
| 12 | safesphere.my.id | Node.js + SQLite | Anti-Bullying Reporting |
| 13 | simpelu.my.id | PHP + MySQL | Campus Management |
| 14 | sjmlelang.com | PHP | Online Auction |
| 15 | socai.my.id | Node.js + PostgreSQL | Main Platform + Bot |
| 16 | studdybuddy.socai.my.id | Laravel + MongoDB | AI Study Assistant |
| 17 | vibeplan.socai.my.id | Laravel + Next.js | AI Planning Assistant |

> Full details: `server-aidis-my-id-full-inventory.md`

---

## 📁 Wiki Structure

```
wiki/
├── 00-overview.md                    # This file - project inventory
├── 01-architecture.md                # LK UKMs architecture
├── 02-routing.md                     # LK UKMs routing
├── 03-security.md                    # LK UKMs security
├── 04-database-schema.md             # LK UKMs database
├── 05-api-map.md                     # LK UKMs API map
├── 06-page-map.md                    # LK UKMs page map
├── 07-proposal-lpj-workflow.md       # LK UKMs proposal workflow
├── 08-surat-workflow.md              # LK UKMs surat workflow
├── 09-upload-pdf-notification-ai.md  # LK UKMs uploads/notifications
├── 10-frontend-patterns.md           # LK UKMs frontend
├── 99-known-issues.md                # LK UKMs known issues
└── aidis-my-id-disposisi-surat.md    # Disposisi Surat UNISBANK (NEW)
```

---

## 🎯 Shared Knowledge

### DBS Preferences
- **Coding Style**: PHP native tanpa framework
- **Architecture**: 3-layer pattern (Controller → Service → Repository)
- **Security**: CSRF, prepared statements, HTML escaping, RBAC
- **Documentation**: Comprehensive wiki untuk setiap project
- **Testing**: PHPUnit untuk unit/integration tests

### Common Patterns Across Projects
1. PHP native tanpa framework (Laravel, Symfony, dll)
2. Frontend vanilla HTML/CSS/JS (tanpa React/Vue/Angular)
3. Comprehensive documentation di wiki folder
4. RBAC-based access control
5. CSRF protection untuk state-changing operations
6. Prepared statements untuk SQL
7. HTML output escaping

---

*Last updated by Pi agent on 2026-06-25*
