# Build stage
FROM maven:3.9.6-eclipse-temurin-21 AS build
WORKDIR /app
COPY . .
RUN ls -l /app && ls -l /app/.mvn/wrapper/
RUN echo "MAVEN_CONFIG=$MAVEN_CONFIG"
RUN ls -l /root && file /root/.m2 || echo "/root/.m2 does not exist"
RUN ./mvnw -version
RUN echo "MAVEN_CONFIG=$MAVEN_CONFIG" && echo "MAVEN_OPTS=$MAVEN_OPTS" && cat .mvn/maven.config || echo "no .mvn/maven.config"
RUN MAVEN_CONFIG="" ./mvnw --no-transfer-progress package -DskipTests

# Run stage
FROM eclipse-temurin:21-jre-alpine
WORKDIR /app
COPY --from=build /app/target/*-runner.jar app.jar
EXPOSE 8080
CMD ["java", "-jar", "app.jar"] 