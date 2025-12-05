# 🚀 Plano de Migração: WAHA → WhatsApp Meta API

## 📋 Visão Geral

Migração completa do sistema de WhatsApp de WAHA (não-oficial) para WhatsApp Business Cloud API (oficial da Meta).

**Status:** 🟡 Planejamento  
**Data:** 2025-11-30  
**Estimativa:** 2-3 horas

---

## ✅ Checklist de Pré-requisitos

### 1. Conta Meta Business
- [ ] Criar conta no [Meta Business Suite](https://business.facebook.com/)
- [ ] Verificar conta de negócio

### 2. App Meta for Developers
- [ ] Acessar [Meta for Developers](https://developers.facebook.com/)
- [ ] Criar novo App ou usar existente
- [ ] Adicionar produto **WhatsApp**

### 3. Configuração WhatsApp
- [ ] Obter **Phone Number ID**
- [ ] Obter **WhatsApp Business Account ID**
- [ ] Gerar **Temporary Access Token** (para testes)

### 4. Token Permanente
- [ ] Criar System User no Meta Business Suite
- [ ] Atribuir permissões: `whatsapp_business_messaging`, `whatsapp_business_management`
- [ ] Gerar token permanente (Never expire)
- [ ] Salvar token em local seguro

### 5. Domínio e HTTPS
- [ ] Confirmar domínio público disponível
- [ ] Verificar certificado SSL válido
- [ ] Testar acesso HTTPS

---

## 🔧 Passos de Implementação

### Fase 1: Configuração Meta API (30 min)

#### 1.1 Configurar Webhook na Meta
```
URL: https://SEU_DOMINIO/webhook/whatsapp-meta
Verify Token: n8n_meta_verify_2024
Subscribe to: messages
```

#### 1.2 Atualizar Variáveis de Ambiente
Arquivo: `.env`
```bash
# WhatsApp Meta API
WHATSAPP_PHONE_NUMBER_ID=123456789
WHATSAPP_BUSINESS_ACCOUNT_ID=987654321
WHATSAPP_ACCESS_TOKEN=EAAxxxxxxxxxxxxx
WHATSAPP_VERIFY_TOKEN=n8n_meta_verify_2024
WHATSAPP_API_VERSION=v21.0

# Seu domínio público
WEBHOOK_PUBLIC_URL=https://SEU_DOMINIO
```

### Fase 2: Atualizar Workflows (45 min)

#### 2.1 Criar Novo Workflow Meta API
- [x] Arquivo criado: `workflows/whatsapp-ai-agent-meta.json`
- [ ] Importar no n8n
- [ ] Configurar credenciais
- [ ] Testar webhook verification

#### 2.2 Migrar Tools AWS
- [x] Tools já funcionam (não precisam mudança)
- [ ] Verificar integração com novo workflow

### Fase 3: Testes (30 min)

#### 3.1 Teste de Webhook
- [ ] Verificar webhook na Meta Console
- [ ] Enviar mensagem de teste
- [ ] Confirmar recebimento no n8n

#### 3.2 Teste de Resposta
- [ ] Enviar mensagem simples
- [ ] Testar comando AWS Cost
- [ ] Verificar formatação WhatsApp

#### 3.3 Teste de Memória
- [ ] Conversa com múltiplas mensagens
- [ ] Verificar contexto mantido

### Fase 4: Deploy (30 min)

#### 4.1 Atualizar Docker Compose
- [ ] Remover serviço WAHA (opcional - manter para fallback)
- [ ] Adicionar variáveis Meta API
- [ ] Restart containers

#### 4.2 Documentação
- [ ] Atualizar README.md
- [ ] Criar guia de troubleshooting
- [ ] Documentar endpoints

---

## 📦 Arquivos Criados/Modificados

### Novos Arquivos
- ✅ `workflows/whatsapp-ai-agent-meta.json` - Workflow Meta API
- ✅ `META_API_MIGRATION_PLAN.md` - Este arquivo
- ✅ `META_API_SETUP.md` - Guia de configuração
- ✅ `test-meta-webhook.sh` - Script de teste

### Arquivos Modificados
- ⏳ `.env` - Adicionar variáveis Meta API
- ⏳ `docker-compose.yml` - Adicionar env vars
- ⏳ `README.md` - Atualizar documentação

### Arquivos Deprecados (manter para rollback)
- 📦 `workflows/whatsapp-ai-agent-native.json` (WAHA)
- 📦 `waha-manage.sh`
- 📦 Serviço `waha` no docker-compose.yml

---

## 🔄 Estratégia de Migração

### Opção Escolhida: Migração Completa

**Vantagens:**
- ✅ Solução definitiva
- ✅ Remove dependência WAHA
- ✅ Melhor estabilidade

**Plano:**
1. Configurar Meta API completamente
2. Testar novo workflow
3. Desativar workflow WAHA
4. Ativar workflow Meta API
5. Manter WAHA como backup por 1 semana

---

## 🧪 Testes de Validação

### Casos de Teste

#### Teste 1: Mensagem Simples
```
Usuário: "Olá"
Esperado: Resposta do AI Agent
```

#### Teste 2: Consulta AWS
```
Usuário: "Quanto gastei na AWS esse mês?"
Esperado: Relatório de custos formatado
```

#### Teste 3: Múltiplas Contas
```
Usuário: "Custos da conta aciol"
Esperado: Custos específicos da conta aciol
```

#### Teste 4: Memória de Contexto
```
Usuário: "Qual o custo do EC2?"
Bot: "Resposta..."
Usuário: "E do S3?"
Esperado: Bot entende contexto da conversa anterior
```

---

## 🚨 Rollback Plan

Se algo der errado:

### Passo 1: Reverter Workflow
```bash
# Desativar Meta API workflow
# Ativar WAHA workflow
```

### Passo 2: Reverter Docker
```bash
cd /home/fabioleal/n8n
docker-compose restart waha
```

### Passo 3: Verificar
```bash
./waha-manage.sh status
```

---

## 💰 Custos Estimados

### Seu Cenário (200 conversas/mês)
- **Custo:** $0/mês (dentro do free tier de 1000)
- **Free tier:** 1000 conversas/mês
- **Margem:** 800 conversas disponíveis

### Projeção Futura
Se crescer para 1500 conversas/mês:
- 1000 grátis
- 500 pagas × $0.005 = **$2.50/mês**

---

## 📚 Recursos e Links

### Documentação Meta
- [Cloud API Overview](https://developers.facebook.com/docs/whatsapp/cloud-api)
- [Send Messages](https://developers.facebook.com/docs/whatsapp/cloud-api/guides/send-messages)
- [Webhooks](https://developers.facebook.com/docs/whatsapp/cloud-api/webhooks)
- [API Reference](https://developers.facebook.com/docs/whatsapp/cloud-api/reference)

### Ferramentas
- [Meta Business Suite](https://business.facebook.com/)
- [Meta for Developers](https://developers.facebook.com/)
- [WhatsApp Manager](https://business.facebook.com/wa/manage/)

---

## ✅ Próximos Passos

1. **Agora:** Configurar conta Meta e obter credenciais
2. **Depois:** Importar workflow Meta API no n8n
3. **Testar:** Validar todos os casos de uso
4. **Deploy:** Ativar em produção
5. **Monitorar:** Acompanhar por 1 semana

---

## 📞 Suporte

### Problemas Comuns

**Webhook não verifica:**
- Verificar URL pública acessível
- Confirmar HTTPS válido
- Checar verify token

**Mensagens não chegam:**
- Verificar subscription no webhook
- Confirmar Phone Number ID correto
- Checar logs do n8n

**Erro 401:**
- Token expirado ou inválido
- Regenerar System User Token

**Erro 403:**
- Permissões insuficientes
- Adicionar `whatsapp_business_messaging`
