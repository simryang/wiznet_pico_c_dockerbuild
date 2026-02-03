#!/bin/bash
# SessionStart Hook - 세션 시작 시 자동 실행
# Claude Code가 시작될 때마다 이전 작업 컨텍스트를 자동으로 로드합니다

set -e

CLAUDE_PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
CLAUDE_ENV_FILE="${CLAUDE_ENV_FILE}"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🚀 WIZnet-PICO-C 프로젝트 세션 시작"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# 1. 프로젝트 기본 정보
if [ -d "$CLAUDE_PROJECT_DIR/.git" ]; then
    CURRENT_BRANCH=$(git -C "$CLAUDE_PROJECT_DIR" rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")
    LAST_COMMIT=$(git -C "$CLAUDE_PROJECT_DIR" log -1 --format="%ai - %s" 2>/dev/null || echo "No commits")

    echo "📁 프로젝트: WIZnet-PICO-C Docker Build System"
    echo "🌿 현재 브랜치: $CURRENT_BRANCH"
    echo "📝 최근 커밋: $LAST_COMMIT"
    echo ""
fi

# 2. 이전 세션 요약 로드
if [ -f "$CLAUDE_PROJECT_DIR/.claude/session-history/latest-summary.md" ]; then
    echo "📋 이전 세션 요약:"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    cat "$CLAUDE_PROJECT_DIR/.claude/session-history/latest-summary.md"
    echo ""
fi

# 3. 미완료 작업 (TODO) 로드
if [ -f "$CLAUDE_PROJECT_DIR/.claude/session-history/pending-tasks.md" ]; then
    echo "⏳ 진행 중인 작업:"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    cat "$CLAUDE_PROJECT_DIR/.claude/session-history/pending-tasks.md"
    echo ""
fi

# 4. 최근 변경사항 (Git diff)
if [ -d "$CLAUDE_PROJECT_DIR/.git" ]; then
    UNCOMMITTED=$(git -C "$CLAUDE_PROJECT_DIR" status --porcelain 2>/dev/null | wc -l)
    if [ "$UNCOMMITTED" -gt 0 ]; then
        echo "⚠️  커밋되지 않은 변경사항: $UNCOMMITTED 개 파일"
        git -C "$CLAUDE_PROJECT_DIR" status --short | head -10
        echo ""
    fi
fi

# 5. 프로젝트 컨텍스트 (claude/CLAUDE.md 존재 시)
if [ -f "$CLAUDE_PROJECT_DIR/claude/CLAUDE.md" ]; then
    echo "💡 프로젝트 컨텍스트는 claude/CLAUDE.md를 참고하세요"
    echo ""
fi

# 6. 프로젝트 스펙 (PROJECT_SPEC.md 존재 시)
if [ -f "$CLAUDE_PROJECT_DIR/PROJECT_SPEC.md" ]; then
    echo "📄 프로젝트 명세: PROJECT_SPEC.md 참고"
    echo ""
fi

# 7. 환경 변수 설정
if [ -n "$CLAUDE_ENV_FILE" ]; then
    echo 'export PROJECT_VERSION="1.0.0"' >> "$CLAUDE_ENV_FILE"
    echo 'export PROJECT_NAME="wiznet-pico-c-docker"' >> "$CLAUDE_ENV_FILE"
    echo 'export BUILD_SYSTEM="Docker"' >> "$CLAUDE_ENV_FILE"
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✨ 세션 준비 완료! 작업을 시작하세요."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

exit 0
