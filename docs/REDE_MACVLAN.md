# Configuração da Rede macvlan-dhcp para Odoo 18.0 Brasil

## 🗌 Visão Geral

Este guia descreve como configurar a rede **macvlan-dhcp** para usar com Odoo 18.0 em seu Portainer.

## 🌐 O que é macvlan?

**macvlan** (MAC VLAN) permite que containers Docker obtenham IPs próprios da sua rede corporativa, não de uma rede virtual.

**Vantagens:**
- ✅ Containers acessíveis diretamente da rede
- ✅ IP fixo no segmento de rede
- ✅ Sem porta mapping complexo
- ✅ Ideal para infraestrutura corporativa
- ✅ Integração com Portainer mais simples

## 🛠️ Pré-requisitos

1. **Docker** instalado e rodando
2. **Interface de rede** conhecida (geralmente `eth0`)
3. **Subnet** da sua rede (ex: `10.41.10.0/24`)
4. **Gateway** da rede (ex: `10.41.10.1`)
5. **IPs disponíveis** na subnet

## 🖥️ Passo 1: Verificar Interface de Rede

```bash
# Listar interfaces de rede
ip link show

# ou
ifconfig

# Procure por algo como:
# eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> ...
```

## 🌐 Passo 2: Criar a Rede macvlan-dhcp

### Opção A: Via Docker CLI (linha de comando)

```bash
# Criar rede macvlan-dhcp
docker network create -d macvlan \
  --subnet=10.41.10.0/24 \
  --gateway=10.41.10.1 \
  -o parent=eth0 \
  macvlan-dhcp

# Verificar criação
docker network ls
```

### Opção B: Via Portainer

