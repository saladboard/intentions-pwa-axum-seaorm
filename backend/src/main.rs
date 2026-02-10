use axum::{routing::get, Router};
use std::net::SocketAddr;

async fn health() -> &'static str {
    "ok"
}

#[tokio::main]
async fn main() {
    tracing_subscriber::fmt::init();

    let app = Router::new().route("/health", get(health));

    // Use env var so Docker can bind 0.0.0.0
    let addr: SocketAddr = std::env::var("APP_ADDR")
        .unwrap_or_else(|_| "0.0.0.0:3000".to_string())
        .parse()
        .expect("APP_ADDR must be a valid SocketAddr");

    let listener = tokio::net::TcpListener::bind(addr).await.unwrap();
    tracing::info!("listening on http://{}", addr);

    axum::serve(listener, app).await.unwrap();
}
