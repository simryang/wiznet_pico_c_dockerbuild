#!/bin/bash
# SessionEnd Hook - 세션 종료 시 자동 실행
# 현재 세션의 작업 내용을 요약하여 저장합니다

set -e

CLAUDE_PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
TRANSCRIPT_PATH="${transcript_path}"
SESSION_ID="${session_id}"

HISTORY_DIR="$CLAUDE_PROJECT_DIR/.claude/session-history"
mkdir -p "$HISTORY_DIR"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "💾 세션 저장 중..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# 1. 타임스탬프
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
DATE_ONLY=$(date '+%Y-%m-%d')

# 2. 세션 요약 생성
cat > "$HISTORY_DIR/latest-summary.md" << EOF
## 마지막 세션 정보

**종료 시각:** $TIMESTAMP
**세션 ID:** ${SESSION_ID:-unknown}

### Git 상태
EOF

# Git 정보 추가
if [ -d "$CLAUDE_PROJECT_DIR/.git" ]; then
    CURRENT_BRANCH=$(git -C "$CLAUDE_PROJECT_DIR" rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")
    LAST_COMMIT=$(git -C "$CLAUDE_PROJECT_DIR" log -1 --format="%h - %s" 2>/dev/null || echo "No commits")

    cat >> "$HISTORY_DIR/latest-summary.md" << EOF
- **브랜치:** $CURRENT_BRANCH
- **최근 커밋:** $LAST_COMMIT

### 작업한 파일들
EOF

    # 최근 수정된 파일 목록
    git -C "$CLAUDE_PROJECT_DIR" diff --name-only HEAD~1..HEAD 2>/dev/null | head -10 | while read file; do
        echo "- \`$file\`" >> "$HISTORY_DIR/latest-summary.md"
    done || echo "- (변경사항 없음)" >> "$HISTORY_DIR/latest-summary.md"
fi

cat >> "$HISTORY_DIR/latest-summary.md" << EOF

### 커밋되지 않은 변경사항
EOF

# Uncommitted 변경사항
if [ -d "$CLAUDE_PROJECT_DIR/.git" ]; then
    UNCOMMITTED=$(git -C "$CLAUDE_PROJECT_DIR" status --porcelain 2>/dev/null | wc -l)
    if [ "$UNCOMMITTED" -gt 0 ]; then
        git -C "$CLAUDE_PROJECT_DIR" status --short | head -10 | while read line; do
            echo "- $line" >> "$HISTORY_DIR/latest-summary.md"
        done
    else
        echo "- 없음 (모두 커밋됨)" >> "$HISTORY_DIR/latest-summary.md"
    fi
fi

cat >> "$HISTORY_DIR/latest-summary.md" << EOF

### 다음 작업 힌트
- 이전 세션에서 작업하던 내용을 계속 진행하세요
- Git 상태를 확인하고 필요시 커밋하세요
- PROJECT_SPEC.md와 claude/CLAUDE.md를 참고하세요
EOF

# 3. 세션 히스토리 아카이브 (날짜별)
if [ -n "$SESSION_ID" ]; then
    ARCHIVE_FILE="$HISTORY_DIR/archive-$DATE_ONLY.md"

    if [ ! -f "$ARCHIVE_FILE" ]; then
        echo "# 세션 히스토리 - $DATE_ONLY" > "$ARCHIVE_FILE"
        echo "" >> "$ARCHIVE_FILE"
    fi

    echo "## 세션 $TIMESTAMP" >> "$ARCHIVE_FILE"
    echo "**ID:** $SESSION_ID" >> "$ARCHIVE_FILE"

    if [ -d "$CLAUDE_PROJECT_DIR/.git" ]; then
        echo "**브랜치:** $(git -C "$CLAUDE_PROJECT_DIR" rev-parse --abbrev-ref HEAD 2>/dev/null)" >> "$ARCHIVE_FILE"
    fi

    echo "" >> "$ARCHIVE_FILE"
fi

# 4. Transcript 백업 (옵션)
if [ -f "$TRANSCRIPT_PATH" ]; then
    # 마지막 5줄만 저장 (용량 절약)
    tail -5 "$TRANSCRIPT_PATH" > "$HISTORY_DIR/last-transcript-preview.jsonl" 2>/dev/null || true
fi

# 5. TODO 파일이 있으면 유지
if [ ! -f "$HISTORY_DIR/pending-tasks.md" ]; then
    cat > "$HISTORY_DIR/pending-tasks.md" << 'EOF'
## 진행 중인 작업

현재 진행 중인 작업이 없습니다.

### 할 일
- [ ] 새 작업 추가

### 완료
- [x] 프로젝트 초기화
EOF
fi

echo "✅ 세션 저장 완료!"
echo "   - 요약: .claude/session-history/latest-summary.md"
echo "   - 아카이브: .claude/session-history/archive-$DATE_ONLY.md"
echo ""

exit 0
