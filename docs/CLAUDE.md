# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**LK UKMs** - Sistem Proposal & LPJ LK UKMs is a native PHP application for managing proposals and accountability reports (LPJ) for student organizations (UKM). It was converted from a Google Apps Script implementation.

## Architecture

This is a **native PHP application** (no framework) with the following structure:

- **Entry Point**: `index.php` - Routes requests to API endpoints or page views
- **API Layer**: `api/*.php` - AJAX endpoints for data operations
- **Page Layer**: `pages/*.php` - View templates (loaded by index.php)
- **Templates**: `templates/header.php`, `templates/sidebar.php`, `templates/footer.php` - Shared layout; each page file includes them
- **Modals**: `modals/surat.php` - Modal dialogs for surat, included by `pages/surat_masuk.php`
- **Core Functions**: `includes/functions.php` and `includes/security.php`
- **Email**: `includes/email.php` - PHPMailer-based email sending (Gmail SMTP)
- **Configuration**: `config/database.php` - DB credentials, connection, session start, and timezone
- **Uploads**: `uploads/` - User files stored in `{category}_{username}/` subdirectories

### Request Routing

URL routing is handled in `index.php` via pretty URLs or `?page=` / `?request=` query params:
- Pretty URL `/dashboard` or `?page=dashboard` → loads `pages/dashboard.php`
- Pretty URL `/api/auth` or `?request=api/auth` → loads `api/auth.php`

API routes registered in `index.php`: `api/auth`, `api/users`, `api/surat`, `api/proposal`, `api/alur`, `api/pengumuman`, `api/arsip`, `api/laporan`, `api/penggunaan_ruangan`. Direct HTTP access to `api/*.php` is blocked by `.htaccess`; use pretty URLs (`/api/users`, etc.). WhatsApp test: `php test_wa.php` (CLI), not a public HTTP endpoint.

Valid page routes: `dashboard`, `surat_masuk`, `proposal`, `users`, `profil`, `monitoring`, `alur`, `system_settings`, `pengumuman`, `activity_logs`, `login`. (`surat_keluar` redirects to `surat_masuk`.) Note: `pages/arsip.php` exists but `arsip` is not in the `$validPages` array in `index.php`.

### Database

- **MySQL/MariaDB** with UTF-8 (utf8mb4)
- Uses `getDBConnection()` from `config/database.php` - returns mysqli connection with static singleton pattern
- **All queries use prepared statements** - never concatenate SQL directly
- **Schema reference**: `config/schema.sql` is the authoritative table definitions. Tables: `users`, `activity_logs`, `surat_masuk`, `surat_keluar`, `arsip`, `pengumuman`, `proposal`, `alur`, `system_config`.
- **`surat_keluar`**: has its own DB table but shares `pages/surat_masuk.php` and `api/surat.php` — there is no separate surat_keluar page or API file.

### Security Model

- **Session-based authentication** with CSRF tokens required for all POST requests
- **Role-based access control**: `Super Admin`, `Admin`, `User`, `Approver`, `Disposisi`, `Read Only`
  - `Approver` — approves proposals and can access targeted disposisi; does not access penggunaan ruangan
  - `Disposisi` — restricted to `surat_masuk`, `dashboard`, and `profil`
  - `Read Only` — restricted to `surat_masuk`, `proposal`, `dashboard`, and `profil`
- **Enforcing roles in API handlers**: call `requireRole()` from `includes/security.php` at the top of each action handler — accepts a single role string or array of allowed roles:
  ```php
  requireRole(['Admin', 'Super Admin']); // array = any of these roles is allowed
  requireRole('Super Admin');            // string = exact match only
  ```
- **Password handling**: bcrypt hashes with fallback to legacy plaintext (auto-upgrades on login)
- **Input sanitization**: Use `sanitize()` from `includes/functions.php` before displaying output
- **CSRF tokens**: Get via `action=getCsrfToken`, include in all POST requests as `csrf_token`

### System Configuration

Feature toggles are stored in the `system_config` table (keys: `OPEN_SURAT`, `SYSTEM_NAME`, `SYSTEM_DESC`). Access via `getSystemConfig()` / `saveSystemConfig()` in `includes/functions.php`. `getSystemConfig()` returns `['surat' => bool, 'system_name' => string, 'system_desc' => string, ...]`. Use the cached helpers `getSystemName()` and `getSystemDescription()` when only reading those values.

## Key Patterns

### API Response Format

All APIs return JSON with this structure:
```php
jsonResponse(['success' => true, 'message' => '...', 'data' => [...]]);
```

### Database Operations

```php
$conn = getDBConnection();
$stmt = $conn->prepare("SELECT * FROM users WHERE id = ?");
$stmt->bind_param("i", $id);
$stmt->execute();
$result = $stmt->get_result();
$row = $result->fetch_assoc();
$stmt->close();
```

### File Uploads

