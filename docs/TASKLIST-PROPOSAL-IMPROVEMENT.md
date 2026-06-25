# Tasklist — Improvement UI/UX Halaman `/proposal`

Dokumen ini merinci analisis mendalam dan rencana perbaikan UI/UX halaman **Proposal & LPJ** (`pages/proposal.php`), berdasarkan audit kode 2026-06-15.

**Status legenda:** `[ ]` belum | `[~]` berjalan | `[x]` selesai

**Scope utama:** `pages/proposal.php` (~3100 baris), `api/proposal.php` (hanya jika perlu endpoint baru), referensi visual `pages/dashboard.php` / `pages/monitoring.php`.

**Prinsip:** Halaman proposal = **workspace operasional** (filter → review → aksi), bukan duplikat dashboard analytics.

**Referensi sebelumnya:** `docs/proposal-uiux-checklist.md` (2026-05-31) — mayoritas item **sudah diimplementasi** (lihat § Inventaris selesai).

---

## Ringkasan analisis

### Arsitektur halaman saat ini

| Aspek | Kondisi |
|-------|---------|
| **Data** | Satu fetch `GET api/proposal?action=getProposals` → seluruh dataset di memori (`allProposals`) |
| **Filter** | Client-side: tab (Proposal/LPJ/Wajib LPJ), status chips, keuangan, prioritas, URL params (`status`, `fin`, `tab`, `overdue`, `mine`, `approve`, `submitted`) |
| **Tampilan** | Tabel 9 kolom + pagination client 15/baris |
| **Aksi** | Max 3 tombol primary + dropdown ellipsis per baris; 8+ modal (create, detail, status, revisi, anggaran, keuangan, tanggal, undo, AI, konfirmasi) |
| **Role** | Permission via JS (`canEdit`, `canRevise`, `canGenerateLembar`, dll.) — selaras API |

### Kekuatan (pertahankan)

- Deep link dari dashboard sudah dibaca (`applyUrlFilters()`)
- Tab Wajib LPJ + flow LPJ terkunci (`openLpjFromMandatory`, parent proposal)
- Dropdown aksi (ellipsis) mengurangi kepadatan baris
- Detail modal dengan tab **Detail** / **Riwayat**
- Validasi form inline (`validateProposalForm`, `validateStatusProposalForm`)
- Konfirmasi hapus (`confirmActionModal`), undo approval (Super Admin)
- Search debounce 300ms, sort tanggal/anggaran/durasi, stats card clickable
- Sanitasi AI output (`formatAnalysis` whitelist DOM)
- Toast sebelum buka PDF lembar pengesahan

### Masalah utama (prioritas perbaikan)

| # | Masalah | Dampak |
|---|---------|--------|
| 1 | **Visual tidak selaras** dengan dashboard Fase 3 (`rounded-3xl`, `slate`, `max-w-7xl`, hero) | Terasa seperti halaman lama vs Pusat Kendali baru |
| 2 | **Filter overload** — 3 baris chip + search sebelum tabel | Cognitive load tinggi; Approver/User overwhelmed |
| 3 | **Stats card global** — angka tidak mengikuti tab aktif (Proposal vs LPJ) | Angka "Total" misleading saat tab LPJ |
| 4 | **Tidak ada bar filter aktif + reset** — hanya teks di pagination | User tidak sadar filter kompleks; sulit clear |
| 5 | **URL tidak disinkronkan** saat user mengubah filter | Tidak bisa share/bookmark view; deep link satu arah |
| 6 | **Mobile** — tabel 9 kolom tanpa fallback card | Unusable di layar < 768px |
| 7 | **Overdue tidak terlihat** di baris (`is_overdue` hanya filter URL) | SA/Admin miss item urgent tanpa buka dashboard |
| 8 | **Bug kecil** — loading/search `colspan="8"` padahal 9 kolom | Layout skeleton salah |
| 9 | **Keuangan filter** tampil untuk semua role | Approver/User jarang butuh; noise |
| 10 | **Monolith 3100+ baris** | Risiko regresi; sulit review |

