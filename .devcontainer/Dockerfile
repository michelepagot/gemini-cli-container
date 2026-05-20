FROM node:20-bookworm

# Install basic tools and dependencies
RUN apt-get update --allow-releaseinfo-change && apt-get upgrade -y && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends \
    sudo \
    git \
    build-essential \
    python3 \
    python3-pip \
    curl \
    wget \
    ca-certificates \
    gnupg \
    lsb-release \
    zsh \
    locales \
    iptables \
    ipset \
    net-tools \
    dnsutils \
    jq \
    tmux \
    vim \
    nano \
    htop \
    && apt-get autoremove -y && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*

# Install optional packages that may not be available in all mirrors
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends \
    fonts-powerline 2>/dev/null || true
    
# Try to install git-delta if available, but don't fail if not
RUN apt-get -y install --no-install-recommends \
    git-delta 2>/dev/null || echo "git-delta not available, skipping" \
    && apt-get autoremove -y && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*

# Generate locale
RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && locale-gen
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

# Add node user to sudoers for firewall script
RUN echo "node ALL=(ALL) NOPASSWD: /workspace/.devcontainer/init-firewall.sh" >> /etc/sudoers.d/node \
    && chmod 0440 /etc/sudoers.d/node

# Create npm global directory
RUN mkdir -p /home/node/.npm-global \
    && chown -R node:node /home/node/.npm-global

# Install global npm packages as node user
USER node
RUN npm install -g \
    @google/gemini-cli \
    typescript \
    tsx \
    nodemon \
    npm-check-updates \
    && npm cache clean --force

# Set up command history
RUN SNIPPET="export PROMPT_COMMAND='history -a' && export HISTFILE=/commandhistory/.bash_history" \
    && mkdir -p /commandhistory \
    && touch /commandhistory/.bash_history \
    && echo "$SNIPPET" >> "/home/node/.bashrc" \
    && echo "$SNIPPET" >> "/home/node/.zshrc"

# Switch back to root for final setup
USER root

# Create workspace directory
RUN mkdir -p /workspace && chown -R node:node /workspace

# Copy firewall initialization script
COPY .devcontainer/init-firewall.sh /workspace/.devcontainer/init-firewall.sh
RUN chmod +x /workspace/.devcontainer/init-firewall.sh

# Set up entrypoint
COPY .devcontainer/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["sleep", "infinity"]
