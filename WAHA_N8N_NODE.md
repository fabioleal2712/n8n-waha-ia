# 🔌 Instalação do Node WAHA no n8n

O n8n possui um **node oficial da comunidade** para WAHA que oferece integração nativa muito mais poderosa do que usar HTTP Request.

## 🎯 Vantagens do Node Nativo

✅ **WAHA Trigger** - Inicia workflows automaticamente ao receber mensagens
✅ **WAHA Actions** - Todas as ações da API disponíveis como nodes
✅ **Credenciais gerenciadas** - Configuração centralizada
✅ **Validação automática** - Erros detectados antes da execução
✅ **Melhor UX** - Interface visual para todas as operações

## 📦 Instalação

### Método 1: Via Interface Web (Recomendado)

1. **Acesse n8n**
   - URL: http://10.30.0.50:5678
   - Login: admin / admin123

2. **Vá em Settings**
   - Clique no ícone de engrenagem (⚙️) no menu lateral
   - Selecione "Community nodes"

3. **Instale o Node WAHA**
   - Clique em "Install a community node"
   - Digite: `@devlikeapro/n8n-nodes-waha`
   - Clique em "Install"
   - Aguarde a instalação (pode levar 1-2 minutos)

4. **Reinicie n8n**
   ```bash
   docker-compose restart n8n
   ```

### Método 2: Via Variável de Ambiente

Adicione ao `docker-compose.yml`:

```yaml
n8n:
  environment:
    # ... outras variáveis ...
    N8N_COMMUNITY_PACKAGES: "@devlikeapro/n8n-nodes-waha"
```

Depois reinicie:
```bash
docker-compose down
docker-compose up -d
```

## 🔐 Configurar Credenciais

1. **Acesse Credentials**
   - No n8n, vá em "Credentials" no menu lateral
   - Clique em "Add Credential"

2. **Selecione WAHA API**
   - Procure por "WAHA" na lista
   - Selecione "WAHA API"

3. **Configure**
   - **Name**: `WAHA Local`
   - **API URL**: `http://waha:3000`
   - **API Key**: deixe vazio (ou use se configurou)
   
4. **Teste e Salve**
   - Clique em "Test" para verificar conexão
   - Clique em "Save"

## 🎨 Criar Workflow com Node Nativo

### Opção 1: WAHA Trigger (Recomendado)

O **WAHA Trigger** inicia o workflow automaticamente quando mensagens chegam.

**Estrutura do Workflow:**
```
[WAHA Trigger] → [AI Agent] → [WAHA - Send Text]
```

**Configuração:**

1. **Adicionar WAHA Trigger**
   - Arraste "WAHA Trigger" para o canvas
   - Credential: Selecione "WAHA Local"
   - Session: `default`
   - Events: Marque `message`

2. **Copiar Webhook URL**
   - O trigger mostrará uma URL de produção
   - Copie essa URL

3. **Configurar Webhook no WAHA**
   ```bash
   # Atualizar sessão com webhook
   curl -X POST http://localhost:3000/api/sessions/default/config \
     -H "Content-Type: application/json" \
     -d '{
       "webhooks": [{
         "url": "https://n8n.fabioleal.com.br/webhook/WAHA_TRIGGER_ID",
         "events": ["message"]
       }]
     }'
   ```

4. **Adicionar AI Agent**
   - Conecte ao WAHA Trigger
   - Configure como antes

5. **Adicionar WAHA - Send Text**
   - Arraste "WAHA" node
   - Operation: `Send Text`
   - Credential: `WAHA Local`
   - Session: `default`
   - Chat ID: `={{ $('WAHA Trigger').item.json.payload.from }}`
   - Text: `={{ $('AI Agent').item.json.output }}`

### Opção 2: Webhook + WAHA Action

Se preferir manter o webhook manual:

```
[Webhook] → [AI Agent] → [WAHA - Send Text]
```

Apenas substitua o último node HTTP Request pelo node WAHA nativo.

## 📊 Workflow Completo (JSON)

