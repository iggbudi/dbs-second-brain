# Tasklist Perbaikan — Temuan Keamanan Kritis

Dokumen ini merinci tugas perbaikan untuk **2 temuan kritis (P0)** dari audit di `arsitektur.md`.

**Status legenda:** `[ ]` belum | `[~]` berjalan | `[x]` selesai

**Implementasi:** 2026-06-15 — commit perbaikan P0

---

## P0-1 — IDOR pada `getUser` (`api/users.php`)

**Masalah:** Endpoint `GET /api/users?action=getUser&id={N}` hanya memanggil `requireLogin()`. User dengan role apapun yang sudah login dapat membaca data user lain (email, telepon, role, NIM, unit).

**Dampak:** Kebocoran PII, enumerasi akun.

### Tasklist

- [x] **P0-1.1 — Tambah guard role di `getUser()`**
  - Implementasi: `requireRole(['Super Admin', 'Admin'])` di `api/users.php`
  - Acceptance: User/Approver memanggil `getUser` untuk ID orang lain → HTTP 403 JSON

- [x] **P0-1.2 — Audit pemanggil `getUser` di frontend**
  - Hasil: tidak ada pemanggilan `action=getUser` di `pages/` — hanya `getUsers` (Super Admin page)
  - Tidak ada regresi UI

- [x] **P0-1.3 — Verifikasi manual / smoke check**
  - `getUser` tanpa login → 401 ✓
  - `requireRole` di unit test via deploy ✓
  - Super Admin authenticated test: butuh kredensial produksi (default dev tidak valid di server live)

- [x] **P0-1.4 — Review endpoint GET lain di `api/users.php`**
  - Aman: `getUsers`, `getActivityLogs`, `getSystemSettings`, `getActiveUserTrend`
  - Sengaja terbuka (agregat): `getDashboardStats`, `getProposalBadgeCount`

---

## P0-2 — `api/wa_send.php` tanpa autentikasi

**Masalah:** File dapat diakses langsung sebagai file fisik (`/api/wa_send.php`). Tidak ada `requireLogin()`. CSRF opsional.

**Dampak:** Spam/abuse WA, biaya kuota, reputasi instance WA tercemar.

### Tasklist

- [x] **P0-2.1 — Kebijakan endpoint**
  - **Keputusan: Opsi A** — hapus endpoint HTTP publik; WA hanya via `sendWhatsAppNotification()` internal + `php test_wa.php` (CLI)

- [x] **P0-2.2 — Hardening (Opsi B)** — tidak dipakai (endpoint dihapus)

- [x] **P0-2.3 — Hapus file publik**
  - `api/wa_send.php` dihapus
  - `test_wa.php` tetap sebagai pengujian CLI

- [x] **P0-2.4 — Blokir akses langsung `api/*.php`**
  - `.htaccess`: `RewriteRule ^api/.+\.php$ - [F,L]`
  - `api/bootstrap.php` + include di semua file API (kompatibel nginx)
  - Tambah rewrite `api/laporan` di `.htaccess`
  - Inventaris: 9 file API + bootstrap; `wa_send` dihapus

- [x] **P0-2.5 — Rate limit pengiriman WA**
  - `includes/security.php`: `isWaRateLimited()` — max 50 / 15 menit per user atau IP
  - `sendWhatsAppNotification()` memanggil rate limit; CLI (`PHP_SAPI === 'cli'`) dikecualikan

- [x] **P0-2.6 — Verifikasi**
  - `POST /api/wa_send.php` → 404 ✓
  - Script: `php scripts/verify_security_p0.php https://lk.pjdigital.top`

---

## Urutan eksekusi (selesai)

```
[x] P0-1.1  patch getUser
[x] P0-1.3  verifikasi
[x] P0-2.1  keputusan wa_send (Opsi A)
[x] P0-2.3  hapus wa_send.php
[x] P0-2.4  .htaccess + api/bootstrap.php
[x] P0-1.2, P0-1.4, P0-2.5
```

---

## Verifikasi

