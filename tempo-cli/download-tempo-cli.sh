#!/bin/bash

# 운영체제 및 아키텍처 감지
OS=$(uname -s | tr '[:upper:]' '[:lower:]')  # darwin, linux 변환
ARCH=$(uname -m)

# 아키텍처 변환
if [ "$ARCH" == "x86_64" ]; then
    ARCH="amd64"
elif [ "$ARCH" == "arm64" || "$ARCH" == "aarch64" ]; then
    ARCH="arm64"
else
    echo "지원되지 않는 아키텍처: $ARCH"
    exit 1
fi

# 파일명 및 다운로드 URL 설정
VERSION=$1
FILENAME="tempo_${VERSION}_${OS}_${ARCH}.tar.gz"
URL="https://github.com/grafana/tempo/releases/download/v${VERSION}/${FILENAME}"

# 파일 다운로드
echo "다운로드 중: $URL"
wget -O "$FILENAME" "$URL"

# 다운로드 확인
if [[ -f "$FILENAME" ]]; then
    echo "다운로드 완료: $FILENAME"
else
    echo "다운로드 실패!"
fi

echo "tempo-cli만 압축해제"
tar xvzf $FILENAME tempo-cli

echo "압축파일 삭제"
rm $FILENAME
