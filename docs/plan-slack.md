# Plan MVP Integrasi Slack → Pi Assistant via Pi SDK

## Keputusan Teknis

MVP ini menggunakan **Pi SDK**, bukan `pi -p`/CLI print mode.

Alasan:

1. Lebih mudah mengontrol tools per mode, misalnya read-only vs write.
2. Bisa streaming dan menangkap event agent secara programmatic.
3. Bisa memakai `cwd` fixed ke project LK UKMs.
4. Bisa memakai `SessionManager.inMemory()` untuk task sekali jalan.
5. Lebih siap dikembangkan ke session per Slack thread.

---

## Tujuan MVP

User yang diizinkan dapat menjalankan instruksi ke Pi Assistant dari Slack memakai slash command:

```text
/pi cek modul proposal
/pi cari input anggaran di codebase
/pi review file api/proposal.php
```

Bot membalas hasilnya ke Slack.

---

## Scope MVP

### Masuk MVP

1. Slash command Slack `/pi`.
2. Node.js bridge service.
3. Verifikasi Slack signature.
4. Allowlist Slack user.
5. Eksekusi prompt memakai Pi SDK.
6. Default mode read-only.
7. Write mode opsional dengan flag eksplisit `--write`.
8. Balasan hasil ke Slack via `response_url`.
9. Logging sederhana JSONL.
10. Timeout task.
11. Concurrency limit 1 task.
12. Working directory fixed ke:

```text
/var/www/lk.pjdigital.top
```

### Tidak Masuk MVP

1. Conversation thread multi-turn penuh.
2. Approval button interaktif.
3. Auto-deploy.
4. Scheduling task.
5. Multi-project routing.
6. Dashboard monitoring.

---

## Arsitektur MVP

```text
Slack Slash Command /pi
        ↓
Node.js Express Endpoint
        ↓
Verifikasi Slack Signature
        ↓
Cek Allowlist User
        ↓
Job Runner Async
        ↓
Pi SDK createAgentSession()
        ↓
Streaming event dikumpulkan
        ↓
Response dikirim ke Slack response_url
```

---

## Struktur Direktori Usulan

```text
slack-pi-bridge/
  package.json
  tsconfig.json
  .env
  src/
    server.ts
    slack.ts
    pi-runner.ts
    logger.ts
    config.ts
  logs/
    jobs.log
```

Bisa juga dibuat JavaScript biasa, tetapi TypeScript lebih cocok karena Pi SDK menyediakan typing.

---

## Dependency Awal

```bash
npm install express dotenv @earendil-works/pi-coding-agent
npm install -D typescript tsx @types/express @types/node
```

Opsional untuk HTTP callback ke Slack:

```bash
npm install undici
```

---

## Environment Variables

```env
PORT=3030
SLACK_SIGNING_SECRET=xxx
SLACK_ALLOWED_USERS=U12345,U67890
PROJECT_DIR=/var/www/lk.pjdigital.top
PI_TIMEOUT_MS=600000
MAX_OUTPUT_CHARS=12000
NODE_ENV=production
```

Jika memakai API key model via environment:

```env
ANTHROPIC_API_KEY=xxx
# atau provider lain sesuai konfigurasi Pi
```

---

## Alur Request

1. User menjalankan command:

```text
/pi cari input anggaran di codebase
```

2. Slack mengirim POST request ke endpoint:

```text
POST /slack/pi
```

3. Endpoint melakukan validasi:
   - `X-Slack-Signature`
   - `X-Slack-Request-Timestamp`
   - `user_id` ada di allowlist
   - command tidak kosong

4. Endpoint langsung membalas dalam < 3 detik:

```text
✅ Task diterima. Sedang diproses...
```

5. Runner menjalankan Pi SDK secara async.

6. Setelah selesai, hasil dikirim ke `response_url` Slack.

---

## Mode Eksekusi

### 1. Default Read-only Mode

Mode default tidak boleh mengubah file.

Tools SDK yang diaktifkan:

```ts
tools: ["read", "grep", "find", "ls"]
```

Prompt guard:

```text
Jalankan dalam mode read-only. Jangan mengubah file. Jika user meminta perubahan kode, buat rencana dan jelaskan file yang perlu diubah.
```

Contoh command:

```text
/pi cari input anggaran di codebase
/pi jelaskan alur approval proposal
/pi review risiko api/proposal.php
```

