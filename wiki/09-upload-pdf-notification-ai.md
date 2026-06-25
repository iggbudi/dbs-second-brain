# Upload, PDF, Notification, AI - LK UKMs

## Upload

Helper utama:

```php
uploadFileSecureWithResult($base64Data, $fileName, $username, $category, $config)
uploadFileSecure($base64Data, $fileName, $username, $category, $config) // wrapper legacy compatible
uploadFileSmart($base64Data, $fileName, $username, $category) // legacy/basic
```

Prioritas gunakan `uploadFileSecureWithResult()` untuk alur baru yang perlu logging/diagnosis upload, atau `uploadFileSecure()` bila caller lama hanya membutuhkan URL/string kosong.

`uploadFileSecureWithResult()` return array metadata aman:

```text
success, url, reason, message, file_name, file_size, file_ext, mime
```

`uploadFileSecure()` tetap kompatibel: internally memanggil result helper lalu return URL saat sukses atau `''` saat gagal.

Config contoh:

```php
$config = [
    'mimes' => ['application/pdf'],
    'extensions' => ['pdf'],
    'max_size_mb' => 10,
];
```

File disimpan di:

```text
uploads/{category}_{username}/
```

Nama file menggunakan prefix unik untuk menghindari overwrite.

### P1 Upload Logging / Error Diagnosis Smoke Checklist

Gunakan checklist ini saat memverifikasi perubahan upload Proposal/LPJ dan revisi:

1. Submit Proposal/LPJ valid dengan PDF kecil.
   - Expected: response sukses, file tersimpan di `uploads/proposal_ukm_{username}/`, event `proposal_submit_success` tercatat dengan `proposal_id`/metadata aman.
2. Submit Proposal/LPJ tanpa file atau tanpa `fileName`.
   - Expected: response JSON error user-facing, event `proposal_submit_file_failed` dengan `reason=missing_file_or_file_name`.
3. Submit file ekstensi/MIME tidak valid.
   - Expected: response JSON error validasi, event `proposal_submit_file_failed`; `error_log` berisi `upload_file_secure_failed` dengan reason seperti `invalid_extension` atau `invalid_mime`.
4. Submit file melebihi batas konfigurasi.
   - Expected: response JSON error, log aman dengan `reason=file_too_large` atau indikasi size limit (`content_length_exceeds_post_max_size` / `empty_post_possible_size_limit_or_timeout`) bila request terpotong oleh PHP/web server.
5. Upload revisi Proposal/LPJ dengan file invalid saat dokumen status Revisi.
   - Expected: event `proposal_revise_file_failed` dengan `proposal_id`, `reason`, `file_name`, `file_size`, `file_ext`, `mime` bila tersedia.
6. Review log.
   - Expected: ada `request_id` untuk korelasi; tidak ada base64 payload, isi dokumen, CSRF token, cookie/session id, password/secret, dump penuh `$_POST`/`$_FILES`, stack trace lengkap, atau path internal sensitif.

## PDF Generation

PDF memakai TCPDF. Endpoint PDF success stream langsung ke browser.

Contoh endpoint:

```text
api/proposal.php?action=generateLembarPengesahan&id=...
api/proposal.php?action=generateLembarPengesahanLPJ&id=...
api/surat.php?action=generatePengesahanSurat&id=...
```

Aturan:
- Validasi login dan permission sebelum stream.
- Validasi dokumen/status sebelum stream.
- Jangan `jsonResponse()` saat success.
- Boleh `jsonResponse()` untuk error sebelum output PDF.

TCPDF class bisa berbeda tergantung Composer:

```php
\TCPDF\TCPDF
\TCPDF
```

## Email

File: `includes/email.php`.

Helper:

```php
sendSystemEmail($email, $name, $subject, $htmlBody, $altBody = '', $attachments = [])
sendWelcomeEmail($email, $username, $name, $password)
```

Ada juga wrapper di `includes/functions.php`:

```php
sendEmailNotification($to, $subject, $body, $attachments = [])
```

SMTP dikonfigurasi untuk Gmail/PHPMailer.

## WhatsApp

Helper:

```php
sendWhatsAppNotification($phone, $message)
```

Mengirim ke service:

```text
https://wa.dwibudi.my.id/instances/{instanceId}/messages
```

