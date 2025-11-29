#!/bin/bash

# Server Monitoring Script
# Monitora recursos do servidor e containers

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

SSH_CMD="ssh -i ~/key_client/keybinario fabioleal@10.30.0.50"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Monitoramento do Servidor${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Sistema
echo -e "${YELLOW}=== SISTEMA ===${NC}"
$SSH_CMD "uptime"
echo ""

# CPU e Load
echo -e "${YELLOW}=== CPU & LOAD ===${NC}"
$SSH_CMD "top -bn1 | head -5"
echo ""

# Memória
echo -e "${YELLOW}=== MEMÓRIA ===${NC}"
$SSH_CMD "free -h"
echo ""

# Disco
echo -e "${YELLOW}=== DISCO ===${NC}"
$SSH_CMD "df -h /"
echo ""

# Containers
echo -e "${YELLOW}=== CONTAINERS ===${NC}"
$SSH_CMD "docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.CPUPerc}}\t{{.MemUsage}}' 2>/dev/null || docker ps --format 'table {{.Names}}\t{{.Status}}'"
echo ""

# n8n específico
echo -e "${YELLOW}=== n8n STATUS ===${NC}"
N8N_STATUS=$($SSH_CMD "docker inspect n8n --format='{{.State.Status}}' 2>/dev/null" || echo "not found")
N8N_HEALTH=$($SSH_CMD "docker inspect n8n --format='{{.State.Health.Status}}' 2>/dev/null" || echo "unknown")

if [ "$N8N_STATUS" = "running" ]; then
    echo -e "${GREEN}✓ n8n está rodando${NC}"
    if [ "$N8N_HEALTH" = "healthy" ]; then
        echo -e "${GREEN}✓ n8n está saudável${NC}"
    else
        echo -e "${YELLOW}⚠ n8n health: $N8N_HEALTH${NC}"
    fi
else
    echo -e "${RED}✗ n8n não está rodando${NC}"
fi

echo ""
echo -e "${BLUE}========================================${NC}"
echo ""
echo "Para monitoramento contínuo:"
echo "  watch -n 5 ./monitor-server.sh"
echo ""
echo "Para ver logs do n8n:"
echo "  ./n8n-manage.sh logs"
echo ""
