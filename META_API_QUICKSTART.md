# ⚡ Quick Start: Migração Meta API

## 🎯 Checklist Rápido (30 minutos)

### 1️⃣ Obter Credenciais Meta (10 min)

```bash
# Acesse: https://developers.facebook.com/
# Crie app → Adicione WhatsApp → Copie:

Phone Number ID: _____________
Business Account ID: _____________
Access Token: EAAxxxxxxxxxxxxx
```

📖 **Guia completo:** [META_API_SETUP.md](META_API_SETUP.md)

---

### 2️⃣ Configurar Variáveis (5 min)

Edite `.env`:

```bash
# WhatsApp Meta API
WHATSAPP_PHONE_NUMBER_ID=seu_phone_id
WHATSAPP_BUSINESS_ACCOUNT_ID=seu_business_id
WHATSAPP_ACCESS_TOKEN=EAAxxxxxxxxxxxxx
WHATSAPP_VERIFY_TOKEN=n8n_meta_verify_2024
WHATSAPP_API_VERSION=v21.0
WEBHOOK_PUBLIC_URL=https://seu-dominio.com

# AWS (se ainda não configurado)
AWS_ACCESS_KEY_ID=sua_key
AWS_SECRET_ACCESS_KEY=sua_secret
AWS_DEFAULT_REGION=us-east-1
```

---

### 3️⃣ Restart n8n (2 min)

```bash
cd /home/fabioleal/n8n
docker-compose restart n8n

# Aguarde ~30 segundos
docker-compose logs -f n8n
```

---

### 4️⃣ Importar Workflow (5 min)

1. Acesse: http://seu-servidor:5678
2. **Workflows** → **Import from File**
3. Selecione: `workflows/whatsapp-ai-agent-meta.json`
4. Configure credenciais:
   - **Meta API** (Header Auth com token)
   - **Google Gemini**
   - **Workflow IDs** dos tools AWS

---

### 5️⃣ Configurar Webhook na Meta (5 min)

```bash
# 1. Ative o workflow no n8n primeiro!

# 2. Teste localmente:
./test-meta-webhook.sh verify

# 3. Configure na Meta:
# https://developers.facebook.com/ → WhatsApp → Configuration
Callback URL: https://seu-dominio.com/webhook/whatsapp-meta
Verify Token: n8n_meta_verify_2024

# 4. Subscribe to: messages
```

---

### 6️⃣ Testar (3 min)

```bash
# Teste 1: Webhook
./test-meta-webhook.sh verify
# ✅ Deve retornar: "Verificação bem-sucedida!"

# Teste 2: Mensagem
# Envie "Olá" via WhatsApp para o número configurado
# ✅ Bot deve responder

# Teste 3: AWS
# Envie "Quanto gastei na AWS?"
# ✅ Bot deve retornar relatório
```

---

## 🚨 Problemas Comuns

### ❌ Webhook não verifica

```bash
# Verifique se workflow está ATIVO
# Teste manualmente:
curl "https://seu-dominio.com/webhook/whatsapp-meta?hub.mode=subscribe&hub.verify_token=n8n_meta_verify_2024&hub.challenge=test"
```

### ❌ Mensagens não chegam

```bash
# Verifique subscription
# Meta Console → WhatsApp → Configuration → Webhook fields
# Marque: ✅ messages
```

### ❌ Bot não responde

```bash
# Verifique credencial Meta API no n8n
# Credentials → Meta API → Bearer TOKEN_AQUI

# Verifique logs:
docker logs -f n8n
```

---

## 📋 Workflow IDs dos Tools AWS

Para configurar os tools no workflow Meta API:

```bash
# 1. Abra cada workflow AWS no n8n
# 2. Copie o ID da URL
# 3. Cole no workflow Meta API

Exemplo:
http://servidor:5678/workflow/123
                          ^^^
                      Este é o ID

Tool AWS Cost - Aciol → ID: ___
Tool AWS Cost - DS2 → ID: ___
Tool AWS Cost - Fabiana → ID: ___
Tool AWS Cost - KLM → ID: ___
Tool AWS Cost - Soluzione → ID: ___
```

---

## ✅ Após Migração

```bash
# 1. Desativar workflow WAHA (opcional - manter como backup)
# 2. Manter WAHA rodando por 1 semana (fallback)
# 3. Monitorar logs por alguns dias
# 4. Remover WAHA após validação completa
```

---

## 📚 Documentação Completa

- 📖 [META_API_SETUP.md](META_API_SETUP.md) - Setup completo
- 📋 [META_API_MIGRATION_PLAN.md](META_API_MIGRATION_PLAN.md) - Plano detalhado
- 🔧 [WHATSAPP_META_API_MIGRATION.md](WHATSAPP_META_API_MIGRATION.md) - Guia original

---

## 🆘 Precisa de Ajuda?

```bash
# Teste webhook
./test-meta-webhook.sh status

# Logs n8n
docker logs -f n8n

# Status containers
docker-compose ps
```
