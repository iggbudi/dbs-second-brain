# Analisis UI/UX Halaman `/proposal` — LK UKMs

**Tanggal analisis:** 2026-06-15
**Lokasi:** `pages/proposal.php` + `public/js/proposal-page.js` + `api/proposal.php` (read-only)
**Pendamping:** `docs/proposal-uiux-checklist.md` (2026-05-31) — digunakan sebagai baseline dan di-*cross-check* terhadap kondisi kode terkini (commit `c0f27ac` — Fase 4).

---

## 1. Ringkasan Eksekutif

Halaman `/proposal` adalah workspace utama untuk mengelola Proposal & LPJ. Permukaan UI saat ini sudah cukup matang: server-side pagination & filtering (Fase 4), preset filter untuk Super Admin, action overflow ke ellipsis dropdown, hero dinamis per role, tab Wajib LPJ, mobile card view, modal detail dengan tab "Detail" / "Riwayat/Revisi", integrasi AI Analysis berlapis, dan undo approval.

Secara keseluruhan kualitas UX-nya di atas rata-rata untuk aplikasi native PHP. Namun ada beberapa area yang masih bisa di-tingkatkan, terutama: konsistensi empty state saat filter aktif menghasilkan nol hasil (belum ada ringkasan konteks), inkonsistensi micro-feedback pada dropdown & status badge, potensi overflow pada kolom Durasi di mobile, dan satu catatan keamanan minor pada sanitasi hasil AI.

---

## 2. Peta Layar & Komponen

### 2.1 Struktur Halaman (atas → bawah)

| # | Region | Komponen | Kode | Catatan |
|---|---|---|---|---|
| 1 | Hero panel | Judul, deskripsi, headline dinamis, badge, CTA "Tambah" | `pages/proposal.php:13-36` | Conditional render CTA via `$canAddProposal` |
| 2 | Stats cards | 4 kartu: Total, Menunggu, Disetujui, Revisi/Tolak | `:38-60` | Clickable → `filterProposals()` |
| 3 | Catatan Wajib LPJ | Banner info | `:62-64` | Hidden by default |
| 4 | Workspace panel | Tabs, search, preset (Super Admin), filter lanjutan, active-filters bar, tabel/card, pagination, empty state | `:66-203` | Komponen paling padat |
| 5 | Empty state | Full-page empty | `:185-202` | Copy adaptif per tab & role |
| 6 | Modal Create | 4 step pill, form LPJ/Proposal | `:288-396` | Step pill hanya indikator visual (non-interaktif) |
| 7 | Modal AI | 3 stage progress + cached badge + tombol Lanjutkan | `:399-456` | Cache via `sessionStorage` |
| 8 | Modal Detail | Tab "Detail" / "Riwayat / Revisi" + preview PDF (iframe) | `:459-487` | PDF preview inline |
| 9 | Modal Update Status | Approve / Revisi / Tolak dengan catatan wajib | `:490-541` | Validasi giliran approver |
| 10 | Modal Upload Revisi | File PDF + catatan | `:544-580` | Catatan ≤ 500 karakter |
| 11 | Modal Edit Anggaran | Edit nominal + catatan | `:583-613` | Admin/Super Admin |
| 12 | Modal Edit Status Keuangan | 3 status + catatan | `:616-647` | Hanya Super Admin & final approved |
| 13 | Modal Edit Tanggal | Tanggal + catatan | `:650-683` | Hanya Super Admin |
| 14 | Modal Undo Approval | Preview + alasan | `:686-720` | Snapshot dari `_snapshot` history |
| 15 | Modal Konfirmasi | Generic confirm (hapus) | `:723-741` | Reusable |

### 2.2 View Modes (Responsive)

- **Desktop (≥ 768px):** Tabel di `#proposalTableScroll` (max-h `min(70vh, 800px)` + sticky `<thead>`).
- **Mobile (< 768px):** Card list di `#proposalCardList` (pakai class `.proposal-mobile-card`).
- **Switching:** CSS murni via media query di `<style>` `:236-243` (override `display:none` global `.hidden`).

**Catatan positif:** thead sticky + overflow-y auto dengan `max-h` adalah pola yang baik untuk tabel panjang tanpa scroll halaman.

