#!/bin/bash
TOKEN="$2b$10$9fUMe1USFM_YKNczZc1xy.QuyurxP2pVxbH1_wJgMewhg3mBH_S7u"
SESSION="n8n-final"
URL="http://localhost:21465"

echo "Tentando pegar QR Code para sessão $SESSION..."

for i in {1..10}; do
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
