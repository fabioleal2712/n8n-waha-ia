import os
import time
import requests
import json
from datetime import datetime

# Configuração via variáveis de ambiente ou direto no script
WPP_HOST = os.getenv('WPP_HOST', '10.30.0.50')
WPP_PORT = int(os.getenv('WPP_PORT', '21465'))
WPP_TOKEN = os.getenv('WPP_TOKEN', '$2b$10$GHPF2x_zztSuaqZYviUsJulvGCJUFJXXLhI4TvdvxToFAGJzMEP02')
WPP_SESSION = os.getenv('WPP_SESSION', 'nova1')
N8N_WEBHOOK = os.getenv('N8N_WEBHOOK', 'https://n8n.fabioleal.com.br/webhook/whatsapp-agent')
POLL_INTERVAL = int(os.getenv('POLL_INTERVAL', '5'))  # segundos

# Cache de mensagens processadas
processed_ids = set()

def get_chats():
    url = f"http://{WPP_HOST}:{WPP_PORT}/api/{WPP_SESSION}/all-chats"
    headers = {
        "accept": "application/json",
        "Authorization": f"Bearer {WPP_TOKEN}"
    }
    try:
        resp = requests.get(url, headers=headers, timeout=10)
        resp.raise_for_status()
        return resp.json()
    except Exception as e:
        print(f"❌ Erro ao buscar chats: {e}")
        return []

def forward_message(msg):
    payload = {
        "body": msg.get("body"),
        "sender": msg.get("from"),
        "timestamp": msg.get("t"),
        "isGroupMsg": msg.get("isGroupMsg", False),
        "chatId": msg.get("chatId"),
    }
    print(f"➡️ Payload para n8n: {json.dumps(payload, ensure_ascii=False)}")
    try:
        resp = requests.post(N8N_WEBHOOK, json=payload, timeout=10)
        print(f"✅ Enviado para n8n: {payload['sender']} - status {resp.status_code}")
        print(f"🔎 Resposta completa n8n: {resp.text}")
        if resp.status_code >= 400:
            print(f"⚠️ Erro HTTP ao enviar para n8n: {resp.status_code} - {resp.text}")
    except Exception as e:
        print(f"❌ Erro ao enviar para n8n: {e}")

def poll():
    print(f"🚀 Polling WPPConnect: http://{WPP_HOST}:{WPP_PORT}")
    print(f"🎯 Forwarding to n8n webhook: {N8N_WEBHOOK}")
    print(f"⏱️  Poll interval: {POLL_INTERVAL}s")
    while True:
        raw = get_chats()
        print(f"🔍 DEBUG chats type: {type(raw)} | value: {str(raw)[:200]}")
        chats = raw.get("response", []) if isinstance(raw, dict) else raw
        found = 0
        if not isinstance(chats, list):
            print("❌ Resposta inesperada da API, esperando lista.")
            time.sleep(POLL_INTERVAL)
            continue
        for chat in chats:
            if not isinstance(chat, dict):
                print(f"⚠️ Ignorando item não-dict: {chat}")
                continue
            print(f"🗂️ Chat: {json.dumps(chat, ensure_ascii=False)[:300]}")
            chat_id = chat.get("id", {}).get("_serialized")
            is_group = chat.get("id", {}).get("server") == "g.us"
            if not chat_id:
                print(f"❌ Chat sem id serializado: {chat}")
                continue
            if is_group:
                # Busca mensagens recentes do grupo
                url = f"http://{WPP_HOST}:{WPP_PORT}/api/{WPP_SESSION}/get-messages?chatId={chat_id}&isGroup=true&includeMe=true&limit=10"
                headers = {
                    "accept": "application/json",
                    "Authorization": f"Bearer {WPP_TOKEN}"
                }
                try:
                    resp = requests.get(url, headers=headers, timeout=10)
                    resp.raise_for_status()
                    msgs_raw = resp.json()
                    msgs = msgs_raw.get("response", []) if isinstance(msgs_raw, dict) else msgs_raw
                    print(f"📦 Mensagens recebidas de grupo {chat_id}: {len(msgs)}")
                    for msg in msgs:
                        msg_id = msg.get("id")
                        if msg_id and msg_id not in processed_ids:
                            print(f"📨 Nova mensagem: {msg.get('body')} de {msg.get('from')}")
                            forward_message(msg)
                            processed_ids.add(msg_id)
                            found += 1
                except Exception as e:
                    print(f"❌ Erro ao buscar mensagens de grupo {chat_id}: {e}")
                    # Fallback: tenta usar lastMessage se disponível
                    last_msg = chat.get("lastMessage")
                    if last_msg:
                        msg_id = last_msg.get("id")
                        print(f"🕵️ lastMessage grupo (fallback): {json.dumps(last_msg, ensure_ascii=False)}")
                        if msg_id and msg_id not in processed_ids:
                            print(f"📨 Nova mensagem grupo (fallback): {last_msg.get('body')} de {last_msg.get('from')}")
                            forward_message(last_msg)
                            processed_ids.add(msg_id)
                            found += 1
            else:
                # Para chats privados, usa lastMessage
                last_msg = chat.get("lastMessage")
                if not last_msg:
                    print(f"❌ Chat privado {chat_id} não tem lastMessage.")
                    continue
                msg_id = last_msg.get("id")
                print(f"🕵️ lastMessage privado: {json.dumps(last_msg, ensure_ascii=False)}")
                if msg_id and msg_id not in processed_ids:
                    print(f"📨 Nova mensagem privada: {last_msg.get('body')} de {last_msg.get('from')}")
                    forward_message(last_msg)
                    processed_ids.add(msg_id)
                    found += 1
        if found:
            print(f"🔔 {found} mensagem(ns) encaminhada(s)")
        time.sleep(POLL_INTERVAL)

if __name__ == "__main__":
    poll()
