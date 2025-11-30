# Guia de Migração: WAHA → WhatsApp Business Cloud API

## Por que migrar?

- ✅ **Oficial e Estável**: API oficial da Meta/Facebook
- ✅ **Sem Banimento**: Menor risco de bloqueio
- ✅ **Recursos Avançados**: Templates, botões, mídia rica
- ✅ **Suporte Oficial**: Documentação e suporte da Meta
- ✅ **Escalável**: Suporta múltiplos números e contas

## Pré-requisitos

1. Conta Meta Business (Facebook Business Manager)
2. App criado no Meta for Developers
3. Número de telefone verificado
4. Domínio público com HTTPS (para webhook)

## Passo 1: Configurar na Meta

### 1.1 Criar App
1. Acesse https://developers.facebook.com/
2. Crie um novo app ou use existente
3. Adicione o produto **WhatsApp**

### 1.2 Obter Credenciais
1. Vá em **WhatsApp** → **API Setup**
2. Anote:
   - **Phone Number ID**
   - **WhatsApp Business Account ID**
   - **Temporary Access Token** (para testes)

### 1.3 Gerar Token Permanente
1. Meta Business Suite → Settings → System Users
2. Create System User (nome: `n8n-bot`)
3. Assign Assets → WhatsApp Business Account
4. Generate Token:
   - Permissions: `whatsapp_business_messaging`, `whatsapp_business_management`
   - Expiration: Never
5. Salve o token em local seguro

### 1.4 Configurar Webhook
1. No app, vá em **WhatsApp** → **Configuration**
2. Edit webhook:
   - **Callback URL**: `https://seu-dominio.com/webhook/whatsapp-meta`
   - **Verify Token**: crie um token customizado (ex: `n8n_verify_2024`)
3. Subscribe to: `messages`

## Passo 2: Configurar n8n

### 2.1 Atualizar .env
```bash
# WhatsApp Business Cloud API
WHATSAPP_PHONE_NUMBER_ID=123456789
WHATSAPP_BUSINESS_ACCOUNT_ID=987654321
WHATSAPP_ACCESS_TOKEN=EAAxxxxxxxxxxxxx
WHATSAPP_VERIFY_TOKEN=n8n_verify_2024
```

### 2.2 Criar Credencial no n8n
1. n8n → Credentials → Add Credential
2. Tipo: **Header Auth**
3. Nome: `WhatsApp Business API Token`
4. Header Name: `Authorization`
5. Header Value: `Bearer ${WHATSAPP_ACCESS_TOKEN}`

### 2.3 Importar Workflow
1. Importe `whatsapp-ai-agent-meta-api.json`
2. Configure as credenciais
3. Ative o workflow

### 2.4 Configurar Webhook Verification
Adicione um node de verificação no início do workflow:

```javascript
// No node "WhatsApp Webhook (Meta)"
// Adicione este código no "Pre-Webhook" script:

if ($request.query['hub.mode'] === 'subscribe' && 
    $request.query['hub.verify_token'] === process.env.WHATSAPP_VERIFY_TOKEN) {
  return {
    status: 200,
    body: parseInt($request.query['hub.challenge'])
  };
}
```

## Passo 3: Testar

### 3.1 Verificar Webhook
1. Na Meta, clique em **Verify** no webhook
2. Deve retornar sucesso

### 3.2 Enviar Mensagem de Teste
1. Envie uma mensagem para o número WhatsApp
2. Verifique se o n8n recebe o webhook
3. Confirme se a resposta é enviada

## Passo 4: Migração Gradual

### Opção A: Migração Imediata
1. Desative o workflow WAHA
2. Ative o workflow Meta API
3. Atualize o webhook no WAHA (se ainda usar)

### Opção B: Migração Gradual
1. Mantenha ambos ativos
2. Use números diferentes para cada um
3. Migre usuários aos poucos

## Diferenças Importantes

| Recurso | WAHA | Meta API |
|---------|------|----------|
| **Custo** | Grátis | Grátis (1000 conversas/mês) |
| **Estabilidade** | ⚠️ Médio | ✅ Alta |
| **Risco Banimento** | ⚠️ Alto | ✅ Baixo |
| **Recursos** | Básico | ✅ Avançado |
| **Suporte** | Comunidade | ✅ Oficial |
| **Setup** | Simples | Médio |

## Limitações da Meta API

- ❌ Precisa de domínio público com HTTPS
- ❌ Número deve ser verificado pela Meta
- ❌ Limite de 1000 conversas gratuitas/mês
- ❌ Após 24h, precisa usar templates aprovados

## Custos (após free tier)

- Conversas de negócio: $0.005 - $0.09 por conversa
- Conversas de utilidade: $0.003 - $0.06 por conversa
- Conversas de autenticação: $0.001 - $0.04 por conversa

**Estimativa para 100 conversas/dia:**
- Mês: 3000 conversas
- Custo: ~$15 - $30/mês (após 1000 gratuitas)

## Troubleshooting

### Webhook não recebe mensagens
- Verifique se o webhook está verificado na Meta
- Confirme que a URL é HTTPS
- Teste com `curl` manualmente

### Erro 401 (Unauthorized)
- Token expirado ou inválido
- Regenere o System User Token

### Erro 403 (Forbidden)
- Permissões insuficientes
- Adicione `whatsapp_business_messaging` ao token

## Próximos Passos

1. ✅ Configurar templates de mensagem
2. ✅ Adicionar botões interativos
3. ✅ Implementar envio de mídia (imagens, PDFs)
4. ✅ Configurar respostas rápidas
5. ✅ Integrar com CRM

## Recursos

- [Documentação Oficial](https://developers.facebook.com/docs/whatsapp/cloud-api)
- [API Reference](https://developers.facebook.com/docs/whatsapp/cloud-api/reference)
- [Webhooks](https://developers.facebook.com/docs/whatsapp/cloud-api/webhooks)
