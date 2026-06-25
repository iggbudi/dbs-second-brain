# AGENTS.md

@/root/.codex/RTK.md
@./CLAUDE.md
@./panduanagen.md

## Project Operating Notes

- This project is LK UKMs, a native PHP application for proposal, LPJ, surat, pengumuman, users, and approval workflow management. KIPK is maintained in a separate project.
- Treat `CLAUDE.md` as the primary architecture and behavior reference before making code changes.
- Keep shell commands prefixed with `rtk` as required by `/root/.codex/RTK.md`.
- Prefer existing native PHP patterns over introducing a framework or new runtime.
- Main routing is handled by `index.php`; registered API endpoints live under `api/*.php`, and rendered pages live under `pages/*.php`.
- Shared layout files are `templates/header.php`, `templates/sidebar.php`, and `templates/footer.php`; page files include these directly.
- Database access must go through `getDBConnection()` from `config/database.php`.
- Use prepared statements for SQL. Do not concatenate user-controlled values into queries.
- Server-side permissions must use session role checks through `requireRole()` or existing security helpers. Never trust client-provided role values.
- POST API requests require CSRF validation. Frontend POST requests should pass `csrf_token: window.csrfToken`.
- API responses should use the existing `jsonResponse(['success' => ..., 'message' => ..., 'data' => ...])` shape unless the endpoint streams binary output.
- PDF generation endpoints stream PDF output directly and should not call `jsonResponse()`.
- For uploads, prefer `uploadFileSecure()` with explicit MIME, extension, and size rules.
- Use `sanitize()` before displaying user-controlled values in PHP-rendered HTML.
- Use `recordLog()` or `recordLogSystem()` for meaningful user/admin/system actions.
- Approval-chain comparisons should use `normalizeApprover()` instead of raw lowercase string comparisons.
- Frontend styling uses Tailwind CDN classes configured in `templates/header.php`; use the existing maroon theme and Font Awesome icons.
- User-facing JS feedback should use the global `showToast(message, type)` helper from `templates/footer.php`.
- Avoid broad refactors unless they are required for the requested change.
- The `autopost/` directory is a standalone tool and should be treated separately from the main LK UKMs app.

## Proposal & LPJ PDF Notes

- Proposal and LPJ records share the `proposal` table and are distinguished by the `jenis` field (`Proposal` or `LPJ`).
- Proposal approval sheets are generated on demand by `api/proposal.php?action=generateLembarPengesahan&id=...`.
- LPJ approval sheets are generated on demand by `api/proposal.php?action=generateLembarPengesahanLPJ&id=...`.
- Both approval-sheet endpoints stream TCPDF output directly to the browser and must not call `jsonResponse()` on success.
- Approval-sheet access is allowed for `Super Admin`, username `ketua-dpm`, or the document owner/pengaju.
- Proposal approval sheets require `jenis != LPJ` and `status = Disetujui`.
- LPJ approval sheets require `jenis = LPJ` and `status = Disetujui`.
- Frontend action visibility lives in `pages/proposal.php`: use `canGenerateLembar()` for proposals and `canGenerateLembarLPJ()` for LPJ.
- LPJ approval sheets include source proposal data from `parent_proposal_id` when available.

## Useful Local Checks

- PHP syntax: `rtk php -l path/to/file.php`
- Dependency install/update: `rtk composer install`
- WhatsApp test: `rtk php test_wa.php`
- Project utility scripts: `rtk php scripts/check_alur.php`, `rtk php scripts/check_detail.php`