### Inventaris selesai (`docs/proposal-uiux-checklist.md`)

Item berikut **sudah ada di kode** — tidak perlu diulang:

- [x] 1.1 Ellipsis dropdown aksi (max 3 primary)
- [x] 1.2 Sembunyikan filter saat tab Wajib LPJ + note
- [x] 1.3 Status cell truncate + badge keuangan baris terpisah
- [x] 1.4 Empty state per tab + role-aware CTA
- [x] 1.5 Detail modal tab Detail / Riwayat
- [x] 2.1 Search debounce + loading tbody
- [x] 2.2 Stats card click → filter
- [x] 2.3 Sort tanggal/anggaran/durasi
- [x] 2.4 Tombol AI prominent (hijau + label)
- [x] 2.5 Pagination info + label filter aktif
- [x] 2.6 Konfirmasi hapus (modal)
- [x] 2.7 Validasi form inline
- [x] 2.8 Status badge stack vertikal
- [x] 3.1 PDF loading toast
- [x] 3.2 XSS sanitize `formatAnalysis`
- [x] 3.3 (sebagian) Field order modal create

---

## Fase 1 — Quick Win (prioritas tinggi)

Target: perbaikan langsung terasa tanpa redesign penuh.

### PROP-1.1 — Selaraskan visual dengan dashboard/monitoring

- [x] Layout: `bg-gray-50/50`, `max-w-7xl mx-auto`, `space-y-6`
- [x] Hero: judul `font-extrabold text-slate-900`, subteks `text-slate-500`, tombol CTA konsisten dashboard
- [x] Stats cards: `rounded-3xl border-slate-100`, decorative blob opsional
- [x] Tabel container: `rounded-3xl` (bukan `rounded-2xl` saja)

**Acceptance:** Buka `/proposal` setelah `/dashboard` — terasa satu keluarga desain.

**Files:** `pages/proposal.php` (HTML + class Tailwind)

---

### PROP-1.2 — Stats card mengikuti tab aktif

- [x] Hitung `statTotal`, `statMenunggu`, dll. dari `getDataByActiveTab()` bukan `allProposals` global
- [x] Tab Wajib LPJ: stats opsional disembunyikan atau label khusus "Proposal Wajib LPJ"

**Acceptance:** Tab LPJ → angka Total = jumlah LPJ saja, bukan seluruh record.

**Files:** `pages/proposal.php` (`loadProposals`, helper `updateStatsCards()`)

---

### PROP-1.3 — Bar filter aktif + tombol "Reset filter"

- [x] Tambah `#activeFiltersBar` di bawah search: chip untuk setiap filter aktif (status, keuangan, prioritas, overdue, dll.)
- [x] Tombol **Reset semua filter** → `resetAllFilters()` (tab tetap, atau reset ke default per role)
- [x] Tetap pertahankan ringkasan di pagination sebagai secondary

**Acceptance:** User apply 3 filter → chip terlihat → satu klik reset → kembali ke Semua.

**Files:** `pages/proposal.php` (HTML + JS)

---

### PROP-1.4 — Indikator overdue di baris tabel

- [x] Jika `p.is_overdue`: border kiri baris `border-l-4 border-red-500` atau badge kecil "Overdue"
- [x] Tooltip: hari menunggu vs threshold sistem

**Acceptance:** Item dengan `is_overdue=true` langsung terlihat tanpa filter `?overdue=1`.

**Files:** `pages/proposal.php` (`renderProposals`)

---

### PROP-1.5 — Perbaikan bug colspan & sticky header

- [x] Ubah semua loading/empty row `colspan` ke **9**
- [x] `thead` sticky (`sticky top-0 z-10 bg-gray-50`) di dalam scroll container

**Acceptance:** Skeleton loading menutup lebar tabel; scroll panjang → header kolom tetap terbaca.

**Files:** `pages/proposal.php`

---

### PROP-1.6 — Filter keuangan & prioritas per role

