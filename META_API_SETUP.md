# 🚀 Guia de Configuração: WhatsApp Meta API

## 📋 Passo a Passo Completo

### Parte 1: Configurar Meta for Developers (30 min)

#### 1. Criar/Acessar App Meta

1. Acesse: https://developers.facebook.com/
2. Faça login com sua conta Facebook
3. Clique em **"My Apps"** → **"Create App"**
4. Escolha tipo: **"Business"**
5. Preencha:
   - **App Name**: `n8n DevOps Bot`
   - **App Contact Email**: seu email
   - **Business Account**: selecione ou crie uma

#### 2. Adicionar WhatsApp ao App

1. No dashboard do app, clique em **"Add Product"**
2. Encontre **"WhatsApp"** e clique em **"Set Up"**
3. Aguarde configuração inicial

#### 3. Obter Credenciais Temporárias (para teste)

1. Vá em **WhatsApp** → **API Setup**
2. Anote as seguintes informações:

```bash
# Copie estes valores:
Phone Number ID: _____________
WhatsApp Business Account ID: _____________
Temporary Access Token: EAAxxxxxxxxxxxxx (válido por 24h)
```

#### 4. Testar Envio de Mensagem (Opcional)

No próprio painel da Meta, você pode testar enviando uma mensagem para seu número:

1. Em **"API Setup"**, role até **"Send and receive messages"**
2. Adicione seu número pessoal (com código do país, ex: 5511999999999)
3. Você receberá um código via WhatsApp
4. Insira o código para verificar
5. Teste enviando uma mensagem

---

### Parte 2: Gerar Token Permanente (20 min)

⚠️ **IMPORTANTE:** O token temporário expira em 24-72h. Você precisa de um token permanente!

#### 1. Acessar Meta Business Suite

1. Acesse: https://business.facebook.com/
2. Selecione sua conta de negócio
3. Vá em **Settings** (⚙️) → **Business Settings**

#### 2. Criar System User

1. No menu lateral, vá em **Users** → **System Users**
2. Clique em **"Add"**
3. Preencha:
   - **System User Name**: `n8n-devops-bot`
   - **System User Role**: **Admin**
4. Clique em **"Create System User"**

#### 3. Atribuir Assets

1. Clique no System User criado
2. Clique em **"Add Assets"**
3. Selecione **"Apps"**
4. Marque seu app (`n8n DevOps Bot`)
5. Permissões: **Full Control**
6. Clique em **"Save Changes"**

#### 4. Gerar Token Permanente

1. Ainda no System User, clique em **"Generate New Token"**
2. Selecione o app: `n8n DevOps Bot`
3. Marque as permissões:
   - ✅ `whatsapp_business_messaging`
   - ✅ `whatsapp_business_management`
4. **Token Expiration**: Selecione **"Never"** (60 dias ou Never)
5. Clique em **"Generate Token"**
6. **COPIE E SALVE O TOKEN IMEDIATAMENTE** (não será mostrado novamente!)

```bash
# Salve este token em local seguro:
WHATSAPP_ACCESS_TOKEN=EAAxxxxxxxxxxxxx
```

---

### Parte 3: Configurar Webhook (15 min)

#### 1. Preparar Variáveis de Ambiente

Edite o arquivo `.env` no servidor:

```bash
# WhatsApp Meta API Configuration
WHATSAPP_PHONE_NUMBER_ID=seu_phone_number_id_aqui
WHATSAPP_BUSINESS_ACCOUNT_ID=seu_business_account_id_aqui
WHATSAPP_ACCESS_TOKEN=EAAxxxxxxxxxxxxx
WHATSAPP_VERIFY_TOKEN=n8n_meta_verify_2024
WHATSAPP_API_VERSION=v21.0

# Seu domínio público (substitua pelo seu)
WEBHOOK_PUBLIC_URL=https://seu-dominio.com
```

#### 2. Atualizar Docker Compose

Adicione as variáveis ao serviço n8n no `docker-compose.yml`:

```yaml
n8n:
  environment:
    # ... outras variáveis ...
    WHATSAPP_PHONE_NUMBER_ID: ${WHATSAPP_PHONE_NUMBER_ID}
    WHATSAPP_BUSINESS_ACCOUNT_ID: ${WHATSAPP_BUSINESS_ACCOUNT_ID}
    WHATSAPP_ACCESS_TOKEN: ${WHATSAPP_ACCESS_TOKEN}
    WHATSAPP_VERIFY_TOKEN: ${WHATSAPP_VERIFY_TOKEN}
    WHATSAPP_API_VERSION: ${WHATSAPP_API_VERSION}
    WEBHOOK_PUBLIC_URL: ${WEBHOOK_PUBLIC_URL}
```

#### 3. Restart n8n

```bash
cd /home/fabioleal/n8n
docker-compose restart n8n
```

#### 4. Configurar Webhook na Meta

1. Volte ao **Meta for Developers**
2. Vá em **WhatsApp** → **Configuration**
3. Em **Webhook**, clique em **"Edit"**

Preencha:
```
Callback URL: https://SEU_DOMINIO/webhook/whatsapp-meta
Verify Token: n8n_meta_verify_2024
```

4. Clique em **"Verify and Save"**

⚠️ **Se der erro:**
- Verifique se o workflow está ATIVO no n8n
- Confirme que a URL é HTTPS
- Teste manualmente: `curl https://SEU_DOMINIO/webhook/whatsapp-meta`