### 2. Write Mode Opsional

Write mode hanya aktif jika command memakai flag:

```text
/pi --write ubah validasi input anggaran agar angka saja
```

Tools SDK yang diaktifkan:

```ts
tools: ["read", "bash", "grep", "find", "ls", "edit", "write"]
```

Prompt guard:

```text
Boleh mengubah file hanya sesuai instruksi user. Setelah selesai, laporkan file yang berubah dan pengecekan yang dijalankan.
```

Untuk MVP, `--write` sebaiknya hanya diberikan ke user sangat terbatas.

---

## Pi SDK Runner

Runner menggunakan `createAgentSession()`.

Konsep implementasi:

```ts
import {
  AuthStorage,
  createAgentSession,
  DefaultResourceLoader,
  ModelRegistry,
  SessionManager,
  SettingsManager,
} from "@earendil-works/pi-coding-agent";

export async function runPiTask(input: {
  prompt: string;
  userId: string;
  mode: "read-only" | "write";
  projectDir: string;
  timeoutMs: number;
}) {
  const authStorage = AuthStorage.create();
  const modelRegistry = ModelRegistry.create(authStorage);

  const systemPrompt = buildSystemPrompt(input.mode, input.userId, input.projectDir);

  const loader = new DefaultResourceLoader({
    cwd: input.projectDir,
    systemPromptOverride: (base) => `${base}\n\n${systemPrompt}`,
  });
  await loader.reload();

  const tools = input.mode === "write"
    ? ["read", "bash", "grep", "find", "ls", "edit", "write"]
    : ["read", "grep", "find", "ls"];

  const { session } = await createAgentSession({
    cwd: input.projectDir,
    authStorage,
    modelRegistry,
    resourceLoader: loader,
    sessionManager: SessionManager.inMemory(input.projectDir),
    settingsManager: SettingsManager.inMemory({
      compaction: { enabled: false },
      retry: { enabled: true, maxRetries: 1 },
    }),
    tools,
  });

  let output = "";

  const unsubscribe = session.subscribe((event) => {
    if (
      event.type === "message_update" &&
      event.assistantMessageEvent.type === "text_delta"
    ) {
      output += event.assistantMessageEvent.delta;
    }
  });

  try {
    await withTimeout(
      session.prompt(input.prompt),
      input.timeoutMs
    );
    return output.trim();
  } finally {
    unsubscribe();
    session.dispose();
  }
}
```

Catatan:

- `SessionManager.inMemory()` dipakai agar setiap slash command menjadi task terpisah.
- Untuk versi lanjut, session bisa dibuat persistent per Slack thread.
- `DefaultResourceLoader` tetap memakai context project seperti `AGENTS.md` dari `cwd`.

---

## Prompt Builder

### Read-only

```text
Kamu dipanggil dari Slack oleh <USER_ID>.
Mode: read-only.
Project: /var/www/lk.pjdigital.top.

Aturan:
- Jangan mengubah file.
- Jangan menjalankan command yang mengubah state.
- Jika user meminta edit, buat rencana perubahan saja.
- Jawab ringkas.
- Sertakan path file relevan.
```

### Write

```text
Kamu dipanggil dari Slack oleh <USER_ID>.
Mode: write allowed.
Project: /var/www/lk.pjdigital.top.

Aturan:
- Boleh mengubah file hanya sesuai instruksi user.
- Hindari refactor luas.
- Ikuti AGENTS.md/CLAUDE.md project.
- Jalankan pengecekan relevan jika memungkinkan.
- Laporkan file yang berubah dan hasil pengecekan.
```

---

## Endpoint Slack

Endpoint utama:

```text
POST /slack/pi
```

Pseudo-flow:

```ts
app.post("/slack/pi", rawBodyMiddleware, async (req, res) => {
  verifySlackSignature(req);

  const userId = req.body.user_id;
  const text = req.body.text.trim();
  const responseUrl = req.body.response_url;

  if (!isAllowedUser(userId)) {
    return res.status(200).send("⛔ Kamu belum diizinkan menggunakan bot ini.");
  }

  if (!text) {
    return res.status(200).send("Kirim instruksi setelah /pi.");
  }

  if (isTaskRunning()) {
    return res.status(200).send("Masih ada task yang berjalan. Coba lagi sebentar.");
  }

  res.status(200).send(`✅ Task diterima: ${text}\nSedang diproses...`);

  runJobAsync({ userId, text, responseUrl });
});
```

