# Zuul Gateway Dockerfile
# Build locally first: mvn clean package -DskipTests

FROM amazoncorretto:17-alpine
WORKDIR /app

# Install curl for healthcheck
RUN apk add --no-cache curl

# Copy the pre-built JAR file
COPY target/zuul-gateway-*.jar app.jar

# Expose port
EXPOSE 8080

# Run the application
ENTRYPOINT ["java", "-jar", "app.jar"]
