# Guia de Configuração de NFe no Odoo 18.0 Brasil

## 🎯 Visão Geral

Este guia descreve os passos necessários para configurar e emitir Notas Fiscais Eletrônicas (NFe) no Odoo 18.0 com localização brasileira.

## 🚦 Pré-requisitos

- Odoo 18.0 instalado e rodando
- Módulos OCA l10n-brazil instalados (`l10n_br_base`, `l10n_br_fiscal`, etc)
- Certificado digital A1 em formato `.pfx` (válido para 12 meses)
- Senha do certificado
- Dados da empresa: CNPJ, IE, IM (se aplicável)
- Acesso à SEFAZ (primeiro em homologação, depois produção)

## 📋 Passo 1: Configurar Dados Fiscais da Empresa

### 1.1 Acessar Configurações de Empresa

1. No Odoo, acesse: **Configurações** (ou gear icon no canto superior)
2. Selecione **Empresas** ou navegue por: **Contatos** → Sua Empresa
3. Abra a empresa para edição

### 1.2 Preencher Dados Fiscais Brasileiros

Abra a aba **Informações Fiscais** (ou similar) e preencha:

| Campo | Valor Exemplo | Obrigatório |
|-------|---------------|-------------|
| **CNPJ** | 12.345.678/0001-90 | ✅ Sim |
| **IE (Inscrição Estadual)** | 123.456.789.012 | ✅ Sim |
| **IM (Inscrição Municipal)** | 123456 | ❌ Não (depende do município) |
| **Regime Tributário** | Normal, Simples, MEI, etc | ✅ Sim |
| **Suframa** | (se aplicável) | ❌ Não |
| **Endereço Completo** | Rua X, 123 | ✅ Sim |
| **CEP** | 12345-678 | ✅ Sim |
| **Município** | São Paulo | ✅ Sim |
| **UF** | SP | ✅ Sim |

### 1.3 Selecionar Ambênte SEFAZ

Em **Localização Brasil** → **Configurações Fiscais**:
- **Ambiente**: Selecione **Homologação** para testes
- Depois de validado, altere para **Produção**

## 🔐 Passo 2: Instalar Certificado Digital A1

### 2.1 Preparar Certificado

1. Obtenha seu certificado A1 em formato `.pfx` de uma AC (Autoridade Certificadora) como:
   - Serasa Experian
   - Certisign
   - DigiCert/eSign
   - Outras ACes credenciadas

2. Guarde a **senha do certificado** em local seguro

### 2.2 Instalar no Odoo

1. Acesse: **Localização Brasil** → **Certificados Digitais**
2. Clique em **Novo**
3. Preencha:
   - **Nome**: (ex: "Certificado Empresa 2025")
   - **Arquivo**: Selecione o arquivo `.pfx`
   - **Senha**: Insira a senha do certificado
   - **Data de Válidade**: Auto-preenchida
   - **Ativo**: Marque como ✅
4. Clique em **Salvar**

### 2.3 Validar Certificado

1. Clique em **Validar** para verificar:
   - ✅ Certificado válido
   - ✅ Senha correta
   - ✅ Não expirado

Se alguma validação falhar, verifique a senha e o arquivo.

## 🏢 Passo 3: Configurar Operações Fiscais

### 3.1 Acessar Operações Fiscais

Acesse: **Localização Brasil** → **Operações Fiscais**

Você deverá configurar operações para:

#### Para **Vendas**:
- Venda interna sem frete
- Venda interna com frete
- Venda para exportação
- Vendas para o exterior
- Devolução de vendas

#### Para **Compras**:
- Compra interna
- Compra de importação
- Compra com nota devolvida
- Devolução de compras

### 3.2 Configurar Alíquotas Padrão

Em cada operação fiscal, defina:

| Imposto | Alíquota | Exemplo |
|---------|----------|----------|
| **ICMS** | Varia por UF | 18% (SP) |
| **IPI** | Depende do produto | 15% |
| **PIS** | Normal | 1.65% |
| **COFINS** | Normal | 7.6% |
| **ISSQN** | Depende do serviço | 5% |

### 3.3 Configurar Substituição Tributária (ST)

Se sua empresa opera com ST:

1. Crie operações específicas para ST
2. Configure alíquota como **0%** (o ICMS vem na NF anterior)
3. Marque como **Substituição Tributária**

## 💰 Passo 4: Posicionar Fiscais (POS/CST/CFOP)

### 4.1 Acessar Posições Fiscais

Acesse: **Configurações** → **Localização Brasil** → **Posições Fiscais**

### 4.2 Criar Posições

Crie combinações de:
- **Partner Type**: Produtor, Distribuidor, Consumidor
- **Partner Category**: Empresa, Consumidor
- **Product Type**: Produto, Serviço
- **Operation Nature**: Venda, Compra, Devolução, etc

Cada combinação deve ter:
- **CFOP**: Código Fiscal de Operação (ex: 5102 = Venda interna)
- **CST ICMS**: Código de Situação Tributária
- **CST PIS/COFINS**: Situação para PIS e COFINS

