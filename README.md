# 🇧🇷 Odoo BR v18 - Localização Brasileira Completa

<p align="center">
  <img src="https://img.shields.io/badge/Odoo-18.0-714B67?style=for-the-badge&logo=odoo" alt="Odoo 18.0">
  <img src="https://img.shields.io/badge/Docker-Compose-2496ED?style=for-the-badge&logo=docker" alt="Docker">
  <img src="https://img.shields.io/badge/PostgreSQL-16-336791?style=for-the-badge&logo=postgresql" alt="PostgreSQL">
  <img src="https://img.shields.io/badge/Python-3.11-3776AB?style=for-the-badge&logo=python" alt="Python">
  <img src="https://img.shields.io/badge/License-AGPL--3.0-green?style=for-the-badge" alt="License">
</p>

**Odoo 18 Community Edition** totalmente configurado com **localização brasileira oficial (OCA)** para emissão de **NF-e, NFC-e, NFS-e, CT-e, MDF-e** e gestão fiscal completa.

🚀 Deploy rápido via Docker Compose com todos os módulos brasileiros pré-configurados.

---

## 📋 Índice

- [Características](#-características)
- [Pré-requisitos](#-pré-requisitos)
- [Instalação Rápida](#-instalação-rápida)
- [Instalação Detalhada](#-instalação-detalhada)
- [Configuração](#-configuração)
- [Módulos Brasileiros Disponíveis](#-módulos-brasileiros-disponíveis)
- [Emissão de NF-e](#-emissão-de-nf-e)
- [Estrutura do Projeto](#-estrutura-do-projeto)
- [Backup e Restore](#-backup-e-restore)
- [Troubleshooting](#-troubleshooting)
- [Documentação Adicional](#-documentação-adicional)
- [Suporte e Comunidade](#-suporte-e-comunidade)
- [Licença](#-licença)

---

## ✨ Características

### 📦 Completo e Pronto para Produção
- ✅ Odoo 18.0 Community Edition (última versão)
- ✅ PostgreSQL 16 com healthcheck configurado
- ✅ Localização brasileira oficial OCA (l10n-brazil)
- ✅ Módulos de RH brasileiros (dependentes, férias, etc)
- ✅ Módulos de pagamentos e contas a pagar/receber
- ✅ Suporte completo a certificado digital A1/A3
- ✅ Bibliotecas erpbrasil pré-instaladas

### 🔐 Segurança e Confiabilidade
- 🔒 Senhas configuráveis via variáveis de ambiente
- 🔒 Volumes persistentes para dados e PostgreSQL
- 🔒 Healthcheck automático dos containers
- 🔒 Logs estruturados e rotativos

### 🚀 Fácil Deploy
- 📦 Deploy com um único comando (`docker-compose up -d`)
- 📦 Configuração via arquivo `.env`
- 📦 Scripts de backup e restore incluídos
- 📦 Documentação completa de troubleshooting

### 🇧🇷 Fiscalização Brasileira
- 📄 **NF-e** (Nota Fiscal Eletrônica)
- 📄 **NFC-e** (Nota Fiscal ao Consumidor Eletrônica)
- 📄 **NFS-e** (Nota Fiscal de Serviço Eletrônica)
- 🚚 **CT-e** (Conhecimento de Transporte Eletrônico)
- 🚚 **MDF-e** (Manifesto Eletrônico de Documentos Fiscais)
- 📊 **SPED Fiscal, Contábil, Contribuições**
- 📊 **eSocial**
- 💰 **Cálculo automático de impostos (ICMS, IPI, PIS, COFINS, ISS)**

---

## 📋 Pré-requisitos

### Software Necessário

- **Docker** (≥ 20.10)
- **Docker Compose** (≥ 2.0)
- **Git**
- **4GB RAM** mínimo (8GB recomendado)
- **10GB** espaço em disco livre

### Verificar Instalação

```bash
# Verificar Docker
docker --version
# Saída esperada: Docker version 20.10.x ou superior

# Verificar Docker Compose
docker-compose --version
# Saída esperada: Docker Compose version 2.x.x ou superior

# Verificar Git
git --version
# Saída esperada: git version 2.x.x ou superior
```

### Instalar Docker (se necessário)

**Ubuntu/Debian:**
```bash
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER
newgrp docker
```

**Outras distribuições:** [Documentação oficial do Docker](https://docs.docker.com/engine/install/)

---

## 🚀 Instalação Rápida

```bash
# 1. Clone o repositório
git clone https://github.com/luanscps/odoobr.git
cd odoobr

# 2. Criar arquivo .env
cp .env.example .env

# 3. Criar estrutura de diretórios
mkdir -p addons postgres/pgdata logs certificates

# 4. Clonar repositórios OCA
cd addons
git clone --depth 1 --branch 18.0 https://github.com/OCA/l10n-brazil.git
git clone --depth 1 --branch 18.0 https://github.com/OCA/hr.git OCA-hr
git clone --depth 1 --branch 18.0 https://github.com/OCA/product-attribute.git
git clone --depth 1 --branch 18.0 https://github.com/OCA/account-payment.git
git clone --depth 1 --branch 18.0 https://github.com/OCA/bank-payment.git
cd ..

# 5. Subir containers
docker-compose up -d

# 6. Acompanhar logs
docker-compose logs -f odoo
```

**Pronto!** Acesse: `http://localhost:8069` ou `http://SEU_IP:8069`

---

## 📖 Instalação Detalhada

### Passo 1: Clone o Repositório

```bash
# Clone em um diretório de sua escolha
cd /opt  # ou /DATA/AppData, ou qualquer outro
git clone https://github.com/luanscps/odoobr.git
cd odoobr
```

### Passo 2: Configure as Variáveis de Ambiente

```bash
# Copie o arquivo de exemplo
cp .env.example .env

# Edite e configure suas senhas
nano .env
```

**Variáveis importantes no `.env`:**

```bash
# PostgreSQL
POSTGRES_DB=odoo
POSTGRES_USER=odoo
POSTGRES_PASSWORD=SuaSenhaSegura123!  # ALTERE!

# Odoo
ODOO_ADMIN_PASSWD=MasterPasswordSeguro456!  # ALTERE!
ODOO_DB_HOST=odoo-pg
ODOO_DB_PORT=5432
ODOO_DB_USER=odoo
ODOO_DB_PASSWORD=SuaSenhaSegura123!  # MESMA DO POSTGRES

# Porta do Odoo
ODOO_PORT=8069

# Ambiente fiscal (homologacao ou prod)
BRASIL_AMBIENTE=homologacao
```

### Passo 3: Crie a Estrutura de Diretórios

```bash
# Criar diretórios necessários
mkdir -p addons
mkdir -p postgres/pgdata
mkdir -p postgres/backup
mkdir -p logs
mkdir -p certificates
mkdir -p filestore

# Ajustar permissões (importante!)
chmod -R 775 addons postgres logs certificates filestore
```

### Passo 4: Clone os Repositórios OCA

Os módulos brasileiros oficiais vêm da **Odoo Community Association (OCA)**.

```bash
cd addons

# 1. Localização Brasileira (OBRIGATÓRIO)
# Contém todos os módulos fiscais (NF-e, CT-e, SPED, etc)
git clone --depth 1 --branch 18.0 https://github.com/OCA/l10n-brazil.git

# 2. Recursos Humanos (RECOMENDADO)
# Dependentes, férias, gestão de pessoal
git clone --depth 1 --branch 18.0 https://github.com/OCA/hr.git OCA-hr

# 3. Atributos de Produto (OBRIGATÓRIO)
# Contém uom_alias - dependência do l10n_br_fiscal
git clone --depth 1 --branch 18.0 https://github.com/OCA/product-attribute.git

# 4. Gestão de Pagamentos (RECOMENDADO)
# Contas a pagar/receber, lista de vencimentos
git clone --depth 1 --branch 18.0 https://github.com/OCA/account-payment.git

# 5. Pagamentos Bancários (OPCIONAL)
# Boletos, CNAB, integração bancária
git clone --depth 1 --branch 18.0 https://github.com/OCA/bank-payment.git

cd ..
```

**⚠️ Importante:** Se você encontrar o erro `country_enforce_cities`, siga as instruções na seção [Troubleshooting](#-troubleshooting) ou consulte [TROUBLESHOOTING.md](TROUBLESHOOTING.md#-attributeerror-rescompany-object-has-no-attribute-country_enforce_cities).

### Passo 5: Build e Inicialize os Containers

```bash
# Build das imagens (primeira vez)
docker-compose build

# Subir containers em background
docker-compose up -d

# Verificar status
docker-compose ps

# Acompanhar logs
docker-compose logs -f
```

**Saída esperada:**
```
NAME                IMAGE              STATUS         PORTS
odoobr-odoo         odoobr-odoo        Up 2 minutes   0.0.0.0:8069->8069/tcp
odoobr-postgres     postgres:16        Up 2 minutes   5432/tcp
odoobr-adminer      adminer:latest     Up 2 minutes   0.0.0.0:9999->8080/tcp
```

### Passo 6: Criar o Banco de Dados

Acesse `http://localhost:8069` (ou `http://SEU_IP:8069`)

1. Você verá a tela **"Manage Databases"**
2. Clique em **"Create Database"**
3. Preencha:
   - **Master Password:** (valor de `ODOO_ADMIN_PASSWD` no `.env`)
   - **Database Name:** `odoobr_prod` (ou outro nome)
   - **Email:** seu-email@exemplo.com
   - **Password:** senha de admin do Odoo
   - **Language:** Portuguese (BR) / Português (BR)
   - **Country:** Brazil / Brasil
   - **Demo data:** ❌ **DESMARCAR** (importante!)
4. Clique em **"Create"**
5. Aguarde 2-3 minutos (instalação dos módulos base)

**Pronto!** Você será redirecionado para o dashboard do Odoo.

---

## ⚙️ Configuração

### Configurações Iniciais do Sistema

1. **Acesse:** Menu → **Configurações** (Settings)
2. **Ative o modo desenvolvedor:**
   - Vá em **Configurações → Ativar modo desenvolvedor**
   - Ou adicione `?debug=1` na URL

### Instalar Módulos Brasileiros

#### Ordem de Instalação Recomendada

1. **Apps → Atualizar Lista de Apps** (para detectar os módulos OCA)
2. Remova o filtro "Apps" na busca para ver todos os módulos

**Instale nesta ordem:**

```
① uom_alias              (product-attribute - OBRIGATÓRIO PRIMEIRO!)
② l10n_br_base           (Base da localização brasileira)
③ l10n_br_fiscal         (Motor fiscal - NF-e, impostos, etc)
④ l10n_br_account        (Contabilidade brasileira)
⑤ l10n_br_sale           (Vendas com fiscalização)
⑥ l10n_br_purchase       (Compras com fiscalização)
⑦ l10n_br_stock          (Estoque com fiscalização)
⑧ l10n_br_nfe            (Nota Fiscal Eletrônica - NF-e)
⑨ l10n_br_nfce           (NFC-e - cupom fiscal eletrônico)
⑩ l10n_br_cte            (Conhecimento de Transporte Eletrônico)
⑪ account_payment_partner (Gestão de pagamentos)
⑫ account_due_list        (Lista de contas a pagar/receber)
```

**⚠️ IMPORTANTE:** Sempre instale `uom_alias` ANTES de qualquer módulo fiscal brasileiro! Caso contrário, você terá erros de dependência.

### Configurar Empresa

1. **Menu → Configurações → Empresas → Empresas**
2. Configure sua empresa:
   - **Nome da Empresa**
   - **CNPJ** (formato: 00.000.000/0000-00)
   - **Inscrição Estadual (IE)**
   - **Inscrição Municipal (IM)** (se aplicável)
   - **Regime Tributário:**
     - Simples Nacional
     - Lucro Presumido
     - Lucro Real
   - **Endereço Completo:**
     - CEP, Rua, Número, Bairro
     - Cidade, Estado
   - **Telefone e E-mail**

### Configurar Certificado Digital

Para emitir NF-e, você precisa de um certificado digital A1 ou A3.

**Certificado A1 (.pfx):**

1. Copie o arquivo `.pfx` para o diretório `certificates/`:
   ```bash
   cp seu-certificado.pfx /caminho/para/odoobr/certificates/
   ```

2. No Odoo:
   - **Menu → Configurações → Técnico → Certificados**
   - Clique em **"Criar"**
   - **Upload** do arquivo `.pfx`
   - Digite a **senha do certificado**
   - **Ambiente:** Homologação (para testes) ou Produção
   - Salvar

**Documentação completa:** Ver [INSTALL_NFE.md](INSTALL_NFE.md)

---

## 📦 Módulos Brasileiros Disponíveis

### Módulos Fiscais (l10n-brazil)

| Módulo | Descrição |
|--------|----------|
| `l10n_br_base` | Base da localização brasileira (CNPJ, IE, CEP, etc) |
| `l10n_br_fiscal` | Motor fiscal brasileiro (impostos, operações fiscais) |
| `l10n_br_account` | Contabilidade adaptada ao Brasil |
| `l10n_br_sale` | Vendas com fiscalização |
| `l10n_br_purchase` | Compras com fiscalização |
| `l10n_br_stock` | Estoque com controle fiscal |
| `l10n_br_nfe` | Nota Fiscal Eletrônica (NF-e) |
| `l10n_br_nfce` | Nota Fiscal ao Consumidor Eletrônica (NFC-e) |
| `l10n_br_nfse` | Nota Fiscal de Serviço Eletrônica (NFS-e) |
| `l10n_br_cte` | Conhecimento de Transporte Eletrônico (CT-e) |
| `l10n_br_mdfe` | Manifesto Eletrônico de Documentos Fiscais (MDF-e) |
| `l10n_br_sped` | SPED Fiscal, Contábil, Contribuições |
| `l10n_br_account_payment_order` | Ordem de pagamento brasileira |
| `l10n_br_cnab` | Geração de arquivos CNAB (boletos bancários) |

### Módulos de RH (OCA-hr)

| Módulo | Descrição |
|--------|----------|
| `hr_employee_relative` | Cadastro de dependentes/familiares |
| `hr_holidays_public` | Feriados nacionais brasileiros |
| `hr_expense_sequence` | Sequência de despesas |

### Módulos de Pagamentos

| Módulo | Descrição |
|--------|----------|
| `account_payment_partner` | Gestão avançada de pagamentos |
| `account_due_list` | Lista de contas a pagar/receber por vencimento |
| `account_payment_term_partner` | Condições de pagamento por parceiro |

---

## 📄 Emissão de NF-e

Para emitir NF-e, siga o guia completo: **[INSTALL_NFE.md](INSTALL_NFE.md)**

**Resumo rápido:**

1. ✅ Instalar módulos: `uom_alias` → `l10n_br_fiscal` → `l10n_br_nfe`
2. ✅ Configurar empresa (CNPJ, IE, endereço completo)
3. ✅ Upload certificado digital A1/A3
4. ✅ Configurar operações fiscais (CFOP, CST)
5. ✅ Cadastrar produtos com NCM e impostos
6. ✅ Testar emissão em **ambiente de homologação**
7. ✅ Após aprovação, mudar para **produção**

**Documentação oficial SEFAZ:** [Portal NF-e](https://www.nfe.fazenda.gov.br/)

---

## 📁 Estrutura do Projeto

```
odoobr/
├── .env.example              # Arquivo de exemplo de variáveis de ambiente
├── .gitignore                # Arquivos ignorados pelo Git
├── docker-compose.yml        # Configuração Docker Compose
├── Dockerfile                # Imagem customizada do Odoo
├── odoo.conf                 # Configuração do Odoo
├── requirements.txt          # Dependências Python (erpbrasil, etc)
├── healthcheck.sh            # Script de healthcheck do container
├── README.md                 # Este arquivo
├── INSTALL_NFE.md            # Guia de configuração de NF-e
├── TROUBLESHOOTING.md        # Soluções para problemas comuns
│
├── addons/                   # Módulos OCA (não versionados)
│   ├── l10n-brazil/          # Localização brasileira
│   ├── OCA-hr/               # Módulos de RH
│   ├── product-attribute/    # Atributos de produto (uom_alias)
│   ├── account-payment/      # Gestão de pagamentos
│   └── bank-payment/         # Pagamentos bancários
│
├── certificates/             # Certificados digitais A1/A3 (.pfx)
├── postgres/                 # Dados do PostgreSQL
│   ├── pgdata/               # Database files
│   └── backup/               # Backups SQL
│
├── logs/                     # Logs do Odoo
├── filestore/                # Arquivos anexados no Odoo
│
├── config/                   # Configurações adicionais
└── scripts/                  # Scripts utilitários
    ├── backup.sh             # Script de backup
    └── restore.sh            # Script de restore
```

**📌 Nota:** Os diretórios `addons/`, `postgres/`, `logs/`, `certificates/` e `filestore/` não são versionados no Git (estão no `.gitignore`).

---

## 💾 Backup e Restore

### Backup Manual

```bash
# Backup PostgreSQL (todos os bancos)
docker-compose exec -T odoo-pg pg_dumpall -U odoo > backup_$(date +%Y%m%d).sql

# Backup de arquivos/certificados
tar czf backup_files_$(date +%Y%m%d).tar.gz certificates/ filestore/ config/
```

### Backup Automatizado

```bash
# Criar script de backup
./scripts/backup.sh
```

Ver documentação completa de backup/restore em [TROUBLESHOOTING.md](TROUBLESHOOTING.md#backup-e-restore).

### Restore

```bash
# Parar containers
docker-compose down

# Restore PostgreSQL
cat backup_20260130.sql | docker-compose exec -T odoo-pg psql -U odoo -d postgres

# Restore arquivos
tar xzf backup_files_20260130.tar.gz

# Iniciar containers
docker-compose up -d
```

---

## 🔧 Troubleshooting

### Problemas Comuns

#### ❌ Erro: `country_enforce_cities`

**Causa:** Bug nos módulos `l10n_br_base` e `l10n_br_fiscal` (aguardando merge da PR #4344).

**Solução:**
```bash
cd addons/l10n-brazil
git remote add ednilson https://github.com/EdnilsonMonteiro/l10n-brazil.git
git fetch ednilson fix-tax-framework-domain
git checkout -b fix-tax-framework-domain ednilson/fix-tax-framework-domain
cd ../..
docker-compose restart odoo
```

**Documentação completa:** [TROUBLESHOOTING.md](TROUBLESHOOTING.md#-attributeerror-rescompany-object-has-no-attribute-country_enforce_cities)

#### ❌ Módulos brasileiros não aparecem

**Causa:** Repositórios OCA não clonados ou caminho incorreto no `odoo.conf`.

**Solução:**
1. Verifique se os repositórios foram clonados em `addons/`
2. No Odoo: **Apps → Atualizar Lista de Apps**
3. Remova o filtro "Apps" na busca

#### ❌ Erro ao instalar módulos: "module not found"

**Causa:** Dependências faltando (geralmente `uom_alias`).

**Solução:**
1. Instale `uom_alias` primeiro (do repositório `product-attribute`)
2. Depois instale os módulos fiscais

#### ❌ Container não inicia: "directory not writable"

**Causa:** Permissões incorretas nos volumes.

**Solução:**
```bash
sudo chown -R 101:101 postgres/pgdata
sudo chmod -R 775 addons logs certificates
```

### Logs e Diagnóstico

```bash
# Ver logs do Odoo em tempo real
docker-compose logs -f odoo

# Ver logs do PostgreSQL
docker-compose logs odoo-pg

# Entrar no container Odoo
docker-compose exec odoo bash

# Verificar módulos instalados
docker-compose exec odoo odoo --version
```

**Documentação completa:** [TROUBLESHOOTING.md](TROUBLESHOOTING.md)

---

## 📚 Documentação Adicional

| Documento | Descrição |
|-----------|----------|
| [INSTALL_NFE.md](INSTALL_NFE.md) | Guia completo para configuração e emissão de NF-e |
| [TROUBLESHOOTING.md](TROUBLESHOOTING.md) | Soluções para problemas comuns |
| [.env.example](.env.example) | Todas as variáveis de ambiente configuráveis |

---

## 🤝 Suporte e Comunidade

### Links Úteis

- 🐛 **Issues deste repositório:** [github.com/luanscps/odoobr/issues](https://github.com/luanscps/odoobr/issues)
- 🇧🇷 **OCA l10n-brazil:** [github.com/OCA/l10n-brazil](https://github.com/OCA/l10n-brazil)
- 📖 **Documentação Odoo 18:** [odoo.com/documentation/18.0](https://www.odoo.com/documentation/18.0)
- 💬 **Fórum Odoo Brasil:** [odoo.com/pt_BR/forum](https://www.odoo.com/pt_BR/forum)
- 📺 **Odoo YouTube (PT-BR):** [youtube.com/@Odoo](https://www.youtube.com/@Odoo)

### Comunidade OCA

- 🌐 **OCA Website:** [odoo-community.org](https://odoo-community.org/)
- 💬 **OCA Discussions:** [github.com/OCA/l10n-brazil/discussions](https://github.com/OCA/l10n-brazil/discussions)
- 🐛 **Reportar bugs:** [github.com/OCA/l10n-brazil/issues](https://github.com/OCA/l10n-brazil/issues)

### Contribuir

Contribuições são bem-vindas! 

1. Fork este repositório
2. Crie uma branch para sua feature (`git checkout -b feature/MinhaFeature`)
3. Commit suas mudanças (`git commit -m 'Adicionar MinhaFeature'`)
4. Push para a branch (`git push origin feature/MinhaFeature`)
5. Abra um Pull Request

**Para contribuir com os módulos brasileiros:** Contribua diretamente no [repositório OCA](https://github.com/OCA/l10n-brazil).

---

## 📄 Licença

Este projeto é distribuído sob a licença **AGPL-3.0**.

- **Odoo Community Edition:** [LGPL-3.0](https://www.odoo.com/documentation/18.0/legal/licenses.html)
- **Módulos OCA (l10n-brazil):** [AGPL-3.0](https://github.com/OCA/l10n-brazil/blob/18.0/LICENSE)

```
Copyright (C) 2026 - Luan Silva

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as published
by the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU Affero General Public License for more details.
```

---

<p align="center">
  <strong>Desenvolvido com ❤️ para a comunidade Odoo Brasil</strong><br>
  <sub>Baseado no trabalho da <a href="https://odoo-community.org/">Odoo Community Association (OCA)</a></sub>
</p>

<p align="center">
  <a href="https://github.com/luanscps/odoobr">⭐ Star este repositório</a> •
  <a href="https://github.com/luanscps/odoobr/issues">🐛 Reportar Bug</a> •
  <a href="https://github.com/luanscps/odoobr/discussions">💬 Discussões</a>
</p>