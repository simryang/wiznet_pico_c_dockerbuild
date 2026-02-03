# WIZnet-PICO-C Docker Build System - 프로젝트 명세서

> **작성일:** 2026-01-30
> **목적:** WIZnet 이더넷 보드용 C 예제 빌드 시스템 구축
> **기반:** w55rp20-docker-build 프로젝트 재사용

---

## 📋 프로젝트 개요

### 프로젝트명
`wiznet-pico-c-docker` (가칭)

### 한 줄 목표
> **WIZnet 이더넷 보드(10종)에서 C 예제(16종)를 간편하게 빌드하는 Docker 기반 빌드 시스템**

### 대상 사용자
- WIZnet 이더넷 보드 구매 고객
- 예제 코드를 빌드하여 테스트하고 싶은 개발자
- 환경 설정 없이 빠르게 예제를 실행하고 싶은 메이커

### 기존 문제점
- ❌ Windows + VS Code + Extension 설치 필요
- ❌ Pico SDK, ARM GCC 툴체인 수동 설치
- ❌ 라이브러리 의존성 설정 복잡 (ioLibrary_Driver, mbedtls)
- ❌ 보드별 설정 변경 번거로움 (CMakeLists.txt 수동 수정)
- ❌ 크로스 플랫폼 환경 구축 어려움

### 제공 솔루션
- ✅ Docker 한 줄 명령으로 빌드 환경 완성
- ✅ 10가지 보드 선택만으로 최적화 설정 자동 적용
- ✅ 16가지 예제 중 원하는 것만 선택 빌드
- ✅ 즉시 사용 가능한 .uf2 파일 생성
- ✅ Windows/Linux/macOS 동일 환경

---

## 🎯 핵심 차이점 (vs w55rp20-docker-build)

| 항목 | w55rp20-docker-build | wiznet-pico-c-docker |
|------|---------------------|---------------------|
| **타겟 보드** | W55RP20 단일 보드 | 10종 WIZnet 보드 |
| **프로젝트** | W55RP20-S2E 펌웨어 | WIZnet-PICO-C 예제 모음 |
| **목적** | S2E 펌웨어 빌드 | 16가지 예제 빌드 |
| **사용자** | W55RP20 사용자 | 모든 WIZnet 보드 사용자 |
| **보드 선택** | 불필요 (고정) | 필수 (Interactive) |
| **예제 선택** | N/A | 필수 (16개 중 선택) |
| **CMake 수정** | 불필요 | BOARD_NAME 자동 설정 |

---

## 🔧 지원 하드웨어 (10종)

### RP2040 기반 (6종)

| 모델명 | 이더넷 칩 | BOARD_NAME | 특징 |
|--------|----------|-----------|------|
| WIZnet Ethernet HAT | W5100S | `WIZnet_Ethernet_HAT` | Raspberry Pi HAT 폼팩터 |
| W5100S-EVB-Pico | W5100S | `W5100S_EVB_PICO` | 16KB 버퍼 |
| W5500-EVB-Pico | W5500 | `W5500_EVB_PICO` | **권장**, 32KB 버퍼 |
| W55RP20-EVB-Pico | W55RP20 | `W55RP20_EVB_PICO` | RP2040+W5500 SiP, PIO 기반 |
| W6100-EVB-Pico | W6100 | `W6100_EVB_PICO` | IPv6 지원 |
| W6300-EVB-Pico | W6300 | `W6300_EVB_PICO` | QSPI, IPv6, PIO 기반 |

### RP2350 기반 (4종)

| 모델명 | 이더넷 칩 | BOARD_NAME | 특징 |
|--------|----------|-----------|------|
| W5100S-EVB-Pico2 | W5100S | `W5100S_EVB_PICO2` | Pico2 (RP2350) |
| W5500-EVB-Pico2 | W5500 | `W5500_EVB_PICO2` | Pico2 (RP2350) |
| W6100-EVB-Pico2 | W6100 | `W6100_EVB_PICO2` | Pico2 (RP2350) |
| W6300-EVB-Pico2 | W6300 | `W6300_EVB_PICO2` | Pico2 (RP2350), QSPI |

### 보드별 특수 설정

**W6300 계열 (W6300_EVB_PICO, W6300_EVB_PICO2):**
- QSPI 모드: `QSPI_QUAD_MODE` (기본값)
- 다른 옵션: `QSPI_DUAL_MODE`, `QSPI_SINGLE_MODE`

**W55RP20, W6300 계열:**
- SPI/QSPI가 PIO로 구현됨
- 관련 파일: `port/wizchip_qspi_pio.c`

**모든 보드:**
- SPI 클록 속도: 40MHz (기본값)
- 설정: `add_definitions(-D_WIZCHIP_SPI_SCLK_SPEED=40)`

---

## 📦 지원 예제 (16종)

### 기본 네트워킹 (4개)

| 예제명 | 디렉토리 | 용도 | 난이도 |
|--------|---------|------|--------|
| Loopback | `loopback` | 루프백 테스트 | ⭐ 초급 |
| UDP | `udp` | UDP 통신 | ⭐ 초급 |
| HTTP Server | `http` | HTTP 서버 | ⭐⭐ 중급 |
| TCP Multi Socket | `tcp_server_multi_socket` | 다중 소켓 서버 | ⭐⭐⭐ 고급 |

### 프로토콜 (7개)

