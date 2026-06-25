#!/bin/bash
# sync-knowledge.sh — Auto-sync knowledge hub from LK UKMs project
# Usage: ./scripts/sync-knowledge.sh
# Cron: 0 */6 * * * /root/lk-ukms-knowledge/scripts/sync-knowledge.sh >> /var/log/knowledge-sync.log 2>&1

set -euo pipefail

KNOWLEDGE_REPO="${KNOWLEDGE_REPO:-$HOME/lk-ukms-knowledge}"
PROJECT_DIR="${PROJECT_DIR:-/var/www/lk.pjdigital.top}"
LOG_FILE="/var/log/knowledge-sync.log"

log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
}

log "🔄 Starting knowledge sync..."

# Step 1: Engram sync
log "📦 Syncing Engram memories..."
cd "$PROJECT_DIR"
engram sync --all 2>&1 | tee -a "$LOG_FILE" || log "⚠️ Engram sync failed (non-fatal)"

# Step 2: Export full JSON dump
log "📄 Exporting Engram JSON..."
engram export "$KNOWLEDGE_REPO/memories/engram-export.json" 2>&1 | tee -a "$LOG_FILE"

# Step 3: Copy docs
log "📚 Copying docs..."
DOCS=(
  CLAUDE.md panduanagen.md arsitektur.md analisis.md AGENTS.md
  wa.md plan-slack.md progres-pwa.md super-pwa.md
  TASKLIST-KEAMANAN-KRITIS.md TASKLIST-DASHBOARD-IMPROVEMENT.md
  TASKLIST-PROPOSAL-IMPROVEMENT.md tasklist-perbaikan-proposal.md
  analisiscmd.md qa-fase1-report.md
)
for f in "${DOCS[@]}"; do
  [ -f "$PROJECT_DIR/$f" ] && cp "$PROJECT_DIR/$f" "$KNOWLEDGE_REPO/docs/"
done

# Step 4: Copy wiki
log "📖 Copying wiki..."
[ -d "$PROJECT_DIR/.ai-team/wiki" ] && cp -r "$PROJECT_DIR/.ai-team/wiki/"* "$KNOWLEDGE_REPO/wiki/"

# Step 5: Copy agents & rules
log "🤖 Copying agents & rules..."
[ -d "$PROJECT_DIR/.pi/agents" ] && cp -r "$PROJECT_DIR/.pi/agents/"* "$KNOWLEDGE_REPO/agents/"
[ -d "$PROJECT_DIR/.ai-team/rules" ] && cp -r "$PROJECT_DIR/.ai-team/rules/"* "$KNOWLEDGE_REPO/rules/"

# Step 6: Copy Engram chunks (git sync)
log "📋 Copying Engram chunks..."
if [ -d "$PROJECT_DIR/.engram" ]; then
  mkdir -p "$KNOWLEDGE_REPO/.engram"
  cp -r "$PROJECT_DIR/.engram/"* "$KNOWLEDGE_REPO/.engram/" 2>/dev/null || true
fi

# Step 7: Git commit & push
log "🔀 Git commit & push..."
cd "$KNOWLEDGE_REPO"
git add -A

if git diff --cached --quiet; then
  log "✅ No changes to commit"
else
  TIMESTAMP=$(date '+%Y-%m-%d %H:%M')
  COMMIT_COUNT=$(git diff --cached --stat | tail -1)
  git commit -m "auto-sync: $TIMESTAMP

$COMMIT_COUNT"
  
  # Push with retry
  for i in 1 2 3; do
    if git push origin main 2>&1 | tee -a "$LOG_FILE"; then
      log "✅ Knowledge pushed to GitHub"
      break
    else
      log "⚠️ Push attempt $i failed, retrying in 5s..."
      sleep 5
    fi
  done
fi

log "🏁 Sync complete"
