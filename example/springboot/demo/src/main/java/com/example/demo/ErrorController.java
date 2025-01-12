package com.example.demo;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;


import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

@RestController
public class ErrorController {
    private static final Logger logger = LoggerFactory.getLogger(ErrorController.class);

    @GetMapping("/error401")
    public ResponseEntity<String> handle401() {
        logger.error("401 Unauthorized - 인증이 필요합니다");
        return ResponseEntity
                .status(HttpStatus.UNAUTHORIZED) // 401 상태 코드
                .body("401 Unauthorized - 인증이 필요합니다.");
    }

    @GetMapping("/error402")
    public ResponseEntity<String> handle402() {
        logger.error("402 Payment Required - 결제가 필요합니다");
        return ResponseEntity
                .status(HttpStatus.PAYMENT_REQUIRED) // 402 상태 코드
                .body("402 Payment Required - 결제가 필요합니다.");
    }

    @GetMapping("/error403")
    public ResponseEntity<String> handle403() {
        logger.error("403 Forbidden - 접근이 금지되었습니다");
        return ResponseEntity
                .status(HttpStatus.FORBIDDEN) // 403 상태 코드
                .body("403 Forbidden - 접근이 금지되었습니다.");
    }

    @GetMapping("/error404")
    public ResponseEntity<String> handle404() {
        logger.error("404 Not Found - 요청한 리소스를 찾을 수 없습니다");
        return ResponseEntity
                .status(HttpStatus.NOT_FOUND) // 404 상태 코드
                .body("404 Not Found - 요청한 리소스를 찾을 수 없습니다.");
    }
}