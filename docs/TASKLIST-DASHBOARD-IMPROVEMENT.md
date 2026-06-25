# Tasklist — Improvement Dashboard Super Admin

Dokumen ini merinci perbaikan UI/UX halaman `/dashboard` untuk role **Super Admin**, berdasarkan analisis sesi 2026-06-15.

**Status legenda:** `[ ]` belum | `[~]` berjalan | `[x]` selesai

**Scope utama:** `pages/dashboard.php`, `api/users.php` (`getDashboardStats`), opsional `pages/monitoring.php` (referensi visual).

**Prinsip:** Dashboard Super Admin = **command center operasional**, bukan duplikat halaman Monitoring atau Proposal.

---

## Ringkasan masalah

| # | Masalah | Dampak |
|---|---------|--------|
| 1 | Super Admin ≈ Admin (aksi cepat & kartu sama) | Tugas eksklusif SA tidak terlihat di dashboard |
| 2 | Informasi repetitif (proposal menunggu di 3 section) | Scroll panjang, bingung angka mana yang diprioritaskan |
| 3 | KPI khas SA tidak ada (keuangan menunggu, wajib LPJ, overdue) | SA harus buka banyak menu untuk tahu antrian |
| 4 | `activeToday` sudah di API, tidak ditampilkan | Data terbuang |
| 5 | Deep link stat kurang spesifik | Klik kartu → `/proposal` tanpa filter |
| 6 | Visual tidak selaras dengan `/monitoring` | Terasa seperti dua produk berbeda |

---

## Fase 1 — Quick Win (prioritas tinggi) — selesai 2026-06-15

Target: Super Admin langsung merasakan dashboard “milik mereka” tanpa redesign penuh.

### DASH-1.1 — Panel antrian khusus Super Admin

- [x] **Backend: tambah field `superAdminQueue` di `getDashboardStats()`**
  - `keuanganMenunggu` — proposal `Disetujui` + `status_keuangan = Menunggu`
  - `prosesKeuangan` — count proposal `status_keuangan = Proses Keuangan` (+ opsional total rupiah)
  - `wajibLpj` — proposal dicairkan tanpa LPJ (reuse logic tab Wajib LPJ / query existing)
  - `overdue` — proposal menunggu melewati threshold (`PROPOSAL_PENDING_THRESHOLD_DAYS` dari system_config)
  - Guard: hanya hitung jika `role === 'Super Admin'`

- [x] **Frontend: section baru `Antrian Super Admin`** (di atas fold, setelah hero)
  - 4 kartu besar dengan warna severity (kuning/ungu/amber/merah)
  - Deep link spesifik ke `/proposal` dengan query filter yang sesuai
  - Tampilkan hanya jika `dashboardRole === 'Super Admin'`

**Acceptance:**
- Login Super Admin → 4 kartu antrian tampil dengan angka benar
- Login Admin → panel tidak tampil (Admin tetap pakai layout lama Fase 1)
- Klik kartu → membuka daftar proposal yang relevan (bukan `/proposal` generik)

---

### DASH-1.2 — Aksi cepat diferensiasi Super Admin

- [x] **Pisahkan quick actions SA vs Admin** di `dashboard.php` (PHP `if ($role === 'Super Admin')`)

**Super Admin — baris Operasional:**
- Monitoring
- Proposal & LPJ (dengan badge jika `actionTotal > 0`)
- Disposisi
- Surat

**Super Admin — baris Administrasi:**
- Kelola Users
- Kelola Alur
- Pengaturan Sistem
- Laporan
- Activity Logs
- Arsip Proposal

- [x] Admin pakai set operasional (Monitoring, Laporan, Pengumuman, Surat) — Fase 4

**Acceptance:**
- Super Admin melihat ≥8 shortcut ke menu eksklusif/tugas harian
- Tidak ada regresi menu Admin

---

### DASH-1.3 — Tampilkan user aktif hari ini

- [x] **Frontend:** kartu kecil di hero atau di baris ringkasan atas
  - Data: `stats.activeToday` / `stats.totals.activeToday` (sudah ada di API)
  - Label: “User login hari ini”
  - Link opsional: `/activity_logs`

**Acceptance:**
- Angka login sukses hari ini tampil dan konsisten dengan query activity_logs

---

### DASH-1.4 — Kurangi duplikasi section proposal

- [x] **Super Admin:** sembunyikan atau gabungkan salah satu dari:
  - `Butuh Tindakan` (4 kartu), atau
  - `Akses Cepat Proposal` (3 kartu)