| 예제명 | 디렉토리 | 용도 | 난이도 |
|--------|---------|------|--------|
| DHCP & DNS | `dhcp_dns` | 동적 IP, DNS | ⭐⭐ 중급 |
| SNTP | `sntp` | 시간 동기화 | ⭐⭐ 중급 |
| MQTT | `mqtt` | MQTT Pub/Sub | ⭐⭐ 중급 |
| TFTP | `tftp` | TFTP 파일 전송 | ⭐⭐ 중급 |
| NetBIOS | `netbios` | NetBIOS 이름 해석 | ⭐⭐⭐ 고급 |
| PPPoE | `pppoe` | PPPoE 연결 | ⭐⭐⭐ 고급 |
| UPnP | `upnp` | UPnP 프로토콜 | ⭐⭐⭐ 고급 |

### 보안 통신 (2개)

| 예제명 | 디렉토리 | 용도 | 난이도 |
|--------|---------|------|--------|
| TCP Client SSL | `tcp_client_over_ssl` | SSL/TLS 클라이언트 | ⭐⭐⭐ 고급 |
| TCP Server SSL | `tcp_server_over_ssl` | SSL/TLS 서버 | ⭐⭐⭐ 고급 |

### 고급 기능 (3개)

| 예제명 | 디렉토리 | 용도 | 난이도 |
|--------|---------|------|--------|
| UDP Multicast | `udp_multicast` | 멀티캐스트 | ⭐⭐⭐ 고급 |
| CAN | `can` | CAN 통신 | ⭐⭐⭐ 고급 |
| Network Install | `network_install` | 네트워크 설치 | ⭐⭐⭐ 고급 |

**총 16개 예제 모두 무조건 빌드됨 (조건부 제외 없음)**

---

## 🏗️ 기술 스택

### Docker 환경 (기존과 100% 동일)

```yaml
Base Image: Ubuntu 22.04
Build System: CMake 3.28.3 + Ninja
Compiler: ARM GNU Toolchain 14.2.rel1
SDK: Raspberry Pi Pico SDK 2.2.0
Caching: ccache (tmpfs 기반)
Languages: Bash, PowerShell, Python 3
```

### 필수 라이브러리 (서브모듈)

```yaml
pico-sdk: libraries/pico-sdk
ioLibrary_Driver: libraries/ioLibrary_Driver (WIZnet 칩 드라이버)
mbedtls: libraries/mbedtls (SSL/TLS 지원)
```

**Git 클론 시 필수:**
```bash
git clone --recurse-submodules https://github.com/WIZnet-ioNIC/WIZnet-PICO-C.git
```

### 재사용 가능 컴포넌트

| 파일 | 재사용 방법 | 수정 사항 |
|------|-----------|---------|
| `Dockerfile` | ✅ 복사 후 최적화 | Pico SDK 설치 제거, PICO_SDK_PATH 제거 |
| `docker-build.sh` | ✅ 복사 후 수정 | PICO_SDK_PATH 전달 제거, 서브모듈 검증 추가 |
| `entrypoint.sh` | ✅ 100% 그대로 | 없음 |
| `.gitignore` | ✅ 복사 | 없음 |
| `build.sh` | ❌ | 새로 작성 (보드/예제 선택) |
| `build.ps1` | ❌ | 새로 작성 (Windows) |
| `README.md` | ❌ | 새로 작성 |

**DockerHub 이미지: 재사용하지 않음 → 새로 빌드**
- 이유: 독립성, 최신 패키지, 이미지 최적화 (300MB 절약)

---

## 📂 프로젝트 구조

```
wiznet-pico-c-docker/
├── Dockerfile                 # w55rp20에서 복사 (수정 없음)
├── entrypoint.sh              # w55rp20에서 복사 (수정 없음)
├── docker-build.sh            # w55rp20에서 복사 (수정 없음)
├── build.sh                   # 새로 작성 (핵심)
├── build.ps1                  # 새로 작성 (Windows)
├── .gitignore                 # w55rp20에서 복사
├── README.md                  # 새로 작성
├── LICENSE                    # MIT or Apache 2.0
│
├── docs/
│   ├── WCC.md                 # WIZnet Community Contents 기사
│   ├── QUICKSTART.md          # 3단계 빠른 시작
│   ├── BOARD_LIST.md          # 보드 상세 스펙
│   ├── EXAMPLES.md            # 예제 상세 설명
│   └── TROUBLESHOOTING.md     # 문제 해결
│
├── examples/
│   └── .gitkeep               # WIZnet-PICO-C는 빌드 시 클론
│
└── .github/
    └── workflows/
        └── docker-image.yml   # DockerHub 자동 빌드 (선택)
```

---

## 🔨 build.sh 요구사항

### 기본 사용법

```bash
# Interactive 모드 (초보자 권장)
./build.sh -i
./build.sh --interactive

# 보드 지정 + 전체 예제
./build.sh --board W5500_EVB_PICO --all

# 보드 + 특정 예제
./build.sh --board W5500_EVB_PICO --example http

# 보드 + 여러 예제
./build.sh --board W5500_EVB_PICO --example "http mqtt udp"

# 디버그 빌드
./build.sh --board W5500_EVB_PICO --example http --debug

# 빌드 정리
./build.sh --clean

# 도움말
./build.sh --help
```

### Interactive 모드 흐름

