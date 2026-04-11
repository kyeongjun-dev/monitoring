# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

이 저장소는 Grafana observability 스택(Tempo, Prometheus, Grafana, Loki, Mimir, Alloy, OTel Collector)을 다양한 방식으로 구성하는 예제 모음입니다. Kubernetes(helmfile) 기반 배포와 docker-compose 기반 로컬 예제 두 가지 방식을 모두 포함합니다.

---

## Kubernetes 환경 (helmfile)

타겟 컨텍스트: `docker-desktop`

### 주요 명령

```bash
# 특정 릴리스만 배포
helmfile sync --selector name=tempo
helmfile sync --selector name=grafana
helmfile sync --selector name=alloy
helmfile sync --selector name=opentelemetry-collector
helmfile sync --selector name=kube-prometheus-stack

# Springboot 앱 배포
kubectl create ns springboot
kubectl apply -f example/springboot/springboot-k8s-otel.yaml -n springboot
# 또는
kubectl apply -f example/springboot/springboot-k8s-alloy.yaml -n springboot

# fluent-bit 설치 (default 네임스페이스)
kubectl -n default create -f fluentbit/rabc.yaml
kubectl -n default create -f fluentbit/configmap.yaml
kubectl -n default create -f fluentbit/daemonset.yaml
```

### Helm chart / values 구조

- `charts/` — 로컬에 vendoring된 Helm charts (tempo, grafana, alloy, kube-prometheus-stack, opentelemetry-collector, mimir-distributed 등)
- `values/` — 각 chart에 대응하는 values 파일
- `helmfile.yaml` — 전체 릴리스 정의

---

## Docker Compose 예제 디렉토리

| 디렉토리 | 설명 |
|---|---|
| `example/docker-compose-springboot-native-histogram/` | Springboot + Native Histogram 기본 예제 |
| `example/docker-compose-springboot-native-histogram-minio/` | 위 예제에 MinIO(S3) Tempo 스토리지 추가 |
| `example/docker-compose-springboot-native-histogram-local_tempo-cli/` | Local storage + tempo-cli 사용 예제 |
| `example/docker-compose-springboot-native-histogram-minio_tempo-cli/` | MinIO + tempo-cli 사용 예제 |
| `example/docker-compose-springboot-native-histogram-nodejs/` | Springboot + Node.js(Next.js) 혼합 예제 |
| `example/nextjs/` | Next.js 단독 OTel 예제 |
| `example/play-with-prometheus-native/` | Prometheus native histogram 비교 실험 |
| `example/prometheus_native_histogram_go_client_on_k8s/` | Go client native histogram on k8s |
| `example/docker-compose-otel-spanmetrics/` | OTel Collector 2-Layer 구조로 Spanmetrics(RED 메트릭) + Tail Sampling 동시 운용 예제 |

### docker-compose 공통 시작 방법

```bash
# Local storage 예제는 tempo-data 디렉토리 먼저 생성 필요
mkdir tempo-data/
docker compose up -d
docker compose down -v
```

### MinIO 예제 시작 순서

```bash
# 1. MinIO만 먼저 기동
docker-compose up -d minio

# 2. localhost:9001에서 버킷(tempo) 및 ACCESS_KEY 생성 후
#    tempo.yaml의 storage.trace.s3 항목에 access_key / secret_key 입력

# 3. 나머지 스택 기동
docker-compose up -d
```

---

## Springboot 데모 앱

- 소스코드: `example/springboot/demo/`
- Docker 빌드: `docker build -t kyeongjundev/springboot:local example/springboot`
- OTel Java agent(`opentelemetry-javaagent.jar`)를 사이드카 방식 없이 Dockerfile에서 직접 주입
- 트레이스는 OTLP gRPC로 OTel Collector 또는 Alloy로 전송

### 엔드포인트

| 경로 | 설명 |
|---|---|
| `/` | Hello World 출력 |
| `/ip` | 컨테이너 IP 출력 |
| `/delay?delay=<초>` | 지정 시간 sleep 후 응답 |
| `/error401` ~ `/error404` | 각 HTTP 에러 코드 반환 |

### 부하 생성 스크립트

```bash
sh curl-springboot-delay.sh 8080
```

---

## Node.js(Next.js) 예제

- 앱 소스: `example/docker-compose-springboot-native-histogram-nodejs/nodejs/my-app/` 및 `example/nextjs/my-app/`
- OTel 계측: `instrumentation.ts` / `instrumentation.node.ts`에서 `@opentelemetry/sdk-node` 사용
- 환경변수로 OTel endpoint 주입 (`OTEL_EXPORTER_OTLP_ENDPOINT`, `OTEL_SERVICE_NAME` 등)

---

## tempo-cli 사용법

```bash
./tempo-cli query trace-summary <traceID> single-tenant \
  --backend=local \
  --bucket=./example/docker-compose-springboot-native-histogram-minio_tempo-cli/tempo-data/blocks/
```

---

## Grafana Datasource 설정 참고

**Loki**
- URL: `http://loki-gateway`
- Derived fields: `trace_id` / Regex `\b([0-9a-fA-F]{32})\b` / Internal link → Tempo

**Tempo**
- URL: `http://tempo:3100`
- Trace to logs: Loki, Span start `-30m` / end `+30m`, Tag `service.name as app`, Filter by trace ID 활성화
