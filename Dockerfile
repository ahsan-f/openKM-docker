# Dockerfile for OpenKM Document Management System

# Stage 1: Base Image
FROM openkm/openkm-ce:latest

# Define environment variables for the application and database driver
# These variables help define the version of the PostgreSQL JDBC driver to fetch.
ENV POSTGRES_VERSION=42.7.3

# Stage 2: Install Database Driver and Clean Up (Combined for efficiency)
# Install wget, download the PostgreSQL JDBC driver, and clean up unnecessary packages.
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

# Stage 4: Set Document Repository Permissions (FIX APPLIED)
# The chown command is fixed by using numerical UID:GID 1000:1000, 
# which is a common convention for the primary application user (Tomcat/OpenKM).
# This resolves the "exit code: 1" error from the previous build.
RUN chown -R 1000:1000 /opt/tomcat/repository

# Stage 5: Healthcheck and Startup

# OpenKM application runs on port 8080 (default Tomcat)
EXPOSE 8080

# The base image already has the CMD to start Tomcat.
