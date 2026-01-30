# Odoo BR v18 - Docker Setup

Odoo 18 configurado com módulos brasileiros (OCA).

## Repositórios OCA incluídos

- **l10n-brazil**: Localização brasileira (fiscalização, NF-e, SAT, etc)
- **OCA-hr**: Módulos de RH (hr_employee_relative, etc)
- **product-attribute**: Atributos de produto (uom_alias - dependência do l10n_br_fiscal)

## Instalação

### 1. Clone este repositório

```bash
git clone https://github.com/luanscps/odoobr.git
cd odoobr
```

### 2. Clone os repositórios OCA

```bash
mkdir -p extra-addons
cd extra-addons

# Localização brasileira
git clone --depth 1 --branch 18.0 https://github.com/OCA/l10n-brazil.git

# Módulos de RH
git clone --depth 1 --branch 18.0 https://github.com/OCA/hr.git OCA-hr

# Atributos de produto
git clone --depth 1 --branch 18.0 https://github.com/OCA/product-attribute.git

cd ..
```

### 3. Subir containers

```bash
docker-compose up -d
```

### 4. Acessar

```
http://localhost:8069
```

## Configuração

- **Database**: odoo_01
- **User**: odoo
- **Password**: odoo2026
- **Admin password**: odoo2026

## Módulos Brasileiros Disponíveis

### Fiscais
- l10n_br_fiscal: Base para módulos fiscais brasileiros
- l10n_br_nfe: Nota Fiscal Eletrônica (NF-e)
- l10n_br_account_due_list: Lista de contas a pagar/receber
- E muitos outros...

### RH
- hr_employee_relative: Cadastro de familiares/dependentes

## Estrutura do Projeto

```
odoobr/
├── docker-compose.yml
├── odoo.conf          # Configuração do Odoo
├── .gitignore         # Arquivos ignorados
├── README.md          # Este arquivo
└── extra-addons/      # Módulos OCA (clonados localmente)
    ├── l10n-brazil/
    ├── OCA-hr/
    └── product-attribute/
```

## Notas

- Os repositórios OCA **não são versionados** neste repo (estão no .gitignore)
- Eles devem ser clonados durante a instalação
- Apenas o `odoo.conf` contém as referências aos caminhos

## Suporte

- [OCA l10n-brazil](https://github.com/OCA/l10n-brazil)
- [OCA hr](https://github.com/OCA/hr)
- [OCA product-attribute](https://github.com/OCA/product-attribute)