Instance ID hardcoded di helper existing.

## Notification Text

Helper:

```php
getNotificationLoginUrl()
appendNotificationGuide($message, $menuLabel, $actionHint = '')
getSebutan($name, $preferredSebutan = '')
```

`sebutan` berasal dari field user atau fallback heuristik nama.

## AI Analysis

### Model AI

**Provider:** Sumopod API (`sumo2`)
**Model:** `MiniMax-M2.7-highspeed`
**Endpoint:** `https://ai.sumopod.com/v1/chat/completions`

Konfigurasi di `.env`:
```env
AI_MODEL=MiniMax-M2.7-highspeed
AI_PROVIDER=sumo2
AI_ENDPOINT=https://ai.sumopod.com/v1/chat/completions
```

### Modul yang punya AI analysis

- Arsip (`api/arsip.php`)
- Proposal/LPJ (`api/proposal.php`)

Kolom umum:

```text
content_text
ai_analysis
ai_analysis_at
ai_prompt_hash
ai_usage
```

### Endpoint umum

| Action | Modul | Deskripsi |
|--------|-------|-----------|
| `extractTextArsip` | arsip | Ekstrak teks dari PDF arsip |
| `analyzeArsip` | arsip | Analisis AI pertama arsip |
| `continueAnalysisArsip` | arsip | Lanjutan analisis arsip |
| `extractTextProposal` | proposal | Ekstrak teks dari PDF proposal |
| `analyzeProposal` | proposal | Analisis AI pertama proposal |
| `continueAnalysisProposal` | proposal | Lanjutan analisis proposal |

Integrasi AI membaca API key melalui `.env`/`includes/env.php` sesuai pola existing.

### Cache AI Response

Mekanisme cache menggunakan hash prompt:

1. Saat analisis, hash prompt dihitung: `ai_prompt_hash = md5($prompt)`
2. Jika hash cocok dengan record di DB → return hasil dari DB (tanpa panggil AI)
3. Cache response menyertakan `messages` untuk keperluan continue
4. Hash disimpan di kolom `ai_prompt_hash`

**Catatan:** Cache berlaku untuk analisis awal dan continue.

### Text Extraction

Helper utama:

```php
extractPdfText($urlFile)
extractAndSaveContentText($urlFile, $table, $id)
extractPdfTextDetailed($urlFile)
extractAndSaveContentTextDetailed($urlFile, $table, $id)
resolveDocumentTextForAi($urlFile, $table, $id)
```

Digunakan untuk menyimpan `content_text` sebelum analisis AI. Untuk alur `analyzeProposal`, `resolveDocumentTextForAi()` menjadi resolver utama: jika `content_text` sudah ada maka dipakai langsung; jika belum ada dan file PDF tersedia maka sistem mencoba ekstraksi teks.

Jika ekstraksi PDF gagal karena `pdftotext` tidak tersedia, PDF scan/tidak memiliki teks, atau PDF terenkripsi, alur Analisis AI proposal tidak lagi gagal total. Sistem tetap membuat analisis berbasis metadata dokumen dan mengirim warning non-blocking `extractionWarning` dengan pesan ramah pengguna: “Isi PDF belum dapat dibaca, analisis dibuat berdasarkan metadata dokumen.”

## Security Notes

- Jangan log/return API key AI/SMTP/WA.
- Validasi akses sebelum menjalankan AI analysis pada dokumen.
- Hindari menampilkan path filesystem ke user.
- Untuk attachment email, resolve path lokal dengan aman.

---

## Pembaruan 2026-05-31

### Ringkasan Perubahan

| Kategori | Perubahan |
|----------|-----------|
| Security | Access control fix, audit logging, authorization verify |
| Model AI | MiniMax-M2.7-highspeed via sumo2 |
| Backend | DB append (continue), cache mechanism, recordLog |
| Frontend | XSS prevention, batas continue 2x, sessionStorage, hapus analisis ulang |

---

### Security Hardening

#### Access Control Fix — `api/proposal.php`

- **Bug:** `in_array('Super Admin', $role)` selalu `false` karena `$role` adalah string
- **Fix:** Gunakan pattern `in_array($role, ['Super Admin', 'Admin'])`
- **Impact:** Super Admin & Admin sekarang bisa akses Analisis AI

