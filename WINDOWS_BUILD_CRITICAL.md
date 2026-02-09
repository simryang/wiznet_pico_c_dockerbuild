# Windows Docker 빌드 - 필수 체크리스트

> **경고**: 이 문서의 내용을 지키지 않으면 Windows 빌드가 실패합니다!
>
> 본 프로젝트와 w55rp20 프로젝트에서 동일하게 발생한 문제들입니다.

---

## 📌 목차

1. [PowerShell 스크립트 인코딩](#1-powershell-스크립트-인코딩-critical)
2. [PowerShell 예약 파라미터](#2-powershell-예약-파라미터)
3. [Windows 경로 vs WSL 경로](#3-windows-경로-vs-wsl-경로-critical)
4. [Docker Desktop for Windows 특성](#4-docker-desktop-for-windows-특성)
5. [검증 체크리스트](#5-검증-체크리스트)

---

## 1. PowerShell 스크립트 인코딩 (CRITICAL)

### ❌ 문제 증상
```
PS> .\build.ps1
?��?��?�� �??��?��?��?��... (한글 깨짐)
```

### ✅ 원인
- PowerShell 스크립트가 **UTF-8 without BOM**으로 저장됨
- Windows PowerShell은 BOM이 없으면 한글을 제대로 표시하지 못함

### ✅ 해결 방법

**모든 `.ps1` 파일은 UTF-8 with BOM으로 저장**

```bash
# 새 파일 작성 시
printf '\xEF\xBB\xBF' > build.ps1
# 이후 내용 추가

# 기존 파일 변환 시
(printf '\xEF\xBB\xBF'; cat build.ps1) > build.ps1.new && mv build.ps1.new build.ps1

# 검증
file build.ps1
# 출력: UTF-8 Unicode (with BOM) text

hexdump -C build.ps1 | head -1
# 첫 3바이트: ef bb bf
```

### ⚠️ 절대 하지 말 것
- ❌ Write 도구로 직접 .ps1 파일 생성 (BOM 없이 저장됨)
- ❌ UTF-8 without BOM 사용
- ❌ 리눅스 에디터로 직접 편집

### ✅ 올바른 방법
- ✅ Bash로 BOM 추가 후 내용 작성
- ✅ Edit 도구 사용 시 BOM 유지 확인
- ✅ 커밋 전 `file *.ps1` 로 검증

### 참고
- w55rp20 프로젝트: 모든 .ps1 파일이 UTF-8 with BOM
- 파일 경로: `~/src/docker/w55rp20/*.ps1`

---

## 2. PowerShell 예약 파라미터

### ❌ 문제 증상
```powershell
이름이 'Debug'인 매개 변수가 명령에 대해 여러 번 정의되었습니다.
```

### ✅ 원인
- `[CmdletBinding()]` 사용 시 자동으로 common parameters 추가됨
- 예약된 파라미터: `-Debug`, `-Verbose`, `-ErrorAction`, `-WarningAction` 등

### ✅ 해결 방법

**예약 파라미터 사용 금지**

```powershell
# ❌ 잘못된 예
[CmdletBinding()]
param(
    [switch]$Debug  # 충돌!
)

# ✅ 올바른 예
[CmdletBinding()]
param(
    [switch]$DebugBuild  # 다른 이름 사용
)
```

### PowerShell 예약 파라미터 목록
```
-Debug
-Verbose
-ErrorAction
-WarningAction
-ErrorVariable
-WarningVariable
-InformationAction
-InformationVariable
-OutVariable
-OutBuffer
-PipelineVariable
```

---

## 3. Windows 경로 vs WSL 경로 (CRITICAL)

### ❌ 가장 흔한 실수

**Docker Desktop for Windows에서 WSL 경로를 사용하면 마운트 실패!**

### 증상
```
/docker-build.sh: /docker-build.sh: Is a directory
docker: invalid spec: :/docker-build.sh:ro: empty section between colons
```

### 원인
```powershell
# ❌ 잘못된 방법 (WSL 경로로 변환)
$absProjectDir = ConvertTo-WSLPath (Resolve-Path $ProjectDir).Path
# 결과: /mnt/d/Test/wiznet_pico_c_dockerbuild/WIZnet-PICO-C

docker run -v "${absProjectDir}:/work/src:rw" ...
# Docker Desktop for Windows는 WSL 경로를 제대로 처리하지 못함!
```

### ✅ 올바른 방법

**Windows 경로를 그대로 사용!**

```powershell
# ✅ 올바른 방법 (Windows 경로 그대로)
$absProjectDir = (Resolve-Path $ProjectDir).Path
# 결과: D:\Test\wiznet_pico_c_dockerbuild\WIZnet-PICO-C

docker run -v "${absProjectDir}:/work/src:rw" ...
# Docker Desktop이 내부적으로 경로 변환 처리
```

### 플랫폼별 차이

| 환경 | 사용할 경로 | 예시 |
|------|------------|------|
| **Linux Docker** | WSL 경로 | `/mnt/d/Test/...` |
| **Windows Docker Desktop** | Windows 경로 | `D:\Test\...` |
| **macOS Docker Desktop** | macOS 경로 | `/Users/...` |

### w55rp20 참고 코드

```powershell
# w55rp20/build-windows.ps1
$dockerArgs = @(
    "run", "--rm", "-t"
    "-v", "${SRC_DIR}:/work/src"      # Windows 경로 그대로!
    "-v", "${OUT_DIR}:/work/out"       # Windows 경로 그대로!
    "-v", "${CCACHE_DIR}:/work/.ccache" # Windows 경로 그대로!
)
```

### 경로 변환 함수는 사용하지 말 것!

```powershell
# ❌ 이런 함수 만들지 말 것
function ConvertTo-WSLPath {
    param([string]$WindowsPath)
    # D:\Test -> /mnt/d/Test 변환 (Docker Desktop에서 문제 발생!)
}

# ✅ 단순하게 유지
$absPath = (Resolve-Path $path).Path  # Windows 경로 그대로
```

---

## 4. Docker Desktop for Windows 특성

### 내부 동작 방식

1. **Windows 경로 자동 변환**
   - `D:\Test\project` → Docker 내부에서 자동 처리
   - WSL2 백엔드 사용 시에도 자동 변환

2. **파일 공유 설정**
   - Docker Desktop > Settings > Resources > File Sharing
   - 프로젝트 드라이브가 공유되어 있는지 확인

3. **WSL2 통합**
   - Docker Desktop이 WSL2를 사용하더라도
   - **입력은 Windows 경로**를 받음

### 볼륨 마운트 규칙

```powershell
# ✅ 올바른 마운트
docker run -v "D:\Test\project:/work/src:rw" ...

# ❌ 잘못된 마운트 (WSL 경로)
docker run -v "/mnt/d/Test/project:/work/src:rw" ...
```

### 파일이 디렉토리로 마운트되는 경우

**원인:**
- 호스트에서 파일을 찾지 못하면 Docker가 자동으로 디렉토리 생성
- WSL 경로 사용 시 발생 가능

**해결:**
1. Windows 경로 사용
2. 마운트 전에 파일 존재 검증

```powershell
# 파일 검증
if (-not (Test-Path $filePath)) {
    Write-Error "파일을 찾을 수 없습니다: $filePath"
    exit 1
}

# 파일인지 디렉토리인지 확인
if ((Get-Item $filePath) -is [System.IO.DirectoryInfo]) {
    Write-Error "파일이 아니라 디렉토리입니다: $filePath"
    exit 1
}
```

---

## 5. 검증 체크리스트

### 개발 시 체크리스트

- [ ] 모든 `.ps1` 파일이 UTF-8 with BOM인가?
  ```bash
  file *.ps1  # 모두 "UTF-8 Unicode (with BOM)" 출력 확인
  ```

- [ ] PowerShell 예약 파라미터를 사용하지 않았는가?
  ```powershell
  # -Debug, -Verbose 등 사용 금지
  ```

- [ ] Windows 경로를 그대로 사용하는가?
  ```powershell
  # WSL 경로 변환 함수 사용 금지
  $absPath = (Resolve-Path $path).Path
  ```

- [ ] Docker 마운트 전에 파일 검증을 하는가?
  ```powershell
  Test-Path $file
  (Get-Item $file) -is [System.IO.FileInfo]
  ```

### 빌드 로그 확인

정상적인 로그:
```
[INFO] docker-build.sh 확인 완료 (크기: 3682 bytes)
[INFO]   소스: D:\Test\wiznet_pico_c_dockerbuild\WIZnet-PICO-C
[INFO]   산출물: D:\Test\wiznet_pico_c_dockerbuild\out
[INFO]   빌드 스크립트: D:\Test\wiznet_pico_c_dockerbuild\docker-build.sh
```

비정상적인 로그:
```
[INFO]   소스: /mnt/d/Test/...  ← WSL 경로 (문제!)
/docker-build.sh: Is a directory  ← 마운트 실패
```

### 디버깅 명령어

```powershell
# 1. 파일 인코딩 확인
file build.ps1

# 2. BOM 바이트 확인
hexdump -C build.ps1 | head -1

# 3. 파일 타입 확인
Get-Item docker-build.sh | Select-Object Mode, Length, FullName

# 4. 경로 확인
(Resolve-Path .).Path  # Windows 경로로 출력되어야 함

# 5. Docker 볼륨 마운트 테스트
docker run --rm -v "${PWD}:/test:ro" alpine ls /test
```

---

## 6. 참고 프로젝트

### w55rp20 프로젝트

**위치:** `~/src/docker/w55rp20/`

**참고할 파일:**
- `build.ps1`: 통합 빌드 스크립트 (UTF-8 with BOM)
- `build-windows.ps1`: Windows Docker 빌드 (경로 처리 참고)
- `build-native-windows.ps1`: Windows 네이티브 빌드

**핵심 패턴:**
```powershell
# 1. 인코딩: UTF-8 with BOM
# 2. 경로: Windows 경로 그대로 사용
# 3. 파라미터: 예약어 사용 안 함
```

---

## 7. 트러블슈팅 히스토리

### 실제 발생했던 문제들 (시간순)

#### 문제 1: UTF-8 without BOM (2026-02-06)
- **증상**: 한글 깨짐
- **해결**: UTF-8 with BOM으로 변환
- **커밋**: `9de315d`

#### 문제 2: -Debug 파라미터 충돌 (2026-02-06)
- **증상**: 파라미터 중복 정의 에러
- **해결**: `-Debug` → `-DebugBuild`
- **커밋**: `98cf523`

#### 문제 3: WSL 경로 사용 (2026-02-06)
- **증상**: `/docker-build.sh: Is a directory`
- **시도 1-4**: 파일 검증 강화 (실패)
- **최종 해결**: WSL 경로 변환 제거
- **커밋**: `6c6bad3` (원인), `ad5be5c` (해결)

---

## 8. AI에게 당부

### 절대 하지 말 것

1. ❌ "정상 작동합니다!" 성급한 선언
   - Windows 환경에서 실제 테스트 전까지 확신 금지

2. ❌ Linux 관점으로 접근
   - Windows Docker Desktop ≠ Linux Docker
   - 경로 처리 방식이 완전히 다름

3. ❌ 증상 치료
   - 파일 검증만 강화하는 것은 해결책이 아님
   - 근본 원인(WSL 경로)을 찾아야 함

### 반드시 할 것

1. ✅ **참고 프로젝트 먼저 분석**
   - w55rp20 프로젝트의 Windows 빌드 방식 참고
   - 검증된 패턴 따르기

2. ✅ **플랫폼별 차이 명확히 구분**
   - Linux: WSL 경로
   - Windows: Windows 경로

3. ✅ **근본 원인 파악 우선**
   - "왜 이런 에러가 발생하는가?"
   - "다른 프로젝트는 어떻게 해결했는가?"

4. ✅ **단계별 검증**
   - 인코딩 확인
   - 파라미터 확인
   - 경로 처리 확인
   - 마운트 검증

---

## 9. 빠른 참조

### PowerShell 스크립트 작성 템플릿

```powershell
#!/usr/bin/env pwsh
# 파일은 UTF-8 with BOM으로 저장!

[CmdletBinding()]
param(
    [switch]$MyOption,  # 예약어 사용 금지!
    [string]$MyPath
)

# 경로 처리
$absPath = (Resolve-Path $MyPath).Path  # Windows 경로 그대로

# 파일 검증
if (-not (Test-Path $absPath)) {
    Write-Error "파일을 찾을 수 없습니다: $absPath"
    exit 1
}

# Docker 실행
docker run -v "${absPath}:/work/data:rw" ...  # Windows 경로 사용
```

### 검증 스크립트

```bash
#!/bin/bash
# check-windows-build.sh

echo "=== Windows 빌드 검증 ==="

# 1. PowerShell 파일 인코딩 확인
echo "1. 인코딩 확인"
for f in *.ps1; do
    encoding=$(file "$f" | grep -o "UTF-8.*")
    if [[ ! "$encoding" =~ "BOM" ]]; then
        echo "  ❌ $f: BOM 없음!"
    else
        echo "  ✅ $f: UTF-8 with BOM"
    fi
done

# 2. 예약 파라미터 확인
echo ""
echo "2. 예약 파라미터 확인"
if grep -n '\$Debug[^B]' *.ps1; then
    echo "  ❌ -Debug 파라미터 사용 발견!"
fi
if grep -n '\$Verbose[^P]' *.ps1; then
    echo "  ❌ -Verbose 파라미터 사용 발견!"
fi

# 3. WSL 경로 변환 함수 확인
echo ""
echo "3. WSL 경로 변환 확인"
if grep -n "ConvertTo-WSLPath" *.ps1 | grep -v "^#"; then
    echo "  ⚠️  WSL 경로 변환 함수 사용 발견!"
    echo "  Docker Desktop for Windows에서는 Windows 경로를 직접 사용해야 합니다."
fi

echo ""
echo "검증 완료"
```

---

## 10. 요약

### 3대 핵심 규칙

1. **UTF-8 with BOM**
   ```bash
   file *.ps1  # "with BOM" 확인
   ```

2. **예약 파라미터 금지**
   ```powershell
   # -Debug, -Verbose 등 사용 금지
   ```

3. **Windows 경로 사용**
   ```powershell
   # WSL 경로 변환 금지!
   $path = (Resolve-Path $p).Path
   ```

### 기억할 것

> **Docker Desktop for Windows는 Windows 경로를 받습니다!**
>
> WSL 경로로 변환하면 마운트가 실패합니다.

---

**마지막 업데이트:** 2026-02-06
**프로젝트:** WIZnet-PICO-C Docker Build System
**참고 프로젝트:** w55rp20 (`~/src/docker/w55rp20/`)
