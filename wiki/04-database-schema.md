# Database Schema Summary - LK UKMs

Sumber otoritatif: `config/schema.sql`.

DB: `lkukm_db`, charset `utf8mb4`, akses via `getDBConnection()`.

## Tables

### `users`
User account dan profile.

Kolom penting:
- `username`, `password`, `name`, `jabatan`, `sebutan`, `role`
- `phone`, `email`, `nim`, `unit`
- `force_change`, `force_change_at`

Role: `Super Admin`, `Admin`, `User`, `Approver`, `Disposisi`, `Read Only`.

### `activity_logs`
Log aktivitas user/system.

Kolom: `waktu`, `username`, `nama_lengkap`, `role`, `aktivitas`.

P2 minimal observability tidak menambah migrasi fisik untuk log terstruktur. Field seperti `event`, `request_id`, `category`, `level`, dan `context` diparse dari JSON yang tersimpan di kolom legacy `aktivitas`; kolom/index fisik `level`, `category`, `request_id`, dan `context_json` masih deferred.

Helper:
- `recordLog($user, $activity)`
- `recordLogSystem($activity)`

### `surat_masuk`
Surat masuk.

Kolom penting:
- `nomor_surat`, `tanggal_terima`, `pengirim`, `no_hp`
- `perkara`, `kategori`, `status`, `keterangan`
- `url_dokumen`, `owner`, `ref_id`, `nim`

### `surat_keluar`
Surat keluar.

Kolom penting:
- `nomor_surat`, `tanggal_kirim`, `tujuan`
- `perkara`, `kategori`, `status`, `keterangan`, `history`
- `url_dokumen`, `created_by`, `ref_id`
- `manual_name`, `manual_phone`, `idempotency_key`

### `surat_disposisi`
Disposisi surat masuk.

Kolom penting:
- `surat_masuk_id`, `ref_id`, `nomor_surat`, `perihal`
- `dari_username`, `kepada_username`, `kepada_role`
- `isi_disposisi`, `prioritas`, `tenggat`, `status`

### `arsip`
Arsip dokumen/surat.

Kolom penting:
- `tanggal`, `nama_surat`, `perkara`, `url_file`, `uploaded_by`
- `content_text`, `ai_analysis`, `ai_analysis_at`, `ai_prompt_hash`, `ai_usage`

### `penggunaan_ruangan`
Jadwal penggunaan ruangan.

Kolom: `tanggal`, `jam_mulai`, `jam_selesai`, `ruangan`, `pengguna_ruangan`, `created_by`.

### `pengumuman`
Pengumuman dashboard/page.

Kolom: `tanggal`, `isi`, `created_by`.

### `laporan_kipk`
Upload laporan KIPK.

Kolom: `nama_mahasiswa`, `nim`, `semester`, `jenis_laporan`, `status`, `keterangan`, `url_file`, `uploaded_by`.

### `proposal`
Tabel utama proposal dan LPJ. Dibedakan oleh `jenis`.

Kolom penting:
- `nama_kegiatan`, `jenis`, `pengaju`, `status`
- `status_keuangan`
- `url_file`, `content_text`, `ai_analysis`, `ai_usage`
- `ketua`, `nim_ketua`, `nama_bank`, `no_rekening`, `jumlah_anggaran`
- `tanggal_pelaksanaan` — DATE opsional
- `current_approver`, `parent_proposal_id`, `history`

Catatan:
- Proposal: `jenis != 'LPJ'`
- LPJ: `jenis = 'LPJ'`
- LPJ bisa merujuk proposal sumber via `parent_proposal_id`.

**Deployment existing DB:** jika kolom `tanggal_pelaksanaan` belum ada, API runtime melakukan `ALTER TABLE proposal ADD COLUMN tanggal_pelaksanaan DATE DEFAULT NULL`. ALTER manual tetap dapat dilakukan jika diinginkan.

### `proposal_revision_history`
Riwayat revisi proposal/LPJ.

Kolom penting:
- `proposal_id`, `revision_cycle`, `version_no`, `event_type`
- `approver_username`, `approver_name`, `request_note`
- `uploaded_by`, `uploaded_at`, `file_url`

### `alur`
Approval chain per pengaju.

Kolom:
- `pengaju`
- `acc1` ... `acc6`

Gunakan `getApprovalChain($pengaju)` dan `normalizeApprover()`.

### `system_config`
Konfigurasi sistem.

Keys default:
- `OPEN_SURAT`
- `OPEN_KIPK`
- `SYSTEM_NAME`
- `SYSTEM_DESC`

Helper:
- `getSystemConfig()`
- `getSystemName()`
- `getSystemDescription()`
- `saveSystemConfig()`
