# n8n Docker & Ansible Setup

Configuração completa do n8n rodando em Docker com provisionamento de workflows via Ansible e integração WhatsApp usando **WAHA** (WhatsApp HTTP API).

## 📋 Pré-requisitos

- Ansible instalado na máquina local
- Acesso SSH ao servidor (10.30.0.50)
- Chave SSH em `~/key_client/keybinario`
- Docker e Docker Compose no servidor

## 🚀 Quick Start

### Deploy Completo

Para fazer deploy completo da solução WAHA + n8n:

📖 **Veja o guia completo**: [DEPLOYMENT.md](DEPLOYMENT.md)

**Resumo rápido:**
```bash
# 1. Deploy n8n
./n8n-manage.sh deploy

# 2. Iniciar WAHA
docker-compose up -d waha

# 3. Conectar WhatsApp
./waha-manage.sh start
./waha-manage.sh qr

# 4. Importar workflow no n8n
# Acesse http://10.30.0.50:5678 e importe workflows/whatsapp-ai-agent-native.json
```

### Usando o Script de Gerenciamento n8n

O script `n8n-manage.sh` facilita todas as operações:

```bash
# Testar conectividade
./n8n-manage.sh ping

# Deploy completo do n8n
./n8n-manage.sh deploy

# Provisionar workflows
./n8n-manage.sh workflows

# Ver logs em tempo real
./n8n-manage.sh logs

# Ver status dos containers
./n8n-manage.sh status

# Ver todos os comandos disponíveis
./n8n-manage.sh help
```

### Usando Ansible Diretamente

#### 1. Testar Conectividade

```bash
ansible -i ansible/inventory.yml all -m ping
```

### 2. Deploy do n8n

```bash
ansible-playbook -i ansible/inventory.yml ansible/playbook-deploy-n8n.yml
```

Este playbook irá:
- ✅ Instalar Docker (se necessário)
- ✅ Criar diretório de instalação
- ✅ Copiar arquivos de configuração
- ✅ Iniciar n8n e PostgreSQL
- ✅ Verificar saúde dos containers

### 3. Copiar Workflows para o Servidor

```bash
# Usando o script
./n8n-manage.sh workflows

# OU usando Ansible
ansible-playbook -i ansible/inventory.yml ansible/playbook-copy-workflows.yml
```

Este playbook irá:
- ✅ Criar diretório de workflows no servidor
- ✅ Copiar todos os workflows da pasta `workflows/`
- ✅ Exibir instruções de importação

## 🔐 Acesso ao n8n

### Acesso Direto (Mesma Rede)

Se você está na **mesma rede** que o servidor:

- **URL**: http://10.30.0.50:5678
- **Usuário**: admin
- **Senha**: admin123

### Acesso Remoto (SSH Tunnel)

Se você está acessando de **outro local/rede** (ex: notebook em casa):

```bash
# Método 1: Script automático
./n8n-tunnel.sh

# Método 2: Comando manual
ssh -i ~/key_client/keybinario -L 5678:localhost:5678 -N fabioleal@10.30.0.50
```

Depois acesse: **http://localhost:5678**

📖 **Guia completo**: Veja [REMOTE_ACCESS.md](REMOTE_ACCESS.md) para mais opções

> ⚠️ **IMPORTANTE**: Altere a senha padrão após o primeiro login!

## 📁 Estrutura do Projeto

```
.
├── docker-compose.yml              # Configuração Docker (n8n + PostgreSQL + WAHA)
├── .env.example                    # Variáveis de ambiente exemplo
├── n8n-manage.sh                   # Script de gerenciamento n8n
├── waha-manage.sh                  # Script de gerenciamento WAHA
├── WAHA_QUICKSTART.md              # Guia rápido WAHA
├── WAHA_MIGRATION.md               # Guia de migração WPPConnect → WAHA
├── ansible/
│   ├── inventory.yml              # Inventário Ansible
│   ├── playbook-deploy-n8n.yml    # Playbook de deploy
│   ├── playbook-copy-workflows.yml    # Playbook para copiar workflows
│   └── playbook-nginx.yml         # Configuração Nginx
├── workflows/
│   ├── whatsapp-ai-agent.json     # AI Agent WhatsApp (WAHA)
│   ├── tool-aws-cost.json         # Ferramenta AWS Cost Explorer
│   └── whatsapp-gateway.json      # Gateway WhatsApp
└── README.md
```

## 📱 WhatsApp com WAHA

Este projeto usa **WAHA** (WhatsApp HTTP API) - uma solução gratuita e open-source.

### Quick Start WAHA

```bash
# Iniciar WAHA
docker-compose up -d waha

# Conectar WhatsApp
./waha-manage.sh start
./waha-manage.sh qr  # Escanear QR code

# Verificar status
./waha-manage.sh status
```

📖 **Guia completo**: Veja [WAHA_QUICKSTART.md](WAHA_QUICKSTART.md)


