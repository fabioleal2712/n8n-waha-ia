# Configuração de Envio WhatsApp (WPPConnect)

Atualizei o workflow para usar a API do WPPConnect para enviar mensagens.

## Passos para Configurar

1. Abra o workflow **"WhatsApp AI Agent (Advanced)"**
2. Clique no nó **"Send WhatsApp (API)"** (é o último nó)
3. Você precisa atualizar a **URL** e o **Token**:

### 1. URL
Substitua `SESSAO` pelo nome da sua sessão no WPPConnect.
Exemplo:
`http://10.30.0.50:21465/api/minha-sessao/send-message`

### 2. Token
Em **Header Parameters** > **Authorization**, substitua `SEU_TOKEN` pelo token da sessão.
Exemplo:
`Bearer $2b$10$J8...`

## Como obter o Token?
Se você não tem o token, pode gerá-lo no WPPConnect:
```bash
curl -X POST http://10.30.0.50:21465/api/minha-sessao/generate-token \
  -H "Content-Type: application/json" \
  -d '{"secret": "sua-secret-key"}'
```

## Testando
1. Ative o workflow
2. Envie uma mensagem no WhatsApp
3. O n8n deve processar e enviar a resposta via API!