---

## 3. Analisis per Area

### 3.1 Hero Panel

**Yang sudah baik:**
- Headline dinamis berbeda per role (`updateProposalHero` di JS):
  - **Approver:** "N proposal menunggu persetujuan Anda" + chip "Lihat antrian saya".
  - **User:** "N proposal perlu revisi dari Anda" + chip "Lihat perlu revisi".
  - **Super Admin:** gabungan "N overdue, N wajib LPJ" dengan dua chip.
  - **Admin:** "N proposal overdue di chain Anda".
- Badge chip `applyHeroFilterShortcut()` membuat perpindahan dari insight → filter cukup satu klik.
- ARIA: `aria-live="polite"` di headline untuk screen reader.

**Risiko / gap kecil:**
- Headline dan badges di-*hide* via `.hidden` Tailwind, tapi di-passing kelas `hidden` dan di-toggle dengan `classList.add/remove('hidden')`. Aman, tapi inkonsisten dengan dokumentasi di styles.css (`.hidden { display:none !important }`). Tidak ada masalah, hanya catatan.
- Tidak ada skeleton/placeholder saat data hero pertama kali dimuat. Counter di stats card tampak `-` sampai data datang. Hal yang sama untuk badge chip — tampil tiba-tiba saat data tiba.

### 3.2 Stats Cards

**Yang sudah baik:**
- Klik untuk filter, dengan toggle: klik 2x pada kartu aktif → reset ke "Semua" (`handleStatCardClick`).
- Active state: `ring-2 ring-primary/40` + shadow.
- Border-left berwarna sesuai metrik (biru/kuning/hijau/merah) + blob dekoratif dengan hover scale.
- Sembunyi & diganti note amber saat tab aktif = `wajib_lpj`.

**Risiko / gap:**
- Label dinamis "Total" → "Total LPJ" sesuai tab. Bagus. Tapi angka menunggu/disetujui/revisi tidak berubah label-nya, padahal di tab LPJ itu bisa membingungkan (mis. "Disetujui" pada tab LPJ artinya LPJ disetujui, beda konteks dengan Proposal).
- Tidak ada delta/indikator perubahan dibanding periode sebelumnya (low priority, nice-to-have).

### 3.3 Tabs (Proposal / LPJ / Wajib LPJ)

**Yang sudah baik:**
- Counter otomatis per tab dari `proposalMeta.tab_counts` (server-side, lebih akurat).
- Sinkron dengan URL via `syncUrlFromFilters` (replaceState) — bisa di-share & di-bookmark.
- Saat masuk tab Wajib LPJ, filter & keuangan otomatis disembunyikan (`updateFilterVisibility`).

**Risiko / gap:**
- Tab Wajib LPJ untuk User = reminder "Wajib upload LPJ". Untuk role lain, masih tetap sebagai monitoring. Belum ada visual cue yang konsisten membedakan "tab ini adalah list LPJ" vs "tab ini adalah list proposal yang menunggu LPJ".
- Tab切换 + filter — urutan tab & sub-filter bisa terasa ramai. Belum ada sticky tabs saat scroll panjang (low priority).

### 3.4 Pencarian

**Yang sudah baik:**
- Debounce 300ms (`searchDebounceTimer`) dengan loading indicator.
- Pencarian multi-field: `nama_kegiatan`, `pengaju`, `status`, `jenis`.
- Active filter chip "Pencarian: ..." bisa di-close individual.
- Ikon search di kiri input — standar.

**Risiko / gap:**
- Tidak ada "clear search" tombol (X) di input. Saat user ingin reset cepat, harus klik filter chip "Pencarian" di bar. Untuk UX mobile akan lebih cepat dengan X di kanan input.
- Tidak ada highlight match di hasil tabel (nice-to-have, kompleks).

### 3.5 Preset Filter (Super Admin)

**Yang sudah baik:**
- 4 preset ringkas: Antrian Keuangan, Wajib LPJ, Overdue, Menunggu ACC.
- Highlight preset aktif via `updateActivePresetHighlight` — visual cue kuat.
- Kombinasi filter yang saved (mis. tab + status + keuangan) di-resolve menjadi preset tunggal saat kondisi cocok (`isPresetActive`).

