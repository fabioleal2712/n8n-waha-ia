# Relatório de Recursos do Servidor

**Servidor**: vmi2031828.contaboserver.net (10.30.0.50)  
**Data**: 2025-11-22  
**Uptime**: 8 dias, 19 horas

---

## 📊 Especificações do Servidor

### Hardware
- **CPU**: AMD EPYC, 4 cores
- **RAM**: 5.8 GB total
- **Disco**: 391 GB total (12% usado = 42 GB)
- **SO**: Debian 6.1.99-1 (Linux x86_64)

### Recursos Disponíveis
- **RAM Livre**: 1.6 GB disponível
- **Disco Livre**: 330 GB disponível
- **Load Average**: 0.60, 0.49, 0.30 (baixo - saudável)

---

## 🐳 Containers em Execução

### Resumo
Total de **10 containers** rodando:

| Container | Imagem | Status | Portas | CPU | RAM | RAM % |
|-----------|--------|--------|--------|-----|-----|-------|
| **n8n** | n8nio/n8n:latest | ✅ Healthy | 5678 | 0.40% | 276 MB | 4.67% |
| **n8n_postgres** | postgres:15-alpine | ✅ Healthy | 5432 (interno) | 0.07% | 43 MB | 0.72% |
| **jenkins** | gitops-jenkins | ✅ Running | 8083, 50000 | 0.21% | 1008 MB | 17.01% |
| **wpp-alert-frontend2** | Custom | ✅ Running | 3000 | 0.05% | 874 MB | 14.75% |
| **glpi_ticket_mysql_1** | elestio/mysql:8.0 | ✅ Running | 3307 | 1.14% | 631 MB | 10.66% |
| **glpi_ticket_glpi_1** | elestio/glpi | ✅ Running | 8081 | 0.01% | 147 MB | 2.48% |
| **wpconnect-server** | wpconnect-server | ✅ Running | 21465 | 0.31% | 183 MB | 3.09% |
| **seq** | datalust/seq | ✅ Running | 5341, 8080 | 0.53% | 158 MB | 2.67% |
| **azure-agent** | Azure Pipelines | ✅ Running | - | 0.00% | 111 MB | 1.87% |
| **portainer** | portainer-ce:2.21.4 | ✅ Running | 8001, 9443 | 0.00% | 22 MB | 0.36% |

### Uso Total de Recursos pelos Containers
- **CPU Total**: ~2.72% (muito baixo)
- **RAM Total**: ~3.45 GB (59.6% da RAM total)
- **RAM Disponível**: 1.6 GB (27.6%)

---

## 🔌 Portas em Uso

| Porta | Serviço |
|-------|---------|
| 22 | SSH |
| 80 | HTTP (nginx/proxy) |
| 443 | HTTPS (nginx/proxy) |
| 3000 | wpp-alert-frontend2 |
| 3307 | MySQL (GLPI) |
| 5341 | Seq (logs) |
| **5678** | **n8n** ⭐ |
| 8001 | Portainer (HTTP) |
| 8080 | Seq (HTTP) |
| 8081 | GLPI |
| 8083 | Jenkins |
| 9100 | Node Exporter (Prometheus) |
| 9323 | Docker metrics |
| 9443 | Portainer (HTTPS) |
| 9993 | ZeroTier |
| 21465 | WPConnect |
| 50000 | Jenkins agents |

---

## 📈 Análise de Capacidade

### Status Atual: ✅ **SAUDÁVEL**

#### Pontos Positivos
- ✅ CPU com uso muito baixo (2.72%)
- ✅ Load average saudável (0.60)
- ✅ Disco com 84% livre (330 GB)
- ✅ RAM disponível suficiente (1.6 GB)

#### Pontos de Atenção
- ⚠️ **RAM**: 59.6% em uso (3.45 GB de 5.8 GB)
  - Jenkins é o maior consumidor (1 GB - 17%)
  - wpp-alert-frontend2 em segundo (874 MB - 14.75%)
  - MySQL GLPI em terceiro (631 MB - 10.66%)

#### Capacidade para n8n
- ✅ **n8n está usando apenas 320 MB (5.4% do total)**
- ✅ Há espaço para crescimento
- ✅ n8n pode escalar até ~500-800 MB sem problemas

---

## 🎯 Recomendações

### 1. Monitoramento
```bash
# Ver uso de recursos em tempo real
ssh -i ~/key_client/keybinario fabioleal@10.30.0.50 "docker stats"

# Ver apenas n8n
ssh -i ~/key_client/keybinario fabioleal@10.30.0.50 "docker stats n8n n8n_postgres"
```

### 2. Otimizações Possíveis

#### Se precisar de mais RAM:
1. **Jenkins**: Considere limitar memória se não estiver em uso constante
   ```yaml
   deploy:
     resources:
       limits:
         memory: 512M
   ```

2. **wpp-alert-frontend2**: Verificar se há memory leak
   ```bash
   docker logs wpp-alert-frontend2 --tail=100
   ```

### 3. Limites para n8n (Opcional)

Se quiser garantir que n8n não use muita RAM:

```yaml
# docker-compose.yml
services:
  n8n:
    deploy:
      resources:
        limits:
          cpus: '2'
          memory: 1G
        reservations:
          memory: 256M
```

### 4. Limpeza Periódica

```bash
# Limpar imagens não utilizadas
docker image prune -a

# Limpar volumes órfãos
docker volume prune

# Limpar build cache
docker builder prune
```

---

## 🚀 Projetos Identificados

1. **n8n** (Novo) - Automação de workflows
2. **Jenkins** - CI/CD
3. **GLPI** - Sistema de tickets/helpdesk
4. **WPConnect** - WhatsApp API
5. **WPP Alert Frontend** - Frontend de alertas WhatsApp
6. **Seq** - Centralização de logs
7. **Portainer** - Gerenciamento Docker
8. **Azure Pipelines Agent** - CI/CD Azure
9. **Prometheus Node Exporter** - Métricas do sistema
10. **ZeroTier** - VPN/Rede privada

---

## ✅ Conclusão

**O servidor tem capacidade suficiente para rodar o n8n sem problemas.**

- RAM disponível: 1.6 GB (suficiente)
- CPU praticamente ociosa
- Disco com muito espaço
- n8n usando apenas 5.4% da RAM total

**Não há necessidade de ajustes imediatos**, mas é recomendável:
1. Monitorar uso de RAM periodicamente
2. Considerar upgrade de RAM se adicionar mais serviços (atualmente em 6 GB, ideal seria 8-16 GB)
3. Configurar alertas de uso de recursos (via Prometheus/Grafana)

---

## 📝 Script de Monitoramento

Criado em: `/home/fabioleal/github/n8n/monitor-server.sh`

Execute:
```bash
./monitor-server.sh
```
