# --- build ---
FROM eclipse-temurin:17-jdk AS build
WORKDIR /app

# Gradle Wrapper 사용(프로젝트 루트에 gradlew/gradle 폴더 있어야 함)
COPY gradlew gradlew
COPY gradle gradle
RUN chmod +x gradlew

# 의존성 캐시 단계 (build.gradle, settings.gradle만 먼저 복사)
COPY build.gradle settings.gradle ./
RUN ./gradlew dependencies --no-daemon || true

# 소스 복사 후 빌드
COPY . .
RUN chmod +x gradlew
RUN ./gradlew clean bootJar --no-daemon -x test

# --- run ---
FROM eclipse-temurin:17-jre
WORKDIR /app
COPY --from=build /app/build/libs/*-*.jar /app/app.jar

EXPOSE 9090
ENV JAVA_OPTS=""
ENTRYPOINT ["sh","-c","java $JAVA_OPTS -jar /app/app.jar"]