- [ ] **Keputusan disarankan:** pertahankan `Antrian Super Admin` (DASH-1.1) + satu section “Prioritas Proposal” (gabungan 4 kartu, tanpa duplikat angka)
- [ ] Hapus kartu redundan dari `Ringkasan` yang sudah ada di panel atas (mis. `proposalMenunggu` jika sudah di prioritas)

**Acceptance:**
- Super Admin tidak melihat “proposal menunggu” di lebih dari 2 section
- Scroll above-the-fold berkurang ±30%

---

### DASH-1.5 — Deep link stat lebih spesifik

- [x] Update `href` kartu stat & antrian:
  - Keuangan Menunggu → `/proposal?status=disetujui&fin=menunggu` (atau filter setara di `proposal.php`)
  - Proses Keuangan → `/proposal?fin=proses`
  - Wajib LPJ → `/proposal?tab=wajib_lpj` (atau param existing)
  - Overdue → `/proposal?overdue=1`
  - Revisi → `/proposal?status=revisi`
  - Disposisi → `/disposisi?status=open`

- [x] Verifikasi `pages/proposal.php` & `pages/disposisi.php` membaca query param (tambah jika belum ada)

**Acceptance:**
- Klik setiap kartu membuka daftar terfilter, tidak perlu filter manual

---

### Verifikasi Fase 1

| Task | Tester | Hasil |
|------|--------|-------|
| DASH-1.1 panel antrian SA | | |
| DASH-1.2 aksi cepat SA | | |
| DASH-1.3 active today | | |
| DASH-1.4 kurangi duplikasi | | |
| DASH-1.5 deep link | | |
| Regresi Admin dashboard | | |
| Regresi User / Approver dashboard | | |

---

## Fase 2 — Polish UX (prioritas sedang) — selesai 2026-06-15

### DASH-2.1 — Ringkasan sistem collapsible

- [x] Section `Ringkasan` default collapsed untuk Super Admin (tombol “Tampilkan statistik lengkap”)
- [x] Expanded: tampilkan grid stat existing + subgroup Keuangan
- [x] Simpan preferensi di `sessionStorage` (`dashboard_stats_expanded`)

**Acceptance:**
- Dashboard SA lebih ringkas saat pertama load; stat lengkap tetap accessible

---

### DASH-2.2 — Indikator waktu pembaruan

- [x] Tampilkan “Terakhir diperbarui: HH:mm” di header section Antrian SA & Prioritas Sistem
- [x] Update timestamp setelah `loadDashboardData()` dan `refreshActionsOnly()` sukses

**Acceptance:**
- User tahu data masih fresh atau perlu klik Muat Ulang

---

### DASH-2.3 — Hero & greeting yang lebih kontekstual

- [x] Ganti `Dashboard Super Admin` → “Pusat Kendali” (Fase 1)
- [x] Subteks dinamis 1 baris dari API (`headlineSummary`)
- [x] Greeting time-of-day: `getGreetingPrefix()` → Selamat pagi/siang/sore/malam

**Acceptance:**
- Hero menampilkan ringkasan urgent tanpa scroll

---

### DASH-2.4 — Aktivitas terkini ringkas

- [x] Batasi tampilan default ke 5 item
- [x] Tombol “Lihat semua” → `/activity_logs` (header + footer)
- [x] Ikon aktivitas berbeda per jenis (`getActivityIcon`) — login, proposal, undo, delete

**Acceptance:**
- Section aktivitas tidak mendominasi layout; link ke logs jelas

---

### DASH-2.5 — Warna kartu by severity

- [x] Definisikan token warna: `urgent`, `warning`, `info`, `success`, `neutral` (`actionSeverityStyles`)
- [x] Terapkan ke kartu Prioritas Sistem / Butuh Tindakan (border-l); panel antrian SA sudah punya warna per kartu (Fase 1)

**Acceptance:**
- Kartu urgent (overdue, revisi) visually distinct tanpa mengubah brand maroon utama

---

## Fase 3 — Visual & analitik (prioritas rendah) — selesai 2026-06-15

### DASH-3.1 — Selaraskan gaya dengan Monitoring

- [x] Audit class Tailwind: `rounded-3xl`, `border-slate-100`, `max-w-7xl`, spacing mengikuti `pages/monitoring.php`
- [x] Hero card, antrian SA, stat card SA/Admin pakai pola visual monitoring (decorative blob, font-extrabold)
- [x] Tetap gunakan palette maroon primary dari `templates/header.php`

