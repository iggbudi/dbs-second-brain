# Frontend Patterns - LK UKMs

## Stack

- Tailwind CSS via CDN.
- Font Awesome 6.4.
- Chart.js untuk dashboard/monitoring.
- Vanilla JavaScript + fetch.

## Layout

Page umum:

```php
require_once ROOT_PATH . '/templates/header.php';
require_once ROOT_PATH . '/templates/sidebar.php';
?>
<!-- content -->
<?php require_once ROOT_PATH . '/templates/footer.php'; ?>
```

## Tailwind Theme

Konfigurasi ada di `templates/header.php`.

Gunakan utility warna:

```text
primary
primary-dark
primary-light
maroon-*
```

Primary color: `#8B1538`.

## Icons

Gunakan Font Awesome:

```html
<i class="fas fa-file-pdf"></i>
<i class="far fa-clock"></i>
<i class="fab fa-whatsapp"></i>
```

## CSRF di JavaScript

`templates/header.php` mengisi:

```js
window.csrfToken = '...';
```

POST fetch:

```js
const formData = new FormData();
formData.append('action', 'someAction');
formData.append('csrf_token', window.csrfToken);

const response = await fetch('api/example.php', {
  method: 'POST',
  body: formData
});
```

## Toast

Gunakan helper global dari `templates/footer.php`:

```js
showToast('Berhasil disimpan');
showToast('Gagal menyimpan', 'error');
```

Jangan membuat sistem toast baru tanpa kebutuhan.

## Code Block Copy

Untuk tampilan `<pre><code>...</code></pre>` yang berisi teks/log/kode, sediakan tombol kecil ikon copy di kanan atas block. Pola ini dipakai pada:

- `pages/arsip_proposal.php` untuk fenced code block hasil analisis AI.
- `pages/monitoring.php` untuk code block/log activity stream.

Catatan implementasi:

- Konten code block tetap harus di-escape sebelum dirender.
- Teks yang disalin diambil dari `code.textContent`, bukan HTML.
- Feedback copy sukses/gagal gunakan `showToast()` jika tersedia.
- Helper/enhancer harus idempotent agar tombol tidak dobel saat konten dinamis di-render ulang.

## API Fetch Pattern

GET:

```js
const response = await fetch('api/proposal.php?action=getProposals');
const result = await response.json();
```

POST:

```js
const formData = new FormData(form);
formData.append('action', 'addProposal');
formData.append('csrf_token', window.csrfToken);
const response = await fetch('api/proposal.php', { method: 'POST', body: formData });
const result = await response.json();
```

## Response Handling

Cek `result.success` dan tampilkan message:

```js
if (result.success) {
  showToast(result.message || 'Berhasil');
} else {
  showToast(result.message || 'Gagal', 'error');
}
```

## UI Component Pattern

Gunakan pola existing:
- Card putih dengan rounded/shadow/border halus.
- Tombol primary maroon.
- Table responsive.
- Modal existing untuk form/detail.
- State kosong yang informatif.
- Loading indicator saat fetch panjang.

## Dashboard Pattern

`pages/dashboard.php` memakai pola role-based dashboard:

- Data utama berasal dari endpoint agregat `api/users.php?action=getDashboardStats`.
- Jangan fetch dataset besar hanya untuk menghitung statistik di browser.
- Letakkan section **Butuh Tindakan** sebelum ringkasan statistik.
- Quick actions harus mengikuti role dan permission UI.
- Statistik/card boleh clickable ke halaman terkait, tetapi API target tetap harus guard server-side.
- Loading awal memakai skeleton.
- Error fetch harus menampilkan error card + tombol retry dan boleh memanggil `showToast(..., 'error')`.
- Empty state harus informatif dan action-nya mengikuti permission.
- Data dinamis dari API seperti pengumuman/activity harus dirender dengan DOM API/`textContent` atau escape helper JS, bukan `innerHTML` mentah.
- Tambahkan `aria-label`, focus ring, dan dukungan `prefers-reduced-motion` untuk elemen interaktif.


## API Error Display

`templates/footer.php` menyediakan helper `formatApiError()` untuk pesan error API. Untuk error submit/revise proposal yang membawa `request_id`, helper menambahkan `Kode laporan: <request_id>` sehingga user dapat melaporkan kode korelasi tanpa detail teknis internal.

## Activity Logs UI

`pages/activity_logs.php` adalah halaman admin untuk observability minimal:
- Akses halaman dan API dibatasi untuk `Admin`/`Super Admin`.
- Filter tersedia untuk user, action, `category`, dan `level`; search mencakup aktivitas/user/`request_id`/detail.
- `request_id` ditampilkan dan dapat dicari agar cocok dengan `Kode laporan` dari error API.
- Tabel memakai pagination client-side atas dataset endpoint existing: default 10 baris per halaman, opsi page size 10/25/50/100, info rentang data, serta Previous/Next. Perubahan search/filter reset ke halaman 1; refresh menjaga page size aktif selama masih valid.
- Rendering data log harus escaped/aman; jangan render payload `aktivitas`/context sebagai HTML mentah.
- Field terstruktur (`event`, `request_id`, `category`, `level`, `detail`/`context`) bersifat turunan dari JSON legacy di `aktivitas`; tetap handle log lama yang tidak structured.

## Accessibility Dasar

- Label form jelas.
- Button punya title/aria-label bila hanya icon.
- Warna error/success tidak jadi satu-satunya indikator.
- Modal bisa ditutup dan tidak mengunci UI saat error.

## QA Frontend

Saat mengubah JS/page:
- Pastikan POST mengirim CSRF.
- Pastikan error fetch ditangani.
- Pastikan `showToast()` dipakai untuk feedback.
- Pastikan action button hanya visibility UI; API tetap guard server-side.
