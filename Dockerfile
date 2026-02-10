# ---- base build image ----
FROM rust:1.86-bookworm AS chef
WORKDIR /app
RUN cargo install cargo-chef

# ---- planner ----
FROM chef AS planner
COPY . .
RUN cargo chef prepare --recipe-path recipe.json

# ---- builder (cache deps) ----
FROM chef AS builder
COPY --from=planner /app/recipe.json recipe.json
RUN cargo chef cook --release --recipe-path recipe.json
COPY . .
RUN cargo build --release

# ---- runtime ----
FROM debian:bookworm-slim AS runtime
WORKDIR /app
RUN apt-get update && apt-get install -y ca-certificates && rm -rf /var/lib/apt/lists/*
COPY --from=builder /app/target/release/your_binary_name /app/your_binary_name
EXPOSE 3000
ENV RUST_LOG=info
CMD ["/app/your_binary_name"]

# ---- dev (optional) ----
FROM rust:1.86-bookworm AS dev
WORKDIR /app
RUN cargo install cargo-watch
COPY . .
EXPOSE 3000
ENV RUST_LOG=debug
CMD ["cargo", "watch", "-x", "run"]
