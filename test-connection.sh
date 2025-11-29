#!/bin/bash

# n8n Connection Test Script
# Este script testa a conectividade com o n8n de várias formas

set -e

N8N_URL="http://10.30.0.50:5678"
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "=========================================="
echo "n8n Connection Test"
echo "=========================================="
echo ""

# Test 1: Ping
echo -n "1. Testing network connectivity (ping)... "
if ping -c 1 -W 2 10.30.0.50 > /dev/null 2>&1; then
    echo -e "${GREEN}OK${NC}"
else
    echo -e "${RED}FAILED${NC}"
    echo "   Cannot reach 10.30.0.50. Check your network connection."
    exit 1
fi

# Test 2: Port connectivity
echo -n "2. Testing port 5678 connectivity... "
if timeout 3 bash -c "cat < /dev/null > /dev/tcp/10.30.0.50/5678" 2>/dev/null; then
    echo -e "${GREEN}OK${NC}"
else
    echo -e "${RED}FAILED${NC}"
    echo "   Port 5678 is not accessible. Check firewall settings."
    exit 1
fi

# Test 3: HTTP request
echo -n "3. Testing HTTP response... "
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "$N8N_URL" 2>/dev/null || echo "000")
if [ "$HTTP_CODE" = "200" ]; then
    echo -e "${GREEN}OK (HTTP $HTTP_CODE)${NC}"
else
    echo -e "${RED}FAILED (HTTP $HTTP_CODE)${NC}"
    exit 1
fi

# Test 4: Get HTML content
echo -n "4. Testing HTML content... "
CONTENT=$(curl -s "$N8N_URL" 2>/dev/null)
if echo "$CONTENT" | grep -q "n8n"; then
    echo -e "${GREEN}OK${NC}"
else
    echo -e "${YELLOW}WARNING${NC}"
    echo "   HTML content doesn't contain 'n8n'. This might be a problem."
fi

# Test 5: WebSocket support (check headers)
echo -n "5. Testing WebSocket headers... "
HEADERS=$(curl -s -I "$N8N_URL" 2>/dev/null)
if echo "$HEADERS" | grep -qi "Connection:"; then
    echo -e "${GREEN}OK${NC}"
else
    echo -e "${YELLOW}WARNING${NC}"
fi

# Test 6: API endpoint
echo -n "6. Testing API endpoint... "
API_CODE=$(curl -s -o /dev/null -w "%{http_code}" "$N8N_URL/healthz" 2>/dev/null || echo "000")
if [ "$API_CODE" = "200" ]; then
    echo -e "${GREEN}OK (HTTP $API_CODE)${NC}"
else
    echo -e "${YELLOW}WARNING (HTTP $API_CODE)${NC}"
fi

echo ""
echo "=========================================="
echo "Test Summary"
echo "=========================================="
echo ""
echo -e "${GREEN}✓ n8n server is accessible!${NC}"
echo ""
echo "If you still get 'Error connecting to n8n' in your browser:"
echo ""
echo "1. Clear browser cache:"
echo "   - Press Ctrl+Shift+Delete"
echo "   - Or try incognito/private mode"
echo ""
echo "2. Try accessing from this machine:"
echo "   - Open browser and go to: $N8N_URL"
echo ""
echo "3. Check browser console (F12) for errors"
echo ""
echo "4. If accessing from a different computer:"
echo "   - Make sure it's on the same network"
echo "   - Or use SSH tunnel:"
echo "     ssh -i ~/key_client/keybinario -L 5678:localhost:5678 fabioleal@10.30.0.50"
echo "   - Then access: http://localhost:5678"
echo ""
