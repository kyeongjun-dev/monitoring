FROM gradle:8.1.1-jdk17 AS builder
WORKDIR /build
COPY ./demo/ .
RUN ./gradlew build -x test

FROM openjdk:17 AS app
WORKDIR /app
COPY --from=builder /build/build/libs/demo.jar /app
COPY opentelemetry-javaagent.jar opentelemetry-javaagent.jar
CMD ["java", "-javaagent:opentelemetry-javaagent.jar", "-jar", "demo.jar"]