```
╔══════════════════════════════════════════════════════════╗
║  WIZnet-PICO-C Docker Build System v1.0.0               ║
╚══════════════════════════════════════════════════════════╝

[1/3] 보드 선택
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

어떤 보드를 사용하시나요?

  RP2040 기반:
  1) WIZnet Ethernet HAT      (W5100S)
  2) W5100S-EVB-Pico          (W5100S)
  3) W5500-EVB-Pico           (W5500) ← 권장
  4) W55RP20-EVB-Pico         (W55RP20 SiP)
  5) W6100-EVB-Pico           (W6100 IPv6)
  6) W6300-EVB-Pico           (W6300 QSPI)

  RP2350 (Pico2) 기반:
  7) W5100S-EVB-Pico2         (W5100S)
  8) W5500-EVB-Pico2          (W5500)
  9) W6100-EVB-Pico2          (W6100)
  10) W6300-EVB-Pico2         (W6300)

선택 [1-10]: 3

✓ 선택: W5500-EVB-Pico (W5500 칩, RP2040)

[2/3] 예제 선택
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

빌드할 예제를 선택하세요:

  0) 전체 빌드 (16개 모두, 약 10분)

  기본 네트워킹:
  1) loopback              - 루프백 테스트 ⭐
  2) udp                   - UDP 통신 ⭐
  3) http                  - HTTP 서버 ⭐⭐
  4) tcp_server_multi      - 다중 소켓 서버 ⭐⭐⭐

  프로토콜:
  5) dhcp_dns              - DHCP & DNS ⭐⭐
  6) sntp                  - 시간 동기화 ⭐⭐
  7) mqtt                  - MQTT Pub/Sub ⭐⭐
  8) tftp                  - TFTP 전송 ⭐⭐
  9) netbios               - NetBIOS ⭐⭐⭐
  10) pppoe                - PPPoE ⭐⭐⭐
  11) upnp                 - UPnP ⭐⭐⭐

  보안:
  12) tcp_client_ssl       - SSL 클라이언트 ⭐⭐⭐
  13) tcp_server_ssl       - SSL 서버 ⭐⭐⭐

  고급:
  14) udp_multicast        - 멀티캐스트 ⭐⭐⭐
  15) can                  - CAN 통신 ⭐⭐⭐
  16) network_install      - 네트워크 설치 ⭐⭐⭐

선택 [0-16] (여러 개 입력 가능, 예: 1 2 3): 3

✓ 선택: http (HTTP 서버)

[3/3] 빌드 설정 확인
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

빌드 설정:
  보드:     W5500_EVB_PICO
  예제:     http
  빌드타입: Release
  Docker:   simryang/w55rp20:latest (재사용)

계속하시겠습니까? [Y/n]:
```

### 필수 기능 목록

1. **보드 선택 검증**
   - 잘못된 보드명 입력 시 에러 메시지
   - 올바른 BOARD_NAME 목록 제시

2. **예제 선택 검증**
   - 존재하지 않는 예제 입력 시 에러
   - 유효한 예제 목록 제시

3. **CMakeLists.txt 자동 수정**
   ```bash
   # BOARD_NAME 라인 수정
   sed -i "s/^set(BOARD_NAME .*/set(BOARD_NAME $BOARD)/" CMakeLists.txt
   ```

4. **서브모듈 자동 클론**
   ```bash
   git clone --recurse-submodules https://github.com/WIZnet-ioNIC/WIZnet-PICO-C.git

   # 이미 클론된 경우
   git submodule update --init --recursive
   ```

5. **산출물 자동 수집**
   ```bash
   # docker-build.sh가 자동으로 처리
   find /work/src/build -name "*.uf2" -exec cp {} /work/out/ \;
   ```

6. **빌드 후 안내**
   ```
   ✅ 빌드 성공! (소요 시간: 2:34)

   생성된 파일:
     → http.uf2  (234 KB)

   산출물 위치: ./out/http.uf2

   다음 단계:
     1. W5500-EVB-Pico를 USB로 연결
     2. BOOTSEL 버튼을 누른 채 RESET 버튼 클릭
     3. out/http.uf2를 드래그앤드롭
     4. 시리얼 터미널로 로그 확인 (115200 baud)
   ```

---

## 🪟 build.ps1 요구사항 (Windows)

### 기본 기능
- build.sh와 동일한 기능
- UTF-8 BOM 포함 (한글 출력 지원)
- PowerShell 5.1+ 지원

### Windows 특화 기능

1. **ExecutionPolicy 안내**
   ```powershell
   if (실행 정책 에러) {
       Write-Host "PowerShell 실행 정책 설정 필요:" -ForegroundColor Yellow
       Write-Host "  PowerShell -ExecutionPolicy Bypass -File build.ps1" -ForegroundColor Green
   }
   ```

2. **Docker Desktop 확인**
   ```powershell
   if (-not (docker info 2>$null)) {
       Write-Error "Docker Desktop이 실행되지 않았습니다"
       exit 1
   }
   ```

3. **WSL2 메모리 안내**
   ```powershell
   Write-Host "권장: WSL2 메모리 4GB 이상" -ForegroundColor Cyan
   ```

---

## 🔧 CMakeLists.txt 수정 전략

### 문제
사용자가 선택한 보드를 `WIZnet-PICO-C/CMakeLists.txt`에 반영 필요

