# 🎉 Deployment Concluído!

## ✅ Status do Deploy

### Containers Rodando
- ✅ **n8n** - Porta 5678 (healthy)
- ✅ **PostgreSQL** - Porta 5432 (healthy)  
- ✅ **WAHA** - Porta 3000 (running)

### Volumes Criados
- ✅ `n8n_waha_sessions` - Sessões WhatsApp
- ✅ `n8n_waha_media` - Arquivos de mídia

### WAHA Configuração
- **Engine**: GOWS (Go WhatsApp)
- **Version**: 2025.11.2
- **Tier**: CORE (gratuito)
- **API**: http://10.30.0.50:3000
- **Swagger UI**: http://10.30.0.50:3000

## 🚀 Próximos Passos

### 1. Conectar WhatsApp

**Via Servidor (SSH):**

```bash
ssh -i ~/key_client/keybinario fabioleal@10.30.0.50

# Criar sessão
curl -X POST http://10.30.0.50:3000/api/sessions/start \
  -H "Content-Type: application/json" \
  -d '{"name": "default"}'

# Verificar status
curl http://10.30.0.50:3000/api/sessions

# Obter QR Code (retorna imagem PNG)
curl http://10.30.0.50:3000/api/screenshot?session=default > qrcode.png

# OU via endpoint de autenticação
curl http://10.30.0.50:3000/api/default/auth/qr
```

**Via Swagger UI (Recomendado):**
1. Acesse: http://10.30.0.50:3000
2. Vá em `POST /api/sessions/start`
3. Execute com: `{"name": "default"}`
4. Vá em `GET /api/sessions/{session}/qr`
5. Escaneie o QR code

### 2. Configurar Credenciais no n8n

1. Acesse: http://10.30.0.50:5678
2. Login: admin / admin123
3. Vá em **Credentials** → **Add Credential**
4. Procure "WAHA API"
5. Configure:
   - Name: `WAHA Local`
   - API URL: `http://waha:3000`
   - API Key: (deixe vazio)
6. **Test** → **Save**

### 3. Importar Workflow

**Opção A: Workflow com Nodes Nativos (Recomendado)**

1. No n8n, clique em "Workflows" → "Import from File"
2. Selecione: `/home/fabioleal/n8n/workflows/whatsapp-ai-agent-native.json`
3. Configure:
   - WAHA Trigger: Credencial "WAHA Local"
   - Send WhatsApp: Credencial "WAHA Local"
   - Google Gemini: Suas credenciais
   - AWS Cost Tool: ID do workflow de custos
4. **Ative o workflow**

**Opção B: Workflow com HTTP Request**

1. Importe: `/home/fabioleal/n8n/workflows/whatsapp-ai-agent.json`
2. Configure credenciais
3. Ative

### 4. Configurar Webhook (se usar WAHA Trigger)

Após importar workflow com WAHA Trigger:

```bash
# Copie a URL do webhook do node WAHA Trigger
# Exemplo: https://n8n.fabioleal.com.br/webhook/abc123

# Configure no WAHA
ssh -i ~/key_client/keybinario fabioleal@10.30.0.50

curl -X POST http://10.30.0.50:3000/api/sessions/default/config \
  -H "Content-Type: application/json" \
  -d '{
    "webhooks": [{
      "url": "https://n8n.fabioleal.com.br/webhook/SUA_URL_AQUI",
      "events": ["message"]
    }]
  }'
```

### 5. Testar

```bash
# Enviar mensagem de teste
curl -X POST http://10.30.0.50:3000/api/sendText \
  -H "Content-Type: application/json" \
  -d '{
    "session": "default",
    "chatId": "5511999999999@c.us",
    "text": "Teste de integração"
  }'
```

**OU envie mensagem real:**
- Envie "Olá" para o WhatsApp conectado
- O AI Agent deve responder automaticamente

## 📊 Verificação

### Comandos Úteis

```bash
# Status dos containers
ssh -i ~/key_client/keybinario fabioleal@10.30.0.50 \
  "cd /home/fabioleal/n8n && docker-compose ps"

# Logs do WAHA
ssh -i ~/key_client/keybinario fabioleal@10.30.0.50 \
  "docker logs -f waha"

# Logs do n8n
ssh -i ~/key_client/keybinario fabioleal@10.30.0.50 \
  "docker logs -f n8n"

# Status da sessão WhatsApp
ssh -i ~/key_client/keybinario fabioleal@10.30.0.50 \
  "curl http://10.30.0.50:3000/api/sessions/default"

# Health check
ssh -i ~/key_client/keybinario fabioleal@10.30.0.50 \
  "curl http://10.30.0.50:3000/health"
```

### Checklist

- [x] WAHA container rodando
- [x] n8n reiniciado
- [ ] WhatsApp conectado (status: WORKING)
- [ ] Credenciais WAHA configuradas no n8n
- [ ] Workflow importado
- [ ] Workflow ativado
- [ ] Webhook configurado (se usar WAHA Trigger)
- [ ] Teste de mensagem bem-sucedido

## 🔗 Links Úteis

- **n8n**: http://10.30.0.50:5678
- **WAHA Swagger**: http://10.30.0.50:3000
- **Documentação**: Ver arquivos `.md` no projeto

## 📚 Documentação

- [WAHA_QUICKSTART.md](file:///home/fabioleal/github/n8n/WAHA_QUICKSTART.md) - Guia rápido
- [WAHA_N8N_NODE.md](file:///home/fabioleal/github/n8n/WAHA_N8N_NODE.md) - Node nativo
- [DEPLOYMENT.md](file:///home/fabioleal/github/n8n/DEPLOYMENT.md) - Deploy completo
- [WAHA_MIGRATION.md](file:///home/fabioleal/github/n8n/WAHA_MIGRATION.md) - Migração

## ⚠️ Notas Importantes

1. **API Key**: WAHA está rodando sem API key (modo desenvolvimento). Para produção, configure `WAHA_API_KEY`.

2. **Node WAHA**: O node da comunidade será instalado automaticamente na próxima vez que você acessar o n8n. Se não aparecer, reinicie o container.

3. **Sessões**: As sessões WhatsApp são persistidas no volume `waha_sessions`.

4. **Backup**: Faça backup regular dos volumes para não perder sessões.
