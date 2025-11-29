#!/bin/bash

# WAHA Management Script
# Facilita o gerenciamento do WAHA (WhatsApp HTTP API)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WAHA_URL="${WAHA_URL:-http://localhost:3000}"
SESSION_NAME="${SESSION_NAME:-default}"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

function print_header() {
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}"
}

function print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

function print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

function print_error() {
    echo -e "${RED}✗ $1${NC}"
}

function check_health() {
    print_header "Verificando Saúde do WAHA"
    if curl -s "$WAHA_URL/health" > /dev/null 2>&1; then
        print_success "WAHA está rodando"
        return 0
    else
        print_error "WAHA não está acessível"
        return 1
    fi
}

function list_sessions() {
    print_header "Sessões Ativas"
    curl -s "$WAHA_URL/api/sessions" | jq '.' || echo "Erro ao listar sessões"
}

function session_status() {
    print_header "Status da Sessão: $SESSION_NAME"
    curl -s "$WAHA_URL/api/sessions/$SESSION_NAME" | jq '.' || echo "Sessão não encontrada"
}

function start_session() {
    print_header "Iniciando Sessão: $SESSION_NAME"
    
    local webhook_url="${1:-http://n8n:5678/webhook/whatsapp-agent}"
    
    curl -X POST "$WAHA_URL/api/sessions/start" \
        -H "Content-Type: application/json" \
        -d "{
            \"name\": \"$SESSION_NAME\",
            \"config\": {
                \"webhooks\": [
                    {
                        \"url\": \"$webhook_url\",
                        \"events\": [\"message\"]
                    }
                ]
            }
        }" | jq '.'
    
    print_success "Sessão iniciada! Use 'waha-manage.sh qr' para ver o QR code"
}

function stop_session() {
    print_header "Parando Sessão: $SESSION_NAME"
    curl -X POST "$WAHA_URL/api/sessions/$SESSION_NAME/stop" | jq '.'
    print_success "Sessão parada"
}

function restart_session() {
    print_header "Reiniciando Sessão: $SESSION_NAME"
    curl -X POST "$WAHA_URL/api/sessions/$SESSION_NAME/restart" | jq '.'
    print_success "Sessão reiniciada"
}

function get_qr() {
    print_header "QR Code da Sessão: $SESSION_NAME"
    
    local qr_data=$(curl -s "$WAHA_URL/api/sessions/$SESSION_NAME/qr")
    
    if echo "$qr_data" | jq -e '.qr' > /dev/null 2>&1; then
        echo "$qr_data" | jq -r '.qr'
        echo ""
        print_success "Escaneie o QR code acima com WhatsApp"
    else
        print_warning "QR code não disponível. Possíveis razões:"
        echo "  - Sessão já está conectada"
        echo "  - Sessão ainda não foi iniciada"
        echo "  - QR code expirou"
        echo ""
        echo "Resposta do servidor:"
        echo "$qr_data" | jq '.'
    fi
}

function send_test() {
    local phone="$1"
    local message="${2:-Teste de mensagem do WAHA}"
    
    if [ -z "$phone" ]; then
        print_error "Uso: waha-manage.sh send <número> [mensagem]"
        echo "Exemplo: waha-manage.sh send 5511999999999 'Olá!'"
        return 1
    fi
    
    print_header "Enviando Mensagem de Teste"
    
    curl -X POST "$WAHA_URL/api/sendText" \
        -H "Content-Type: application/json" \
        -d "{
            \"session\": \"$SESSION_NAME\",
            \"chatId\": \"${phone}@c.us\",
            \"text\": \"$message\"
        }" | jq '.'
    
    print_success "Mensagem enviada!"
}

function open_swagger() {
    print_header "Abrindo Swagger UI"
    
    if command -v xdg-open > /dev/null; then
        xdg-open "$WAHA_URL"
    elif command -v open > /dev/null; then
        open "$WAHA_URL"
    else
        echo "Acesse manualmente: $WAHA_URL"
    fi
}

function show_logs() {
    print_header "Logs do WAHA"
    docker logs -f waha
}

function show_help() {
    cat <<EOF
WAHA Management Script

Uso: $0 [comando] [argumentos]

Comandos disponíveis:
    health            Verifica saúde do WAHA
    sessions          Lista todas as sessões
    status            Status da sessão atual
    start [webhook]   Inicia sessão (webhook opcional)
    stop              Para sessão
    restart           Reinicia sessão
    qr                Mostra QR code para conectar
    send <phone> [msg] Envia mensagem de teste
    swagger           Abre interface Swagger
    logs              Mostra logs do container
    help              Mostra esta ajuda

Variáveis de ambiente:
    WAHA_URL          URL do WAHA (padrão: http://localhost:3000)
    SESSION_NAME      Nome da sessão (padrão: default)

Exemplos:
    $0 health                           # Verifica se WAHA está rodando
    $0 start                            # Inicia sessão com webhook padrão
    $0 start http://n8n:5678/webhook   # Inicia com webhook customizado
    $0 qr                               # Mostra QR code
    $0 send 5511999999999 "Olá!"       # Envia mensagem de teste
    $0 status                           # Ver status da sessão

    # Usando sessão customizada
    SESSION_NAME=mysession $0 status

    # Usando WAHA remoto
    WAHA_URL=http://10.30.0.50:3000 $0 sessions

EOF
}

# Main
case "${1:-help}" in
    health)
        check_health
        ;;
    sessions)
        list_sessions
        ;;
    status)
        session_status
        ;;
    start)
        start_session "$2"
        ;;
    stop)
        stop_session
        ;;
    restart)
        restart_session
        ;;
    qr)
        get_qr
        ;;
    send)
        send_test "$2" "$3"
        ;;
    swagger)
        open_swagger
        ;;
    logs)
        show_logs
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        print_error "Comando desconhecido: $1"
        echo ""
        show_help
        exit 1
        ;;
esac