### 현재 CMakeLists.txt 구조
```cmake
# 주석 처리된 옵션들
# set(BOARD_NAME WIZnet_Ethernet_HAT)
# set(BOARD_NAME W5100S_EVB_PICO)
# set(BOARD_NAME W5500_EVB_PICO)
...

# 활성화된 라인 (기본값: W6300_EVB_PICO2)
set(BOARD_NAME W6300_EVB_PICO2)
```

### 해결책: sed로 직접 수정 (권장)

```bash
BOARD="W5500_EVB_PICO"
PROJECT_DIR="WIZnet-PICO-C"

# 1. 모든 set(BOARD_NAME ...) 라인 주석 처리
sed -i 's/^set(BOARD_NAME /#set(BOARD_NAME /' "$PROJECT_DIR/CMakeLists.txt"

# 2. 선택한 보드만 활성화 (파일 끝에 추가)
echo "set(BOARD_NAME $BOARD)" >> "$PROJECT_DIR/CMakeLists.txt"

# 3. 검증
grep "^set(BOARD_NAME" "$PROJECT_DIR/CMakeLists.txt"
# 출력: set(BOARD_NAME W5500_EVB_PICO)
```

### 대안: CMake 캐시 변수 (확인 필요)

```bash
# CMakeLists.txt가 캐시 변수를 지원하면:
cmake -S . -B build -DBOARD_NAME=W5500_EVB_PICO ...
```

**확인 필요:** WIZnet-PICO-C의 CMakeLists.txt가 `-D` 옵션을 지원하는지?

---

## 🎨 개별 예제 빌드 방법

### 문제
16개 전체 빌드는 시간 소요 (첫 빌드 ~10분)

### 해결책 A: CMake 타겟 지정 (권장)

```bash
# 전체 프로젝트 configure
cmake -S WIZnet-PICO-C -B build -G Ninja ...

# 특정 예제만 빌드
cmake --build build --target http
```

**확인 필요:**
- 각 예제의 CMake 타겟명 = 디렉토리명인지?
- 예: `examples/http/CMakeLists.txt`의 타겟이 `http`인가?

### 해결책 B: examples/CMakeLists.txt 주석 처리

```bash
# 사용자가 http만 선택한 경우
cd WIZnet-PICO-C/examples

# http 외 모든 예제 주석 처리
for example in dhcp_dns mqtt sntp ...; do
    sed -i "s/add_subdirectory($example)/#add_subdirectory($example)/" CMakeLists.txt
done

# http만 남김
sed -i "s/#add_subdirectory(http)/add_subdirectory(http)/" CMakeLists.txt
```

### 해결책 C: 전체 빌드 후 타겟 파일만 복사

```bash
# 전체 빌드
cmake --build build

# 사용자가 선택한 예제의 .uf2만 out/에 복사
cp build/examples/http/*.uf2 out/
```

---

## 📤 산출물 관리

### 출력 구조

```
out/
├── loopback.uf2              # 124 KB
├── http.uf2                  # 234 KB
├── mqtt.uf2                  # 312 KB
├── tcp_client_over_ssl.uf2  # 456 KB
└── ...
```

### 네이밍 규칙

| 예제 디렉토리 | 산출물 파일명 |
|--------------|-------------|
| `examples/http/` | `http.uf2` |
| `examples/tcp_client_over_ssl/` | `tcp_client_over_ssl.uf2` |
| `examples/tcp_server_multi_socket/` | `tcp_server_multi_socket.uf2` |

### docker-build.sh (수정 불필요)

현재 로직이 자동으로 모든 .uf2 수집:
```bash
find /work/src/build -type f -name "*.uf2" -exec cp -f {} /work/out/ \;
```

---

## 📖 README.md 구조

### 1. 프로젝트 소개

```markdown
# WIZnet-PICO-C Docker Build System

**WIZnet 이더넷 보드용 C 예제를 3분 안에 빌드하는 Docker 기반 시스템**

- 🎯 **10가지 보드 지원**: W5100S ~ W6300, RP2040 & RP2350
- 📦 **16가지 예제**: HTTP, MQTT, SSL, UDP 등
- ⚡ **빠른 빌드**: ccache로 12초 (2회차 이후)
- 🌍 **크로스 플랫폼**: Windows/Linux/macOS

## Why Docker?

| 기존 방식 ❌ | Docker 방식 ✅ |
|-----------|-------------|
| VS Code Extension 설치 | Docker만 설치 |
| 수동 라이브러리 설정 | 자동 의존성 해결 |
| 보드 변경 시 재설정 | 선택만으로 자동 적용 |
| Windows 전용 | 모든 OS 동일 환경 |
```

### 2. 지원 하드웨어

```markdown
## 지원 보드 (10종)

### RP2040 기반

| 보드 | 칩 | 구매 링크 | 특징 |
|------|-----|---------|------|
| W5500-EVB-Pico | W5500 | [구매](링크) | **권장** |
| W55RP20-EVB-Pico | W55RP20 | [구매](링크) | SiP |
| W6100-EVB-Pico | W6100 | [구매](링크) | IPv6 |
| ... | ... | ... | ... |

### RP2350 (Pico2) 기반

...
```

### 3. 빠른 시작 (3단계)

