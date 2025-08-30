# Stage 1: Build with Maven and Java 21
FROM maven:3.9.6-eclipse-temurin-21 AS build

WORKDIR /app

# Copy only pom.xml first to leverage Docker cache for dependencies
COPY pom.xml .
RUN mvn dependency:go-offline -B

# Now copy the rest of the project
COPY . .

# Build the WAR file, skipping tests for faster builds
RUN mvn clean package -DskipTests

# Stage 2: Run with Tomcat
FROM tomcat:9.0-jdk17-temurin

# Remove default Tomcat apps
RUN rm -rf /usr/local/tomcat/webapps/*

# Copy backend WAR to Tomcat as ROOT.war (deployed at http://localhost:8080/)
COPY --from=build /app/target/*.war /usr/local/tomcat/webapps/ROOT.war

EXPOSE 8080
CMD ["catalina.sh", "run"]
