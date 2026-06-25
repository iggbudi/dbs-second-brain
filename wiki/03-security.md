# Security Rules - LK UKMs

## Auth & Session

- Auth berbasis session.
- User login disimpan di `$_SESSION['user']`.
- Gunakan `isLoggedIn()` dan `getCurrentUser()` dari `includes/functions.php`.
- Jangan percaya role/username dari request client.

## Role-Based Access Control

Role yang dikenal:

```text
Super Admin
Admin
User
Approver
Disposisi
Read Only
```

Gunakan:

```php
requireRole('Super Admin');
requireRole(['Admin', 'Super Admin']);
```

`requireRole()` ada di `includes/security.php` dan akan return JSON 403 bila akses ditolak.

## CSRF

Semua POST API wajib validasi CSRF.

Backend:

```php
requireCsrfToken();
```

Frontend:

```js
formData.append('csrf_token', window.csrfToken);
```

`window.csrfToken` diset oleh `templates/header.php`. Jangan fetch token baru mid-page kecuali benar-benar perlu.

## SQL Injection

Semua query wajib prepared statements.

Benar:

```php
$stmt = $conn->prepare('SELECT * FROM users WHERE id = ?');
$stmt->bind_param('i', $id);
$stmt->execute();
```

Hindari concat input user ke SQL.

## XSS / Output Escaping

Untuk output HTML dari data user, gunakan:

```php
sanitize($value)
```

Atau escaping setara seperti `htmlspecialchars()` bila konteksnya jelas.

## Upload Security

Prioritaskan helper upload aman dari `includes/functions.php`.

Untuk caller yang perlu diagnosis/logging detail gunakan:

```php
$result = uploadFileSecureWithResult($base64Data, $fileName, $username, 'category', [
    'mimes' => ['application/pdf'],
    'extensions' => ['pdf'],
    'max_size_mb' => 10,
]);

if (empty($result['success'])) {
    // log metadata aman: reason/message/file_name/file_size/file_ext/mime
}
```

`uploadFileSecureWithResult()` mengembalikan metadata aman: `success`, `url`, `reason`, `message`, `file_name`, `file_size`, `file_ext`, dan `mime`. Helper ini juga menulis `error_log` ringkas pada kegagalan upload dengan context yang sudah melalui sanitasi/redaction bila helper tersedia. Jangan log payload base64 atau isi file.

Untuk kompatibilitas kode lama, `uploadFileSecure()` tetap tersedia sebagai wrapper legacy yang memanggil `uploadFileSecureWithResult()` dan mengembalikan string URL saat sukses atau string kosong saat gagal.

Validasi wajib:

- MIME type
- extension
- ukuran file
- nama file aman
- lokasi upload sesuai kategori/user

## PDF/Binary Endpoint

Endpoint PDF harus:

1. Validasi login/permission dulu.
2. Validasi ownership/role bila relevan.
3. Validasi status dokumen.
4. Baru stream PDF.

Jangan `jsonResponse()` pada success PDF/binary.

## Approval Security

Proposal/LPJ memakai approval chain dinamis. Untuk membandingkan approver/current approver/username, gunakan:

```php
normalizeApprover($value)
```

Jangan pakai raw `strtolower()` karena username/role bisa berbeda spasi vs underscore.

## Error Handling & Logging P0

### Production error config

- `index.php` dan `config/database.php` membaca `APP_ENV` dan `APP_DEBUG`.
- Default environment adalah `production`; production harus memakai `APP_ENV=production` dan `APP_DEBUG` tidak aktif.
- `display_errors` dan `display_startup_errors` hanya aktif untuk `APP_ENV=local|development|dev` atau `APP_DEBUG=true`.
- Di production, `display_errors=0`/`display_startup_errors=0` dan `log_errors=1`; error detail tidak ditampilkan ke user.

### Structured event logging

Helper logging terstruktur ada di `includes/functions.php`:

```php
getRequestId()
safeLogContext($context)
recordEventLog($event, $context = [], $user = null)
```

- Setiap request mendapat `request_id` untuk korelasi response, `error_log`, dan `activity_logs`.
- `jsonResponse()` menambahkan `data.request_id` pada response error bila helper tersedia.
- `recordEventLog()` menyimpan event aman ke `activity_logs` dan fallback ke `error_log`; helper tidak boleh melempar exception.
- Context harus ringkas dan aman; `safeLogContext()` melakukan redaction/drop key sensitif dan memotong nilai panjang.
- P2 minimal observability belum menambah kolom fisik baru di `activity_logs`; data terstruktur dibaca dari payload JSON legacy di kolom `aktivitas`.
- Kolom/index fisik untuk `level`, `category`, `request_id`, dan `context_json` masih deferred. Jangan mengandalkan kolom tersebut di query sampai ada migrasi resmi.

### API JSON error handler

- Endpoint JSON proposal memakai handler JSON-safe dari `registerApiJsonErrorHandlers('proposal')`.
- Handler mengubah unhandled exception/PHP error/fatal error menjadi JSON generic: `success=false`, pesan umum, dan `data.request_id`.
- Header `X-Request-ID` dikirim bila header belum terkirim.
- `formatApiError()` di `templates/footer.php` menampilkan `request_id` dari error proposal submit/revise sebagai `Kode laporan` agar user bisa menyertakan kode saat melapor tanpa melihat detail internal.
- Handler juga mencatat indikasi request bermasalah: `content_length_exceeds_post_max_size` dan `empty_post_possible_size_limit_or_timeout`.
- Pengecualian: endpoint PDF/binary seperti `generateLembarPengesahan` dan `generateLembarPengesahanLPJ` tetap stream PDF pada success dan tidak memakai `jsonResponse()` untuk output binary.
- P1-2 penerapan JSON error handler ke API lain masih **deferred/bertahap**. Jangan menganggap semua `api/*.php` sudah memakai handler ini, karena endpoint PDF/binary atau response non-JSON berisiko rusak bila dipasang secara broad tanpa audit output.

### Data sensitif yang tidak boleh dilog

Jangan log nilai mentah berikut:

- Password/PIN/passphrase dan hash password.
- CSRF token, access token, API key, authorization header.
- Cookie/session id.
- Base64/file payload, isi dokumen, atau file upload mentah.
- Nomor rekening, credential bank, secret SMTP/WA/AI, dan konfigurasi rahasia lain.
- Stack trace lengkap, path internal detail, SQL mentah dengan data user, atau dump `$_POST`/`$_FILES` penuh.
- Data pribadi yang tidak perlu untuk diagnosis; gunakan id/status/reason/request size/file metadata minimal bila cukup.

## Checklist Review Security

- [ ] Login required bila endpoint/page sensitif.
- [ ] `requireRole()` atau owner check server-side.
- [ ] POST validasi CSRF.
- [ ] Prepared statements.
- [ ] Output escaped.
- [ ] Upload secure.
- [ ] PDF access control sebelum stream.
- [ ] Approval comparison pakai `normalizeApprover()`.
- [ ] Tidak ada secret di response/log user-facing.
