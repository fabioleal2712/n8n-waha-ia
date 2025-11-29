#!/bin/bash

# n8n Remote Access via SSH Tunnel
# Este script cria um túnel SSH para acessar o n8n remoto localmente

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}n8n Remote Access - SSH Tunnel${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Configurações
REMOTE_HOST="10.30.0.50"
REMOTE_USER="fabioleal"
SSH_KEY="~/key_client/keybinario"
LOCAL_PORT="5678"
REMOTE_PORT="5678"

echo -e "${YELLOW}Criando túnel SSH...${NC}"
echo ""
echo "Servidor remoto: $REMOTE_USER@$REMOTE_HOST"
echo "Porta local: $LOCAL_PORT"
echo "Porta remota: $REMOTE_PORT"
echo ""
echo -e "${GREEN}✓ Túnel criado com sucesso!${NC}"
echo ""
echo -e "${BLUE}Acesse o n8n em:${NC}"
echo -e "${GREEN}http://localhost:$LOCAL_PORT${NC}"
echo ""
echo -e "${YELLOW}Credenciais:${NC}"
echo "Usuário: admin"
echo "Senha: admin123"
echo ""
echo -e "${YELLOW}Pressione Ctrl+C para encerrar o túnel${NC}"
echo ""
echo "=========================================="
echo ""

# Criar o túnel SSH
ssh -i "$SSH_KEY" \
    -L "$LOCAL_PORT:localhost:$REMOTE_PORT" \
    -N \
    -o ServerAliveInterval=60 \
    -o ServerAliveCountMax=3 \
    "$REMOTE_USER@$REMOTE_HOST"