#### Audit Logging — `api/proposal.php`

`recordLog()` ditambahkan di:

| Action | Format Log |
|--------|------------|
| `analyzeProposal` | `"Melakukan analisis AI pada proposal: {nama} (ID: {id})"` |
| `continueAnalysisProposal` | `"{accept/revisi} hasil analisis AI pada proposal: {nama} (ID: {id})"` |

#### Authorization — `continueAnalysisProposal()`

- Memverifikasi kepemilikan proposal
- User biasa hanya bisa melanjutkan analisis miliknya sendiri
- Super Admin & Admin bisa melanjutkan analisis proposal siapa pun

#### XSS Prevention — Frontend

- **Files:** `pages/proposal.php`, `pages/arsip_proposal.php`
- DOM whitelist sanitizer: hanya tag yang diizinkan (`strong`, `em`, `ul`, `li`, `ol`, `h1-h3`, `p`, `br`, `blockquote`, `code`)
- `escapeHtml()` dilakukan sebelum markdown parsing di `formatAnalysis()`

---

### Model AI Baru

| Item | Nilai |
|------|-------|
| Provider | sumo2 (Sumopod API) |
| Model | MiniMax-M2.7-highspeed |
| Endpoint | `https://ai.sumopod.com/v1/chat/completions` |

Konfigurasi di `.env`:
```env
AI_MODEL=MiniMax-M2.7-highspeed
AI_PROVIDER=sumo2
```

---

### Perbaikan Backend — `api/proposal.php`

#### DB Append (Continue Analysis)

Hasil lanjutan di-APPEND ke kolom `ai_analysis` (bukan replace):

```php
// Sebelum: $db->update(..., ['ai_analysis' => $newResult]);
// Sesudah: $db->update(..., ['ai_analysis' => $existing . "\n\n" . $newResult]);
```

#### Cache Mechanism

| Kondisi | Perilaku |
|---------|----------|
| `ai_prompt_hash` cocok | Return dari DB, tidak panggil AI |
| Cache hit | Response menyertakan `messages` untuk continue |

#### Continue Analysis Authorization

`continueAnalysisProposal()` sekarang:
1. Verifikasi user login
2. Cek role: Super Admin/Admin boleh siapa pun, user biasa hanya miliknya
3. Record log dengan action `accept` atau `revisi`

---

### Perbaikan Frontend

#### `pages/proposal.php`

| Fitur | Detail |
|-------|--------|
| XSS Prevention | DOM whitelist sanitizer + `escapeHtml()` di `formatAnalysis()` |
| Tombol "Analisis Ulang" | Dihapus |
| Tombol "Lanjutkan" | Maks 2x, disabled saat cache aktif |
| Indikator "hasil terpotong" | Tampil saat hasil awal terpotong |
| sessionStorage | Messages di-persist untuk continue |
| Kirim ID proposal | Via FormData (bukan URL) |
| Error Handling | Perbaikan di catch block |

#### `pages/arsip_proposal.php`

Diselaraskan dengan `pages/proposal.php`:
- XSS prevention dengan DOM whitelist sanitizer
- Kirim ID proposal di FormData
- Error handling untuk continue analysis
- sessionStorage untuk persist messages

---

### Checklist Status — 2026-05-31

| Item | Status |
|------|--------|
| Access control fix | ✅ Selesai |
| Audit logging (`recordLog`) | ✅ Selesai |
| Authorization `continueAnalysisProposal` | ✅ Selesai |
| DB append (continue, bukan replace) | ✅ Selesai |
| Cache dengan `ai_prompt_hash` | ✅ Selesai |
| Cache response menyertakan `messages` | ✅ Selesai |
| Model AI: MiniMax-M2.7-highspeed | ✅ Selesai |
| XSS prevention (whitelist sanitizer + `escapeHtml`) | ✅ Selesai |
| Hapus tombol "Analisis Ulang" | ✅ Selesai |
| Batas continue maks 2x | ✅ Selesai |
| Indikator "hasil terpotong" | ✅ Selesai |
| sessionStorage untuk messages | ✅ Selesai |
| Error handling improvement | ✅ Selesai |
| Kirim ID proposal di FormData | ✅ Selesai |
| Sync `arsip_proposal.php` dengan `proposal.php` | ✅ Selesai |
