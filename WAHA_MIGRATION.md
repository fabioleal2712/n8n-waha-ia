# 🔄 Migração WPPConnect → WAHA

Guia completo para migrar do WPPConnect para WAHA (WhatsApp HTTP API).

## 📋 O que é WAHA?

**WAHA** (WhatsApp HTTP API) é uma alternativa **gratuita e open-source** ao WPPConnect, com:

- ✅ **Webhooks nativos** (sem necessidade de polling)
- ✅ **Interface Swagger** para testes
- ✅ **Múltiplos engines** (WEBJS, NOWEB, GOWS)
- ✅ **Menor consumo de recursos**
- ✅ **Desenvolvimento ativo**

## 🚀 Migração Rápida

### 1. Parar Serviços Antigos

```bash
cd /home/fabioleal/github/n8n
docker-compose down
```

### 2. Atualizar Configuração

O `docker-compose.yml` já foi atualizado com:
- ✅ Serviço WAHA configurado
- ✅ WPPConnect polling forwarder desabilitado
- ✅ Volumes para sessões e mídia

### 3. Iniciar WAHA

```bash
docker-compose up -d waha
```

### 4. Verificar Status

```bash
# Ver logs
docker logs -f waha

# Verificar saúde
curl http://localhost:3000/health
```

### 5. Acessar Interface

Abra no navegador: **http://10.30.0.50:3000**

Você verá a interface Swagger do WAHA.

## 📱 Conectar WhatsApp

### Método 1: Via Swagger UI (Recomendado)

1. Acesse http://10.30.0.50:3000
2. Vá em **Sessions** → `POST /api/sessions/start`
3. Clique em "Try it out"
4. Use este JSON:
   ```json
   {
     "name": "default",
     "config": {
       "webhooks": [
         {
           "url": "http://n8n:5678/webhook/whatsapp-agent",
           "events": ["message"]
         }
       ]
     }
   }
   ```
5. Clique em "Execute"
6. Vá em `GET /api/sessions/{session}/qr` para ver o QR code
7. Escaneie com WhatsApp

### Método 2: Via cURL

```bash
# Iniciar sessão
curl -X POST http://localhost:3000/api/sessions/start \
  -H "Content-Type: application/json" \
  -d '{
    "name": "default",
    "config": {
      "webhooks": [
        {
          "url": "http://n8n:5678/webhook/whatsapp-agent",
          "events": ["message"]
        }
      ]
    }
  }'

# Obter QR Code
curl http://localhost:3000/api/sessions/default/qr
```

## 🔧 Atualizar Workflow n8n

### Webhook (Receber Mensagens)

O webhook já está configurado no WAHA para enviar para:
```
http://n8n:5678/webhook/whatsapp-agent
```

**Formato da mensagem recebida:**
```json
{
  "event": "message",
  "session": "default",
  "payload": {
    "id": "message_id",
    "from": "5511999999999@c.us",
    "body": "Texto da mensagem",
    "timestamp": 1234567890
  }
}
```

### Enviar Mensagens

**Endpoint WAHA:**
```
POST http://waha:3000/api/sendText
```

**Body:**
```json
{
  "session": "default",
  "chatId": "5511999999999@c.us",
  "text": "Sua mensagem aqui"
}
```

## 📊 Comparação de APIs

| Ação | WPPConnect | WAHA |
|------|------------|------|
| **Enviar Texto** | `POST /api/{session}/send-message` | `POST /api/sendText` |
| **Enviar Imagem** | `POST /api/{session}/send-image` | `POST /api/sendImage` |
| **Status Sessão** | `GET /api/{session}/status` | `GET /api/sessions/{session}` |
| **QR Code** | `GET /api/{session}/qrcode` | `GET /api/sessions/{session}/qr` |

## 🔍 Mapeamento de Dados

### Mensagem Recebida

**WPPConnect:**
```json
{
  "event": "onMessage",
  "sender": "5511999999999@c.us",
  "body": "texto"
}
```

**WAHA:**
```json
{
  "event": "message",
  "payload": {
    "from": "5511999999999@c.us",
    "body": "texto"
  }
}
```

### Enviar Mensagem

**WPPConnect:**
```json
{
  "phone": "5511999999999",
  "message": "texto"
}
```

**WAHA:**
```json
{
  "session": "default",
  "chatId": "5511999999999@c.us",
  "text": "texto"
}
```

## ✅ Checklist de Migração

- [ ] Parar serviços antigos (`docker-compose down`)
- [ ] Atualizar `docker-compose.yml` (já feito)
- [ ] Iniciar WAHA (`docker-compose up -d waha`)
- [ ] Acessar Swagger UI (http://10.30.0.50:3000)
- [ ] Criar sessão via API
- [ ] Escanear QR code no WhatsApp
- [ ] Verificar webhook configurado
- [ ] Atualizar workflow n8n (próximo passo)
- [ ] Testar envio de mensagem
- [ ] Testar recebimento de mensagem

## 🛠️ Comandos Úteis

### Ver Sessões Ativas
```bash
curl http://localhost:3000/api/sessions
```

### Status da Sessão
```bash
curl http://localhost:3000/api/sessions/default
```

### Parar Sessão
```bash
curl -X POST http://localhost:3000/api/sessions/default/stop
```

### Reiniciar Sessão
```bash
curl -X POST http://localhost:3000/api/sessions/default/restart
```

### Logs do WAHA
```bash
docker logs -f waha
```

## 🐛 Troubleshooting

### WAHA não inicia

```bash
# Ver logs
docker logs waha

# Verificar porta
netstat -tulpn | grep 3000

# Reiniciar
docker-compose restart waha
```

### QR Code não aparece

```bash
# Verificar status da sessão
curl http://localhost:3000/api/sessions/default

# Se necessário, parar e reiniciar
curl -X POST http://localhost:3000/api/sessions/default/stop
curl -X POST http://localhost:3000/api/sessions/default/start
```

### Webhook não funciona

1. Verificar se n8n está acessível:
   ```bash
   docker exec waha ping n8n
   ```

2. Testar webhook manualmente:
   ```bash
   curl -X POST http://n8n:5678/webhook/whatsapp-agent \
     -H "Content-Type: application/json" \
     -d '{"test": "data"}'
   ```

3. Ver logs do n8n:
   ```bash
   docker logs -f n8n
   ```

## 📚 Recursos

- [WAHA Documentation](https://waha.devlike.pro/)
- [WAHA GitHub](https://github.com/devlikeapro/waha)
- [API Reference](https://waha.devlike.pro/docs/how-to/engines/)

## 🔙 Rollback (se necessário)

Se precisar voltar ao WPPConnect:

1. Edite `docker-compose.yml`
2. Descomente o serviço `wpp-polling-forwarder`
3. Comente o serviço `waha`
4. Execute: `docker-compose up -d`
