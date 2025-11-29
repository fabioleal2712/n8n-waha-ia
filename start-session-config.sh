#!/bin/bash
TOKEN="$2b$10$8_jbIqBt_Iiuq7OL3haL0.m15Eea8o32n8rxgVrvSxpu7R.LJL_zq"
SESSION="nova1"
URL="http://localhost:21465"
WEBHOOK="https://n8n.fabioleal.com.br/webhook/whatsapp-agent"

echo "1. Iniciando sessão com autoClose aumentado..."
curl -s -X POST "$URL/api/$SESSION/start-session" \
  -H 'accept: application/json' \
  -H 'Content-Type: application/json' \
  -H "Authorization: Bearer $TOKEN" \
  -d "{
    \"webhook\": \"$WEBHOOK\",
    \"waitQrCode\": 60000,
    \"autoClose\": 120000
  }"

echo -e "\n\n2. Aguardando inicialização (10s)..."
sleep 10

echo "3. Tentando pegar QR Code..."
for i in {1..20}; do
    echo "Tentativa $i..."
    RESPONSE=$(curl -s -X GET "$URL/api/$SESSION/qrcode-session" \
      -H 'accept: application/json' \
      -H "Authorization: Bearer $TOKEN")
    
    if [[ "$RESPONSE" == *"qrcode"* ]] && [[ "$RESPONSE" != *"null"* ]]; then
        echo "QR Code encontrado!"
        QRCODE=$(echo $RESPONSE | grep -o '"qrcode":"[^"]*"' | cut -d'"' -f4)
        echo "QRCODE_BASE64: $QRCODE"
        exit 0
    fi
    sleep 3
done
