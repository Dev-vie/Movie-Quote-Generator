# Eureka Server Dockerfile
# Stage 1: Build
FROM amazoncorretto:17-alpine AS builder
WORKDIR /app

# Copy maven executable and pom.xml
COPY mvnw pom.xml ./
COPY .mvn .mvn

# Download dependencies
RUN chmod +x mvnw && ./mvnw dependency:go-offline -B

# Copy source code and build
COPY src ./src
RUN ./mvnw clean package -DskipTests

# Stage 2: Runtime
FROM amazoncorretto:17-alpine
WORKDIR /app

# Install curl for healthcheck
RUN apk add --no-cache curl

# Copy JAR from builder
COPY --from=builder /app/target/eureka-server-*.jar app.jar

# Expose port
EXPOSE 8761

# Run the application
ENTRYPOINT ["java", "-jar", "app.jar"]
