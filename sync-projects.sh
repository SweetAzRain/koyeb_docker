#!/bin/bash
# sync-projects.sh

# Установка SSH-ключа
if [ -n "$SSH_PRIVATE_KEY" ]; then
    mkdir -p /root/.ssh
    echo "$SSH_PRIVATE_KEY" > /root/.ssh/id_ed25519
    chmod 600 /root/.ssh/id_ed25519
    ssh-keyscan github.com >> /root/.ssh/known_hosts
    chmod 600 /root/.ssh/known_hosts
fi

# Синхронизация проектов
if [ -d "/app/projects/.git" ]; then
    cd /app/projects
    git pull origin main
else
    git clone git@github.com:SweetAzRain/rust-projects.git /app/projects
fi

# Копирование артефактов (если есть)
if [ -d "/app/projects/artifacts" ]; then
    cp -r /app/projects/artifacts/* /app/projects/*/target/release/ 2>/dev/null
fi

# Синхронизация настроек code-server
if [ -d "/root/.local/share/code-server/.git" ]; then
    cd /root/.local/share/code-server
    git pull origin main
else
    mkdir -p /root/.local/share
    git clone git@github.com:SweetAzRain/code-server-config.git /root/.local/share/code-server
fi

# Установка владельца для настроек
chown -R root:root /root/.local/share/code-server

# Запуск code-server
exec /app/code-server/bin/code-server --bind-addr 0.0.0.0:8080 --auth none /app/projects
