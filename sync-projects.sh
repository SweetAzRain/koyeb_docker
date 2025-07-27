#!/bin/bash
# sync-projects.sh (HTTPS version)

# Проверка токена
if [ -n "$GITHUB_TOKEN" ]; then
    echo "Using GitHub token"
else
    echo "GITHUB_TOKEN not set"
    exit 1
fi

# Синхронизация проектов
if [ -d "/app/projects/.git" ]; then
    cd /app/projects
    git pull origin main || {
        echo "Failed to pull rust-projects"
        exit 1
    }
else
    rm -rf /app/projects
    mkdir -p /app/projects
    git clone https://$GITHUB_TOKEN@github.com/SweetAzRain/rust-projects.git /app/projects || {
        echo "Failed to clone rust-projects"
        exit 1
    }
fi

# Копирование артефактов
if [ -d "/app/projects/artifacts" ]; then
    cp -r /app/projects/artifacts/* /app/projects/*/target/release/ 2>/dev/null || echo "Failed to copy artifacts"
fi

# Синхронизация настроек code-server
if [ -d "/root/.local/share/code-server/.git" ]; then
    cd /root/.local/share/code-server
    git pull origin main || {
        echo "Failed to pull code-server-config"
        exit 1
    }
else
    rm -rf /root/.local/share/code-server
    mkdir -p /root/.local/share/code-server
    git clone https://$GITHUB_TOKEN@github.com/SweetAzRain/code-server-config.git /root/.local/share/code-server || {
        echo "Failed to clone code-server-config"
        exit 1
    }
fi

# Установка владельца
if [ -d "/root/.local/share/code-server" ]; then
    chown -R root:root /root/.local/share/code-server
    echo "Chown completed for code-server"
else
    echo "code-server directory not found"
    exit 1
fi
if [ -d "/app/projects" ]; then
    chown -R root:root /app/projects
    echo "Chown completed for projects"
else
    echo "projects directory not found"
    exit 1
fi

# Запуск code-server
exec /app/code-server/bin/code-server --bind-addr 0.0.0.0:8080 --auth none /app/projects
