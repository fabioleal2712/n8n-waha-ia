# 📱 Como Obter o QR Code do WAHA

## ✅ Sessão Criada com Sucesso!

Você já criou a sessão "default" e ela está aguardando o QR code (status: `SCAN_QR_CODE`).

## 🎯 Métodos para Obter o QR Code

### Método 1: Swagger UI (Mais Fácil) ⭐

1. **Acesse**: http://10.30.0.50:3000
2. **Vá em**: `GET /api/screenshot`
3. **Clique em**: "Try it out"
4. **Parameters**: 
   - session: `default`
5. **Execute**
6. **Resultado**: Imagem do QR code aparecerá
7. **Escaneie** com WhatsApp

### Método 2: Baixar QR Code via SSH

```bash
# No servidor
ssh -i ~/key_client/keybinario fabioleal@10.30.0.50

# Salvar QR code como imagem
curl http://localhost:3000/api/screenshot?session=default > /tmp/qrcode.png

# Sair do SSH
exit

# Baixar para sua máquina local
scp -i ~/key_client/keybinario \
  fabioleal@10.30.0.50:/tmp/qrcode.png \
  ~/qrcode.png

# Abrir imagem
xdg-open ~/qrcode.png  # Linux
# ou
open ~/qrcode.png      # Mac
```

### Método 3: Túnel SSH + Navegador

```bash
# Criar túnel SSH (em outra janela do terminal)
ssh -i ~/key_client/keybinario -L 3000:localhost:3000 -N fabioleal@10.30.0.50

# Agora acesse no seu navegador local:
# http://localhost:3000

# Vá em GET /api/screenshot e execute
```

### Método 4: Endpoint de Autenticação

```bash
# Retorna dados do QR em formato JSON
curl http://localhost:3000/api/default/auth/qr
```

## 📱 Como Escanear o QR Code

1. Abra o **WhatsApp** no celular
2. Vá em **Menu (⋮)** → **Aparelhos conectados**
3. Toque em **Conectar um aparelho**
4. **Escaneie o QR code** que apareceu

## ✅ Verificar Conexão

```bash
# Verificar status da sessão
curl http://localhost:3000/api/sessions

# Deve mostrar: "status": "WORKING" quando conectado
```

**Status possíveis:**
- `SCAN_QR_CODE` - Aguardando escanear QR
- `WORKING` - Conectado e funcionando ✅
- `FAILED` - Falha na conexão
- `STOPPED` - Sessão parada

## 🔄 Se o QR Code Expirar

```bash
# Reiniciar sessão para gerar novo QR
curl -X POST http://localhost:3000/api/sessions/default/restart

# Aguardar alguns segundos e obter novo QR
curl http://localhost:3000/api/screenshot?session=default > qrcode.png
```

## 🎉 Após Conectar

Quando o status mudar para `WORKING`:

1. **Configure credenciais no n8n**
   - Acesse http://10.30.0.50:5678
   - Credentials → Add → WAHA API
   - URL: `http://waha:3000`

2. **Importe workflow**
   - Import → `whatsapp-ai-agent-native.json`

3. **Teste**
   - Envie mensagem para o WhatsApp
   - AI deve responder!

## 📚 Referências

- **Swagger UI**: http://10.30.0.50:3000
- **WAHA Docs**: https://waha.devlike.pro/docs/how-to/sessions/