```markdown
## 빠른 시작

### 사전 요구사항
- Docker Desktop 설치
- Git 설치
- 10GB 이상 여유 공간

### 1단계: 저장소 클론
\```bash
git clone https://github.com/simryang/wiznet-pico-c-docker
cd wiznet-pico-c-docker
\```

### 2단계: 빌드 (Interactive 모드)
\```bash
# Linux/macOS
./build.sh -i

# Windows PowerShell
.\build.ps1 -Interactive
\```

**화면 안내에 따라 보드와 예제를 선택하세요.**

### 3단계: 펌웨어 업로드
1. 보드를 USB로 연결
2. BOOTSEL 버튼 누른 채 RESET 클릭
3. `out/http.uf2`를 드래그앤드롭
4. 시리얼 터미널 열기 (115200 baud)

**축하합니다! 🎉 예제가 실행 중입니다.**
```

### 4. 고급 사용법

```markdown
## 고급 사용법

### 명령행 빌드

\```bash
# 특정 보드 + 예제
./build.sh --board W5500_EVB_PICO --example http

# 여러 예제 동시 빌드
./build.sh --board W5500_EVB_PICO --example "http mqtt udp"

# 전체 예제 빌드
./build.sh --board W5500_EVB_PICO --all

# 디버그 빌드
./build.sh --board W5500_EVB_PICO --example http --debug
\```

### 빌드 옵션

| 옵션 | 설명 | 예시 |
|------|------|------|
| `--board` | 보드 선택 (필수) | `W5500_EVB_PICO` |
| `--example` | 예제 선택 | `http` |
| `--all` | 전체 예제 빌드 | - |
| `--debug` | 디버그 빌드 | - |
| `--clean` | 빌드 정리 | - |
| `-i, --interactive` | Interactive 모드 | - |
```

### 5. 예제 목록

```markdown
## 지원 예제 (16종)

| 카테고리 | 예제 | 용도 | 난이도 |
|---------|------|------|--------|
| 기본 | loopback | 루프백 테스트 | ⭐ |
| 기본 | udp | UDP 통신 | ⭐ |
| 기본 | http | HTTP 서버 | ⭐⭐ |
| ... | ... | ... | ... |

[전체 예제 상세 설명 →](docs/EXAMPLES.md)
```

### 6. 트러블슈팅

```markdown
## 트러블슈팅

### Docker 권한 오류
\```bash
sudo usermod -aG docker $USER
newgrp docker
\```

### WSL2 메모리 부족
`.wslconfig` 파일 생성:
\```ini
[wsl2]
memory=4GB
\```

### 빌드 실패
\```bash
# 빌드 정리 후 재시도
./build.sh --clean
./build.sh --board W5500_EVB_PICO --example http
\```

[더 많은 문제 해결 →](docs/TROUBLESHOOTING.md)
```

---

## 🎨 WCC.md 구조 (핵심)

### 메타데이터

```yaml
---
Title (EN): WIZnet Pico Ethernet Examples - Docker Build System
Summary (EN): Build 16 Ethernet examples for 10 WIZnet boards in 3 steps. No complex setup, just Docker and 3 minutes.

Title (KR): WIZnet Pico 이더넷 예제 - Docker 빌드 시스템
Summary (KR): WIZnet 보드 10종의 이더넷 예제 16개를 3단계로 빌드. 복잡한 설정 없이 Docker 하나면 끝.

Keywords: WIZnet, W5500, W6100, W55RP20, Pico, RP2040, RP2350, Docker, Ethernet, Examples, MQTT, HTTP, SSL

Hardware:
  - W5500-EVB-Pico (권장)
  - W6100-EVB-Pico
  - W55RP20-EVB-Pico
  - W6300-EVB-Pico
  - 기타 6종

Software:
  - Docker Desktop
  - Git

Repository: https://github.com/simryang/wiznet-pico-c-docker
---
```

### 스토리 구성

#### Before (기존 방식의 고통)

```markdown
## 예제 빌드가 이렇게 복잡했나요?

**WIZnet 보드를 샀는데 예제만 실행하려다 좌절한 경험 있으신가요?**

### 기존 방식의 문제점

❌ **1단계: 개발 환경 설치 (1시간)**
- Windows 필수 (Linux/macOS 사용자 포기)
- Visual Studio Code 설치
- Raspberry Pi Pico Extension 설치
- ARM GCC 툴체인 다운로드 (1.2GB)
- Pico SDK 설치

❌ **2단계: 라이브러리 설정 (30분)**
- ioLibrary_Driver 서브모듈 클론
- mbedtls 서브모듈 클론
- 경로 설정 (환경변수 지옥)

❌ **3단계: 보드 설정 (10분)**
- CMakeLists.txt 수동 수정
- BOARD_NAME 찾아서 변경
- SPI 속도 설정

❌ **4단계: 빌드... 그리고 오류 (???)**
- "pico-sdk not found"
- "arm-none-eabi-gcc: command not found"
- "서브모듈이 초기화되지 않았습니다"

**결과: 예제 하나 빌드하는 데 반나절 소요 😭**
```

#### After (Docker의 마법)

```markdown
## Docker로 3분 안에 해결!

### 새로운 방식: 3단계 완성

✅ **1단계: 클론 (10초)**
\```bash
git clone https://github.com/simryang/wiznet-pico-c-docker
cd wiznet-pico-c-docker
\```

✅ **2단계: 빌드 (2분 30초)**
\```bash
./build.sh -i

> 보드 선택: 3) W5500-EVB-Pico
> 예제 선택: 3) http
> 계속? Y
\```

✅ **3단계: 업로드 (10초)**
- BOOTSEL + RESET
- out/http.uf2 드래그앤드롭

**끝! 🎉**

### 빌드 시간 비교

| 방식 | 첫 빌드 | 2회차 이후 |
|------|---------|-----------|
| 기존 (수동) | 반나절 | 3-5분 |
| Docker | 6분 | **12초** ⚡ |
```

