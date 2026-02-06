#!/usr/bin/env pwsh
# -----------------------------------------------------------------------------
# build.ps1 - WIZnet-PICO-C Docker Build System (Windows)
#
# WIZnet 이더넷 보드(10종)용 C 예제(16종) 빌드 스크립트
#
# 사용법:
#   .\build.ps1 -Interactive                        # Interactive 모드
#   .\build.ps1 -Board W5500_EVB_PICO -All          # 전체 빌드
#   .\build.ps1 -Board W5500_EVB_PICO -Example http # 특정 예제
#   .\build.ps1 -Clean                              # 빌드 정리
#   .\build.ps1 -Help                               # 도움말
# -----------------------------------------------------------------------------

[CmdletBinding()]
param(
    [Parameter(HelpMessage="Interactive 모드 실행")]
    [Alias("i")]
    [switch]$Interactive,

    [Parameter(HelpMessage="사용자 프로젝트 경로 (예: C:\my-wiznet-project)")]
    [Alias("p")]
    [string]$Project,

    [Parameter(HelpMessage="보드 이름 (예: W5500_EVB_PICO)")]
    [Alias("b")]
    [string]$Board,

    [Parameter(HelpMessage="예제 이름 (예: http)")]
    [Alias("e")]
    [string[]]$Example,

    [Parameter(HelpMessage="전체 예제 빌드")]
    [Alias("a")]
    [switch]$All,

    [Parameter(HelpMessage="디버그 빌드")]
    [Alias("d")]
    [switch]$DebugBuild,

    [Parameter(HelpMessage="빌드 정리")]
    [Alias("c")]
    [switch]$Clean,

    [Parameter(HelpMessage="examples 폴더를 호스트로 복사")]
    [switch]$InitExamples,

    [Parameter(HelpMessage="도움말 표시")]
    [Alias("h")]
    [switch]$Help
)

# UTF-8 출력 설정
$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# 버전
$Version = "1.0.0"

# 기본 설정
$RepoUrl = "https://github.com/WIZnet-ioNIC/WIZnet-PICO-C.git"
$ProjectDir = "WIZnet-PICO-C"
$DockerImage = "simryang/w55rp20:latest"
$BuildTypeValue = if ($DebugBuild) { "Debug" } else { "Release" }
$OutDir = "out"
$ExamplesDir = "examples"

# 성능 최적화 설정
$CcacheDirHost = if ($env:CCACHE_DIR_HOST) { $env:CCACHE_DIR_HOST } else { "$env:USERPROFILE\.ccache-wiznet-pico-c" }
$TmpfsSize = if ($env:TMPFS_SIZE) { $env:TMPFS_SIZE } else { "20g" }
$Jobs = if ($env:JOBS) { $env:JOBS } else { 16 }

# 지원 보드 목록
$Boards = @(
    "WIZnet_Ethernet_HAT",
    "W5100S_EVB_PICO",
    "W5500_EVB_PICO",
    "W55RP20_EVB_PICO",
    "W6100_EVB_PICO",
    "W6300_EVB_PICO",
    "W5100S_EVB_PICO2",
    "W5500_EVB_PICO2",
    "W6100_EVB_PICO2",
    "W6300_EVB_PICO2"
)

# 보드 설명
$BoardDescriptions = @(
    "WIZnet Ethernet HAT      (W5100S)",
    "W5100S-EVB-Pico          (W5100S)",
    "W5500-EVB-Pico           (W5500) ← 권장",
    "W55RP20-EVB-Pico         (W55RP20 SiP)",
    "W6100-EVB-Pico           (W6100 IPv6)",
    "W6300-EVB-Pico           (W6300 QSPI)",
    "W5100S-EVB-Pico2         (W5100S)",
    "W5500-EVB-Pico2          (W5500)",
    "W6100-EVB-Pico2          (W6100)",
    "W6300-EVB-Pico2          (W6300)"
)

# 지원 예제 목록
$Examples = @(
    "loopback",
    "udp",
    "http",
    "tcp_server_multi_socket",
    "dhcp_dns",
    "sntp",
    "mqtt",
    "tftp",
    "netbios",
    "pppoe",
    "upnp",
    "tcp_client_over_ssl",
    "tcp_server_over_ssl",
    "udp_multicast",
    "can",
    "network_install"
)