Aqui está um exemplo de workflow usando nodes nativos:

```json
{
  "name": "WhatsApp AI Agent (WAHA Native)",
  "nodes": [
    {
      "parameters": {
        "session": "default",
        "events": ["message"]
      },
      "name": "WAHA Trigger",
      "type": "@devlikeapro/n8n-nodes-waha.wahaTrigger",
      "typeVersion": 1,
      "position": [100, 300],
      "credentials": {
        "wahaApi": {
          "name": "WAHA Local"
        }
      }
    },
    {
      "parameters": {
        "text": "={{ $json.payload.body }}",
        "options": {
          "systemMessage": "Você é um assistente DevOps..."
        }
      },
      "name": "AI Agent",
      "type": "@n8n/n8n-nodes-langchain.agent",
      "typeVersion": 1,
      "position": [400, 300]
    },
    {
      "parameters": {
        "operation": "sendText",
        "session": "default",
        "chatId": "={{ $('WAHA Trigger').item.json.payload.from }}",
        "text": "={{ $('AI Agent').item.json.output }}"
      },
      "name": "Send WhatsApp",
      "type": "@devlikeapro/n8n-nodes-waha.waha",
      "typeVersion": 1,
      "position": [700, 300],
      "credentials": {
        "wahaApi": {
          "name": "WAHA Local"
        }
      }
    }
  ],
  "connections": {
    "WAHA Trigger": {
      "main": [[{"node": "AI Agent", "type": "main", "index": 0}]]
    },
    "AI Agent": {
      "main": [[{"node": "Send WhatsApp", "type": "main", "index": 0}]]
    }
  }
}
```

## 🚀 Operações Disponíveis

O node WAHA oferece diversas operações:

### Mensagens
- ✅ Send Text
- ✅ Send Image
- ✅ Send File
- ✅ Send Video
- ✅ Send Audio
- ✅ Send Location
- ✅ Send Contact

### Sessões
- ✅ Start Session
- ✅ Stop Session
- ✅ Get Session Status
- ✅ Get QR Code

### Chats
- ✅ Get Chats
- ✅ Get Messages
- ✅ Delete Message

### Grupos
- ✅ Create Group
- ✅ Get Group Info
- ✅ Add/Remove Participants

## 🔄 Migração do Workflow Atual

Para migrar seu workflow atual:

1. **Instale o node WAHA** (passos acima)
2. **Configure credenciais**
3. **Substitua nodes:**
   - `Webhook` → `WAHA Trigger` (opcional, mas recomendado)
   - `HTTP Request (Send)` → `WAHA - Send Text`

## ✅ Checklist de Instalação

- [ ] Node WAHA instalado no n8n
- [ ] n8n reiniciado
- [ ] Credencial WAHA configurada
- [ ] Credencial testada com sucesso
- [ ] Workflow atualizado com nodes nativos
- [ ] Webhook configurado (se usar WAHA Trigger)
- [ ] Teste de envio/recebimento realizado

## 🐛 Troubleshooting

### Node não aparece após instalação
```bash
# Reiniciar n8n
docker-compose restart n8n

# Verificar logs
docker logs -f n8n
```

### Erro de conexão nas credenciais
- Verifique se WAHA está rodando: `docker ps | grep waha`
- Teste URL: `curl http://waha:3000/health`
- Use `http://waha:3000` (não `localhost`)

### Webhook não funciona
- Certifique-se que a URL do webhook está configurada no WAHA
- Use a URL de **produção** do trigger, não a de teste
- Verifique logs: `docker logs -f waha`

## 📚 Recursos

- **Node GitHub**: https://github.com/devlikeapro/n8n-nodes-waha
- **WAHA Docs**: https://waha.devlike.pro/
- **n8n Community Nodes**: https://docs.n8n.io/integrations/community-nodes/

## 🎯 Próximos Passos

1. Instalar node WAHA
2. Configurar credenciais
3. Criar novo workflow com WAHA Trigger
4. Testar integração
5. Migrar workflows existentes