### 핵심 메시지

```markdown
## 왜 이 프로젝트가 필요한가?

> **"WIZnet 보드를 샀는데, 예제만 실행하려다 포기하셨나요?"**

WIZnet는 10가지 이더넷 보드를 판매합니다.
각 보드마다 16가지 예제 코드를 제공합니다.
그런데... **빌드 환경 구축이 너무 복잡합니다.**

**이 프로젝트는 그 문제를 해결합니다.**

- ✅ 10가지 보드 모두 지원
- ✅ 16가지 예제 모두 빌드 가능
- ✅ 보드 선택만으로 자동 최적화
- ✅ Windows/Linux/macOS 동일 환경
- ✅ 3분이면 끝

**고객이 원하는 건 "예제 실행"이지, "환경 구축"이 아닙니다.**
```

### 빌드 시연 (스크린샷 8장)

```markdown
## 실제 빌드 과정 (스크린샷)

### 1. Interactive 모드 시작
![빌드 시작](screenshots/01_build_start.png)
*Docker Desktop 확인 및 빌드 시작*

### 2. 보드 선택
![보드 선택](screenshots/02_board_select.png)
*10가지 보드 중 W5500-EVB-Pico 선택*

### 3. 예제 선택
![예제 선택](screenshots/03_example_select.png)
*16가지 예제 중 HTTP 서버 선택*

### 4. 빌드 진행
![빌드 진행](screenshots/04_build_progress.png)
*Docker 이미지 다운로드 (첫 실행만)*

### 5. CPU 사용률
![CPU 사용](screenshots/05_cpu_usage.png)
*멀티코어 병렬 빌드 (Ninja)*

### 6. 빌드 성공
![빌드 성공](screenshots/06_build_success.png)
*산출물 위치 안내*

### 7. 산출물 확인
![산출물](screenshots/07_output_files.png)
*out/http.uf2 생성 완료*

### 8. 펌웨어 업로드
![업로드](screenshots/08_upload.png)
*드래그앤드롭으로 펌웨어 설치*
```

### FAQ 섹션

```markdown
## 자주 묻는 질문

### Q1: 어떤 보드를 사용해야 하나요?
**A:** 처음이라면 **W5500-EVB-Pico** 권장
- 가격: 약 $10
- 안정성: 검증된 W5500 칩
- 호환성: 가장 많은 예제 지원
- 구매: [WIZnet 공식몰](링크)

### Q2: 예제를 수정하고 싶어요
**A:** 빌드 후 `WIZnet-PICO-C/` 디렉토리가 남아있습니다.
\```bash
cd WIZnet-PICO-C/examples/http
# 코드 수정
nano main.c

# 재빌드
cd ../../..
./build.sh --board W5500_EVB_PICO --example http
\```

### Q3: Windows에서도 되나요?
**A:** 네! PowerShell 스크립트 제공
\```powershell
.\build.ps1 -Interactive
\```

### Q4: Mac에서도 되나요?
**A:** 네! Intel/Apple Silicon 모두 지원
- Docker Desktop for Mac 설치
- `./build.sh -i` 실행

### Q5: Linux는요?
**A:** 물론입니다! 가장 빠릅니다.
- Docker Engine 설치
- `./build.sh -i` 실행

### Q6: 빌드 시간이 얼마나 걸리나요?
**A:**
- 첫 빌드: ~6분 (Docker 이미지 다운로드 포함)
- 2회차: ~12초 (ccache 덕분) ⚡
- 전체 16개 예제: ~10분

### Q7: 용량이 얼마나 필요한가요?
**A:**
- Docker 이미지: 2.5GB
- 프로젝트 소스: 50MB
- 빌드 산출물: 100MB
- **총 권장: 10GB 여유 공간**

### Q8: IPv6 예제도 되나요?
**A:** W6100/W6300 보드를 선택하면 IPv6 지원 예제 빌드 가능

### Q9: SSL/TLS 예제도 빌드되나요?
**A:** 네! mbedtls가 자동으로 포함됩니다.
- tcp_client_over_ssl
- tcp_server_over_ssl

### Q10: 문제가 생기면 어디에 문의하나요?
**A:** [GitHub Issues](https://github.com/simryang/wiznet-pico-c-docker/issues)
```

---

## 🐳 DockerHub 이미지 전략

### 기존 이미지 재사용 (권장)

```bash
# w55rp20 프로젝트의 이미지 그대로 사용
docker pull simryang/w55rp20:latest
```

**재사용 가능 이유 (상세 분석):**

1. **빌드 도구 100% 호환**
   - ✅ ARM GCC 14.2.rel1 (정확히 일치)
   - ✅ CMake 3.28.3 (WIZnet-PICO-C는 3.13+ 요구)
   - ✅ Ninja (빌드 시스템)
   - ✅ ccache (빌드 캐싱)

2. **라이브러리 충돌 없음**
   - WIZnet-PICO-C는 **모든 라이브러리를 서브모듈로 관리**
   - Docker 이미지의 `/opt/pico-sdk`는 **사용되지 않음** (CMakeLists.txt에서 서브모듈 우선)
   - ioLibrary_Driver, mbedtls는 **소스로 빌드**됨 (미리 설치 불필요)