- [x] **Super Admin / Admin:** tampilkan bar keuangan + chip Overdue (jika belum ada)
- [x] **Approver:** sembunyikan bar keuangan; default atau sorot "Prioritas Saya" saat `?approve=1`
- [x] **User:** sembunyikan keuangan (kecuali tab Disetujui + milik sendiri — opsional Fase 2)
- [x] **Read Only:** sembunyikan semua chip aksi create; filter read-only only

**Acceptance:** Login Approver → tidak melihat filter keuangan; prioritas jelas.

**Files:** `pages/proposal.php` (PHP `$role` + `updateFilterVisibility()`)

---

## Fase 2 — UX operasional (prioritas sedang)

### PROP-2.1 — Sinkronisasi URL (shareable state)

- [x] `syncUrlFromFilters()` — `history.replaceState` saat tab/filter/search berubah
- [x] Param: `tab`, `status`, `fin`, `priority`, `mine`, `approve`, `overdue`, `submitted`, `q` (search)
- [x] Load awal tetap `applyUrlFilters()`; hindari loop infinite

**Acceptance:** Set filter → copy URL → buka tab baru → state sama.

**Files:** `pages/proposal.php`

---

### PROP-2.2 — Layout mobile: card view

- [x] Breakpoint `< md`: sembunyikan tabel, tampilkan `#proposalCardList` (kartu per item)
- [x] Kartu: nama kegiatan, status, pengaju, tanggal, aksi primary + ellipsis
- [x] Pagination shared dengan tabel

**Acceptance:** Viewport 375px — tidak perlu scroll horizontal; aksi tetap accessible.

**Files:** `pages/proposal.php`

---

### PROP-2.3 — Kolaps "Filter lanjutan"

- [x] Gabung baris status chips + keuangan ke dalam panel collapsible **Filter lanjutan**
- [x] Default: terbuka untuk SA/Admin; collapsed untuk User/Approver
- [x] Tab chips (Proposal/LPJ/Wajib LPJ) tetap selalu visible

**Acceptance:** Above-the-fold lebih ringkas; power user tetap akses filter penuh.

**Files:** `pages/proposal.php`

---

### PROP-2.4 — Prioritas aksi per role di baris

- [x] **Approver** + `canEdit(p)`: primary slot 1 = Update Status (bukan AI)
- [x] **Super Admin:** pertahankan AI + detail; reminder bell tetap di status cell
- [x] **User** + revisi: primary = Upload Revisi jika `canRevise`

**Acceptance:** Approver melihat tombol approve hijau lebih dominan dari AI.

**Files:** `pages/proposal.php` (`renderProposals` primary action logic)

---

### PROP-2.5 — Hero kontekstual per role

- [x] Subteks dinamis satu baris (mirip dashboard headline):
  - Approver: "X menunggu persetujuan Anda"
  - User: "X perlu revisi"
  - SA: "X overdue, Y wajib LPJ" (dari data client)
- [x] Opsional: badge link ke filter terkait

**Acceptance:** Hero menjawab "apa yang harus saya lakukan?" tanpa scroll.

**Files:** `pages/proposal.php` (JS setelah `loadProposals`)

---

### PROP-2.6 — Dropdown aksi: positioning & overflow

- [x] Deteksi viewport bawah — flip dropdown ke `bottom-full` jika terpotong
- [x] Tambah class `action-dropdown-menu` konsisten (fix selector di `toggleActionDropdown` — saat ini query `.action-dropdown-menu` tapi id `dropdown-menu-*`)

**Acceptance:** Baris terakhir tabel — menu ellipsis tidak terpotong container.

**Files:** `pages/proposal.php`

---

## Fase 3 — Detail & modals (prioritas sedang–rendah)

### PROP-3.1 — Preview PDF inline di modal detail

- [x] Tab **Detail** → jika file PDF: `<iframe>` atau embed di bawah metadata (tinggi max 400px)
- [x] Fallback link "Buka di tab baru" tetap ada
- [x] LPJ: tampilkan proposal sumber + file LPJ berdampingan

**Acceptance:** Review approver bisa baca PDF tanpa tab baru (desktop).

**Files:** `pages/proposal.php` (`renderDetailContent`)

---

### PROP-3.2 — Modal create: konsistensi tema maroon

