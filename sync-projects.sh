#!/bin/bash
# sync-projects.sh

# Установка SSH-ключа
if [ -n "$SSH_PRIVATE_KEY" ]; then
    mkdir -p /root/.ssh
    echo "$SSH_PRIVATE_KEY" > /root/.ssh/id_ed25519
    chmod 600 /root/.ssh/id_ed25519
    ssh-keyscan github.com >> /root/.ssh/known_hosts
    chmod 600 /root/.ssh/known_hosts
    echo "SSH key configured"
else
    echo "SSH_PRIVATE_KEY not set"
fi

# Синхронизация проектов
if [ -d "/app/projects/.git" ]; then
    cd /app/projects
    git pull origin main || echo "Failed to pull rust-projects"
else
    git clone git@github.com:SweetAzRain/rust-projects.git /app/projects || echo "Failed to clone rust-projects"
fi

# Копирование артефактов
if [ -d "/app/projects/artifacts" ]; then
    cp -r /app/projects/artifacts/* /app/projects/*/target/release/ 2>/dev/null || echo "Failed to copy artifacts"
fi

# Синхронизация настроек code-server
if [ -d "/root/.local/share/code-server/.git" ]; then
    cd /root/.local/share/code-server
    git pull origin main || echo "Failed to pull code-server-config"
else
    mkdir -p /root/.local/share
    git clone git@github.com:SweetAzRain/code-server-config.git /root/.local/share/code-server || echo "Failed to clone code-server-config"
fi

# Установка владельца
if [ -d "/root/.local/share/code-server" ]; then
    chown -R root:root /root/.local/share/code-server
    echo "Chown completed"
else
    echo "code-server directory not found"
fi

# Запуск code-server
exec /app/code-server/bin/code-server --bind-addr 0.0.0.0:8080 --auth none /app/projects