---

## Verifikasi Slack Signature

Wajib validasi:

- `X-Slack-Signature`
- `X-Slack-Request-Timestamp`

Base string:

```text
v0:<timestamp>:<raw_body>
```

Signature:

```text
v0=<hmac_sha256(base_string, SLACK_SIGNING_SECRET)>
```

Reject jika:

1. Timestamp lebih dari 5 menit.
2. Signature tidak cocok.

---

## Parsing Command

Aturan sederhana:

```text
/pi <prompt>              -> read-only
/pi --write <prompt>      -> write
```

Contoh parser:

```ts
function parseCommand(text: string) {
  const trimmed = text.trim();
  if (trimmed.startsWith("--write ")) {
    return {
      mode: "write" as const,
      prompt: trimmed.replace(/^--write\s+/, ""),
    };
  }
  return {
    mode: "read-only" as const,
    prompt: trimmed,
  };
}
```

---

## Response Slack

### Diterima

```text
✅ Task diterima: cari input anggaran di codebase
Sedang diproses...
```

### Sukses

```text
✅ Selesai

Ringkasan:
<hasil dari Pi>
```

### Timeout

```text
⏱️ Task dihentikan karena melewati batas waktu.
```

### Error

```text
❌ Gagal menjalankan task
Error: <pesan error>
```

### Tidak Diizinkan

```text
⛔ Kamu belum diizinkan menggunakan bot ini.
```

---

## Output Limit

Slack output dibatasi oleh `MAX_OUTPUT_CHARS`.

Jika output terlalu panjang:

```text
<output dipotong>

...output terlalu panjang, lihat log server untuk detail lengkap.
```

MVP tidak perlu upload file log ke Slack.

---

## Logging

Simpan JSONL ke:

```text
slack-pi-bridge/logs/jobs.log
```

Format:

```json
{"time":"2026-06-24T10:00:00+07:00","user_id":"U12345","mode":"read-only","command":"cari input anggaran","status":"success","duration_ms":25000}
```

Jangan log:

- Slack signing secret
- API key model
- token OAuth
- raw secret lain

---

## Security Minimum

1. Verifikasi Slack signature.
2. Allowlist Slack user.
3. Working directory fixed.
4. Timeout 10 menit.
5. Concurrency limit 1 task.
6. Default read-only tools.
7. `--write` hanya untuk allowlist khusus jika perlu.
8. Jangan expose endpoint tanpa HTTPS.
9. Jangan commit `.env`.

---

## Deployment MVP

### Opsi Process Manager

Gunakan PM2:

```bash
pm2 start "npm run start" --name slack-pi-bridge
pm2 save
```

Atau systemd jika ingin native service.

### Reverse Proxy

Expose endpoint HTTPS:

```text
https://domain-kamu/slack/pi
```

Proxy ke:

```text
http://127.0.0.1:3030/slack/pi
```

---

## Rencana Sprint MVP

Estimasi sprint bisa dibuat pendek, misalnya 1–3 hari per sprint tergantung ketersediaan. Fokus utama MVP adalah membuat jalur `/pi` read-only stabil terlebih dahulu, lalu membuka write mode secara terbatas.

**Endpoint final MVP:**

```text
https://bot.pjdigital.top/slack/pi
```

**Virtual host document root:**

```text
/var/www/bot.pjdigital.top/
```

---

### Sprint 0 — Persiapan Slack App dan Environment

**Status:** selesai.

**Tujuan:** menyiapkan akses, secret, dan konfigurasi dasar sebelum coding.

**Task:**

1. Buat Slack App.
2. Aktifkan Slash Commands.
3. Buat command `/pi`.
4. Set Request URL sementara/final:

```text
https://domain-kamu/slack/pi
```

5. Ambil dan simpan `Slack Signing Secret`.
6. Tentukan Slack user ID yang masuk allowlist.
7. Siapkan environment variable:

```env
SLACK_SIGNING_SECRET=xxx
SLACK_ALLOWED_USERS=U12345,U67890
PROJECT_DIR=/var/www/lk.pjdigital.top
```

**Deliverable:**

