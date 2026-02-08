FROM mcr.microsoft.com/devcontainers/base:ubuntu

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    build-essential \
    python3.12 \
    python3-pip \
    nodejs \
    npm \
    && rm -rf /var/lib/apt/lists/*

# Install Python packages
RUN pip3 install --no-cache-dir \
    openai \
    anthropic \
    langchain \
    langchain-openai \
    langchain-anthropic \
    requests \
    python-dotenv

# Install Node packages globally
RUN npm install -g npm@latest

# Set working directory
WORKDIR /workspace

# Default command
CMD ["bash"]
