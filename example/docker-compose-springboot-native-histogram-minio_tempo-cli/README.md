## 실행순서
minio만 실행
```
docker-compose up -d minio
```

`localhost:9001` 접속 후, `tempo` 버킷 및 ACCESS_KEY 생성 및 `tempo.yaml` 파일의 storage 부분에 입력
```
storage:
  trace:
    backend: s3
    s3:
      bucket: tempo
      endpoint: minio:9000
      access_key: <enter access key>
      secret_key: <enter secret key>
      insecure: true
```

root 디렉토리의 스크립트 파일을 실행하여 trace 생성
```
sh curl-springboot-delay.sh 8080
```

`tempo.yaml` 파일에 입력된 아래 값에 따라, 5분 뒤에 minio의 `tempo` 버킷에 `single-tenant` Object에 데이터가 생성되는 것을 확인
```
ingester:
  max_block_duration: 5m
```