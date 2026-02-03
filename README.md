# WIZnet-PICO-C Docker Build System

> **WIZnet 이더넷 보드(10종)용 C 예제(16종)를 3분 안에 빌드하는 Docker 기반 시스템**

## 프로젝트 상태

🚧 **현재 상태: 기획 단계**

- [x] 프로젝트 분석 완료
- [x] Dockerfile 최적화 완료
- [x] docker-build.sh 수정 완료
- [ ] build.sh 작성 (진행 예정)
- [ ] build.ps1 작성 (진행 예정)
- [ ] 테스트 빌드
- [ ] 문서화

## 빠른 시작 (예정)

```bash
# 저장소 클론
git clone https://github.com/simryang/wiznet-pico-c-docker
cd wiznet-pico-c-docker

# Interactive 빌드
./build.sh -i

# 보드 선택 → 예제 선택 → 빌드 완료!
```

## 지원 하드웨어

### RP2040 기반 (6종)
- WIZnet Ethernet HAT (W5100S)
- W5100S-EVB-Pico
- W5500-EVB-Pico ⭐ 권장
- W55RP20-EVB-Pico
- W6100-EVB-Pico
- W6300-EVB-Pico

### RP2350 (Pico2) 기반 (4종)
- W5100S-EVB-Pico2
- W5500-EVB-Pico2
- W6100-EVB-Pico2
- W6300-EVB-Pico2

## 지원 예제 (16종)

**기본 네트워킹:** loopback, udp, http, tcp_server_multi_socket

**프로토콜:** dhcp_dns, sntp, mqtt, tftp, netbios, pppoe, upnp

**보안 통신:** tcp_client_over_ssl, tcp_server_over_ssl

**고급 기능:** udp_multicast, can, network_install

## 프로젝트 구조

```
wiznet-pico-c-docker/
├── Dockerfile              # 최적화된 빌드 환경
├── docker-build.sh         # 컨테이너 내부 빌드 스크립트
├── entrypoint.sh           # Docker 진입점
├── build.sh                # Bash 빌드 스크립트 (TODO)
├── build.ps1               # PowerShell 스크립트 (TODO)
├── README.md               # 이 파일
├── PROJECT_SPEC.md         # 상세 기술 명세서
├── docs/                   # 문서
└── tests/                  # 테스트 스크립트
```

## 기술 스택

- **컨테이너:** Docker (Ubuntu 22.04)
- **빌드 시스템:** CMake 3.28 + Ninja
- **컴파일러:** ARM GNU Toolchain 14.2
- **캐싱:** ccache
- **언어:** Bash, PowerShell

## 개발 계획

### Phase 1: MVP (1일)
- [ ] build.sh 작성 (보드/예제 선택)
- [ ] W5500-EVB-Pico + http 테스트

### Phase 2: Windows 지원 (0.5일)
- [ ] build.ps1 작성
- [ ] Interactive 모드

### Phase 3: 문서화 (0.5일)
- [ ] WCC 기사 작성
- [ ] 사용 가이드

## 참고 자료

- **WIZnet-PICO-C:** https://github.com/WIZnet-ioNIC/WIZnet-PICO-C
- **기반 프로젝트:** https://github.com/simryang/w55rp20-docker-build
- **상세 명세서:** [PROJECT_SPEC.md](PROJECT_SPEC.md)

## 라이선스

MIT License

---

**작성자:** simryang
**최종 업데이트:** 2026-01-30
