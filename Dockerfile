# Этап сборки: установка code-server и Rust
FROM codercom/code-server:latest AS builder
WORKDIR /app
RUN sudo apt-get update && sudo apt-get install -y \
    curl \
    build-essential \
    && sudo rm -rf /var/lib/apt/lists/*

# Установка Rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="/root/.cargo/bin:$PATH"

# Финальный этап: минимальная среда для выполнения
FROM codercom/code-server:latest
WORKDIR /app
COPY --from=builder /root/.cargo /root/.cargo
COPY --from=builder /root/.rustup /root/.rustup
ENV PATH="/root/.cargo/bin:$PATH"
RUN sudo apt-get update && sudo apt-get install -y \
    libssl-dev \
    pkg-config \
    && sudo rm -rf /var/lib/apt/lists/*

# Открываем порт для code-server
EXPOSE 8080

# Команда для запуска code-server
CMD ["code-server", "--bind-addr", "0.0.0.0:8080", "--auth", "none", "/app"]
