#!/bin/bash

SESSION="n8n-agent"
TOKEN="$2b$10$aQk8oU_ZEVdde78Od79W3.OU0ZZ4BtPe0MnWRuWV5FW4hqCf4SXaq"
URL="http://localhost:21465"

echo "1. Reiniciando sessão..."
curl -s -X POST "$URL/api/$SESSION/start-session" \
  -H 'accept: application/json' \
  -H "Authorization: Bearer $TOKEN" \
  -d ''

echo -e "\n\n2. Aguardando 15 segundos..."
sleep 15

echo "3. Verificando Status..."
curl -s -X GET "$URL/api/$SESSION/status-session" \
  -H 'accept: application/json' \
  -H "Authorization: Bearer $TOKEN"

echo -e "\n\n4. Obtendo QR Code..."
curl -s -X GET "$URL/api/$SESSION/qrcode-session" \
  -H 'accept: application/json' \
  -H "Authorization: Bearer $TOKEN"