- [x] Header modal create: gradient maroon (bukan `from-primary to-blue-600`)
- [x] Step indicator opsional: (1) Identitas → (2) Keuangan → (3) Dokumen

**Acceptance:** Modal selaras brand LK UKMs.

**Files:** `pages/proposal.php`

---

### PROP-3.3 — Status update modal: konteks proposal

- [x] Tampilkan nama kegiatan + pengaju + approver saat ini di header `statusProposalModal`
- [x] Disable opsi "Disetujui" jika bukan giliran (Approver) — dengan pesan

**Acceptance:** Approver tidak bingung proposal mana yang di-update.

**Files:** `pages/proposal.php` (`openStatusProposal`)

---

### PROP-3.4 — Riwayat tab: timeline visual

- [x] Ganti list plain menjadi timeline vertikal (ikon per status: setuju/revisi/tolak/undo)
- [x] Highlight entry terakhir; tampilkan `_snapshot` undo jika ada

**Acceptance:** Riwayat approval terbaca dalam <5 detik.

**Files:** `pages/proposal.php` (`renderTimeline`, `renderDetailContent`)

---

### PROP-3.5 — Empty state saat filter aktif

- [x] Bedakan copy: "Tidak ada data" vs "Tidak ada hasil untuk filter X" + CTA **Reset filter**
- [x] Jangan tampilkan CTA "Tambah Proposal" jika filter aktif dan role User

**Acceptance:** User tidak mengira sistem kosong padahal hanya filter ketat.

**Files:** `pages/proposal.php` (`updateEmptyStateCopy`, `renderProposals`)

---

## Fase 4 — Performa & maintainability (prioritas rendah)

### PROP-4.1 — Server-side pagination & filter (opsional besar)

- [x] Extend `getProposals`: param `page`, `per_page`, `status`, `jenis`, `fin`, `search`
- [x] Frontend: fetch per halaman; stats dari endpoint terpisah atau header response
- [x] Guard performa jika >500 proposal

**Acceptance:** Load halaman <2s dengan 1000+ record.

**Files:** `api/proposal.php`, `pages/proposal.php`

---

### PROP-4.2 — Ekstrak JS ke modul terpisah

- [x] `public/js/proposal-page.js` atau `assets/proposal.js` — render, filter, modals
- [x] PHP page hanya config role + include script
- [x] Tidak ubah behavior; pure refactor

**Acceptance:** `pages/proposal.php` <800 baris HTML/PHP.

**Files:** struktur baru + `pages/proposal.php`

---

### PROP-4.3 — Preset filter Super Admin

- [x] Chip preset: "Antrian Keuangan", "Wajib LPJ", "Overdue", "Menunggu ACC"
- [x] Map ke query param existing (sama dengan dashboard deep links)

**Acceptance:** SA satu klik ke daftar yang sama dengan kartu dashboard.

**Files:** `pages/proposal.php`

---

## Fase 5 — Role polish (setelah Fase 1–2 stabil)

### PROP-5.1 — Approver landing experience

- [ ] Jika `?approve=1` atau first visit session: auto-enable Prioritas Saya + sort durasi desc
- [ ] Banner tip singkat dismissible: "Hanya proposal di giliran Anda yang dapat disetujui"

**Files:** `pages/proposal.php`

---

### PROP-5.2 — User LPJ journey

- [ ] Tab Wajib LPJ: highlight kartu dengan CTA "Unggah LPJ" di mobile card view
- [ ] Setelah submit LPJ sukses → redirect ke tab LPJ + toast

**Files:** `pages/proposal.php`, form submit handler

---

### PROP-5.3 — Read Only mode

- [ ] Sembunyikan tombol aksi di baris (hanya Detail + PDF view)
- [ ] Banner: "Mode baca saja — tidak dapat mengubah data"

**Files:** `pages/proposal.php` (`renderProposals`, PHP guard)

---

### PROP-5.4 — Admin scope indicator

- [ ] Subteks hero: "Menampilkan proposal di chain Anda & milik sendiri" (selaras dashboard Admin)
- [ ] Stats hanya dari data yang API sudah filter (sudah scoped di `getProposals`)

