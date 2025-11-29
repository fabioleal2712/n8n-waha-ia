#!/bin/bash
SESSION="n8n-client"
SECRET="THISISMYSECURETOKEN"
URL="http://localhost:21465"
WEBHOOK="https://n8n.fabioleal.com.br/webhook/whatsapp-agent"

echo "1. Reiniciando WPPConnect..."
docker restart wpconnect-server
echo "Aguardando 10s..."
sleep 10

echo "2. Gerando Token..."
TOKEN_RESP=$(curl -s -X POST "$URL/api/$SESSION/$SECRET/generate-token" -d '')
TOKEN=$(echo $TOKEN_RESP | grep -o '"token":"[^"]*"' | cut -d'"' -f4)

if [ -z "$TOKEN" ]; then
    echo "Erro ao gerar token. Verifique o servidor."
    exit 1
fi
echo "Token gerado."

echo "3. Iniciando Sessão..."
curl -s -X POST "$URL/api/$SESSION/start-session" \
  -H 'Content-Type: application/json' \
  -H "Authorization: Bearer $TOKEN" \
  -d "{
    \"webhook\": \"$WEBHOOK\",
    \"waitQrCode\": 60000,
    \"autoClose\": 120000
  }"

echo -e "\n4. Buscando QR Code (pode levar até 30s)..."

for i in {1..15}; do
    RESPONSE=$(curl -s -X GET "$URL/api/$SESSION/qrcode-session" \
      -H "Authorization: Bearer $TOKEN")
    
    if [[ "$RESPONSE" == *"qrcode"* ]] && [[ "$RESPONSE" != *"null"* ]]; then
        echo -e "\n✅ QR CODE ENCONTRADO!"
        QRCODE=$(echo $RESPONSE | grep -o '"qrcode":"[^"]*"' | cut -d'"' -f4)
        echo "---------------------------------------------------"
        echo "$QRCODE"
        echo "---------------------------------------------------"
        echo "Copie o código acima e gere a imagem em: https://www.qr-code-generator.com/ (selecione Texto)"
        echo "Token para o n8n: $TOKEN"
        exit 0
    fi
    echo -n "."
    sleep 2
done

echo -e "\n❌ Não foi possível obter o QR Code. Tente novamente."
