# Security Rules - LK UKMs Wiki Layer

Security workflow wajib membaca:

```text
.ai-team/wiki/03-security.md
.ai-team/wiki/02-routing.md
.ai-team/wiki/05-api-map.md
```

Tambahkan wiki domain bila relevan:
- Proposal/LPJ: `07-proposal-lpj-workflow.md`
- Surat: `08-surat-workflow.md`
- Upload/PDF/AI: `09-upload-pdf-notification-ai.md`

## Verification

- Auth/authorization server-side.
- CSRF untuk POST.
- Prepared statements.
- Output escaping.
- Secure upload.
- PDF access control sebelum stream.
- No secret leak.
- Approval uses `normalizeApprover()`.

## Reporting

Laporan security boleh menyebut severity, file, dampak, dan mitigasi. Jangan menulis secret/token/password atau detail eksploit berlebihan yang tidak diperlukan.
