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