#!/usr/bin/env bash
set -euo pipefail

# -----------------------------------------------------------------------------
# build.sh - WIZnet-PICO-C Docker Build System
#
# WIZnet 이더넷 보드(10종)용 C 예제(16종) 빌드 스크립트
#
# 사용법:
#   ./build.sh -i                           # Interactive 모드
#   ./build.sh --board W5500_EVB_PICO --all # 전체 빌드
#   ./build.sh --board W5500_EVB_PICO --example http
#   ./build.sh --clean                      # 빌드 정리
#   ./build.sh --help                       # 도움말
# -----------------------------------------------------------------------------

# 버전
VERSION="1.0.0"

# 기본 설정
REPO_URL="https://github.com/WIZnet-ioNIC/WIZnet-PICO-C.git"
PROJECT_DIR="WIZnet-PICO-C"
DOCKER_IMAGE="simryang/w55rp20:latest"
BUILD_TYPE="Release"
OUT_DIR="out"

# 성능 최적화 설정
CCACHE_DIR_HOST="${CCACHE_DIR_HOST:-$HOME/.ccache-wiznet-pico-c}"
TMPFS_SIZE="${TMPFS_SIZE:-20g}"
JOBS="${JOBS:-16}"

# 지원 보드 목록 (BOARD_NAME)
BOARDS=(
    "WIZnet_Ethernet_HAT"
    "W5100S_EVB_PICO"
    "W5500_EVB_PICO"
    "W55RP20_EVB_PICO"
    "W6100_EVB_PICO"
    "W6300_EVB_PICO"
    "W5100S_EVB_PICO2"
    "W5500_EVB_PICO2"
    "W6100_EVB_PICO2"
    "W6300_EVB_PICO2"
)

# 보드 설명 (Interactive UI용)
BOARD_DESCRIPTIONS=(
    "WIZnet Ethernet HAT      (W5100S)"
    "W5100S-EVB-Pico          (W5100S)"
    "W5500-EVB-Pico           (W5500) ← 권장"
    "W55RP20-EVB-Pico         (W55RP20 SiP)"
    "W6100-EVB-Pico           (W6100 IPv6)"
    "W6300-EVB-Pico           (W6300 QSPI)"
    "W5100S-EVB-Pico2         (W5100S)"
    "W5500-EVB-Pico2          (W5500)"
    "W6100-EVB-Pico2          (W6100)"
    "W6300-EVB-Pico2          (W6300)"
)

# 지원 예제 목록
EXAMPLES=(
    "loopback"
    "udp"
    "http"
    "tcp_server_multi_socket"
    "dhcp_dns"
    "sntp"
    "mqtt"
    "tftp"
    "netbios"
    "pppoe"
    "upnp"
    "tcp_client_over_ssl"
    "tcp_server_over_ssl"
    "udp_multicast"
    "can"
    "network_install"
)

# 예제 설명 (Interactive UI용)
EXAMPLE_DESCRIPTIONS=(
    "loopback              - 루프백 테스트"
    "udp                   - UDP 통신"
    "http                  - HTTP 서버"
    "tcp_server_multi      - 다중 소켓 서버"
    "dhcp_dns              - DHCP & DNS"
    "sntp                  - 시간 동기화"
    "mqtt                  - MQTT Pub/Sub"
    "tftp                  - TFTP 전송"
    "netbios               - NetBIOS"
    "pppoe                 - PPPoE"
    "upnp                  - UPnP"
    "tcp_client_ssl        - SSL 클라이언트"
    "tcp_server_ssl        - SSL 서버"
    "udp_multicast         - 멀티캐스트"
    "can                   - CAN 통신"
    "network_install       - 네트워크 설치"
)

# 로깅 함수
log() { echo "[INFO] $*"; }
warn() { echo "[WARN] $*" >&2; }
error() { echo "[ERROR] $*" >&2; exit 1; }

