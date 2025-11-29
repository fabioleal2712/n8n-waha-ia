#!/bin/bash
SESSION="nova1"
SECRET="THISISMYSECURETOKEN"
URL="http://localhost:21465"
WEBHOOK="https://n8n.fabioleal.com.br/webhook/whatsapp-agent"

echo "0. Limpando processos antigos..."
pkill -f chrome || true
pkill -f chromium || true

echo "1. Gerando novo token..."
TOKEN_RESP=$(curl -s -X POST "$URL/api/$SESSION/$SECRET/generate-token" -d '')
TOKEN=$(echo $TOKEN_RESP | grep -o '"token":"[^"]*"' | cut -d'"' -f4)

if [ -z "$TOKEN" ]; then
    echo "Erro ao gerar token: $TOKEN_RESP"
    exit 1
fi
echo "Token: $TOKEN"

echo -e "\n2. Iniciando sessão..."
curl -s -X POST "$URL/api/$SESSION/start-session" \
  -H 'accept: application/json' \
  -H 'Content-Type: application/json' \
  -H "Authorization: Bearer $TOKEN" \
  -d "{
    \"webhook\": \"$WEBHOOK\",
    \"waitQrCode\": 60000,
    \"autoClose\": 120000
  }"

echo -e "\n\n3. Aguardando (15s)..."
sleep 15

echo "4. Pegando QR Code..."
for i in {1..20}; do
    RESPONSE=$(curl -s -X GET "$URL/api/$SESSION/qrcode-session" \
      -H 'accept: application/json' \
      -H "Authorization: Bearer $TOKEN")
    
    if [[ "$RESPONSE" == *"qrcode"* ]] && [[ "$RESPONSE" != *"null"* ]]; then
        echo "QR Code encontrado!"
        QRCODE=$(echo $RESPONSE | grep -o '"qrcode":"[^"]*"' | cut -d'"' -f4)
        echo "QRCODE_BASE64: $QRCODE"
        exit 0
    fi
    echo "Tentativa $i: $(echo $RESPONSE | cut -c 1-50)..."
    sleep 3
done
