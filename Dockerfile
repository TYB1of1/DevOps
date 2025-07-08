FROM jenkins/agent:latest

USER root

# Install prerequisites with clean up
RUN apt-get update && \
    apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    sudo \
    && rm -rf /var/lib/apt/lists/*

# Install Docker CLI (including docker-compose-plugin)
RUN mkdir -p /etc/apt/keyrings && \
    curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg && \
    chmod a+r /etc/apt/keyrings/docker.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | \
    tee /etc/apt/sources.list.d/docker.list > /dev/null && \
    apt-get update && \
    apt-get install -y docker-ce-cli docker-compose-plugin && \
    rm -rf /var/lib/apt/lists/*

# Dynamic Docker group setup (matches host's docker group)
ARG DOCKER_GID=999
RUN groupadd -g ${DOCKER_GID} docker && \
    usermod -aG docker jenkins

# Install additional tools
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y nodejs python3 python3-pip git && \
    rm -rf /var/lib/apt/lists/*

# Ensure proper permissions on docker.sock (will be mounted from host)
RUN mkdir -p /var/run && \
    touch /var/run/docker.sock && \
    chown jenkins:docker /var/run/docker.sock

USER jenkins

# Verify Docker access
HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 \
    CMD docker ps > /dev/null || exit 1