# 도움말
show_help() {
    cat <<EOF
WIZnet-PICO-C Docker Build System v${VERSION}

사용법:
  ./build.sh [옵션]

옵션:
  -i, --interactive              Interactive 모드 (초보자 권장)
  -b, --board BOARD_NAME         보드 지정 (예: W5500_EVB_PICO)
  -e, --example EXAMPLE          예제 지정 (예: http)
  -a, --all                      전체 예제 빌드 (16개)
  -d, --debug                    디버그 빌드 (기본: Release)
  -c, --clean                    빌드 정리
  -h, --help                     이 도움말 표시

예시:
  ./build.sh -i                                # Interactive 모드
  ./build.sh -b W5500_EVB_PICO -a              # 전체 빌드
  ./build.sh -b W5500_EVB_PICO -e http         # HTTP 예제만
  ./build.sh -b W5500_EVB_PICO -e "http mqtt"  # 여러 예제
  ./build.sh -c                                # 빌드 정리

지원 보드 (10종):
  WIZnet_Ethernet_HAT, W5100S_EVB_PICO, W5500_EVB_PICO,
  W55RP20_EVB_PICO, W6100_EVB_PICO, W6300_EVB_PICO,
  W5100S_EVB_PICO2, W5500_EVB_PICO2, W6100_EVB_PICO2,
  W6300_EVB_PICO2

지원 예제 (16종):
  loopback, udp, http, tcp_server_multi_socket,
  dhcp_dns, sntp, mqtt, tftp, netbios, pppoe, upnp,
  tcp_client_over_ssl, tcp_server_over_ssl,
  udp_multicast, can, network_install
EOF
}

# 보드 선택 Interactive UI
select_board() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "[1/3] 보드 선택"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "어떤 보드를 사용하시나요?"
    echo ""
    echo "  RP2040 기반:"
    for i in {0..5}; do
        echo "  $((i+1))) ${BOARD_DESCRIPTIONS[$i]}"
    done
    echo ""
    echo "  RP2350 (Pico2) 기반:"
    for i in {6..9}; do
        echo "  $((i+1))) ${BOARD_DESCRIPTIONS[$i]}"
    done
    echo ""
    read -p "선택 [1-10]: " choice

    if [[ ! "$choice" =~ ^[1-9]$|^10$ ]]; then
        error "잘못된 선택입니다. 1-10 사이의 숫자를 입력하세요."
    fi

    SELECTED_BOARD="${BOARDS[$((choice-1))]}"
    echo ""
    echo "✓ 선택: ${BOARD_DESCRIPTIONS[$((choice-1))]}"
}

# 예제 선택 Interactive UI
select_examples() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "[2/3] 예제 선택"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "빌드할 예제를 선택하세요:"
    echo ""
    echo "  0) 전체 빌드 (16개 모두, 약 10분)"
    echo ""
    echo "  기본 네트워킹:"
    echo "  1) ${EXAMPLE_DESCRIPTIONS[0]} ⭐"
    echo "  2) ${EXAMPLE_DESCRIPTIONS[1]} ⭐"
    echo "  3) ${EXAMPLE_DESCRIPTIONS[2]} ⭐⭐"
    echo "  4) ${EXAMPLE_DESCRIPTIONS[3]} ⭐⭐⭐"
    echo ""
    echo "  프로토콜:"
    echo "  5) ${EXAMPLE_DESCRIPTIONS[4]} ⭐⭐"
    echo "  6) ${EXAMPLE_DESCRIPTIONS[5]} ⭐⭐"
    echo "  7) ${EXAMPLE_DESCRIPTIONS[6]} ⭐⭐"
    echo "  8) ${EXAMPLE_DESCRIPTIONS[7]} ⭐⭐"
    echo "  9) ${EXAMPLE_DESCRIPTIONS[8]} ⭐⭐⭐"
    echo "  10) ${EXAMPLE_DESCRIPTIONS[9]} ⭐⭐⭐"
    echo "  11) ${EXAMPLE_DESCRIPTIONS[10]} ⭐⭐⭐"
    echo ""
    echo "  보안:"
    echo "  12) ${EXAMPLE_DESCRIPTIONS[11]} ⭐⭐⭐"
    echo "  13) ${EXAMPLE_DESCRIPTIONS[12]} ⭐⭐⭐"
    echo ""
    echo "  고급:"
    echo "  14) ${EXAMPLE_DESCRIPTIONS[13]} ⭐⭐⭐"
    echo "  15) ${EXAMPLE_DESCRIPTIONS[14]} ⭐⭐⭐"
    echo "  16) ${EXAMPLE_DESCRIPTIONS[15]} ⭐⭐⭐"
    echo ""
    read -p "선택 [0-16] (여러 개 입력 가능, 예: 1 2 3): " choices

    if [[ "$choices" =~ (^|[[:space:]])0($|[[:space:]]) ]]; then
        SELECTED_EXAMPLES=("${EXAMPLES[@]}")
        BUILD_ALL=true
        echo ""
        echo "✓ 선택: 전체 빌드 (16개)"
    else
        SELECTED_EXAMPLES=()
        for choice in $choices; do
            if [[ ! "$choice" =~ ^[1-9]$|^1[0-6]$ ]]; then
                error "잘못된 선택: $choice (1-16 사이의 숫자를 입력하세요)"
            fi
            SELECTED_EXAMPLES+=("${EXAMPLES[$((choice-1))]}")
        done
        BUILD_ALL=false
        echo ""
        echo "✓ 선택: ${SELECTED_EXAMPLES[*]}"
    fi
}

