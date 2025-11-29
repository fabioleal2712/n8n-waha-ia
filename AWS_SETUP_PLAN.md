# Plano de Configuração AWS e Memória

## 1. Memória do Agente (Já Configurada ✅)
Você perguntou se precisa configurar algo na memória. **A resposta é: Não.**

Já deixei configurado para você:
- **Tipo:** Window Buffer Memory
- **Capacidade:** Lembra das últimas 10 mensagens.
- **Sessão:** Usa o número do telefone (`sender`) como chave. Isso significa que o bot lembra da conversa de cada pessoa separadamente.

---

## 2. Configuração da AWS (Necessário ⚠️)

Para o agente consultar custos, você precisa configurar as credenciais no n8n.

### Passo 1: Criar Usuário na AWS (IAM) com Permissão Mínima
1. Acesse o console da AWS > **IAM**.
2. Vá em **Policies** > **Create policy**.
3. Clique na aba **JSON**.
4. Cole o conteúdo do arquivo `aws-policy.json` (que criei para você).
   - *Essa política dá acesso APENAS à leitura de custos.*
5. Dê um nome, ex: `N8NCostRead`.
   - *Descrição (sem acentos):* `Read only access to Cost Explorer`
6. Crie a política.

Agora crie o usuário:
1. Vá em **Users** > **Create user** (ex: `n8n-bot`).
2. Selecione **"Attach policies directly"**.
3. Procure e selecione a política `N8NCostRead` que você criou.
4. Finalize e crie uma **Access Key** para este usuário.

### Passo 2: Configurar no n8n
1. Acesse seu n8n: https://n8n.fabioleal.com.br
2. Vá em **Credentials** > **Add Credential**.
3. Procure por **AWS**.
4. Preencha:
   - **Access Key ID**: (Sua chave)
   - **Secret Access Key**: (Sua secret)
   - **Region**: `us-east-1` (ou a região que você usa, mas Cost Explorer é global/us-east-1).
5. Clique em **Save**.

### Passo 3: Conectar no Workflow
1. Abra o workflow **"Tool - AWS Cost"**.
2. Clique no nó **"AWS Cost Explorer"**.
3. Em **Credential**, selecione a credencial AWS que você acabou de criar.
4. Salve o workflow.

---

## 3. Como Testar

1. Abra o workflow **"Tool - AWS Cost"**.
2. Clique em **"Execute Workflow"**.
   - *Nota: Pode dar erro se não tiver input, mas você pode clicar no "+" do nó AWS e "Execute Node" para testar a conexão.*
3. Se der sucesso, ele vai retornar um JSON com os custos.

Depois disso, vá no WhatsApp e pergunte:
> "Quanto gastei na AWS este mês?"

O Agente deve responder com o valor! 🚀