**Risiko / gap:**
- Hanya Super Admin yang melihat bar preset. Admin melihat filter yang sama tapi manual. Mungkin perlu minimal 1 preset untuk Admin (mis. "Overdue di chain Anda" yang sudah dipakai di hero).
- Posisi preset ada di atas Filter Lanjutan. Mungkin lebih baik di dalam panel "Filter lanjutan" agar konsisten, atau dipertahankan dengan label jelas (sudah ada label "Preset" uppercase). Saat ini sudah cukup jelas.

### 3.6 Filter Lanjutan (Status / Keuangan / Prioritas / Overdue)

**Yang sudah baik:**
- Collapsible dengan `localStorage` persistence (`ADVANCED_FILTERS_KEY`) — nice touch.
- Default open untuk Admin/Super Admin (`$advancedFiltersExpanded = $isAdminRole`).
- "Active filters bar" dengan chip yang bisa di-hapus individual.
- Reset semua filter di kanan.
- Filter Keuangan disembunyikan untuk role non-admin & di tab Wajib LPJ.

**Risiko / gap:**
- Definisi "Prioritas Saya" berbeda per role (`matchesPriorityFilter`):
  - Approver → hanya yg sedang di-gilir.
  - User → milik sendiri & menunggu/revisi.
  - Lainnya → semua menunggu/revisi.
  Logikanya benar, tapi label "Prioritas Saya" bisa misleading untuk role Admin/Super Admin (yang artinya "menunggu/revisi" global). Mungkin perlu label "Butuh Tindakan" atau icon berbeda.
- Ada 3 kondisi yang masing-masing punya chip berbeda tapi bisa tumpang tindih: Prioritas Saya, Milik Saya (`currentMineOnly` — tapi UI tidak expose secara langsung?), Baru Disubmit (`currentRecentOnly` — juga tidak expose?), Perlu Persetujuan Saya (`currentApproveOnly` — juga tidak expose?). Backend sudah support semuanya, tapi di UI hanya Prioritas & Overdue yang punya tombol. Mungkin ada rencana untuk expose yang lain via hero badge, yang sudah dilakukan sebagian.

### 3.7 Tabel / Card List

**Header tabel:**
- 9 kolom: No, Kegiatan, Pengaju, Tanggal, Tgl Pelaksanaan, Anggaran, Durasi, Status, Aksi.
- Sortable: Tanggal, Anggaran, Durasi (klik header → toggle asc/desc).
- Sort icon konsisten, default DESC by tanggal.

**Cell highlights:**
- **Status:** stacked badges (status utama + keuangan + overdue + age indicator dengan bell reminder). Compact di tabel (`min-w-0 max-w-[180px]`).
- **Durasi:** 3-baris mini info: total hari + status "berjalan/selesai" + nama tahap. Tooltip dengan breakdown per-stage (`info.tooltip`).
- **Overdue:** baris `border-l-4 border-red-500 bg-red-50/40`; card `is-overdue` dengan border-left merah.

**Risiko / gap:**
- Kolom "Durasi" di mobile card hilang (tidak dirender). Durasi adalah informasi berharga — bisa ditambahkan sebagai baris tambahan di card mobile.
- Kolom "Pengaju" `truncate max-w-[120px]` — nama bisa terpotong. Tidak ada tooltip. Tambahkan `title` attribute.
- "No" monoton naik per halaman, bukan global — standar pagination, fine.
- Header tabel tidak sticky-tinggi (sticky-top sudah benar) — verified.

### 3.8 Empty State

**Yang sudah baik:**
- 3 konteks copy berbeda (Proposal / LPJ / Wajib LPJ).
- CTA adaptif: Tambah / Reset filter / Kembali ke Proposal.
- Role-aware: User vs Read-Only vs Approver.
- Icon berbeda per konteks (inbox / file-invoice / check-circle / filter).