- Slack App tersedia.
- Slash command `/pi` tersedia.
- Secret dan allowlist siap dipakai.
- Endpoint final menggunakan `https://bot.pjdigital.top/slack/pi`.
- Virtual host document root tersedia di `/var/www/bot.pjdigital.top/`.

**Acceptance Criteria:**

- Slash command `/pi` bisa diarahkan ke endpoint target.
- Signing secret sudah tersimpan aman di `.env` server.
- Endpoint final sudah ditentukan.

---

### Sprint 1 — Bridge Service Skeleton + Security Dasar

**Status:** selesai.

**Tujuan:** membuat service Node.js/TypeScript yang bisa menerima request Slack dengan aman.

**Task:**

1. Buat folder `slack-pi-bridge`.
2. Setup `package.json`, `tsconfig.json`, dan script dev/start.
3. Install dependency:

```bash
npm install express dotenv @earendil-works/pi-coding-agent undici
npm install -D typescript tsx @types/express @types/node
```

4. Buat `src/config.ts` untuk membaca env.
5. Buat `src/server.ts` dengan Express endpoint:

```text
POST /slack/pi
```

6. Implement raw body middleware untuk validasi Slack signature.
7. Implement `verifySlackSignature()`.
8. Implement allowlist user.
9. Tambahkan response dasar untuk `/pi ping` tanpa Pi SDK dulu.

**Deliverable:**

- Service bisa menerima Slack request.
- Request invalid ditolak.
- User tidak diizinkan ditolak.
- `/pi ping` membalas dari bridge.
- Implementasi tersedia di `/var/www/bot.pjdigital.top/`.

**Acceptance Criteria:**

1. Signature invalid mendapat HTTP 401/403.
2. User di luar allowlist mendapat pesan penolakan.
3. `/pi ping` dari user allowlist mendapat balasan sukses.
4. Service bisa dijalankan lokal/server dengan `npm run dev` atau `npm run start`.

---

### Sprint 2 — Pi SDK Runner Read-only

**Status:** selesai.

**Tujuan:** menghubungkan bridge ke Pi SDK dalam mode aman/read-only.

**Task:**

1. Buat `src/pi-runner.ts`.
2. Implement `runPiTask()` dengan `createAgentSession()`.
3. Set `cwd` ke `PROJECT_DIR`.
4. Gunakan `SessionManager.inMemory()`.
5. Gunakan tools read-only:

```ts
tools: ["read", "grep", "find", "ls"]
```

6. Tambahkan `DefaultResourceLoader` agar context project seperti `AGENTS.md` tetap dibaca.
7. Tambahkan system prompt guard read-only.
8. Subscribe event `message_update` / `text_delta` untuk mengumpulkan output.
9. Dispose session setelah task selesai.

**Deliverable:**

- `/pi <prompt>` menjalankan Pi SDK read-only.
- Hasil dikirim balik ke Slack.
- Runner tersedia di `/var/www/bot.pjdigital.top/src/pi-runner.ts`.
- Tools default dibatasi ke `read`, `grep`, `find`, dan `ls`.

**Acceptance Criteria:**

1. `/pi cari input anggaran di codebase` menghasilkan jawaban relevan.
2. Agent tidak punya tool `edit` dan `write` pada default mode.
3. Jika user meminta edit tanpa `--write`, agent hanya membuat rencana.
4. Session tidak disimpan permanen untuk MVP awal.

---

### Sprint 3 — Async Job, Timeout, Logging, dan Output Limit

**Status:** selesai.

**Tujuan:** membuat eksekusi stabil untuk dipakai internal.

**Task:**

1. Endpoint Slack membalas cepat dalam < 3 detik.
2. Task Pi berjalan async setelah initial response.
3. Hasil dikirim ke Slack via `response_url`.
4. Implement timeout, default:

```text
10 menit
```

5. Implement concurrency lock:

```text
1 task aktif dalam satu waktu
```

6. Implement output truncation sesuai `MAX_OUTPUT_CHARS`.
7. Buat `src/logger.ts` untuk JSONL log.
8. Simpan log ke:

```text
slack-pi-bridge/logs/jobs.log
```

9. Log minimal: time, user_id, mode, command, status, duration_ms.

**Deliverable:**

