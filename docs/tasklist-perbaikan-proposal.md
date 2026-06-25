# Tasklist Rencana Perbaikan UI/UX Halaman `/proposal`

**Berdasarkan:** `analisiscmd.md` (analisis 2026-06-15)
**Lokasi target:** `pages/proposal.php` + `public/js/proposal-page.js`
**Prinsip:** Native PHP + Tailwind CSS + Font Awesome; no new framework; minimal API change.

---

## Legend

- **Status:** ⬜ Not started / 🟡 In progress / ✅ Done
- **Priority:** HIGH / MEDIUM / LOW
- **Estimasi:** ringkas (S=1 sesi, M=2–3 sesi, L=4+ sesi)
- **AC:** Acceptance Criteria

---

## Fase 1 — Aksesibilitas & Mobile (HIGH)

| # | Task | Target | AC | File | Est. | Status |
|---|---|---|---|---|---|---|
| 1.1 | **Perbesar touch target tombol aksi di mobile** | Di mobile card view (`< 768px`), action buttons di perlu 44×44 px (WCAG 2.5.5). | Semua `.action-btn` / `.action-dropdown-btn` di proposal card memiliki `min-width: 44px; min-height: 44px` pada layar `< 768px`. Icon tetap terlihat rapi, tidak overlap. | `pages/proposal.php` (CSS), `public/js/proposal-page.js` (render mobile card) | S | ⬜ |
| 1.2 | **Tambahkan informasi Durasi di mobile card** | Kolom Durasi saat ini hanya muncul di desktop table. | Setiap proposal card di mobile menampilkan 1 baris kompak: `⏱ 5 hari · berjalan` (atau selesai/overdue). Warna teks merah jika overdue. | `public/js/proposal-page.js` (render mobile card) | S | ⬜ |
| 1.3 | **Perbaiki overflow status badges di mobile card** | Status + keuangan + overdue badge kadang tumpang tindih di layar sempit. | Badges di mobile card berada dalam container `flex flex-wrap gap-1` dengan `max-width: 100%`. Tidak ada horizontal overflow. | `public/js/proposal-page.js` (`renderProposalStatusBadges` atau mobile card branch) | S | ⬜ |
| 1.4 | **Tambahkan tooltip/title di kolom Pengaju** | Nama pengaju di desktop `truncate max-w-[120px]` tanpa tooltip. | Semua cell Pengaju memiliki `title="${escapeText(p.pengaju)}"`. | `public/js/proposal-page.js` (render desktop table) | XS | ⬜ |
| 1.5 | **Tutup action dropdown dengan tombol ESC** | Saat ini dropdown ditutup hanya via klik luar. | Tekan ESC menutup dropdown yang sedang terbuka. Listener global di-DOMContentLoaded. | `public/js/proposal-page.js` | XS | ⬜ |

---

## Fase 2 — Clarity & Microcopy (MEDIUM)