**Risiko / gap:**
- Ada dua empty state:
  1. Full-page empty (`#emptyState`) saat `allProposals.length === 0`.
  2. In-grid empty (`#proposalGrid` filterEmptyHtml) saat `hasActiveFiltersFlag`.
  Keduanya informatif, tapi copy-nya berbeda. Filter-empty menyebut "Ada X data di tab ini, tetapi tidak cocok dengan filter aktif" — bagus, eksplisit. Full-page tidak menyebut tab total. Sedikit inkonsisten.
- Empty state untuk Wajib LPJ User yang belum upload LPJ: copy "Semua LPJ Sudah Diajukan" + tombol "Kembali ke Proposal". Untuk User yang punya wajib LPJ, tab ini berisi list proposal yang perlu LPJ — mungkin perlu konfirmasi "0 wajib LPJ" dengan copy yang lebih netral: "Tidak ada proposal yang menunggu LPJ saat ini" (sudah seperti itu, OK).

### 3.9 Pagination

**Yang sudah baik:**
- Server-side (`total_pages` dari API meta), 15 per page.
- Ellipsis saat `totalPages > 7` (`if (totalPages > 7 && Math.abs(i - currentPage) > 2 ...)`).
- Pagination info `1-15 dari 42 (filter: Menunggu)` — sesuai rekomendasi Phase 2.5 checklist.
- Disabled state untuk prev/next di halaman 1 / terakhir.

**Risiko / gap:**
- Tidak ada "go to page" input langsung (jump to page) — fine untuk 15 per page.
- Tidak ada pilihan per-page (15/30/50). Bisa ditambahkan tapi low priority.
- Pagination info di kanan (`ml-auto`) pada row yang sama dengan controls — fine untuk desktop, agak sempit di mobile.

### 3.10 Action Bar (per Row)

**Yang sudah baik:**
- Maks 3 primary action + 1 ellipsis dropdown.
- Catalog-based ordering: status / detail / revise / lpjUpload / lembar / lembarLpj / ai.
- Order berbeda per role:
  - Approver: status → detail → lpjUpload → revise → lembar → lembarLpj → ai
  - User: revise → lpjUpload → detail → lembar → lembarLpj → status → ai
  - Admin/SA (dengan AI): ai → detail → status → lpjUpload → revise → lembar → lembarLpj
- AI button sudah prominent: `bg-green-600` dengan label "AI" (sesuai rekomendasi 2.4).

**Risiko / gap:**
- Dropdown ditutup dengan global click handler yang cek `e.target.closest('[id^="dropdown-"]')` — robust. Tapi tidak ada ESC keyboard handler.
- Dropdown auto-position via `positionActionDropdown` cek overflow bottom → flip ke atas. Bagus.
- Tombol di primary row terlalu kecil untuk sentuhan (touch target < 40px). Di mobile, primary actions di card masih di flex-wrap. Touch target 32×32 (`h-8 w-8`) terlalu kecil untuk WCAG 2.5.5 (min 44×44 ideal). **Ini accessibility issue prioritas MEDIUM.**

### 3.11 Modal Create (Tambah Proposal / LPJ)

**Yang sudah baik:**
- 4 step pill: Identitas → Keuangan → Dokumen (header visual saja, single-page form).
- Field parent_proposal_id auto-muncul saat Jenis = LPJ (`toggleLpjParentField`).
- LPJ parent options di-resolve dari `lpjParentOptions` (server) atau fallback dari `getWajibLpjItems()`.
- Lockable select via `setSelectLocked` + `enforceLockedSelectValue` saat dipanggil dari Wajib LPJ (forced parent).
- Validasi:
  - Nama kegiatan, jenis, ketua, file → wajib.
  - LPJ → parent_proposal_id wajib.
  - Anggaran non-negatif.
  - Tanggal pelaksanaan tidak boleh mundur (untuk Proposal; LPJ bebas).
- Inline error dengan red border + pesan `<p class="text-xs text-red-600">` (sesuai rekomendasi 2.7).
- File wajib PDF (`isPdfFile` di handler revisi, juga dicek di handler proposal).

