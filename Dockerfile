# Dockerfile for OpenKM Document Management System

# Stage 1: Base Image
FROM openkm/openkm-ce:latest

# Define environment variables for the application and database driver
# These values are used inside the OpenKM.cfg and server.xml during configuration.
ENV POSTGRES_VERSION=42.7.3

# Stage 2: Install Database Driver
# Install wget to download the driver, download the PostgreSQL JDBC driver, and clean up.
RUN apt-get update && apt-get install -y wget && \
    wget -P /opt/tomcat/lib/ \
    "https://jdbc.postgresql.org/download/postgresql-${POSTGRES_VERSION}.jar" && \
    apt-get purge -y wget && \
    rm -rf /var/lib/apt/lists/*

# Stage 3: Configuration Overrides
# Create the config directory and copy the database configuration files.
# The 'config' directory must exist in the build context (same folder as Dockerfile).
RUN mkdir -p /opt/tomcat/config

# Copy custom configuration files into the container.
# These files set the database connection and hibernate dialect.
COPY config/OpenKM.cfg /opt/tomcat/OpenKM.cfg
COPY config/server.xml /opt/tomcat/conf/server.xml

# Stage 4: Set Permissions (Best Practice)
# Ensure the Tomcat user has correct ownership of the repository directory 
# which will be used for volume mounting the binary document files.
RUN chown -R tomcat:tomcat /opt/tomcat/repository

# OpenKM application runs on port 8080 (default Tomcat)
EXPOSE 8080

# The base image already has the CMD to start Tomcat.
