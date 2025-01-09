package com.example.demo;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.net.InetAddress;
import java.net.NetworkInterface;
import java.util.Enumeration;

@RestController
public class HelloWorldController {

    private static final Logger logger = LoggerFactory.getLogger(HelloWorldController.class);

    @GetMapping("")
    public String helloWorld() {
        logger.info("home() has been called");
        return "Hello, world";
    }

    @GetMapping("/ip")
    public String getContainerIpAddress() {
        try {
            // 모든 네트워크 인터페이스를 순회하며 IP 주소를 확인
            Enumeration<NetworkInterface> interfaces = NetworkInterface.getNetworkInterfaces();
            while (interfaces.hasMoreElements()) {
                NetworkInterface networkInterface = interfaces.nextElement();
                Enumeration<InetAddress> addresses = networkInterface.getInetAddresses();
                while (addresses.hasMoreElements()) {
                    InetAddress inetAddress = addresses.nextElement();
                    // 루프백 주소 제외
                    if (!inetAddress.isLoopbackAddress() && inetAddress.isSiteLocalAddress()) {
                        return "Container IP Address: " + inetAddress.getHostAddress();
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            return "Unable to determine IP address.";
        }
        return "IP address not found.";
    }
}