# Agent Routing - LK UKMs

## Model LK Sub-Agent

Model dikunci di frontmatter masing-masing file `.pi/agents/lk-*.md`. Main agent **tidak boleh** mengirim override `model` saat memanggil sub-agent, kecuali user meminta eksplisit.

```text
lk-analyst   → sumo2/MiniMax-M2.7-highspeed
lk-designer  → sumopod/MiniMax-M2.7-highspeed
lk-docs      → sumo2/MiniMax-M2.7-highspeed
lk-developer → sumopod/MiniMax-M2.7-highspeed
lk-qa        → sumopod/MiniMax-M2.7-highspeed
```

## Pilih Agent

- `lk-analyst`: requirement/spec, acceptance criteria, impact analysis.
- `lk-designer`: UI/UX, Tailwind component, layout/state.
- `lk-developer`: implementasi PHP/JS/SQL.
- `lk-qa`: bug triage, regression, security review, syntax check.
- `lk-docs`: dokumentasi perubahan, wiki maintenance.

## Workflow

Main agent adalah orchestrator/reviewer. Untuk task menengah/besar, jangan langsung mengerjakan seluruh implementasi di main agent.

### Feature
1. `lk-analyst` membuat/menajamkan spec.
2. `lk-designer` memberi design notes bila UI berubah.
3. `lk-developer` implementasi.
4. Main agent membaca/verifikasi perubahan aktual.
5. `lk-qa` validasi.
6. `lk-docs` update docs/wiki/metrics bila perlu.

### Bug-Refactor
1. `lk-qa` atau `lk-analyst` triage.
2. `lk-developer` melakukan minimal fix/refactor.
3. Main agent membaca/verifikasi perubahan aktual.
4. `lk-qa` regression/security check.
5. `lk-docs` dokumentasi bila behavior/pola berubah.

### Security
1. `lk-qa` security triage.
2. `lk-developer` remediation.
3. Main agent membaca/verifikasi perubahan aktual.
4. `lk-qa` security verification.
5. `lk-docs` security notes tanpa secret/exploit detail berlebih.

### Jika Sub-Agent Gagal
- Jika sub-agent no output/error, ulangi sekali dengan scope lebih kecil.
- Jika tetap gagal, laporkan ke user bahwa delegasi gagal.
- Jangan diam-diam mengambil alih seluruh workflow kecuali user mengizinkan.

## Wiki-First

Semua agent LK harus membaca `.ai-team/wiki/` yang relevan sebelum membuka source mentah.
