# WIZnet-PICO-C Docker Build System

WIZnet 이더넷 보드(10종)용 C 예제(16종)를 Docker로 빌드합니다. Windows, Linux, macOS 모두 지원합니다.

[![Build Status](https://img.shields.io/badge/build-passing-brightgreen)]()
[![Docker](https://img.shields.io/badge/docker-ready-blue)]()
[![Platform](https://img.shields.io/badge/platform-windows%20%7C%20linux%20%7C%20macos-lightgrey)]()

## 주요 특징

- **Windows 환경 지원**: PowerShell 스크립트로 간편하게 빌드
- 10종 보드 지원 (W5100S ~ W6300, RP2040 & RP2350)
- 16가지 예제 (HTTP, MQTT, SSL, CAN 등)
- Docker 기반 통일된 빌드 환경
- 예제 코드를 호스트에서 직접 수정 가능
- Linux 환경에서는 ccache로 재빌드 6초

---

## 목차

1. [빠른 시작](#빠른-시작)
2. [예제 수정](#예제-수정)
3. [더 많은 사용법](#더-많은-사용법)
4. [지원 하드웨어 & 예제](#지원-하드웨어--예제)
5. [문제 해결](#문제-해결)

---

## 빠른 시작

기본 예제를 빌드해보려면:

### Windows

Docker Desktop과 Git for Windows를 설치합니다.

```powershell
git clone https://github.com/simryang/wiznet-pico-c-docker
cd wiznet-pico-c-docker
powershell -ExecutionPolicy Bypass -File .\build.ps1 -Interactive
```

참고: `powershell -ExecutionPolicy Bypass`는 스크립트 실행 권한 문제를 우회합니다.

대화형 모드에서:
1. 보드 선택: `3` (W5500-EVB-Pico 권장)
2. 예제 선택: `3` (HTTP 서버)
3. 확인: `y`

WIZnet-PICO-C 저장소를 클론하고 서브모듈을 초기화한 후 Docker 빌드를 실행합니다 (첫 빌드는 약 45초).

산출물: `.\out\*.uf2`

펌웨어 업로드:
1. 보드를 USB로 연결
2. BOOTSEL 버튼을 누른 채 RESET 버튼 클릭
3. .uf2 파일을 드래그앤드롭

---

### Linux / macOS

<details>
<summary>클릭하여 확장</summary>

Docker를 설치합니다:

```bash
# Ubuntu/Debian
sudo apt-get update
sudo apt-get install docker.io
sudo usermod -aG docker $USER
# 로그아웃 후 다시 로그인
```

빌드 실행:

```bash
git clone https://github.com/simryang/wiznet-pico-c-docker
cd wiznet-pico-c-docker
./build.sh -i
```

대화형 모드에서 보드와 예제를 선택합니다.

산출물: `./out/*.uf2`

</details>

---

## 예제 수정

예제 코드를 직접 수정하려면 호스트로 복사하는 방법이 편합니다. 서브모듈 관리가 필요 없고, 수정 사항이 자동으로 빌드에 반영됩니다.

### 1. examples 복사

```powershell
# Windows
.\build.ps1 -InitExamples

# Linux/macOS
./build.sh --init-examples
```

WIZnet-PICO-C 저장소의 `examples` 폴더를 현재 디렉토리로 복사합니다. 16개 예제의 소스 코드가 `./examples/` 에 생성됩니다.

### 2. 코드 수정

예를 들어 HTTP 서버 포트를 변경하려면:

파일: `.\examples\http\w5x00_http_server.c`

```c
// 변경 전
#define PORT_HTTP 80

// 변경 후
#define PORT_HTTP 8080
```

메모장, VS Code, Visual Studio 등 원하는 편집기를 사용하세요.

### 3. 빌드

```powershell
# Windows
.\build.ps1 -Board W5500_EVB_PICO -All

# Linux/macOS
./build.sh --board W5500_EVB_PICO --all
```

호스트의 `./examples/` 폴더를 자동으로 마운트해서 빌드합니다. 빌드 로그에서 다음 줄을 확인하세요:

```
[INFO] 호스트 examples 사용: /path/to/examples
```

Linux 환경에서는 Docker 컨테이너 내부의 ccache로 재빌드가 6초면 끝납니다. Windows는 Docker Desktop 오버헤드로 약간 더 걸립니다.

### 4. 테스트

1. .uf2 파일을 보드에 업로드
2. 시리얼 터미널 (PuTTY, TeraTerm 등)로 IP 확인
3. 웹 브라우저에서 접속: `http://192.168.1.100:8080`

### 5. 반복

코드를 계속 수정하면서 테스트하려면:

```powershell
# 1. 코드 수정
code .\examples\http\

# 2. 빌드 (특정 예제만)
.\build.ps1 -Board W5500_EVB_PICO -Example http

# 3. 펌웨어 업로드 (드래그앤드롭)
# 4. 테스트
```

---

## 더 많은 사용법

### 특정 예제만 빌드

```powershell
# Windows
.\build.ps1 -Board W5500_EVB_PICO -Example http
.\build.ps1 -Board W5500_EVB_PICO -Example http,mqtt,ssl
```

```bash
# Linux/macOS
./build.sh --board W5500_EVB_PICO --example http
./build.sh --board W5500_EVB_PICO --example "http mqtt tcp_client_over_ssl"
```

### 디버그 빌드

```powershell
# Windows
.\build.ps1 -Board W5500_EVB_PICO -Example http -Debug
```

```bash
# Linux/macOS
./build.sh --board W5500_EVB_PICO --example http --debug
```

### 성능 조정 (Linux/macOS)

Linux 환경에서는 tmpfs와 ccache 설정으로 빌드 속도를 향상시킬 수 있습니다.

```bash
# Linux/macOS
export CCACHE_DIR_HOST="$HOME/.ccache-custom"
export TMPFS_SIZE="30g"
export JOBS=8
./build.sh --board W5500_EVB_PICO --all
```

Windows에서는 기본 설정을 사용하는 것을 권장합니다. 병렬 빌드 수만 조정할 수 있습니다:

```powershell
# Windows - 병렬 빌드 수 조정
$env:JOBS=8
.\build.ps1 -Board W5500_EVB_PICO -All
```

### 빌드 정리

```powershell
# Windows
.\build.ps1 -Clean
```

```bash
# Linux/macOS
./build.sh --clean
```

---

## 지원 하드웨어 & 예제

### 지원 보드 (10종)

#### RP2040 기반 (6종)

| 보드 | 이더넷 칩 | BOARD_NAME |
|------|----------|-----------|
| WIZnet Ethernet HAT | W5100S | `WIZnet_Ethernet_HAT` |
| W5100S-EVB-Pico | W5100S | `W5100S_EVB_PICO` |
| W5500-EVB-Pico (권장) | W5500 | `W5500_EVB_PICO` |
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

### 지원 예제 (16종)

#### 기본 네트워킹 (4개)
- `loopback` - 루프백 테스트
- `udp` - UDP 통신
- `http` - HTTP 서버
- `tcp_server_multi_socket` - 다중 소켓 서버

#### 프로토콜 (7개)
- `dhcp_dns` - DHCP & DNS
- `sntp` - 시간 동기화
- `mqtt` - MQTT Pub/Sub
- `tftp` - TFTP 파일 전송
- `netbios` - NetBIOS 이름 해석
- `pppoe` - PPPoE 연결
- `upnp` - UPnP 프로토콜

#### 보안 통신 (2개)
- `tcp_client_over_ssl` - SSL/TLS 클라이언트
- `tcp_server_over_ssl` - SSL/TLS 서버

#### 고급 기능 (3개)
- `udp_multicast` - 멀티캐스트
- `can` - CAN 통신
- `network_install` - 네트워크 설치

---

## 문제 해결

### Docker 데몬이 실행되지 않음

Windows: Docker Desktop을 실행하고 시스템 트레이에서 확인하세요. WSL2 백엔드가 활성화되어 있는지 확인하세요.

Linux:
```bash
sudo systemctl start docker
sudo systemctl enable docker
```

macOS: Docker Desktop을 실행하고 메뉴바에서 확인하세요.

### Permission denied (Docker daemon socket)

Linux:
```bash
sudo usermod -aG docker $USER
# 로그아웃 후 다시 로그인
```

### PowerShell 실행 권한 오류

일회성:
```powershell
powershell -ExecutionPolicy Bypass -File .\build.ps1 -Interactive
```

영구 설정:
```powershell
# PowerShell을 관리자 권한으로 실행 후:
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### 빌드가 느림 (45초 이상)

**Windows**: Docker Desktop이 WSL2를 사용하는지 확인하세요. 설정 > General > "Use the WSL 2 based engine"을 활성화해야 합니다.

병렬 빌드 수를 조정해보세요:

```powershell
# Windows
$env:JOBS=8
.\build.ps1 -Board W5500_EVB_PICO -All
```

**Linux/macOS**: 빌드 로그에서 tmpfs와 ccache가 활성화되었는지 확인하세요:

```
[INFO]   tmpfs: 20g (RAM disk)
Hits: 2249 / 2250 (99.96 %)
```

### examples 수정이 빌드에 반영되지 않음

빌드 로그에서 호스트 examples가 마운트되었는지 확인하세요:

```
[INFO] 호스트 examples 사용: /path/to/examples
```

캐시를 정리하고 다시 빌드하세요:

```powershell
.\build.ps1 -Clean
.\build.ps1 -Board W5500_EVB_PICO -All
```

### 서브모듈 초기화 오류

```bash
cd WIZnet-PICO-C
git submodule update --init --recursive
cd ..
```

### 추가 도움

- GitHub Issues: https://github.com/simryang/wiznet-pico-c-docker/issues
- WIZnet 공식 포럼: https://forum.wiznet.io/

---

## 성능 벤치마크

Linux 환경 기준 (Ubuntu 22.04, 16GB RAM, 8 Core):

| 빌드 유형 | 시간 | 개선율 |
|---------|------|--------|
| 최초 빌드 (최적화 전) | 45초 | - |
| tmpfs 적용 | 33초 | 27% ↑ |
| tmpfs + ccache (재빌드) | 6초 | 87% ↑ |

Windows 환경에서는 Docker Desktop 오버헤드로 약간 더 걸립니다.

---

## 기술 스택

| 구성 요소 | 버전/기술 |
|---------|----------|
| 컨테이너 | Docker (Ubuntu 22.04) |
| 빌드 시스템 | CMake 3.28 + Ninja |
| 컴파일러 | ARM GNU Toolchain 14.2 |
| SDK | Raspberry Pi Pico SDK (서브모듈) |
| 성능 최적화 | tmpfs + ccache (Linux 컨테이너 내부) |

---

## 참고 자료

- WIZnet-PICO-C 공식 저장소: https://github.com/WIZnet-ioNIC/WIZnet-PICO-C
- Pico SDK 문서: https://www.raspberrypi.com/documentation/pico-sdk/
- Docker 공식 문서: https://docs.docker.com/

---

## 라이선스

MIT License

---

## 개발 현황

- [x] 프로젝트 초기화 및 분석
- [x] Dockerfile 최적화
- [x] docker-build.sh 작성
- [x] build.sh 작성 (Linux/macOS)
- [x] build.ps1 작성 (Windows)
- [x] Linux 환경 성능 최적화 (tmpfs + ccache)
- [x] examples 호스트 복사 기능
- [x] 테스트 빌드 (W5500-EVB-Pico)
- [x] README 문서화
- [ ] 다양한 보드 테스트
- [ ] CI/CD 파이프라인

---

최종 업데이트: 2026-02-06
