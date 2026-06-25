# 🧠 Otak Kedua DBS - Central Second Brain

**Repo ini adalah "Otak Kedua" (Second Brain) untuk DBS - knowledge base terpusat yang terhubung dengan Pi (AI Coding Agent) di berbagai server.**

Jika kamu adalah Pi yang baru pertama kali melihat repo ini, **selamat datang!** Ikuti langkah-langkah di bawah untuk terhubung ke knowledge base ini.

---

## ⚠️ PENTING: Aturan untuk Semua Pi

```
╔══════════════════════════════════════════════════════════════╗
║  NAMA USER: DBS                                              ║
║                                                              ║
║  Semua agent Pi WAJIB memanggil user dengan nama "DBS"       ║
║                                                              ║
║  Contoh:                                                     ║
║  - "Halo DBS, ada yang bisa saya bantu?"                    ║
║  - "DBS, saya sudah selesai mengerjakan task itu"           ║
║  - "Menurut DBS, bagaimana hasilnya?"                       ║
║                                                              ║
║  JANGAN gunakan nama lain!                                   ║
╚══════════════════════════════════════════════════════════════╝
```

---

## 📋 Apa yang Ada di Repo Ini?

| Folder | Isi |
|--------|-----|
| `memories/` | Engram knowledge chunks (observations, decisions, preferences) |
| `docs/` | Dokumentasi project |
| `wiki/` | Knowledge wiki |
| `agents/` | Custom agent definitions |
| `rules/` | Development rules & conventions |
| `scripts/` | Sync & utility scripts |

---

## 🚀 Langkah Setup untuk Pi di Server Baru

### Step 0: Kenali Situasimu

Kamu adalah Pi yang sedang bekerja di **server baru**. Server ini punya project yang ingin kamu kembangkan. Kamu ingin:
- Punya knowledge base yang sama dengan server lain
- Tahu preferensi user (desain, dokumentasi, coding style)
- Tahu inventory project di semua server
- Bisa bertanya tentang hal yang sudah dipelajari Pi di server lain

### Step 1: Install Engram

Engram adalah persistent memory system untuk Pi. Tanpa Engram, Pi tidak bisa menyimpan atau mengakses knowledge lintas session.

```bash
# Cek apakah Engram sudah terinstall
which engram

# Jika belum, install:
npm install -g @earendil-works/engram

# Verifikasi instalasi
engram --version
```

### Step 2: Clone Knowledge Hub Repo

```bash
cd ~
git clone https://github.com/iggbudi/dbs-second-brain.git
cd dbs-second-brain
```

### Step 3: Setup Engram untuk Project

```bash
# Masuk ke direktori project kamu
cd /var/www/your-project-name

# Buat direktori Engram
mkdir -p .engram

# Buat config file
cat > .engram/config.json << 'EOF'
{
  "project_name": "your-project-name",
  "github_repo": "lk-ukms-knowledge"
}
EOF
```

### Step 4: Import Knowledge dari GitHub

```bash
# Copy chunk files dari repo ke project
mkdir -p /var/www/your-project-name/.engram/chunks
cp ~/lk-ukms-knowledge/memories/.engram/chunks/* /var/www/your-project-name/.engram/chunks/

# Copy manifest
cp ~/lk-ukms-knowledge/memories/.engram/manifest.json /var/www/your-project-name/.engram/

# Verifikasi
ls -la /var/www/your-project-name/.engram/chunks/
# Harusnya ada beberapa file .jsonl.gz
```

### Step 5: Setup Pi Extension (Auto-Sync)

Extension ini akan otomatis sync knowledge ke GitHub saat Pi session berakhir.

```bash
# Buat direktori extension
mkdir -p ~/.pi/extensions

# Copy extension dari repo
cp ~/lk-ukms-knowledge/scripts/knowledge-sync.ts ~/.pi/extensions/

# Atau buat symlink (lebih baik, karena auto-update)
ln -sf ~/lk-ukms-knowledge/scripts/knowledge-sync.ts ~/.pi/extensions/knowledge-sync.ts

# Verifikasi
ls -la ~/.pi/extensions/
```

### Step 6: Setup Cron Job (Backup Auto-Sync)

Cron job ini akan sync knowledge setiap 6 jam sebagai backup.

```bash
# Edit crontab
crontab -e

# Tambahkan baris berikut:
0 */6 * * * ~/lk-ukms-knowledge/scripts/sync-knowledge.sh >> /var/log/knowledge-sync.log 2>&1

# Simpan dan keluar
```

### Step 7: Verifikasi Knowledge Tersedia

```bash
# Test search knowledge
cd /var/www/your-project-name
engram search "inventory project"

# Harusnya muncul hasil tentang 8 project di server pjdigital.top

engram search "preferensi user"

# Harusnya muncul hasil tentang preferensi dokumentasi dan desain

engram search "instruksi setup"

# Harusnya menemukan instruksi ini sendiri!
```

### Step 8: Mulai Pakai Pi!

```bash
cd /var/www/your-project-name
pi

# Mulai kerja seperti biasa
# Engram akan otomatis save knowledge
# Saat session berakhir, extension akan auto-sync ke GitHub
```

