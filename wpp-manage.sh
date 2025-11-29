#!/bin/bash

# Script para gerenciar o WPP Polling Forwarder
# Uso: ./wpp-manage.sh [generate-token|deploy|restart|logs|status]

set -e

WPP_HOST="${WPP_HOST:-10.30.0.50}"
WPP_PORT="${WPP_PORT:-21465}"
SESSION="${WPP_SESSION:-nova1}"
SECRET_KEY="${WPP_SECRET_KEY:-THISISMYSECURETOKEN}"

function generate_token() {
    echo "🔑 Generating new token for session: $SESSION"
    
    RESPONSE=$(curl -s -X POST \
        "http://${WPP_HOST}:${WPP_PORT}/api/${SESSION}/${SECRET_KEY}/generate-token" \
        -H 'accept: */*' \
        -d '')
    
    TOKEN=$(echo "$RESPONSE" | grep -o '"token":"[^"]*"' | cut -d'"' -f4)
    
    if [ -z "$TOKEN" ]; then
        echo "❌ Failed to generate token"
        echo "Response: $RESPONSE"
        exit 1
    fi
    
    echo "✅ Token generated successfully!"
    echo ""
    echo "Token: $TOKEN"
    echo ""
    echo "To use this token, create a .env file with:"
    echo "WPP_TOKEN=$TOKEN"
    echo ""
    echo "Or export it:"
    echo "export WPP_TOKEN='$TOKEN'"
}

function deploy() {
    echo "🚀 Deploying WPP Polling Forwarder..."
    
    if [ ! -f .env ]; then
        echo "⚠️  .env file not found. Creating from .env.example..."
        cp .env.example .env
        echo "❗ Please edit .env file and set WPP_TOKEN before deploying"
        exit 1
    fi
    
    # Load .env
    export $(cat .env | xargs)
    
    if [ -z "$WPP_TOKEN" ]; then
        echo "❌ WPP_TOKEN not set in .env file"
        echo "Run: ./wpp-manage.sh generate-token"
        exit 1
    fi
    
    echo "📦 Building and starting container..."
    docker-compose up -d --build wpp-polling-forwarder
    
    echo "✅ Deployment complete!"
    echo ""
    echo "Check logs with: ./wpp-manage.sh logs"
}

function restart() {
    echo "🔄 Restarting WPP Polling Forwarder..."
    docker-compose restart wpp-polling-forwarder
    echo "✅ Restarted!"
}

function logs() {
    echo "📋 Showing logs (Ctrl+C to exit)..."
    docker-compose logs -f wpp-polling-forwarder
}

function status() {
    echo "📊 Container Status:"
    docker-compose ps wpp-polling-forwarder
    echo ""
    echo "📋 Recent logs:"
    docker-compose logs --tail=20 wpp-polling-forwarder
}

function usage() {
    echo "Usage: $0 [command]"
    echo ""
    echo "Commands:"
    echo "  generate-token  - Generate a new WPPConnect token"
    echo "  deploy          - Deploy the forwarder (builds and starts)"
    echo "  restart         - Restart the forwarder container"
    echo "  logs            - Show live logs"
    echo "  status          - Show container status and recent logs"
    echo ""
    echo "Environment variables:"
    echo "  WPP_HOST        - WPPConnect host (default: 10.30.0.50)"
    echo "  WPP_PORT        - WPPConnect port (default: 21465)"
    echo "  WPP_SESSION     - Session name (default: nova1)"
    echo "  WPP_SECRET_KEY  - Secret key for token generation (default: THISISMYSECURETOKEN)"
}

case "${1:-}" in
    generate-token)
        generate_token
        ;;
    deploy)
        deploy
        ;;
    restart)
        restart
        ;;
    logs)
        logs
        ;;
    status)
        status
        ;;
    *)
        usage
        exit 1
        ;;
esac
