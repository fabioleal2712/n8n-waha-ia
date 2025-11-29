# 🚀 Deployment Guide - WAHA + n8n

Guia completo para fazer deploy da solução WAHA + n8n com AI Agent.

## 📋 Pré-requisitos

- [x] Docker e Docker Compose instalados
- [x] Servidor com acesso SSH (10.30.0.50)
- [x] Chave SSH configurada (`~/key_client/keybinario`)
- [x] Porta 3000 (WAHA) e 5678 (n8n) disponíveis

## 🎯 Deployment Completo

### Passo 1: Deploy via Ansible

```bash
cd /home/fabioleal/github/n8n

# Testar conectividade
./n8n-manage.sh ping

# Deploy completo (n8n + PostgreSQL)
./n8n-manage.sh deploy
```

### Passo 2: Iniciar WAHA

```bash
# Via SSH no servidor
ssh -i ~/key_client/keybinario fabioleal@10.30.0.50

cd /home/fabioleal/n8n
docker-compose up -d waha

# Verificar status
docker ps | grep waha
docker logs -f waha
```

**OU localmente:**

```bash
# Executar comando remoto
ssh -i ~/key_client/keybinario fabioleal@10.30.0.50 \
  "cd /home/fabioleal/n8n && docker-compose up -d waha"
```

### Passo 3: Verificar Instalação do Node WAHA

O node WAHA será instalado automaticamente na primeira inicialização do n8n.

```bash
# Ver logs de instalação
ssh -i ~/key_client/keybinario fabioleal@10.30.0.50 \
  "docker logs n8n | grep waha"
```

**Verificar na interface:**
1. Acesse http://10.30.0.50:5678
2. Crie um novo workflow
3. Procure por "WAHA" nos nodes
4. Deve aparecer: "WAHA" e "WAHA Trigger"

### Passo 4: Configurar Credenciais WAHA

1. **Acesse n8n**: http://10.30.0.50:5678
2. **Login**: admin / admin123
3. **Vá em Credentials** (menu lateral)
4. **Add Credential** → Procure "WAHA API"
5. **Configure:**
   - Name: `WAHA Local`
   - API URL: `http://waha:3000`
   - API Key: (deixe vazio)
6. **Test** → Deve mostrar "Connection successful"
7. **Save**

### Passo 5: Conectar WhatsApp

```bash
# Criar sessão
ssh -i ~/key_client/keybinario fabioleal@10.30.0.50 \
  "curl -X POST http://localhost:3000/api/sessions/start \
    -H 'Content-Type: application/json' \
    -d '{\"name\": \"default\"}'"

# Obter QR Code
ssh -i ~/key_client/keybinario fabioleal@10.30.0.50 \
  "curl http://localhost:3000/api/sessions/default/qr"
```

**OU via interface Swagger:**
1. Acesse http://10.30.0.50:3000
2. Vá em `POST /api/sessions/start`
3. Execute com: `{"name": "default"}`
4. Vá em `GET /api/sessions/{session}/qr`
5. Escaneie o QR code com WhatsApp

### Passo 6: Importar Workflow

**Opção A: Workflow com Nodes Nativos (Recomendado)**

1. Acesse n8n: http://10.30.0.50:5678
2. Clique em "Workflows" → "Import from File"
3. Selecione: `workflows/whatsapp-ai-agent-native.json`
4. **Configure:**
   - WAHA Trigger: Selecione credencial "WAHA Local"
   - Send WhatsApp: Selecione credencial "WAHA Local"
   - Google Gemini: Configure suas credenciais
   - AWS Cost Tool: Configure o workflow ID
5. **Ative o workflow**

**Opção B: Workflow com HTTP Request**

1. Importe: `workflows/whatsapp-ai-agent.json`
2. Configure credenciais do Gemini
3. Ative o workflow

### Passo 7: Configurar Webhook (se usar WAHA Trigger)

Após importar o workflow com WAHA Trigger:

1. **Copie a URL do webhook** do node WAHA Trigger
2. **Configure no WAHA:**

```bash
ssh -i ~/key_client/keybinario fabioleal@10.30.0.50

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

### Passo 8: Testar Integração

```bash
# Enviar mensagem de teste
ssh -i ~/key_client/keybinario fabioleal@10.30.0.50 \
  "curl -X POST http://localhost:3000/api/sendText \
    -H 'Content-Type: application/json' \
    -d '{
      \"session\": \"default\",
      \"chatId\": \"5511999999999@c.us\",
      \"text\": \"Teste de integração\"
    }'"
```

**OU envie uma mensagem real:**
1. Envie "Olá" para o WhatsApp conectado
2. O AI Agent deve responder automaticamente
3. Teste: "Quanto gastei na AWS?"

## 🔍 Verificação

### Checklist de Deployment

- [ ] n8n rodando (`docker ps | grep n8n`)
- [ ] PostgreSQL saudável (`docker ps | grep postgres`)
- [ ] WAHA rodando (`docker ps | grep waha`)
- [ ] WAHA health check OK (`curl http://localhost:3000/health`)
- [ ] Node WAHA instalado no n8n
- [ ] Credenciais WAHA configuradas
- [ ] WhatsApp conectado (status: WORKING)
- [ ] Workflow importado e ativo
- [ ] Webhook configurado (se usar WAHA Trigger)
- [ ] Teste de mensagem bem-sucedido