**Risiko / gap:**
- Step pill non-interaktif. User tidak bisa klik "lompat ke step 2" untuk review Keuangan. Mungkin acceptable, tapi bisa ditambah anchor scroll.
- Field bank/rek tidak wajib, tapi sebenarnya penting untuk pencairan. Untuk User yang awam, field ini bisa terlewat dan diisi belakangan. Mungkin perlu banner: "Lengkapi data bank sebelum status Disetujui & cair".
- Tidak ada preview nama file sebelum upload (di luar scope, low priority).
- Tidak ada confirm modal "Yakin submit?" — bisa langsung submit. Untuk file besar, mungkin perlu warning.

### 3.12 Modal Detail (Tabbed)

**Yang sudah baik:**
- 2 tab: Detail & Riwayat/Revisi. Pisah concerns.
- Detail: data master + preview PDF (iframe 400px) + LPJ dengan preview file sumber & LPJ.
- Riwayat: 2 bagian — Riwayat Revisi per approver (grouped by username) + Riwayat Approval timeline.
- Riwayat Revisi:
  - Grouped by approver → cycleNo → request + uploads (sorted by versionNo).
  - "Versi N" badge + link ke PDF per upload.
- Timeline: rail dengan icon per status (submit, setujui, revisi, tolak, undo), entry "Terakhir" disorot, snapshot info di undo entries.

**Risiko / gap:**
- Iframe PDF 400px — agak pendek. Untuk membaca proposal multi-halaman, user harus scroll dalam iframe. Lebih baik tombol "Buka di tab baru" yang lebih prominent (sudah ada, secondary).
- Tidak ada print/download dari modal (window.print() of iframe content). Low priority.
- Riwayat approval tidak punya pagination saat history panjang. Untuk proposal dengan revisi banyak, bisa panjang. Low priority.
- Timeline tidak bisa dilipat per tahun/bulan (low priority).

### 3.13 Modal Update Status

**Yang sudah baik:**
- Context bar atas: nama kegiatan, jenis+pengaju+status, current approver.
- Validasi giliran approver (`updateStatusProposalModalContext`):
  - Approver yang bukan current → "Disetujui" di-disable + hint + banner.
- Catatan wajib ≥ 3 karakter untuk Revisi/Tolak (sesuai rekomendasi).

**Risiko / gap:**
- Tidak ada preview note history approver sebelumnya (di timeline bisa, tapi di sini tidak). User approver mungkin perlu melihat "komentar sebelumnya" sebelum memberi status. Nice-to-have.
- Tidak ada emoji/styling untuk membedakan tone Revisi vs Tolak. Hanya icon + warna background select.

### 3.14 Modal Upload Revisi

**Yang sudah baik:**
- Validasi file PDF only.
- Catatan opsional max 500 karakter.
- Tombol disabled state dengan spinner.

**Risiko / gap:**
- Tidak menampilkan revisi sebelumnya (di modal detail sudah ada Riwayat, tapi di sini tidak). User pengaju yang revisi akan lebih percaya diri jika lihat versi sebelumnya + alasannya.

### 3.15 Modal Edit Anggaran / Status Keuangan / Tanggal

**Yang sudah baik:**
- Tersegmentasi: hanya role yang berhak yang bisa membuka (guard di `canEdit*`).
- Field `id` hidden untuk submit.
- Catatan opsional untuk audit trail.

**Risiko / gap:**
- Tidak ada diff preview: user tidak melihat nilai lama vs baru sebelum save. Untuk perubahan kritis (anggaran, status keuangan), ini akan sangat membantu. Bisa tambahkan baris "Saat ini: Rp X" di atas field input.
- Tidak ada konfirmasi setelah save (cuma toast, fine).

### 3.16 Modal Undo Approval (Super Admin)

**Yang sudah baik:**
- Preview fetched via `getUndoPreview` API — menampilkan aksi yang akan di-undo dan state yang akan di-restore.
- Alasan wajib.
- Guard: hanya keputusan terakhir setelah deploy & bukan SYSTEM yang bisa di-undo.

**Risiko / gap:**
- Tidak ada visual diff "sebelum → sesudah" (mis. dengan strikethrough). Preview hanya teks.
- Tidak ada undo chain: undo hanya satu langkah. Untuk kompleksitas, mungkin fine — Super Admin harus pelan-pelan.