| Task | Tanggal | Tester | Hasil |
|------|---------|--------|-------|
| P0-1.3 getUser tanpa login | 2026-06-15 | verify_security_p0.php | 401 PASS |
| P0-1.3 Super Admin getUser | 2026-06-15 | — | Skip (password produksi bukan default dev) |
| P0-2.6 wa_send tanpa auth | 2026-06-15 | verify_security_p0.php | 404 PASS |
| P0-2.4 direct api/users.php | 2026-06-15 | verify_security_p0.php | 403 setelah deploy bootstrap |

---

## P1 — Temuan sedang (selesai 2026-06-15)

- [x] **Page guard `monitoring.php` dan `arsip.php`**
  - HTTP redirect ke `/dashboard` untuk role selain Admin/Super Admin
  - Guard terpusat di `index.php` untuk `monitoring`, `laporan`, `arsip`

- [x] **Role check `getApprovalChain` (`api/proposal.php`)**
  - `User`: hanya `pengaju` = username sendiri
  - `Approver`: harus ada di chain pengaju (kecuali `ketua-dpm`)
  - `Admin`: di chain atau pengaju = username sendiri
  - `Super Admin` / `Read Only`: akses penuh
  - `Disposisi` dan role lain: 403

- [x] **`addArsipData` + `getArsipData` (`api/arsip.php`)**
  - Keduanya memanggil `requireRole(['Super Admin', 'Admin'])`

### Verifikasi P1

| Task | Tanggal | Hasil |
|------|---------|-------|
| getApprovalChain tanpa login | 2026-06-15 | 401 PASS |
| getArsipData tanpa login | 2026-06-15 | 401 PASS |
| /monitoring role User | 2026-06-15 | redirect dashboard (index.php) |

---

## P2 — Redirect halaman privileged (selesai 2026-06-15)

- [x] **Helper `redirectUnlessPageRole()`** di `includes/security.php`
  - HTTP 302 ke `/dashboard` (atau `/login` jika belum auth) — bukan JSON `requireRole()`

- [x] **Guard sebelum output HTML** di halaman:
  - `users`, `alur`, `system_settings` → Super Admin
  - `arsip_proposal` → Super Admin (ganti partial 403 HTML)
  - `activity_logs` → Admin/Super Admin (ganti `requireRole` JSON)
  - `monitoring`, `arsip`, `laporan`, `penggunaan_ruangan` → diseragamkan

- [x] **Guard terpusat `index.php`**
  - `activity_logs` ditambahkan ke `$adminOnlyPages`
  - `$superAdminOnlyPages`: users, alur, system_settings, arsip_proposal
  - `penggunaan_ruangan`: Super Admin, User, Approver

### Verifikasi P2

| Task | Hasil |
|------|-------|
| Tidak ada `window.location.href = "/dashboard"` di pages | PASS |
| `/users` tanpa login | 302 → `/login` |

---

## P3 — CORS policy ketat (selesai 2026-06-15)

**Masalah:** Beberapa API mengirim `Access-Control-Allow-Origin: *`, sehingga origin arbitrer bisa membaca respons API jika session/cookie tidak ketat.

### Tasklist

- [x] **Helper CORS terpusat** (`includes/security.php`)
  - `getAllowedApiOrigins()` — localhost, 127.0.0.1, `scheme://HTTP_HOST`, env `CORS_ALLOWED_ORIGINS` (comma-separated)
  - `applyApiCorsHeaders()` — reflect Origin hanya jika di allowlist; **tidak pernah `*`**
  - `applyApiSecurityHeaders()`, `handleApiPreflightRequest()` (OPTIONS → 204)

- [x] **Semua file API** memakai helper (ganti blok CORS lama)
  - `auth`, `users`, `proposal`, `surat`, `arsip`, `pengumuman`, `penggunaan_ruangan`, `alur`, `laporan`

- [x] **Verifikasi**
  - `grep` tidak ada sisa `Access-Control-Allow-Origin: *` di `api/`
  - `php scripts/verify_security_p0.php` — tes origin jahat + allowlist + no wildcard

### Verifikasi P3

| Task | Hasil |
|------|-------|
| Origin `https://evil.example.com` tidak direfleksikan | PASS (setelah deploy) |
| Origin same-host direfleksikan | PASS |
| OPTIONS tanpa `ACAO: *` | PASS |