# WIZnet-PICO-C Docker Build System

> **WIZnet 이더넷 보드(10종)용 C 예제(16종)를 6초 만에 빌드하는 초고속 Docker 시스템**

[![Build Status](https://img.shields.io/badge/build-passing-brightgreen)]()
[![Docker](https://img.shields.io/badge/docker-ready-blue)]()
[![Platform](https://img.shields.io/badge/platform-linux%20%7C%20windows%20%7C%20macos-lightgrey)]()

## ✨ 주요 특징

- 🚀 **초고속 빌드**: tmpfs + ccache로 6초 완성 (재빌드 기준)
- 🎯 **10종 보드 지원**: W5100S ~ W6300, RP2040 & RP2350
- 📦 **16가지 예제**: HTTP, MQTT, SSL, CAN 등
- 🐳 **Docker 기반**: 의존성 걱정 없는 통일된 환경
- 💻 **크로스 플랫폼**: Windows, Linux, macOS 모두 지원
- ✏️ **간편한 수정**: 예제 코드를 호스트에서 직접 수정 가능

---

## 📖 목차

1. [빠른 시작 (처음 사용자)](#-빠른-시작-처음-사용자)
2. [예제 코드 수정하기](#-예제-코드-수정하기)
3. [더 많은 사용법](#-더-많은-사용법)
4. [지원 하드웨어 & 예제](#-지원-하드웨어--예제)
5. [문제 해결](#-문제-해결)

---

## 🚀 빠른 시작 (처음 사용자)

> 예제를 수정하지 않고, 기본 예제를 빌드하려는 경우

### Windows 사용자

#### 1단계: 준비물 설치

**필수 프로그램 2개만 설치:**

1. **Docker Desktop**: https://www.docker.com/products/docker-desktop
   - 다운로드 → 설치 → 재부팅
   - 설치 후 Docker Desktop 실행 (시스템 트레이 확인)

2. **Git for Windows**: https://git-scm.com/download/win
   - 다운로드 → 설치 (기본 옵션 그대로)

#### 2단계: 빌드 실행

**PowerShell 또는 Git Bash 열고 아래 명령어 복사 후 실행:**

```powershell
git clone https://github.com/simryang/wiznet-pico-c-docker
cd wiznet-pico-c-docker
powershell -ExecutionPolicy Bypass -File .\build.ps1 -Interactive
```

> **💡 참고:** `powershell -ExecutionPolicy Bypass`는 스크립트 실행 권한 문제를 우회합니다.

**대화형 모드 진행:**

1. **보드 선택**: `3` (W5500-EVB-Pico 권장) → Enter
2. **예제 선택**: `3` (HTTP 서버) → Enter
3. **확인**: `y` → Enter

**자동 진행:**
- WIZnet-PICO-C 저장소 클론
- 서브모듈 초기화
- Docker 빌드 (~45초)

#### 3단계: 완료!

**산출물:** `.\out\*.uf2`

**펌웨어 업로드:**
1. 보드를 USB로 연결
2. BOOTSEL 버튼을 누른 채 RESET 버튼 클릭
3. `.\out\*.uf2` 파일을 드래그앤드롭

---

### Linux / macOS 사용자

<details>
<summary>클릭하여 확장</summary>

#### 1단계: 준비물 설치

**Docker 설치:**
```bash
# Ubuntu/Debian
sudo apt-get update
sudo apt-get install docker.io
sudo usermod -aG docker $USER
# 로그아웃 후 다시 로그인

# macOS
# Docker Desktop for Mac 설치: https://www.docker.com/products/docker-desktop
```

#### 2단계: 빌드 실행

```bash
git clone https://github.com/simryang/wiznet-pico-c-docker
cd wiznet-pico-c-docker
./build.sh -i
```

**대화형 모드 진행:**
1. 보드 선택: `3` (W5500-EVB-Pico)
2. 예제 선택: `3` (HTTP)
3. 확인: `y`

#### 3단계: 완료!

**산출물:** `./out/*.uf2`

</details>

---

## 📝 예제 코드 수정하기

> **이 섹션은 예제 코드를 직접 수정하고 싶은 경우입니다.**

### 왜 이 방법을 사용하나요?

- ✅ **간편함**: 서브모듈 관리 불필요
- ✅ **빠름**: 예제 코드만 수정하면 자동으로 반영
- ✅ **안전함**: 원본은 그대로, 복사본만 수정

### Windows 사용자 가이드

#### Step 1: examples 폴더 복사

**명령 실행:**
```powershell
.\build.ps1 -InitExamples
```

**무슨 일이 일어나나요?**
- WIZnet-PICO-C 저장소에서 `examples` 폴더를 현재 디렉토리로 복사
- 결과: `.\examples\` 폴더 생성
- 내용: http, mqtt, ssl 등 16개 예제의 소스 코드

**출력 예시:**
```
[INFO] examples 폴더 초기화 중...
[INFO] examples 폴더 복사 중: WIZnet-PICO-C\examples -> examples
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ examples 폴더 초기화 완료!
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

이제 다음과 같이 사용할 수 있습니다:
  1. 예제 수정:
     notepad .\examples\http\w5x00_http_server.c
  2. 빌드:
     .\build.ps1 -b W5500_EVB_PICO -a
```

---

#### Step 2: 예제 코드 수정

**파일 탐색기에서:**
1. `examples` 폴더 열기
2. 수정하고 싶은 예제 선택 (예: `http`)
3. 소스 코드 편집

**예시: HTTP 서버 포트 변경**

파일: `.\examples\http\w5x00_http_server.c`

```c
// 변경 전
#define PORT_HTTP 80

// 변경 후
#define PORT_HTTP 8080
```

**편집 도구:**
- **메모장**: `notepad .\examples\http\w5x00_http_server.c`
- **VS Code**: `code .\examples\http\`
- **Visual Studio**: 파일 탐색기에서 우클릭 → 연결 프로그램

---

#### Step 3: 수정된 예제 빌드

**명령 실행:**
```powershell
.\build.ps1 -Board W5500_EVB_PICO -All
```

**무슨 일이 일어나나요?**
1. Docker 빌드 시작
2. **자동으로 호스트의 `.\examples\` 폴더를 마운트**
3. 수정된 코드로 빌드
4. 산출물: `.\out\*.uf2`

**출력 확인:**
```
[INFO] 호스트 examples 사용: C:/Users/yourname/wiznet-pico-c-docker/examples
[INFO] Docker 빌드 시작...
...
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ 빌드 성공! (소요 시간: 0분 6초)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

> **⚡ 성능**: 재빌드 시 ccache 덕분에 6초만에 완료!

---

#### Step 4: 펌웨어 업로드 및 테스트

**펌웨어 업로드:**
1. 보드를 USB로 연결
2. **BOOTSEL** 버튼을 누른 채 **RESET** 버튼 클릭
3. `.\out\w5x00_http.uf2`를 드래그앤드롭
4. 자동으로 재부팅

**테스트:**
1. 시리얼 터미널 열기 (PuTTY, TeraTerm 등)
   - 포트: COM3 (또는 자동 감지된 포트)
   - 속도: 115200 baud
2. 보드 IP 확인 (예: `192.168.1.100`)
3. 웹 브라우저에서 접속:
   - 변경 전: `http://192.168.1.100:80`
   - **변경 후: `http://192.168.1.100:8080`** ✅

---

#### Step 5: 계속 수정하기

**코드 수정 → 빌드 → 테스트 반복:**

```powershell
# 1. 코드 수정
code .\examples\http\

# 2. 빌드 (6초!)
.\build.ps1 -Board W5500_EVB_PICO -Example http

# 3. 펌웨어 업로드 (드래그앤드롭)
# 4. 테스트
```

**빠른 재빌드:**
- 전체 빌드 필요 없음: `-Example http`로 특정 예제만
- ccache 덕분에 6초만에 완료
- 코드 수정이 즉시 반영

---

### Linux / macOS 사용자 가이드

<details>
<summary>클릭하여 확장</summary>

#### Step 1: examples 폴더 복사

```bash
./build.sh --init-examples
```

#### Step 2: 예제 코드 수정

```bash
# VS Code로 편집
code ./examples/http/

# 또는 vi/vim
vi ./examples/http/w5x00_http_server.c
```

#### Step 3: 수정된 예제 빌드

```bash
./build.sh --board W5500_EVB_PICO --all
```

#### Step 4: 펌웨어 업로드 및 테스트

```bash
# 산출물 확인
ls -lh ./out/*.uf2

# 펌웨어 업로드 (드래그앤드롭)
# 시리얼 모니터링
screen /dev/ttyACM0 115200
# (또는 minicom, picocom 등)
```

</details>

---

## 💡 더 많은 사용법

### 특정 예제만 빌드

**Windows:**
```powershell
# HTTP 예제만
.\build.ps1 -Board W5500_EVB_PICO -Example http

# 여러 예제
.\build.ps1 -Board W5500_EVB_PICO -Example http,mqtt,ssl
```

**Linux/macOS:**
```bash
# HTTP 예제만
./build.sh --board W5500_EVB_PICO --example http

# 여러 예제
./build.sh --board W5500_EVB_PICO --example "http mqtt tcp_client_over_ssl"
```

---

### 디버그 빌드

**Windows:**
```powershell
.\build.ps1 -Board W5500_EVB_PICO -Example http -Debug
```

**Linux/macOS:**
```bash
./build.sh --board W5500_EVB_PICO --example http --debug
```

---

### 환경변수로 성능 조정

**Windows:**
```powershell
# ccache 디렉토리 변경
$env:CCACHE_DIR_HOST="$env:USERPROFILE\.ccache-custom"

# tmpfs 크기 변경 (기본 20GB)
$env:TMPFS_SIZE="30g"

# 병렬 빌드 작업 수 (기본 16)
$env:JOBS=8

.\build.ps1 -Board W5500_EVB_PICO -All
```

**Linux/macOS:**
```bash
export CCACHE_DIR_HOST="$HOME/.ccache-custom"
export TMPFS_SIZE="30g"
export JOBS=8

./build.sh --board W5500_EVB_PICO --all
```

---

### 빌드 정리

**Windows:**
```powershell
.\build.ps1 -Clean
```

**Linux/macOS:**
```bash
./build.sh --clean
```

---

## 🎯 지원 하드웨어 & 예제

### 지원 보드 (10종)

#### RP2040 기반 (6종)

| 보드 | 이더넷 칩 | BOARD_NAME |
|------|----------|-----------|
| WIZnet Ethernet HAT | W5100S | `WIZnet_Ethernet_HAT` |
| W5100S-EVB-Pico | W5100S | `W5100S_EVB_PICO` |
| **W5500-EVB-Pico** ⭐ | W5500 | `W5500_EVB_PICO` |
| W55RP20-EVB-Pico | W55RP20 | `W55RP20_EVB_PICO` |
| W6100-EVB-Pico | W6100 | `W6100_EVB_PICO` |
| W6300-EVB-Pico | W6300 | `W6300_EVB_PICO` |

#### RP2350 (Pico2) 기반 (4종)

| 보드 | 이더넷 칩 | BOARD_NAME |
|------|----------|-----------|
| W5100S-EVB-Pico2 | W5100S | `W5100S_EVB_PICO2` |
| W5500-EVB-Pico2 | W5500 | `W5500_EVB_PICO2` |
| W6100-EVB-Pico2 | W6100 | `W6100_EVB_PICO2` |
| W6300-EVB-Pico2 | W6300 | `W6300_EVB_PICO2` |

---

### 지원 예제 (16종)

#### 기본 네트워킹 (4개)
- `loopback` - 루프백 테스트 ⭐
- `udp` - UDP 통신 ⭐
- `http` - HTTP 서버 ⭐⭐
- `tcp_server_multi_socket` - 다중 소켓 서버 ⭐⭐⭐

#### 프로토콜 (7개)
- `dhcp_dns` - DHCP & DNS ⭐⭐
- `sntp` - 시간 동기화 ⭐⭐
- `mqtt` - MQTT Pub/Sub ⭐⭐
- `tftp` - TFTP 파일 전송 ⭐⭐
- `netbios` - NetBIOS 이름 해석 ⭐⭐⭐
- `pppoe` - PPPoE 연결 ⭐⭐⭐
- `upnp` - UPnP 프로토콜 ⭐⭐⭐

#### 보안 통신 (2개)
- `tcp_client_over_ssl` - SSL/TLS 클라이언트 ⭐⭐⭐
- `tcp_server_over_ssl` - SSL/TLS 서버 ⭐⭐⭐

#### 고급 기능 (3개)
- `udp_multicast` - 멀티캐스트 ⭐⭐⭐
- `can` - CAN 통신 ⭐⭐⭐
- `network_install` - 네트워크 설치 ⭐⭐⭐

---

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
   ```
   # 빌드 로그에서 확인:
   [INFO]   tmpfs: 20g (RAM disk)
   ```

2. **ccache 동작 확인**
   ```
   # 재빌드 시 로그에서 확인:
   Hits: 2249 / 2250 (99.96 %)
   ```

3. **병렬 빌드 수 조정**

   **Windows:**
   ```powershell
   $env:JOBS=8
   .\build.ps1 -Board W5500_EVB_PICO -All
   ```

   **Linux/macOS:**
   ```bash
   export JOBS=8
   ./build.sh --board W5500_EVB_PICO --all
   ```

---

### examples 관련

**문제: "호스트 examples 폴더가 이미 존재합니다"**

**해결:**
- 덮어쓰기: `y` 입력
- 또는 수동 삭제 후 재실행:
  ```powershell
  # Windows
  Remove-Item -Recurse -Force .\examples\
  .\build.ps1 -InitExamples
  ```
  ```bash
  # Linux/macOS
  rm -rf ./examples/
  ./build.sh --init-examples
  ```

---

**문제: "examples를 수정했는데 빌드에 반영이 안 됨"**

**확인:**
1. 호스트 `./examples/` 폴더가 있는지 확인
2. 빌드 로그에서 확인:
   ```
   [INFO] 호스트 examples 사용: /path/to/examples
   ```
3. 캐시 정리 후 재빌드:
   ```powershell
   # Windows
   .\build.ps1 -Clean
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

### 추가 도움

- **GitHub Issues**: [이슈 등록](https://github.com/simryang/wiznet-pico-c-docker/issues)
- **WIZnet 공식 포럼**: https://forum.wiznet.io/

---

## 📊 성능 벤치마크

| 빌드 유형 | 시간 | 개선율 |
|---------|------|--------|
| 최초 빌드 (최적화 전) | 45초 | - |
| tmpfs 적용 | 33초 | 27% ↑ |
| **tmpfs + ccache (재빌드)** | **6초** | **87% ↑** |

---

## 🔧 기술 스택

| 구성 요소 | 버전/기술 |
|---------|----------|
| **컨테이너** | Docker (Ubuntu 22.04) |
| **빌드 시스템** | CMake 3.28 + Ninja |
| **컴파일러** | ARM GNU Toolchain 14.2 |
| **SDK** | Raspberry Pi Pico SDK (서브모듈) |
| **성능 최적화** | tmpfs (RAM disk) + ccache |

---

## 📚 참고 자료

- **WIZnet-PICO-C 공식 저장소**: https://github.com/WIZnet-ioNIC/WIZnet-PICO-C
- **Pico SDK 문서**: https://www.raspberrypi.com/documentation/pico-sdk/
- **Docker 공식 문서**: https://docs.docker.com/

---

## 📝 라이선스

MIT License - 자유롭게 사용하세요!

---

## ✅ 개발 현황

- [x] 프로젝트 초기화 및 분석
- [x] Dockerfile 최적화
- [x] docker-build.sh 작성
- [x] build.sh 작성 (Linux/macOS)
- [x] build.ps1 작성 (Windows)
- [x] 성능 최적화 (tmpfs + ccache)
- [x] examples 호스트 복사 기능
- [x] 테스트 빌드 (W5500-EVB-Pico)
- [x] README 문서화
- [ ] 다양한 보드 테스트
- [ ] CI/CD 파이프라인

---

**최종 업데이트:** 2026-02-06

⭐ **이 프로젝트가 유용했다면 Star를 눌러주세요!**
