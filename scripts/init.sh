#!/bin/bash

# Odoo 18.0 Brasil - Initialization Script
# This script sets up directories, environment, and starts the containers

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
echo -e "${YELLOW}[1/8] Checking Docker...${NC}"
if ! command -v docker &> /dev/null; then
    echo -e "${RED}Docker is not installed. Please install Docker first.${NC}"
    exit 1
fi
echo -e "${GREEN}Docker found: $(docker --version)${NC}"
echo ""

# Step 2: Check Docker Compose
echo -e "${YELLOW}[2/8] Checking Docker Compose...${NC}"
if ! command -v docker-compose &> /dev/null; then
    echo -e "${RED}Docker Compose is not installed. Please install Docker Compose first.${NC}"
    exit 1
fi
echo -e "${GREEN}Docker Compose found: $(docker-compose --version)${NC}"
echo ""

# Step 3: Check macvlan network
echo -e "${YELLOW}[3/8] Checking macvlan-dhcp network...${NC}"
if ! docker network ls | grep -q macvlan-dhcp; then
    echo -e "${YELLOW}Creating macvlan-dhcp network...${NC}"
    docker network create -d macvlan \
        --subnet=10.41.10.0/24 \
        --gateway=10.41.10.1 \
        -o parent=eth0 \
        macvlan-dhcp
    echo -e "${GREEN}Network created successfully${NC}"
else
    echo -e "${GREEN}Network already exists${NC}"
fi
echo ""

# Step 4: Create directories
echo -e "${YELLOW}[4/8] Creating data directories...${NC}"
mkdir -p /DATA/AppData/odoobr/{postgres,odoo,config,addons,logs,filestore,sessions,certificates}
echo -e "${GREEN}Directories created${NC}"
echo ""

# Step 5: Setup environment
echo -e "${YELLOW}[5/8] Setting up environment...${NC}"
if [ ! -f "$PROJECT_ROOT/.env" ]; then
    echo -e "${YELLOW}Creating .env file from .env.example...${NC}"
    cp "$PROJECT_ROOT/.env.example" "$PROJECT_ROOT/.env"
    echo -e "${GREEN}.env file created${NC}"
    echo -e "${YELLOW}⚠ IMPORTANT: Edit .env and change passwords before starting!${NC}"
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

# Step 6: Clone OCA l10n-brazil
echo -e "${YELLOW}[6/8] Preparing OCA l10n-brazil modules...${NC}"
if [ ! -d "/DATA/AppData/odoobr/addons/l10n-brazil" ]; then
    echo -e "${YELLOW}Cloning OCA l10n-brazil repository...${NC}"
    cd /DATA/AppData/odoobr/addons
    git clone --branch 18.0 https://github.com/OCA/l10n-brazil.git
    echo -e "${GREEN}OCA modules cloned successfully${NC}"
else
    echo -e "${GREEN}OCA modules already cloned${NC}"
fi
echo ""

# Step 7: Build and start containers
echo -e "${YELLOW}[7/8] Building Docker image...${NC}"
cd "$PROJECT_ROOT"
docker-compose build
echo -e "${GREEN}Image built successfully${NC}"
echo ""

# Step 8: Start containers
echo -e "${YELLOW}[8/8] Starting containers...${NC}"
docker-compose up -d
echo -e "${GREEN}Containers started${NC}"
echo ""

# Wait for Odoo to be ready
echo -e "${YELLOW}Waiting for Odoo to initialize (this may take a few minutes)...${NC}"
for i in {1..60}; do
    if docker-compose logs odoo 2>/dev/null | grep -q "ready"; then
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
echo "Access Odoo at:"
echo -e "${YELLOW}http://10.41.10.148:8069${NC}"
echo ""
echo "Default credentials:"
echo "  Email: admin"
echo "  Password: (from ODOO_ADMIN_PASSWORD in .env)"
echo ""
echo "Database Manager (Adminer):"
echo -e "${YELLOW}http://10.41.10.149:9999${NC}"
echo ""
echo "Next steps:"
echo "  1. Log in to Odoo"
echo "  2. Install OCA modules: Applications → Update Modules List"
echo "  3. Search for 'l10n_br' and install modules"
echo "  4. Configure company fiscal data"
echo "  5. Upload digital certificate A1"
echo ""
echo "Useful commands:"
echo "  View logs: docker-compose logs -f odoo"
echo "  Stop: docker-compose down"
echo "  Restart: docker-compose restart"
echo ""
echo -e "${YELLOW}For more information, see README.md${NC}"