Base64-encoded uploads via `uploadFileSmart()` (basic) or `uploadFileSecure()` (validated):
```php
$filePath = uploadFileSecure($base64Data, $fileName, $username, 'category', [
    'mimes' => ['application/pdf'],
    'extensions' => ['pdf'],
    'max_size_mb' => 10
]);
```

### Activity Logging

Two helpers in `includes/functions.php`:
- `recordLog($user, $activity)` — logs an action by a specific user (pass the `$_SESSION['user']` array)
- `recordLogSystem($activity)` — logs a system/automated event using the current session user; use this when no explicit `$user` variable is in scope

### PDF Generation

`generateLembarPengesahan()` in `api/proposal.php` and `generatePengesahanSurat()` in `api/surat.php` output PDFs directly via TCPDF — they do **not** call `jsonResponse()`. They set `Content-Type: application/pdf` and stream binary output. TCPDF class is loaded as either `\TCPDF\TCPDF` or `\TCPDF` depending on Composer version.

### Approval Chain System

Proposals use a dynamic approval chain stored in the `alur` table:
- Each `pengaju` has up to 6 approvers (acc1-acc6)
- `getApprovalChain($pengaju)` returns the ordered chain; `findApproverUsers($approver)` resolves approver by trying username → role → name (first match wins)
- Proposal `current_approver` tracks who must approve next
- History stored as JSON in `proposal.history`
- **Approver identity normalization**: `normalizeApprover(string $s)` in `includes/functions.php` treats spaces and underscores as equivalent (`'bem ftii' == 'bem_ftii'`). Use it whenever comparing any `acc*` / `current_approver` value against a username — do not use bare `strtolower()` for these comparisons.

### Frontend Stack

Pages use a shared layout: `templates/header.php` → `templates/sidebar.php` → page content → `templates/footer.php`. Each page file includes them directly (not via output buffering).

- **CSS**: Tailwind CSS loaded from CDN with a custom maroon color theme. Primary color is `#8B1538`; use the `primary`, `primary-dark`, `primary-light`, and `maroon-*` utility classes defined in `tailwind.config` inside `templates/header.php`.
- **Icons**: Font Awesome 6.4 via CDN (`fas`, `far`, `fab` prefixes).
- **Charts**: Chart.js via CDN, used on `pages/dashboard.php` and `pages/monitoring.php`.
- **CSRF in JS**: `window.csrfToken` is set by `header.php` on every page load. All JS `fetch` POST calls should pass `csrf_token: window.csrfToken` — never fetch a new token from the API mid-page.
- **Toast notifications**: `showToast(message, type)` is a global JS helper defined in `templates/footer.php`. Use it for all user-facing feedback in page scripts.

## Development Commands

### Installation

1. Run `composer install` to install dependencies (TCPDF, QR code, PHPMailer)
2. Navigate to `/install.php` in browser to create database and tables
3. Default login: `superadmin` / `admin123`

### Testing

PowerShell smoke test (Windows/XAMPP):
```powershell
powershell -ExecutionPolicy Bypass -File smoke_test.ps1
```

Utility scripts in `scripts/` for one-off tasks: `check_alur.php`, `check_user.php`, `ensure_superadmin.php`, `import_google_csv.php`

Quick WhatsApp send test (run via CLI or browser):
```bash
php test_wa.php
```

The `autopost/` directory contains a standalone content auto-posting tool (separate from the main app).

### Running Locally

- Place in `C:\xampp\htdocs\lkv2\` (or adjust RewriteBase in .htaccess)
- Requires Apache with mod_rewrite enabled
- Requires MySQL/MariaDB
- Configure DB credentials in `config/database.php`

## Dependencies

Managed via Composer (`composer.json`):
- `tecnickcom/tcpdf: ^6.10` - PDF generation
- `endroid/qr-code: ^6.0` - QR code generation
- `phpmailer/phpmailer: ^6.9` - Email via SMTP (configured for Gmail in `includes/email.php`)

## Important Notes

- **Timezone**: Set to Asia/Jakarta in `config/database.php`
- **Legacy passwords**: System auto-upgrades plaintext passwords to bcrypt hashes on login. The upgrade also sets `force_change = 1` on the user row, prompting a password change on next login.
- **WhatsApp notifications**: Calls `https://wa.dwibudi.my.id/instances/{instanceId}/messages` via cURL; instance ID is hardcoded in `sendWhatsAppNotification()` in `includes/functions.php`
- **Session role**: Always use server-side role from session, never trust client-provided role
- **File uploads**: Stored in `uploads/{category}_{username}/` with `uniqid()` prefix to prevent overwrites
- **`sebutan` field**: Users have a `sebutan` column (Bapak/Ibu) used for notification salutations. `getSebutan($name, $preferredSebutan)` in `includes/functions.php` derives it from the stored value or falls back to name heuristics.
- **`display_errors = 1`**: Both `index.php` and `config/database.php` enable error display — disable for production deployments
