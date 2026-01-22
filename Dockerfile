## (c) 2026
## Ramon Brooker <rbrooker@aeo3.io>
## Dockerfile for Cognitify Fancy Prompt on RHEL-based systems

FROM redhat/ubi8:latest

# Set maintainer
LABEL maintainer="rbrooker@aeo3.io"
LABEL description="Cognitify Fancy Prompt on RHEL-based container"

# Install required packages
RUN dnf install -y bash which ncurses sudo && \
    dnf clean all

# Set working directory
WORKDIR /opt/cognitify

# Copy project files
COPY . /opt/cognitify/

# Install the prompt system-wide
RUN chmod +x /opt/cognitify/bin/install.sh && \
    /opt/cognitify/bin/install.sh --skip-user-files && \
    /opt/cognitify/bin/install.sh --user root --update-skel

# Create a test user to demonstrate the prompt
RUN useradd -m -s /bin/bash testuser && \
    echo "testuser ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/testuser && \
    chmod 440 /etc/sudoers.d/testuser && \
    /opt/cognitify/bin/install.sh --user testuser

# Set default user (can be overridden)
USER root

# Set default command to bash
CMD ["/bin/bash"]
