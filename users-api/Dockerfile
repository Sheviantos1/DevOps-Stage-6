FROM maven:3.8-openjdk-11
WORKDIR /app
COPY pom.xml .
COPY src ./src
RUN mvn clean package -DskipTests
EXPOSE 8083
CMD ["java", "-jar", "target/*.jar"]