# 빌드 확인
confirm_build() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "[3/3] 빌드 설정 확인"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "빌드 설정:"
    echo "  보드:     $SELECTED_BOARD"
    if $BUILD_ALL; then
        echo "  예제:     전체 (16개)"
    else
        echo "  예제:     ${SELECTED_EXAMPLES[*]}"
    fi
    echo "  빌드타입: $BUILD_TYPE"
    echo "  Docker:   $DOCKER_IMAGE"
    echo ""
    read -p "계속하시겠습니까? [Y/n]: " confirm

    if [[ "$confirm" =~ ^[Nn] ]]; then
        echo "빌드를 취소했습니다."
        exit 0
    fi
}

# 보드명 검증
validate_board() {
    local board=$1
    for b in "${BOARDS[@]}"; do
        if [[ "$b" == "$board" ]]; then
            return 0
        fi
    done
    error "잘못된 보드명: $board\n사용 가능한 보드: ${BOARDS[*]}"
}

# 예제명 검증
validate_example() {
    local example=$1
    for e in "${EXAMPLES[@]}"; do
        if [[ "$e" == "$example" ]]; then
            return 0
        fi
    done
    error "잘못된 예제명: $example\n사용 가능한 예제: ${EXAMPLES[*]}"
}

# Docker 확인
check_docker() {
    if ! command -v docker &> /dev/null; then
        error "Docker가 설치되지 않았습니다. https://www.docker.com/get-started 참조"
    fi

    if ! docker info &> /dev/null; then
        error "Docker 데몬이 실행되지 않았습니다. Docker Desktop을 실행하세요."
    fi
}

# WIZnet-PICO-C 저장소 클론
clone_repo() {
    if [ -d "$PROJECT_DIR" ]; then
        log "기존 프로젝트 디렉토리 발견: $PROJECT_DIR"
        log "서브모듈 업데이트 확인 중..."
        cd "$PROJECT_DIR"
        git submodule update --init --recursive
        cd ..
    else
        log "WIZnet-PICO-C 저장소 클론 중..."
        git clone --recurse-submodules "$REPO_URL" "$PROJECT_DIR"

        # 서브모듈 완전 초기화 보장
        log "서브모듈 초기화 중..."
        cd "$PROJECT_DIR"
        git submodule update --init --recursive
        cd ..
    fi

    # 서브모듈 초기화 확인
    if [ ! -f "$PROJECT_DIR/libraries/pico-sdk/CMakeLists.txt" ]; then
        error "Pico SDK 서브모듈이 초기화되지 않았습니다!"
    fi
    if [ ! -d "$PROJECT_DIR/libraries/ioLibrary_Driver/Ethernet" ]; then
        error "ioLibrary_Driver 서브모듈이 초기화되지 않았습니다!"
    fi
    if [ ! -f "$PROJECT_DIR/libraries/mbedtls/CMakeLists.txt" ]; then
        error "mbedtls 서브모듈이 초기화되지 않았습니다!"
    fi
    log "서브모듈 초기화 완료"
}

