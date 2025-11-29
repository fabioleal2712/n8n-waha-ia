# Acessando n8n Remotamente

## Problema

O n8n está rodando no servidor `10.30.0.50`, mas você quer acessá-lo do seu **notebook local** que está em outra rede.

## Solução: SSH Tunnel

Use um túnel SSH para "trazer" o n8n remoto para o seu localhost.

### Método 1: Script Automático (Recomendado)

```bash
cd /home/fabioleal/github/n8n
./n8n-tunnel.sh
```

Depois acesse no navegador: **http://localhost:5678**

### Método 2: Comando Manual

```bash
ssh -i ~/key_client/keybinario -L 5678:localhost:5678 -N fabioleal@10.30.0.50
```

Depois acesse no navegador: **http://localhost:5678**

### Método 3: Configuração SSH Permanente

Adicione ao seu `~/.ssh/config`:

```
Host n8n-server
    HostName 10.30.0.50
    User fabioleal
    IdentityFile ~/key_client/keybinario
    LocalForward 5678 localhost:5678
```

Depois execute:
```bash
ssh n8n-server
```

E acesse: **http://localhost:5678**

## Como Funciona

```
[Seu Notebook] --SSH--> [Servidor 10.30.0.50]
     ↓                           ↓
localhost:5678 ←--tunnel-→ localhost:5678 (n8n)
```

O túnel SSH cria uma "ponte" segura entre seu notebook e o servidor, fazendo parecer que o n8n está rodando localmente.

## Credenciais

- **URL**: http://localhost:5678
- **Usuário**: admin
- **Senha**: admin123

> ⚠️ **IMPORTANTE**: Altere a senha após o primeiro login!

## Manter o Túnel Ativo

O túnel SSH precisa ficar rodando enquanto você usa o n8n. Se você fechar o terminal, o túnel será encerrado.

**Para rodar em background:**

```bash
ssh -i ~/key_client/keybinario -L 5678:localhost:5678 -N -f fabioleal@10.30.0.50
```

**Para encerrar o túnel em background:**

```bash
# Encontrar o processo
ps aux | grep "ssh.*5678"

# Matar o processo (substitua PID pelo número encontrado)
kill PID
```

## Alternativa: Acesso Direto (Requer Configuração de Rede)

Se você quiser acessar diretamente via `http://10.30.0.50:5678` sem túnel SSH, você precisaria:

1. **VPN**: Conectar-se à mesma rede do servidor via VPN
2. **Reverse Proxy**: Configurar nginx/traefik com domínio público
3. **Cloudflare Tunnel**: Expor o n8n via Cloudflare

Para a maioria dos casos, o **SSH Tunnel é a solução mais simples e segura**.

## Troubleshooting

### Erro: "bind: Address already in use"

A porta 5678 já está em uso no seu notebook local.

**Solução 1**: Use outra porta local
```bash
ssh -i ~/key_client/keybinario -L 8080:localhost:5678 -N fabioleal@10.30.0.50
```
Acesse: http://localhost:8080

**Solução 2**: Pare o n8n local
```bash
docker stop n8n
docker rm n8n
```

### Erro: "Connection refused"

O servidor não está acessível.

**Verificar**:
```bash
ping 10.30.0.50
ssh -i ~/key_client/keybinario fabioleal@10.30.0.50 "docker ps | grep n8n"
```

### Túnel desconecta frequentemente

Adicione keep-alive:
```bash
ssh -i ~/key_client/keybinario \
    -L 5678:localhost:5678 \
    -N \
    -o ServerAliveInterval=60 \
    -o ServerAliveCountMax=3 \
    fabioleal@10.30.0.50
```

## Comparação: Local vs Remoto

| Aspecto | n8n Local | n8n Remoto (via SSH Tunnel) |
|---------|-----------|----------------------------|
| **Acesso** | http://localhost:5678 | http://localhost:5678 |
| **Dados** | No seu notebook | No servidor (persistente) |
| **Performance** | Depende do notebook | Depende do servidor |
| **Disponibilidade** | Só quando notebook ligado | 24/7 no servidor |
| **Webhooks** | Difícil de receber | Servidor pode receber |
| **Backup** | Manual | Pode ser automatizado |

## Recomendação

Para **desenvolvimento/testes**: Use n8n local
Para **produção/workflows importantes**: Use n8n remoto com SSH tunnel para acesso
