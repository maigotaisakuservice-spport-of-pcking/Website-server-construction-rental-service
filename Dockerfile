# Step 1: Base Image and Desktop Environment
FROM public.ecr.aws/ubuntu/ubuntu:20.04

# Avoid interactive prompts during installation
ENV DEBIAN_FRONTEND=noninteractive

# Install basic utilities, XFCE desktop, and VNC server
RUN apt-get update && apt-get install -y --no-install-recommends \
    sudo \
    wget \
    xfce4 \
    xfce4-goodies \
    tightvncserver \
    websockify \
    novnc \
    # Browsers
    firefox \
    # Cleanup
    && rm -rf /var/lib/apt/lists/*

# Install Google Chrome
RUN apt-get update && \
    wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb && \
    apt-get install -y --no-install-recommends ./google-chrome-stable_current_amd64.deb && \
    rm google-chrome-stable_current_amd64.deb && \
    rm -rf /var/lib/apt/lists/*

# Install VS Code
RUN apt-get update && apt-get install -y --no-install-recommends \
    apt-transport-https \
    gpg && \
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg && \
    install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/ && \
    sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list' && \
    rm -f packages.microsoft.gpg && \
    apt-get update && \
    apt-get install -y code && \
    rm -rf /var/lib/apt/lists/*

# Install PyCharm Community Edition (from tar.gz)
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    libfuse2 && \
    curl -L "https://download.jetbrains.com/product?code=PC&latest&distribution=linux" --output pycharm.tar.gz && \
    tar -xzf pycharm.tar.gz -C /opt/ && \
    rm pycharm.tar.gz && \
    ln -s /opt/pycharm-*/bin/pycharm.sh /usr/local/bin/pycharm && \
    rm -rf /var/lib/apt/lists/*

# Install Postman (from tar.gz)
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl && \
    curl -L "https://dl.pstmn.io/download/latest/linux64" --output postman.tar.gz && \
    tar -xzf postman.tar.gz -C /opt/ && \
    rm postman.tar.gz && \
    ln -s /opt/Postman/Postman /usr/local/bin/postman && \
    rm -rf /var/lib/apt/lists/*

# Install Creative Tools (Kdenlive for video editing, Flameshot for screenshots)
RUN apt-get update && apt-get install -y --no-install-recommends \
    kdenlive \
    flameshot \
    # Cleanup
    && rm -rf /var/lib/apt/lists/*

# --- VNC and User Setup ---

# Create a non-root user 'dev' with password 'dev' and grant passwordless sudo
RUN useradd -m -s /bin/bash -p $(openssl passwd -1 dev) dev && \
    adduser dev sudo && \
    echo "dev ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/90-dev-nopasswd && \
    chmod 0440 /etc/sudoers.d/90-dev-nopasswd

# Switch to the new user
USER dev
WORKDIR /home/dev

# Setup VNC server for the 'dev' user
RUN mkdir /home/dev/.vnc && \
    echo '#!/bin/bash\nxrdb $HOME/.Xresources\nstartxfce4 &' > /home/dev/.vnc/xstartup && \
    chmod +x /home/dev/.vnc/xstartup && \
    # Set VNC password to 'password'
    (echo "password" | vncpasswd -f > /home/dev/.vnc/passwd) && \
    chmod 600 /home/dev/.vnc/passwd

# --- Entrypoint Script ---

# Create a startup script
COPY --chown=dev:dev entrypoint.sh /home/dev/entrypoint.sh
RUN sudo chmod +x /home/dev/entrypoint.sh

# Expose VNC and NoVNC ports
EXPOSE 5901 6901

# Set the entrypoint
ENTRYPOINT ["/home/dev/entrypoint.sh"]
