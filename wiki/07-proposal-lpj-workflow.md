# Proposal & LPJ Workflow - LK UKMs

## Data Model

Proposal dan LPJ sama-sama disimpan di tabel `proposal`.

Pembeda:

```text
Proposal: jenis != 'LPJ'
LPJ:      jenis = 'LPJ'
```

LPJ dapat merujuk proposal sumber via:

```text
parent_proposal_id
```

## Status Penting

- `status`: status approval dokumen.
- `status_keuangan`: status pencairan proposal, hanya relevan untuk Proposal final, bukan LPJ.
- `current_approver`: approver yang sedang mendapat giliran.
- `history`: JSON riwayat approval/status.

## Approval Chain

Alur approval ada di tabel `alur`:

```text
pengaju, acc1, acc2, acc3, acc4, acc5, acc6
```

Helper:

```php
getApprovalChain($pengaju)
findApproverUsers($approver)
normalizeApprover($value)
```

Perbandingan approver wajib:

```php
normalizeApprover($currentApprover) === normalizeApprover($username)
```

Jangan pakai raw lowercase comparison.

## Tambah Proposal/LPJ

Endpoint:

```text
POST api/proposal.php action=addProposal
```

Aturan umum:
- Hanya role `User` yang mengajukan proposal/LPJ.
- Nama kegiatan dan jenis wajib.
- **Upload file wajib** dan divalidasi dengan `uploadFileSecure()` — baik frontend maupun backend.
- `tanggal_pelaksanaan` opsional (DATE).
- Proposal (`jenis != 'LPJ'`) tidak boleh memakai `tanggal_pelaksanaan` lampau saat diajukan user.
- LPJ (`jenis = 'LPJ'`) boleh memakai `tanggal_pelaksanaan` lampau karena LPJ adalah laporan kegiatan yang sudah terjadi.
- Untuk LPJ, proposal sumber harus valid, milik pengaju, bukan LPJ, dan sudah dicairkan.
- Sistem mencegah LPJ duplicate untuk proposal sumber yang sama.

Catatan teknis insert:
- Submit Proposal/LPJ memakai jalur `INSERT` yang sama di `api/proposal.php?action=addProposal`.
- `bind_param()` untuk insert harus konsisten dengan 15 placeholder dan 15 variabel; tipe parameter yang digunakan: `ssssssssssdsssi`.
- API proposal sudah memakai JSON error handler; fatal error submit harus menjadi JSON generic dengan `request_id`, kecuali endpoint PDF/binary.
- Frontend submit/revise memakai `formatApiError()` dari `templates/footer.php`; bila response error membawa `request_id`, pesan user menambahkan `Kode laporan` untuk korelasi dengan Activity Logs.

Logging P0/P1 submit Proposal/LPJ:
- `addProposal` mencatat event terstruktur via `recordEventLog()` untuk validation/file/db/success path.
- Event utama: `proposal_submit_validation_failed`, `proposal_submit_file_failed`, `proposal_submit_db_connection_failed`, `proposal_submit_db_prepare_failed`, `proposal_submit_db_execute_failed`, dan `proposal_submit_success`.
- `addProposal` memakai `uploadFileSecureWithResult()` agar kegagalan upload tercatat lebih presisi dengan `reason`, `message`, `file_name`, `file_size`, `file_ext`, dan `mime` tanpa menyimpan payload file.
- Context aman berisi metadata minimal seperti `request_id`, `doc_type`, `parent_proposal_id`, `nama_kegiatan`, `file_name`, `file_size`, `file_ext`, `mime`, `reason`, dan `proposal_id` saat sukses.
- Handler API juga mencatat indikasi request size/POST kosong: `content_length_exceeds_post_max_size` dan `empty_post_possible_size_limit_or_timeout` untuk membantu diagnosis upload besar/timeout.
- Jangan log payload file/base64, dump `$_POST`/`$_FILES`, token/CSRF/cookie, password, nomor rekening, secret, stack trace lengkap, atau isi dokumen.

## LPJ Detail Modal

Saat membuka detail LPJ di modal (`pages/proposal.php`):
- Jika `url_file` kosong → menampilkan notice merah: "File LPJ tidak tersedia"
- Jika proposal sumber (`parent_proposal_id`) memiliki file → menampilkan link "Buka Proposal Sumber" (hijau) sebagai alternatif

## Update Status Approval

Endpoint:

```text
POST api/proposal.php action=updateStatusProposal
```

Role:
- `Admin`
- `Super Admin`
- `Approver`

Untuk `Approver`, harus sesuai `current_approver`.

Status umum:
- Menunggu
- Disetujui
- Ditolak
- Revisi

## Revisi Proposal/LPJ

Endpoint:

```text
POST api/proposal.php action=reviseProposal
```

Tabel pendukung:

```text
proposal_revision_history
```

Catatan:
- Revisi hanya valid saat dokumen dalam status revisi.
- Upload revisi harus divalidasi.
- History dan revision cycle/version perlu dijaga.
- P1 upload logging: `reviseProposal` memakai `uploadFileSecureWithResult()` dan mencatat `proposal_revise_file_failed` dengan metadata aman (`proposal_id`, `reason`, `message`, `file_name`, `file_size`, `file_ext`, `mime`) agar diagnosis kegagalan upload revisi lebih presisi tanpa log payload base64/isi dokumen.