### 3.17 Modal AI Analysis

**Yang sudah baik:**
- 3-stage progress: Ekstrak → Prompt → AI Call.
- Cache badge: hasil di-cache, tidak re-call.
- Tombol "Lanjutkan" (continue) untuk hasil yang terpotong.
- sessionStorage persistence: `ai_messages_<id>` + `ai_continue_count_<id>`.
- Sanitasi: `formatAnalysis` melakukan escape + markdown-to-HTML + DOM walk whitelist tags (`STRONG, EM, UL, OL, LI, H1-3, P, BR, BLOCKQUOTE`).

**Risiko / gap — Security:**
- `formatAnalysis` menggunakan `escapeText` (custom) → `innerHTML` assignment di dalam parsing. Setelah markdown, ada DOM walk yang whitelist tag. Ini cukup aman, **tapi** ada satu celah potensial: `escapeText` melakukan replace sebelum markdown parsing. Karena markdown parser tidak menghasilkan tag di luar whitelist (hanya `<strong>`, `<em>`, `<ul>`, `<li>`, `<h1-3>`, `<p>`, `<br>`), dan DOM walk menghapus sisanya, **resiko XSS rendah** — namun bergantung pada kebenaran regex markdown. Untuk input yang sangat panjang atau khusus-crafted, lebih aman render ke text node + render markdown via library (marked.js + DOMPurify). Low priority hardening.

**Risiko / gap — UX:**
- Tidak ada cara copy hasil analisis (tidak ada tombol "Salin").
- Tidak ada cara download hasil ke .md.
- Stage progress (3 step) tidak ada estimasi waktu; hanya animasi `fa-spin`. Untuk user yang belum pernah pakai, bisa terasa "macet".

---

## 4. Status Implementasi vs. `docs/proposal-uiux-checklist.md` (2026-05-31)

| Item | Status | Catatan |
|---|---|---|
| 1.1 Action ellipsis (max 3 + dropdown) | ✅ **Implemented** | `buildProposalRowActions` catalog + dropdown. |
| 1.2 Disable subfilters on Wajib LPJ | ✅ **Implemented** | `updateFilterVisibility`. |
| 1.3 Status single-line + tooltip | ⚠️ **Parsial** | Ada `title` attribute di status text, tapi cell `min-w-0 max-w-[180px]` masih bisa wrap di mobile. Badge keuangan dipisah via `flex-col gap-1` (rendered). |
| 1.4 Empty state copy adaptif | ✅ **Implemented** | `updateEmptyStateCopy` 3 konteks + role. |
| 1.5 Detail modal tabs | ✅ **Implemented** | Tab "Detail" & "Riwayat / Revisi". |
| 2.1 Search debounce 300ms | ✅ **Implemented** | `searchDebounceTimer` + `showLoadingInTable`. |
| 2.2 Stats card click to filter | ✅ **Implemented** | `handleStatCardClick` + ring highlight. |
| 2.3 Client-side sort | ✅ **Implemented (server-side)** | Sort dikirim via query param `sort` & `dir`. |
| 2.4 AI button prominent | ✅ **Implemented** | `bg-green-600` + label "AI". |
| 2.5 Pagination info with active filter | ✅ **Implemented** | `buildActiveFilterLabel`. |
| 2.6 Delete confirmation | ✅ **Implemented** | `confirmActionModal` reusable. |
| 2.7 Inline validation | ✅ **Implemented** | `setFieldError` + clear on input. |
| 2.8 Badge approver mobile stack | ⚠️ **Parsial** | `flex-col gap-1` di sel. Belum ada media query variant. |
| 3.1 PDF loading toast | ✅ **Implemented** | `showToast('Membuat lembar pengesahan...', 'info')`. |
| 3.2 XSS sanitasi | ✅ **Implemented** | DOM walk whitelist di `formatAnalysis`. |
| 3.3 Modal field order | ❓ **Belum jelas** | Order sudah: identitas → PJ → keuangan → dokumen. Sudah logis. |

**Kesimpulan:** ~95% rekomendasi Phase 1–3 sudah terimplementasi oleh Fase 1–4. Item 1.3 dan 2.8 masih parsial.

