#!/bin/bash

SESSION="n8n-agent"
SECRET="THISISMYSECURETOKEN"
URL="http://localhost:21465"
WEBHOOK="https://n8n.fabioleal.com.br/webhook/whatsapp-agent"

echo "1. Gerando token para sessão $SESSION..."
TOKEN_RESP=$(curl -s -X POST "$URL/api/$SESSION/$SECRET/generate-token" -d '')
TOKEN=$(echo $TOKEN_RESP | grep -o '"token":"[^"]*"' | cut -d'"' -f4)

if [ -z "$TOKEN" ]; then
    echo "Erro ao gerar token: $TOKEN_RESP"
    exit 1
fi

echo "Token gerado: $TOKEN"

echo -e "\n2. Iniciando sessão..."
START_RESP=$(curl -s -X POST "$URL/api/$SESSION/start-session" \
  -H 'accept: application/json' \
  -H "Authorization: Bearer $TOKEN" \
  -d "{\"webhook\": \"$WEBHOOK\"}")
echo $START_RESP

echo -e "\n3. Aguardando inicialização (15s)..."
sleep 15

echo "4. Tentando pegar QR Code..."
for i in {1..5}; do
    echo "Tentativa $i..."
    RESPONSE=$(curl -s -X GET "$URL/api/$SESSION/qrcode-session" \
      -H 'accept: application/json' \
      -H "Authorization: Bearer $TOKEN")
    
    if [[ "$RESPONSE" == *"qrcode"* ]]; then
        echo "QR Code encontrado!"
        QRCODE=$(echo $RESPONSE | grep -o '"qrcode":"[^"]*"' | cut -d'"' -f4)
        echo "QRCODE_BASE64: $QRCODE"
        exit 0
    fi
    sleep 5
done
