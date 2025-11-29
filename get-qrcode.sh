#!/bin/bash
TOKEN="$2b$10$M2UVj9SZ2XzlTV0WVvFTCeYo8Vo3vj4_QcWt03t7vF_TDaub5jUAC"
SESSION="nova1"
URL="http://localhost:21465"
WEBHOOK="https://n8n.fabioleal.com.br/webhook/whatsapp-agent"

echo "1. Iniciando sessão..."
curl -s -X POST "$URL/api/$SESSION/start-session" \
  -H 'accept: application/json' \
  -H "Authorization: Bearer $TOKEN" \
  -d "{\"webhook\": \"$WEBHOOK\"}"

echo -e "\n\n2. Aguardando inicialização (10s)..."
sleep 10

echo "3. Tentando pegar QR Code..."
for i in {1..5}; do
    echo "Tentativa $i..."
    RESPONSE=$(curl -s -X GET "$URL/api/$SESSION/qrcode-session" \
      -H 'accept: application/json' \
      -H "Authorization: Bearer $TOKEN")
    
    STATUS=$(echo $RESPONSE | grep -o '"status":"[^"]*"' | cut -d'"' -f4)
    echo "Status: $STATUS"
    
    if [[ "$RESPONSE" == *"qrcode"* ]] && [[ "$RESPONSE" != *"null"* ]]; then
        echo "QR Code encontrado!"
        QRCODE=$(echo $RESPONSE | grep -o '"qrcode":"[^"]*"' | cut -d'"' -f4)
        echo "QRCODE_BASE64: $QRCODE"
        exit 0
    fi
    sleep 5
done
