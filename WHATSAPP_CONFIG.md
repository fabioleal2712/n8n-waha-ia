# Configuração do Webhook WhatsApp

Você perguntou sobre a URL: `https://n8n.fabioleal.com.br/webhook-test/whatsapp-webhook`

## ⚠️ Importante: Teste vs Produção

O n8n tem duas URLs diferentes para webhooks:

1. **URL de Teste** (`/webhook-test/...`)
   - Use quando estiver **criando/editando** o workflow.
   - Você precisa clicar em "Execute Workflow" no n8n para ele funcionar.
   - Serve para debugar e ver os dados chegando.

2. **URL de Produção** (`/webhook/...`)
   - Use quando o workflow estiver **pronto e ativado**.
   - Funciona 24/7 sem precisar estar com o n8n aberto.
   - **Use esta URL na configuração final do seu WhatsApp.**

---

## Onde Configurar?

Como vi que você tem um container `wpconnect-server` rodando, provavelmente está usando o **WPPConnect**.

### Opção 1: WPPConnect Server (Via API)

Se você usa o WPPConnect Server, você define o webhook ao iniciar a sessão ou via rota de configuração.

**Exemplo de chamada para configurar webhook:**

```bash
curl -X POST http://10.30.0.50:21465/api/my-session/webhook \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer SEU_TOKEN_WPPCONNECT" \
  -d '{
    "url": "https://n8n.fabioleal.com.br/webhook/whatsapp-webhook",
    "enabled": true
  }'
```

*(Substitua `my-session` pelo nome da sua sessão e a porta `21465` pela porta do seu WPPConnect)*

### Opção 2: WPPConnect (Arquivo de Configuração)

Se você roda via docker-compose, verifique o arquivo `.env` ou `config.js` do projeto WPPConnect:

```env
# No arquivo .env do WPPConnect
WEBHOOK_URL=https://n8n.fabioleal.com.br/webhook/whatsapp-webhook
```

### Opção 3: API Oficial (Meta/Facebook)

Se estiver usando a API oficial:
1. Acesse [developers.facebook.com](https://developers.facebook.com)
2. Vá em **WhatsApp** > **Configuration**
3. Em **Webhook**, clique em **Edit**
4. Coloque a URL: `https://n8n.fabioleal.com.br/webhook/whatsapp-webhook`
5. Coloque o Token de Verificação (se configurado no n8n)

---

## Como Testar Agora?

1. No n8n, abra o workflow "WhatsApp AI AWS Assistant".
2. Clique no nó **Webhook**.
3. Veja que ele tem duas URLs (Test e Production).
4. Clique em **"Execute Workflow"**.
5. Agora envie uma mensagem para o seu WhatsApp conectado.
6. Se o webhook estiver configurado corretamente no WPPConnect, você verá os dados aparecerem no n8n!

## Resumo

Para configurar no seu sistema de WhatsApp, use a URL de **Produção**:
👉 `https://n8n.fabioleal.com.br/webhook/whatsapp-webhook`
