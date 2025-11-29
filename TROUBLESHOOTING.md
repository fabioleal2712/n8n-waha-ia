# n8n Troubleshooting Guide

## Problema: "Error connecting to n8n - Could not connect to server"

### Soluções Aplicadas

✅ **Configuração Atualizada**
Adicionadas as seguintes variáveis de ambiente ao `docker-compose.yml`:
```yaml
N8N_HOST: 10.30.0.50
N8N_PORT: 5678
N8N_PROTOCOL: http
```

✅ **Container Recriado**
O n8n foi recriado com as novas configurações.

### Verificações

1. **Status dos Containers**
   ```bash
   ./n8n-manage.sh status
   ```
   Ambos devem estar "healthy"

2. **Logs do n8n**
   ```bash
   ./n8n-manage.sh logs
   ```
   Deve mostrar: "Editor is now accessible via: http://10.30.0.50:5678"

3. **Teste de Conectividade**
   ```bash
   curl -I http://10.30.0.50:5678
   ```
   Deve retornar: HTTP/1.1 200 OK

### Possíveis Causas do Erro

#### 1. Cache do Navegador
**Solução:**
- Pressione `Ctrl + Shift + R` (ou `Cmd + Shift + R` no Mac) para recarregar sem cache
- Ou abra em uma aba anônima/privada

#### 2. Problema de Rede Local
**Verificar:**
```bash
ping 10.30.0.50
```
Se não responder, verifique sua conexão com a rede onde o servidor está.

#### 3. Firewall Local
**Verificar:**
- Desative temporariamente o firewall do seu computador
- Ou adicione exceção para a porta 5678

#### 4. Proxy ou VPN
**Solução:**
- Desative proxy/VPN temporariamente
- Ou configure exceção para 10.30.0.50

#### 5. DNS/Hosts
Se estiver usando um nome de domínio em vez de IP:
```bash
# Verificar resolução DNS
nslookup seu-dominio.com

# Ou adicionar ao /etc/hosts (Linux/Mac) ou C:\Windows\System32\drivers\etc\hosts (Windows)
10.30.0.50  n8n.local
```

### Comandos Úteis de Diagnóstico

```bash
# Ver logs em tempo real
./n8n-manage.sh logs

# Reiniciar n8n
./n8n-manage.sh restart

# Verificar conectividade HTTP
curl -v http://10.30.0.50:5678

# Verificar se a porta está aberta
nc -zv 10.30.0.50 5678

# Verificar rota de rede
ip route get 10.30.0.50
```

### Se Nada Funcionar

1. **Reiniciar completamente**
   ```bash
   ./n8n-manage.sh stop
   sleep 5
   ./n8n-manage.sh start
   ```

2. **Verificar logs detalhados**
   ```bash
   ssh -i ~/key_client/keybinario fabioleal@10.30.0.50 "docker logs n8n --tail=100"
   ```

3. **Acessar via SSH tunnel** (solução temporária)
   ```bash
   ssh -i ~/key_client/keybinario -L 5678:localhost:5678 fabioleal@10.30.0.50
   ```
   Depois acesse: http://localhost:5678

### Configurações Adicionais (Opcional)

Se você tiver um domínio ou quiser usar HTTPS:

```yaml
# docker-compose.yml
environment:
  N8N_HOST: seu-dominio.com
  N8N_PROTOCOL: https
  WEBHOOK_URL: https://seu-dominio.com/
```

Depois execute:
```bash
./n8n-manage.sh deploy
```