1. Acesse **Portainer** (http://seu-portainer:9000)
2. Selecione seu **endpoint** (Docker)
3. Navegue: **Networks** → **Create Network**
4. Preencha:
   - **Name**: `macvlan-dhcp`
   - **Driver**: `macvlan`
   - **IPAM Configuration**:
     - Subnet: `10.41.10.0/24`
     - Gateway: `10.41.10.1`
   - **Driver Options**:
     - Key: `parent`
     - Value: `eth0`
5. Clique em **Create Network**

### Opção C: Via docker-compose (não recomendado para primeira criação)

Já implementado no arquivo `docker-compose.yml` deste repositório.

## 📈 Passo 3: Atribuir IPs aos Containers

### No docker-compose.yml

```yaml
services:
  odoo-pg:
    networks:
      macvlan-dhcp:
        ipv4_address: 10.41.10.147  # IP do PostgreSQL

  odoo:
    networks:
      macvlan-dhcp:
        ipv4_address: 10.41.10.148  # IP do Odoo

  adminer:
    networks:
      macvlan-dhcp:
        ipv4_address: 10.41.10.149  # IP do Adminer

networks:
  macvlan-dhcp:
    external: true
    driver: macvlan
    driver_opts:
      parent: eth0
    ipam:
      config:
        - subnet: 10.41.10.0/24
          gateway: 10.41.10.1
```

## ⚠️ Passo 4: Evitar Conflitos de IP

### Verificar IPs Já em Uso

```bash
# Verificar IPs da rede (requer nmap)
nmap -sn 10.41.10.0/24

# ou com arp-scan
arp-scan 10.41.10.0/24

# ou com ping
for i in {1..255}; do ping -c 1 10.41.10.$i 2>/dev/null && echo "10.41.10.$i: UP"; done
```

### Lista de IPs Já em Uso (da sua infraestrutura)

De acordo com sua mensagem:

| Serviço | IP | MAC | Status |
|---------|----|----|--------|
| dexplorer | 10.41.10.150 | 62:4b:88:d5:64:6f | Ativo |
| grafana | 10.41.10.141 | 0a:07:53:98:a6:e2 | Ativo |
| mktxp | 10.41.10.146 | e6:8e:ef:7f:59:c0 | Ativo |
| prometheus | 10.41.10.140 | de:3e:76:7c:e7:7a | Ativo |
| node-exporter | 10.41.10.144 | f2:05:56:e7:63:bb | Ativo |
| adguard-host | 10.41.10.130 | e2:23:a4:0d:bf:fc | Ativo |
| portainer_agent | 10.41.10.134 | 0a:15:79:5e:fc:b3 | Ativo |
| jackett | 10.41.10.143 | 52:54:00:00:10:03 | Ativo |
| big-bear-homarr | 10.41.10.142 | 52:54:00:00:10:01 | Ativo |
| caddy | 10.41.10.128 | 4e:d8:28:7d:76:ff | Ativo |
| adminer | 10.41.10.131 | ae:28:38:b6:fb:22 | Ativo |
| mariadb | 10.41.10.129 | 56:89:02:d0:ab:16 | Ativo |

### IPs Disponíveis para Odoo

Com base na lista acima, **IPs livres sugeridos**:
- **10.41.10.147** - PostgreSQL ✅
- **10.41.10.148** - Odoo ✅
- **10.41.10.149** - Adminer ✅
- **10.41.10.132** - (se precisar de mais)
- **10.41.10.133** - (se precisar de mais)
- **10.41.10.135-139** - (livres)
- **10.41.10.151-200** - (livres para expansão)

## 📁 Passo 5: Verificar Conectividade

```bash
# Após iniciar os containers
docker ps

# Verificar IP do container
docker inspect odoobr-odoo | grep -i "ipaddress\|ipv4"

# Testar ping do host para container
ping 10.41.10.148

# Testar conectividade do container
docker-compose exec odoo ping 10.41.10.147  # PostgreSQL
```

## 🐏 macvlan vs bridge (Comparação)

| Aspecto | macvlan | bridge |
|--------|---------|--------|
| **IP** | IP real da rede | IP virtual (nat) |
| **Acesso externo** | Direto | Via port-mapping |
| **Performance** | Melhor | Bom |
| **Complexidade** | Média | Baixa |
| **Ideal para** | Infraestrutura | Desenvolvimento |
| **Em Portainer** | Mais fácil | Port mapping manual |

## 🐄 Problema Comum: Container sem Conectividade

### Sintoma:
Container está rodando mas não responde ao IP atribuído.

### Soluções:

**1. Verificar IP do container:**
```bash
docker inspect odoobr-odoo | grep -i ipv4address
```

**2. Verificar se a rede foi criada corretamente:**
```bash
docker network inspect macvlan-dhcp
```

**3. Verificar logs do container:**
```bash
docker logs odoobr-odoo
```

**4. Recriar a rede (se necessário):**
```bash
# Remover containers primeiro
docker-compose down

# Remover rede
docker network rm macvlan-dhcp

# Recriar
docker network create -d macvlan \
  --subnet=10.41.10.0/24 \
  --gateway=10.41.10.1 \
  -o parent=eth0 \
  macvlan-dhcp

# Reiniciar
docker-compose up -d
```

## 🔐 Problema: Conflito de IP

### Sintoma:
Docker avisa que IP já está em uso.

### Solução:

1. Verifique que não há outro container usando esse IP:
```bash
docker inspect $(docker ps -aq) | grep -i "ipv4address" | sort
```

2. Se houver conflito, mude o IP no `.env` ou `docker-compose.yml`

3. Reinicie:
```bash
docker-compose down
docker-compose up -d
```

## 📚 Referências

- [Docker macvlan](https://docs.docker.com/network/macvlan/)
- [Docker Compose networking](https://docs.docker.com/compose/networking/)
- [Portainer Networks](https://docs.portainer.io/user/docker/networks/)

## 📄 Resumo Passo-a-Passo

1. ✅ Verifique interface de rede (`eth0`)
2. ✅ Crie rede macvlan-dhcp via Portainer ou CLI
3. ✅ Configure IPs nos containers (.env)
4. ✅ Evite conflitos com IPs existentes
5. ✅ Valide conectividade com `ping`
6. ✅ Acesse Odoo no IP configurado (10.41.10.148:8069)

---

**Criado em:** 26 de janeiro de 2026
**Versão:** 1.0
