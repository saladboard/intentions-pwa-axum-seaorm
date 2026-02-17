#!/usr/bin/env bash
set -euo pipefail

# devsh — one script to manage your dev docker environment
#
# Usage:
#   ./devsh up
#   ./devsh down
#   ./devsh restart
#   ./devsh logs [service]
#   ./devsh sh [service]
#   ./devsh psql
#   ./devsh clean
#   ./devsh status
#
# Defaults:
#   service = api for sh/logs
#   service = db for psql

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT"

COMPOSE=(docker compose)

usage() {
  cat <<'EOF'
devsh — manage local dev docker env (Axum + SeaORM + Postgres)

Commands:
  up                 Build and start services
  down               Stop services (keeps volumes)
  restart            Restart services
  status             Show container status
  logs [svc]         Follow logs (default: api)
  sh [svc]           Shell into a container (default: api)
  psql               Open psql inside the db container
  clean              DANGER: down -v + remove orphans + optional builder prune
  help               Show this help

Examples:
  ./devsh up
  ./devsh logs
  ./devsh logs db
  ./devsh sh
  ./devsh sh db
  ./devsh psql
  ./devsh clean
EOF
}

need_docker() {
  command -v docker >/dev/null 2>&1 || { echo "docker not found"; exit 1; }
  docker info >/dev/null 2>&1 || { echo "docker daemon not running"; exit 1; }
}

svc_default_api() {
  echo "${1:-api}"
}

cmd_up() {
  need_docker
  "${COMPOSE[@]}" up --build
}

cmd_down() {
  need_docker
  "${COMPOSE[@]}" down
}

cmd_restart() {
  need_docker
  "${COMPOSE[@]}" down
  "${COMPOSE[@]}" up --build
}

cmd_status() {
  need_docker
  "${COMPOSE[@]}" ps
}

cmd_logs() {
  need_docker
  local svc
  svc="$(svc_default_api "${1:-}")"
  "${COMPOSE[@]}" logs -f --tail=200 "$svc"
}

cmd_sh() {
  need_docker
  local svc
  svc="$(svc_default_api "${1:-}")"
  # Use bash if present; fall back to sh
  if "${COMPOSE[@]}" exec -T "$svc" bash -lc 'exit 0' >/dev/null 2>&1; then
    "${COMPOSE[@]}" exec "$svc" bash
  else
    "${COMPOSE[@]}" exec "$svc" sh
  fi
}

cmd_psql() {
  need_docker
  # Since you hardcoded POSTGRES_USER/DB as app/app in compose, use that.
  "${COMPOSE[@]}" exec db psql -U app -d app
}

cmd_clean() {
  need_docker
  echo "DANGER: This will remove containers, networks, and VOLUMES (Postgres data) for this project."
  echo "Type 'clean' to confirm:"
  read -r confirm
  if [[ "$confirm" != "clean" ]]; then
    echo "Aborted."
    exit 1
  fi

  "${COMPOSE[@]}" down -v --remove-orphans

  # Optional: prune dangling builder cache (comment out if you don't want it)
  docker builder prune -f || true

  echo "Clean complete."
}

cmd="${1:-help}"
shift || true

case "$cmd" in
  up)      cmd_up "$@" ;;
  down)    cmd_down "$@" ;;
  restart) cmd_restart "$@" ;;
  status|ps) cmd_status "$@" ;;
  logs)    cmd_logs "$@" ;;
  sh|shell|exec) cmd_sh "$@" ;;
  psql)    cmd_psql "$@" ;;
  clean)   cmd_clean "$@" ;;
  help|-h|--help) usage ;;
  *)
    echo "Unknown command: $cmd"
    echo
    usage
    exit 2
    ;;
esac
