# OTel Collector — Spanmetrics + Tail Sampling 예제

Spanmetrics(RED 메트릭 생성)와 Tail Sampling(지능형 트레이스 샘플링)을 동시에 운용하기 위해 OTel Collector를 2-Layer 구조로 구성하는 예제입니다.

---

## 아키텍처

### 구성 다이어그램

```
┌─────────────────────────────────────────────────────────────────┐
│  SpringBoot App (demo)  :8080                                   │
└───────────────────────────────┬─────────────────────────────────┘
                                │ OTLP gRPC (:4317)
                                ▼
┌─────────────────────────────────────────────────────────────────┐
│  Layer 1 — Load Balancing Exporter                              │
│                                                                 │
│  otel-collector-lb                                              │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  loadbalancing/spanmetrics  routing_key: service        │   │
│  │  loadbalancing/tailsampling routing_key: traceID        │   │
│  └──────────────────┬────────────────────┬─────────────────┘   │
└─────────────────────┼────────────────────┼─────────────────────┘
                      │ Consistent Hashing  │ Consistent Hashing
               by ServiceName          by TraceID
                      │                    │
          ┌───────────▼──────┐   ┌─────────▼────────────┐
          │  Layer 2-A       │   │  Layer 2-B            │
          │                  │   │                       │
          │  otel-collector  │   │  otel-collector       │
          │  -spanmetrics    │   │  -tailsampling        │
          │                  │   │                       │
          │  spanmetrics     │   │  tail_sampling        │
          │  connector       │   │  processor            │
          └───────┬──────────┘   └─────────┬─────────────┘
                  │ Prometheus               │ OTLP gRPC
                  │ Remote Write             │
                  ▼                          ▼
            Prometheus                    Tempo
                  │                          │
                  └──────────┬───────────────┘
                             ▼
                           Grafana
```

### Layer 구성

| Layer | 컴포넌트 | 역할 |
|---|---|---|
| Layer 1 | `otel-collector-lb` | OTLP 수신 후 두 개의 하위 Collector로 라우팅 |
| Layer 2-A | `otel-collector-spanmetrics` | Span에서 RED 메트릭을 생성해 Prometheus로 전송 |
| Layer 2-B | `otel-collector-tailsampling` | TraceID 단위로 샘플링 결정 후 Tempo로 전송 |

---

## 핵심 개념

### Load Balancing Exporter가 필요한 이유

Tail Sampling Processor는 **동일한 TraceID에 속한 모든 Span이 하나의 Collector 인스턴스에 도달**해야 샘플링 결정을 올바르게 내릴 수 있습니다.
Span이 서로 다른 Collector로 분산되면 각 인스턴스가 트레이스의 일부만 보게 되므로 Tail Sampling이 제대로 동작하지 않습니다.

마찬가지로 Spanmetrics Connector도 **동일한 서비스의 모든 Span이 하나의 인스턴스로 집약**되어야 정확한 RED 메트릭을 생성할 수 있습니다.

### Consistent Hashing을 통한 라우팅

여러 대의 Load Balancing Exporter가 존재하더라도, Consistent Hashing 알고리즘을 통해 동일한 키(TraceID 또는 ServiceName)는 항상 동일한 백엔드 Collector로 전달됩니다.

### Routing Key 종류

| Routing Key | 사용 대상 | 이유 |
|---|---|---|
| `service` | Spanmetrics Collector | 같은 서비스의 Span을 모아야 정확한 메트릭 집계가 가능 |
| `traceID` | Tail Sampling Collector | 같은 TraceID의 Span을 모아야 올바른 샘플링 결정이 가능 |

---

## 시작 방법

```bash
# Tempo 로컬 스토리지 디렉토리 생성 (최초 1회)
mkdir tempo-data/

# 전체 스택 실행
docker compose up -d

# 전체 스택 중지 및 볼륨 삭제
docker compose down -v
```

---

## 서비스 포트

| 서비스 | 포트 | 설명 |
|---|---|---|
| Grafana | 3000 | 대시보드 |
| Prometheus | 9090 | 메트릭 |
| Tempo | 3200 | 트레이스 쿼리 |
| otel-collector-lb | 4317 | OTLP gRPC 수신 (SpringBoot → LB) |
| SpringBoot | 8080 | 데모 앱 |

---

## 트래픽 생성

```bash
# 일반 트래픽 — probabilistic-policy 트리거
while true; do curl -s http://localhost:8080/ > /dev/null; sleep 0.5; done

# 지연 트레이스 — slow-traces-policy 트리거 (2초 지연)
curl "http://localhost:8080/delay?delay=2"

# 에러 트레이스 — errors-policy 트리거
curl http://localhost:8080/error500
```

또는 제공된 스크립트를 사용합니다.

```bash
sh generate-traffic.sh
```

---

## Tail Sampling 정책

| 정책 | 조건 | 수집 비율 |
|---|---|---|
| `errors-policy` | ERROR 상태코드를 포함한 Trace | 100% |
| `slow-traces-policy` | 1000ms 이상 소요된 Trace | 100% |
| `probabilistic-policy` | 위 조건에 해당하지 않는 나머지 Trace | 10% |

> `decision_wait: 10s` — Tail Sampling 결정을 내리기 전에 Trace의 모든 Span이 도착할 때까지 최대 10초 대기합니다.
