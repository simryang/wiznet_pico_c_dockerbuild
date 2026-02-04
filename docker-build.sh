#!/usr/bin/env bash
set -euo pipefail

# -----------------------------------------------------------------------------
# docker-build.sh (WIZnet-PICO-C 전용)
#
# 컨테이너 내부에서 실행되는 빌드 스크립트
#
# 마운트 포인트:
#   /work/src : WIZnet-PICO-C 소스 (서브모듈 포함)
#   /work/out : 산출물 디렉토리 (.uf2, .elf 등)
#
# 환경변수:
#   JOBS      : 병렬 빌드 작업 수 (기본: 16)
#   BUILD_TYPE: Release | Debug (기본: Release)
#
# 주요 차이점 (vs w55rp20-docker-build):
#   - PICO_SDK_PATH를 CMake에 전달하지 않음 (서브모듈 사용)
#   - 서브모듈 초기화 확인 추가
# -----------------------------------------------------------------------------

: "${JOBS:=16}"
: "${BUILD_TYPE:=Release}"

log(){ echo "[BUILD] $*"; }
die(){ echo "[BUILD][ERROR] $*" >&2; exit 2; }
need(){ command -v "$1" >/dev/null 2>&1 || die "missing tool: $1"; }

# Git safe.directory (Docker mount ownership 이슈 회피)
if [ -d "/work/src/.git" ]; then
  git config --global --add safe.directory /work/src
fi

log "PATH=$PATH"
log "python=$(command -v python || echo NO)"
log "python3=$(command -v python3 || echo NO)"

# 필수 툴 확인
need cmake
need ninja
need python
need python3
need arm-none-eabi-gcc
need srec_cat

# astyle (선택)
if ! command -v astyle >/dev/null 2>&1; then
  log "[WARN] astyle not found -> 'restyle' target may fail"
fi

# 서브모듈 초기화 확인
log "Checking submodules..."
if [ ! -f "/work/src/libraries/pico-sdk/CMakeLists.txt" ]; then
  die "Pico SDK submodule not initialized! Run: git submodule update --init --recursive"
fi
if [ ! -d "/work/src/libraries/ioLibrary_Driver/Ethernet" ]; then
  die "ioLibrary_Driver submodule not initialized!"
fi
if [ ! -f "/work/src/libraries/mbedtls/CMakeLists.txt" ]; then
  die "mbedtls submodule not initialized!"
fi
log "Submodules OK"

# tmpfs 사용량 모니터링
trap 'echo "=== TMPFS DF ==="; df -h /work/src/build || true; echo "=== TMPFS DU ==="; du -sh /work/src/build || true' EXIT

PEAK_FILE=/tmp/tmpfs_peak_$$
echo 0 > "$PEAK_FILE"

monitor_tmpfs() {
  while true; do
    USED=$(df -B1 /work/src/build 2>/dev/null | awk 'NR==2{print $3}')
    USED=${USED:-0}
    CUR=$(cat "$PEAK_FILE" 2>/dev/null || echo 0)
    if [ "$USED" -gt "$CUR" ]; then
      echo "$USED" > "$PEAK_FILE"
    fi
    sleep 0.5
  done
}
monitor_tmpfs &
MPID=$!

# ccache 설정
C_LAUNCHER=""
CXX_LAUNCHER=""
if command -v ccache >/dev/null 2>&1; then
  log "ccache enabled"
  C_LAUNCHER="-DCMAKE_C_COMPILER_LAUNCHER=ccache"
  CXX_LAUNCHER="-DCMAKE_CXX_COMPILER_LAUNCHER=ccache"
  ccache -z >/dev/null 2>&1 || true
else
  log "[WARN] ccache not found (ok)"
fi

# CMake Configure
# 주의: PICO_SDK_PATH를 전달하지 않음!
# WIZnet-PICO-C의 CMakeLists.txt가 libraries/pico-sdk를 직접 참조
log "Running cmake..."
cmake -S /work/src -B /work/src/build -G Ninja \
  -DCMAKE_BUILD_TYPE="$BUILD_TYPE" \
  -DPICO_TOOLCHAIN_PATH=/opt/toolchain \
  ${C_LAUNCHER} ${CXX_LAUNCHER}

# Build
log "Building with ninja (-j $JOBS)..."
cmake --build /work/src/build -- -j "$JOBS"

# tmpfs 모니터 종료
kill "$MPID" >/dev/null 2>&1 || true
PEAK=$(cat "$PEAK_FILE" 2>/dev/null || echo 0)
rm -f "$PEAK_FILE" || true

log "TMPFS_PEAK_BYTES=$PEAK"
python3 - <<PY
p=int("$PEAK")
print(f"TMPFS_PEAK_GiB={p/1024**3:.2f}")
PY

# 산출물 수집
mkdir -p /work/out
find /work/src/build -type f \( -name "*.uf2" -o -name "*.elf" -o -name "*.bin" -o -name "*.hex" \) \
  -exec cp -f {} /work/out/ \;

log "=== OUTPUTS ==="
ls -lh /work/out || true

if command -v ccache >/dev/null 2>&1; then
  log "=== CCACHE STATS ==="
  ccache -s || true
fi

log "Build complete!"