# 예제 설명
$ExampleDescriptions = @(
    "loopback              - 루프백 테스트",
    "udp                   - UDP 통신",
    "http                  - HTTP 서버",
    "tcp_server_multi      - 다중 소켓 서버",
    "dhcp_dns              - DHCP & DNS",
    "sntp                  - 시간 동기화",
    "mqtt                  - MQTT Pub/Sub",
    "tftp                  - TFTP 전송",
    "netbios               - NetBIOS",
    "pppoe                 - PPPoE",
    "upnp                  - UPnP",
    "tcp_client_ssl        - SSL 클라이언트",
    "tcp_server_ssl        - SSL 서버",
    "udp_multicast         - 멀티캐스트",
    "can                   - CAN 통신",
    "network_install       - 네트워크 설치"
)

# 로깅 함수
function Write-Log {
    param([string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor Green
}

function Write-Warning-Custom {
    param([string]$Message)
    Write-Host "[WARN] $Message" -ForegroundColor Yellow
}

function Write-Error-Custom {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor Red
    exit 1
}

# 도움말 표시
function Show-Help {
    Write-Host @"
WIZnet-PICO-C Docker Build System v$Version

사용법:
  .\build.ps1 [옵션]

옵션:
  프로젝트:
    -Interactive, -i              Interactive 모드 (초보자 권장)
    -Project, -p PATH             사용자 프로젝트 경로 지정
                                  (기본: WIZnet-PICO-C 자동 클론)

  빌드:
    -Board, -b BOARD_NAME         보드 지정 (예: W5500_EVB_PICO)
    -Example, -e EXAMPLE          예제 지정 (예: http)
    -All, -a                      전체 예제 빌드 (16개)
    -DebugBuild, -d               디버그 빌드 (기본: Release)
    -Clean, -c                    빌드 정리
    -InitExamples                 examples 폴더를 호스트로 복사 (최초 1회)

  도움말:
    -Help, -h                     이 도움말 표시

예시:
  # Interactive 모드
  .\build.ps1 -i

  # 전체 빌드
  .\build.ps1 -b W5500_EVB_PICO -a

  # 특정 예제만 빌드
  .\build.ps1 -b W5500_EVB_PICO -e http

  # 여러 예제 빌드
  .\build.ps1 -b W5500_EVB_PICO -e http,mqtt

  # 사용자 프로젝트 빌드
  .\build.ps1 -p C:\my-wiznet-project -b W5500_EVB_PICO -a

  # examples를 호스트로 복사 후 수정하여 빌드
  .\build.ps1 -InitExamples        # 최초 1회 (examples 복사)
  # (.\examples\http\ 등을 수정)
  .\build.ps1 -b W5500_EVB_PICO -a  # 수정된 examples로 빌드

  # 빌드 정리
  .\build.ps1 -c

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

Windows 특화 사항:
  - Docker Desktop 필수
  - WSL2 백엔드 권장
  - RAM 4GB 이상 권장
"@
}

# 보드 선택 Interactive UI
function Select-Board {
    Write-Host ""
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
    Write-Host "[1/3] 보드 선택" -ForegroundColor Cyan
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "어떤 보드를 사용하시나요?"
    Write-Host ""
    Write-Host "  RP2040 기반:"
    for ($i = 0; $i -lt 6; $i++) {
        Write-Host "  $($i+1)) $($BoardDescriptions[$i])"
    }
    Write-Host ""
    Write-Host "  RP2350 (Pico2) 기반:"
    for ($i = 6; $i -lt 10; $i++) {
        Write-Host "  $($i+1)) $($BoardDescriptions[$i])"
    }
    Write-Host ""

    $choice = Read-Host "선택 [1-10]"
    $choiceNum = [int]$choice

    if ($choiceNum -lt 1 -or $choiceNum -gt 10) {
        Write-Error-Custom "잘못된 선택입니다. 1-10 사이의 숫자를 입력하세요."
    }

    $script:SelectedBoard = $Boards[$choiceNum - 1]
    Write-Host ""
    Write-Host "✓ 선택: $($BoardDescriptions[$choiceNum - 1])" -ForegroundColor Green
}

# 예제 선택 Interactive UI
function Select-Examples {
    Write-Host ""
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
    Write-Host "[2/3] 예제 선택" -ForegroundColor Cyan
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "빌드할 예제를 선택하세요:"
    Write-Host ""
    Write-Host "  0) 전체 빌드 (16개 모두, 약 10분)"
    Write-Host ""
    Write-Host "  기본 네트워킹:"
    Write-Host "  1) $($ExampleDescriptions[0]) ⭐"
    Write-Host "  2) $($ExampleDescriptions[1]) ⭐"
    Write-Host "  3) $($ExampleDescriptions[2]) ⭐⭐"
    Write-Host "  4) $($ExampleDescriptions[3]) ⭐⭐⭐"
    Write-Host ""
    Write-Host "  프로토콜:"
    for ($i = 4; $i -lt 11; $i++) {
        $stars = if ($i -lt 5) { "⭐⭐" } else { "⭐⭐⭐" }
        Write-Host "  $($i+1)) $($ExampleDescriptions[$i]) $stars"
    }
    Write-Host ""
    Write-Host "  보안:"
    Write-Host "  12) $($ExampleDescriptions[11]) ⭐⭐⭐"
    Write-Host "  13) $($ExampleDescriptions[12]) ⭐⭐⭐"
    Write-Host ""
    Write-Host "  고급:"
    Write-Host "  14) $($ExampleDescriptions[13]) ⭐⭐⭐"
    Write-Host "  15) $($ExampleDescriptions[14]) ⭐⭐⭐"
    Write-Host "  16) $($ExampleDescriptions[15]) ⭐⭐⭐"
    Write-Host ""

    $choices = Read-Host "선택 [0-16] (여러 개 입력 가능, 예: 1 2 3)"

    if ($choices -match '\b0\b') {
        $script:SelectedExamples = $Examples
        $script:BuildAll = $true
        Write-Host ""
        Write-Host "✓ 선택: 전체 빌드 (16개)" -ForegroundColor Green
    }
    else {
        $script:SelectedExamples = @()
        foreach ($choice in $choices -split '\s+') {
            $choiceNum = [int]$choice
            if ($choiceNum -lt 1 -or $choiceNum -gt 16) {
                Write-Error-Custom "잘못된 선택: $choice (1-16 사이의 숫자를 입력하세요)"
            }
            $script:SelectedExamples += $Examples[$choiceNum - 1]
        }
        $script:BuildAll = $false
        Write-Host ""
        Write-Host "✓ 선택: $($script:SelectedExamples -join ', ')" -ForegroundColor Green
    }
}

# 빌드 확인
function Confirm-Build {
    Write-Host ""
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
    Write-Host "[3/3] 빌드 설정 확인" -ForegroundColor Cyan
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "빌드 설정:"
    Write-Host "  보드:     $script:SelectedBoard"
    if ($script:BuildAll) {
        Write-Host "  예제:     전체 (16개)"
    }
    else {
        Write-Host "  예제:     $($script:SelectedExamples -join ', ')"
    }
    Write-Host "  빌드타입: $BuildTypeValue"
    Write-Host "  Docker:   $DockerImage"
    Write-Host ""

    $confirm = Read-Host "계속하시겠습니까? [Y/n]"
    if ($confirm -match '^[Nn]') {
        Write-Host "빌드를 취소했습니다."
        exit 0
    }
}

# Docker 확인
function Test-Docker {
    Write-Log "Docker 확인 중..."

    if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
        Write-Error-Custom @"
Docker가 설치되지 않았습니다.

설치 방법:
  1. https://www.docker.com/products/docker-desktop 방문
  2. Docker Desktop for Windows 다운로드
  3. 설치 후 재부팅
  4. Docker Desktop 실행
"@
    }

    try {
        $null = docker info 2>&1
    }
    catch {
        Write-Error-Custom @"
Docker 데몬이 실행되지 않았습니다.

해결 방법:
  1. Docker Desktop을 실행하세요
  2. 작업 표시줄에서 Docker 아이콘이 녹색인지 확인
  3. WSL2 백엔드 사용 권장 (설정 > General > Use WSL 2)
"@
    }

    Write-Log "Docker 확인 완료"
}

# WIZnet-PICO-C 저장소 클론 또는 사용자 프로젝트 검증
function Clone-OrValidateProject {
    param([string]$UserProject)

    if ($UserProject) {
        # 사용자 프로젝트 사용
        Write-Log "사용자 프로젝트 사용: $UserProject"

        if (-not (Test-Path $UserProject)) {
            Write-Error-Custom "프로젝트 디렉토리가 존재하지 않습니다: $UserProject"
        }

        $script:ProjectDir = $UserProject

        # 필수 파일 확인
        if (-not (Test-Path "$ProjectDir\CMakeLists.txt")) {
            Write-Error-Custom "CMakeLists.txt를 찾을 수 없습니다: $ProjectDir"
        }

        # 서브모듈 확인
        Write-Log "서브모듈 검증 중..."
        if (-not (Test-Path "$ProjectDir\libraries\pico-sdk\CMakeLists.txt")) {
            Write-Error-Custom @"
Pico SDK 서브모듈이 초기화되지 않았습니다!

다음 명령으로 서브모듈을 초기화하세요:
  cd $ProjectDir
  git submodule update --init --recursive
"@
        }
        if (-not (Test-Path "$ProjectDir\libraries\ioLibrary_Driver\Ethernet")) {
            Write-Error-Custom @"
ioLibrary_Driver 서브모듈이 초기화되지 않았습니다!

다음 명령으로 서브모듈을 초기화하세요:
  cd $ProjectDir
  git submodule update --init --recursive
"@
        }
        if (-not (Test-Path "$ProjectDir\libraries\mbedtls\CMakeLists.txt")) {
            Write-Error-Custom @"
mbedtls 서브모듈이 초기화되지 않았습니다!

다음 명령으로 서브모듈을 초기화하세요:
  cd $ProjectDir
  git submodule update --init --recursive
"@
        }

        Write-Log "사용자 프로젝트 검증 완료"
    }
    else {
        # 기본 동작: WIZnet-PICO-C 클론
        if (Test-Path $ProjectDir) {
            Write-Log "기존 프로젝트 디렉토리 발견: $ProjectDir"
            Write-Log "서브모듈 업데이트 확인 중..."
            Push-Location $ProjectDir
            git submodule update --init --recursive
            Pop-Location
        }
        else {
            Write-Log "WIZnet-PICO-C 저장소 클론 중..."
            git clone --recurse-submodules $RepoUrl $ProjectDir

            Write-Log "서브모듈 초기화 중..."
            Push-Location $ProjectDir
            git submodule update --init --recursive
            Pop-Location
        }

        # 서브모듈 초기화 확인
        if (-not (Test-Path "$ProjectDir\libraries\pico-sdk\CMakeLists.txt")) {
            Write-Error-Custom "Pico SDK 서브모듈이 초기화되지 않았습니다!"
        }
        if (-not (Test-Path "$ProjectDir\libraries\ioLibrary_Driver\Ethernet")) {
            Write-Error-Custom "ioLibrary_Driver 서브모듈이 초기화되지 않았습니다!"
        }
        if (-not (Test-Path "$ProjectDir\libraries\mbedtls\CMakeLists.txt")) {
            Write-Error-Custom "mbedtls 서브모듈이 초기화되지 않았습니다!"
        }

        Write-Log "서브모듈 초기화 완료"
    }
}

# CMakeLists.txt 수정
function Update-CMakeLists {
    param([string]$BoardName)

    $cmakeFile = "$ProjectDir\CMakeLists.txt"
    Write-Log "CMakeLists.txt 수정 중: BOARD_NAME=$BoardName"

    # 백업이 없으면 생성
    if (-not (Test-Path "$cmakeFile.bak")) {
        Copy-Item $cmakeFile "$cmakeFile.bak"
    }
    else {
        # 백업에서 복원
        Copy-Item "$cmakeFile.bak" $cmakeFile -Force
    }

    # 파일 읽기
    $content = Get-Content $cmakeFile -Raw

    # 모든 set(BOARD_NAME ...) 라인 주석 처리
    $content = $content -replace '(?m)^set\(BOARD_NAME ', '#set(BOARD_NAME '
    $content = $content -replace '(?m)^#set\(BOARD_NAME ', '#set(BOARD_NAME '

    # 13번 라인에 활성화된 BOARD_NAME 설정
    $lines = $content -split "`n"
    $lines[12] = "set(BOARD_NAME $BoardName)"
    $content = $lines -join "`n"

    # 파일 쓰기
    $content | Out-File -FilePath $cmakeFile -Encoding UTF8 -NoNewline

    # 검증
    if (-not (Select-String -Path $cmakeFile -Pattern "^set\(BOARD_NAME $BoardName\)" -Quiet)) {
        Write-Error-Custom "CMakeLists.txt 수정 실패!"
    }

    Write-Log "CMakeLists.txt 수정 완료"
}

# Docker 빌드 실행
function Invoke-DockerBuild {
    param([string[]]$ExampleList)

    Write-Log "Docker 이미지 pull 중: $DockerImage"
    docker pull $DockerImage

    # 디렉토리 생성
    New-Item -ItemType Directory -Force -Path $OutDir | Out-Null
    New-Item -ItemType Directory -Force -Path $CcacheDirHost | Out-Null

    # 절대 경로 변환 (Windows 경로를 WSL 경로로 변환)
    $absProjectDir = (Resolve-Path $ProjectDir).Path -replace '\\', '/' -replace '^([A-Z]):', { "/mnt/$($_.Groups[1].Value.ToLower())" }
    $absOutDir = (Resolve-Path $OutDir).Path -replace '\\', '/' -replace '^([A-Z]):', { "/mnt/$($_.Groups[1].Value.ToLower())" }
    $absCcacheDir = (Resolve-Path $CcacheDirHost).Path -replace '\\', '/' -replace '^([A-Z]):', { "/mnt/$($_.Groups[1].Value.ToLower())" }
    $absDockerBuildSh = ((Resolve-Path "docker-build.sh").Path -replace '\\', '/' -replace '^([A-Z]):', { "/mnt/$($_.Groups[1].Value.ToLower())" })

    # 호스트 examples 마운트 설정
    $examplesMount = @()
    if (Test-Path $ExamplesDir) {
        $absExamplesDir = (Resolve-Path $ExamplesDir).Path -replace '\\', '/' -replace '^([A-Z]):', { "/mnt/$($_.Groups[1].Value.ToLower())" }
        $examplesMount = @("-v", "${absExamplesDir}:/work/src/examples:rw")
        Write-Log "호스트 examples 사용: $absExamplesDir"
    }

    Write-Log "Docker 빌드 시작..."
    Write-Log "  소스: $absProjectDir"
    Write-Log "  산출물: $absOutDir"
    Write-Log "  ccache: $absCcacheDir"
    Write-Log "  tmpfs: $TmpfsSize (RAM disk)"

    # 시작 시간 기록
    $startTime = Get-Date

    # Docker 빌드 실행
    $dockerArgs = @(
        "run", "--rm",
        "-v", "${absProjectDir}:/work/src:rw",
        "-v", "${absOutDir}:/work/out:rw",
        "-v", "${absCcacheDir}:/work/.ccache:rw",
        "-v", "${absDockerBuildSh}:/docker-build.sh:ro"
    )
    $dockerArgs += $examplesMount
    $dockerArgs += @(
        "--tmpfs", "/work/src/build:rw,exec,size=$TmpfsSize",
        "-e", "CCACHE_DIR=/work/.ccache",
        "-e", "JOBS=$Jobs",
        "-e", "BUILD_TYPE=$BuildTypeValue",
        $DockerImage,
        "bash", "/docker-build.sh"
    )

    & docker $dockerArgs

    # 종료 시간 계산
    $endTime = Get-Date
    $elapsed = $endTime - $startTime
    $minutes = [int]$elapsed.TotalMinutes
    $seconds = [int]$elapsed.Seconds

    Write-Host ""
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Green
    Write-Host "✅ 빌드 성공! (소요 시간: ${minutes}분 ${seconds}초)" -ForegroundColor Green
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Green
    Write-Host ""
    Write-Host "생성된 파일:"
    Get-ChildItem "$OutDir\*.uf2" -ErrorAction SilentlyContinue | ForEach-Object {
        Write-Host "  $($_.Name) ($([math]::Round($_.Length / 1KB))K)"
    }
    Write-Host ""
    Write-Host "산출물 위치: $(Resolve-Path $OutDir)"
    Write-Host ""
    Write-Host "다음 단계:"
    Write-Host "  1. $script:SelectedBoard를 USB로 연결"
    Write-Host "  2. BOOTSEL 버튼을 누른 채 RESET 버튼 클릭"
    Write-Host "  3. out\*.uf2를 드래그앤드롭"
    Write-Host "  4. 시리얼 터미널로 로그 확인 (115200 baud)"
    Write-Host ""
}

# examples 폴더 초기화 (호스트로 복사)
function Initialize-Examples {
    Write-Log "examples 폴더 초기화 중..."

    # WIZnet-PICO-C가 없으면 먼저 클론
    if (-not (Test-Path $ProjectDir)) {
        Write-Log "WIZnet-PICO-C 저장소 클론 중..."
        git clone --recurse-submodules $RepoUrl $ProjectDir
    }

    # examples 폴더 확인
    if (-not (Test-Path "$ProjectDir\examples")) {
        Write-Error-Custom "$ProjectDir\examples 폴더를 찾을 수 없습니다!"
    }

    # 호스트 examples 폴더가 이미 있는지 확인
    if (Test-Path $ExamplesDir) {
        Write-Warning-Custom "호스트 examples 폴더가 이미 존재합니다: $ExamplesDir"
        $overwrite = Read-Host "덮어쓸까요? [y/N]"
        if ($overwrite -notmatch '^[Yy]') {
            Write-Log "초기화를 취소했습니다."
            exit 0
        }
        Remove-Item -Recurse -Force $ExamplesDir
    }

    # examples 복사
    Write-Log "examples 폴더 복사 중: $ProjectDir\examples -> $ExamplesDir"
    Copy-Item -Recurse "$ProjectDir\examples" $ExamplesDir

    Write-Host ""
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    Write-Host "✅ examples 폴더 초기화 완료!" -ForegroundColor Green
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    Write-Host ""
    Write-Host "이제 다음과 같이 사용할 수 있습니다:"
    Write-Host ""
    Write-Host "  1. 예제 수정:"
    Write-Host "     notepad $ExamplesDir\http\w5x00_http_server.c"
    Write-Host ""
    Write-Host "  2. 빌드 (자동으로 수정된 examples 사용):"
    Write-Host "     .\build.ps1 -b W5500_EVB_PICO -a"
    Write-Host ""
    Write-Host "  3. 빌드 시 호스트의 $ExamplesDir가 자동으로 마운트됩니다."
    Write-Host ""
}

# 빌드 정리
function Clear-Build {
    Write-Log "빌드 정리 중..."

    if (Test-Path "$ProjectDir\build") {
        Remove-Item -Recurse -Force "$ProjectDir\build"
        Write-Log "제거: $ProjectDir\build"
    }

    if (Test-Path "$ProjectDir\CMakeLists.txt.bak") {
        Move-Item -Force "$ProjectDir\CMakeLists.txt.bak" "$ProjectDir\CMakeLists.txt"
        Write-Log "복원: CMakeLists.txt"
    }

    if (Test-Path $OutDir) {
        Remove-Item -Recurse -Force $OutDir
        Write-Log "제거: $OutDir"
    }

    # ccache 정리는 선택 사항
    $cleanCcache = Read-Host "ccache 디렉토리도 삭제할까요? [y/N]"
    if ($cleanCcache -match '^[Yy]') {
        if (Test-Path $CcacheDirHost) {
            Remove-Item -Recurse -Force $CcacheDirHost
            Write-Log "제거: $CcacheDirHost"
        }
    }

    Write-Log "빌드 정리 완료"
}

# 메인 로직
function Main {
    # 헤더
    Write-Host ""
    Write-Host "╔══════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║  WIZnet-PICO-C Docker Build System v$Version               ║" -ForegroundColor Cyan
    Write-Host "╚══════════════════════════════════════════════════════════╝" -ForegroundColor Cyan

    # 도움말
    if ($Help) {
        Show-Help
        exit 0
    }

    # examples 초기화
    if ($InitExamples) {
        Initialize-Examples
        exit 0
    }

    # 빌드 정리
    if ($Clean) {
        Clear-Build
        exit 0
    }

    # Interactive 모드
    if ($Interactive) {
        Select-Board
        Select-Examples
        Confirm-Build
    }
    else {
        # 명령줄 모드 검증
        if (-not $Board) {
            Write-Error-Custom @"
보드를 지정하세요: -Board BOARD_NAME

사용법: .\build.ps1 -Help
"@
        }

        if ($Board -notin $Boards) {
            Write-Error-Custom @"
잘못된 보드명: $Board

사용 가능한 보드: $($Boards -join ', ')
"@
        }

        $script:SelectedBoard = $Board

        if ($All) {
            $script:SelectedExamples = $Examples
            $script:BuildAll = $true
        }
        elseif ($Example) {
            $script:SelectedExamples = $Example
            $script:BuildAll = $false

            foreach ($ex in $Example) {
                if ($ex -notin $Examples) {
                    Write-Error-Custom @"
잘못된 예제명: $ex

사용 가능한 예제: $($Examples -join ', ')
"@
                }
            }
        }
        else {
            Write-Error-Custom @"
예제를 지정하세요: -Example EXAMPLE 또는 -All

사용법: .\build.ps1 -Help
"@
        }
    }

    # Docker 확인
    Test-Docker

    # 저장소 클론 또는 사용자 프로젝트 검증
    Clone-OrValidateProject -UserProject $Project

    # CMakeLists.txt 수정
    Update-CMakeLists $script:SelectedBoard

    # Docker 빌드 실행
    Invoke-DockerBuild $script:SelectedExamples
}

# 스크립트 실행
Main
