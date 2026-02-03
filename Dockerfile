# syntax=docker/dockerfile:1
#
# WIZnet-PICO-C Docker Build System
#
# 이 Dockerfile은 WIZnet 이더넷 보드(10종)용 C 예제(16종)를
# 빌드하기 위한 크로스 컴파일 환경을 구성합니다.
#
# 기반: w55rp20-docker-build (최적화됨)
# 프로젝트: https://github.com/simryang/wiznet-pico-c-docker
#

FROM ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive

# ===== 버전 고정 =====
ARG CMAKE_VERSION=3.28.3
ARG ARM_GNU_TOOLCHAIN_VERSION=14.2.rel1

# ===== 캐시 무효화 스위치 =====
# build 스크립트에서 REFRESH 환경변수로 제어 가능
# 예: REFRESH="toolchain" ./build.sh
ARG REFRESH_APT=0
ARG REFRESH_CMAKE=0
ARG REFRESH_GCC=0

# buildx 플랫폼 감지
ARG TARGETARCH=amd64

# ===== 툴체인 경로 =====
# 주의: PICO_SDK_PATH는 설정하지 않음!
# WIZnet-PICO-C는 서브모듈(libraries/pico-sdk)을 사용
ENV PICO_TOOLCHAIN_PATH=/opt/toolchain
ENV PATH="/opt/toolchain/bin:/usr/local/bin:${PATH}"

WORKDIR /opt

# ===== 시스템 패키지 설치 =====
RUN echo "REFRESH_APT=$REFRESH_APT" && \
    apt-get update && apt-get install -y --no-install-recommends \
    # 코드 포매터
    astyle \
    # UF2 생성 도구
    srecord \
    # 유틸리티
    file \
    time \
    ca-certificates \
    # 빌드 캐시
    ccache \
    # 다운로드
    curl \
    wget \
    # Git (서브모듈 클론 필수)
    git \
    # 압축
    unzip \
    xz-utils \
    tar \
    # Python (빌드 스크립트)
    python3 \
    python-is-python3 \
    # 빌드 시스템
    ninja-build \
    build-essential \
    pkg-config \
    # USB 디버깅 (선택)
    libusb-1.0-0-dev \
    udev \
    gdb-multiarch \
    openocd \
    # 동기화
    rsync \
    && rm -rf /var/lib/apt/lists/*

# ===== CMake 3.28+ (멀티 아키텍처) =====
RUN echo "REFRESH_CMAKE=$REFRESH_CMAKE" && \
    set -eux; \
    case "$TARGETARCH" in \
      amd64) CMAKE_ARCH="x86_64" ;; \
      arm64) CMAKE_ARCH="aarch64" ;; \
      *) echo "Unsupported TARGETARCH=$TARGETARCH"; exit 1 ;; \
    esac; \
    mkdir -p /opt/cmake; \
    curl -fsSL -o /tmp/cmake.tar.gz \
      "https://github.com/Kitware/CMake/releases/download/v${CMAKE_VERSION}/cmake-${CMAKE_VERSION}-linux-${CMAKE_ARCH}.tar.gz"; \
    tar -xzf /tmp/cmake.tar.gz -C /opt/cmake --strip-components=1; \
    rm -f /tmp/cmake.tar.gz; \
    ln -sf /opt/cmake/bin/cmake /usr/local/bin/cmake; \
    ln -sf /opt/cmake/bin/ctest /usr/local/bin/ctest; \
    ln -sf /opt/cmake/bin/cpack /usr/local/bin/cpack

# ===== ARM GNU Toolchain 14.2 (멀티 아키텍처) =====
RUN echo "REFRESH_GCC=$REFRESH_GCC" && \
    set -eux; \
    case "$TARGETARCH" in \
      amd64) HOST_ARCH="x86_64" ;; \
      arm64) HOST_ARCH="aarch64" ;; \
      *) echo "Unsupported TARGETARCH=$TARGETARCH"; exit 1 ;; \
    esac; \
    curl -fsSL -o /tmp/armgnu.tar.xz \
      "https://developer.arm.com/-/media/Files/downloads/gnu/${ARM_GNU_TOOLCHAIN_VERSION}/binrel/arm-gnu-toolchain-${ARM_GNU_TOOLCHAIN_VERSION}-${HOST_ARCH}-arm-none-eabi.tar.xz"; \
    tar -xJf /tmp/armgnu.tar.xz -C /opt; \
    rm -f /tmp/armgnu.tar.xz; \
    TOOLCHAIN_DIR="$(ls -d /opt/arm-gnu-toolchain-* | head -n 1)"; \
    mkdir -p /opt/toolchain; \
    cp -a "${TOOLCHAIN_DIR}/." /opt/toolchain; \
    rm -rf "${TOOLCHAIN_DIR}"

# ===== 주의: Pico SDK는 설치하지 않음! =====
# WIZnet-PICO-C는 서브모듈(libraries/pico-sdk)을 사용하므로
# Docker 이미지에 Pico SDK를 포함하지 않습니다.
#
# 장점:
#   - 이미지 크기 ~200MB 절약
#   - 버전 충돌 없음 (프로젝트가 자체 관리)
#   - 서브모듈 업데이트 시 자동 반영
#
# 주의:
#   - docker-build.sh는 PICO_SDK_PATH 환경변수를 사용하지 않음
#   - CMakeLists.txt에서 libraries/pico-sdk를 직접 참조

# ===== 빌드 스크립트 =====
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
COPY docker-build.sh /usr/local/bin/docker-build.sh
RUN chmod +x /usr/local/bin/entrypoint.sh /usr/local/bin/docker-build.sh

WORKDIR /work
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

# ===== 메타데이터 =====
LABEL maintainer="simryang"
LABEL description="WIZnet-PICO-C Docker Build System - Build Ethernet examples for 10 WIZnet boards"
LABEL version="1.0.0"
LABEL project="https://github.com/simryang/wiznet-pico-c-docker"