**Acceptance:**
- Dashboard & Monitoring terasa satu keluarga desain

---

### DASH-3.2 — Mini chart trend (opsional)

- [x] Extend `getDashboardStats`: `weeklyTrend` 7 hari (`calculateProposalWeeklyTrend`)
- [x] Chart.js line chart di section Ringkasan (CDN header)
- [x] Hanya Super Admin + Admin; fallback jika data kosong / Chart tidak tersedia

**Acceptance:**
- Chart load tanpa error; graceful fallback jika data kosong

---

### DASH-3.3 — Widget kesehatan sistem

- [x] Kartu: UKM/User tanpa alur (`calculateDashboardSystemHealth` → `ukmTanpaAlur`)
- [x] Kartu: approver chain tidak resolve (`approverTidakResolve` via `findApproverUsers`)
- [x] Link ke `/alur` dan `/users`; section hanya Super Admin

**Acceptance:**
- SA bisa deteksi misconfig alur dari dashboard

---

## Fase 4 — Admin & role lain (setelah SA stabil) — selesai 2026-06-15

### DASH-4.1 — Dashboard Admin terdedikasi

- [x] Panel antrian Admin (`adminQueue`: menunggu, revisi, overdue, baru — scope chain + milik sendiri)
- [x] API: `scopeLabel`, totals proposal & quick-access difilter `isProposalInAdminScope`
- [x] Quick actions: Monitoring, Laporan, Pengumuman, Surat + Proposal/Disposisi (badge); tanpa Users/Alur/Settings

### DASH-4.2 — Review dashboard User / Approver

- [x] User layout tidak berubah (proposal quick access + aksi cepat profil)
- [x] Approver: section **Prioritas Saya** `order-1` di atas fold; 3 kartu (menunggu, revisi, baru); tanpa duplikat quick access

### DASH-4.3 — Read Only / Disposisi

- [x] Disposisi: kartu disposisi + surat; tanpa proposal/keuangan di Ringkasan
- [x] Read Only: kartu proposal/surat/disposisi; subgroup Keuangan disembunyikan

---

## Urutan eksekusi disarankan

```
[x] DASH-1.5  deep link (prasyarat filter di proposal/disposisi)
[x] DASH-1.1  panel antrian SA (API + UI)
[x] DASH-1.2  aksi cepat SA
[x] DASH-1.3  active today
[x] DASH-1.4  kurangi duplikasi
[~] Verifikasi Fase 1 (smoke manual per role)
[x] DASH-2.x  polish UX (2026-06-15)
[x] DASH-3.x  visual & chart (2026-06-15)
[x] DASH-4.x  role lain (2026-06-15)
```

---

## File yang kemungkinan disentuh

| File | Perubahan |
|------|-----------|
| `api/users.php` | `getDashboardStats()` — field antrian SA, headline |
| `pages/dashboard.php` | Layout per role, section baru, JS render |
| `pages/proposal.php` | Baca query param filter (`fin`, `overdue`, `tab`) |
| `pages/disposisi.php` | Query `status=open` (jika belum) |
| `includes/functions.php` | Helper hitung wajib LPJ / overdue (reuse) |
| `arsitektur.md` | Dokumentasi dashboard SA setelah selesai |

---

## Definisi selesai (DoD)

- [ ] Super Admin membuka `/dashboard` dan dalam **≤2 scroll** melihat: antrian urgent, shortcut administrasi, headline ringkas
- [ ] Tidak ada angka proposal menunggu yang duplikat di >2 section
- [ ] Semua kartu antrian/prioritas punya deep link terfilter
- [ ] Admin / User / Approver tidak regresi (smoke test manual per role)
- [ ] `php -l` pada file PHP yang diubah
- [x] Update `arsitektur.md` § dashboard / onboarding SA (2026-06-15)

---

## Catatan

- **Tidak** menggabungkan `/monitoring` ke `/dashboard` — keduanya tetap terpisah; dashboard fokus **aksi**, monitoring fokus **analitik/chart**.
- Fitur **undo approval** tidak perlu widget khusus di dashboard Fase 1; cukup masuk activity logs / proposal.
- Pertimbangkan toggle `system_config` `DASHBOARD_SA_V2=1` jika ingin rollout bertahap (opsional, Fase 2+).