FROM jenkins/agent:latest

USER root

# Install prerequisites
RUN apt-get update && \
    apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    sudo \
    && rm -rf /var/lib/apt/lists/*

# Install Docker CLI
RUN mkdir -p /etc/apt/keyrings && \
    curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg && \
    chmod a+r /etc/apt/keyrings/docker.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | \
    tee /etc/apt/sources.list.d/docker.list > /dev/null && \
    apt-get update && \
    apt-get install -y docker-ce-cli docker-ce docker-compose-plugin && \
    rm -rf /var/lib/apt/lists/*

# Install additional tools
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y nodejs python3 python3-pip git && \
    rm -rf /var/lib/apt/lists/*

# Configure Docker
RUN groupadd -g 999 docker && \
    usermod -aG docker jenkins && \
    mkdir -p /home/jenkins/.docker && \
    chown jenkins:jenkins /home/jenkins/.docker

USER jenkins
