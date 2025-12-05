#!/bin/bash

# Meta API Migration Helper
# Script interativo para guiar a migração

set -e

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# Banner
show_banner() {
    clear
    echo -e "${CYAN}"
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║                                                            ║"
    echo "║     🚀 WhatsApp Meta API - Migration Helper 🚀            ║"
    echo "║                                                            ║"
    echo "║     WAHA → Meta API (Official)                            ║"
    echo "║                                                            ║"
    echo "╚════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo ""
}

# Menu principal
show_menu() {
    echo -e "${BLUE}=== Menu Principal ===${NC}"
    echo ""
    echo "1. 📋 Ver Checklist de Migração"
    echo "2. 🔍 Verificar Pré-requisitos"
    echo "3. 🧪 Testar Webhook"
    echo "4. 📊 Ver Status Atual"
    echo "5. 📚 Abrir Documentação"
    echo "6. ❌ Sair"
    echo ""
    echo -n "Escolha uma opção: "
}

# Checklist
show_checklist() {
    echo -e "${PURPLE}=== Checklist de Migração ===${NC}"
    echo ""
    
    # Verificar .env
    if [ -f .env ]; then
        if grep -q "WHATSAPP_PHONE_NUMBER_ID" .env && \
           grep -q "WHATSAPP_ACCESS_TOKEN" .env; then
            echo -e "✅ ${GREEN}Variáveis de ambiente configuradas${NC}"
        else
            echo -e "❌ ${RED}Variáveis de ambiente faltando${NC}"
            echo -e "   ${YELLOW}Execute: cp .env.example .env e edite${NC}"
        fi
    else
        echo -e "❌ ${RED}Arquivo .env não encontrado${NC}"
        echo -e "   ${YELLOW}Execute: cp .env.example .env${NC}"
    fi
    
    # Verificar workflow
    if [ -f "workflows/whatsapp-ai-agent-meta.json" ]; then
        echo -e "✅ ${GREEN}Workflow Meta API criado${NC}"
    else
        echo -e "❌ ${RED}Workflow Meta API não encontrado${NC}"
    fi
    
    # Verificar n8n rodando
    if docker ps | grep -q n8n; then
        echo -e "✅ ${GREEN}n8n está rodando${NC}"
    else
        echo -e "❌ ${RED}n8n não está rodando${NC}"
        echo -e "   ${YELLOW}Execute: docker-compose up -d n8n${NC}"
    fi
    
    echo ""
    echo -e "${YELLOW}Próximos passos:${NC}"
    echo "1. Configure credenciais na Meta (META_API_SETUP.md)"
    echo "2. Importe workflow no n8n"
    echo "3. Configure webhook na Meta Console"
    echo "4. Teste com opção 3 deste menu"
    echo ""
}

# Verificar pré-requisitos
check_prerequisites() {
    echo -e "${PURPLE}=== Verificando Pré-requisitos ===${NC}"
    echo ""
    
    # Docker
    if command -v docker &> /dev/null; then
        echo -e "✅ ${GREEN}Docker instalado${NC}"
    else
        echo -e "❌ ${RED}Docker não encontrado${NC}"
    fi
    
    # Docker Compose
    if command -v docker-compose &> /dev/null; then
        echo -e "✅ ${GREEN}Docker Compose instalado${NC}"
    else
        echo -e "❌ ${RED}Docker Compose não encontrado${NC}"
    fi
    
    # curl
    if command -v curl &> /dev/null; then
        echo -e "✅ ${GREEN}curl instalado${NC}"
    else
        echo -e "❌ ${RED}curl não encontrado${NC}"
    fi
    
    # Arquivos necessários
    echo ""
    echo -e "${YELLOW}Arquivos de configuração:${NC}"
    
    [ -f "docker-compose.yml" ] && echo -e "✅ docker-compose.yml" || echo -e "❌ docker-compose.yml"
    [ -f ".env.example" ] && echo -e "✅ .env.example" || echo -e "❌ .env.example"
    [ -f "workflows/whatsapp-ai-agent-meta.json" ] && echo -e "✅ workflow Meta API" || echo -e "❌ workflow Meta API"
    [ -f "test-meta-webhook.sh" ] && echo -e "✅ script de teste" || echo -e "❌ script de teste"
    
    echo ""
}

# Testar webhook
test_webhook() {
    echo -e "${PURPLE}=== Testar Webhook ===${NC}"
    echo ""
    
    if [ ! -f "test-meta-webhook.sh" ]; then
        echo -e "${RED}❌ Script de teste não encontrado${NC}"
        return
    fi
    
    echo "1. Teste de Verificação (Meta)"
    echo "2. Teste de Mensagem (Simulação)"
    echo "3. Status do Webhook"
    echo ""
    echo -n "Escolha: "
    read test_choice
    
    case $test_choice in
        1)
            ./test-meta-webhook.sh verify
            ;;
        2)
            ./test-meta-webhook.sh message
            ;;
        3)
            ./test-meta-webhook.sh status
            ;;
        *)
            echo -e "${RED}Opção inválida${NC}"
            ;;
    esac
    
    echo ""
}

# Ver status
show_status() {
    echo -e "${PURPLE}=== Status Atual ===${NC}"
    echo ""
    
    echo -e "${YELLOW}Containers Docker:${NC}"
    docker-compose ps 2>/dev/null || echo "Erro ao verificar containers"
    
    echo ""
    echo -e "${YELLOW}Variáveis de Ambiente (.env):${NC}"
    if [ -f .env ]; then
        echo "WHATSAPP_PHONE_NUMBER_ID: $(grep WHATSAPP_PHONE_NUMBER_ID .env | cut -d= -f2 | head -c 20)..."
        echo "WHATSAPP_ACCESS_TOKEN: $(grep WHATSAPP_ACCESS_TOKEN .env | cut -d= -f2 | head -c 20)..."
        echo "WEBHOOK_PUBLIC_URL: $(grep WEBHOOK_PUBLIC_URL .env | cut -d= -f2)"
    else
        echo "Arquivo .env não encontrado"
    fi
    
    echo ""
}

# Abrir documentação
open_docs() {
    echo -e "${PURPLE}=== Documentação Disponível ===${NC}"
    echo ""
    echo "1. 🚀 META_API_QUICKSTART.md - Início rápido (30 min)"
    echo "2. 📖 META_API_SETUP.md - Setup completo"
    echo "3. 📋 META_API_MIGRATION_PLAN.md - Plano detalhado"
    echo "4. 💬 META_API_EXAMPLES.md - Exemplos de uso"
    echo "5. ✅ MIGRATION_SUMMARY.md - Resumo da migração"
    echo ""
    echo -n "Escolha (ou Enter para voltar): "
    read doc_choice
    
    case $doc_choice in
        1) cat META_API_QUICKSTART.md | less ;;
        2) cat META_API_SETUP.md | less ;;
        3) cat META_API_MIGRATION_PLAN.md | less ;;
        4) cat META_API_EXAMPLES.md | less ;;
        5) cat MIGRATION_SUMMARY.md | less ;;
        *) return ;;
    esac
}

# Main loop
main() {
    while true; do
        show_banner
        show_menu
        read choice
        
        case $choice in
            1)
                show_checklist
                ;;
            2)
                check_prerequisites
                ;;
            3)
                test_webhook
                ;;
            4)
                show_status
                ;;
            5)
                open_docs
                ;;
            6)
                echo -e "${GREEN}Até logo! 👋${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}Opção inválida!${NC}"
                ;;
        esac
        
        echo ""
        echo -n "Pressione Enter para continuar..."
        read
    done
}

# Run
main
