# Page Map - LK UKMs

Pages berada di `pages/*.php`. Umumnya include `templates/header.php`, `templates/sidebar.php`, dan `templates/footer.php`.

## Pages

### `pages/dashboard.php`
Dashboard ringkasan **role-based**. Mengambil data agregat dari:
- `api/users.php?action=getDashboardStats`

Endpoint ini mengembalikan statistik sesuai role, action counts, pengumuman terbatas, activity terbatas untuk Admin/Super Admin, dan trend indicators (Admin/Super Admin only). Dashboard tidak lagi mengambil dataset penuh hanya untuk menghitung angka.

Pola UI terkini:
- Header menampilkan role user.
- Section **Butuh Tindakan** berada di atas sebagai prioritas, auto-refresh setiap 60 detik (paused saat tab hidden).
- Ringkasan statistik berupa card clickable ke halaman terkait dengan query param filter.
- Card keuangan (`Ajuan Masuk`, `Proses Keuangan`, `Dicairkan`) dirender dalam subgroup "Keuangan".
- Trend indicator badge per card (Admin/Super Admin only): panah + warna + persen perubahan dari periode sebelumnya.
- **Semantic icon color gradients** (`actionColorMap`, `statColorMap` hardcoded; yellow menunggu, red revisi/ditolak, green disetujui/dicairkan, blue surat/disposisi/info, maroon neutral/fallback).
- Quick actions berbeda per role (`Super Admin/Admin`, `User`, `Approver`, `Disposisi`, `Read Only`).
- Loading skeleton muncul saat awal load.
- Error card + tombol retry muncul saat fetch gagal.
- Empty state informatif muncul saat tidak ada item.
- Pengumuman dan activity dirender dengan DOM API/`textContent`, bukan interpolasi HTML mentah.
- Activity terkini hanya ditampilkan untuk `Admin`/`Super Admin`; role lain mendapat info state.

### `pages/surat_masuk.php`
Halaman gabungan surat masuk dan surat keluar.

API utama:
- `api/surat.php?action=getSuratMasuk`
- `api/surat.php?action=getSuratKeluar`
- `api/surat.php?action=getMonitoringSurat`
- POST add/update/delete/revisi/disposisi via `api/surat.php`

Catatan: route `surat_keluar` diarahkan ke page ini.

### `pages/disposisi.php`
Daftar dan update disposisi.

API:
- `api/surat.php?action=getDisposisiList`
- POST `updateDisposisiStatus`

### `pages/proposal.php`
Halaman proposal dan LPJ.

Kolom tabel utama: No, Kegiatan, Pengaju, Tanggal, Anggaran, **Durasi**, Status, Aksi.
Kolom **Durasi** menampilkan total hari approval (dari `tanggal_upload` ke final Disetujui, atau ke sekarang jika belum final), plus durasi tahap saat ini. Tidak mengubah database; semua kalkulasi di frontend JS.

API:
- `api/proposal.php?action=getProposals`
- POST add/update/revise/edit financial status/reminder/analyze
- PDF: `generateLembarPengesahan`, `generateLembarPengesahanLPJ`

Fungsi frontend penting:
- `canGenerateLembar(p)`
- `canGenerateLembarLPJ(p)`
- `getProposalDurationInfo(p)` — hitung durasi total & tahap
- `renderDurationCell(p)` — render HTML kolom Durasi

### `pages/arsip_proposal.php`
Arsip proposal khusus Super Admin.

API:
- `api/proposal.php?action=getArchivePengaju`
- `api/proposal.php?action=getArchiveByPengaju`
- POST extract/analyze/continue analysis via `api/proposal.php`

### `pages/arsip.php`
Arsip dokumen/surat.

API:
- `api/arsip.php?action=getArsipData`
- POST add/delete/extract/analyze/continue analysis

### `pages/penggunaan_ruangan.php`
Jadwal penggunaan ruangan.

API:
- `api/penggunaan_ruangan?action=getPenggunaanRuangan`
- POST add/update via `/api/penggunaan_ruangan`

### `pages/kipk` tidak ada sebagai file terpisah
Data KIPK dikelola melalui API `api/kipk.php`; page terkait perlu dicek di UI existing bila ada perubahan.

### `pages/pengumuman.php`
Pengumuman.

API:
- `api/pengumuman.php?action=getAnnouncements`
- POST add/delete.

### `pages/users.php`
Manajemen user.

API:
- `api/users.php?action=getUsers`
- `api/users.php?action=getDashboardStats`
- `api/users.php?action=getActiveUserTrend&range=7|14|30` → line chart trendline user aktif harian (Admin/Super Admin). Tombol 7H/14H/30H切换 rentang. Chart library: Chart.js.
- POST add/update/delete/reset/send WA.

### `pages/profil.php`
Profile user.

API:
- POST `updateProfile`
- POST `changePassword`

### `pages/alur.php`
Manajemen approval chain.

API:
- `api/alur.php?action=getApproverUsers`
- `api/alur.php?action=getUKMUsers`
- `api/alur.php?action=getAlur`
- POST add/update/delete alur.

### `pages/system_settings.php`
Pengaturan sistem.

API:
- `api/users.php?action=getSystemSettings`
- POST `saveSystemSettings`.

### `pages/activity_logs.php`
Log aktivitas untuk observability minimal. Halaman dibatasi untuk `Admin`/`Super Admin`, menyediakan search/filter user/action/`category`/`level`, menampilkan dan mencari `request_id`, serta merender data log dengan escaping aman. Tabel dipaginasi di sisi frontend dengan default 10 baris per halaman, opsi 10/25/50/100, info rentang data, dan tombol Previous/Next yang mengikuti hasil filter aktif.

API:
- `api/users.php?action=getActivityLogs` — guard `Admin`/`Super Admin`; response menjaga `aktivitas` legacy dan menambahkan field turunan `event`, `request_id`, `category`, `level`, `detail`/`context`, `is_structured` dari payload JSON bila tersedia. Endpoint tetap mengirim dataset existing (100 log terbaru); pagination dilakukan oleh UI halaman.

### `pages/login.php`
Login form mandiri untuk route `/login`, generate CSRF token, dan menangani POST autentikasi tanpa template shared. Tampilan memakai Tailwind CDN dengan tema maroon, layout responsif mobile (`w-full max-w-md`, padding adaptif, `overflow-x-hidden`), input username/password dan tombol submit dengan tap target minimal 48px, alert error `role="alert"`, atribut autocomplete, serta JS ringan untuk state loading/disabled saat submit agar double submit berkurang. Logic autentikasi, CSRF, rate limit, session, dan redirect tetap server-side di file ini.

## Frontend Rules

- POST harus menyertakan `csrf_token: window.csrfToken`.
- User feedback pakai `showToast()`.
- Ikuti Tailwind maroon theme.
