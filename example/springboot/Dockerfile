FROM gradle:8.1.1-jdk17 AS builder
WORKDIR /build
COPY ./demo/ .
RUN ./gradlew build -x test

FROM openjdk:17 AS app
WORKDIR /app
COPY --from=builder /build/build/libs/demo-0.0.1-SNAPSHOT.jar /app
CMD ["java", "-jar", "demo-0.0.1-SNAPSHOT.jar"]