## 🔧 Configuração

### Alterar Porta do n8n

Edite `docker-compose.yml`:
```yaml
ports:
  - "SUA_PORTA:5678"
```

E `ansible/inventory.yml`:
```yaml
n8n_port: SUA_PORTA
```

### Alterar Credenciais

Edite `docker-compose.yml`:
```yaml
N8N_BASIC_AUTH_USER: seu_usuario
N8N_BASIC_AUTH_PASSWORD: sua_senha
```

E `ansible/inventory.yml`:
```yaml
n8n_user: seu_usuario
n8n_password: sua_senha
```

### Configurar Webhook URL Externa

Se você tem um domínio ou IP público, edite `docker-compose.yml`:
```yaml
WEBHOOK_URL: https://seu-dominio.com/
```

## 📝 Workflows

### Adicionar Novos Workflows

**Método 1: Via Interface Web (Recomendado)**
1. Acesse http://10.30.0.50:5678
2. Faça login (admin/admin123)
3. Clique em "Workflows" > "Import from File"
4. Selecione o arquivo JSON do workflow

**Método 2: Via Ansible**
1. Crie ou exporte workflows do n8n como JSON
2. Coloque os arquivos na pasta `workflows/`
3. Execute: `./n8n-manage.sh workflows`
4. Importe manualmente via interface web

**Método 3: Via CLI do n8n**
```bash
ssh -i ~/key_client/keybinario fabioleal@10.30.0.50
cd /home/fabioleal/n8n
docker-compose exec n8n n8n import:workflow --input=/home/fabioleal/n8n/workflows/example-webhook.json
```

### Workflows Incluídos

#### 1. Example Webhook (`example-webhook.json`)
- **Trigger**: Webhook HTTP POST
- **URL**: http://10.30.0.50:5678/webhook/example-webhook
- **Função**: Recebe dados via webhook, processa e retorna resposta

**Teste**:
```bash
curl -X POST http://10.30.0.50:5678/webhook/example-webhook \
  -H "Content-Type: application/json" \
  -d '{"test": "data", "message": "Hello n8n"}'
```

#### 2. Scheduled Task (`scheduled-task.json`)
- **Trigger**: Agendamento (a cada 1 hora)
- **Função**: Executa tarefa periódica e registra logs
- **Status**: Inativo por padrão (ative manualmente na interface)

## 🐳 Comandos Docker Úteis

### Ver logs do n8n
```bash
ssh -i ~/key_client/keybinario fabioleal@10.30.0.50 "docker logs -f n8n"
```

### Ver logs do PostgreSQL
```bash
ssh -i ~/key_client/keybinario fabioleal@10.30.0.50 "docker logs -f n8n_postgres"
```

### Reiniciar n8n
```bash
ssh -i ~/key_client/keybinario fabioleal@10.30.0.50 "cd /home/fabioleal/n8n && docker-compose restart n8n"
```

### Parar todos os serviços
```bash
ssh -i ~/key_client/keybinario fabioleal@10.30.0.50 "cd /home/fabioleal/n8n && docker-compose down"
```

### Iniciar todos os serviços
```bash
ssh -i ~/key_client/keybinario fabioleal@10.30.0.50 "cd /home/fabioleal/n8n && docker-compose up -d"
```

## 🔍 Troubleshooting

### n8n não inicia

1. Verifique logs:
   ```bash
   ssh -i ~/key_client/keybinario fabioleal@10.30.0.50 "docker logs n8n"
   ```

2. Verifique se o PostgreSQL está saudável:
   ```bash
   ssh -i ~/key_client/keybinario fabioleal@10.30.0.50 "docker ps"
   ```

### Workflows não importam

1. Verifique se o n8n está acessível:
   ```bash
   curl http://10.30.0.50:5678/healthz
   ```

2. Verifique credenciais no `ansible/inventory.yml`

### Erro de conexão SSH

Verifique se a chave SSH tem as permissões corretas:
```bash
chmod 600 ~/key_client/keybinario
```

## 📚 Recursos

- [Documentação oficial do n8n](https://docs.n8n.io/)
- [n8n Community](https://community.n8n.io/)
- [Workflow Templates](https://n8n.io/workflows/)

## 🔄 Backup e Restore

### Backup dos dados

```bash
ssh -i ~/key_client/keybinario fabioleal@10.30.0.50 \
  "cd /home/fabioleal/n8n && docker-compose exec -T postgres pg_dump -U n8n n8n > backup_$(date +%Y%m%d).sql"
```

### Restore dos dados

```bash
cat backup.sql | ssh -i ~/key_client/keybinario fabioleal@10.30.0.50 \
  "cd /home/fabioleal/n8n && docker-compose exec -T postgres psql -U n8n n8n"
```

## 📄 Licença

Este projeto é fornecido como está, para uso pessoal e educacional.
# n8n-waha-ia
