# Odoo 18.0 Brasil - NFe e Localização Brasileira

[![License: AGPL-3](https://img.shields.io/badge/License-AGPL%203-blue.svg)](https://www.gnu.org/licenses/agpl-3.0)
[![Odoo Version](https://img.shields.io/badge/Odoo-18.0-blue.svg)](https://www.odoo.com)
[![Python](https://img.shields.io/badge/Python-3.10%2B-blue.svg)](https://www.python.org)
[![Docker](https://img.shields.io/badge/Docker-Compose-blue.svg)](https://www.docker.com)

Repositório para instalação completa do **Odoo 18.0** com localização brasileira, módulos fiscais OCA, suporte a **NFe (Nota Fiscal Eletrônica)**, NFS-e, e-CNAB, boletos e documentos fiscais eletrônicos.

**Desenvolvido para funcionar com Docker + Portainer + macvlan-dhcp em infraestrutura corporativa.**

---

## 📋 Índice

1. [Características](#características)
2. [Pré-requisitos](#pré-requisitos)
3. [Instalação Rápida](#instalação-rápida)
4. [Configuração Detalhada](#configuração-detalhada)
5. [Estrutura de Diretórios](#estrutura-de-diretórios)
6. [Módulos Instalados](#módulos-instalados)
7. [Dependências Python](#dependências-python)
8. [Configuração de NFe](#configuração-de-nfe)
9. [Troubleshooting](#troubleshooting)
10. [Suporte](#suporte)

---

## ✨ Características

### 🎯 Odoo 18.0 Localização Brasileira
- ✅ Odoo 18.0 Community Edition
- ✅ 18 módulos OCA l10n-brazil (versão 18.0)
- ✅ Motor fiscal completo com cálculo de impostos
- ✅ Suporte a múltiplas operações fiscais

### 📄 Documentos Fiscais Eletrônicos
- ✅ **NF-e** (Nota Fiscal Eletrônica) - modelo 55
- ✅ **NFC-e** (Nota Fiscal de Consumidor) - modelo 65
- ✅ **NFSe** (Nota Fiscal de Serviço Eletrônica)
- ✅ **CT-e** (Conhecimento de Transporte Eletrônico)
- ✅ **MDF-e** (Manifesto de Documento Fiscal Eletrônico)
- ✅ **e-CNAB** (Remessas bancárias automatizadas)
- ✅ **Boletos** (Geração automática de boletos)

### 💰 Impostos Suportados
- ✅ ICMS (Imposto sobre Circulação de Mercadorias)
- ✅ IPI (Imposto sobre Produtos Industrializados)
- ✅ PIS (Programa de Integração Social)
- ✅ COFINS (Contribuição para Financiamento da Seguridade Social)
- ✅ ISSQN (Imposto sobre Serviços)
- ✅ Substituição Tributária
- ✅ ICMS Monofásico

### 🔐 Segurança e Certificados
- ✅ Suporte a certificados digitais A1 (padrão ICP-Brasil)
- ✅ Assinatura digital de documentos XML
- ✅ Transmissão segura à SEFAZ
- ✅ Validação de documentos

### 🐳 Docker & Infraestrutura
- ✅ Docker Compose com macvlan-dhcp
- ✅ PostgreSQL 15 integrado
- ✅ Portainer-ready (UI management)
- ✅ Adminer para gerenciamento de BD
- ✅ Volumes persistentes em `/DATA/AppData/odoobr/`
- ✅ Health checks integrados

---

## 🔧 Pré-requisitos

### Hardware Mínimo
- **CPU**: 2+ cores
- **RAM**: 4 GB (8 GB recomendado)
- **Disco**: 20 GB livres em `/DATA`

### Software Obrigatório
- **Docker**: 20.10+
- **Docker Compose**: 2.0+
- **Git**: para clonar o repositório
- **Portainer**: (opcional, mas recomendado para criar a rede macvlan-dhcp)

### Rede
- **macvlan-dhcp**: rede Docker já configurada em sua infraestrutura (criada via Portainer/CasaOS)
- **Subnet esperada**: 10.41.10.0/24
- **IPs para containers**: 10.41.10.147, 10.41.10.148, 10.41.10.149
- **Gateway**: 10.41.10.1

**⚠️ Importante**: A rede `macvlan-dhcp` deve existir antes de executar o `docker-compose up`. Crie-a via Portainer/CasaOS.

### Certificados Digitais (para produção)
- Certificado A1 em formato `.pfx` (padrão ICP-Brasil)
- Senha do certificado

---

## 🚀 Instalação Rápida

### 1. Clone o Repositório

```bash
cd /DATA/AppData
git clone https://github.com/luanscps/odoobr.git
cd odoobr
```

### 2. Configure as Variáveis de Ambiente

```bash
cp .env.example .env
# Edite o arquivo .env conforme sua infraestrutura
vim .env
```

**Valores essenciais a alterar em `.env`:**
```bash
POSTGRES_IP=10.41.10.147          # Ou seu IP disponível
ODOO_IP=10.41.10.148              # Ou seu IP disponível
ADMINER_IP=10.41.10.149            # Ou seu IP disponível
POSTGRES_PASSWORD=sua_senha_forte  # ALTERAR
ODOO_ADMIN_PASSWORD=sua_senha_admin # ALTERAR
BRASIL_AMBIENTE=homolog            # (homolog para testes, prod para produção)
```

### 3. Execute o Script de Inicialização

```bash
chmod +x scripts/init.sh
./scripts/init.sh
```

O script fará:
- ✅ Validar Docker e docker-compose
- ✅ **Validar que a rede `macvlan-dhcp` existe** (não cria)
- ✅ Criar diretórios necessários
- ✅ Clonar repositório OCA l10n-brazil
- ✅ Construir a imagem Docker
- ✅ Iniciar containers

### 4. Aguarde a Inicialização

```bash
# Verifique os logs
docker-compose logs -f odoo

# Aguarde até ver: "[INFO] odoo.modules.loading: [...] ready"
```

### 5. Acesse o Odoo

```
http://10.41.10.148:8069
```

**Credenciais padrão:**
- Email: `admin`
- Senha: Valor definido em `ODOO_ADMIN_PASSWORD` no `.env`

---

## ⚙️ Configuração Detalhada

### Variáveis de Ambiente

| Variável | Descrição | Obrigatório | Padrão |
|----------|-----------|-------------|--------|
| `POSTGRES_IP` | IP do PostgreSQL | ✅ | `10.41.10.147` |
| `ODOO_IP` | IP do Odoo | ✅ | `10.41.10.148` |
| `ADMINER_IP` | IP do Adminer | ✅ | `10.41.10.149` |
| `POSTGRES_DB` | Nome do banco de dados | ❌ | `odoo` |
| `POSTGRES_USER` | Usuário PostgreSQL | ❌ | `odoo` |
| `POSTGRES_PASSWORD` | Senha PostgreSQL | ✅ | - |
| `ODOO_ADMIN_PASSWORD` | Senha admin do Odoo | ✅ | - |
| `ODOO_PORT` | Porta web do Odoo | ❌ | `8069` |
| `LOG_LEVEL` | Nível de logs | ❌ | `info` |
| `BRASIL_AMBIENTE` | SEFAZ: homolog ou prod | ❌ | `homolog` |
| `BRASIL_NFSE_ENABLED` | Habilitar NFSe | ❌ | `True` |
| `ADMINER_PORT` | Porta do Adminer | ❌ | `9999` |

**⚠️ Obrigatórios (ALTERAR):**
- `POSTGRES_PASSWORD` - Senha forte para banco de dados
- `ODOO_ADMIN_PASSWORD` - Senha forte para admin do Odoo
- `BRASIL_AMBIENTE` - Não alterar até validar em homolog

### Estrutura de Diretórios

```
/DATA/AppData/odoobr/
├── postgres/              # Dados do PostgreSQL
│   ├── pgdata/           # Data files
│   └── backup/           # Backups do BD
├── odoo/                  # Dados do Odoo
├── config/                # Configurações
│   └── odoo.conf
├── addons/                # Módulos (OCA clonado aqui)
│   └── l10n-brazil/       # OCA l10n-brazil (clone automático)
├── logs/                  # Logs da aplicação
├── filestore/             # Documentos e arquivos
├── sessions/              # Sessões de usuário
└── certificates/          # Certificados digitais A1
    └── seu_certificado.pfx
```

### Comandos Docker Essenciais

```bash
# Ver status dos containers
docker-compose ps

# Ver logs em tempo real
docker-compose logs -f odoo
docker-compose logs -f odoo-pg

# Parar containers
docker-compose down

# Reiniciar
docker-compose restart

# Acessar shell do Odoo
docker-compose exec odoo bash

# Acessar PostgreSQL
docker-compose exec odoo-pg psql -U odoo -d odoo

# Fazer backup do banco
docker-compose exec odoo-pg pg_dump -U odoo odoo > backup-$(date +%Y%m%d).sql
```

---

## 📦 Módulos Instalados

### Módulos OCA l10n-brazil (18 módulos)

Os seguintes módulos OCA estarão disponíveis para instalação:

| Módulo | Versão | Descrição |
|--------|--------|----------|
| `l10n_br_base` | 18.0.1.1.1 | Base com validações (CPF, CNPJ, IE, CEP) |
| `l10n_br_fiscal` | 18.0.3.1.0 | Motor fiscal e cálculo de impostos |
| `l10n_br_nfe_spec` | 18.0.1.0.0 | Modelos abstratos NF-e (XSD) |
| `l10n_br_nfse` | 18.0.2.1.0 | Emissão de NFS-e (serviços) |
| `l10n_br_account` | 18.0.x.x.x | Integração fiscal com contabilidade |
| `l10n_br_sale` | 18.0.x.x.x | Integração fiscal com vendas |
| `l10n_br_purchase` | 18.0.x.x.x | Integração fiscal com compras |
| `l10n_br_fiscal_certificate` | 18.0.1.0.0 | Gerenciamento cert. A1 |
| `l10n_br_fiscal_dfe` | 18.0.1.0.0 | Distribuição de docs. fiscais |
| `l10n_br_fiscal_edi` | 18.0.1.0.0 | Recursos EDI fiscal |
| `l10n_br_cte_spec` | 18.0.1.0.0 | Conhecimento de Transporte |
| `l10n_br_mdfe_spec` | 18.0.1.0.0 | Manifesto de Documento Fiscal |
| `l10n_br_hr` | 18.0.1.0.0 | RH/Folha de pagamento |
| `l10n_br_zip` | 18.0.1.0.0 | Consulta CEP |
| `l10n_br_nfe_transit` | 18.0.x.x.x | CT-e (Transporte) |
| `l10n_br_mail` | 18.0.x.x.x | Integração de e-mails |
| `l10n_br_cnpj_search` | 18.0.x.x.x | Busca de CNPJ |
| `l10n_br_account_payment` | 18.0.x.x.x | Pagamentos (boletos, etc) |

### Instalação dos Módulos

**Via UI (Interface Web):**
1. Acesse `http://10.41.10.148:8069/web`
2. Menu: **Aplicações → Atualizar Lista de Módulos**
3. Busque por `l10n_br`
4. Instale na ordem: base → fiscal → account → sale/purchase

**Via Linha de Comando:**
```bash
docker-compose exec odoo odoo -c /etc/odoo/odoo.conf \
  -i l10n_br_base,l10n_br_fiscal,l10n_br_account,l10n_br_sale \
  --stop-after-init
```

---

## 🐍 Dependências Python

Todas as dependências estão no arquivo `requirements.txt` e no `Dockerfile`:

### Bibliotecas Principais

```
ERPBrasil Core:
- erpbrasil.base>=2.3.0       # Utilitários brasileiros
- erpbrasil.assinatura>=1.2.0 # Assinatura digital A1

NFe Transmission:
- pytrustnfe3>=3.1.0          # SEFAZ integration (principal)
- PyNFe>=5.0.0                # Alternativa NFe

Financeiro:
- python3-cnab>=2.8.1         # CNAB processing
- python3-boleto>=3.0.0       # Boleto generation
- pycnab240>=2.8.2            # CNAB 240 format

Text Processing:
- num2words>=0.5.12           # Números em extenso
- phonenumbers>=8.13.0        # Validação telefone
- email-validator>=2.0.0      # Validação e-mail

XML & Crypto:
- lxml>=4.9.0                 # XML processing
- zeep>=4.2.0                 # SOAP client
- cryptography>=40.0.0        # Criptografia
```

Para verificar as dependências instaladas:
```bash
docker-compose exec odoo pip list | grep -i erpbrasil
docker-compose exec odoo pip list | grep -i pytrustnfe
```

---

## 📝 Configuração de NFe

### 1. Carregar Certificado Digital A1

1. No Odoo, acesse: **Configurações → Localização Brasil → Certificados Digitais**
2. Clique em "Novo"
3. Selecione o arquivo `.pfx` do seu certificado
4. Insira a senha do certificado
5. Marque como "Ativo"
6. Salve e valide

### 2. Configurar Dados Fiscais da Empresa

1. Acesse: **Configurações → Empresas → [Sua Empresa]**
2. Preencha os campos:
   - **CNPJ**: XX.XXX.XXX/XXXX-XX
   - **IE (Inscrição Estadual)**: XXXXXXXXXXXXXXX
   - **IM (Inscrição Municipal)**: (se aplicável)
   - **Endereço completo** com CEP
   - **Regime tributário**: Simples, Normal, MEI, etc.

### 3. Configurar Operações Fiscais

1. Acesse: **Configurações → Localização Brasil → Operações Fiscais**
2. Configure tipos de operação para:
   - Vendas (Venda interna, exportação, etc)
   - Compras (Compra interna, importação, etc)
   - Devoluções
3. Defina alíquotas padrão de ICMS, IPI, PIS, COFINS

### 4. Ambiente SEFAZ

**Homologação (Testes):**
```bash
Em .env: BRASIL_AMBIENTE=homolog
```

**Produção:**
```bash
Em .env: BRASIL_AMBIENTE=prod
# Requer certificado válido emitido pela SEFAZ
# Reconfigure após testes em homologação
```

### 5. Emitir Primeira NFe

1. Acesse: **Vendas → Pedidos**
2. Crie um novo pedido
3. Preencha dados do cliente (CNPJ/CPF)
4. Adicione produtos
5. Confirme o pedido
6. Na fatura, clique em "Emitir Nota Fiscal Eletrônica"
7. O Odoo gerará o XML e transmitirá à SEFAZ
8. Você receberá o número da NFe

---

## 🔍 Troubleshooting

### Problema: Rede macvlan-dhcp não existe

```bash
# Verifique se a rede existe
docker network ls | grep macvlan-dhcp

# Se não existir, crie via Portainer/CasaOS ou via CLI:
docker network create -d macvlan \
  --subnet=10.41.10.0/24 \
  --gateway=10.41.10.1 \
  -o parent=eth0 \
  macvlan-dhcp
```

### Problema: Containers não iniciam

```bash
# Verifique logs detalhados
docker-compose logs

# Verifique se IPs estão disponíveis
ping 10.41.10.147
ping 10.41.10.148
```

### Problema: Odoo não conecta ao PostgreSQL

```bash
# Verifique se PostgreSQL está saudável
docker-compose exec odoo-pg pg_isready -U odoo

# Verifique os logs
docker-compose logs odoo-pg
```

### Problema: Módulos OCA não aparecem

```bash
# Atualize a lista de módulos
docker-compose exec odoo odoo -c /etc/odoo/odoo.conf \
  --update=base --stop-after-init

# Verifique se o diretório /mnt/extra-addons foi mapeado
docker-compose exec odoo ls -la /mnt/extra-addons
```

### Problema: NFe não transmite

```bash
# Verifique certificado
docker-compose exec odoo python -c "import pytrustnfe3; print('OK')"

# Verifique logs
docker-compose logs odoo | grep -i nfe
```

---

## 📊 Adminer (Gerenciador de BD)

Acesse em: `http://10.41.10.149:9999`

**Credenciais:**
- Servidor: `odoobr-postgres`
- Usuário: `odoo`
- Senha: Valor em `POSTGRES_PASSWORD` no `.env`
- Banco: `odoo`

---

## 🔄 Backup e Restauração

### Fazer Backup Manual

```bash
# Backup do banco de dados
docker-compose exec odoo-pg pg_dump -U odoo odoo > \
  /DATA/AppData/odoobr/postgres-backup/odoo_$(date +%Y%m%d_%H%M%S).sql

# Backup completo (BD + filestore)
tar czf /DATA/AppData/odoobr/odoo-backup-$(date +%Y%m%d_%H%M%S).tar.gz \
  /DATA/AppData/odoobr/postgres \
  /DATA/AppData/odoobr/odoo
```

### Restaurar Backup

```bash
# Restaurar banco de dados
docker-compose exec odoo-pg psql -U odoo odoo < \
  /DATA/AppData/odoobr/postgres-backup/seu_backup.sql
```

---

## 🛡️ Segurança

### Recomendações

1. **Altere todas as senhas padrão** (`.env`)
2. **Use certificados válidos** em produção
3. **Mantenha Docker atualizado**
4. **Faça backups regulares**
5. **Restrinja acesso à rede macvlan-dhcp**
6. **Use reverse proxy** (Nginx/Caddy) em produção
7. **Habilite HTTPS** com Let's Encrypt

### Permissões de Arquivo

```bash
chmod 700 /DATA/AppData/odoobr/certificates/
chown odoo:odoo /DATA/AppData/odoobr -R
```

---

## 📚 Recursos Adicionais

- **OCA l10n-brazil**: https://github.com/OCA/l10n-brazil
- **Documentação Odoo**: https://www.odoo.com/documentation/18.0
- **PyTrustNFe3**: https://github.com/danimaribeiro/PyTrustNFe
- **SEFAZ**: https://www.sefaz.fazenda.gov.br
- **ERPBrasil**: https://github.com/erpbrasil

---

## 📞 Suporte e Contribuições

### Reportar Issues

Abra uma issue no GitHub com:
- Descrição do problema
- Logs relevantes (`docker-compose logs`)
- Versão do Odoo
- Sistema operacional

### Contribuir

1. Faça um fork
2. Crie uma branch (`git checkout -b feature/nova-feature`)
3. Commit suas mudanças (`git commit -am 'Add nova-feature'`)
4. Push para a branch (`git push origin feature/nova-feature`)
5. Abra um Pull Request

---

## 📄 Licença

Este projeto segue as mesmas licenças dos componentes:
- **Odoo**: AGPL-3.0
- **OCA l10n-brazil**: AGPL-3.0

---

## 👤 Autor

Repositório criado para facilitar implementações de Odoo 18.0 com localização brasileira e suporte completo a documentos fiscais eletrônicos.

**Criado em:** 26 de janeiro de 2026
**Versão:** 1.0.0

---

## 🎯 Próximas Etapas (Pós-Instalação)

1. ✅ Crie a rede `macvlan-dhcp` via Portainer/CasaOS (pré-requisito)
2. ✅ Execute o script `scripts/init.sh`
3. ✅ Instale e configure os módulos OCA l10n-brazil
4. ✅ Configure certificado digital A1
5. ✅ Preencha dados fiscais da empresa
6. ✅ Configure operações fiscais
7. ✅ Teste emissão de NFe em homologação
8. ✅ Migre para produção após validação

---

**Bom uso do Odoo 18.0 Brasil! 🚀**