# CMakeLists.txt 수정 (BOARD_NAME 설정)
modify_cmakelists() {
    local board=$1
    local cmake_file="$PROJECT_DIR/CMakeLists.txt"

    log "CMakeLists.txt 수정 중: BOARD_NAME=$board"

    # 백업이 없으면 생성
    if [ ! -f "${cmake_file}.bak" ]; then
        cp "$cmake_file" "${cmake_file}.bak"
    else
        # 백업에서 복원
        cp "${cmake_file}.bak" "$cmake_file"
    fi

    # 모든 set(BOARD_NAME ...) 라인 주석 처리 (이미 주석 처리된 것 포함)
    sed -i 's/^set(BOARD_NAME /#set(BOARD_NAME /' "$cmake_file"
    sed -i 's/^#set(BOARD_NAME /#set(BOARD_NAME /' "$cmake_file"

    # 13번 라인 위치에 활성화된 BOARD_NAME 설정 삽입
    sed -i "13s|.*|set(BOARD_NAME $board)|" "$cmake_file"

    # 검증
    if ! grep -q "^set(BOARD_NAME $board)" "$cmake_file"; then
        error "CMakeLists.txt 수정 실패!"
    fi

    log "CMakeLists.txt 수정 완료"
}

# Docker 빌드 실행
run_docker_build() {
    local examples=("$@")

    log "Docker 이미지 pull 중: $DOCKER_IMAGE"
    docker pull "$DOCKER_IMAGE"

    # 디렉토리 생성
    mkdir -p "$OUT_DIR" "$CCACHE_DIR_HOST"

    # 절대 경로 변환
    local abs_project_dir=$(cd "$PROJECT_DIR" && pwd)
    local abs_out_dir=$(cd "$OUT_DIR" && pwd)
    local abs_ccache_dir=$(cd "$CCACHE_DIR_HOST" && pwd)

    log "Docker 빌드 시작..."
    log "  소스: $abs_project_dir"
    log "  산출물: $abs_out_dir"
    log "  ccache: $abs_ccache_dir"
    log "  tmpfs: $TMPFS_SIZE (RAM disk)"

    # 시작 시간 기록
    local start_time=$(date +%s)

    # docker-build.sh 절대 경로
    local abs_docker_build_sh=$(cd "$(dirname "$0")" && pwd)/docker-build.sh

    if $BUILD_ALL; then
        # 전체 빌드 (성능 최적화: tmpfs + ccache)
        docker run --rm \
            -v "$abs_project_dir:/work/src:rw" \
            -v "$abs_out_dir:/work/out:rw" \
            -v "$abs_ccache_dir:/work/.ccache:rw" \
            -v "$abs_docker_build_sh:/docker-build.sh:ro" \
            --tmpfs /work/src/build:rw,exec,size="$TMPFS_SIZE" \
            -e "CCACHE_DIR=/work/.ccache" \
            -e "JOBS=$JOBS" \
            -e "BUILD_TYPE=$BUILD_TYPE" \
            "$DOCKER_IMAGE" \
            bash /docker-build.sh
    else
        # 개별 예제 빌드 (전체 빌드 후 필터링)
        log "개별 예제 빌드는 전체 빌드 후 필터링합니다..."
        docker run --rm \
            -v "$abs_project_dir:/work/src:rw" \
            -v "$abs_out_dir:/work/out:rw" \
            -v "$abs_ccache_dir:/work/.ccache:rw" \
            -v "$abs_docker_build_sh:/docker-build.sh:ro" \
            --tmpfs /work/src/build:rw,exec,size="$TMPFS_SIZE" \
            -e "CCACHE_DIR=/work/.ccache" \
            -e "JOBS=$JOBS" \
            -e "BUILD_TYPE=$BUILD_TYPE" \
            "$DOCKER_IMAGE" \
            bash /docker-build.sh

        # 선택한 예제의 산출물만 필터링
        log "선택한 예제의 산출물만 필터링 중..."
        for example in "${examples[@]}"; do
            find "$abs_out_dir" -name "*${example}*.uf2" -o -name "*${example}*.elf"
        done | sort | uniq
    fi

    # 종료 시간 계산
    local end_time=$(date +%s)
    local elapsed=$((end_time - start_time))
    local minutes=$((elapsed / 60))
    local seconds=$((elapsed % 60))

    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "✅ 빌드 성공! (소요 시간: ${minutes}분 ${seconds}초)"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "생성된 파일:"
    ls -lh "$abs_out_dir"/*.uf2 2>/dev/null || log "산출물이 없습니다."
    echo ""
    echo "산출물 위치: $abs_out_dir"
    echo ""
    echo "다음 단계:"
    echo "  1. $SELECTED_BOARD를 USB로 연결"
    echo "  2. BOOTSEL 버튼을 누른 채 RESET 버튼 클릭"
    echo "  3. $abs_out_dir/*.uf2를 드래그앤드롭"
    echo "  4. 시리얼 터미널로 로그 확인 (115200 baud)"
    echo ""
}

# 빌드 정리
clean_build() {
    log "빌드 정리 중..."

    if [ -d "$PROJECT_DIR/build" ]; then
        rm -rf "$PROJECT_DIR/build"
        log "제거: $PROJECT_DIR/build"
    fi

    if [ -f "$PROJECT_DIR/CMakeLists.txt.bak" ]; then
        mv "$PROJECT_DIR/CMakeLists.txt.bak" "$PROJECT_DIR/CMakeLists.txt"
        log "복원: CMakeLists.txt"
    fi

    if [ -d "$OUT_DIR" ]; then
        rm -rf "$OUT_DIR"
        log "제거: $OUT_DIR"
    fi

    # ccache 정리는 선택 사항 (기본적으로 유지)
    read -p "ccache 디렉토리도 삭제할까요? [y/N]: " clean_ccache
    if [[ "$clean_ccache" =~ ^[Yy] ]]; then
        if [ -d "$CCACHE_DIR_HOST" ]; then
            rm -rf "$CCACHE_DIR_HOST"
            log "제거: $CCACHE_DIR_HOST"
        fi
    fi

    log "빌드 정리 완료"
}

# 메인 로직
main() {
    # 인자 파싱
    INTERACTIVE=false
    SELECTED_BOARD=""
    SELECTED_EXAMPLES=()
    BUILD_ALL=false
    CLEAN=false

    while [[ $# -gt 0 ]]; do
        case $1 in
            -i|--interactive)
                INTERACTIVE=true
                shift
                ;;
            -b|--board)
                SELECTED_BOARD="$2"
                shift 2
                ;;
            -e|--example)
                IFS=' ' read -ra SELECTED_EXAMPLES <<< "$2"
                shift 2
                ;;
            -a|--all)
                BUILD_ALL=true
                SELECTED_EXAMPLES=("${EXAMPLES[@]}")
                shift
                ;;
            -d|--debug)
                BUILD_TYPE="Debug"
                shift
                ;;
            -c|--clean)
                CLEAN=true
                shift
                ;;
            -h|--help)
                show_help
                exit 0
                ;;
            *)
                error "알 수 없는 옵션: $1\n사용법: ./build.sh --help"
                ;;
        esac
    done

    # 헤더
    echo ""
    echo "╔══════════════════════════════════════════════════════════╗"
    echo "║  WIZnet-PICO-C Docker Build System v${VERSION}               ║"
    echo "╚══════════════════════════════════════════════════════════╝"

    # 빌드 정리
    if $CLEAN; then
        clean_build
        exit 0
    fi

    # Interactive 모드
    if $INTERACTIVE; then
        select_board
        select_examples
        confirm_build
    else
        # 명령줄 모드 검증
        if [ -z "$SELECTED_BOARD" ]; then
            error "보드를 지정하세요: --board BOARD_NAME\n사용법: ./build.sh --help"
        fi
        validate_board "$SELECTED_BOARD"

        if [ ${#SELECTED_EXAMPLES[@]} -eq 0 ]; then
            error "예제를 지정하세요: --example EXAMPLE 또는 --all\n사용법: ./build.sh --help"
        fi

        for example in "${SELECTED_EXAMPLES[@]}"; do
            validate_example "$example"
        done
    fi

    # Docker 확인
    check_docker

    # 저장소 클론
    clone_repo

    # CMakeLists.txt 수정
    modify_cmakelists "$SELECTED_BOARD"

    # Docker 빌드 실행
    run_docker_build "${SELECTED_EXAMPLES[@]}"
}

# 스크립트 실행
main "$@"
