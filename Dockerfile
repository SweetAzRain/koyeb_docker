
# Этап сборки
FROM rust:bookworm AS builder

WORKDIR /app

# Установка дополнительных зависимостей
RUN apt-get update && apt-get install -y \
    curl \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Установка code-server
RUN curl -fsSL https://github.com/coder/code-server/releases/download/v4.93.1/code-server-4.93.1-linux-amd64.tar.gz \
    | tar -xz -C /app && \
    mv /app/code-server-4.93.1-linux-amd64 /app/code-server

# Проверка Rust и Cargo
RUN cargo --version && rustc --version

# Финальный образ
FROM debian:bookworm-slim AS runner

WORKDIR /app

# Установка runtime-зависимостей и Rust
RUN apt-get update && apt-get install -y \
    curl \
    build-essential \
    && curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y \
    && rm -rf /var/lib/apt/lists/*

# Установка PATH для Rust и code-server
ENV PATH="/usr/local/cargo/bin:/app/code-server/bin:$PATH"

# Копирование code-server
COPY --from=builder /app/code-server /app/code-server

# Создание директории для проектов
RUN mkdir -p /app/projects

# Открытие порта
EXPOSE 8080

# Запуск code-server
CMD ["code-server", "--bind-addr", "0.0.0.0:8080", "--auth", "none", "/app/projects"]
