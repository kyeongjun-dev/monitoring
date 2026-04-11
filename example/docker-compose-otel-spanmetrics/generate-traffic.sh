#!/bin/bash

HOST=${1:-localhost}
PORT=${2:-8080}
BASE_URL="http://${HOST}:${PORT}"

echo "Sending traffic to ${BASE_URL} ... (Ctrl+C to stop)"

while true; do
  # 0~9 랜덤
  RAND=$((RANDOM % 10))

  if [ $RAND -le 5 ]; then
    # 60% : 정상 요청
    curl -s "${BASE_URL}/" > /dev/null
    echo "[$(date +%H:%M:%S)] GET /  → 200"

  elif [ $RAND -le 7 ]; then
    # 20% : 지연 요청 (1~3초, tail sampling slow-traces-policy 트리거)
    DELAY=$((RANDOM % 3 + 1))
    curl -s "${BASE_URL}/delay?delay=${DELAY}" > /dev/null
    echo "[$(date +%H:%M:%S)] GET /delay?delay=${DELAY}  → 200 (slow)"

  elif [ $RAND -eq 8 ]; then
    # 10% : 4xx 에러 (401~404 중 랜덤)
    CODE=$((RANDOM % 4 + 401))
    curl -s "${BASE_URL}/error${CODE}" > /dev/null
    echo "[$(date +%H:%M:%S)] GET /error${CODE}  → ${CODE}"

  else
    # 10% : IP 조회 (정상, 다른 엔드포인트)
    curl -s "${BASE_URL}/ip" > /dev/null
    echo "[$(date +%H:%M:%S)] GET /ip  → 200"
  fi

  sleep 0.5
done
