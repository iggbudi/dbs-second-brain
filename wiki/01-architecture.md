# Architecture - LK UKMs

## Model Aplikasi

LK UKMs adalah aplikasi **PHP native tanpa framework**.

Tidak ada controller framework; request diarahkan oleh `index.php` ke file API atau page.

## Layer

```text
Browser
  ↓
index.php
  ├─ api/*.php      JSON/PDF/binary endpoint
  └─ pages/*.php    server-rendered pages
        ↓
templates/header.php + sidebar.php + footer.php
        ↓
includes/functions.php / includes/security.php / includes/email.php
        ↓
config/database.php → getDBConnection() → MySQL/MariaDB
```

## Routing

`index.php` membaca URI:

- `/dashboard` → `pages/dashboard.php`
- `/proposal` → `pages/proposal.php`
- `/api/proposal` → `api/proposal.php`
- fallback query: `?page=...` atau `?request=...` pada beberapa pola lama

Jika user belum login dan bukan `login`, diarahkan ke `/login`.

## API Layer

API endpoint berada di `api/*.php` dan umumnya memakai parameter `action`.

Pola umum:

```php
require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../includes/functions.php';
require_once __DIR__ . '/../includes/security.php';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    requireCsrfToken();
}

$conn = getDBConnection();
$stmt = $conn->prepare('SELECT ... WHERE id = ?');
$stmt->bind_param('i', $id);
$stmt->execute();
jsonResponse(['success' => true, 'data' => $data]);
```

PDF/binary endpoints stream output langsung dan tidak `jsonResponse()` pada success.

## Page Layer

Page berada di `pages/*.php` dan biasanya include:

```php
require_once ROOT_PATH . '/templates/header.php';
require_once ROOT_PATH . '/templates/sidebar.php';
// content
require_once ROOT_PATH . '/templates/footer.php';
```

Catatan: `templates/header.php` juga memuat Tailwind config, Font Awesome, dan `window.csrfToken`.

## Helper Layer

- `includes/functions.php`: `sanitize()`, `jsonResponse()`, upload, log, approval chain, system config, dashboard stats, PDF text extraction.
- `includes/security.php`: CSRF, password hashing/legacy upgrade, `requireRole()`, upload validation, secure logging.
- `includes/email.php`: SMTP config dan template email.
- `includes/env.php`: loader `.env` sederhana untuk integrasi AI.

## DB Access

Semua akses DB harus lewat:

```php
$conn = getDBConnection();
```

Jangan membuat koneksi DB baru di luar `config/database.php`.

## Prinsip Perubahan

- Ikuti pola PHP native existing.
- Jangan menambah framework/runtime.
- Hindari broad refactor.
- Guard server-side wajib di API/page sensitif.
- Update wiki jika ada pola permanen baru.
