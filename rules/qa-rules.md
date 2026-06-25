# QA Rules - LK UKMs Wiki Layer

QA wajib mulai dari wiki sesuai area, lalu verifikasi source/file berubah.

## Wajib Verifikasi Konkret

- Baca source/diff aktual yang berubah, bukan hanya ringkasan agent atau laporan implementasi.
- Setiap PASS harus punya evidence: file, fungsi/baris relevan, command, atau hasil inspeksi kode.
- Jika command tidak bisa dijalankan atau skenario tidak bisa dites, tulis keterbatasannya dan gunakan status `PASS WITH NOTES` atau `FAIL` sesuai risiko.
- Jangan memberi PASS pada kontrol kritis yang hanya diasumsikan.

## Syntax Check

```bash
rtk php -l path/to/file.php
```

## Checklist Ketat

### PHP / Type Safety
- Cek penggunaan built-in PHP sensitif tipe seperti `in_array`, `array_key_exists`, `json_decode`, `password_verify`, `hash_equals`, dan `mysqli::bind_param`.
- Role session biasanya string; pola benar: `$role === 'Super Admin'` atau `in_array($role, ['Super Admin', 'Admin'])`.
- Flag pola salah seperti `in_array('Super Admin', $roleString)`.

### Authorization & Negative Test
- Verifikasi role/owner berasal dari session/database, bukan input client.
- Untuk endpoint protected, cek minimal satu skenario negatif: user bukan owner/role tidak sesuai harus 403.
- PDF/binary harus cek akses sebelum stream output.

### CSRF & API Contract
- Semua POST memanggil `requireCsrfToken()`.
- Frontend POST mengirim `csrf_token: window.csrfToken`.
- Response JSON mengikuti `jsonResponse(['success'=>..., 'message'=>..., 'data'=>...])`, kecuali binary/PDF stream.

### SQL, XSS, Upload
- SQL wajib prepared statements; tidak ada concatenation input user.
- Output HTML wajib `sanitize()`/escape setara.
- JS `innerHTML` harus aman untuk konteks atribut/konten; quote escaping atau DOM API/textContent wajib diverifikasi.
- Upload wajib validasi MIME, extension, dan size eksplisit via helper secure.

### Logging & Audit
- Aksi state-changing/sensitif harus mencatat `recordLog()` atau `recordLogSystem()` bila bermakna.

## Regression Matrix

### Proposal/LPJ
Baca `07-proposal-lpj-workflow.md`.

Cek:
- add proposal
- add LPJ
- approval current approver
- revisi
- status keuangan
- generate PDF proposal/LPJ

### Surat
Baca `08-surat-workflow.md`.

Cek:
- surat masuk/keluar list/add/update/delete
- idempotency surat keluar
- disposisi
- pengesahan surat

### Security
Baca `03-security.md`.

Cek:
- auth/role
- CSRF
- SQLi
- XSS
- upload
- PDF access

## Report Output

Simpan report di `.ai-team/output/reports/[task].md` bila diminta.