| # | Task | Target | AC | File | Est. | Status |
|---|---|---|---|---|---|---|
| 2.1 | **Ubah label tombol "ACC" jadi "Setujui"** | Label "ACC" kurang jelas untuk user awam. | Di primary action bar, tombol approve/acc memiliki label "Setujui" + icon `fa-check`. Tooltip tetap "Setujui Proposal". | `public/js/proposal-page.js` (`buildProposalRowActions` catalog label) | XS | ⬜ |
| 2.2 | **Tambahkan preview nilai lama di modal edit** | Modal edit anggaran, status keuangan, dan tanggal tidak menampilkan nilai existing sebelum diubah. | Di atas input field, tampilkan baris readonly: `Saat ini: Rp 5.000.000` / `Saat ini: Menunggu` / `Saat ini: 2026-06-10`. | `pages/proposal.php` (markup modal), `public/js/proposal-page.js` (open modal handlers) | S | ⬜ |
| 2.3 | **Tambahkan tombol clear (X) di search input** | Reset pencarian saat ini membutuhkan klik filter chip. | Input `#searchProposal` menampilkan icon `fa-times-circle` di kanan saat `value !== ''`. Klik icon mengosongkan input, mereset search, dan memanggil `loadProposals()`. | `pages/proposal.php` (markup search), `public/js/proposal-page.js` | XS | ⬜ |
| 2.4 | **Ubah label "Prioritas Saya" menjadi kontekstual per role** | Label "Prioritas Saya" menyesatkan untuk Admin/Super Admin. | Di UI, label chip berubah dinamis: Approver="Antrian Saya", User="Perlu Perhatian", Admin/SA="Butuh Tindakan". Logika filter backend tidak berubah. | `pages/proposal.php` (chip label), `public/js/proposal-page.js` (chip text update) | XS | ⬜ |
| 2.5 | **Perjelas stats card label untuk tab LPJ** | Label "Menunggu / Disetujui / Revisi" di stats card tetap sama padahal konteks LPJ. | Saat tab `lpj` aktif, label card berubah: "Menunggu LPJ / Disetujui LPJ / Revisi LPJ" (bisa dengan subtitle kecil). | `public/js/proposal-page.js` (`updateStatsCards`) | S | ⬜ |
| 2.6 | **Samakan tone empty state untuk filter-empty vs full-empty** | Dua empty state sedikit berbeda tone. | Full-page empty state juga menyebutkan total data tab saat ini (mis. "Tidak ada proposal di tab ini."). Filter-empty tetap menyebutkan jumlah filter yang cocok. | `public/js/proposal-page.js` (`updateEmptyStateCopy`, `renderProposals` filterEmptyHtml) | S | ⬜ |
| 2.7 | **Tambahkan banner pengingat data bank di modal Create** | User sering melewati field bank/rek. | Di modal Create, jika Jenis = Proposal, tampilkan banner kecil `bg-blue-50 text-blue-700` di bawah field bank: "Lengkapi data bank agar pencairan dapat diproses." | `pages/proposal.php` (markup modal Create) | XS | ⬜ |

---

## Fase 3 — Polish & Hardening (LOW)

| # | Task | Target | AC | File | Est. | Status |
|---|---|---|---|---|---|---|
| 3.1 | **Tambahkan skeleton loader untuk stats & hero** | Counter tampil `-` saat data pertama kali dimuat. | Saat `loadProposals()` dipanggil, stats card & hero panel menampilkan shimmer/skeleton placeholder sampai data tiba. | `pages/proposal.php` (markup), `public/js/proposal-page.js` (show/hide skeleton) | M | ⬜ |
| 3.2 | **Tambahkan tombol "Salin" hasil analisis AI** | Hasil AI tidak bisa dicopy. | Header modal AI mendapat tombol `fa-copy` "Salin". Klik menyalin teks hasil analisis ke clipboard dan menampilkan toast "Hasil analisis disalin". | `pages/proposal.php` (modal AI header), `public/js/proposal-page.js` | S | ⬜ |
| 3.3 | **Tambahkan tombol print/download di modal Detail** | User tidak bisa print/download dari modal. | Header modal Detail mendapat tombol `fa-print` "Cetak". Klik memanggil `window.print()` pada iframe PDF atau membuka PDF di tab baru jika print gagal. | `pages/proposal.php` (modal Detail header), `public/js/proposal-page.js` | S | ⬜ |
| 3.4 | **Naikkan tinggi iframe PDF preview** | Iframe 400px terlalu pendek untuk dokumen multi-halaman. | Tinggi iframe preview PDF di modal Detail menjadi `60vh` (min 400px, max 600px). | `pages/proposal.php` (style/inline) | XS | ⬜ |
| 3.5 | **Jadikan step pill di modal Create clickable anchor** | Step pill non-interaktif. | Klik step pill melakukan smooth scroll ke bagian form yang sesuai (Identitas → Keuangan → Dokumen). Tidak mengubah urutan field. | `pages/proposal.php` (markup), `public/js/proposal-page.js` | S | ⬜ |
| 3.6 | **Hardening sanitasi AI output dengan marked.js + DOMPurify** | Sanitasi regex-based masih memiliki celah teoretis. | Gunakan `marked.js` dari CDN untuk parse markdown, lalu `DOMPurify` untuk whitelist tag. Hanya `<strong>, <em>, <ul>, <ol>, <li>, <h1-3>, <p>, <br>, <blockquote>` diizinkan. | `pages/proposal.php` (CDN scripts), `public/js/proposal-page.js` (`formatAnalysis`) | M | ⬜ |
| 3.7 | **Tambahkan durasi estimasi di progress AI** | Progress AI hanya spinner tanpa estimasi. | Di bawah 3 step progress, tampilkan teks kecil: "Analisis biasanya memerlukan 10–30 detik." | `pages/proposal.php` (modal AI markup) | XS | ⬜ |
| 3.8 | **Tambahkan pilihan per-page (15 / 30 / 50)** | Pagination tidak punya opsi jumlah item. | Di bar pagination, tambahkan dropdown `Per halaman: 15 | 30 | 50`. Pilihan disimpan di state dan dikirim ke API via `per_page`. | `pages/proposal.php` (pagination markup), `public/js/proposal-page.js` (state + load) | M | ⬜ |

