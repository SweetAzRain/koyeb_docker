# Этап сборки: установка Rust и зависимостей
FROM rust:latest AS builder
WORKDIR /app
RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    && rm -rf /var/lib/apt/lists/*
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get install -y nodejs \
    && npm install -g yarn

# Установка code-server (веб-версия VS Code)
RUN curl -fsSL https://code-server.dev/install.sh | sh

# Финальный этап: минимальная среда для выполнения
FROM rust:latest
WORKDIR /app
COPY --from=builder /usr/local/bin/code-server /usr/local/bin/code-server
COPY --from=builder /usr/local/cargo /usr/local/cargo
COPY --from=builder /usr/local/rustup /usr/local/rustup
ENV PATH="/usr/local/cargo/bin:$PATH"
RUN apt-get update && apt-get install -y \
    libssl-dev \
    pkg-config \
    && rm -rf /var/lib/apt/lists/*

# Открываем порт для code-server
EXPOSE 8080

# Команда для запуска code-server
CMD ["code-server", "--bind-addr", "0.0.0.0:8080", "--auth", "none", "/app"]