#### 5. Subscribe to Webhooks

1. Ainda em **Configuration**, role até **"Webhook fields"**
2. Clique em **"Manage"**
3. Marque: ✅ **messages**
4. Clique em **"Save"**

---

### Parte 4: Configurar n8n (20 min)

#### 1. Criar Credencial Meta API

1. Acesse n8n: http://seu-servidor:5678
2. Vá em **Credentials** → **Add Credential**
3. Busque por **"HTTP Header Auth"** ou **"Generic Credential Type"**
4. Crie uma credencial chamada **"Meta API"**:

```
Name: Meta API
Type: Header Auth
Header Name: Authorization
Header Value: Bearer SEU_ACCESS_TOKEN_AQUI
```

#### 2. Criar Credencial Google Gemini

1. **Credentials** → **Add Credential**
2. Busque por **"Google Gemini"**
3. Configure OAuth2 ou API Key
4. Nome: `Google Gemini Account`

#### 3. Importar Workflow

1. Vá em **Workflows** → **Import from File**
2. Selecione: `workflows/whatsapp-ai-agent-meta.json`
3. Clique em **"Import"**

#### 4. Configurar Workflow

Abra o workflow importado e configure:

**Node "Send WhatsApp":**
- Credential: Selecione **"Meta API"** criada

**Node "Google Gemini":**
- Credential: Selecione **"Google Gemini Account"**

**Nodes de AWS Cost (5 nodes):**
- Cada um precisa do **Workflow ID** correspondente
- Para obter o ID:
  1. Abra cada workflow de AWS Cost
  2. Copie o ID da URL (ex: `123`)
  3. Cole no campo `workflowId`

Exemplo:
```
AWS Cost - Aciol → workflowId: 123
AWS Cost - DS2 → workflowId: 124
AWS Cost - Fabiana → workflowId: 125
AWS Cost - KLM → workflowId: 126
AWS Cost - Soluzione → workflowId: 127
```

#### 5. Ativar Workflow

1. Clique no toggle **"Active"** no canto superior direito
2. Deve ficar verde ✅

---

### Parte 5: Testar (15 min)

#### Teste 1: Verificação do Webhook

```bash
# Execute no terminal:
./test-meta-webhook.sh verify
```

Ou manualmente:
```bash
curl "https://SEU_DOMINIO/webhook/whatsapp-meta?hub.mode=subscribe&hub.verify_token=n8n_meta_verify_2024&hub.challenge=12345"
```

**Esperado:** Retorna `12345`

#### Teste 2: Enviar Mensagem

1. Abra WhatsApp no celular
2. Envie mensagem para o número configurado na Meta
3. Mensagem: `Olá`

**Esperado:**
- Bot responde com saudação
- Logs do n8n mostram execução

#### Teste 3: Consulta AWS

Envie: `Quanto gastei na AWS esse mês?`

**Esperado:**
- Bot consulta AWS Cost Explorer
- Retorna relatório formatado

#### Teste 4: Conta Específica

Envie: `Custos da conta aciol`

**Esperado:**
- Bot usa tool específico da conta aciol
- Retorna custos dessa conta

---

## 🔍 Troubleshooting

### Webhook não verifica

**Sintomas:** Erro ao salvar webhook na Meta

**Soluções:**
1. Verifique se workflow está ATIVO
2. Confirme URL é HTTPS válido
3. Teste manualmente:
   ```bash
   curl -v "https://SEU_DOMINIO/webhook/whatsapp-meta?hub.mode=subscribe&hub.verify_token=n8n_meta_verify_2024&hub.challenge=test"
   ```
4. Verifique logs do n8n:
   ```bash
   docker logs -f n8n
   ```

### Mensagens não chegam no n8n

**Sintomas:** Envia mensagem mas n8n não recebe

**Soluções:**
1. Verifique subscription em **Webhook fields**
2. Confirme Phone Number ID correto
3. Teste webhook manualmente:
   ```bash
   ./test-meta-webhook.sh message
   ```

### Erro 401 ao enviar mensagem

**Sintomas:** Bot recebe mas não responde

**Soluções:**
1. Token expirado → Gere novo System User Token
2. Atualize credencial "Meta API" no n8n
3. Verifique variável `WHATSAPP_ACCESS_TOKEN` no `.env`

### Erro 403 (Forbidden)

**Sintomas:** Permissão negada

**Soluções:**
1. Verifique permissões do System User
2. Confirme token tem `whatsapp_business_messaging`
3. Re-gere token com permissões corretas

### Bot não usa ferramentas AWS

**Sintomas:** Bot responde mas não consulta AWS

**Soluções:**
1. Verifique Workflow IDs dos tools
2. Confirme workflows AWS estão ativos
3. Teste tools individualmente
4. Verifique credenciais AWS no n8n

---

## 📚 Próximos Passos

Após configuração completa:

1. ✅ Testar todos os casos de uso
2. ✅ Documentar números e contas
3. ✅ Configurar monitoramento
4. ✅ Desativar WAHA (se tudo funcionar)
5. ✅ Atualizar README.md

---

## 🔗 Links Úteis

- [Meta for Developers](https://developers.facebook.com/)
- [WhatsApp Business API Docs](https://developers.facebook.com/docs/whatsapp/cloud-api)
- [Meta Business Suite](https://business.facebook.com/)
- [API Reference](https://developers.facebook.com/docs/whatsapp/cloud-api/reference)
