#!/bin/bash
# SessionStart Hook - 세션 시작 시 자동 실행
# Claude Code가 시작될 때마다 이전 작업 컨텍스트를 자동으로 로드합니다

set -e

CLAUDE_PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
CLAUDE_ENV_FILE="${CLAUDE_ENV_FILE}"

# Git 정보 수집
if [ -d "$CLAUDE_PROJECT_DIR/.git" ]; then
    CURRENT_BRANCH=$(git -C "$CLAUDE_PROJECT_DIR" rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")
    LAST_COMMIT=$(git -C "$CLAUDE_PROJECT_DIR" log -1 --format="%h - %s (%ai)" 2>/dev/null || echo "No commits")
    UNCOMMITTED=$(git -C "$CLAUDE_PROJECT_DIR" status --porcelain 2>/dev/null)
fi

# ============================================================================
# 세션 시작 템플릿 출력 (Claude가 이걸 그대로 사용자에게 보여줌)
# ============================================================================
cat <<'TEMPLATE'
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
## 🚀 WIZnet-PICO-C 프로젝트 세션 시작

TEMPLATE

echo "**📁 프로젝트:** WIZnet-PICO-C Docker Build System"
echo "**🌿 브랜치:** $CURRENT_BRANCH"
echo "**📝 최근 커밋:** $LAST_COMMIT"
echo ""

cat <<'TEMPLATE'
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
## ✅ 완료된 작업

- [x] 프로젝트 초기화
- [x] Dockerfile 최적화
- [x] docker-build.sh 수정
- [x] 프로젝트 구조 생성
- [x] Claude Code 세션 관리 설정

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
## 📋 다음 할 일 (우선순위)

**1단계: build.sh 작성** ⭐
- [ ] 10종 보드 선택 UI 구현
- [ ] 16종 예제 선택 UI 구현
- [ ] WIZnet-PICO-C 클론 및 서브모듈 초기화
- [ ] CMakeLists.txt 자동 수정
- [ ] Docker 빌드 실행

**2단계: 테스트 빌드**
- [ ] W5500-EVB-Pico + http 예제

**3단계: Windows 지원**
- [ ] build.ps1 작성

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
TEMPLATE

# 커밋되지 않은 변경사항
if [ -n "$UNCOMMITTED" ]; then
    echo "## ⚠️ 커밋되지 않은 변경사항"
    echo ""
    echo '```'
    git -C "$CLAUDE_PROJECT_DIR" status --short | head -10
    echo '```'
    echo ""
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# 환경 변수 설정
if [ -n "$CLAUDE_ENV_FILE" ]; then
    echo 'export PROJECT_VERSION="1.0.0"' >> "$CLAUDE_ENV_FILE"
    echo 'export PROJECT_NAME="wiznet-pico-c-docker"' >> "$CLAUDE_ENV_FILE"
    echo 'export BUILD_SYSTEM="Docker"' >> "$CLAUDE_ENV_FILE"
fi

exit 0
