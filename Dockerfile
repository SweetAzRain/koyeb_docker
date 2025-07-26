# Этап сборки: установка Rust и code-server
FROM rust:latest AS builder
WORKDIR /app
RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Установка code-server
RUN curl -fsSL https://code-server.dev/install.sh | sh -s -- --prefix=/app/code-server

# Финальный этап: минимальная среда для выполнения
FROM rust:latest
WORKDIR /app
COPY --from=builder /app/code-server /app/code-server
COPY --from=builder /usr/local/cargo /usr/local/cargo
COPY --from=builder /usr/local/rustup /usr/local/rustup
ENV PATH="/app/code-server/bin:/usr/local/cargo/bin:$PATH"
RUN apt-get update && apt-get install -y \
    libssl-dev \
    pkg-config \
    && rm -rf /var/lib/apt/lists/*

# Открываем порт для code-server
EXPOSE 8080

# Команда для запуска code-server
CMD ["/app/code-server/bin/code-server", "--bind-addr", "0.0.0.0:8080", "--auth", "none", "/app"]
