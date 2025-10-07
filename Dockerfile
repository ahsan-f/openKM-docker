# Dockerfile for OpenKM Document Management System

# Stage 1: Base Image
FROM openkm/openkm-ce:latest

# Define environment variables for the application and database driver
ENV POSTGRES_VERSION=42.7.3

# Stage 2: Install Database Driver and Clean Up
RUN apt-get update && \
    apt-get install -y wget && \
    wget -P /opt/tomcat/lib/ \
    "https://jdbc.postgresql.org/download/postgresql-${POSTGRES_VERSION}.jar" && \
    apt-get purge -y wget && \
    rm -rf /var/lib/apt/lists/*

# Stage 3: Configuration Overrides
# Create the config directory and copy the database configuration files.
RUN mkdir -p /opt/tomcat/config

# Copy custom configuration files into the container.
COPY config/OpenKM.cfg /opt/tomcat/OpenKM.cfg
COPY config/server.xml /opt/tomcat/conf/server.xml

# Stage 4: Set Document Repository Permissions (FIX: REMOVED BUILD-TIME CHOWN)
# Removed the problematic RUN chown command. 
# Permissions will be managed at runtime via Docker Compose or Kubernetes, 
# ensuring the volume mount is writable by the running user.
# The repository directory is still present for mounting.

# Stage 5: Healthcheck and Startup

# OpenKM application runs on port 8080 (default Tomcat)
EXPOSE 8080
