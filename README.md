# monitoring
## Grafana Datasource
`enable` 명시하지 않은 경우, 기본 설정 사용
### Grafana에서 Datasource로 Loki 추가
```
// HTTP.URL
http://loki-gateway

// Derived fields
Name  : trace_id
Regex : \b([0-9a-fA-F]{32})\b
Query : ${__value.raw}

// Internal link
Tempo
```

### Grafana에서 Datasource로 Tempo 추가
```
// Connection.URL
http://tempo:3100

// Trace to logs
Data source : Loki
Span start time shift : -30m
Span end time shift : 30m
Tags : service.name as app
Filter by trace ID : enable
```

### fluent-bit 설치
`default` 네임스페이스에 데몬셋으로 설치
```
kubectl -n default create -f fluentbit/rabc.yaml
kubectl -n default create -f fluentbit/configmap.yaml
kubectl -n default create -f fluentbit/daemonset.yaml
```

### Dockerfile 빌드
```
docker build -t kyeongjundev/springboot:local example/springboot
```
---
# 테스트 환경 세팅
### grafana stack 배포
tempo, grafana 배포
```
helmfile sync --selector name=tempo
helmfile sync --selector name=grafana
```

alloy or otel collector 배포
```
helmfile sync --selector name=alloy
helmfile sync --selector name=opentelemetry-collector
```

### prometheus 배포
kube prometheus stack 배포
```
helmfile sync --selector name=kube-prometheus-stack
```


### springboot 배포
namespace 생성
```
kubectl create ns springboot
```

`example/springboot/springboot-k8s-alloy.yaml` 또는 `example/springboot/springboot-k8s-otel.yaml` 설치
```
kubectl apply -f example/springboot/springboot-k8s-alloy.yaml -n springboot
kubectl apply -f example/springboot/springboot-k8s-otel.yaml -n springboot
```
---
## Springboot 설정
endpoint 리스트
```
helloworld 출력
/

ip주소 출력
/ip

error 반환
/error401
/error402
/error403
/error404

입력한 초 n 만큰 sleep 후 응답
/delay?delay=3
```
---
# Native Histogram - go client 예시
## play-with-prometheus-native
아래 명령어로 컨테이너를 실행
```
cd example/play-with-prometheus-native
docker-compose up -d
```

`native-histogram` feature가 활성화된 9090 포트와 9091 포트의 프로메테우스에 접속해서 각각 `http_request_durations`를 검색하여 차이 확인
```
// 9090
http_request_durations (histogram)

// 9090
http_request_durations_sum (counter)
http_request_durations_count (counter)
http_request_durations_bucket (counter)
```

## prometheus_native_histogram_go_client_on_k8s
아래 경로로 이동 및 도커 빌드
```
cd example/prometheus_native_histogram_go_client_on_k8s
docker build -t go:local .
```

`example/prometheus_native_histogram_go_client_on_k8s/go.yaml` 파일 배포
```
kubectl create ns go
kubectl apply -f example/prometheus_native_histogram_go_client_on_k8s/go.yaml -n go
```

`values/kube-prometheuss-tack.yaml` 파일 최하단의 아래 부분에서 scrap
```
    additionalScrapeConfigs:
    - job_name: go-client
      scrape_interval: 10s
      static_configs:
      - targets: ["go.go.svc.cluster.local:8080"]
```

프로메테우스에서 request_latency_seconds 검색
```
request_latency_seconds (histogram)
```