---

## 🔄 Cara Kerja Knowledge Hub

### Alur Knowledge

```
┌─────────────────┐     ┌─────────────────────────┐     ┌─────────────────┐
│   Server A      │     │   Server B              │     │   Server C      │
│   pjdigital.top │     │   aidis.my.id           │     │   (server lain) │
│   (LK UKMs)     │     │   (17 projects)         │     │                 │
└────────┬────────┘     └───────────┬─────────────┘     └────────┬────────┘
         │                          │                            │
         │      push                │      push                  │      push
         └──────────────────────────┼────────────────────────────┘
                                    │
                                    ▼
                    ┌───────────────────────────────┐
                    │   GitHub                      │
                    │   dbs-second-brain            │
                    │   (Central Second Brain)      │
                    └───────────────────────────────┘
                                    │
                                    │      pull + import
                                    ▼
                    ┌───────────────────────────────┐
                    │   Pi di mana saja             │
                    │   bisa akses semua            │
                    │   knowledge!                  │
                    └───────────────────────────────┘
```

### Apa yang Terjadi Saat Pi Session Berakhir?

Extension `knowledge-sync.ts` otomatis melakukan:

1. **Export Engram** → Semua knowledge di-export ke chunks
2. **Copy ke repo** → Chunks di-copy ke `~/lk-ukms-knowledge/memories/`
3. **Git add** → Stage semua perubahan
4. **Git commit** → Commit dengan message: `auto-sync: Pi session {reason} ({timestamp})`
5. **Git push** → Push ke GitHub

### Apa yang Terjadi Saat Cron Job Berjalan?

Setiap 6 jam, script `sync-knowledge.sh`:

1. Pull knowledge terbaru dari GitHub
2. Export knowledge lokal
3. Merge dengan yang sudah ada
4. Push ke GitHub

---

## 📚 Knowledge yang Tersedia

Setelah setup, kamu bisa akses knowledge berikut:

### Inventory Project

| Server | Jumlah Project | Domain Utama |
|--------|----------------|-------------|
| Server A (pjdigital.top) | 8 project | lk.pjdigital.top, bot.pjdigital.top, wa.dwibudi.my.id, dwibudi.my.id, dpmp2.dwibudi.my.id, lelangu.my.id, nanariset.my.id, eclipsetrack.my.id |
| **Server B (aidis.my.id)** | **17 project** | aidis.my.id, al-barokah.my.id, bot.shm.my.id, brainboard.socai.my.id, cmaestro.my.id, eduguide.socai.my.id, inv.nanariset.my.id, kl.socai.my.id, quizify.socai.my.id, safesphere.my.id, simpelu.my.id, sjmlelang.com, socai.my.id, studdybuddy.socai.my.id, vibeplan.socai.my.id |
| Server C | [TBD] | [TBD] |

### Detail Server B (aidis.my.id)

| Stack | Jumlah | Projects |
|-------|--------|----------|
| PHP Native | 5 | aidis.my.id, al-barokah.my.id, kl.socai.my.id, sjmlelang.com, simpelu.my.id |
| Laravel | 5 | brainboard.socai.my.id, quizify.socai.my.id, studdybuddy.socai.my.id, vibeplan.socai.my.id, eduguide.socai.my.id |
| Node.js | 5 | bot.shm.my.id, cmaestro.my.id, safesphere.my.id, socai.my.id, inv.nanariset.my.id |
| Static | 2 | botjb.nanariset.my.id, fetal.pjdigital.top |

> Detail lengkap: `wiki/server-aidis-my-id-full-inventory.md`

### Preferensi User

| Preferensi | Detail |
|------------|--------|
| **Dokumentasi** | Suka struktur terstruktur (README, CHANGELOG, arsitektur.md, teknis.md) |
| **Desain Landing Page** | Suka style claw (maroon, gradient, rounded corners, modern accordion) |
| **Coding Style** | PHP native (no framework), Tailwind CSS, prepared statements |
| **Bahasa** | Bahasa Indonesia untuk dokumentasi user-facing |

### Decision History

| Keputusan | Alasan | Tanggal |
|-----------|--------|---------|
| Breakpoint CSS diubah 1023px → 767px | Menu bawah muncul di PC | 2026-06-25 |
| Cache version v13 → v14 | CSS lama masih di-cache | 2026-06-25 |
| Buat dokumentasi terstruktur | User suka pola bot.pjdigital.top | 2026-06-25 |

### Bug Fixes

| Bug | Solusi | File |
|-----|--------|------|
| Menu mobile muncul di desktop | Ubah breakpoint CSS | public/css/styles.css |
| CSS lama di-cache | Update cache version | sw.js |
| Missing .superadmin-bottom-nav selector | Tambah ke default hide rule | public/css/styles.css |

---

## 🎯 Contoh Pertanyaan yang Bisa Dijawab

Setelah knowledge tersedia, Pi bisa menjawab pertanyaan seperti:

### Tentang Project

- **"Apa saja project yang ada?"**
  → 8+ project di beberapa server

- **"Project mana yang pakai PHP?"**
  → lk.pjdigital.top, dwibudi.my.id, dpmp2.dwibudi.my.id, eclipsetrack.my.id