## Status Keuangan Proposal

Endpoint:

```text
POST api/proposal.php action=updateProposalFinancialStatus
```

Role:
- `Super Admin`

Aturan:
- Tidak berlaku untuk LPJ.
- Hanya bisa diubah untuk proposal final `Disetujui`.

## Edit Proposal oleh Admin

Endpoint:

```text
POST api/proposal.php action=editProposalByAdmin
```

Role:
- `Super Admin`
- `Admin`

### Edit `tanggal_pelaksanaan` oleh Super Admin

Super Admin dapat mengedit atau mengosongkan (`NULL`) kolom `tanggal_pelaksanaan` proposal.

Aturan:
- Format tanggal wajib valid (`YYYY-MM-DD`) jika diisi.
- Tanggal kosong disimpan sebagai `NULL`; tanggal invalid ditolak.
- Tanggal lampau diperbolehkan untuk koreksi admin.
- Perubahan dicatat via history/keterangan/log aktivitas.

## Reminder

Endpoint:

```text
POST api/proposal.php action=sendReminder
```

Role:
- `Super Admin`

Mengirim notifikasi ke pengaju/approver sesuai status.

## Lembar Pengesahan Proposal

Endpoint:

```text
GET api/proposal.php?action=generateLembarPengesahan&id=...
```

Akses diizinkan untuk:
- `Super Admin`
- username `ketua-dpm`
- owner/pengaju dokumen

Syarat:
- `jenis != LPJ`
- `status = Disetujui`

Output:
- Stream PDF TCPDF langsung.
- Jangan `jsonResponse()` saat success.

Frontend visibility:
- `pages/proposal.php` → `canGenerateLembar(p)`

## Lembar Pengesahan LPJ

Endpoint:

```text
GET api/proposal.php?action=generateLembarPengesahanLPJ&id=...
```

Akses diizinkan untuk:
- `Super Admin`
- username `ketua-dpm`
- owner/pengaju dokumen

Syarat:
- `jenis = LPJ`
- `status = Disetujui`

LPJ approval sheet bisa memakai data proposal sumber via `parent_proposal_id`.

Frontend visibility:
- `pages/proposal.php` → `canGenerateLembarLPJ(p)`

## AI Analysis Proposal

Endpoint:
- `extractTextProposal`
- `analyzeProposal`
- `continueAnalysisProposal`

Kolom:
- `content_text`
- `ai_analysis`
- `ai_analysis_at`
- `ai_prompt_hash`
- `ai_usage`

## Durasi Approval (Frontend-only)

Kolom **Durasi** di halaman Proposal (setelah Anggaran, sebelum Status) menampilkan durasi approval dalam hitungan hari.

### Sumber Data

- `proposal.tanggal_upload` — tanggal pengajuan (MySQL DATETIME `yyyy-mm-dd HH:ii:ss`)
- `proposal.history` — JSON array riwayat approval/status

### Formula

**Total durasi:**
- Jika final Disetujui → `tanggal_upload` → tanggal entry terakhir yang mengandung "setuju"
- Jika belum final → `tanggal_upload` → waktu sekarang (ongoing)

**Durasi tahap saat ini:**
- Selisih hari antara entry history sebelumnya dengan entry terakhir (atau `now` jika ongoing)

### Helper Functions (JavaScript)

| Function | Peran |
|---|---|
| `parseProposalDate(value)` | Parsing tanggal: `dd/mm/yyyy HH:ii:ss` (history) dan `yyyy-mm-dd HH:ii:ss` (MySQL) |
| `normalizeProposalHistory(history)` | Normalisasi JSON history ke array, populate `_date` |
| `diffDays(startDate, endDate)` | Selisih hari (floor) |
| `getApprovalEndDate(p, history)` | Tanggal final approval (entry terakhir dengan status mengandung "setuju") |
| `formatDurationLabel(days)` | Format: "Hari ini" / "X hari" |
| `getDurationColorClass(days)` | Warna: gray (≤2), yellow (≤7), red (>7) |
| `getProposalDurationInfo(p)` | Mengembalikan object: `totalDays`, `totalLabel`, `stageDays`, `stageLabel`, `stageName`, `isOngoing`, `sortValue`, `tooltip` |
| `renderDurationCell(p)` | Render HTML cell untuk tabel |

### Catatan Teknis

- **Tidak ada perubahan schema DB** — semua kalkulasi dilakukan entirely di frontend JS.
- Kolom `Durasi` bisa di-sort via `toggleSort('durasi')` menggunakan `sortValue` (numerik).
- Tooltip pada cell menampilkan breakdown per tahap: "Ajuan → Acc1: X hari, Acc1 → Acc2: Y hari, ..."

## Halaman List Proposal

Halaman `/proposal` menampilkan kolom `tanggal_pelaksanaan` pada tabel, setelah kolom `tanggal_ajuan`.

## QA Regression Area

Jika mengubah proposal/LPJ, cek:
- Add proposal.
- Add LPJ dari proposal dicairkan.
- Approval oleh approver sesuai giliran.
- Revisi.
- Final approved.
- Generate lembar proposal.
- Generate lembar LPJ.
- Role non-owner tidak bisa akses dokumen/PDF.
