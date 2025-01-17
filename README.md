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