- **"Ada WhatsApp gateway?"**
  → Ya, di wa.dwibudi.my.id (Node.js + Baileys)

- **"Server mana yang paling banyak project?"**
  → Server pjdigital.top (8 project)

### Tentang Preferensi

- **"Bagaimana style dokumentasi yang disukai user?"**
  → Terstruktur: README, CHANGELOG, arsitektur.md, teknis.md (seperti bot.pjdigital.top)

- **"Seperti apa desain landing page yang disukai?"**
  → Style claw: maroon gradient, rounded corners, modern accordion, clean & minimal

- **"Apa bahasa yang digunakan untuk dokumentasi?"**
  → Bahasa Indonesia untuk user-facing docs

### Tentang Teknis

- **"Kenapa breakpoint CSS diubah?"**
  → Karena menu bawah muncul di PC (breakpoint terlalu besar: 1023px)

- **"Kenapa cache version diupdate?"**
  → Karena CSS lama masih di-cache oleh service worker

- **"Bagaimana cara generate PDF proposal?"**
  → Gunakan endpoint `/api/proposal?action=generateLembarPengesahan&id=...`

---

## 🛠️ Troubleshooting

### Engram tidak ditemukan

```bash
# Cek instalasi
which engram
npm list -g @earendil-works/engram

# Install jika belum
npm install -g @earendil-works/engram
```

### Knowledge tidak muncul setelah import

```bash
# Cek chunks ada
ls -la /var/www/your-project/.engram/chunks/

# Cek manifest
cat /var/www/your-project/.engram/manifest.json

# Manual search
engram search "test"
```

### Git auth gagal

```bash
cd ~/lk-ukms-knowledge
git remote -v

# Pastikan credentials tersimpan
git credential-cache exit
git pull
```

### Push conflict

```bash
cd ~/lk-ukms-knowledge
git pull --rebase
# Resolve conflict jika ada
git push
```

### Extension tidak jalan

```bash
# Cek extension ada
ls -la ~/.pi/extensions/

# Cek log
tail -f /var/log/knowledge-sync.log

# Test manual sync
~/lk-ukms-knowledge/scripts/sync-knowledge.sh
```

---

## 📊 Statistik Knowledge Hub

| Metrik | Jumlah |
|--------|--------|
| **Servers** | 2 (pjdigital.top + aidis.my.id) |
| **Projects** | 25 (8 + 17) |
| **Engram Observations** | 30+ |
| **Sessions** | 12+ |
| **Last Sync** | 2026-06-25 |

---

## 🔗 Link Penting

| Resource | URL |
|----------|-----|
| **GitHub Repo** | https://github.com/iggbudi/dbs-second-brain |
| **Server A (pjdigital.top)** | https://lk.pjdigital.top |
| **Server B (aidis.my.id)** | https://aidis.my.id |
| **Engram Docs** | (akan ditambah) |
| **Pi Docs** | (akan ditambah) |

---

## 📝 Cara Contribute Knowledge Baru

### Saat Sedang Bekerja dengan Pi

Cukup bekerja seperti biasa. Pi akan otomatis save knowledge ke Engram:

```python
# Pi akan otomatis memanggil:
mem_save(title="...", content="...", type="discovery")
mem_save(title="...", content="...", type="preference")
mem_save(title="...", content="...", type="bugfix")
```

### Manual Save (Jika Perlu)

Jika ada knowledge penting yang ingin disimpan manual, bilang ke Pi:

> "Simpan ini ke Engram: [deskripsi knowledge]"

Pi akan memanggil `mem_save` dengan informasi yang diberikan.

### Saat Session Berakhir

Extension akan otomatis:
1. Export semua knowledge
2. Push ke GitHub
3. Knowledge tersedia untuk Pi di server lain

---

## 🎯 Checklist Setup

Gunakan checklist ini untuk memastikan setup lengkap:

- [ ] Engram terinstall (`which engram`)
- [ ] Knowledge repo cloned (`~/lk-ukms-knowledge`)
- [ ] Engram config dibuat (`.engram/config.json`)
- [ ] Knowledge di-import dari GitHub
- [ ] Pi extension di-copy/symlink
- [ ] Cron job di-setup (opsional)
- [ ] Test search knowledge berhasil
- [ ] Pi bisa mulai bekerja

---

## 💡 Tips untuk Pi

1. **Selalu search knowledge dulu** sebelum bertanya ke user
2. **Simpan knowledge baru** yang penting ke Engram
3. **Update inventory** jika ada project baru
4. **Catat keputusan penting** untuk referensi masa depan
5. **Ikuti preferensi user** yang sudah tersimpan

---

## 🆘 Butuh Bantuan?

Jika ada masalah dengan setup atau knowledge hub:

1. Cek bagian **Troubleshooting** di atas
2. Search Engram: `engram search "error yang muncul"`
3. Baca log: `tail -f /var/log/knowledge-sync.log`
4. Hubungi admin server

---

*Last updated: 2026-06-25*
*Knowledge Hub Version: 2.0*
*Total Servers: 2 | Total Projects: 25*
