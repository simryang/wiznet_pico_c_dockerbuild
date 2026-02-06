# WIZnet-PICO-C Docker Build System

> **WIZnet 이더넷 보드(10종)용 C 예제(16종)를 6초 만에 빌드하는 초고속 Docker 시스템**

[![Build Status](https://img.shields.io/badge/build-passing-brightgreen)]()
[![Docker](https://img.shields.io/badge/docker-ready-blue)]()
[![Platform](https://img.shields.io/badge/platform-linux%20%7C%20windows%20%7C%20macos-lightgrey)]()

---

## 🚀 빠른 시작 (Windows)

### 1️⃣ 준비물 설치

**필수 프로그램 2개만 설치:**

1. **Docker Desktop**: https://www.docker.com/products/docker-desktop
   - 다운로드 → 설치 → 재부팅
   - 설치 후 Docker Desktop 실행 (시스템 트레이 확인)

2. **Git for Windows**: https://git-scm.com/download/win
   - 다운로드 → 설치 (기본 옵션 그대로)

---

### 2️⃣ 빌드 실행 (Copy & Paste)

**PowerShell 또는 Git Bash 열고 아래 명령어 복사 후 실행:**

```powershell
git clone https://github.com/simryang/wiznet-pico-c-docker
cd wiznet-pico-c-docker
powershell -ExecutionPolicy Bypass -File .\build.ps1 -Interactive
```

> **💡 참고:** `powershell -ExecutionPolicy Bypass`는 스크립트 실행 권한 문제를 우회합니다.
> 또는 PowerShell을 관리자 권한으로 열고 `Set-ExecutionPolicy RemoteSigned -Scope CurrentUser` 실행 후 `.\build.ps1 -Interactive`로 간단히 실행 가능합니다.

**대화형 모드 진행 방법:**

1. **보드 선택** 화면이 나오면:
   - RP2040 보드: `1-6` 입력 → Enter
   - RP2350 보드: `7-10` 입력 → Enter
   - 권장: `3` (W5500-EVB-Pico)

2. **예제 선택** 화면이 나오면:
   - 전체 빌드: `0` 입력 → Enter
   - 개별 예제: `1-16` 입력 → Enter (여러 개 가능: `3 7 12`)

3. **빌드 설정 확인** 화면이 나오면:
   - 계속 진행: `y` 입력 → Enter (또는 그냥 Enter)

**이후 자동 진행:**
- WIZnet-PICO-C 저장소 클론 (최초 1회)
- 서브모듈 초기화 (pico-sdk, mbedtls 등)
- Docker 빌드 실행
- 완료 메시지 및 산출물 위치 안내

---

### 3️⃣ 완료!

**산출물 위치:** `.\out\*.uf2`

**소요 시간:**
- 최초 빌드: 약 45초
- 재빌드 (ccache): 약 6초 ⚡ (87% 개선!)

**펌웨어 업로드 방법:**
1. 보드를 USB로 연결
2. BOOTSEL 버튼을 누른 채 RESET 버튼 클릭
3. `.\out\*.uf2` 파일을 드래그앤드롭
4. 시리얼 터미널로 로그 확인 (115200 baud)

---

## 💡 다음 빌드부터는

### 간단 실행

**자동 모드 (이전 설정 재사용):**
```powershell
.\build.ps1
```

**대화형 모드 (보드/예제 다시 선택):**
```powershell
.\build.ps1 -Interactive
```

### 주요 옵션

**보드 및 예제 지정:**
```powershell
.\build.ps1 -Board W5500_EVB_PICO -All                # 전체 예제 빌드
.\build.ps1 -Board W5500_EVB_PICO -Example http       # HTTP 예제만
.\build.ps1 -Board W5500_EVB_PICO -Example http,mqtt  # 여러 예제
```

**빌드 타입:**
```powershell
.\build.ps1 -Debug          # 디버그 빌드 (디버깅 심볼 포함)
```

**정리 및 재빌드:**
```powershell
.\build.ps1 -Clean          # 이전 빌드 산출물 삭제 후 빌드
```

**도움말:**
```powershell
.\build.ps1 -Help
```

---

## 🔧 예제 코드 수정하기

예제 코드를 직접 수정하고 싶으신가요? 간단합니다!

### Windows

**1. examples 폴더를 호스트로 복사:**
```powershell
.\build.ps1 -InitExamples
```

**2. 예제 수정:**
```powershell
notepad .\examples\http\w5x00_http_server.c
# 또는 Visual Studio Code로
code .\examples\http\
```

**3. 빌드 (자동으로 수정된 examples 사용):**
```powershell
.\build.ps1 -Board W5500_EVB_PICO -All
```

### Linux / macOS

**1. examples 폴더를 호스트로 복사:**
```bash
./build.sh --init-examples
```

**2. 예제 수정:**
```bash
vi ./examples/http/w5x00_http_server.c
# 또는 VS Code로
code ./examples/http/
```

**3. 빌드 (자동으로 수정된 examples 사용):**
```bash
./build.sh --board W5500_EVB_PICO --all
```

**이점:**
- 서브모듈 관리 불필요
- 예제 코드만 간편하게 수정
- 빌드 시 자동으로 반영

---

## 🐧 Linux / macOS 사용자

<details>
<summary>클릭하여 확장</summary>

### 빠른 시작

```bash
# 1. 저장소 클론
git clone https://github.com/simryang/wiznet-pico-c-docker
cd wiznet-pico-c-docker

# 2. Interactive 빌드
./build.sh -i

# 3. 보드 선택 → 예제 선택 → 빌드 완료!
```

### 명령줄 사용법

```bash
# 전체 예제 빌드
./build.sh --board W5500_EVB_PICO --all

# 특정 예제만 빌드
./build.sh --board W5500_EVB_PICO --example http

# 여러 예제 빌드
./build.sh --board W5500_EVB_PICO --example "http mqtt udp"

# 디버그 빌드
./build.sh --board W5500_EVB_PICO --example http --debug

# 도움말
./build.sh --help
```

</details>

---

## ✨ 주요 특징

- 🚀 **초고속 빌드**: tmpfs + ccache로 6초 완성 (재빌드 기준)
- 🎯 **10종 보드 지원**: W5100S ~ W6300, RP2040 & RP2350
- 📦 **16가지 예제**: HTTP, MQTT, SSL, CAN 등
- 🐳 **Docker 기반**: 의존성 걱정 없는 통일된 환경
- 💻 **크로스 플랫폼**: Windows, Linux, macOS 모두 지원

## 📊 성능 벤치마크

| 빌드 유형 | 시간 | 개선율 |
|---------|------|--------|
| 최초 빌드 (최적화 전) | 45초 | - |
| tmpfs 적용 | 33초 | 27% ↑ |
| **tmpfs + ccache (재빌드)** | **6초** | **87% ↑** |


## 🎯 지원 하드웨어 (10종)

### RP2040 기반 (6종)

| 보드 | 이더넷 칩 | BOARD_NAME |
|------|----------|-----------|
| WIZnet Ethernet HAT | W5100S | `WIZnet_Ethernet_HAT` |
| W5100S-EVB-Pico | W5100S | `W5100S_EVB_PICO` |
| **W5500-EVB-Pico** ⭐ | W5500 | `W5500_EVB_PICO` |
| W55RP20-EVB-Pico | W55RP20 | `W55RP20_EVB_PICO` |
| W6100-EVB-Pico | W6100 | `W6100_EVB_PICO` |
| W6300-EVB-Pico | W6300 | `W6300_EVB_PICO` |

### RP2350 (Pico2) 기반 (4종)

| 보드 | 이더넷 칩 | BOARD_NAME |
|------|----------|-----------|
| W5100S-EVB-Pico2 | W5100S | `W5100S_EVB_PICO2` |
| W5500-EVB-Pico2 | W5500 | `W5500_EVB_PICO2` |
| W6100-EVB-Pico2 | W6100 | `W6100_EVB_PICO2` |
| W6300-EVB-Pico2 | W6300 | `W6300_EVB_PICO2` |

## 📦 지원 예제 (16종)

### 기본 네트워킹 (4개)
- `loopback` - 루프백 테스트 ⭐
- `udp` - UDP 통신 ⭐
- `http` - HTTP 서버 ⭐⭐
- `tcp_server_multi_socket` - 다중 소켓 서버 ⭐⭐⭐

### 프로토콜 (7개)
- `dhcp_dns` - DHCP & DNS ⭐⭐
- `sntp` - 시간 동기화 ⭐⭐
- `mqtt` - MQTT Pub/Sub ⭐⭐
- `tftp` - TFTP 파일 전송 ⭐⭐
- `netbios` - NetBIOS 이름 해석 ⭐⭐⭐
- `pppoe` - PPPoE 연결 ⭐⭐⭐
- `upnp` - UPnP 프로토콜 ⭐⭐⭐

### 보안 통신 (2개)
- `tcp_client_over_ssl` - SSL/TLS 클라이언트 ⭐⭐⭐
- `tcp_server_over_ssl` - SSL/TLS 서버 ⭐⭐⭐

### 고급 기능 (3개)
- `udp_multicast` - 멀티캐스트 ⭐⭐⭐
- `can` - CAN 통신 ⭐⭐⭐
- `network_install` - 네트워크 설치 ⭐⭐⭐

## 🔧 고급 설정

### 환경변수

빌드 성능을 조정할 수 있습니다:

```bash
# ccache 디렉토리 변경
export CCACHE_DIR_HOST="$HOME/.ccache-custom"

# tmpfs 크기 변경 (기본 20GB)
export TMPFS_SIZE="30g"

# 병렬 빌드 작업 수 변경 (기본 16)
export JOBS=8

./build.sh --board W5500_EVB_PICO --all
```

### Windows (PowerShell)

```powershell
$env:CCACHE_DIR_HOST="$env:USERPROFILE\.ccache-custom"
$env:TMPFS_SIZE="30g"
$env:JOBS=8

.\build.ps1 -Board W5500_EVB_PICO -All
```

## 📂 프로젝트 구조

```
wiznet-pico-c-docker/
├── build.sh                # Linux/macOS 빌드 스크립트
├── build.ps1               # Windows PowerShell 스크립트
├── Dockerfile              # 최적화된 빌드 환경
├── docker-build.sh         # 컨테이너 내부 빌드 로직
├── entrypoint.sh           # Docker 진입점
├── README.md               # 이 파일
├── PROJECT_SPEC.md         # 상세 기술 명세서
├── .gitignore              # Git 제외 파일
├── docs/                   # 문서
├── tests/                  # 테스트 스크립트
└── claude/                 # 개발 문서 (AI 작업 히스토리)
```

## 🔨 기술 스택

| 구성 요소 | 버전/기술 |
|---------|----------|
| **컨테이너** | Docker (Ubuntu 22.04) |
| **빌드 시스템** | CMake 3.28 + Ninja |
| **컴파일러** | ARM GNU Toolchain 14.2 |
| **SDK** | Raspberry Pi Pico SDK 2.2.0 |
| **성능 최적화** | tmpfs (RAM disk) + ccache |
| **스크립트** | Bash, PowerShell |

## 🚀 성능 최적화 기술

### 1. tmpfs (RAM disk)
빌드 디렉토리를 메모리에 마운트하여 디스크 I/O 완전 제거
- 크기: 20GB (조정 가능)
- 첫 빌드: 45초 → 33초 (27% 개선)

### 2. ccache (컴파일 캐시)
컴파일 결과를 캐싱하여 재빌드 시간 극대화
- 캐시 위치: `~/.ccache-wiznet-pico-c`
- 재빌드: 33초 → 6초 (87% 개선)

### 3. 병렬 빌드
16개 작업을 동시에 처리 (조정 가능)

## 📋 시스템 요구사항

### 공통
- Docker Desktop 또는 Docker Engine
- Git
- 인터넷 연결 (최초 이미지 다운로드)

### Linux
- Docker 20.10 이상
- 16GB RAM 권장 (tmpfs 사용 시)

### Windows
- Docker Desktop for Windows
- WSL2 백엔드 권장
- 16GB RAM 권장

### macOS
- Docker Desktop for Mac
- Apple Silicon (M1/M2) 또는 Intel
- 16GB RAM 권장

## 🐛 문제 해결

### Docker 관련

**문제: "Docker 데몬이 실행되지 않았습니다"**

**Windows:**
1. Docker Desktop이 실행 중인지 확인 (시스템 트레이)
2. Docker Desktop 재시작
3. WSL2 백엔드가 활성화되어 있는지 확인

**Linux:**
```bash
sudo systemctl start docker
sudo systemctl enable docker  # 부팅 시 자동 시작
```

**macOS:**
- Docker Desktop을 실행하세요
- 메뉴바에서 Docker 아이콘 확인

---

**문제: "permission denied while trying to connect to the Docker daemon socket"**

**Linux:**
```bash
sudo usermod -aG docker $USER
# 로그아웃 후 다시 로그인
```

---

### PowerShell 실행 권한 오류

**문제: "이 시스템에서 스크립트를 실행할 수 없으므로..."**

**해결 방법 1 (일회성):**
```powershell
powershell -ExecutionPolicy Bypass -File .\build.ps1 -Interactive
```

**해결 방법 2 (영구 설정):**
```powershell
# PowerShell을 관리자 권한으로 실행 후:
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser

# 이후 간단히 실행:
.\build.ps1 -Interactive
```

---

### 빌드 성능 개선

**문제: 빌드가 너무 느림 (45초 이상)**

**확인 사항:**

1. **tmpfs 활성화 확인**
   ```bash
   # 빌드 로그에서 확인:
   # [INFO]   tmpfs: 20g (RAM disk)
   ```

2. **ccache 동작 확인**
   ```bash
   # 재빌드 시 로그에서 확인:
   # Hits: 2249 / 2250 (99.96 %)
   ```

3. **병렬 빌드 수 조정**
   ```bash
   # CPU 코어 수에 맞게 조정 (기본값: 16)
   export JOBS=8
   ./build.sh --board W5500_EVB_PICO --all
   ```

   **Windows (PowerShell):**
   ```powershell
   $env:JOBS=8
   .\build.ps1 -Board W5500_EVB_PICO -All
   ```

---

### 서브모듈 오류

**문제: "Pico SDK 서브모듈이 초기화되지 않았습니다!"**

**해결:**
```bash
cd WIZnet-PICO-C
git submodule update --init --recursive
cd ..
```

---

### Windows 경로 오류

**문제: "C:\Users\... 경로를 찾을 수 없습니다"**

**해결:**
- PowerShell을 **관리자 권한**으로 실행
- 또는 경로에 공백이 없는지 확인

---

### 추가 도움이 필요하신가요?

- **GitHub Issues**: [이슈 등록](https://github.com/simryang/wiznet-pico-c-docker/issues)
- **WIZnet 공식 포럼**: https://forum.wiznet.io/

## 📚 참고 자료

- **WIZnet-PICO-C 공식 저장소**: https://github.com/WIZnet-ioNIC/WIZnet-PICO-C
- **기반 프로젝트**: https://github.com/simryang/w55rp20-docker-build
- **상세 명세서**: [PROJECT_SPEC.md](PROJECT_SPEC.md)
- **Pico SDK 문서**: https://www.raspberrypi.com/documentation/pico-sdk/

## 🤝 기여

이슈 및 풀 리퀘스트를 환영합니다!

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📝 라이선스

MIT License - 자유롭게 사용하세요!

## ✅ 개발 현황

- [x] 프로젝트 초기화 및 분석
- [x] Dockerfile 최적화
- [x] docker-build.sh 작성
- [x] build.sh 작성 (Linux/macOS)
- [x] build.ps1 작성 (Windows)
- [x] 성능 최적화 (tmpfs + ccache)
- [x] 테스트 빌드 (W5500-EVB-Pico)
- [x] README 문서화
- [ ] 다양한 보드 테스트
- [ ] CI/CD 파이프라인
- [ ] WCC 기사 작성

## 📧 연락처

**작성자:** simryang

**최종 업데이트:** 2026-02-04

---

⭐ **이 프로젝트가 유용했다면 Star를 눌러주세요!**
