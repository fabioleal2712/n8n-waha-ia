# Acesso ao n8n

## ✅ Acesso Principal (HTTPS)

Acesse de qualquer lugar (internet pública):

- **URL**: https://n8n.fabioleal.com.br
- **Usuário**: admin
- **Senha**: admin123

> 🔒 **Seguro**: Conexão criptografada com SSL (Let's Encrypt)

## Outros Métodos (Backup)

### IP Direto (HTTP)
- URL: http://62.169.17.216:5678
- Nota: Não recomendado (sem criptografia)

### Rede Interna / VPN
- URL: http://10.30.0.50:5678
- Requer: VPN conectada

### SSH Tunnel
- Script: `./n8n-tunnel.sh`
- URL: http://localhost:5678

## Arquitetura

```
[Internet] -> [Nginx (SSL)] -> [Docker (n8n)]
              Porta 443        Porta 5678
```

## Manutenção

### Renovar Certificado SSL
O Certbot renova automaticamente. Para testar:
```bash
ssh -i ~/key_client/keybinario fabioleal@10.30.0.50 "sudo certbot renew --dry-run"
```

### Ver Logs do Nginx
```bash
ssh -i ~/key_client/keybinario fabioleal@10.30.0.50 "sudo tail -f /var/log/nginx/access.log"
```
