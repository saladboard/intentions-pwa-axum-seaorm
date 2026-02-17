use axum::{routing::get, Router};
use sea_orm::{Database, DatabaseConnection};
use std::net::SocketAddr;
use tracing_subscriber::{layer::SubscriberExt, util::SubscriberInitExt};

#[tokio::main]
async fn main() -> anyhow::Result<()> {
    tracing_subscriber::registry()
        .with(tracing_subscriber::EnvFilter::try_from_default_env().unwrap_or_else(|_| "info".into()))
        .with(tracing_subscriber::fmt::layer())
        .init();

    let db = connect_db().await?;

    let app = Router::new()
        .route("/health", get(health))
        .with_state(AppState { db });

    let addr: SocketAddr = "0.0.0.0:3000".parse().unwrap();
    tracing::info!("listening on http://{addr}");

    axum::serve(tokio::net::TcpListener::bind(addr).await?, app).await?;
    Ok(())
}

#[derive(Clone)]
struct AppState {
    db: DatabaseConnection,
}

async fn connect_db() -> anyhow::Result<DatabaseConnection> {
    let url = std::env::var("DATABASE_URL")?;
    Ok(Database::connect(url).await?)
}

async fn health() -> &'static str {
    "ok"
}
