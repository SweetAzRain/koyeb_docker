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

# Проверка, что Rust и Cargo доступны
RUN cargo --version && rustc --version

# Финальный образ
FROM rust:slim-bookworm AS runner

WORKDIR /app

# Установка runtime-зависимостей и инструментов для компиляции
RUN apt-get update && apt-get install -y \
    curl \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Копирование code-server из этапа builder
COPY --from=builder /app/code-server /app/code-server

# Установка PATH для code-server
ENV PATH="/app/code-server/bin:$PATH"

# Открытие порта для code-server
EXPOSE 8080

# Запуск code-server
CMD ["code-server", "--bind-addr", "0.0.0.0:8080", "--auth", "none", "/app"]