**Files:** `pages/proposal.php`

---

## Urutan eksekusi disarankan

```
[x] PROP-1.5  colspan + sticky header (bugfix cepat)
[x] PROP-1.2  stats per tab
[x] PROP-1.3  active filters bar + reset
[x] PROP-1.4  overdue row indicator
[x] PROP-1.6  filter per role
[x] PROP-1.1  visual alignment
[~] Smoke test per role (User, Approver, Admin, SA, Read Only)
[x] PROP-2.1  URL sync
[x] PROP-2.4  action priority per role
[x] PROP-2.2  mobile cards
[x] PROP-2.3  collapsible advanced filters
[x] PROP-2.5  hero kontekstual
[x] PROP-2.6  dropdown positioning
[x] PROP-3.x  detail & modals
[x] PROP-4.x  performa & refactor
[ ] PROP-5.x  role polish
```

---

## File yang kemungkinan disentuh

| File | Perubahan |
|------|-----------|
| `pages/proposal.php` | Utama — layout, filter, render, modals |
| `api/proposal.php` | Opsional Fase 4 — pagination server-side |
| `templates/footer.php` | Opsional — extract global helpers |
| `arsitektur.md` | Dokumentasi § proposal UI setelah Fase 1 selesai |
| `docs/proposal-uiux-checklist.md` | Tandai legacy / arsip setelah Fase 1 |

---

## Definisi selesai (DoD)

- [x] Visual selaras dashboard (Fase 1.1)
- [x] Mobile usable tanpa scroll horizontal (Fase 2.2)
- [x] Filter state shareable via URL (Fase 2.1)
- [x] Overdue terlihat di tabel (Fase 1.4)
- [ ] Tidak regresi: create proposal/LPJ, approve, revisi, undo, PDF, AI
- [ ] `rtk php -l pages/proposal.php` (+ `api/proposal.php` jika diubah)
- [ ] Smoke manual 5 role

---

## Matriks regresi manual

| Skenario | User | Approver | Admin | Super Admin | Read Only |
|----------|:----:|:--------:|:-----:|:-----------:|:---------:|
| Tambah Proposal | ✓ | — | — | — | — |
| Tambah LPJ (wajib) | ✓ | — | — | — | — |
| Approve / Revisi / Tolak | — | ✓ | ✓ | ✓ | — |
| Edit anggaran | — | — | ✓ | ✓ | — |
| Status keuangan | — | — | — | ✓ | — |
| Undo approval | — | — | — | ✓ | — |
| Lembar pengesahan PDF | ✓* | — | — | ✓ | — |
| AI analysis | — | — | ✓ | ✓ | — |
| Deep link dashboard | ✓ | ✓ | ✓ | ✓ | ✓ |
| Hanya lihat detail | — | — | — | — | ✓ |

\* User/ketua-dpm untuk proposal/LPJ milik sendiri yang disetujui.

---

## Catatan teknis

- **PDF endpoints** (`generateLembarPengesahan`, `generateLembarPengesahanLPJ`) tetap stream binary — jangan ubah ke JSON.
- **Pretty URL API** wajib: `api/proposal`, bukan `api/proposal.php`.
- **`is_overdue`** sudah dikirim dari API (`getProposals`) — manfaatkan di UI.
- **Admin `canEdit`** di UI return `true` untuk semua baris yang tampil; API tetap enforce chain — jangan tampilkan aksi untuk baris di luar scope jika data leak (verifikasi `getProposals` filter).
- Pertimbangkan feature flag `PROPOSAL_UX_V2=1` di `system_config` untuk rollout bertahap (opsional).

---

## Estimasi effort (kasar)

| Fase | Effort | Impact |
|------|--------|--------|
| Fase 1 | 1–2 hari | Tinggi |
| Fase 2 | 2–3 hari | Tinggi |
| Fase 3 | 1–2 hari | Sedang |
| Fase 4 | 3–5 hari | Sedang (skalabilitas) |
| Fase 5 | 1 hari | Sedang |