---

## 5. Risiko & Rekomendasi

### 5.1 Risiko Tinggi

| # | Risiko | Lokasi | Dampak | Rekomendasi |
|---|---|---|---|---|
| R1 | Touch target tombol aksi < 40px di mobile | `buildProposalRowActions` — `w-8 h-8` | Aksesibilitas (WCAG 2.5.5) | Naikkan ke `w-10 h-10` di mobile (override via media query) atau perbesar area sentuh dengan padding internal. |
| R2 | Kolom Durasi tidak muncul di mobile card | `renderProposals` mobile branch | User kehilangan informasi waktu approval | Tambahkan baris durasi di mobile card (compact: "⏱ 5 hari · berjalan"). |

### 5.2 Risiko Sedang

| # | Risiko | Lokasi | Dampak | Rekomendasi |
|---|---|---|---|---|
| R3 | Tidak ada "clear search" (X) di input | `#searchProposal` | UX minor | Tambahkan tombol clear (Font Awesome `fa-times-circle`) di kanan input saat `value !== ''`. |
| R4 | Modal edit (anggaran, keuangan, tanggal) tidak menampilkan nilai lama | Modal edit | User bisa salah input | Tambahkan "Saat ini: Rp X" atau `readonly` preview. |
| R5 | Mobile card status bisa overflow horizontal | `renderProposalStatusBadges` | Teks kepotong | Tambahkan `flex-wrap` di parent + max-width per badge. |
| R6 | Tombol "ACC" di primary action terlalu generic | `buildProposalRowActions` btnStatus | Tidak jelas ACC = approve | Ganti label jadi "Setujui" dengan icon cek. |
| R7 | Filter "Prioritas Saya" misleading untuk Admin/SA | `matchesPriorityFilter` | Ekspektasi user | Ubah label kondisional per role atau ganti jadi "Butuh Tindakan". |

### 5.3 Risiko Rendah / Polish

| # | Risiko | Lokasi | Dampak | Rekomendasi |
|---|---|---|---|---|
| R8 | Dropdown tidak close dengan ESC | `toggleActionDropdown` | Keyboard UX | Tambah keydown listener. |
| R9 | Tidak ada skeleton loader untuk stats & hero | `updateStatsCards`, `updateProposalHero` | Flash of `-` | Tampilkan placeholder spinner inline. |
| R10 | Tidak ada print/download dari modal detail | Modal detail | Minor | Tambah tombol print modal. |
| R11 | AI Analysis tidak punya copy/download | Modal AI | Minor | Tambah tombol "Salin" di header. |
| R12 | PDF iframe height 400px pendek | Modal detail preview | Scroll iframe panjang | Naikkan ke 60vh atau sticky bottom toolbar. |
| R13 | Step pill di modal Create non-interaktif | Modal Create | User tidak bisa jump | (Opsional) Jadikan anchor scroll. |
| R14 | Tidak ada "empty filter state" global berbeda dari full empty | Empty state | Sedikit bingung | Samakan tone: keduanya sebut "tab ini punya X data, Y cocok". |

### 5.4 Risiko Keamanan

| # | Risiko | Lokasi | Dampak | Rekomendasi |
|---|---|---|---|---|
| S1 | `formatAnalysis` — sanitasi regex-based | `formatAnalysis` | XSS low-probability | Pertimbangkan marked.js + DOMPurify (CDN) untuk markdown AI. |
| S2 | `escapeJsString` dipakai untuk nama di inline onclick | `buildProposalRowActions` | Injection via nama | Function sudah escape `\`, `'`, `\n`, `<`. Cukup aman, tapi untuk pengaman ekstra bisa ubah ke `data-id` + delegated handler. |

---

## 6. Highlight Positif

1. **Arsitektur state-driven** dengan URL sync (`syncUrlFromFilters`) — shareable & bookmarkable state.
2. **Server-side pagination + filter** (Fase 4) — skalabel untuk ribuan proposal.
3. **Hero adaptif per role** dengan one-click filter — onboarding cepat untuk tiap peran.
4. **Catalog-based action ordering** — clean extensibility untuk tambah tombol baru.
5. **Per-tab empty state & tab counters** — clarity untuk konteks berbeda.
6. **Sanitasi output berlapis** — escape → markdown → DOM walk.
7. **Modal reusable** (`confirmActionModal`) — DRY.
8. **Mobile card fallback** — viewport-aware rendering.
9. **`localStorage` persistence** untuk filter panel state — continuity antar reload.
10. **PDF preview inline** + link "Buka di tab baru" — comfort.

