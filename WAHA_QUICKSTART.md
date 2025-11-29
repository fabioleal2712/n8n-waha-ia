# 🚀 WAHA Quick Start

Guia rápido para começar a usar WAHA (WhatsApp HTTP API) com n8n.

## ⚡ Início Rápido (5 minutos)

### 1. Iniciar WAHA

```bash
cd /home/fabioleal/github/n8n
docker-compose up -d waha
```

### 2. Verificar Status

```bash
./waha-manage.sh health
```

### 3. Conectar WhatsApp

```bash
# Iniciar sessão
./waha-manage.sh start

# Ver QR code
./waha-manage.sh qr
```

Escaneie o QR code com WhatsApp (WhatsApp → Menu → Aparelhos conectados → Conectar aparelho)

### 4. Verificar Conexão

```bash
./waha-manage.sh status
```

Deve mostrar: `"status": "WORKING"`

### 5. Testar Envio

```bash
./waha-manage.sh send 5511999999999 "Olá do WAHA!"
```

## 🎯 Comandos Principais

| Comando | Descrição |
|---------|-----------|
| `./waha-manage.sh health` | Verifica se WAHA está rodando |
| `./waha-manage.sh start` | Inicia sessão WhatsApp |
| `./waha-manage.sh qr` | Mostra QR code |
| `./waha-manage.sh status` | Status da sessão |
| `./waha-manage.sh send <phone> <msg>` | Envia mensagem teste |
| `./waha-manage.sh logs` | Ver logs |

## 🌐 Acessar Interface Web

Abra no navegador: **http://10.30.0.50:3000**

Interface Swagger com todos os endpoints disponíveis.

## 🤖 Integração com n8n

### Webhook já está configurado!

O WAHA já está configurado para enviar mensagens para:
```
http://n8n:5678/webhook/whatsapp-agent
```

### Workflow atualizado

O workflow `WhatsApp AI Agent (WAHA)` já está pronto para usar.

### Testar integração

1. Envie uma mensagem para o WhatsApp conectado
2. O AI Agent deve responder automaticamente
3. Verifique logs: `docker logs -f n8n`

## 📊 Formato das Mensagens

### Recebida (do WAHA para n8n)
```json
{
  "event": "message",
  "payload": {
    "from": "5511999999999@c.us",
    "body": "Olá!"
  }
}
```

### Enviada (do n8n para WAHA)
```json
{
  "session": "default",
  "chatId": "5511999999999@c.us",
  "text": "Resposta do bot"
}
```

## 🔧 Troubleshooting Rápido

### WAHA não inicia
```bash
docker logs waha
docker-compose restart waha
```

### QR code não aparece
```bash
./waha-manage.sh stop
./waha-manage.sh start
./waha-manage.sh qr
```

### Mensagens não chegam no n8n
```bash
# Verificar webhook
docker exec waha ping n8n

# Ver logs
docker logs -f waha
docker logs -f n8n
```

## 📚 Próximos Passos

- ✅ Conectar WhatsApp
- ✅ Testar envio/recebimento
- ✅ Configurar AI Agent
- 📖 Ler [WAHA_MIGRATION.md](WAHA_MIGRATION.md) para detalhes
- 🔧 Personalizar workflow no n8n

## 🆘 Ajuda

- **Documentação completa**: [WAHA_MIGRATION.md](WAHA_MIGRATION.md)
- **WAHA Docs**: https://waha.devlike.pro/
- **Swagger UI**: http://10.30.0.50:3000
