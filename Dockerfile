# Use the official Ubuntu image as the base image
FROM ubuntu:latest

# Set environment variables for non-interactive installation
ENV DEBIAN_FRONTEND=noninteractive

# Update the package list and install required packages
RUN apt-get update && \
    apt-get install -y sudo curl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Create a new user with sudo privileges for testing
RUN useradd -m -s /bin/bash testuser && \
    echo 'testuser ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# Set the working directory
WORKDIR /opt/test

# Copy the entire directory structure to the container
COPY . .

# Ensure scripts have the correct permissions
RUN chmod +x bin/*.sh

# Switch to the new user
USER testuser
WORKDIR /opt/test/bin

# Run the install script
CMD ["./install.sh"]
