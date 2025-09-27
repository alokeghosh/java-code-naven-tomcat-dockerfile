# ----------------------------------------------------------------------
# STAGE 1: The Builder Stage - Compiles the Java code and creates the WAR file.
# ----------------------------------------------------------------------
FROM maven:3.9.5-eclipse-temurin-17 AS builder

# Set the working directory
WORKDIR /app

# Copy the Maven project file first for better Docker layer caching
COPY pom.xml .

# Download dependencies (if they change less frequently than the code)
# -B: Batch mode, non-interactive
RUN mvn dependency:go-offline -B

# Copy the rest of the source code
COPY src/ ./src/

# Package the application. This creates target/my-tomcat-app.war
RUN mvn package -DskipTests

# ----------------------------------------------------------------------
# STAGE 2: The Final Stage - Deploys the WAR file onto a Tomcat server.
# ----------------------------------------------------------------------
FROM tomcat:10.1-jdk21-temurin

RUN rm -rf /usr/local/tomcat/webapps/ROOT

COPY --from=builder /app/target/my-tomcat-app.war /usr/local/tomcat/webapps/ROOT.war

# Tomcat's default HTTP port
EXPOSE 8080

# The base Tomcat image already has a CMD to start the server (catalina.sh run)