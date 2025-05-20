
FROM jenkins/jenkins:lts

# Switch to root user to install packages
USER root

# Install prerequisites for adding Docker repo, Node.js, and other utilities
RUN apt-get update && apt-get install -y --no-install-recommends \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    sudo && \
    rm -rf /var/lib/apt/lists/*

# Add Docker's official GPG key
RUN mkdir -p /etc/apt/keyrings && \
    curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg && \
    chmod a+r /etc/apt/keyrings/docker.gpg

# Set up the Docker stable repository
RUN echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker CLI
RUN apt-get update && \
    apt-get install -y --no-install-recommends docker-ce-cli && \
    rm -rf /var/lib/apt/lists/*

# Install Node.js and npm (e.g., LTS version, currently Node 18.x)
RUN curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - && \
    apt-get install -y nodejs && \
    rm -rf /var/lib/apt/lists/*

# Verify installations
RUN docker --version
RUN node --version
RUN npm --version

# (Optional but good practice) Create a docker group and add jenkins user to it
# This GID might need to match the host's docker group GID for socket permissions
# RUN groupadd -g 999 docker || true # 999 is an example GID, check your host
# RUN usermod -aG docker jenkins

# Switch back to the jenkins user
USER jenkins
