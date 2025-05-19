# Start from official Jenkins image
FROM jenkins/jenkins:lts

# Switch to root user to install packages
USER root

# Install Docker CLI inside Jenkins container
RUN apt-get update && \
    apt-get install -y docker.io && \
    apt-get clean

# Switch back to Jenkins user
USER jenkins
