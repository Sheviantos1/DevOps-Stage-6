# Build stage
FROM maven:3.8-openjdk-17 as build
WORKDIR /app
COPY pom.xml .
COPY src ./src
RUN mvn clean package -DskipTests

# Run stage - Use standard OpenJDK that definitely exists
FROM openjdk:17
WORKDIR /app
COPY --from=build /app/target/*.jar app.jar
EXPOSE 8083
CMD ["java", "-jar", "app.jar"]