### Comandos de Verificação

```bash
# Status de todos os containers
ssh -i ~/key_client/keybinario fabioleal@10.30.0.50 \
  "cd /home/fabioleal/n8n && docker-compose ps"

# Logs do n8n
ssh -i ~/key_client/keybinario fabioleal@10.30.0.50 \
  "docker logs -f --tail=50 n8n"

# Logs do WAHA
ssh -i ~/key_client/keybinario fabioleal@10.30.0.50 \
  "docker logs -f --tail=50 waha"

# Status da sessão WhatsApp
ssh -i ~/key_client/keybinario fabioleal@10.30.0.50 \
  "curl http://localhost:3000/api/sessions/default"
```

## 🔧 Configurações Adicionais

### Nginx (Acesso Externo)

Se você configurou Nginx:

```bash
# Deploy Nginx
ansible-playbook -i ansible/inventory.yml ansible/playbook-nginx.yml
```

Acesse:
- n8n: https://n8n.fabioleal.com.br
- WAHA: http://10.30.0.50:3000 (apenas rede interna)

### Variáveis de Ambiente

Edite `.env` no servidor se necessário:

```bash
ssh -i ~/key_client/keybinario fabioleal@10.30.0.50
cd /home/fabioleal/n8n
nano .env
```

Depois reinicie:
```bash
docker-compose down
docker-compose up -d
```

## 🐛 Troubleshooting

### WAHA não inicia

```bash
# Ver logs detalhados
docker logs waha

# Verificar porta
netstat -tulpn | grep 3000

# Reiniciar
docker-compose restart waha
```

### Node WAHA não aparece

```bash
# Verificar instalação
docker exec n8n ls -la /home/node/.n8n/nodes

# Forçar reinstalação
docker-compose down
docker volume rm n8n_n8n_data  # CUIDADO: apaga dados
docker-compose up -d
```

### WhatsApp desconecta

```bash
# Verificar status
curl http://localhost:3000/api/sessions/default

# Reiniciar sessão
curl -X POST http://localhost:3000/api/sessions/default/restart

# Obter novo QR
curl http://localhost:3000/api/sessions/default/qr
```

### Webhook não funciona

```bash
# Testar conectividade n8n ↔ WAHA
docker exec waha ping n8n
docker exec n8n ping waha

# Verificar webhook configurado
curl http://localhost:3000/api/sessions/default | jq '.config.webhooks'

# Testar webhook manualmente
curl -X POST https://n8n.fabioleal.com.br/webhook/WEBHOOK_ID \
  -H "Content-Type: application/json" \
  -d '{"test": "data"}'
```

## 📊 Monitoramento

### Logs em Tempo Real

```bash
# Todos os containers
docker-compose logs -f

# Apenas n8n
docker logs -f n8n

# Apenas WAHA
docker logs -f waha
```

### Métricas

```bash
# Uso de recursos
docker stats

# Espaço em disco
docker system df
```

## 🔄 Backup

### Backup do n8n

```bash
# Backup do banco de dados
ssh -i ~/key_client/keybinario fabioleal@10.30.0.50 \
  "cd /home/fabioleal/n8n && \
   docker-compose exec -T postgres pg_dump -U n8n n8n > backup_$(date +%Y%m%d).sql"

# Download do backup
scp -i ~/key_client/keybinario \
  fabioleal@10.30.0.50:/home/fabioleal/n8n/backup_*.sql \
  ./backups/
```

### Backup das Sessões WAHA

```bash
# Backup dos volumes
ssh -i ~/key_client/keybinario fabioleal@10.30.0.50 \
  "cd /home/fabioleal/n8n && \
   docker run --rm -v n8n_waha_sessions:/data -v $(pwd):/backup \
   alpine tar czf /backup/waha_sessions_$(date +%Y%m%d).tar.gz /data"
```

## 🎉 Deployment Completo!

Após seguir todos os passos, você terá:

✅ n8n rodando com PostgreSQL
✅ WAHA integrado e conectado ao WhatsApp
✅ Node WAHA instalado no n8n
✅ AI Agent respondendo mensagens automaticamente
✅ Integração com AWS Cost Explorer
✅ Monitoramento e logs configurados

## 📚 Próximos Passos

1. Personalizar mensagens do AI Agent
2. Adicionar mais ferramentas (tools) ao agente
3. Configurar alertas e notificações
4. Implementar backup automático
5. Adicionar mais workflows

## 🔗 Links Úteis

- **n8n**: http://10.30.0.50:5678
- **WAHA Swagger**: http://10.30.0.50:3000
- **Documentação WAHA**: https://waha.devlike.pro/
- **n8n Docs**: https://docs.n8n.io/
