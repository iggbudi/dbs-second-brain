# Surat Workflow - LK UKMs

## Modul

Surat dikelola terutama oleh:

```text
pages/surat_masuk.php
api/surat.php
modals/surat.php
```

`surat_masuk` dan `surat_keluar` punya tabel berbeda tetapi berbagi page/API.

Route `surat_keluar` diarahkan ke `surat_masuk`.

## Surat Masuk

Tabel: `surat_masuk`

Kolom penting:
- `nomor_surat`
- `tanggal_terima`
- `pengirim`
- `no_hp`
- `perkara`
- `kategori`
- `status`
- `keterangan`
- `url_dokumen`
- `owner`
- `ref_id`
- `nim`

Endpoint umum:

```text
GET  api/surat.php?action=getSuratMasuk
POST api/surat.php action=addSuratMasuk
POST api/surat.php action=updateStatusSurat
POST api/surat.php action=deleteSuratMasuk
```

## Surat Keluar

Tabel: `surat_keluar`

Kolom penting:
- `nomor_surat`
- `tanggal_kirim`
- `tujuan`
- `perkara`
- `kategori`
- `status`
- `keterangan`
- `history`
- `url_dokumen`
- `created_by`
- `ref_id`
- `manual_name`
- `manual_phone`
- `idempotency_key`

Endpoint umum:

```text
GET  api/surat.php?action=getSuratKeluar
POST api/surat.php action=addSuratKeluar
POST api/surat.php action=reviseSuratKeluar
POST api/surat.php action=deleteSuratKeluar
```

Catatan: `idempotency_key` digunakan untuk mencegah duplicate submit surat keluar.

## Disposisi

Tabel: `surat_disposisi`

Kolom penting:
- `surat_masuk_id`
- `dari_username`
- `kepada_username`
- `kepada_role`
- `isi_disposisi`
- `prioritas`
- `tenggat`
- `status`

Endpoint:

```text
POST api/surat.php action=addDisposisiSurat
GET  api/surat.php?action=getDisposisiBySurat
GET  api/surat.php?action=getDisposisiList
POST api/surat.php action=updateDisposisiStatus
```

Page:
- `pages/surat_masuk.php` untuk membuat disposisi dari surat.
- `pages/disposisi.php` untuk daftar/update disposisi.

## Status Surat

Status tergantung jenis dan workflow existing. Saat mengubah status, pastikan:
- Role yang berhak diverifikasi server-side.
- History/keterangan diperbarui bila diperlukan.
- Notifikasi dikirim bila pattern existing mengharuskan.

## Upload Dokumen Surat

Upload harus pakai `uploadFileSecure()` dengan config MIME/ext/size sesuai dokumen.

Surat keluar juga punya proses konversi dokumen:
- `convertDocxToPdf()`
- `ensureSuratAsPdf()`

## Pengesahan Surat

Endpoint:

```text
GET api/surat.php?action=generatePengesahanSurat&id=...
```

Output PDF/binary harus stream langsung pada success.

Pastikan access control dilakukan sebelum generate/stream PDF.

## Notifikasi

Surat dapat mengirim email/WhatsApp. Helper terkait:
- `buildNotificationAbsoluteUrl()`
- `resolveApprovedLetterEmailTarget()`
- `buildApprovedSuratEmailAttachments()`
- `sendEmailNotification()`
- `sendWhatsAppNotification()`

## QA Regression Area

Jika mengubah surat, cek:
- List surat masuk/keluar.
- Add surat masuk.
- Add surat keluar.
- Duplicate prevention/idempotency surat keluar.
- Update status.
- Revisi surat keluar.
- Disposisi create/list/update.
- Generate pengesahan surat.
- Permission role `Disposisi` dan `Read Only`.
