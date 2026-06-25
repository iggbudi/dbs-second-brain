# Server aidis.my.id - Full Project Inventory

> **Server**: aidis.my.id  
> **IP**: Check DNS  
> **OS**: Ubuntu (assumed)  
> **Web Server**: Apache 2 with SSL (Let's Encrypt)  
> **Last Updated**: 2026-06-25  
> **Total Projects**: 17 active domains/subdomains

---

## 📊 Server Overview

| Metric | Value |
|--------|-------|
| Total Vhosts | 17 |
| Active Projects | 17 |
| PHP Projects | 8 |
| Node.js Projects | 6 |
| Laravel Projects | 4 |
| Static Sites | 2 |
| Databases | PostgreSQL, MySQL, MongoDB, SQLite |

---

## 🏢 Complete Project List

### 1. aidis.my.id
> **Domain**: https://aidis.my.id  
> **Path**: `/var/www/aidis.my.id/public`  
> **Stack**: PHP 8.2+ native, PostgreSQL 15+  
> **Type**: Web Application  
> **Status**: Active Development

**Deskripsi**: Sistem Disposisi Surat UNISBANK - Manajemen disposisi surat masuk universitas.

**Fitur Utama**:
- Registrasi surat masuk dengan nomor agenda otomatis
- Routing disposisi hierarkis (Rektor → Wakil Rektor → Dekan → Kaprodi)
- 11 roles dengan RBAC
- Siklus review dan instruksi lanjutan
- Delegasi kewenangan
- Usulan bottom-up dari admin fakultas
- Dashboard dan reporting real-time
- Notifikasi in-app, email, WhatsApp

**Arsitektur**: 3-layer (Controller → Service → Repository)  
**Database**: PostgreSQL 15+  
**Testing**: PHPUnit 10 with SQLite in-memory  
**Wiki**: `aidis-my-id-disposisi-surat.md`

---

### 2. al-barokah.my.id
> **Domain**: https://al-barokah.my.id  
> **Path**: `/var/www/al-barokah.my.id/public`  
> **Stack**: PHP native, DOMPDF  
> **Type**: Landing Page + Admin  
> **Status**: Active

**Deskripsi**: Website resmi Masjid Al-Barokah - Portal informasi masjid dan jamaah.

**Fitur Utama**:
- Landing page masjid dengan informasi kegiatan
- Jadwal shalat dan petugas
- Pengurus DKM
- Layanan masjid (Perpustakaan, Amil Zakat, Gedung Serbaguna, Muallaf Center)
- Agenda dan berita
- Galeri foto
- Pengumuman
- Portal admin untuk pengelolaan konten

**Stack**: PHP 8.1+, DOMPDF untuk PDF  
**Database**: File-based atau SQLite (no framework)  
**Namespace**: `AlBarokah\`

---

### 3. botjb.nanariset.my.id
> **Domain**: https://botjb.nanariset.my.id  
> **Path**: `/var/www/botjb.nanariset.my.id/public_html`  
> **Stack**: Static HTML  
> **Type**: Placeholder/Bot  
> **Status**: Active

**Deskripsi**: Placeholder page untuk bot project. Hanya menampilkan halaman statis "botjb.nanariset.my.id aktif".

---

### 4. bot.shm.my.id
> **Domain**: https://bot.shm.my.id  
> **Path**: `/var/www/bot.shm.my.id`  
> **Stack**: Node.js, TypeScript, Telegraf, Pi SDK  
> **Type**: Telegram Bot  
> **Status**: Active

**Deskripsi**: SIMPEL-U Pi SDK Telegram Bot - Bot Telegram yang membaca database SIMPEL-U dan menggunakan Pi SDK.

**Fitur Utama**:
- Telegram bot dengan webhook
- Koneksi database SIMPEL-U (MySQL)
- Pi SDK integration
- Fitur: `/menu`, `/export csv|pdf`, `/laporan`, `/observability`, `/tren`, `/alert`, `/rekomendasi`
- Rate limiting dan allowed user IDs
- Audit logging

**Stack**: Node.js 22+, TypeScript, Telegraf, Pi SDK, MySQL  
**Service**: `simpelu-pi-bot` (systemd)  
**Endpoints**:
- `https://bot.shm.my.id/`
- `https://bot.shm.my.id/health`
- Webhook: `https://bot.shm.my.id/telegram-webhook`

---

### 5. brainboard.socai.my.id
> **Domain**: https://brainboard.socai.my.id  
> **Path**: `/var/www/brainboard.socai.my.id/public`  
> **Stack**: Laravel, Tailwind CSS, Alpine.js  
> **Type**: Web Application  
> **Status**: Active

**Deskripsi**: BrainBoard - Aplikasi web berbasis Laravel.

**Stack**: Laravel (PHP), Tailwind CSS 3, Alpine.js, Vite  
**Database**: MySQL/PostgreSQL (Laravel default)  
**Dependencies**: Laravel framework, Tailwind CSS Forms

---

### 6. cmaestro.my.id
> **Domain**: https://cmaestro.my.id  
> **Path**: `/var/www/cmaestro.my.id/public`  
> **Stack**: Node.js, TypeScript, Pi SDK, SQLite  
> **Type**: AI Chatbot  
> **Status**: Active (Production)

**Deskripsi**: BengkelBot - AI chatbot untuk bengkel mobil di Semarang. Powered by Pi SDK + SumoPod LLM.

**Fitur Utama**:
- AI chatbot untuk bengkel mobil
- Web interface dengan SSE (Server-Sent Events)
- Admin panel
- Workshop tools (booking, lookup, dll)
- SQLite database
- WhatsApp integration (opsional, belum aktif)

**Arsitektur**:
```
Browser → Apache :443 (SSL) → Node :3012 (PM2) → BengkelBot Agent → SQLite + LLM
```

**Stack**: Node.js 22+, TypeScript, Pi SDK, SumoPod (DeepSeek V4 Pro), SQLite, React  
**PM2 Process**: `cmaestro-bengkelbot`  
**Port**: 3012  
**URLs**:
- Chat: https://cmaestro.my.id/
- Admin: https://cmaestro.my.id/admin

---

### 7. eduguide.socai.my.id
> **Domain**: https://eduguide.socai.my.id  
> **Path**: `/var/www/eduguide.socai.my.id/app`  
> **Stack**: Next.js (Frontend), Laravel (Backend), Supabase  
> **Type**: AI Academic Assistant  
> **Status**: Active

**Deskripsi**: EduGuide AI - Asisten akademik berbasis AI untuk mahasiswa. "AI as Assistant, Not Assignment Solver".

**Fitur Utama**:
- Upload PDF akademik
- AI Document Summary (ringkasan terstruktur)
- Chat berbasis dokumen
- Proofreading paragraf akademik
- Generator sitasi
- Penyimpanan hasil AI ke Documents
- Download DOCX/PDF
- Dashboard aktivitas

**Stack**: Next.js (Frontend), Laravel REST API (Backend), Supabase PostgreSQL, Groq/OpenRouter AI  
**Target User**: Mahasiswa  
**Theme**: AI for Education (UTS Project)

---

### 8. fetal.pjdigital.top
> **Domain**: https://fetal.pjdigital.top  
> **Path**: (no DocumentRoot in conf)  
> **Stack**: Unknown  
> **Type**: Unknown  
> **Status**: Active (SSL enabled)

**Deskripsi**: Project dari domain pjdigital.top. Detail belum tersedia.

---

### 9. inv.nanariset.my.id
> **Domain**: https://inv.nanariset.my.id  
> **Path**: `/var/www/inv.nanariset.my.id/repo/invoice`  
> **Stack**: Node.js  
> **Type**: Invoice System  
> **Status**: Active

**Deskripsi**: Sistem invoice untuk nanariset.my.id.

**Dependencies**: pngjs (image processing)  
**Stack**: Node.js (CommonJS)

---

### 10. kl.socai.my.id
> **Domain**: https://kl.socai.my.id  
> **Path**: `/var/www/kl.socai.my.id`  
> **Stack**: PHP native, MySQL  
> **Type**: Landing Page + Admin  
> **Status**: Active

**Deskripsi**: Kausar Leather - Landing page dan admin untuk toko kulit.

**Fitur Utama**:
- Landing page produk kulit
- Admin dashboard
- Gallery management
- Site settings
- User management

**Stack**: PHP 8.1+, MySQL/MariaDB, PDO  
**Database**: `kl_socai_admin`  
**Environment Variables**: `KL_DB_DSN`, `KL_DB_HOST`, `KL_DB_DATABASE`, `KL_DB_USERNAME`, `KL_DB_PASSWORD`  
**No Framework**: Pure PHP, no Composer

---

### 11. quizify.socai.my.id
> **Domain**: https://quizify.socai.my.id  
> **Path**: `/var/www/quizify.socai.my.id/public`  
> **Stack**: Laravel, Tailwind CSS 4  
> **Type**: Quiz Application  
> **Status**: Active

**Deskripsi**: Quizify - Aplikasi quiz berbasis Laravel.

**Stack**: Laravel (PHP), Tailwind CSS 4, Vite  
**Database**: MySQL/PostgreSQL (Laravel default)

---

### 12. safesphere.my.id
> **Domain**: https://safesphere.my.id  
> **Path**: `/var/www/safesphere.my.id/public`  
> **Stack**: Node.js, Express, SQLite  
> **Type**: Anti-Bullying Reporting System  
> **Status**: Active (Pilot Ready)

**Deskripsi**: SafeSphere - Aplikasi pelaporan anonim anti-perundungan untuk kampus.

**Fitur Utama**:
- Pelaporan anonim tanpa identitas
- Pelaporan rahasia (login required)
- User registration & login (bcrypt)
- Admin user management
- Evidence upload dengan enkripsi AES-256-GCM
- Dashboard user dan admin
- Workflow status: Baru Masuk → Direview → Diproses → Selesai
- SafeBot dengan risk classification
- Edukasi bystander (6 skenario)
- Quick escape (Esc×2)
- Rate limiting persisten
- Audit logging

**Arsitektur**:
```
Browser → Apache (HTTPS) → Express :3000 → SQLite
```

**Stack**: Node.js 18+, Express, SQLite, Xiaomi MiMo AI (optional)  
**Testing**: 78 API tests + 7 Playwright E2E tests  
**Status**: Siap pilot terbatas (1 fakultas, 30 hari)

**Security Features**:
- Session persisten SQLite + RBAC
- Cookie HttpOnly, SameSite=Strict, Secure
- Helmet, CSP, Rate limiting
- PII redaction + prompt injection filter
- Evidence terenkripsi, scanner strict

---

### 13. simpelu.my.id
> **Domain**: https://simpelu.my.id  
> **Path**: `/var/www/simpelu.my.id/public`  
> **Stack**: PHP 8.2+ native, MySQL 8+  
> **Type**: Campus Management System  
> **Status**: Active

**Deskripsi**: SIMPEL-U - Sistem Informasi Manajemen Kampus. Migrasi dari Google Apps Script ke PHP native.

**Fitur Utama**:
- Multi-role auth (Super Admin, Admin, Dosen, Mahasiswa)
- Surat masuk/keluar dengan workflow
- KIPK & KIP Calon (beasiswa)
- Bantuan SPP
- PKM (proposal dengan validasi dosen)
- Event (registrasi, absensi QR/GPS)
- Prestasi, dokumen, sertifikat, wiramuda
- Pengumuman (popup, gambar, Telegram/email)
- Dashboard analytics
- Activity log
- Landing page publik

**Stack**: PHP 8.2+, MySQL 8+, PDO  
**Arsitektur**: MVC custom (no Laravel/Composer)  
**Database**: MySQL  
**Testing**: PHPUnit  
**Roles**: SUPER_ADMIN, ADMIN, DOSEN, MAHASISWA

**Documentation**:
- `codebase.md` - Codebase documentation
- `docs/ERD_SIMPELU_PHP_MYSQL.md` - ERD
- `docs/SETUP_MIGRATION.md` - Setup guide

---

### 14. sjmlelang.com
> **Domain**: https://sjmlelang.com  
> **Path**: `/var/www/sjmlelang.com`  
> **Stack**: PHP 7.4+ native  
> **Type**: Online Auction Platform  
> **Status**: Active

**Deskripsi**: Lelangu.my.id - Platform lelang online berbasis waktu (timed auction).

**Fitur Utama**:
- **Peserta**: Registrasi, verifikasi email, profil lengkap, pembelian NIPL, bidding real-time, anti-sniping, verifikasi pembayaran, download risalah lelang
- **Admin**: Event/lot/produk management, verifikasi peserta/NIPL/pembayaran, dashboard control room, sistem settings, FAQ, audit log, export data
- **Keamanan**: Bcrypt, CSRF, rate limiting, session security, prepared statements, audit logging

**Stack**: PHP 7.4+, MySQL  
**No Framework**: Pure PHP  
**Documentation**: `README.md`, `panduan.md`, `saran.md`

---

### 15. socai.my.id
> **Domain**: https://socai.my.id  
> **Path**: `/var/www/socai.my.id`  
> **Stack**: Node.js, Express, PostgreSQL, Telegraf  
> **Type**: Main Platform + Telegram Bot  
> **Status**: Active

**Deskripsi**: SocAI.my.id - Platform utama dengan Telegram bot dan AI capabilities.

**Fitur Utama**:
- Web server dengan Express
- Telegram bot (Telegraf)
- PostgreSQL database
- Pi SDK integration
- Session management
- File upload (multer)
- Security (Helmet)

**Stack**: Node.js 24+, Express 5, PostgreSQL, Telegraf, Pi SDK, bcryptjs  
**Dependencies**: express, pg, telegraf, helmet, multer, bcryptjs, dotenv

---

### 16. studdybuddy.socai.my.id
> **Domain**: https://studdybuddy.socai.my.id  
> **Path**: `/var/www/studdybuddy.socai.my.id/public`  
> **Stack**: Laravel, MongoDB, Groq API  
> **Type**: AI Study Assistant  
> **Status**: Active

**Deskripsi**: AI Study Buddy - Aplikasi web berbasis AI untuk membantu mahasiswa memahami materi kuliah.

**Fitur Utama**:
- Dashboard statistik
- Input materi manual
- AI Summarizer (Groq AI)
- AI Quiz Generator (pilihan ganda, essay)
- AI Study Plan
- Riwayat AI (history di MongoDB)
- Upload materi (PDF, DOCX, TXT, gambar)
- Chat Material (tanya jawab dengan dokumen)
- Login/Register (MongoDB)
- Profil akun
- Landing page modern dengan particle animation

**Stack**: Laravel, MongoDB, Groq API (LLaMA model), Bootstrap 5, Blade  
**AI Provider**: Groq API  
**Database**: MongoDB  
**Developer**: Fathur Rohman

---

### 17. vibeplan.socai.my.id
> **Domain**: https://vibeplan.socai.my.id  
> **Path**: `/var/www/vibeplan.socai.my.id`  
> **Stack**: Laravel (Backend), Next.js (Frontend), MongoDB  
> **Type**: AI Planning Assistant  
> **Status**: Active

**Deskripsi**: VibePlan AI - Workspace AI untuk menyusun dokumen perencanaan software.

**Fitur Utama**:
- Generate PRD (Product Requirement Document)
- Generate Next Step Planner
- Generate Coding Prompt
- User Journey, Data Model & ERD, API Design
- Result detail dan history
- Download Markdown
- Profile management
- Token request
- Admin dashboard (AI settings, user, support chat)
- Live chat / bantuan
- Login/Register, Google OAuth

**Stack**: Laravel (Backend API), Next.js (Frontend), MongoDB Atlas, AI Provider  
**Target User**: Mahasiswa, developer pemula, tim startup kecil

---

## 📈 Project Categories

### By Stack
| Stack | Projects |
|-------|----------|
| **PHP Native** | aidis.my.id, al-barokah.my.id, kl.socai.my.id, sjmlelang.com, simpelu.my.id |
| **Laravel** | brainboard.socai.my.id, quizify.socai.my.id, studdybuddy.socai.my.id, vibeplan.socai.my.id, eduguide.socai.my.id |
| **Node.js/Express** | bot.shm.my.id, cmaestro.my.id, safesphere.my.id, socai.my.id |
| **Static** | botjb.nanariset.my.id, fetal.pjdigital.top |
| **Node.js (Utility)** | inv.nanariset.my.id |

### By Type
| Type | Projects |
|------|----------|
| **AI Chatbot** | cmaestro.my.id, bot.shm.my.id |
| **AI Assistant** | eduguide.socai.my.id, studdybuddy.socai.my.id, vibeplan.socai.my.id |
| **Campus System** | simpelu.my.id, aidis.my.id |
| **E-Commerce/Marketplace** | sjmlelang.com, kl.socai.my.id |
| **Reporting System** | safesphere.my.id |
| **Landing Page** | al-barokah.my.id |
| **Invoice** | inv.nanariset.my.id |

### By Database
| Database | Projects |
|----------|----------|
| **PostgreSQL** | aidis.my.id, socai.my.id |
| **MySQL** | simpelu.my.id, kl.socai.my.id, sjmlelang.com, bot.shm.my.id |
| **MongoDB** | studdybuddy.socai.my.id, vibeplan.socai.my.id, eduguide.socai.my.id |
| **SQLite** | cmaestro.my.id, safesphere.my.id |
| **Supabase** | eduguide.socai.my.id |

---

## 🔧 Server Configuration

### Apache Modules
- mod_rewrite
- mod_ssl
- mod_proxy (for Node.js apps)

### SSL
All domains have SSL via Let's Encrypt (certbot).

### Process Management
- **PM2**: Used for Node.js apps (cmaestro, safesphere, socai)
- **systemd**: Used for bot.shm.my.id

### Key Directories
```
/var/www/
├── aidis.my.id/           # PHP + PostgreSQL
├── al-barokah.my.id/      # PHP landing page
├── botjb.nanariset.my.id/ # Static placeholder
├── bot.shm.my.id/         # Node.js Telegram bot
├── brainboard.socai.my.id/# Laravel
├── cmaestro.my.id/        # Node.js AI chatbot
├── eduguide.socai.my.id/  # Next.js + Laravel
├── fetal.pjdigital.top/   # Unknown
├── inv.nanariset.my.id/   # Node.js invoice
├── kl.socai.my.id/        # PHP landing + admin
├── quizify.socai.my.id/   # Laravel
├── safesphere.my.id/      # Node.js reporting
├── simpelu.my.id/         # PHP campus system
├── sjmlelang.com/         # PHP auction
├── socai.my.id/           # Node.js main platform
├── studdybuddy.socai.my.id/# Laravel + MongoDB
└── vibeplan.socai.my.id/  # Laravel + Next.js
```

---

## 📝 Notes for Pi Agents

### When Working on This Server
1. **Check which project** you're working on (path matters!)
2. **Different stacks** = different conventions
3. **PHP projects** may use frameworks (Laravel) or native
4. **Node.js projects** use TypeScript mostly
5. **Databases vary** - check which one per project

### Common Patterns
- Most PHP projects use `public/` as document root
- Laravel projects have `artisan`, `app/`, `resources/`, `routes/`
- Node.js projects have `package.json`, `src/`, `dist/`
- All have SSL enabled
- Most use `.env` for configuration

### Project Documentation
Each project may have:
- `README.md` - Main documentation
- `AGENTS.md` - Agent guidelines
- `docs/` - Additional documentation
- `wiki.md` or `codebase.md` - Codebase documentation

---

*Inventory compiled by Pi agent on 2026-06-25*
*Source: /etc/apache2/sites-available/ and /var/www/*