- Task long-running tidak menggantung selamanya.
- Task overlap ditolak sementara.
- Semua task tercatat di log.
- Async job runner tersedia di `/var/www/bot.pjdigital.top/src/job-runner.ts`.
- Endpoint Slack membalas cepat dengan pesan task diterima, lalu hasil dikirim ke `response_url`.

**Acceptance Criteria:**

1. Jika task melewati timeout, Slack mendapat pesan timeout.
2. Jika ada task berjalan, command baru mendapat pesan “masih ada task berjalan”.
3. Output panjang dipotong dengan pesan yang jelas.
4. Log JSONL tercatat untuk success, error, timeout, dan denied.

---

### Sprint 4 — Write Mode Terbatas

**Tujuan:** membuka kemampuan edit kode secara eksplisit dan terkendali.

**Task:**

1. Implement parser command:

```text
/pi <prompt>         -> read-only
/pi --write <prompt> -> write
```

2. Tambahkan allowlist khusus write jika diperlukan:

```env
SLACK_WRITE_ALLOWED_USERS=U12345
```

3. Untuk write mode, aktifkan tools:

```ts
tools: ["read", "bash", "grep", "find", "ls", "edit", "write"]
```

4. Tambahkan system prompt guard write mode.
5. Pastikan hasil akhir menyebut:
   - file yang berubah
   - ringkasan perubahan
   - pengecekan yang dijalankan
6. Tambahkan logging mode `write`.

**Deliverable:**

- `/pi --write ...` bisa melakukan perubahan kode terbatas.
- Hanya user write-allowed yang bisa memakai `--write`.

**Acceptance Criteria:**

1. User biasa tidak bisa menjalankan `--write`.
2. User write-allowed bisa menjalankan perubahan kecil.
3. Agent melaporkan file yang berubah.
4. Agent menjalankan check relevan jika memungkinkan, misalnya `rtk php -l file.php` untuk PHP.

---

### Sprint 5 — Deployment Internal dan Hardening MVP

**Tujuan:** menjalankan service secara stabil di server internal/production-like.

**Task:**

1. Deploy service dengan PM2 atau systemd.
2. Pasang reverse proxy HTTPS ke endpoint:

```text
https://domain-kamu/slack/pi
```

3. Pastikan endpoint hanya expose route yang diperlukan.
4. Test command utama:

```text
/pi ping
/pi cari input anggaran di codebase
/pi jelaskan alur approval proposal
```

5. Test skenario error:
   - signature invalid
   - user tidak diizinkan
   - command kosong
   - timeout
   - concurrent task
6. Review log agar tidak ada secret bocor.
7. Dokumentasikan cara restart service dan lokasi log.

**Deliverable:**

- MVP siap dipakai internal dari Slack.
- Runbook pendek tersedia.

**Acceptance Criteria:**

1. Slash command bisa dipakai dari Slack workspace.
2. Semua acceptance criteria MVP terpenuhi.
3. Secret tidak masuk log/repository.
4. Service bisa restart otomatis setelah server reboot.

---

## Prioritas Release

### Release MVP-1: Read-only Slack Assistant

Berisi Sprint 0–3.

Fitur:

- `/pi <prompt>`
- Pi SDK read-only
- Slack signature verification
- allowlist
- async response
- timeout
- logging

Ini adalah release pertama yang disarankan untuk dipakai harian.

### Release MVP-2: Controlled Write Mode

Berisi Sprint 4–5.

Fitur tambahan:

- `/pi --write <prompt>`
- write allowlist
- edit/write tools
- deployment hardening

---

## Acceptance Criteria MVP

MVP selesai jika:

1. `/pi ping` mendapat response dari bot.
2. User tidak di allowlist ditolak.
3. Signature invalid ditolak.
4. `/pi cari input anggaran di codebase` menghasilkan jawaban relevan.
5. Default mode tidak bisa edit file karena tools read-only.
6. `--write` memakai tools edit/write.
7. Task timeout dihentikan.
8. Hasil dikirim ke Slack via `response_url`.
9. Log task tersimpan.

---

## Roadmap Setelah MVP

1. Session persistent per Slack thread.
2. Streaming progress ke Slack thread.
3. Button approval sebelum write mode benar-benar dijalankan.
4. Separate allowlist untuk read-only dan write.
5. Branch git otomatis untuk setiap write task.
6. Ringkasan diff otomatis.
7. Dashboard history task.
8. Multi-project routing dengan whitelist project.
