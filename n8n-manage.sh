#!/bin/bash

# n8n Management Script
# Facilita o gerenciamento do n8n via Ansible

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INVENTORY="$SCRIPT_DIR/ansible/inventory.yml"

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

function check_connectivity() {
    print_header "Testando Conectividade"
    if ansible -i "$INVENTORY" all -m ping > /dev/null 2>&1; then
        print_success "Conectividade OK"
        return 0
    else
        print_error "Falha na conectividade"
        return 1
    fi
}

function deploy_n8n() {
    print_header "Deploying n8n"
    ansible-playbook -i "$INVENTORY" "$SCRIPT_DIR/ansible/playbook-deploy-n8n.yml"
    print_success "Deploy concluído!"
}

function provision_workflows() {
    print_header "Provisionando Workflows"
    # 1. Copiar arquivos
    ansible-playbook -i "$INVENTORY" "$SCRIPT_DIR/ansible/playbook-copy-workflows.yml"
    
    # 2. Importar via CLI
    print_header "Importando Workflows no n8n"
    ssh -i ~/key_client/keybinario fabioleal@10.30.0.50 "cd /home/fabioleal/n8n && \
        for f in workflows/*.json; do \
            filename=\$(basename \$f); \
            echo \"Importing \$filename...\"; \
            docker-compose exec -T n8n n8n import:workflow --input=/home/node/workflows/\$filename; \
        done"
    
    print_success "Workflows provisionados e importados com sucesso!"
}

function show_logs() {
    print_header "Logs do n8n"
    ssh -i ~/key_client/keybinario fabioleal@10.30.0.50 "docker logs -f --tail=100 n8n"
}

function show_status() {
    print_header "Status dos Containers"
    ssh -i ~/key_client/keybinario fabioleal@10.30.0.50 "docker ps -a | grep -E 'n8n|postgres'"
}

function restart_n8n() {
    print_header "Reiniciando n8n"
    ssh -i ~/key_client/keybinario fabioleal@10.30.0.50 "cd /home/fabioleal/n8n && docker-compose restart n8n"
    print_success "n8n reiniciado!"
}

function stop_n8n() {
    print_header "Parando n8n"
    ssh -i ~/key_client/keybinario fabioleal@10.30.0.50 "cd /home/fabioleal/n8n && docker-compose down"
    print_success "n8n parado!"
}

function start_n8n() {
    print_header "Iniciando n8n"
    ssh -i ~/key_client/keybinario fabioleal@10.30.0.50 "cd /home/fabioleal/n8n && docker-compose up -d"
    print_success "n8n iniciado!"
}

function show_help() {
    cat << EOF
n8n Management Script

Uso: $0 [comando]

Comandos disponíveis:
    ping              Testa conectividade com o servidor
    deploy            Faz deploy completo do n8n
    workflows         Provisiona workflows
    logs              Mostra logs do n8n (Ctrl+C para sair)
    status            Mostra status dos containers
    restart           Reinicia o n8n
    stop              Para o n8n
    start             Inicia o n8n
    help              Mostra esta ajuda

Exemplos:
    $0 ping           # Testa conectividade
    $0 deploy         # Deploy completo
    $0 workflows      # Importa workflows
    $0 logs           # Ver logs em tempo real

EOF
}

# Main
case "${1:-help}" in
    ping)
        check_connectivity
        ;;
    deploy)
        check_connectivity && deploy_n8n
        ;;
    workflows)
        provision_workflows
        ;;
    logs)
        show_logs
        ;;
    status)
        show_status
        ;;
    restart)
        restart_n8n
        ;;
    stop)
        stop_n8n
        ;;
    start)
        start_n8n
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