---

## Fase 4 — Nice-to-Have (Optional / Future)

| # | Task | Target | AC | File | Est. | Status |
|---|---|---|---|---|---|---|
| 4.1 | **Tambahkan highlight pencarian di hasil tabel** | Match keyword di-highlight. | Saat `currentSearchQuery` tidak kosong, tabel/card menandai substring match dengan `mark` berwarna kuning. | `public/js/proposal-page.js` (render functions) | M | ⬜ |
| 4.2 | **Tambahkan preset filter untuk Admin** | Admin hanya punya filter manual. | Admin melihat minimal 1 preset "Overdue di Chain Saya" (atau "Butuh Tindakan"). | `pages/proposal.php` (preset visibility), `public/js/proposal-page.js` | S | ⬜ |
| 4.3 | **Tambahkan visual diff di modal Undo Approval** | Preview undo hanya teks. | Modal Undo menampilkan state sebelum (strikethrough) dan sesudah undo. | `pages/proposal.php` (modal Undo markup), `public/js/proposal-page.js` | M | ⬜ |
| 4.4 | **Tambahkan pagination di Riwayat Approval modal Detail** | Riwayat panjang tidak dipagination. | Riwayat approval dalam tab Riwayat dipaginate client-side 10 per halaman. | `public/js/proposal-page.js` (render timeline) | M | ⬜ |
| 4.5 | **Tambahkan go-to-page input di pagination** | Lompatan halaman cepat. | Pagination menampilkan input kecil "Ke halaman" + tombol "Go". | `pages/proposal.php`, `public/js/proposal-page.js` | S | ⬜ |
| 4.6 | **Tambahkan confirm sebelum submit modal Create** | User bisa submit tanpa konfirmasi. | Sebelum submit proposal/LPJ, tampilkan `confirmActionModal` ringkas: "Ajukan proposal ini? Pastikan data sudah benar." | `public/js/proposal-page.js` (submit handler) | S | ⬜ |
| 4.7 | **Tampilkan preview nama file sebelum upload** | User tidak tahu file sudah dipilih. | Setelah memilih file di modal Create/Upload Revisi, nama file muncul di bawah input. | `pages/proposal.php`, `public/js/proposal-page.js` | S | ⬜ |

---

## Cross-Cutting Checklist (setiap task)

- [ ] Update `analisiscmd.md` jika ada perubahan status item yang sudah diperbaiki.
- [ ] Jangan ubah API endpoint (kecuali `per_page` sudah didukung).
- [ ] Pastikan semua POST API tetap sertakan `csrf_token: window.csrfToken`.
- [ ] Gunakan `sanitize()` / `escapeText()` untuk output dinamis.
- [ ] Jalankan `rtk php -l pages/proposal.php` dan `rtk php -l public/js/proposal-page.js` (syntax check JS bisa via `node --check` jika tersedia).
- [ ] Verifikasi responsive di mobile viewport 375px dan 768px.
- [ ] Catat perubahan di `docs/proposal-uiux-changelog.md` (jika ada).

---

## Urutan Eksekusi Direkomendasikan

1. **Mulai Fase 1** (aksesibilitas & mobile) — dampak langsung ke semua user mobile.
2. **Lanjut Fase 2** (clarity) — cepat, mengurangi kesalahan user.
3. **Fase 3** (polish & hardening) — setelah fondasi aman.
4. **Fase 4** — ambil jika ada bandwidth; otherwise backlog.

---

## Notes

- Semua perubahan harus tetap dalam satu halaman/modal yang ada. Hindari refactor besar.
- Jika task menambahkan CDN (marked.js/DOMPurify), pastikan URL dari CDN resmi (cdnjs / jsDelivr) dan gunakan SRI hash jika memungkinkan.
- Tidak boleh mengubah logika approval chain atau role guard backend; hanya perubahan UI/UX.
