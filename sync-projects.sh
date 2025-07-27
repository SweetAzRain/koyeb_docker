#!/bin/bash
# sync-projects.sh

# Установка SSH-ключа
if [ -n "$SSH_PRIVATE_KEY" ]; then
    mkdir -p /root/.ssh
    echo "$SSH_PRIVATE_KEY" > /root/.ssh/id_ed25519
    chmod 600 /root/.ssh/id_ed25519
fi

# Синхронизация проектов
if [ -d "/app/projects/.git" ]; then
    cd /app/projects
    git pull origin main
else
    git clone git@github.com:SweetAzRain/rust-projects.git /app/projects
fi

# Копирование артефактов
if [ -d "/app/projects/artifacts" ]; then
    cp -r /app/projects/artifacts/* /app/projects/*/target/release/
fi

# Синхронизация настроек code-server
if [ -d "/root/.config/code-server/.git" ]; then
    cd /root/.config/code-server
    git pull origin main
else
    mkdir -p /root/.config
    git clone git@github.com:SweetAzRain/code-server-config.git /root/.config/code-server
fi

# Запуск code-server
exec /app/code-server/bin/code-server --bind-addr 0.0.0.0:8080 --auth none /app/projects
