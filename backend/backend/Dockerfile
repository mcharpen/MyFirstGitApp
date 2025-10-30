# Build stage
FROM maven:3.9.6-eclipse-temurin-21 AS build
WORKDIR /app
COPY . .
RUN chmod +x mvnw
RUN MAVEN_CONFIG="" ./mvnw --no-transfer-progress package -DskipTests -Dquarkus.package.type=uber-jar
RUN ls -lh /app/target
RUN jar tf /app/target/*-runner.jar | grep create_emp_table.sql || echo "SQL SCRIPT NOT FOUND IN JAR"

# Run stage
FROM eclipse-temurin:21-jre-alpine
WORKDIR /app
COPY --from=build /app/target/*-runner.jar app.jar
EXPOSE 8080
CMD ["java", "-jar", "app.jar"] 