package main

import (
	"math/rand"
	"net/http"
	"time"

	"github.com/prometheus/client_golang/prometheus"
	"github.com/prometheus/client_golang/prometheus/promhttp"
)

func main() {
	// Native Histogram 정의
	histogram := prometheus.NewHistogramVec(
		prometheus.HistogramOpts{
			Name:                       "request_latency_seconds",
			Help:                       "Histogram of request latency in seconds",
			NativeHistogramBucketFactor: 1.1,
			NativeHistogramMaxBucketNumber: 100,
			NativeHistogramMinResetDuration: 1 * time.Hour,
		},
	)

	// Histogram을 레지스트리에 등록
	prometheus.MustRegister(histogram)

	// 데이터를 관찰하는 Goroutine
	go func() {
		for {
			// 랜덤 요청 지연 시간을 관찰
			latency := rand.Float64() * 5 // 0~5초 사이 랜덤
			histogram.Observe(latency)
			time.Sleep(500 * time.Millisecond) // 0.5초 간격으로 관찰
		}
	}()

	// HTTP 서버에서 /metrics 엔드포인트로 Prometheus 메트릭 노출
	http.Handle("/metrics", promhttp.Handler())

	// 서버 실행
	port := ":8080"
	println("Starting server at http://localhost" + port)
	if err := http.ListenAndServe(port, nil); err != nil {
		panic(err)
	}
}