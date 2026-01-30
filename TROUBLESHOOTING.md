# 🔧 Troubleshooting - Odoo 18.0 Brasil

Soluções para problemas comuns durante instalação e configuração.

---

## 📋 Índice

1. [Erros PostgreSQL](#erros-postgresql)
2. [Erros Odoo](#erros-odoo)
3. [Erros Módulos Brasileiros](#erros-módulos-brasileiros)
4. [Erros Docker](#erros-docker)
5. [Erros Python/Pacotes](#erros-pythonpacotes)
6. [Comandos de Diagnóstico](#comandos-de-diagnóstico)
7. [Backup e Restore](#backup-e-restore)
8. [Reinstalação Limpa](#reinstalação-limpa)

---

## Erros PostgreSQL

### ❌ **"Directory not empty"**

**Sintoma:**
```
initdb: error: directory "/var/lib/postgresql/data/pgdata" exists but is not empty
```

**Causa:** Diretório PostgreSQL contém arquivos de instalação anterior.

**Solução:**
```bash
cd /DATA/AppData/odoobr

# Parar containers
docker-compose down -v

# Limpar diretório PostgreSQL
sudo rm -rf postgres/pgdata/*

# Iniciar novamente
docker-compose up -d

# Monitorar
docker-compose logs -f odoo-pg
```

---

### ❌ **"password authentication failed"**

**Sintoma:**
```
FATAL: password authentication failed for user "odoo"
```

**Causa:** Senha no `.env` não corresponde ao PostgreSQL.

**Solução:**
```bash
# 1. Verificar senha no .env
cat .env | grep POSTGRES_PASSWORD

# 2. Parar containers
docker-compose down

# 3. Recriar database com senha correta
sudo rm -rf postgres/pgdata/*

# 4. Editar .env se necessário
nano .env

# 5. Iniciar
docker-compose up -d
```

---

### ❌ **"database 'odoo' does not exist" (healthcheck)**

**Sintoma:**
```
FATAL: database "odoo" does not exist
2026-01-28 11:13:45.482 UTC [467] FATAL: database "odoo" does not exist
```

**Causa:** Healthcheck tentando conectar em database que foi removido ou renomeado.

**Solução:** Já corrigido no repositório! O healthcheck agora usa `postgres` que sempre existe.

Se ainda aparecer:
```bash
# Verificar docker-compose.yml
grep "pg_isready" docker-compose.yml

# Deve ter: pg_isready -U odoo -d postgres
# Se não tiver, atualizar do repositório:
git pull origin main
docker-compose up -d --force-recreate odoo-pg
```

---

## Erros Odoo

### ❌ **"directory is not writable"**

**Sintoma:**
```
AssertionError: /var/lib/odoo/.local/share/Odoo/sessions: directory is not writable
```

**Causa:** Permissões incorretas em volumes mapeados.

**Solução:** Já corrigido no repositório usando volume nomeado!

Se ainda aparecer:
```bash
# Verificar se está usando volume nomeado
grep "odoo-data" docker-compose.yml

# Deve ter: - odoo-data:/var/lib/odoo
# Se não tiver, atualizar do repositório:
git pull origin main
docker-compose down
docker-compose up -d
```

---

### ❌ **"KeyError: 'ir.http'"**

**Sintoma:**
```
KeyError: 'ir.http'
ERROR: Database odoo not initialized, you can force it with `-i base`
```

**Causa:** Database existe mas está vazio (sem tabelas Odoo).

**Solução Opção 1 - Interface Web (RECOMENDADO):**
```
1. Acessar http://SEU_IP:8069
2. Ver tela "Manage Databases"
3. Clicar "Create Database"
4. Preencher formulário:
   - Master Password: (do odoo.conf)
   - Database Name: odoobr_prod
   - Email: admin@exemplo.com
   - Password: (sua senha)
   - Language: Portuguese (BR)
   - Country: Brazil
   - Demo data: DESMARCAR
5. Aguardar 2-3 minutos
```

**Solução Opção 2 - Terminal:**
```bash
# Parar Odoo
docker-compose stop odoo

# Recriar database vazio
docker-compose exec odoo-pg psql -U odoo -d postgres <<SQL
DROP DATABASE IF EXISTS odoo;
CREATE DATABASE odoo OWNER odoo;
SQL

# Inicializar com módulo base
docker-compose run --rm odoo odoo -d odoo -i base --stop-after-init --without-demo=all

# Iniciar Odoo
docker-compose start odoo
```

---

### ❌ **500 Internal Server Error**

**Sintoma:** Página web mostra erro 500.

**Diagnóstico:**
```bash
# Ver logs em tempo real
docker-compose logs -f odoo

# Procurar por linhas com ERROR ou CRITICAL
```

**Causas comuns:**
1. Database não inicializado → Ver solução KeyError acima
2. Permissões incorretas → Ver solução "directory is not writable"
3. Pacotes Python faltando → Ver seção "Erros Python/Pacotes"

---

## Erros Módulos Brasileiros

### ❌ **"AttributeError: 'res.company' object has no attribute 'country_enforce_cities'"**

**Sintoma:**
```javascript
AttributeError: 'res.company' object has no attribute 'country_enforce_cities'
Traceback (most recent call last):
  File "/usr/lib/python3/dist-packages/odoo/tools/convert.py", line 1786, in _tag_root
    f(rec, node)
  ...
AttributeError: 'res.company' object has no attribute 'country_enforce_cities'
```

Ou erro similar relacionado a `parent.tax_framework` em domains XML.

**Causa:** 
- Bug nos módulos `l10n_br_base` e `l10n_br_fiscal` (issues [#4213](https://github.com/OCA/l10n-brazil/issues/4213) e [#4328](https://github.com/OCA/l10n-brazil/issues/4328))
- Uso incorreto de `parent.country_enforce_cities` e `parent.tax_framework` nos domains dos views XML
- Campos do addon nativo `base_address_extended` não tratados corretamente no `res_company.py`

**Solução:**

A correção está na [PR #4344](https://github.com/OCA/l10n-brazil/pull/4344) do OCA, que ainda aguarda merge na branch oficial `18.0`. Enquanto isso, use a branch com a correção:

```bash
# 1. Acessar diretório l10n-brazil
cd /DATA/AppData/odoobr/addons/l10n-brazil

# 2. Adicionar remote do fork com a correção (se ainda não adicionou)
git remote add ednilson https://github.com/EdnilsonMonteiro/l10n-brazil.git

# 3. Fazer fetch da branch com a correção
git fetch ednilson fix-tax-framework-domain

# 4. Trocar para a branch corrigida
git checkout -b fix-tax-framework-domain ednilson/fix-tax-framework-domain

# 5. Verificar se está no commit correto
git log -1 --format="%H"
# Deve retornar: eec7f132cc9f6b06d8ed0bfdec2aba955dd23295

# 6. Reiniciar o container Odoo
cd /DATA/AppData/odoobr
docker-compose restart odoo

# 7. Atualizar os módulos afetados
docker-compose exec odoo odoo -c /etc/odoo/odoo.conf -d SEU_BANCO -u l10n_br_base,l10n_br_fiscal --stop-after-init

# 8. Reiniciar novamente
docker-compose restart odoo
```

**Verificar se a correção funcionou:**
```bash
# Testar acesso à interface
curl -I http://localhost:8069

# Verificar logs (não deve ter mais erros country_enforce_cities)
docker-compose logs odoo | grep -i "country_enforce_cities"

# Verificar que novos métodos foram criados
grep -n "_tax_piscofins_domain\|_tax_icms_domain\|_tax_issqn_domain" \
  /DATA/AppData/odoobr/addons/l10n-brazil/l10n_br_base/models/res_company.py
```

**O que a correção faz:**
1. Adiciona tratamento para campos do `base_address_extended` no `res_company.py`
2. Cria métodos computados (`_tax_piscofins_domain`, `_tax_icms_domain`, `_tax_issqn_domain`) para substituir os domains problemáticos
3. Remove referências diretas a `parent.tax_framework` e `parent.country_enforce_cities` dos views XML

**Status da correção:**
- **Commit:** [eec7f132](https://github.com/OCA/l10n-brazil/commit/eec7f132cc9f6b06d8ed0bfdec2aba955dd23295)
- **PR:** [#4344](https://github.com/OCA/l10n-brazil/pull/4344) (aberta, aguardando revisão)
- **Autor:** EdnilsonMonteiro
- **Issues corrigidas:** [#4213](https://github.com/OCA/l10n-brazil/issues/4213), [#4328](https://github.com/OCA/l10n-brazil/issues/4328)
- **Data:** 10/01/2026

**Quando a PR for mergeada na branch oficial:**
```bash
# Voltar para a branch oficial
cd /DATA/AppData/odoobr/addons/l10n-brazil
git checkout 18.0
git pull origin 18.0

# Atualizar módulos
cd /DATA/AppData/odoobr
docker-compose exec odoo odoo -c /etc/odoo/odoo.conf -d SEU_BANCO -u l10n_br_base,l10n_br_fiscal --stop-after-init
docker-compose restart odoo
```

---

## Erros Docker

### ❌ **"version is obsolete"**

**Sintoma:**
```
WARNING: The 'version' field is obsolete
```

**Causa:** Docker Compose v2 não usa mais `version: '3.8'`.

**Solução:** Já corrigido no repositório! A linha `version` foi removida.

```bash
# Atualizar do repositório
git pull origin main
```

---

### ❌ **"network not found"**

**Sintoma:**
```
network macvlan-dhcp declared as external, but could not be found
```

**Causa:** Rede macvlan-dhcp não foi criada.

**Solução:**
```bash
# Criar rede macvlan-dhcp
docker network create -d macvlan \
  --subnet=10.41.10.0/24 \
  --gateway=10.41.10.1 \
  -o parent=eth0 \
  macvlan-dhcp

# Verificar
docker network ls | grep macvlan
```

**Alternativa (sem macvlan):**
Editar `docker-compose.yml` para usar rede bridge:
```yaml
networks:
  default:
    driver: bridge
```

---

### ❌ **"Cannot start service: port is already allocated"**

**Sintoma:**
```
ERROR: for odoo Cannot start service odoo: driver failed programming external connectivity on endpoint odoobr-odoo: Bind for 0.0.0.0:8069 failed: port is already allocated
```

**Causa:** Porta 8069 já em uso por outro serviço.

**Solução:**
```bash
# Verificar quem está usando a porta
sudo lsof -i :8069

# Matar processo (se seguro)
sudo kill -9 PID

# OU alterar porta no .env
echo "ODOO_PORT=8070" >> .env
docker-compose up -d
```

---

## Erros Python/Pacotes

### ❌ **"cannot import 'erpbrasil'"**

**Sintoma:**
```
ModuleNotFoundError: No module named 'erpbrasil'
```

**Causa:** Pacotes Python não instalados ou conflito com Debian.

**Solução:** Já corrigido no Dockerfile com `--ignore-installed`!

```bash
# Rebuild forçado
docker-compose build --no-cache odoo
docker-compose up -d

# Verificar instalação
docker-compose exec odoo pip list | grep erpbrasil

# Deve mostrar:
# erpbrasil.assinatura
# erpbrasil.base
# erpbrasil.edoc
# erpbrasil.transmissao
```

---

### ❌ **"pip error: externally-managed-environment"**

**Sintoma:**
```
error: externally-managed-environment
```

**Causa:** Python 3.11+ exige flag `--break-system-packages`.

**Solução:** Já corrigido no Dockerfile!

```bash
# Se aparecer, rebuild:
docker-compose build --no-cache odoo
```

---

## Comandos de Diagnóstico

### **Logs**
```bash
# Odoo em tempo real
docker-compose logs -f odoo

# PostgreSQL últimas 50 linhas
docker-compose logs odoo-pg | tail -n 50

# Todos os containers
docker-compose logs -f

# Filtrar apenas erros
docker-compose logs odoo | grep -i error
```

### **Status Containers**
```bash
# Ver status
docker-compose ps

# Ver uso de recursos
docker stats

# Inspecionar container
docker inspect odoobr-odoo
```

### **Entrar nos Containers**
```bash
# Odoo
docker-compose exec odoo bash

# PostgreSQL
docker-compose exec odoo-pg sh

# Como root (Odoo)
docker-compose exec -u root odoo bash
```

### **PostgreSQL**
```bash
# Listar databases
docker-compose exec odoo-pg psql -U odoo -d postgres -c "\l"

# Conectar em database
docker-compose exec odoo-pg psql -U odoo -d odoobr_prod

# Tamanho do database
docker-compose exec odoo-pg psql -U odoo -d postgres -c "SELECT pg_size_pretty(pg_database_size('odoobr_prod'));"

# Ver conexões ativas
docker-compose exec odoo-pg psql -U odoo -d postgres -c "SELECT * FROM pg_stat_activity;"
```

### **Odoo**
```bash
# Verificar pacotes Python
docker-compose exec odoo pip list | grep erpbrasil

# Verificar versão Odoo
docker-compose exec odoo odoo --version

# Listar addons detectados
docker-compose exec odoo ls -la /mnt/extra-addons/

# Testar healthcheck
docker-compose exec odoo curl -f http://localhost:8069/web/health

# Ver permissões
docker-compose exec odoo ls -la /var/lib/odoo/
```

### **Volumes**
```bash
# Listar volumes
docker volume ls | grep odoo

# Inspecionar volume
docker volume inspect odoobr_odoo-data

# Ver conteúdo de volume
docker run --rm -v odoobr_odoo-data:/data alpine ls -la /data
```

---

## Backup e Restore

### **Backup Completo**

```bash
#!/bin/bash
BACKUP_DIR="/DATA/AppData/odoobr/backups/$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_DIR"

echo "Iniciando backup..."

# 1. Backup PostgreSQL (todos os databases)
echo "[1/4] Backup PostgreSQL..."
docker-compose exec -T odoo-pg pg_dumpall -U odoo > "$BACKUP_DIR/postgresql.sql"

# 2. Backup volume odoo-data (sessions, filestore)
echo "[2/4] Backup odoo-data..."
docker run --rm \
  -v odoobr_odoo-data:/data \
  -v "$BACKUP_DIR":/backup \
  alpine tar czf /backup/odoo-data.tar.gz -C /data .

# 3. Backup configurações e addons
echo "[3/4] Backup config e addons..."
cp -r config addons .env "$BACKUP_DIR/"

# 4. Backup certificados
echo "[4/4] Backup certificados..."
cp -r certificates "$BACKUP_DIR/" 2>/dev/null || echo "Sem certificados"

echo ""
echo "✅ Backup completo em: $BACKUP_DIR"
echo ""
ls -lh "$BACKUP_DIR"
```

### **Restore Completo**

```bash
#!/bin/bash
BACKUP_DIR="/DATA/AppData/odoobr/backups/20260128-083000"

if [ ! -d "$BACKUP_DIR" ]; then
    echo "❌ Backup não encontrado: $BACKUP_DIR"
    exit 1
fi

echo "Iniciando restore de $BACKUP_DIR..."

# 1. Parar containers
echo "[1/5] Parando containers..."
docker-compose down

# 2. Restore PostgreSQL
echo "[2/5] Restore PostgreSQL..."
cat "$BACKUP_DIR/postgresql.sql" | docker-compose exec -T odoo-pg psql -U odoo -d postgres

# 3. Restore odoo-data
echo "[3/5] Restore odoo-data..."
docker run --rm \
  -v odoobr_odoo-data:/data \
  -v "$BACKUP_DIR":/backup \
  alpine tar xzf /backup/odoo-data.tar.gz -C /data

# 4. Restore configurações
echo "[4/5] Restore config..."
cp -r "$BACKUP_DIR/config" .
cp -r "$BACKUP_DIR/addons" .
cp "$BACKUP_DIR/.env" .

# 5. Iniciar containers
echo "[5/5] Iniciando containers..."
docker-compose up -d

echo ""
echo "✅ Restore concluído!"
echo ""
docker-compose ps
```

---

## Reinstalação Limpa

### **Reset Completo (CUIDADO!)**

```bash
#!/bin/bash
echo "⚠️  ATENÇÃO: Isto vai apagar TODOS os dados!"
echo "Pressione CTRL+C para cancelar, ou ENTER para continuar..."
read

cd /DATA/AppData/odoobr

# 1. Parar e remover containers
echo "[1/6] Removendo containers..."
docker-compose down -v

# 2. Limpar dados PostgreSQL
echo "[2/6] Limpando PostgreSQL..."
sudo rm -rf postgres/pgdata/*
sudo rm -rf postgres/backup/*

# 3. Limpar logs
echo "[3/6] Limpando logs..."
sudo rm -rf logs/*

# 4. Limpar volumes Docker
echo "[4/6] Removendo volumes..."
docker volume rm odoobr_odoo-data 2>/dev/null || true

# 5. Rebuild
echo "[5/6] Rebuild containers..."
docker-compose build --no-cache

# 6. Iniciar
echo "[6/6] Iniciando..."
docker-compose up -d

echo ""
echo "✅ Reinstalação limpa concluída!"
echo ""
echo "Monitorar logs:"
echo "  docker-compose logs -f"
echo ""
echo "Acessar:"
echo "  http://SEU_IP:8069"
echo ""
```

### **Manter Configurações**

Se quiser resetar MAS manter config/addons/.env:

```bash
# Fazer backup de configs
cp -r config config.backup
cp -r addons addons.backup
cp .env .env.backup

# Executar reset completo
# (script acima)

# Restaurar configs
cp -r config.backup config
cp -r addons.backup addons
cp .env.backup .env
```

---

## 📞 Suporte

### **Links Úteis**

- **Repositório:** https://github.com/luanscps/odoobr
- **Issues:** https://github.com/luanscps/odoobr/issues
- **OCA l10n-brazil:** https://github.com/OCA/l10n-brazil
- **PR #4344 (fix country_enforce_cities):** https://github.com/OCA/l10n-brazil/pull/4344
- **Documentação Odoo:** https://www.odoo.com/documentation/18.0
- **Fórum Odoo Brasil:** https://www.odoo.com/pt_BR/forum

### **Reportar Problemas**

Ao abrir issue, inclua:

```bash
# Versões
docker --version
docker-compose --version
uname -a

# Status containers
docker-compose ps

# Logs (últimas 100 linhas)
docker-compose logs --tail=100 > logs.txt

# Configuração (SEM SENHAS!)
cat docker-compose.yml
cat config/odoo.conf
```

---

**✅ Com este guia você consegue resolver 99% dos problemas!** 🔧🚀