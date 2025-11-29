# n8n Quick Reference

## 🚀 Comandos Rápidos

### Deploy Inicial
```bash
./n8n-manage.sh deploy
```

### Provisionar Workflows
```bash
./n8n-manage.sh workflows
```

### Monitoramento
```bash
./n8n-manage.sh status    # Ver status
./n8n-manage.sh logs      # Ver logs (Ctrl+C para sair)
```

### Controle
```bash
./n8n-manage.sh restart   # Reiniciar
./n8n-manage.sh stop      # Parar
./n8n-manage.sh start     # Iniciar
```

## 🔐 Acesso

**Mesma rede:**
- URL: http://10.30.0.50:5678

**Remoto (SSH Tunnel):**
```bash
./n8n-tunnel.sh
# Depois acesse: http://localhost:5678
```

- Usuário: admin
- Senha: admin123

## 📝 Adicionar Workflow

1. Coloque arquivo `.json` em `workflows/`
2. Execute: `./n8n-manage.sh workflows`
3. Importe via interface web:
   - Acesse http://10.30.0.50:5678
   - Workflows > Import from File
   - Selecione o arquivo copiado para `/home/fabioleal/n8n/workflows/`

## 🧪 Testar Webhook

```bash
curl -X POST http://10.30.0.50:5678/webhook/example-webhook \
  -H "Content-Type: application/json" \
  -d '{"test": "data"}'
```

## 🔧 SSH Direto

```bash
ssh -i ~/key_client/keybinario fabioleal@10.30.0.50
cd /home/fabioleal/n8n
docker-compose logs -f n8n
```

## 📚 Documentação Completa

Veja [README.md](README.md) para documentação completa.
