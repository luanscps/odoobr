# 🇧🇷 Guia Completo de Instalação NFe - Odoo 18.0 Brasil

> **Pré-requisito:** Odoo 18.0 instalado e funcionando ([veja README.md](README.md))

Este guia cobre a instalação completa dos módulos OCA l10n-brazil e configuração para emissão de NFe.

---

## 📋 Índice

1. [Instalação Módulos OCA](#1-instalação-módulos-oca)
2. [Configuração da Empresa](#2-configuração-da-empresa)
3. [Certificado Digital](#3-certificado-digital)
4. [Operações Fiscais](#4-operações-fiscais)
5. [Primeiro NFe de Teste](#5-primeiro-nfe-de-teste)
6. [Troubleshooting NFe](#6-troubleshooting-nfe)

---

## 1. Instalação Módulos OCA

### **1.1. Clonar Repositório OCA l10n-brazil**

```bash
cd /DATA/AppData/odoobr/addons

# Clonar branch 18.0 oficial
git clone -b 18.0 https://github.com/OCA/l10n-brazil.git

# Ajustar permissões (UID 101 = usuário odoo no container)
sudo chown -R 101:101 l10n-brazil/

# Verificar módulos disponíveis
ls -la l10n-brazil/ | grep "l10n_br"
```

**Módulos principais clonados:**
```
l10n_br_base/                  # Cadastros BR (CPF, CNPJ, IE)
l10n_br_coa/                   # Plano de contas brasileiro
l10n_br_fiscal/                # Motor fiscal (impostos)
l10n_br_nfe_spec/              # Schemas NFe 4.0
l10n_br_fiscal_certificate/    # Certificados digitais
l10n_br_fiscal_edi/            # Transmissão SEFAZ
l10n_br_nfse/                  # NFSe (opcional)
l10n_br_sale/                  # Vendas com fiscal
l10n_br_purchase/              # Compras com fiscal
```

### **1.2. Reiniciar Odoo para Detectar Módulos**

```bash
cd /DATA/AppData/odoobr
docker-compose restart odoo

# Aguardar 10 segundos
sleep 10

# Verificar se detectou os módulos
docker-compose logs odoo | grep "l10n-brazil"

# Deve aparecer:
# INFO odoo: addons paths: [..., '/mnt/extra-addons/l10n-brazil']
```

### **1.3. Atualizar Lista de Apps no Odoo**

**No navegador (http://SEU_IP:8069):**

1. Fazer login como **admin**
2. **Apps** (menu lateral)
3. **⚙️ Menu** → **Update Apps List**
4. **Update** (confirmar)
5. Aguardar ~30 segundos

### **1.4. Instalar Módulos (NESSA ORDEM)**

**⚠️ IMPORTANTE:** Instale na ordem exata para respeitar dependências!

#### **① l10n_br_base** (Base)
```
Apps → Remover filtro "Apps" → Buscar: l10n_br_base
→ Install (~30 segundos)
```

**O que instala:**
- Campos CPF/CNPJ/IE em contatos
- Validações brasileiras
- Busca CEP automática
- Campos de endereço BR

#### **② l10n_br_coa** (Plano de Contas)
```
Buscar: l10n_br_coa
→ Install (~1 minuto)
```

**O que instala:**
- Plano de contas brasileiro padrão
- Estrutura contábil

#### **③ l10n_br_fiscal** (Motor Fiscal) ⚡ CRÍTICO
```
Buscar: l10n_br_fiscal
→ Install (~2-3 minutos)
```

**O que instala:**
- Cálculo ICMS, IPI, PIS, COFINS, ISS
- Tabelas CFOP, NCM, CEST, CST
- Operações fiscais
- Documentos fiscais
- **ESTE É O MÓDULO PRINCIPAL!**

#### **④ l10n_br_nfe_spec** (Schemas NFe)
```
Buscar: l10n_br_nfe_spec
→ Install (~30 segundos)
```

**O que instala:**
- Estruturas XSD NFe 4.0 oficiais
- Modelos de dados SEFAZ
- Validações XML

#### **⑤ l10n_br_fiscal_certificate** (Certificados)
```
Buscar: l10n_br_fiscal_certificate
→ Install (~30 segundos)
```

**O que instala:**
- Upload certificado A1 (.pfx)
- Suporte certificado A3 (token/smartcard)
- Gestão validade certificados

#### **⑥ l10n_br_fiscal_edi** (Transmissão SEFAZ) 🚀
```
Buscar: l10n_br_fiscal_edi
→ Install (~1 minuto)
```

**O que instala:**
- Transmissão para SEFAZ (autorização)
- Consulta status NFe
- Cancelamento
- Carta de Correção Eletrônica (CCe)
- Inutilização de numeração

#### **⑦ l10n_br_sale** (Vendas - OPCIONAL)
```
Buscar: l10n_br_sale
→ Install (~1 minuto)
```

**O que instala:**
- Integração Vendas → NFe
- Geração automática NFe ao confirmar venda

---

## 2. Configuração da Empresa

### **2.1. Dados Básicos**

**Settings → Companies → Your Company**

**Aba General Information:**
```
Company Name: Sua Empresa Ltda
Email: contato@suaempresa.com.br
Phone: +55 11 98765-4321
Website: www.suaempresa.com.br
```

**Aba Address:**
```
Street: Rua Exemplo
Street2: 123 - Sala 45
ZIP: 01234-567 (busca automática)
City: São Paulo
State: São Paulo
Country: Brazil
```

### **2.2. Informações Fiscais** ⚠️ CRÍTICO

**Aba Fiscal (após instalar l10n_br_fiscal):**

```
CNPJ: 12.345.678/0001-99
Inscrição Estadual: 123.456.789.012
Inscrição Municipal: 12345678 (se tiver)
Suframa: (apenas Zona Franca)

Regime Tributário:
  ( ) Simples Nacional
  (•) Lucro Real
  ( ) Lucro Presumido

Regime Especial de Tributação:
  Deixar em branco (se não tiver)
```

### **2.3. Configuração NFe**

**Settings → Fiscal → Document Types**

Configurar **NFe (Modelo 55):**
```
Ambiente: Homologação (para testes)
Série: 1
Próximo Número: 1
Estado: Ativo
```

**⚠️ IMPORTANTE:**
- Sempre teste em **Homologação** primeiro
- Produção só depois de aprovar todos os testes
- SEFAZ exige ambiente de homologação para testes

---

## 3. Certificado Digital

### **3.1. Tipos de Certificado**

| Tipo | Descrição | Armazenamento |
|------|-----------|---------------|
| **A1** | Arquivo .pfx | Servidor (arquivo) |
| **A3** | Token/Smartcard | Hardware externo |

**Recomendado para Docker:** **A1** (mais simples)

### **3.2. Upload Certificado A1**

**Settings → Technical → Fiscal → Certificates**

**Criar novo certificado:**
```
Name: Certificado Produção - Sua Empresa
Type: A1 (arquivo)
File: [Upload do arquivo .pfx]
Password: [senha do certificado]
Environment: Homologação (para testes)
```

**Clicar em Save**

**Validar:**
- ✅ Validade: deve aparecer data início/fim
- ✅ CNPJ: deve corresponder ao da empresa
- ✅ Status: Válido (ícone verde)

### **3.3. Certificado A3 (Token/Smartcard)**

**⚠️ Complexo em Docker!** Requer:
- Driver do fabricante instalado no host
- Mapeamento USB para container
- Configuração pcscd (daemon smartcard)

**Recomendação:** Use A1 para facilitar.

### **3.4. Renovação de Certificado**

**Quando o certificado expirar:**

1. Adquirir novo certificado
2. Desativar certificado antigo (não excluir!)
3. Criar novo registro com certificado renovado
4. Testar em homologação
5. Ativar em produção

---

## 4. Operações Fiscais

### **4.1. Configurar CFOP Principal**

**Fiscal → Configuration → Fiscal Operations**

**Criar operação de venda:**
```
Name: Venda dentro do Estado
CFOP: 5.102 - Venda de mercadoria adquirida ou recebida de terceiros
Document Type: NFe (55)
Direction: Saída
```

**Impostos (exemplo Lucro Real SP):**
```
ICMS:
  CST: 00 - Tributada integralmente
  Alíquota: 18%
  Base de cálculo: 100%

IPI:
  CST: 99 - Outras saídas
  Alíquota: 0%

PIS:
  CST: 01 - Operação tributável base de cálculo = valor da operação
  Alíquota: 1.65%

COFINS:
  CST: 01 - Operação tributável base de cálculo = valor da operação  
  Alíquota: 7.6%
```

### **4.2. Produtos com NCM**

**Inventory → Products → [Seu Produto]**

**Aba Fiscal:**
```
NCM: 8471.30.12 (buscar na lista)
CEST: (se aplicável)
Origem: 0 - Nacional
Unidade Tributável: UN
```

### **4.3. Clientes com CNPJ/CPF**

**Contacts → [Seu Cliente]**

**Pessoa Jurídica:**
```
Company Type: Company
CNPJ: 98.765.432/0001-10
Inscrição Estadual: 123456789012
Contribuinte ICMS: Sim
```

**Pessoa Física:**
```
Company Type: Individual
CPF: 123.456.789-00
Contribuinte ICMS: Não
```

---

## 5. Primeiro NFe de Teste

### **5.1. Criar Pedido de Venda**

**Sales → Orders → Create**

```
Customer: [Cliente com CNPJ]
Fiscal Operation: Venda dentro do Estado (5.102)
Product: [Produto com NCM configurado]
Quantity: 1
Unit Price: 100.00
```

**Confirm** (confirmar pedido)

### **5.2. Gerar NFe**

**Aba "Fiscal Documents":**

**Create → NFe**

Sistema vai:
1. Calcular impostos automaticamente
2. Gerar XML conforme layout SEFAZ
3. Assinar com certificado digital

### **5.3. Transmitir para SEFAZ (Homologação)**

**Botão "Validate" (validar)**

Sistema vai:
1. Validar XML (estrutura, obrigatoriedades)
2. Transmitir para SEFAZ homologação
3. Aguardar resposta

**Respostas possíveis:**

✅ **Autorizada (status 100)**
```
NFe autorizada com sucesso!
Protocolo: 143210000000001
Data: 2026-01-28 08:30:00
Chave: 35260112345678000199550010000000011234567890
```

❌ **Rejeitada (status 2xx, 3xx, 7xx)**
```
Rejeição 233: CNPJ do destinatário inválido
Rejeição 563: Duplicidade de NFe
```

### **5.4. DANFE (Impressão)**

**Após autorização:**

**Print → DANFE** (PDF)

- Código de barras com chave de acesso
- QR Code (para consulta mobile)
- Dados fiscais completos
- Protocolo de autorização

### **5.5. XML NFe**

**Attachments → Download XML**

**Enviar para cliente:**
- XML assinado e autorizado
- DANFE em PDF

---

## 6. Troubleshooting NFe

### **❌ Rejeição 213: CNPJ do emitente inválido**

**Causa:** CNPJ da empresa não está cadastrado na SEFAZ.

**Solução:**
1. Verificar CNPJ em Settings → Companies
2. Em homologação, usar CNPJ de teste da SEFAZ
3. Em produção, ativar emissão NFe junto à SEFAZ

---

### **❌ Rejeição 280: Certificado revogado/vencido**

**Causa:** Certificado digital expirou ou foi revogado.

**Solução:**
```bash
# Verificar validade
Settings → Technical → Fiscal → Certificates
# Ver data de validade

# Se expirado:
1. Adquirir novo certificado
2. Upload do novo .pfx
3. Desativar certificado antigo
```

---

### **❌ Rejeição 539: Duplicidade de NFe**

**Causa:** Número da NFe já foi utilizado.

**Solução:**
```
# Cancelar documento duplicado
Fiscal Documents → [NFe duplicada] → Cancel Draft

# Criar nova NFe (número será incrementado)
```

---

### **❌ Erro: "No module named 'erpbrasil'"**

**Causa:** Pacotes Python não instalados.

**Solução:**
```bash
# Verificar se pacotes estão instalados
docker-compose exec odoo pip list | grep erpbrasil

# Se não aparecer, rebuild container
docker-compose build --no-cache odoo
docker-compose up -d
```

---

### **❌ Timeout ao transmitir**

**Causa:** SEFAZ fora do ar ou lentidão.

**Solução:**
1. Verificar status SEFAZ: https://www.nfe.fazenda.gov.br/portal/disponibilidade.aspx
2. Tentar novamente após 5 minutos
3. Em produção, usar contingência (FS-DA)

---

### **❌ XML mal formado**

**Causa:** Campos obrigatórios faltando.

**Solução:**
```
# Verificar dados obrigatórios:
✓ Empresa: CNPJ, IE, endereço completo
✓ Cliente: CNPJ/CPF, endereço completo
✓ Produto: NCM, unidade, valor
✓ Impostos: ICMS, PIS, COFINS configurados
```

---

## 📊 Checklist NFe Funcional

- [ ] Módulos OCA instalados (base, fiscal, nfe_spec, edi, certificate)
- [ ] Empresa configurada (CNPJ, IE, endereço)
- [ ] Certificado A1 válido carregado
- [ ] Operação fiscal criada (CFOP 5.102)
- [ ] Produto com NCM cadastrado
- [ ] Cliente com CNPJ/CPF
- [ ] NFe de teste autorizada em homologação
- [ ] DANFE impresso corretamente
- [ ] XML gerado e assinado

---

## 🚀 Próximos Passos

### **1. Passar para Produção**
```
1. Solicitar habilitação NFe junto à SEFAZ
2. Alterar ambiente para Produção
3. Configurar série de produção
4. Fazer backup antes da primeira NFe real
```

### **2. Configurações Avançadas**
- Contingência (FS-DA, EPEC)
- NFe de devolução (CFOP 1.202)
- NFe de remessa/retorno
- Carta de Correção Eletrônica
- Inutilização de números

### **3. Integrações**
- Boletos bancários (l10n_br_account_payment_order)
- NFSe (l10n_br_nfse)
- CT-e (l10n_br_cte)
- MDF-e (l10n_br_mdfe)

---

## 📞 Suporte

- **Repositório:** https://github.com/luanscps/odoobr
- **Issues:** https://github.com/luanscps/odoobr/issues
- **OCA l10n-brazil:** https://github.com/OCA/l10n-brazil
- **Fórum Odoo Brasil:** https://www.odoo.com/pt_BR/forum
- **Manual NFe SEFAZ:** http://www.nfe.fazenda.gov.br/portal/principal.aspx

---

**✅ Com este guia você tem uma instalação completa e funcional de NFe no Odoo 18.0!** 🇧🇷🚀
