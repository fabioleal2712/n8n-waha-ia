# Configuração do AI Agent (WhatsApp + AWS)

Este setup usa um **Agente de IA** avançado que pode conversar e usar ferramentas.

## 1. Configurar a Ferramenta (Tool)

1. Abra o workflow **"Tool - AWS Cost"**
2. Configure a credencial da **AWS** no nó "AWS Cost Explorer"
3. Salve o workflow
4. **Copie o ID** deste workflow (está na URL, ex: `.../workflow/BwX...`) ou memorize o nome.

## 2. Configurar o Agente

1. Abra o workflow **"WhatsApp AI Agent (Advanced)"**
2. Configure a credencial da **OpenAI** no nó "OpenAI Chat Model"
3. Clique no nó **"AWS Cost Tool"**
4. Em **Workflow ID**, selecione "Tool - AWS Cost" (ou cole o ID)
5. Salve e Ative!

## 3. Configurar Webhook

Use a URL deste novo workflow no seu WhatsApp:
`https://n8n.fabioleal.com.br/webhook/whatsapp-agent`

## Como Testar

Envie mensagens no WhatsApp como:
- "Olá, quem é você?" (O agente vai responder usando a memória)
- "Quanto gastei na AWS mês passado?" (O agente vai usar a ferramenta AWS)
- "Quais serviços estão gastando mais?" (O agente vai analisar os dados)

## Diferença para o anterior

- **Anterior**: Fluxo rígido (Se perguntar X -> Faz Y).
- **AI Agent**: Fluxo dinâmico. Ele decide se precisa chamar a AWS ou só conversar. Ele lembra do contexto ("E no mês anterior?").
