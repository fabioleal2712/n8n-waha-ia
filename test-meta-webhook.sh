#!/bin/bash

# Script de teste para WhatsApp Meta API Webhook
# Uso: ./test-meta-webhook.sh [verify|message|status]

set -e

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Carregar variáveis de ambiente
if [ -f .env ]; then
    source .env
else
    echo -e "${RED}❌ Arquivo .env não encontrado!${NC}"
    exit 1
fi

# Verificar variáveis necessárias
if [ -z "$WEBHOOK_PUBLIC_URL" ]; then
    echo -e "${RED}❌ WEBHOOK_PUBLIC_URL não configurado no .env${NC}"
    exit 1
fi

WEBHOOK_URL="${WEBHOOK_PUBLIC_URL}/webhook/whatsapp-meta"

# Função de ajuda
show_help() {
    echo -e "${BLUE}=== WhatsApp Meta API Webhook Tester ===${NC}"
    echo ""
    echo "Uso: $0 [comando]"
    echo ""
    echo "Comandos:"
    echo "  verify    - Testa verificação do webhook (Meta)"
    echo "  message   - Simula recebimento de mensagem"
    echo "  status    - Verifica status do webhook"
    echo "  help      - Mostra esta ajuda"
    echo ""
    echo "Exemplos:"
    echo "  $0 verify"
    echo "  $0 message"
    echo ""
}

# Teste de verificação (usado pela Meta)
test_verification() {
    echo -e "${BLUE}🔍 Testando verificação do webhook...${NC}"
    echo -e "${YELLOW}URL: ${WEBHOOK_URL}${NC}"
    echo ""
    
    CHALLENGE="test_challenge_12345"
    VERIFY_TOKEN="${WHATSAPP_VERIFY_TOKEN:-n8n_meta_verify_2024}"
    
    echo -e "${YELLOW}Enviando requisição de verificação...${NC}"
    
    RESPONSE=$(curl -s -w "\n%{http_code}" \
        "${WEBHOOK_URL}?hub.mode=subscribe&hub.verify_token=${VERIFY_TOKEN}&hub.challenge=${CHALLENGE}")
    
    HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
    BODY=$(echo "$RESPONSE" | head -n-1)
    
    echo ""
    echo -e "${YELLOW}HTTP Status: ${HTTP_CODE}${NC}"
    echo -e "${YELLOW}Response: ${BODY}${NC}"
    echo ""
    
    if [ "$HTTP_CODE" = "200" ] && [ "$BODY" = "$CHALLENGE" ]; then
        echo -e "${GREEN}✅ Verificação bem-sucedida!${NC}"
        echo -e "${GREEN}   O webhook está configurado corretamente.${NC}"
        return 0
    else
        echo -e "${RED}❌ Verificação falhou!${NC}"
        echo -e "${RED}   Esperado: HTTP 200 e body '${CHALLENGE}'${NC}"
        echo -e "${RED}   Recebido: HTTP ${HTTP_CODE} e body '${BODY}'${NC}"
        return 1
    fi
}

# Simula mensagem recebida
test_message() {
    echo -e "${BLUE}📱 Simulando mensagem recebida...${NC}"
    echo -e "${YELLOW}URL: ${WEBHOOK_URL}${NC}"
    echo ""
    
    # Payload similar ao que a Meta envia
    PAYLOAD='{
  "object": "whatsapp_business_account",
  "entry": [{
    "id": "WHATSAPP_BUSINESS_ACCOUNT_ID",
    "changes": [{
      "value": {
        "messaging_product": "whatsapp",
        "metadata": {
          "display_phone_number": "5511999999999",
          "phone_number_id": "PHONE_NUMBER_ID"
        },
        "contacts": [{
          "profile": {
            "name": "Test User"
          },
          "wa_id": "5511888888888"
        }],
        "messages": [{
          "from": "5511888888888",
          "id": "wamid.test123",
          "timestamp": "1234567890",
          "text": {
            "body": "Olá, este é um teste!"
          },
          "type": "text"
        }]
      },
      "field": "messages"
    }]
  }]
}'
    
    echo -e "${YELLOW}Enviando payload de teste...${NC}"
    
    RESPONSE=$(curl -s -w "\n%{http_code}" \
        -X POST \
        -H "Content-Type: application/json" \
        -d "$PAYLOAD" \
        "${WEBHOOK_URL}")
    
    HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
    BODY=$(echo "$RESPONSE" | head -n-1)
    
    echo ""
    echo -e "${YELLOW}HTTP Status: ${HTTP_CODE}${NC}"
    echo -e "${YELLOW}Response: ${BODY}${NC}"
    echo ""
    
    if [ "$HTTP_CODE" = "200" ]; then
        echo -e "${GREEN}✅ Mensagem processada com sucesso!${NC}"
        echo -e "${GREEN}   Verifique os logs do n8n para ver a execução.${NC}"
        return 0
    else
        echo -e "${RED}❌ Erro ao processar mensagem!${NC}"
        echo -e "${RED}   HTTP Status: ${HTTP_CODE}${NC}"
        return 1
    fi
}

# Verifica status do webhook
test_status() {
    echo -e "${BLUE}📊 Verificando status do webhook...${NC}"
    echo -e "${YELLOW}URL: ${WEBHOOK_URL}${NC}"
    echo ""
    
    echo -e "${YELLOW}Testando conectividade...${NC}"
    
    if curl -s -f -o /dev/null "${WEBHOOK_URL}"; then
        echo -e "${GREEN}✅ Webhook está acessível${NC}"
    else
        echo -e "${RED}❌ Webhook não está acessível${NC}"
        echo -e "${RED}   Verifique se o n8n está rodando e o workflow está ativo${NC}"
        return 1
    fi
    
    echo ""
    echo -e "${YELLOW}Configuração atual:${NC}"
    echo -e "  Webhook URL: ${WEBHOOK_URL}"
    echo -e "  Verify Token: ${WHATSAPP_VERIFY_TOKEN:-n8n_meta_verify_2024}"
    echo -e "  Phone Number ID: ${WHATSAPP_PHONE_NUMBER_ID:-não configurado}"
    echo -e "  Business Account ID: ${WHATSAPP_BUSINESS_ACCOUNT_ID:-não configurado}"
    echo ""
}

# Main
case "${1:-help}" in
    verify)
        test_verification
        ;;
    message)
        test_message
        ;;
    status)
        test_status
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        echo -e "${RED}❌ Comando inválido: $1${NC}"
        echo ""
        show_help
        exit 1
        ;;
esac
