#!/bin/bash

# Odoo 18.0 Brasil - Initialization Script
# This script sets up directories, environment, and starts the containers
# Assumes macvlan-dhcp network already exists in your CasaOS/Portainer

set -e

echo "========================================"
echo "Odoo 18.0 Brasil - Setup Script"
echo "========================================"
echo ""

# Define colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

echo "Project root: $PROJECT_ROOT"
echo ""

# Step 1: Check Docker
echo -e "${YELLOW}[1/6] Checking Docker...${NC}"
if ! command -v docker &> /dev/null; then
    echo -e "${RED}Docker is not installed. Please install Docker first.${NC}"
    exit 1
fi
echo -e "${GREEN}Docker found: $(docker --version)${NC}"
echo ""

# Step 2: Check Docker Compose
echo -e "${YELLOW}[2/6] Checking Docker Compose...${NC}"
if ! command -v docker-compose &> /dev/null; then
    echo -e "${RED}Docker Compose is not installed. Please install Docker Compose first.${NC}"
    exit 1
fi
echo -e "${GREEN}Docker Compose found: $(docker-compose --version)${NC}"
echo ""

# Step 3: Validate existing macvlan-dhcp network
echo -e "${YELLOW}[3/6] Validating macvlan-dhcp network...${NC}"
if ! docker network ls | grep -q "macvlan-dhcp"; then
    echo -e "${RED}ERROR: Network 'macvlan-dhcp' not found!${NC}"
    echo ""
    echo -e "${YELLOW}Please create this network in your CasaOS/Portainer first:${NC}"
    echo -e "  1. Open Portainer"
    echo -e "  2. Go to Networks"
    echo -e "  3. Create Network with name 'macvlan-dhcp'"
    echo -e "  4. Configure with your network settings (subnet, gateway, parent interface)"
    echo ""
    exit 1
fi
echo -e "${GREEN}Network 'macvlan-dhcp' found and ready${NC}"
echo ""

# Step 4: Create data directories
echo -e "${YELLOW}[4/6] Creating data directories...${NC}"
mkdir -p /DATA/AppData/odoobr/{postgres,odoo,config,addons,logs,filestore,sessions,certificates}
echo -e "${GREEN}Directories created${NC}"
echo ""

# Step 5: Setup environment
echo -e "${YELLOW}[5/6] Setting up environment...${NC}"
if [ ! -f "$PROJECT_ROOT/.env" ]; then
    echo -e "${YELLOW}Creating .env file from .env.example...${NC}"
    cp "$PROJECT_ROOT/.env.example" "$PROJECT_ROOT/.env"
    echo -e "${GREEN}.env file created${NC}"
    echo -e "${YELLOW}⚠  IMPORTANT: Edit .env and change passwords!${NC}"
    echo ""
    read -p "Do you want to edit .env now? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        ${EDITOR:-vim} "$PROJECT_ROOT/.env"
    fi
else
    echo -e "${GREEN}.env file already exists${NC}"
fi
echo ""

# Step 6: Clone OCA l10n-brazil and start containers
echo -e "${YELLOW}[6/6] Preparing modules and starting containers...${NC}"

# Clone OCA modules if not exist
if [ ! -d "/DATA/AppData/odoobr/addons/l10n-brazil" ]; then
    echo -e "${YELLOW}Cloning OCA l10n-brazil repository...${NC}"
    mkdir -p /DATA/AppData/odoobr/addons
    cd /DATA/AppData/odoobr/addons
    git clone --branch 18.0 https://github.com/OCA/l10n-brazil.git
    echo -e "${GREEN}OCA modules cloned${NC}"
else
    echo -e "${GREEN}OCA modules already present${NC}"
fi

# Build and start
cd "$PROJECT_ROOT"
echo -e "${YELLOW}Building Docker image...${NC}"
docker-compose build
echo -e "${YELLOW}Starting containers...${NC}"
docker-compose up -d
echo -e "${GREEN}Containers started${NC}"
echo ""

# Wait for Odoo to be ready
echo -e "${YELLOW}Waiting for Odoo to initialize (may take 2-5 minutes)...${NC}"
for i in {1..60}; do
    if docker-compose logs odoo 2>/dev/null | grep -q "ready\|loaded"; then
        echo -e "${GREEN}Odoo is ready!${NC}"
        break
    fi
    echo -n "."
    sleep 5
done
echo ""
echo ""

# Display summary
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Setup Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "${GREEN}✅ Odoo 18.0 Brasil is now running${NC}"
echo ""
echo -e "${YELLOW}Access URLs:${NC}"
echo "  Odoo:    http://10.41.10.148:8069"
echo "  Adminer: http://10.41.10.149:9999"
echo ""
echo -e "${YELLOW}Login Credentials:${NC}"
echo "  Email:    admin"
echo "  Password: (check ODOO_ADMIN_PASSWORD in .env)"
echo ""
echo -e "${YELLOW}Next Steps:${NC}"
echo "  1. Log in to Odoo at http://10.41.10.148:8069"
echo "  2. Go to Applications → Update Modules List"
echo "  3. Search for 'l10n_br' and install OCA modules"
echo "  4. Configure company fiscal data (CNPJ, IE, etc)"
echo "  5. Upload digital certificate A1"
echo "  6. See docs/CONFIGURACAO_NFe.md for NFe setup"
echo ""
echo -e "${YELLOW}Useful Commands:${NC}"
echo "  View logs:     docker-compose logs -f odoo"
echo "  Stop:          docker-compose down"
echo "  Restart:       docker-compose restart"
echo "  Shell access:  docker-compose exec odoo bash"
echo ""
echo -e "${YELLOW}Documentation:${NC}"
echo "  README.md              - Main documentation"
echo "  docs/CONFIGURACAO_NFe.md - NFe setup guide"
echo "  docs/REDE_MACVLAN.md     - Network configuration"
echo ""
