# Этап сборки: установка Rust и code-server
FROM rust:latest AS builder
WORKDIR /app
RUN apt-get update && apt-get install -y \
    curl \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Установка code-server
RUN curl -fsSL https://github.com/coder/code-server/releases/download/v4.93.1/code-server-4.93.1-linux-amd64.tar.gz \
    | tar -xz -C /app && \
    mv /app/code-server-4.93.1-linux-amd64 /app/code-server

# Проверка путей для отладки
RUN ls -la /root/.cargo /root/.rustup || echo "Cargo or Rustup not found"

# Финальный этап: минимальная среда
FROM rust:latest
WORKDIR /app
COPY --from=builder /app/code-server /app/code-server
COPY --from=builder /root/.cargo /root/.cargo
COPY --from=builder /root/.rustup /root/.rustup
ENV PATH="/app/code-server/bin:/root/.cargo/bin:$PATH"
RUN apt-get update && apt-get install -y \
    libssl-dev \
    pkg-config \
    && rm -rf /var/lib/apt/lists/*

# Открываем порт для code-server
EXPOSE 8080

# Команда для запуска code-server
CMD ["/app/code-server/bin/code-server", "--bind-addr", "0.0.0.0:8080", "--auth", "none", "/app"]
