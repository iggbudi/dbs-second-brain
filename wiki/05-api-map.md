# API Map - LK UKMs

API menggunakan parameter `action` dan mayoritas merespons JSON via `jsonResponse()`.

## `api/auth.php`

POST actions:
- `login` → login user, verify password, upgrade legacy password bila perlu, generate CSRF.
- `logout` → destroy session.
- `checkSession` → cek status login.
- `getCsrfToken` → return CSRF token.

## `api/users.php`

GET actions:
- `getUsers`
- `getUser`
- `getActivityLogs` → log aktivitas untuk `Admin`/`Super Admin`. Response tetap menyertakan `aktivitas` legacy dan menambahkan field turunan non-breaking dari payload JSON terstruktur bila ada: `event`, `request_id`, `category`, `level`, `detail`/`context`, dan `is_structured`. Endpoint masih mengirim 100 log terbaru; pagination/filter/search dilakukan client-side di `pages/activity_logs.php` dengan default 10 baris per halaman dan opsi 10/25/50/100. Data terstruktur masih diparse dari kolom `aktivitas`, bukan kolom fisik baru.
- `getDashboardStats` → role-aware aggregate dashboard stats untuk `/dashboard`; response berisi `stats.role`, `stats.scopeLabel`, `stats.totals`, `stats.actions`, `stats.announcements`, `stats.recentActivity`, dan `stats.trends`.
  - `stats.trends` hanya untuk `Admin`/`Super Admin` (direction/delta/percent per card); `null` untuk non-admin.
  - `stats.activeToday` dan `stats.totals.activeToday`: jumlah user distinct dengan aktivitas `Login Sukses` di `activity_logs` pada tanggal hari ini (root dan per-role sama). Digunakan oleh card "Aktif hari ini" di `/users`.
- `getActiveUserTrend` → trendline user aktif harian. Parameter `range` (7|14|30). Role: `Admin`/`Super Admin`. Data source: `activity_logs`, distinct `username` dengan `aktivitas='Login Sukses'` per tanggal. Response: array `{tanggal, activeUsers}` dan summary `avg`/`max`/`min`; tanggal tanpa login diisi 0.
- `getSystemSettings`

POST actions:
- `addUser`
- `deleteUser`
- `resetUserPassword`
- `updateUser`
- `updateProfile`
- `changePassword`
- `sendLoginInfoWA`
- `saveSystemSettings`

Catatan security: user management dan system settings harus role-restricted.

Catatan dashboard:
- `getDashboardStats` wajib login.
- Statistik proposal untuk `User` dibatasi ke `pengaju = username`.
- Statistik proposal untuk `Approver` difilter dengan `normalizeApprover(current_approver) == normalizeApprover(username)`.
- Activity logs di response dashboard hanya untuk `Admin`/`Super Admin`.
- List pengumuman dibatasi 5 item dan activity dibatasi 10 item.

## `api/proposal.php`

GET actions:
- `getProposals`
- `getArchivePengaju`
- `getArchiveByPengaju`
- `getApprovalChain`
- `generateLembarPengesahan` → stream PDF proposal.
- `generateLembarPengesahanLPJ` → stream PDF LPJ.

POST actions:
- `addProposal`
- `updateStatusProposal`
- `reviseProposal`
- `sendReminder`
- `editProposalByAdmin`
- `updateProposalFinancialStatus`
- `deleteProposal`
- `extractTextProposal`
- `analyzeProposal`
- `continueAnalysisProposal`

Catatan:
- Proposal dan LPJ memakai tabel `proposal`.
- LPJ wajib `jenis = LPJ`.
- Approval comparison wajib pakai `normalizeApprover()`.
- Endpoint JSON utama untuk halaman `/proposal` (`getProposals`, `getProposal`, `getApprovalChain`) memakai wrapper konsisten `{success, message, data}` dan tetap mempertahankan key legacy seperti `proposals`, `meta`, `proposal`, dan `chain` untuk kompatibilitas frontend lama.
- Endpoint JSON proposal memakai JSON-safe error handler dengan `request_id`; unhandled error/fatal error dikembalikan sebagai JSON generic dan dicatat via structured event log.
- `addProposal`/submit Proposal-LPJ mencatat validation/file/db/success events, termasuk indikasi request size/empty POST untuk upload bermasalah.
- PDF success stream langsung, bukan JSON; perlakukan PDF/binary sebagai pengecualian dari JSON response success.

## `api/surat.php`

GET actions:
- `getSuratMasuk`
- `getSuratKeluar`
- `getMonitoringSurat`
- `getDisposisiBySurat`
- `getDisposisiList`
- `generatePengesahanSurat` → stream/generate PDF pengesahan surat.

POST actions:
- `addSuratMasuk`
- `addSuratKeluar`
- `reviseSuratKeluar`
- `updateStatusSurat`
- `addDisposisiSurat`
- `updateDisposisiStatus`
- `deleteSuratMasuk`
- `deleteSuratKeluar`

Catatan:
- Surat masuk/keluar berbagi page `pages/surat_masuk.php` dan API `api/surat.php`.
- Surat keluar punya idempotency logic untuk mencegah duplicate submit.

## `api/alur.php`

GET actions:
- `getAlur`
- `getApproverUsers`
- `getUKMUsers`

POST actions:
- `addAlur`
- `updateAlur`
- `deleteAlur`

Catatan: alur menentukan `acc1` sampai `acc6` per `pengaju`.

## `api/kipk.php`

GET actions:
- `getLaporanKIPK`

POST actions:
- `addLaporanKIPK`
- `updateStatusKIPK`
- `deleteLaporanKIPK`

## `api/pengumuman.php`

GET actions:
- `getAnnouncements`

POST actions:
- `addAnnouncement`
- `deleteAnnouncement`

## `api/arsip.php`

GET actions:
- `getArsipData`
- `getAnnouncements` (legacy/duplicated with pengumuman)

POST actions:
- `addArsipData`
- `deleteArsip`
- `analyzeArsip`
- `continueAnalysisArsip`
- `extractTextArsip`
- `addAnnouncement`
- `deleteAnnouncement`

Catatan: arsip memiliki integrasi AI (`content_text`, `ai_analysis`, `ai_usage`).

## `api/penggunaan_ruangan.php`

GET actions:
- `getPenggunaanRuangan`

POST actions:
- `addPenggunaanRuangan`
- `updatePenggunaanRuangan`

## `api/wa_send.php`

Ada di codebase tapi tidak terdaftar di `index.php`. Treat as direct/standalone endpoint bila masih digunakan.