3. **빌드 흐름**
   ```
   git clone --recurse-submodules (서브모듈 다운로드)
   → cmake 실행 (libraries/ 내 소스 사용)
   → add_subdirectory() (ioLibrary, mbedtls 함께 컴파일)
   → 최종 .uf2 생성
   ```

4. **검증 방법**
   - 빌드 로그에서 `"Using PICO_SDK_PATH from: /work/src/libraries/pico-sdk"` 확인
   - Docker의 `/opt/pico-sdk`가 아닌 서브모듈 사용

### build.sh에서 이미지 지정

```bash
IMAGE="simryang/w55rp20:latest"

# 또는 더 명확한 이름
IMAGE="simryang/wiznet-pico:latest"
```

### (선택) 전용 이미지 생성

```bash
# 기존 이미지 태그만 변경
docker tag simryang/w55rp20:latest simryang/wiznet-pico:latest
docker push simryang/wiznet-pico:latest
```

**장점:**
- 프로젝트별 명확한 이미지명
- 버전 관리 독립성

**단점:**
- DockerHub 스토리지 중복
- 관리 포인트 증가

**결론:** 첫 버전은 `simryang/w55rp20:latest` 재사용, 필요시 나중에 분리

---

## 🚀 개발 우선순위 및 일정

### Phase 1: MVP (최소 기능 제품) - 1일

**목표:** W5500-EVB-Pico + http 예제 빌드 성공

- [ ] **저장소 생성 (30분)**
  - GitHub 저장소 생성
  - w55rp20에서 파일 복사 (Dockerfile, docker-build.sh, entrypoint.sh)
  - .gitignore 설정

- [ ] **build.sh 작성 (2시간)**
  - 보드 선택 기능 (--board 옵션)
  - 예제 선택 기능 (--example 옵션)
  - CMakeLists.txt 수정 로직
  - WIZnet-PICO-C 클론 (--recurse-submodules)
  - Docker 빌드 실행

- [ ] **테스트 (1시간)**
  - W5500-EVB-Pico + http 빌드
  - 산출물 확인 (out/http.uf2)
  - 실제 보드에 업로드 테스트

- [ ] **README.md 작성 (1시간)**
  - 빠른 시작 가이드
  - 명령행 사용법
  - 트러블슈팅 기본 항목

**결과물:** 기본 빌드 시스템 동작

---

### Phase 2: Interactive 모드 & Windows - 0.5일

- [ ] **Interactive 모드 (2시간)**
  - 보드 선택 UI (1-10 번호 입력)
  - 예제 선택 UI (0-16 번호 입력)
  - 빌드 설정 확인 화면

- [ ] **build.ps1 작성 (2시간)**
  - UTF-8 BOM 추가
  - PowerShell 문법 변환
  - ExecutionPolicy 안내
  - Interactive 모드 동일 구현

**결과물:** 초보자 친화적 UI

---

### Phase 3: WCC 문서 - 0.5일

- [ ] **스크린샷 촬영 (1시간)**
  - Interactive 모드 실행 (8장)
  - 각 단계별 화면 캡처
  - 이미지 편집 (설명 추가)

- [ ] **WCC.md 작성 (2시간)**
  - 메타데이터 (제목, 요약, 키워드)
  - Before/After 스토리
  - 빌드 시연 섹션
  - FAQ 10개
  - SEO/AEO 최적화

- [ ] **docs/ 디렉토리 정리 (1시간)**
  - QUICKSTART.md
  - BOARD_LIST.md
  - EXAMPLES.md
  - TROUBLESHOOTING.md

**결과물:** WCC 투고 준비 완료

---

### Phase 4: 고급 기능 (선택, 1일)

- [ ] **다중 예제 빌드**
  ```bash
  ./build.sh --board W5500_EVB_PICO --example "http mqtt udp"
  ```

- [ ] **커스텀 설정**
  ```bash
  ./build.sh --board W6300_EVB_PICO --qspi-mode DUAL
  ./build.sh --board W5500_EVB_PICO --spi-speed 80
  ```

- [ ] **빌드 캐시 관리**
  ```bash
  ./build.sh --cache-stats  # ccache 통계
  ./build.sh --cache-clear  # ccache 초기화
  ```

- [ ] **CI/CD**
  - GitHub Actions: 자동 빌드 테스트
  - DockerHub: 이미지 자동 빌드

**결과물:** 프로 개발자용 고급 기능

---

## ✅ 성공 지표

### 기술적 검증

- [ ] **10개 보드 모두 빌드 성공**
  - WIZnet_Ethernet_HAT ✓
  - W5100S_EVB_PICO ✓
  - W5500_EVB_PICO ✓
  - W55RP20_EVB_PICO ✓
  - W6100_EVB_PICO ✓
  - W6300_EVB_PICO ✓
  - W5100S_EVB_PICO2 ✓
  - W5500_EVB_PICO2 ✓
  - W6100_EVB_PICO2 ✓
  - W6300_EVB_PICO2 ✓

- [ ] **16개 예제 모두 .uf2 생성**
  - loopback.uf2 ✓
  - udp.uf2 ✓
  - http.uf2 ✓
  - ... (13개 더)

- [ ] **성능 목표**
  - 첫 빌드: 6분 이내
  - ccache 적용 후: 12초 이내
  - Docker 이미지 크기: 3GB 이하