---

## 7. Peta Ringkas Komponen vs. File

```
pages/proposal.php                 # 661 baris — markup + style + modal
├── Hero (#proposalHero*)         # Headline dinamis, badge, CTA
├── Stats (#proposalStats*)        # 4 kartu + Wajib LPJ note
├── Tabs (3 tab chips)              # Proposal / LPJ / Wajib LPJ
├── Search (#searchProposal)
├── Preset (Super Admin only)      # 4 preset filter
├── Advanced filter panel          # Status, keuangan, priority, overdue
├── Active filters bar             # Chips + reset
├── Table (#proposalTableWrap)     # Desktop view
├── Card list (#proposalCardList)  # Mobile view
├── Pagination (#paginationInfo + #paginationControls)
├── Empty state (#emptyState)
└── Modals (10 modal: Create, AI, Detail, Status, Revise,
              EditBudget, EditFinance, EditTanggal, Undo, Confirm)

public/js/proposal-page.js         # 3485 baris — semua logic
├── State vars                     # 15+ state (currentFilter, currentTab, ...)
├── API helpers                    # fetchProposalById, normalize, ...
├── Render                         # renderProposals, renderDurationCell, ...
├── Filter & search                # filterProposals, searchProposals, ...
├── Modal orchestration            # open*, close*, openFromList, ...
├── Form handlers                  # validate* + submit handlers
├── URL sync                       # applyUrlFilters, syncUrlFromFilters
├── AI flow                        # analyzeProposalFromList, continue*, ...
└── Bootstrap                      # bootProposalPage → initProposalPage

api/proposal.php                   # Read-only context
├── getProposals                   # 1153 — scope + filter + sort + paginate
├── Filters                        # tab, status, fin, search, priority, mine, ...
├── Tab counts / stats / hero      # computeProposalTabCounts, etc.
└── Helpers                        # normalizeApprover, isOverdue, isWajibLPJ
```

---

## 8. Rekomendasi Urutan Implementasi Lanjutan

| Urutan | Item | Alasan |
|---|---|---|
| 1 | R1, R2 (touch target + durasi mobile) | Aksesibilitas & info integrity. |
| 2 | R6 (label "Setujui" / "ACC" jelas) | Clarity cepat. |
| 3 | R4 (preview nilai lama di modal edit) | Kurangi error input. |
| 4 | R3 (clear search button) | UX kecil, dampak besar. |
| 5 | R7 (label "Prioritas Saya" adaptif) | Clarity per role. |
| 6 | R8 (ESC close dropdown) | Keyboard UX. |
| 7 | R5, R14 (mobile status wrap, empty state) | Polish. |
| 8 | S1 (marked.js + DOMPurify) | Hardening keamanan AI. |
| 9 | R9–R13 (skeleton, print, copy AI, PDF height, step pill) | Polish tambahan. |

---

## 9. Penutup

Halaman `/proposal` adalah halaman dengan kompleksitas tertinggi di aplikasi (multi-role, multi-status, multi-aksi, multi-modal). Kode sudah terstruktur dengan baik dan ter-*decompose* per concern. Mayoritas rekomendasi UI/UX dari checklist Mei 2026 sudah terimplementasi.

Area fokus selanjutnya adalah:
- **Aksesibilitas mobile** (touch target, durasi di card, overflow wrap).
- **Clarity label tombol** (ACC → Setujui, Prioritas Saya → adaptif).
- **Sanitasi AI output** untuk hardening jangka panjang.
- **Kecil tapi penting** (clear search X, diff preview di modal edit, ESC handler).

Tidak ada blocker UX yang kritikal. Iterasi kecil yang disebutkan di atas akan mengangkat kualitas dari "sangat baik" menjadi "production-grade enterprise".