## 📝 Passo 5: Criar e Emitir Primeira NFe

### 5.1 Criar Pedido de Venda

1. Acesse: **Vendas** → **Pedidos** → **Novo**
2. Preencha:
   - **Cliente**: Selecione cliente (CNPJ/CPF)
   - **Data da Venda**: Data de emissão
   - **Linhas**: Adicione produtos
   - **Operação Fiscal**: Selecione operação (ex: Venda Interna)
3. Clique em **Salvar**

### 5.2 Confirmar Pedido

1. Clique em **Confirmar**
   - Sistema vai criar fatura automaticamente
   - Imposto será calculado baseado na posição fiscal

### 5.3 Verificar Fatura

Na fatura criada, verifique:
- ✅ ICMS calculado corretamente
- ✅ IPI, PIS, COFINS preenchidos
- ✅ Dados do cliente corretos
- ✅ Endereço de entrega preenchido

### 5.4 Emitir Nota Fiscal Eletrônica

1. Na fatura, localize o botão **Emitir Nota Fiscal Eletrônica**
2. Clique nele
3. Odoo irá:
   - Gerar XML da NFe
   - Assinar digitalmente com certificado A1
   - Transmitir para SEFAZ
   - Receber número de autorização

### 5.5 Validar Emissão

Após transmissão, verifique:
- **Status**: "Autorizada" (verde)
- **Número NFe**: Exibido no campo de NFe
- **Data de Autorização**: Registrada
- **QR Code**: Gerado automaticamente

## 🧪 Passo 6: Testes em Homologação

### 6.1 Validar Estrutura

Em homologação, teste:

1. **NFe Simples**:
   - Venda interna simples
   - Sem frete
   - Sem acréscimos/descontos

2. **NFe com Impostos**:
   - Diferentes alíquotas
   - Substituição Tributária
   - ICMS diferenciado

3. **NFe com Transporte**:
   - Com frete
   - COM dados da transportadora
   - Com volume/peso

4. **NFe com Devolução**:
   - Emitir e depois devolver
   - Validar cancelamento

### 6.2 Ciclos Recomendados

**Ciclo 1 (Básico)**:
- 5-10 notas simples
- Valide cálculo de impostos
- Teste cancelamentos

**Ciclo 2 (Intermediário)**:
- NFe com todos os tipos de CFOP
- Diferentes clientes
- Diferentes produtos

**Ciclo 3 (Avançado)**:
- Substituição Tributária
- Operações com diferimento
- Casos especiais

## ✅ Passo 7: Migrar para Produção

### 7.1 Checklist Pré-Produção

- [ ] Certificado A1 válido (não vence nos próximos 11 meses)
- [ ] Ciclos de teste em homologação concluídos
- [ ] Posições fiscais validadas
- [ ] Alíquotas conferidas com contabilidade
- [ ] Backup de dados realizado
- [ ] Documentação de CFOP validada com fisco

### 7.2 Ativar Produção

1. Em **Localização Brasil** → **Configurações Fiscais**:
   - Altere **Ambiente**: de "Homologação" para **Produção**

2. Verifique:
   - [ ] URL da SEFAZ mudou automaticamente
   - [ ] Certificado continua válido
   - [ ] Caminho dos arquivos correto

### 7.3 Emitir Primeira NFe em Produção

1. Crie um novo pedido
2. Emita a NFe normalmente
3. Valide:
   - Número NFe (sequência correta)
   - Autorização da SEFAZ
   - QR Code gerado

## 🐛 Troubleshooting

### Problema: "Certificado Inválido"

```bash
# Verifique a senha do certificado
# Verifique se .pfx não está corrompido
# Valide data de expiração
docker-compose exec odoo python -c "from OpenSSL import crypto; cert = crypto.load_certificate(crypto.FILETYPE_PEM, open('cert.pem').read()); print(cert.get_notAfter())"
```

### Problema: "Erro ao Conectar SEFAZ"

```bash
# Verifique conectividade
docker-compose exec odoo ping www.sefaz.rs.gov.br  # (substitua pela UF)

# Verifique logs
docker-compose logs odoo | grep -i "sefaz\|transmiss"
```

### Problema: "CFOP Inválido"

- Verifique CFOP com a SEFAZ de sua UF
- Alguns CFOPs são específicos por UF
- Confirme a Vigência do CFOP

### Problema: "Imposto Calculado Incorreto"

```bash
# Verifique regra de posição fiscal
# Valide alíquota configurada
# Confirme regime tributário da empresa
```

## 📚 Referências

- **SEFAZ**: https://www.sefaz.fazenda.gov.br
- **Manual NF-e**: https://www.nfe.fazenda.gov.br
- **OCA Docs**: https://github.com/OCA/l10n-brazil/wiki
- **Receita Federal**: https://www.gov.br/receitafederal

## 📞 Suporte

Para dúvidas:
1. Abra issue no GitHub
2. Consulte documentação OCA
3. Contate SEFAZ de sua UF
4. Procure integrador certificado

---

**Última atualização:** 26 de janeiro de 2026
**Versão:** 1.0