- [ ] **크로스 플랫폼 동작**
  - Linux (Ubuntu 22.04) ✓
  - macOS (Intel + Apple Silicon) ✓
  - Windows 11 (WSL2) ✓

### 사용자 경험 검증

- [ ] **3단계 빌드 완성**
  - 클론 → 빌드 → 업로드
  - 5분 이내 완료

- [ ] **Interactive 모드**
  - 3번 입력만으로 빌드 완료
  - 명확한 안내 메시지

- [ ] **에러 처리**
  - 잘못된 보드명: 유효한 목록 제시
  - 잘못된 예제명: 유효한 목록 제시
  - Docker 미실행: 설치 가이드 링크

### 문서 완성도

- [ ] **README.md**
  - 3단계 빠른 시작 ✓
  - 지원 보드 테이블 ✓
  - 지원 예제 테이블 ✓
  - 트러블슈팅 ✓

- [ ] **WCC.md**
  - 메타데이터 (제목, 요약, 키워드) ✓
  - Before/After 스토리 ✓
  - 8장 스크린샷 ✓
  - FAQ 10개 ✓

---

## 🎓 학습 포인트 (개발 시 유의사항)

### CMakeLists.txt 수정 시 주의

1. **백업 필수**
   ```bash
   cp CMakeLists.txt CMakeLists.txt.bak
   ```

2. **수정 후 검증**
   ```bash
   grep "^set(BOARD_NAME" CMakeLists.txt
   ```

3. **Git 상태 확인**
   ```bash
   # CMakeLists.txt는 .gitignore에 추가하지 않음
   # 사용자가 수정할 수 있도록 추적
   ```

### 서브모듈 처리

1. **초기 클론**
   ```bash
   git clone --recurse-submodules https://github.com/WIZnet-ioNIC/WIZnet-PICO-C.git
   ```

2. **이미 클론된 경우**
   ```bash
   git submodule update --init --recursive
   ```

3. **서브모듈 확인**
   ```bash
   ls -la WIZnet-PICO-C/libraries/
   # pico-sdk/, ioLibrary_Driver/, mbedtls/ 존재 확인
   ```

### Docker 빌드 디버깅

1. **컨테이너 내부 접근**
   ```bash
   docker run -it --rm \
     -v $(pwd)/WIZnet-PICO-C:/work/src \
     simryang/w55rp20:latest \
     bash

   # 내부에서 수동 빌드 테스트
   cmake -S /work/src -B /work/src/build ...
   ```

2. **로그 확인**
   ```bash
   # docker-build.sh 출력 저장
   docker run ... > build.log 2>&1
   ```

### 예제별 CMake 타겟 확인

```bash
# 타겟 목록 확인
cmake --build build --target help

# 또는
ninja -C build -t targets
```

---

## 📦 최종 체크리스트

### 코드

- [ ] `Dockerfile` 복사 및 확인
- [ ] `docker-build.sh` 복사 및 확인
- [ ] `entrypoint.sh` 복사 및 확인
- [ ] `build.sh` 작성 및 테스트
- [ ] `build.ps1` 작성 및 테스트
- [ ] `.gitignore` 설정
- [ ] `LICENSE` 추가 (MIT or Apache 2.0)

### 문서

- [ ] `README.md` (빠른 시작, 사용법, FAQ)
- [ ] `docs/WCC.md` (WIZnet Community Contents)
- [ ] `docs/QUICKSTART.md` (3단계 가이드)
- [ ] `docs/BOARD_LIST.md` (보드 상세 스펙)
- [ ] `docs/EXAMPLES.md` (예제 상세 설명)
- [ ] `docs/TROUBLESHOOTING.md` (문제 해결)

### 테스트

- [ ] W5500-EVB-Pico + http 빌드
- [ ] W6100-EVB-Pico + mqtt 빌드 (IPv6)
- [ ] W6300-EVB-Pico + tcp_client_ssl 빌드 (QSPI + SSL)
- [ ] Windows 환경 테스트 (build.ps1)
- [ ] macOS 환경 테스트 (Intel + M1)

### 배포

- [ ] GitHub 저장소 생성
- [ ] DockerHub 이미지 준비 (simryang/w55rp20:latest 재사용)
- [ ] WCC 기사 투고
- [ ] README 뱃지 추가 (Docker pulls, Stars 등)

---

## 🔗 참고 자료

### 공식 저장소
- WIZnet-PICO-C: https://github.com/WIZnet-ioNIC/WIZnet-PICO-C
- w55rp20-docker-build: https://github.com/simryang/w55rp20-docker-build

### WIZnet 제품
- 제품 페이지: https://www.wiznet.io/
- 구매: https://www.wiznet.io/where-to-buy/

### Docker
- Docker Desktop: https://www.docker.com/products/docker-desktop
- DockerHub: https://hub.docker.com/

### Raspberry Pi Pico
- Pico SDK: https://github.com/raspberrypi/pico-sdk
- Getting Started: https://datasheets.raspberrypi.com/pico/getting-started-with-pico.pdf

---

## 📝 변경 이력

| 버전 | 날짜 | 변경 사항 |
|------|------|-----------|
| 1.0.0 | 2026-01-30 | 초기 명세서 작성 |

---

**작성자:** simryang
**라이선스:** MIT
**문의:** GitHub Issues
