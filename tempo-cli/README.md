## tempo-cli 바이너리 파일 다운로드
2.7.1 버전 다운로드
```
/bin/bash download-tempo-cli.sh 2.7.1
```

명령어 실행
```
./tempo-cli -h
```

도커허브 이미지
```
kyeongjundev/ubuntu-tempo-cli:latest
kyeongjundev/ubuntu-tempo-cli:2.7.1
```

빌드명령어 기록
```
docker buildx create --use
docker buildx build -t kyeongjundev/ubuntu-tempo-cli:latest --platform linux/amd64,linux/arm64 . --push
docker buildx build -t kyeongjundev/ubuntu-tempo-cli:2.7.1 --platform linux/amd64,linux/arm64 . --push
```